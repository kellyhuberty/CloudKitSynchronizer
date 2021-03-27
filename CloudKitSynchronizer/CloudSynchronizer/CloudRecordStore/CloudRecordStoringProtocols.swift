//
//  CloudRecordStoringProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/24/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit
import GRDB

protocol CloudRecordStoring {
    
    //MARK:- Cloud Record Checkout/Checkin
    func checkoutRecord(with ids:[String], zoneID:CKRecordZone.ID, from table:String, for status:CloudRecordMutationType, sorted: Bool, using db: Database) throws -> [CKRecord]

    func checkinCloudRecords(_ records:[CKRecord],
                             with status:CloudRecordMutationType?,
                             having currentStatuses:[CloudRecordMutationType]?,
                             error: CloudRecordError?,
                             using db:Database) throws
    
    func checkinCloudRecordIds(_ identifiers:[CKRecordIdentifiable],
                               with status:CloudRecordMutationType,
                               having currentStatuses:[CloudRecordMutationType]?,
                               error:CloudRecordError?,
                               using db:Database) throws
        
    func removeCloudRecords(identifiers:[CKRecordIdentifiable], using db:Database) throws
    
    func cloudRecords(with status:CloudRecordMutationType, using db:Database) throws -> [CloudRecord]
    
}

extension CloudRecordStoring {
    func checkinCloudRecordIds(_ identifiers:[CKRecordIdentifiable], with status:CloudRecordMutationType, using db:Database) throws {
        try self.checkinCloudRecordIds(identifiers,
                                       with: status,
                                       having: CloudRecordMutationType.All,
                                       error: nil,
                                       using: db)
    }
}
