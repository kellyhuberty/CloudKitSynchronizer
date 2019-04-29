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



class CloudSyncronizer {
    
    class TableObserver{
        
        let tableName:String
        
        let resultsController:FetchedRecordsController<TableRow>?
        
        var currentPushOperation:CKModifyRecordsOperation?
        var currentRowsCreatingUp:[TableRow] = []
        var currentRowsUpdatingUp:[TableRow] = []
        var currentRowsDeletingUp:[TableRow] = []
        
        init(tableName:String, controller:FetchedRecordsController<TableRow>) {
            self.tableName = tableName
            self.resultsController = controller
        }
        
    }
    
    struct TableNames{
        static let Migration = "SyncMigration"
        static let CloudRecords = "SyncCloudRecords"
    }
    
    static let Prefix = "cloudRecord"
    
    
    let container:CKContainer = CKContainer.default()
    let cloudDatabase:CKDatabase = CKContainer.default().privateCloudDatabase
    let localDatabasePool:DatabasePool

    var observers:[TableObserver] = []
    
    init(databasePool:DatabasePool) {
        localDatabasePool = databasePool
        
        try! databasePool.write { (db) in
            try! runSynchronizerMigrations(db)
        }
        
    }
    
    var synchronizedTables:[String] = [] {
        didSet{
            setSyncRequest()
        }
    }
    
    func processCloudNotificationPayload(_ userInfo:[AnyHashable : Any]){
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        //Do something
        
        
    }
    
    
    func setSyncRequest(){
        
        for table in synchronizedTables {
            
            try! startObservingTable(table)
            
        }
        
    }
    
    func addTableObserver(_ tableObserver:TableObserver){
        
        observers.append(tableObserver)
        
    }
    
    func tableObserver(for name:String) -> TableObserver?{
        
        for observer in observers {
            if observer.tableName == name {
                return observer
            }
        }
        return nil
    }
    
    func startObservingTable(_ table:String) throws {
        
        let request = SQLRequest<TableRow>("SELECT `\(table)`.* FROM `\(table)`", arguments: nil, adapter: nil, cached: false)
        
        let controller = try! FetchedRecordsController<TableRow>(localDatabasePool, request: request)
        
        try! controller.performFetch()
        
        let tableObserver = TableObserver(tableName: table, controller: controller)
        
        controller.trackChanges(willChange: { (contoller) in
            tableObserver.currentPushOperation = CKModifyRecordsOperation()
        
        
        }, onChange: { (controller, tableRow, change) in
            
            switch change{
            case .deletion:
                tableObserver.currentRowsDeletingUp.append(tableRow)
            case .insertion:
                tableObserver.currentRowsCreatingUp.append(tableRow)
            case .update:
                tableObserver.currentRowsUpdatingUp.append(tableRow)
            case .move:
                tableObserver.currentRowsUpdatingUp.append(tableRow)
            }
            
        }) { [weak self] (controller) in
            
            guard let self = self else {
                return
            }
            
            
            
            
            
            let deleteCkRecords = tableObserver.currentRowsDeletingUp.map{ $0.identifier }
            let updateCkRecords = tableObserver.currentRowsUpdatingUp.map{ $0.identifier }
            let createCkRecords = tableObserver.currentRowsCreatingUp.map{ $0.identifier }

            
            
            let recordsToDelete = self.checkoutRecord(with: deleteCkRecords, from: table , for: .synced)
            let recordsToUpdate = self.checkoutRecord(with: updateCkRecords, from: table , for: .synced)
            let recordsToCreate = self.checkoutRecord(with: createCkRecords, from: table , for: .synced)

            
            let deleteIds = recordsToDelete.map{ $0.recordID }

            let recordsToCreateOrUpdate = recordsToUpdate + recordsToCreate

            let currentPushOperation = CKModifyRecordsOperation(recordsToSave: recordsToCreateOrUpdate, recordIDsToDelete: deleteIds)
            
            tableObserver.currentPushOperation = currentPushOperation
            
            self.configureModifyRecordsOperation(currentPushOperation)
            
            currentPushOperation.start()
            
            
            
            
        }

        addTableObserver(tableObserver)
        
    }
    
    func configureModifyRecordsOperation(_ operation:CKModifyRecordsOperation){
        
        operation.perRecordCompletionBlock = { [weak self] (record, error) in
            print("blah")
            self?.checkinCloudRecords([record], with: .synced)
        }

        // Completion
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIds, error) in

        }
        
    }
    
    func configureZoneRecordPullOperation(_ operation:CKFetchRecordZoneChangesOperation){
        
        operation.recordZoneIDs = [CKRecordZone.default().zoneID]
        
        operation.recordChangedBlock = { (record) in
            
            self.checkinCloudRecords([record], with: .pullingUpdate)
            
            
            
        }
        
        operation.recordWithIDWasDeletedBlock = { (recordId, recordType) in
            
            self.checkinCloudRecordIds([recordId], with: .pullingDelete)

        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { (error) in
            
            
        }
        
    }
    
    
    /*
    func syncRows(on tableName: String, rows:[Row]){
        
        var rowsToCreate = [Row]()
        var rowsToUpdate = [Row]()
        var rowsToDelete = [Row]()

        for row in rows {
            
            guard let syncStatus = CloudRecordStatus(rawValue: (row["cloudRecordStatus"] as? String) ?? "") else{
                continue
            }
            
            switch syncStatus{
            case .pendingUpdate:
                rowsToUpdate.append(row)
            case .pendingDelete:
                rowsToDelete.append(row)
            default:
                noop()
            }
        
        }
        
        
        let recordsToUpdate = records(for: rowsToUpdate, in: tableName)
        let recordsToDelete = records(for: rowsToDelete, in: tableName)
        
        let deleteIds = recordsToDelete.map { (record) -> CKRecord.ID in
            return record.recordID
        }
        
        let operation = CloudPushUpdateOperation(updateRecords: recordsToUpdate, deleteRecordIds: deleteIds)
        
        scheduleModificationOperation(operation)
        
    }
    */
    
    
    
    func checkoutRecord(with ids:[String], from table:String, for status:CloudRecordStatus) -> [CKRecord] {
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< ids.count {
            bindingsArr.append("?")
        }
        
        var updateRecords:[CKRecord] = []
        var createRecords:[CKRecord] = []

        var createCloudRecords:[CloudRecord] = []
        
        
        try! localDatabasePool.write { (db) in

            
            
           
            //UPDATE ACTIVE RECORDS
            var argumentsArr = [status.rawValue]
            
            argumentsArr.append(contentsOf: ids)
            
            var updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
            
            try db.execute(updateQuery, arguments: StatementArguments( argumentsArr ) )
            
            var selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
            
            
            
            //QUERY RECORDS
            let request = SQLRequest<CloudRecord>(selectQuery, arguments: StatementArguments(ids), adapter: nil, cached: false)

            let results = try! request.fetchAll(db)
            
            updateRecords = results.compactMap({ (cloudRecord) -> CKRecord? in
                return cloudRecord.record
            })
            
            //CREATE CKRECORDS NEEDED
            let updatedIds = updateRecords.map({ (ckRecord) -> String in
                return ckRecord.recordID.recordName
            })
            
            let createIds = Set(ids).subtracting(updatedIds)
            
            for createId in createIds {
                let newRecord = newCloudRecord(with: createId, tableName: table, ckRecord:nil)
                try! newRecord.save(db)
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
    
    func newCloudRecord(with identifier:String, tableName:String, ckRecord:CKRecord?) -> CloudRecord{
        
        let cloudRecord = CloudRecord(identifier: identifier, tableName: tableName)
        
        if let ckRecord = ckRecord {
            cloudRecord.record = ckRecord
        }else{
            cloudRecord.record = createNewCKRecord(with:identifier, tableName:tableName)
        }
        
        return cloudRecord
    }
    
    func createNewCKRecord(with identifier:String, tableName:String) -> CKRecord{
        let ckId = CKRecord.ID(recordName: identifier)
        let ckRecord = CKRecord(recordType: tableName, recordID: ckId)
        return ckRecord
    }
    
    
    func checkinCloudRecords(_ records:[CKRecord], with status:CloudRecordStatus) {
        //After a modification has completed, check in a record.
        
        
        let allRecords = records.sorted(by: { (leftRecord, rightRecord) -> Bool in
            leftRecord.recordID.recordName > rightRecord.recordID.recordName
        })
        
        
        let allRecordIds = records.map { (record) -> CKRecord.ID in
            return record.recordID
        }
        
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< allRecordIds.count {
            bindingsArr.append("?")
        }
        
        
        try! localDatabasePool.write { (db) in
        
            var cloudRecordsToSave:[CloudRecord] = []
            
            let selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) ) ORDER BY `identifier` ASC"
            
            let request = SQLRequest<CloudRecord>(selectQuery, arguments: StatementArguments(allRecordIds), adapter: nil, cached: false)
            
            var availableCloudRecords = try! CloudRecord.fetchAll(db, request)
            
            for record in allRecords {
                if record.recordID.recordName == availableCloudRecords.first?.identifier {
                    let cloudRecord = availableCloudRecords.removeFirst()
                    cloudRecordsToSave.append(cloudRecord)
                }else{
                    let cloudRecord = self.newCloudRecord(with: record.recordID.recordName, tableName: record.recordType, ckRecord: record)
                    cloudRecordsToSave.append(cloudRecord)
                }
            }
            
            for cloudRecord in cloudRecordsToSave {
                try! cloudRecord.save(db)
            }
            
        }
        
    }
    
    func checkinCloudRecordIds(_ recordIds:[CKRecord.ID], with status:CloudRecordStatus) {
        //After a modification has completed, check in a record.
        
        let recordIdStrings = recordIds.map { (recordIds) -> String in
            return recordIds.recordName
        }
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< recordIdStrings.count {
            bindingsArr.append("?")
        }
        
        let args = [status] + recordIdStrings
        
        try! localDatabasePool.write { (db) in
            
            var updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
            
            try! db.execute(updateQuery, arguments: StatementArguments(args) )
        }
        
    }
    
    
    /*
    func processCloudRecordError(){
        
    }
    
    func push(to record:CKRecord, from tableRow:TableRow){
        
        let valuesDict = tableRow.dict
        
        for (key, value) in valuesDict {
            
            switch value?.storage ?? .null {
            case .null:
                record.setObject(nil, forKey: key)
            case .double(let double):
                record.setObject(NSNumber(value: double), forKey: key)
            case .int64(let int):
                record.setObject(NSNumber(value: int), forKey: key)
            case .blob(let data):
                record.setObject(data as NSData, forKey: key)
            case .string(let str):
                record.setObject(str as NSString, forKey: key)
            }
            
        }
        
    }
    
    func pull(from record:CKRecord, into tableRow:TableRow){
        
        let keys = record.allKeys()
        
        var dict:[String: DatabaseValue?] = [:]
        
        for key in keys {
        
            let value = DatabaseValue(value: record.object(forKey: key) as Any)
            
            dict[key] = value
            
        }
        
        tableRow.dict = dict
        
    }
    
    */
    
    func records(for rows:[Row], in table:String) -> [CKRecord] {
        
        var recordsToModify:[CKRecord] = []
        
        for row in rows {
        
            let record:CKRecord
            if let recordData:Data = row[CloudSyncronizer.Prefix + "Data"], let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: recordData), let serializedRecord = CKRecord(coder:unarchiver) {
                record = serializedRecord
            }else{
                let identifier:String = row["identifier"]
                let newRecord = CKRecord(recordType: table, recordID: CKRecord.ID(recordName: identifier))
                record = newRecord
            }
            
            let dict = Dictionary(row, uniquingKeysWith: { (left, _) in left })
            
            let valuesDict = dict.filter { (key: String, value: DatabaseValue) -> Bool in
                return key.hasPrefix(CloudSyncronizer.Prefix) ? false : true
            }
            
            for (key, value) in valuesDict {
                
                switch value.storage {
                case .null:
                    record.setObject(nil, forKey: key)
                case .double(let double):
                    record.setObject(NSNumber(value: double), forKey: key)
                case .int64(let int):
                    record.setObject(NSNumber(value: int), forKey: key)
                case .blob(let data):
                    record.setObject(data as NSData, forKey: key)
                case .string(let str):
                    record.setObject(str as NSString, forKey: key)
                }
                
            }
            
            recordsToModify.append(record)
        }
        
        return recordsToModify
    }
    
    
    
//    func rows(for records:[CKRecord]) -> [Row] {
//
//        var newRecords:[CKRecord] = []
//
//        for row in rows {
//
//            let record = CKRecord(recordType:table , recordID: CKRecord.ID(recordName: row["identifier"]))
//
//            let dict = Dictionary(row, uniquingKeysWith: { (left, _) in left })
//
//            for (key, value) in dict {
//
//                switch value.storage {
//                case .null:
//                    record.setObject(nil, forKey: key)
//                case .double(let double):
//                    record.setObject(NSNumber(value: double), forKey: key)
//                case .int64(let int):
//                    record.setObject(NSNumber(value: int), forKey: key)
//                case .blob(let data):
//                    record.setObject(data as NSData, forKey: key)
//                case .string(let str):
//                    record.setObject(str as NSString, forKey: key)
//                }
//
//                //record.setObject(value.storage as? __CKRecordObjCValue, forKey: key)
//
//            }
//
//            newRecords.append(record)
//        }
//
//        return newRecords
//
//    }

    func updateExistingRecords(){
        
        
        
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
                table.column("status", Database.ColumnType.text)
                table.column("changeDate", Database.ColumnType.text)
            })

        }
        
        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.migrationVersion.description )
        
    }
    
    
    
    
}


class TableRow : FetchableRecord{
    
    //let _row:Row
    
    var dict:[String: DatabaseValue?] = [:]

    
    
    required init(row: Row){
        //let keys = row.columnNames
        
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


class CloudRecord : Model, Codable{
    
    static var databaseTableName: String {
        return CloudSyncronizer.TableNames.CloudRecords
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
    }
    
    init(identifier:String, tableName:String) {
        self.identifier = identifier
        self.tableName = tableName
    }
//
//    init(identifier:String, tableName:String) {
//        self.identifier =
//        self.tableName = tableName
//    }
    
    let identifier:String
    let tableName:String
    var ckRecordData:Data? = nil
    var cloudChangeTag:String? = nil
    var changeDate:Date? = nil
    
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

//static let Domain = "com.kellyhuberty.CloudKitSynchronizer"

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

//
//class TablePullData {
//
//
//
//}
//
//class TablePushData {
//
//    var currentPushOperation:CKModifyRecordsOperation?
//    var currentRowsCreatingUp:[TableRow] = []
//    var currentRowsUpdatingUp:[TableRow] = []
//    var currentRowsDeletingUp:[TableRow] = []
//
//}
//

//class CloudPushOperation : NSOperation {
//
//    var currentPushOperation:CKModifyRecordsOperation?
//    var currentRowsCreatingUp:[TableRow] = []
//    var currentRowsUpdatingUp:[TableRow] = []
//    var currentRowsDeletingUp:[TableRow] = []
//
//
//
//}


class CloudPullOperation : Operation {
    
    var currentPullOperation:CKFetchRecordZoneChangesOperation?
//    var currentRowsCreatingDown:[TableRow] = []
//    var currentRowsUpdatingDown:[TableRow] = []
//    var currentRowsDeletingDown:[TableRow] = []

    
    
    
}
