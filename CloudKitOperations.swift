//
//  File.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 7/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import CloudKit

enum CloudRecordOperationStatus{
    case success
    case error
}

protocol CloudRecordPushOperationDelegate: class {
    func cloudPushOperation(_ operation:CloudRecordPushOperation,
                            processedRecords:[CKRecord],
                            status:CloudRecordOperationStatus)
    
    func cloudPushOperationDidComplete(_ operation:CloudRecordPushOperation)
}

protocol CloudRecordPushOperation : Operation {
    
    var delegate: CloudRecordPushOperationDelegate? { get set }
    
    var updates:[CKRecord] { get set }
    var deleteIds:[CKRecord.ID] { get set }
    
}

protocol CloudRecordPullOperationDelegate: class {
    func cloudPullOperation(_ operation:CloudRecordPullOperation,
                            processedUpdatedRecords:[CKRecord],
                            status:CloudRecordOperationStatus)
    
    func cloudPullOperation(_ operation:CloudRecordPullOperation,
                            processedDeletedRecordIds:[CKRecord.ID],
                            status:CloudRecordOperationStatus)
    
    func cloudPullOperation(_ operation:CloudRecordPullOperation,
                            pulledNewChangeTag:CKServerChangeToken?)
    
    func cloudPullOperationDidComplete(_ operation:CloudRecordPullOperation)
}

protocol CloudRecordPullOperation : Operation {
    
    var zoneId:CKRecordZone.ID? { get set }
    var previousServerChangeToken:CKServerChangeToken? { get set }

    var delegate: CloudRecordPullOperationDelegate? { get set }
    
}

class CloudKitOperationFactory: OperationFactory {

    func newPullOperation(delegate:CloudRecordPullOperationDelegate) -> CloudRecordPullOperation {
        return CloudKitRecordPullOperation(delegate: delegate)
    }
    
    func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation{
        return CloudKitRecordPushOperation(delegate: delegate)
    }
    
}



/*
private func configureModifyRecordsOperation(_ operation:CKModifyRecordsOperation){
    
    operation.perRecordCompletionBlock = { [weak self] (record, error) in
        print("blah")
        self?.checkinCloudRecords([record], with: .synced)
    }
    
    // Completion
    operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIds, error) in
        
    }
    
}
*/


/*
private func configureZoneRecordPullOperation(_ operation:CKFetchRecordZoneChangesOperation){
    
    operation.recordZoneIDs = [zoneId]
    
    let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
    
    configuration.previousServerChangeToken = currentChangeTag
    
    operation.configurationsByRecordZoneID = [zoneId:configuration]
    
    operation.recordChangedBlock = { (record) in
        
        self.checkinCloudRecords([record], with: .pullingUpdate)
        
    }
    
    operation.recordWithIDWasDeletedBlock = { (recordId, recordType) in
        
        self.checkinCloudRecordIds([recordId], with: .pullingDelete)
        
    }
    
    operation.recordZoneChangeTokensUpdatedBlock = { (_, serverChangeToken, _) in
        
        self.currentChangeTag = serverChangeToken
    }
    
    operation.fetchRecordZoneChangesCompletionBlock = { (error) in
        
    }
    
    operation.recordZoneFetchCompletionBlock = { (_, serverChangeToken, _, _, _) in
        
        
        //Error: database push error
        try! self.propegatePulledChangesToDatabase()
        
        self.currentChangeTag = serverChangeToken
    }
}
*/