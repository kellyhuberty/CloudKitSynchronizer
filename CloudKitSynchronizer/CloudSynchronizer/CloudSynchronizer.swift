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

struct TableNames{
    static let Migration = "SyncMigration"
    static let CloudRecords = "SyncCloudRecords"
    static let ChangeTags = "SyncChangeTags"
}

class CloudSynchronizer {
    
    static let Domain: String = "com.kellyhuberty.CloudKitSynchronizer"
    
    enum Status {
        case unstarted
        case syncing
        case stopped
        case halted(error:Error?)
    }
    
    static let Prefix = "cloudRecord"
    
    //Constants
    
    /// These two vars are currently unused, but I imagine tey will be at some point (And were previously.) Because they are both
    /// Default, they are usually assumed by CloudKit.
    /**
     let container:CKContainer = CKContainer.default()
     let cloudDatabase:CKDatabase = CKContainer.default().privateCloudDatabase
     */
    static let defaultZoneId: CKRecordZone.ID = CKRecordZone.ID(zoneName: CloudSynchronizer.Domain,
    ownerName: CKCurrentUserDefaultName)
    
    var zoneId: CKRecordZone.ID {
        return CloudSynchronizer.defaultZoneId
    }
    
    let localDatabasePool:DatabaseQueue

    private let _operationFactory:CloudOperationProducing

    private let _tableObserverFactory:TableObserverProducing

    
    private var status:Status
    
    var operationFactory:CloudOperationProducing? {
        get{
            switch status {
            case .syncing:
                return _operationFactory
            default:
                return nil
            }
        }
    }
    
    let cloudRecordStore: CloudRecordStoring
    
    private var currentChangeTagCache:CKServerChangeToken?
    
    var currentChangeTag:CKServerChangeToken? {
        get{
            guard currentChangeTagCache == nil else {
                return currentChangeTagCache
            }
            
            //Error: .changeTokenSaveError
            let tag = try! localDatabasePool.read { (db) -> CloudChangeTag? in
                return try CloudChangeTag.fetchOne(db,
                                                   sql: """
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
    
    var observers:[TableObserving] = []
    
    ///Unused
    weak var delegate: CloudSynchronizerDelegate?
    
    init(databaseQueue: DatabaseQueue,
         operationFactory: CloudOperationProducing? = nil,
         tableObserverFactory: TableObserverProducing? = nil,
         cloudRecordStore: CloudRecordStoring? = nil) throws {
        
        self.localDatabasePool = databaseQueue
        
        if let operationFactory = operationFactory {
            self._operationFactory = operationFactory
        }
        else {
            self._operationFactory = CloudKitOperationProducer()
        }
        
        if let tableObserverFactory = tableObserverFactory {
            self._tableObserverFactory = tableObserverFactory
        }
        else {
            self._tableObserverFactory = SQLiteTableObserverFactory(databaseQueue: databaseQueue)
        }
        
        if let cloudRecordStore = cloudRecordStore {
            self.cloudRecordStore = cloudRecordStore
        }
        else {
            self.cloudRecordStore = CloudRecordStore()
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
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)!
        //TODO: Support for push notification changes
        
    }
    
    private func setSyncRequest(){
        
        for table in synchronizedTables {
            //Error: table setup error
            try! startObservingTable(table)
        }
        
    }
    
    private func addTableObserver(_ tableObserver:TableObserving){
        
        observers.append(tableObserver)
        
    }
    
    private func tableObserver(for name:String) -> TableObserving{
        
        for observer in observers {
            if observer.tableName == name {
                return observer
            }
        }
        
        //TODO: Lets not fatal error here
        fatalError("Unable to find observed table \(name)")
        
    }
    
    private func startObservingTable(_ syncedTable:SynchronizedTableProtocol) throws {
        
        let table = syncedTable.tableName
        let tableObserver = _tableObserverFactory.newTableObserver(table)
        tableObserver.delegate = self
        addTableObserver(tableObserver)
        
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
    
    private func propagatePulledChangesToDatabase() throws {
        
        try localDatabasePool.write { (db) in
            
            let cloudRecordsToDelete = try cloudRecordStore.cloudRecords(with: .pullingDelete, using: db)
            
            let cloudRecordsToUpdate = try cloudRecordStore.cloudRecords(with: .pullingUpdate, using: db)
            
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
            try cloudRecordStore.checkinCloudRecords(identifiers:allIdentifiers, with: .synced, using: db)
            
        }
        
    }
    
    private func propegatesDeletesToDatabase(_ identifiers:[String], in tableName:String, database:Database) throws {
                
        let args = StatementArguments(identifiers)
        
        //Delete From Table
        try database.execute(sql: "DELETE FROM `\(tableName)` WHERE `identifier` IN ( \(identifiers.sqlPlaceholderString()) )", arguments: args)
        
        try cloudRecordStore.removeCloudRecords(identifiers: identifiers, using: database)
    }
    
    private func propegatesUpdatesToDatabase(_ ckRecords:[CKRecord], in tableName:String, database:Database) throws {
        
        
        let mapper = tableObserver(for:tableName).mapper
        
        let sortedSqlColumnString = mapper.sortedSqlColumnString()
        
        let sqlValues = mapper.sqlValues(forRecords: ckRecords)
        
        let sqlValuesString = mapper.sqlValuesString(forRecords: ckRecords)

        let arguments = StatementArguments(sqlValues)
        
        //Update cloud record table
        try database.execute(sql: """
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
            //Error:
            try? localDatabasePool.write { (db) in
                try? cloudRecordStore.checkinCloudRecords(processedRecords, with: .synced, using:db)
            }
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
        
        switch status {
        case .error(let error):
            break
        case .success:
            
            //Error:
            try? localDatabasePool.write { [weak self] (db) in
                try? self?.cloudRecordStore.checkinCloudRecords(processedUpdatedRecords, with: .pullingUpdate, using: db)
            }
        }
    }
    
    func cloudPullOperation(_ operation: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus) {
        
        switch status {
        case .error(let error):
            break
        case .success:
            //Error:
            try? localDatabasePool.write { [weak self] (db) in
                try? self?.cloudRecordStore.checkinCloudRecordIds(processedDeletedRecordIds, with: .pullingDelete, using:db)
            }
        }
        
    }
    
    func cloudPullOperation(_ operation: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?) {
        self.currentChangeTag = pulledNewChangeTag
    }
    
    func cloudPullOperationDidComplete(_ operation: CloudRecordPullOperation) {
        try! self.propagatePulledChangesToDatabase()
    }
    
}

extension CloudSynchronizer: TableObserverDelegate {
    
    func mapAndCheckoutRecord(from tableRows:[TableRow], from table:String, for status:CloudRecordStatus, using db: Database) throws -> [CKRecord] {

        let mapper = tableObserver(for: table).mapper

        let rowIdentifers = tableRows.map { $0.identifier }

        let ckRecords = try cloudRecordStore.checkoutRecord(with: rowIdentifers, from: table, for: status, sorted: true, using: db)

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
    
    func tableObserver(_ observer: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow]) {
        
        let table = observer.tableName
        
        let deletedIdentifiers = deleted.map{ $0.identifier }
        
        var recordsToDelete: [CKRecord] = []
        var recordsToUpdate: [CKRecord] = []
        var recordsToCreate: [CKRecord] = []
        
        do {
            try localDatabasePool.write { (db) in
                recordsToDelete = try cloudRecordStore.checkoutRecord(with: deletedIdentifiers, from: table, for: .pushingDelete, sorted: true, using: db)
                recordsToUpdate = try self.mapAndCheckoutRecord(from: updated, from: table, for: .pushingUpdate, using: db)
                recordsToCreate = try self.mapAndCheckoutRecord(from: created, from: table , for: .pushingUpdate, using: db)
            }
        } catch {
            
        }
        
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

protocol CloudOperationProducing : class{
    func newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation
    func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation
    func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation
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
        if let index = newColumns.firstIndex(of: "identifier") {
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




