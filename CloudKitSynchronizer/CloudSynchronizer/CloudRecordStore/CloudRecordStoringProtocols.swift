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
    func checkoutRecord(with ids:[String], from table:String, for status:CloudRecordStatus, sorted: Bool, using db: Database) throws -> [CKRecord]
    
    func checkinCloudRecords(_ records:[CKRecord], with status:CloudRecordStatus, using db:Database) throws
    
    func checkinCloudRecordIds(_ recordIds:[CKRecord.ID], with status:CloudRecordStatus, using db:Database) throws
    
    func checkinCloudRecords(identifiers:[String], with status:CloudRecordStatus, using db:Database) throws
    
    func removeCloudRecords(identifiers:[String], using db:Database) throws
    
    func cloudRecords(with status:CloudRecordStatus, using db:Database) throws -> [CloudRecord]
    
}
