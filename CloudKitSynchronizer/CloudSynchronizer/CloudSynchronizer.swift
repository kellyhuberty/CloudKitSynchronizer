//
//  CloudSynchronizer.swift
//  VHX
//
//  Created by Kelly Huberty on 2/9/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit
import GRDB

class SynchronizedTable : SynchronizedTableProtocol{
    let tableName:String
    
    init(table:String){
        tableName = table
    }
}

protocol SynchronizedTableProtocol {
    var tableName:String { get }
}

class CloudErrorPrototype : LocalizedError {
    
    var localizedDescription: String
    
    init(_ description:String) {
        localizedDescription = description
    }
}

typealias DatabaseValueDictionary = [String:DatabaseValueConvertible?]

enum CloudSynchronizerError: Error {
    
    case sqlLite(_ error:Error)
    case cloudKitError(_ error:Error)
    case archivalError(_ error:Error)
    
}

protocol CloudSynchronizerDelegate : class {
    
    func cloudSynchronizer(_ synchronizer:CloudSynchronizer, errorOccured:CloudSynchronizerError)
    
    func cloudSynchronizerNetworkBecameUnavailable(_ synchronizer:CloudSynchronizer)
    
    func cloudSynchronizerNetworkBecameAvailable(_ synchronizer:CloudSynchronizer)
    
}


class CloudSynchronizer {
    
    static let Domain: String = "com.kellyhuberty.CloudKitSynchronizer"
    
    struct TableNames{
        static let Migration = "SyncMigration"
        static let CloudRecords = "SyncCloudRecords"
        static let ChangeTags = "SyncChangeTags"
    }
    
    enum Status {
        case unstarted
        case syncing
        case stopped
        case halted(error:Error?)
    }
    
    static let Prefix = "cloudRecord"
    
    //Constants
    let container:CKContainer = CKContainer.default()
    let cloudDatabase:CKDatabase = CKContainer.default().privateCloudDatabase
    let zoneId = CKRecordZone.ID(zoneName: CloudSynchronizer.Domain,
                                     ownerName: CKCurrentUserDefaultName)
    
    let localDatabasePool:DatabaseQueue

    private let _operationFactory:OperationFactory

    private let _tableObserverFactory:TableObserverFactory

    
    private var status:Status
    
    var operationFactory:OperationFactory? {
        get{
            switch status {
            case .syncing:
                return _operationFactory
            default:
                return nil
            }
        }
    }
    
    private var currentChangeTagCache:CKServerChangeToken?
    
    var currentChangeTag:CKServerChangeToken? {
        get{
            guard currentChangeTagCache == nil else {
                return currentChangeTagCache
            }
            
            //Error: .changeTokenSaveError
            let tag = try! localDatabasePool.read { (db) -> CloudChangeTag? in
                return try CloudChangeTag.fetchOne(db,
                                                    """
                                                    SELECT *
                                                    FROM \(TableNames.ChangeTags)
                                                   """)
            }
            
            //Error: changeTokenSaveError
            currentChangeTagCache = try! tag?.getChangeToken()
            
            return currentChangeTagCache
        }
        set{
            
            guard let newValue = newValue else{
                return
            }
            
            //Error: changeTokenSaveError
            let newTag = try! CloudChangeTag(token:newValue, processDate: Date())
            
            //Error: changeTokenSaveError
            try! localDatabasePool.write { (db) in
                try newTag.save(db)
            }
            
            //Error: changeTokenSaveError
            currentChangeTagCache = try! newTag.getChangeToken()
        }
    }
    
    var observers:[TableObserver] = []
    
    weak var delegate: CloudSynchronizerDelegate?
    
    init(databaseQueue:DatabaseQueue,
         operationFactory:OperationFactory? = nil,
         tableObserverFactory:TableObserverFactory? = nil ) throws {
        
        self.localDatabasePool = databaseQueue
        
        if let operationFactory = operationFactory {
            self._operationFactory = operationFactory
        }
        else {
            self._operationFactory = CloudKitOperationFactory()
        }
        
        if let tableObserverFactory = tableObserverFactory {
            self._tableObserverFactory = tableObserverFactory
        }
        else {
            self._tableObserverFactory = SQLiteTableObserverFactory(databaseQueue: databaseQueue)
        }
        
        self.status = .unstarted
        
        //Error: databaseMigration
        try! databaseQueue.write { (db) in
            try runSynchronizerMigrations(db)
        }
    }
    
    public func startSync() {

        var start: Bool = false
        
        switch status {
        case .unstarted:
            start = true
        case .stopped:
            break
        case .syncing:
            break
        case .halted(_):
            break
        }

        guard start else {
            return
        }
        
        initilizeZones{            
            self.status = .syncing
        }
        
    }
    
    public func stopSync() {
        status = .stopped
    }
    
    var synchronizedTables:[SynchronizedTableProtocol] = [] {
        didSet{
            setSyncRequest()
        }
    }
    
    public func processCloudNotificationPayload(_ userInfo:[AnyHashable : Any]){
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        //TODO: Support for push notification changes
        
    }
    
    private func setSyncRequest(){
        
        for table in synchronizedTables {
            //Error: table setup error
            try! startObservingTable(table)
        }
        
    }
    
    private func addTableObserver(_ tableObserver:TableObserver){
        
        observers.append(tableObserver)
        
    }
    
    private func tableObserver(for name:String) -> TableObserver{
        
        for observer in observers {
            if observer.tableName == name {
                return observer
            }
        }
        
        fatalError("Unable to find observed table \(name)")
        
    }
    
    private func startObservingTable(_ syncedTable:SynchronizedTableProtocol) throws {
        
        let table = syncedTable.tableName
        let tableObserver = _tableObserverFactory.newTableObserver(table)
        tableObserver.delegate = self
        addTableObserver(tableObserver)
        
    }
    
    private func mapAndCheckoutRecord(from tableRows:[TableRow], from table:String, for status:CloudRecordStatus) -> [CKRecord] {
        
        let mapper = tableObserver(for: table).mapper
        
        let rowIdentifers = tableRows.map { $0.identifier }

        let ckRecords = checkoutRecord(with: rowIdentifers, from: table, for: status, sorted: true)
        
        let ckRecordsDictionary:[String:CKRecord] = ckRecords.reduce(into: [String:CKRecord]()) { return $0[$1.recordID.recordName] = $1 }
        
        var mappedCkRecords = [CKRecord]()
        
        for row in tableRows {
            
            guard let ckRecord = ckRecordsDictionary[row.identifier] else {
                continue
            }
            
            let mappedCKRecord = mapper.map(data: row.dict, to: ckRecord)
            
            mappedCkRecords.append(mappedCKRecord)
            
        }
        
        return mappedCkRecords
        
    }
    
    
    private func checkoutRecord(with ids:[String], from table:String, for status:CloudRecordStatus, sorted: Bool = true) -> [CKRecord] {
        
        guard ids.count > 0 else {
            return []
        }
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< ids.count {
            bindingsArr.append("?")
        }
        
        var updateRecords:[CKRecord] = []
        var createRecords:[CKRecord] = []
        
        //Error: checkout eror
        try! localDatabasePool.write { (db) in

            
            //UPDATE ACTIVE RECORDS
            var argumentsArr = [status.rawValue]
            
            argumentsArr.append(contentsOf: ids)
            
            let updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
            
            try db.execute(updateQuery, arguments: StatementArguments( argumentsArr ) )
            
            let selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
            
            //QUERY RECORDS
            let request = SQLRequest<CloudRecord>(selectQuery, arguments: StatementArguments(ids), adapter: nil, cached: false)

            let results = try request.fetchAll(db)
            
            updateRecords = results.compactMap({ (cloudRecord) -> CKRecord? in
                return cloudRecord.record
            })
            
            //CREATE CKRECORDS NEEDED
            let updatedIds = updateRecords.map({ (ckRecord) -> String in
                return ckRecord.recordID.recordName
            })
            
            let createIds = Set(ids).subtracting(updatedIds)
            
            for createId in createIds {
                let newRecord = newCloudRecord(with: createId, tableName: table, ckRecord:nil, status: status)
                try newRecord.save(db)
                //createCloudRecords.append( newRecord)
                
                guard let record = newRecord.record else{
                    continue
                }
                
                createRecords.append(record)

            }
            
        }
        
        updateRecords.append(contentsOf:createRecords)
        
        //Checkout a CK record
        return updateRecords
    }
    
    private func newCloudRecord(with identifier:String, tableName:String, ckRecord:CKRecord?, status: CloudRecordStatus) -> CloudRecord{
        
        let cloudRecord = CloudRecord(identifier: identifier, tableName: tableName, status: status)
        
        if let ckRecord = ckRecord {
            cloudRecord.record = ckRecord
        }else{
            cloudRecord.record = createNewCKRecord(with:identifier, tableName:tableName)
        }
        
        return cloudRecord
    }
    
    private func createNewCKRecord(with identifier:String, tableName:String) -> CKRecord{
        let ckId = CKRecord.ID(recordName: identifier, zoneID: zoneId)
        let ckRecord = CKRecord(recordType: tableName, recordID: ckId)
        return ckRecord
    }
    
    private func checkinCloudRecords(_ records:[CKRecord], with status:CloudRecordStatus) {
        //After a modification has completed, check in a record.
        
        
        let allRecords = records.sorted(by: { (leftRecord, rightRecord) -> Bool in
            leftRecord.recordID.recordName > rightRecord.recordID.recordName
        })
        
        let allRecordIds = records.map { (record) -> CKRecord.ID in
            return record.recordID
        }
        
        let allRecordIdNames = allRecordIds.map { (recordId) -> String in
            return recordId.recordName
        }
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< allRecordIdNames.count {
            bindingsArr.append("?")
        }
        
        //Error: Cloud Checkin Error
        try! localDatabasePool.write { (db) in
        
            var cloudRecordsToSave:[CloudRecord] = []
            
            let selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) ) ORDER BY `identifier` ASC"
            
            let request = SQLRequest<CloudRecord>(selectQuery, arguments: StatementArguments(allRecordIdNames), adapter: nil, cached: false)
            
            var availableCloudRecords = try CloudRecord.fetchAll(db, request)
            
            for record in allRecords {
                if record.recordID.recordName == availableCloudRecords.first?.identifier {
                    let cloudRecord = availableCloudRecords.removeFirst()
                    cloudRecord.status = status
                    cloudRecord.record = record
                    cloudRecordsToSave.append(cloudRecord)
                }else{
                    let cloudRecord = self.newCloudRecord(with: record.recordID.recordName, tableName: record.recordType, ckRecord: record, status:status)
                    cloudRecordsToSave.append(cloudRecord)
                }
            }
            
            for cloudRecord in cloudRecordsToSave {
                try cloudRecord.save(db)
            }
            
        }
        
    }
    
    private func checkinCloudRecordIds(_ recordIds:[CKRecord.ID], with status:CloudRecordStatus) {
        //After a modification has completed, check in a record.
        
        let recordIdStrings = recordIds.map { (recordIds) -> String in
            return recordIds.recordName
        }
        
        //Error: Cloud Checkin Error
        try! localDatabasePool.write { (db) in
            try checkinCloudRecords(identifiers:recordIdStrings, with: status, database: db)
        }
    }
    
    private func checkinCloudRecords(identifiers:[String], with status:CloudRecordStatus, database:Database) throws {
        //After a modification has completed, check in a record.
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< identifiers.count {
            bindingsArr.append("?")
        }
        
        let args = [status.rawValue] + identifiers
    
        let updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
        
        try database.execute(updateQuery, arguments: StatementArguments(args) )
    
    }
    
    func initilizeZones(completion:@escaping ()->Void) {
        let createZoneOperation = _operationFactory.newZoneAvailablityOperation()
        createZoneOperation.zoneIds = [zoneId]
        
        createZoneOperation.completionBlock = {
            completion()
        }
        createZoneOperation.start()
    }
    
    func runSynchronizerMigrations(_ db:Database) throws {
        
        try self.initilizeSyncDatabase(db)
        
    }
    
    func initilizeSyncDatabase(_ db:Database) throws {

        var version = UserDefaults.standard.integer(forKey: UserDefaultsKeys.migrationVersion.description )
        
        if version <= 0 {

            version += 1
            
            try db.create(table: TableNames.Migration, body: { (table) in
                table.column("version", Database.ColumnType.text).unique(onConflict: Database.ConflictResolution.replace).primaryKey()
                table.column("completionDate", Database.ColumnType.date).unique(onConflict: Database.ConflictResolution.replace)
            })

            try db.create(table: TableNames.CloudRecords, body: { (table) in
                table.column("identifier", Database.ColumnType.text).unique(onConflict: Database.ConflictResolution.replace).primaryKey()
                table.column("tableName", Database.ColumnType.text)
                table.column("ckRecordData", Database.ColumnType.blob)
                table.column("cloudChangeTag", Database.ColumnType.text)
                table.column("status", Database.ColumnType.text).notNull()
                table.column("changeDate", Database.ColumnType.text)
            })
            
            try db.create(table: TableNames.ChangeTags, body: { (table) in
                table.autoIncrementedPrimaryKey("identifier")
                table.column("changeTokenData", Database.ColumnType.blob)
                table.column("processDate", Database.ColumnType.text)
            })

        }
        
        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.migrationVersion.description)
    }
    
    private func propegatePulledChangesToDatabase() throws {
        
        try localDatabasePool.write { (db) in
            
            let deletedCRSQL =
                """
                    SELECT
                        `\(CloudSynchronizer.TableNames.CloudRecords)`.*
                    FROM
                        `\(CloudSynchronizer.TableNames.CloudRecords)`
                    WHERE
                        `status` = ?
                """
            
            let deletedCRRequest = SQLRequest<CloudRecord>(deletedCRSQL, arguments: StatementArguments([CloudRecordStatus.pullingDelete.rawValue]), adapter: nil, cached: false)
            
            let cloudRecordsToDelete = try CloudRecord.fetchAll(db, deletedCRRequest)
            
            
            let updatedCRSQL =
                """
                    SELECT
                    `\(CloudSynchronizer.TableNames.CloudRecords)`.*
                    FROM
                    `\(CloudSynchronizer.TableNames.CloudRecords)`
                    WHERE
                    `status` = ?
                """
            
            let updatedCRRequest = SQLRequest<CloudRecord>(updatedCRSQL, arguments: StatementArguments([CloudRecordStatus.pullingUpdate.rawValue]), adapter: nil, cached: false)
            
            let cloudRecordsToUpdate = try CloudRecord.fetchAll(db, updatedCRRequest)
            
            //Deletes
            var cloudRecordsToDeleteGrouped = [String:[String]]()
            
            for cloudRecord in cloudRecordsToDelete {
                var recordGroup = cloudRecordsToDeleteGrouped[cloudRecord.tableName] ?? [String]()
                recordGroup.append(cloudRecord.identifier)
                cloudRecordsToDeleteGrouped[cloudRecord.tableName] = recordGroup
            }
            
            for (tableName, group) in cloudRecordsToDeleteGrouped {

                disableCloudObservers(for:tableName)
                try propegatesDeletesToDatabase(group, in: tableName, database: db)
                enableCloudObservers(for:tableName)

            }
        
            

            
            //Updates
            var cloudRecordsToUpdateGrouped = [String:[CKRecord]]()

            for cloudRecord in cloudRecordsToUpdate {
                var recordGroup = cloudRecordsToUpdateGrouped[cloudRecord.tableName] ?? [CKRecord]()
                guard let ckRecord = cloudRecord.record else {continue}
                recordGroup.append(ckRecord)
                cloudRecordsToUpdateGrouped[cloudRecord.tableName] = recordGroup
            }
            
            for (tableName, group) in cloudRecordsToUpdateGrouped {

                disableCloudObservers(for:tableName)
                try propegatesUpdatesToDatabase(group, in: tableName, database: db)
                enableCloudObservers(for:tableName)

            }

            let allCloudRecords = cloudRecordsToDelete + cloudRecordsToUpdate
            
            let allIdentifiers = allCloudRecords.map({ (record) -> String in
                return record.identifier
            })
            
            //Error: Cloud Checkin Error
            try checkinCloudRecords(identifiers:allIdentifiers, with: .synced, database: db)
            
        }
        
    }
    
    private func propegatesDeletesToDatabase(_ identifiers:[String], in tableName:String, database:Database) throws {
        
        let args = StatementArguments(identifiers)
        
        //Clean up from CloudRecordTable
        try database.execute("DELETE FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(identifiers.sqlPlaceholderString()) )", arguments: args)
        
        //Delete From Table
        try database.execute("DELETE FROM `\(tableName)` WHERE `identifier` IN ( \(identifiers.sqlPlaceholderString()) )", arguments: args)
    }
    
    private func propegatesUpdatesToDatabase(_ ckRecords:[CKRecord], in tableName:String, database:Database) throws {
        
        
        let mapper = tableObserver(for:tableName).mapper
        
        let sortedSqlColumnString = mapper.sortedSqlColumnString()
        
        let sqlValues = mapper.sqlValues(forRecords: ckRecords)
        
        let sqlValuesString = mapper.sqlValuesString(forRecords: ckRecords)

        let arguments = StatementArguments(sqlValues)
        
        //Update cloud record table
        try database.execute("""
                                INSERT OR REPLACE INTO \(tableName) \(sortedSqlColumnString) VALUES \(sqlValuesString)
                              """
            , arguments: arguments)
        
        
        
        //Clean up from CloudRecordTable
        
    }
    
    private func disableCloudObservers(for table:String) {
        let observer = tableObserver(for: table)
        observer.isObserving = false
    }
    
    private func enableCloudObservers(for table:String) {
        let observer = tableObserver(for: table)
        observer.isObserving = true
    }
    
    public func refreshFromCloud(_ completion: @escaping (() -> Void)) {

        guard let operation = operationFactory?.newPullOperation(delegate: self) else {
            return
        }
        
        operation.zoneId = zoneId
        operation.previousServerChangeToken = currentChangeTag
        
        operation.completionBlock = {
            completion()
        }
        operation.start()
    }
    
}

extension CloudSynchronizer: CloudRecordPushOperationDelegate {
    
    func cloudPushOperation(_ operation: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus) {
        //TODO: Include better error handeling

        switch status {
        case .error(let error):
            break
        case .success:
            self.checkinCloudRecords(processedRecords, with: .synced)
        }

    }
    
    func cloudPushOperationDidComplete(_ operation: CloudRecordPushOperation) {
        //No-Op
        //TODO: If possible, and if in makes sense,
        //See if we can add some kind of consolidated changes here
        //To improve performance.
    }
    
}

extension CloudSynchronizer: CloudRecordPullOperationDelegate {
    
    func cloudPullOperation(_ operation: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus) {
        self.checkinCloudRecords(processedUpdatedRecords, with: .pullingUpdate)
        
        switch status {
        case .error(let error):
            break
        case .success:
            self.checkinCloudRecords(processedUpdatedRecords, with: .pullingUpdate)
        }
    }
    
    func cloudPullOperation(_ operation: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus) {
        
        switch status {
        case .error(let error):
            break
        case .success:
            self.checkinCloudRecordIds(processedDeletedRecordIds, with: .pullingDelete)
        }
        
    }
    
    func cloudPullOperation(_ operation: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?) {
        self.currentChangeTag = pulledNewChangeTag
    }
    
    func cloudPullOperationDidComplete(_ operation: CloudRecordPullOperation) {
        try! self.propegatePulledChangesToDatabase()
    }
    
}

extension CloudSynchronizer: TableObserverDelegate {
    
    func tableObserver(_ observer: TableObserver, created: [TableRow], updated: [TableRow], deleted: [TableRow]) {
        
        let table = observer.tableName
        
        let deletedIdentifiers = deleted.map{ $0.identifier }
        
        let recordsToDelete = self.checkoutRecord(with: deletedIdentifiers, from: table , for: .pushingDelete)
        let recordsToUpdate = self.mapAndCheckoutRecord(from: updated, from: table, for: .pushingUpdate)
        let recordsToCreate = self.mapAndCheckoutRecord(from: created, from: table , for: .pushingUpdate)
        
        let deleteIds = recordsToDelete.map{ $0.recordID }
        
        let recordsToCreateOrUpdate = recordsToUpdate + recordsToCreate
        
        guard let currentPushOperation =
            self.operationFactory?.newPushOperation(delegate: self) else {
                return
        }
        
        
        currentPushOperation.updates = recordsToCreateOrUpdate
        currentPushOperation.deleteIds = deleteIds
        
        currentPushOperation.start()
    }
    
}



class TableRow : FetchableRecord {
    
    
    let dict:[String: DatabaseValue?]

    
    required init(row: Row){
        dict = Dictionary(row, uniquingKeysWith: { (left, _) in left })
    }
    
    var identifier:String {
        
        guard let recordId = dict["identifier"] else{
            fatalError()
        }
        guard let stringValue = String.fromDatabaseValue(recordId!) else{
            fatalError()
        }
        return stringValue
    }
    
    
}

extension TableRow: Hashable{

    static func == (lhs: TableRow, rhs: TableRow) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}

class CloudRecord : Model, Codable{
    
    static var databaseTableName: String {
        return CloudSynchronizer.TableNames.CloudRecords
    }
    
    struct Identifier{
        let identifier:String
        let tableName:String
    }
    
    enum CodingKeys : CodingKey {
        case identifier
        case tableName
        case ckRecordData
        case cloudChangeTag
        case changeDate
        case status
    }
    
    init(identifier:String, tableName:String, status: CloudRecordStatus) {
        self.identifier = identifier
        self.tableName = tableName
        self.status = status
    }
    
    let identifier:String
    let tableName:String
    var ckRecordData:Data? = nil
    var cloudChangeTag:String? = nil
    var changeDate:Date? = nil
    var status: CloudRecordStatus
    
    private var _record:CKRecord? = nil
    
    var record:CKRecord?{
        get{

            guard let data = ckRecordData else{
                return nil
            }
            
            if let record = _record {
                return record
            }

            do{
                _record = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.self, from: data)
            }catch{
                NSLog("Record Decode warning: \(error)")
                _record = nil
            }
            return _record
            
        }
        set{
            ckRecordData = try? NSKeyedArchiver.archivedData(withRootObject: newValue as Any, requiringSecureCoding: true)
            _record = newValue
        }
    }
}

class CloudChangeTag : Model, Codable{
    
    static var databaseTableName: String {
        return CloudSynchronizer.TableNames.ChangeTags
    }
    
    var changeTokenData: Data
    let processDate: Date

    init(token: CKServerChangeToken, processDate: Date = Date()) throws {
        self.changeTokenData = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        self.processDate = processDate
    }
    
    func getChangeToken() throws -> CKServerChangeToken{
        //Error: .changeTokenArchiveError
        return try! NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: changeTokenData)!
    }
    
    func setChangeToken(_ newToken: CKServerChangeToken) throws{
        //Error: .changeTokenArchiveError
        changeTokenData = try! NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: true)
    }
    
    
}

enum UserDefaultsKeys : CustomStringConvertible {
    var description: String {
        switch self {
        case .migrationVersion:
            return UserDefaultsKeys.Domain + ".migrationVersion"
        }
        
    }
    
    static let Domain = "com.kellyhuberty.CloudKitSynchronizer"

    case migrationVersion
}

protocol OperationFactory : class{
    func newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation
    func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation
    func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation
}

protocol TableObserverFactory : class{
    func newTableObserver(_ tableName: String) -> TableObserver
}

class CloudRecordMapper {
    
    let columns:[String]
    let tableName:String
    
    let sortedColumns:[String]
    
    init(tableName:String, columnNames:[String]) {
        self.columns = columnNames
        self.tableName = tableName
        
        var newColumns = columns
        newColumns.sort()
        if let index = newColumns.index(of: "identifier") {
            newColumns.remove(at: index)
            newColumns.insert("identifier", at: 0)
        }
        sortedColumns = newColumns
    }
    
    func map(data:[String:DatabaseValue?], to record:CKRecord) -> CKRecord{

        for (key, value) in data{
            guard let value = value else{
                record.setValue(nil, forKey: key)
                continue
            }
            
            switch value.storage {
            case .blob(let data):
                record.setValue(data, forKey: key)
            case .double(let double):
                record.setValue(double, forKey: key)
            case .int64(let integer):
                record.setValue(integer, forKey: key)
            case .string(let string):
                record.setValue(string, forKey: key)
            case .null:
                record.setValue(nil, forKey: key)
            }
            
        }

        return record
    }
    
    func map(record:CKRecord) -> [String:DatabaseValue?]{
        
        var allValues = [String:DatabaseValue?]()
        
        for key in record.allKeys() {

            guard let value = record[key] else{
                allValues[key] = nil
                continue
            }
            
            switch value {
            case let value as Data:
                allValues[key] = DatabaseValue(value: value)
            case let value as Double:
                allValues[key] = DatabaseValue(value: value)
            case let value as Int:
                allValues[key] = DatabaseValue(value: value)
            case let value as String:
                allValues[key] = DatabaseValue(value: value)
            default:
                fatalError("Unsupported CKRecord Type")
            }
            
        }
        
        return allValues
    }
    
    func sortedSqlColumnString() -> String {
        
        return "(" + sortedColumns.joined(separator: ", ") + ")"
        
    }
    
    func sortedSqlValues(_ sqlValues:[String:DatabaseValueConvertible?]) -> [DatabaseValueConvertible?] {
        
        return sortedColumns.map { (key) -> DatabaseValueConvertible? in
            return sqlValues[key] ?? nil
        }
        
    }
    
    func sqlValues(forRecords records:[CKRecord]) -> [DatabaseValueConvertible?] {
        
        let rows = records.map { (record) -> [String:DatabaseValueConvertible?] in
            return map(record: record)
        }
        
        return sqlValues(forRows: rows)
    }
    
    func sqlValues(forRows dictionaries:[[String:DatabaseValueConvertible?]]) -> [DatabaseValueConvertible?]{
        
        var valuesArray = [DatabaseValueConvertible?]()
        
        for dictionary in dictionaries {
            
            let sortedValues = sortedSqlValues(dictionary)
            valuesArray.append(contentsOf: sortedValues)
            
        }
        return valuesArray
    }
    
    func sqlValuesString(forRecords records:[CKRecord]) -> String {
        
        let rows = records.map { (record) -> [String:DatabaseValueConvertible?] in
            return map(record: record)
        }
        
        return sqlValuesString(rows:rows)
    }
    
    func sqlValuesString(rows:[[String:DatabaseValueConvertible?]]) -> String {
        
        let placeholderArray = sortedColumns.map { (_) -> String in
            return "?"
        }
        
        let recordPlaceholderArray = rows.map { (_) -> String in
            return "(" + placeholderArray.joined(separator: ", ") + ")"
        }
        
        return recordPlaceholderArray.joined(separator: ", ")
    }
    
}


extension Array where Element == String {

    func sqlPlaceholderString() -> String{
        
        var quoteArr = [String]()
        
        for _ in 0 ..< self.count{
            quoteArr.append("?")
        }
        
        return quoteArr.joined(separator: ",")
        
    }

}




