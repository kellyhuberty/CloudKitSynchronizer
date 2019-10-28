//
//  CloudRecordStore.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 10/6/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit
import GRDB

protocol CloudRecordStoring {
    
    //MARK:- Cloud Record Checkout/Checkin
    func checkoutRecord(with ids:[String], from table:String, for status:CloudRecordStatus, sorted: Bool, using db: Database) throws -> [CKRecord]
    
    func checkinCloudRecords(_ records:[CKRecord], with status:CloudRecordStatus, using db:Database) throws
    
    func checkinCloudRecordIds(_ recordIds:[CKRecord.ID], with status:CloudRecordStatus, using db:Database) throws
    
    func checkinCloudRecords(identifiers:[String], with status:CloudRecordStatus, using db:Database) throws
    
    func removeCloudRecords(identifiers:[String], using db:Database) throws
    
    func cloudRecords(with status:CloudRecordStatus, using db:Database) throws -> [CloudRecord]
    
}


class CloudRecordStore : CloudRecordStoring {
    
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
        
        //TODO: Fix so that we aren't calling to the cloud synchronizer.
        let ckId = CKRecord.ID(recordName: identifier, zoneID: CloudSynchronizer.defaultZoneId)
        let ckRecord = CKRecord(recordType: tableName, recordID: ckId)
        return ckRecord
    }
    
    //MARK:- Cloud Record Checkout/Checkin
    func checkoutRecord(with ids:[String], from table:String, for status:CloudRecordStatus, sorted: Bool = true, using db: Database) throws -> [CKRecord] {
        
        guard ids.count > 0 else {
            return []
        }
        
        var bindingsArr = [String]()
        
        for _ in 0 ..< ids.count {
            bindingsArr.append("?")
        }
        
        var updateRecords:[CKRecord] = []
        var createRecords:[CKRecord] = []
        
        //UPDATE ACTIVE RECORDS
        var argumentsArr = [status.rawValue]
        
        argumentsArr.append(contentsOf: ids)
        
        let updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
        
        try db.execute(sql: updateQuery, arguments: StatementArguments( argumentsArr ) )
        
        let selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
        
        //QUERY RECORDS
        let request = SQLRequest<CloudRecord>(sql: selectQuery, arguments: StatementArguments(ids), adapter: nil, cached: false)
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
            
            guard let record = newRecord.record else{
                continue
            }
            
            createRecords.append(record)

        }
                
        updateRecords.append(contentsOf:createRecords)
        
        //Checkout a CK record
        return updateRecords
    }
    
    
    func checkinCloudRecords(_ records:[CKRecord], with status:CloudRecordStatus, using db:Database) throws {
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
        var cloudRecordsToSave:[CloudRecord] = []
        let selectQuery = "SELECT * FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) ) ORDER BY `identifier` ASC"
        let request = SQLRequest<CloudRecord>(sql: selectQuery, arguments: StatementArguments(allRecordIdNames), adapter: nil, cached: false)
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
    
    func checkinCloudRecordIds(_ recordIds:[CKRecord.ID], with status:CloudRecordStatus, using db:Database) throws {
        //After a modification has completed, check in a record.
        let recordIdStrings = recordIds.map { (recordIds) -> String in
            return recordIds.recordName
        }
        //Error: Cloud Checkin Error
        try checkinCloudRecords(identifiers:recordIdStrings, with: status, using: db)
    }
    
    func checkinCloudRecords(identifiers:[String], with status:CloudRecordStatus, using db:Database) throws {
        
        //After a modification has completed, check in a record.
        var bindingsArr = [String]()
        
        for _ in 0 ..< identifiers.count {
            bindingsArr.append("?")
        }
        
        let args = [status.rawValue] + identifiers
        let updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
        try db.execute(sql: updateQuery, arguments: StatementArguments(args) )
    }
    
    func removeCloudRecords(identifiers:[String], using db:Database) throws {
        
        let args = StatementArguments(identifiers)

        //Clean up from CloudRecordTable
        try db.execute(sql: "DELETE FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(identifiers.sqlPlaceholderString()) )", arguments: args)
    }
    
    func cloudRecords(with status:CloudRecordStatus, using db:Database) throws -> [CloudRecord] {
        let sql =
            """
                SELECT
                    `\(TableNames.CloudRecords)`.*
                FROM
                    `\(TableNames.CloudRecords)`
                WHERE
                    `status` = ?
            """
        
        let cloudRecordRequest = SQLRequest<CloudRecord>(sql: sql, arguments: StatementArguments([status.rawValue]), adapter: nil, cached: false)
        let cloudRecords = try CloudRecord.fetchAll(db, cloudRecordRequest)
        return cloudRecords
    }

    
}
