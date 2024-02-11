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

class CloudRecordStore : CloudRecordStoring {
    
    private func newCloudRecord(with identifier:String, zoneID:CKRecordZone.ID, tableName:String, ckRecord:CKRecord?, status: CloudRecordMutationType, error: CloudRecordError? = nil) -> CloudRecord{
        
        let cloudRecord = CloudRecord(identifier: identifier, tableName: tableName, status: status)
        if let ckRecord = ckRecord {
            cloudRecord.record = ckRecord
        } else{
            cloudRecord.record = createNewCKRecord(with:identifier, zoneID:zoneID, tableName:tableName)
        }
        return cloudRecord
    }
    
    private func createNewCKRecord(with identifier:String, zoneID:CKRecordZone.ID, tableName:String) -> CKRecord{
        
        //TODO: Fix so that we aren't calling to the cloud synchronizer.
        let ckId = CKRecord.ID(recordName: identifier, zoneID: zoneID)
        let ckRecord = CKRecord(recordType: tableName, recordID: ckId)
        return ckRecord
    }
    
    //MARK:- Cloud Record Checkout/Checkin
    func checkoutRecord(with ids:[String], zoneID:CKRecordZone.ID, from table:String, for status:CloudRecordMutationType, sorted: Bool = true, using db: Database) throws -> [CKRecord] {
        
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
            let newRecord = newCloudRecord(with: createId, zoneID: zoneID, tableName: table, ckRecord:nil, status: status)
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
    
    
    func checkinCloudRecords(_ records:[CKRecord],
                             with status:CloudRecordMutationType?,
                             having currentStatuses: [CloudRecordMutationType]?,
                             error: CloudRecordError?,
                             using db:Database) throws {
        
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
                if let status = status {
                    cloudRecord.status = status
                }
                cloudRecord.error = error
                cloudRecord.record = record
                cloudRecordsToSave.append(cloudRecord)
            }else{
                if let status = status {
                    let cloudRecord = self.newCloudRecord(with: record.recordID.recordName, zoneID: record.recordID.zoneID, tableName: record.recordType, ckRecord: record, status: status, error: error)
                    cloudRecordsToSave.append(cloudRecord)
                }
            }
        }
        
        for cloudRecord in cloudRecordsToSave {
            try cloudRecord.save(db)
        }
    }
    
    func checkinCloudRecordIds(_ recordIds:[CKRecordIdentifiable],
                               with status:CloudRecordMutationType,
                               having currentStatuses: [CloudRecordMutationType]?,
                               error: CloudRecordError?,
                               using db:Database) throws {
        //After a modification has completed, check in a record.
        let recordIdStrings = recordIds.map { (recordIds) -> String in
            return recordIds.identifier
        }
        //Error: Cloud Checkin Error
        try checkinCloudRecords(identifiers:recordIdStrings, with: status, error: error, using: db)
    }
    
    private func checkinCloudRecords(identifiers:[String], with status:CloudRecordMutationType, error: CloudRecordError?, using db:Database) throws {
        
        //After a modification has completed, check in a record.
        var bindingsArr = [String]()
        
        for _ in 0 ..< identifiers.count {
            bindingsArr.append("?")
        }
        
        let args = [status.rawValue, error?.status?.rawValue, error?.description] + identifiers
        let updateQuery = "UPDATE `\(TableNames.CloudRecords)` SET `status` = ?, `errorType` = ?, `errorDescription` = ? WHERE `identifier` IN ( \(bindingsArr.joined(separator: ",")) )"
        try db.execute(sql: updateQuery, arguments: StatementArguments(args) )
    }
    
    func removeCloudRecords(identifiers:[CKRecordIdentifiable], using db:Database) throws {
        
        let identifierStrings = identifiers.map { (ckRecordIdentifiable) in
            return ckRecordIdentifiable.identifier
        }
                
        let args = StatementArguments(identifierStrings)

        //Clean up from CloudRecordTable
        try db.execute(sql: "DELETE FROM `\(TableNames.CloudRecords)` WHERE `identifier` IN ( \(identifierStrings.sqlPlaceholderString()) )", arguments: args)
    }
    
    func cloudRecords(with status:CloudRecordMutationType, using db:Database) throws -> [CloudRecord] {
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

protocol CKRecordIdentifiable {
    var identifier: String { get }
}

extension CKRecord.ID: CKRecordIdentifiable {
    var identifier: String {
        return recordName
    }
}

extension String: CKRecordIdentifiable {
    var identifier: String {
        return self
    }
}
