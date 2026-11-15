//
//  CloudOperator.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 11/10/25.
//
import CloudKit


protocol CloudOperating {
    func pullChanges(tag: CKServerChangeToken?, in zone: CKRecordZone.ID?, delegate: CloudRecordPullOperationDelegate) -> CKRecordUpdates
  
    func pushChanges(updates: [CKRecord], deletes: [CKRecord.ID], delegate: CloudRecordPushOperationDelegate)
}

struct CKRecordUpdates {
    let changeTag: CKServerChangeToken?
    let updates: [CKRecord]
    let deletes: [CKRecord.ID]
}
