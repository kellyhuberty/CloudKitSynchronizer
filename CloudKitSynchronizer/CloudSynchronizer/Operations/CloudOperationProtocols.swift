//
//  CloudOperationProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 7/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import CloudKit

enum CloudRecordOperationStatus{
    case success
    case error(_ error:CloudKitError)
}

protocol CloudRecordPushOperationDelegate: AnyObject {
    func cloudPushOperation(_ operation:CloudRecordPushOperation,
                            processedUpdatedRecords:[CKRecord],
                            status:CloudRecordOperationStatus)
    
    func cloudPushOperation(_ operation:CloudRecordPushOperation,
                            processedDeletedRecords:[CKRecord.ID],
                            status:CloudRecordOperationStatus)
    
    func cloudPushOperationDidComplete(_ operation:CloudRecordPushOperation)
}

protocol CloudRecordPushOperation : Operating {
    
    var delegate: CloudRecordPushOperationDelegate? { get set }
    
    var updates:[CKRecord] { get set }
    var deleteIds:[CKRecord.ID] { get set }
    
}

protocol CloudRecordPullOperationDelegate: AnyObject {
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

protocol CloudRecordPullOperation : Operating {
    
    var zoneId:CKRecordZone.ID? { get set }
    var previousServerChangeToken:CKServerChangeToken? { get set }

    var delegate: CloudRecordPullOperationDelegate? { get set }
    
}


//protocol CloudZoneAvailablityOperationDelegate: class {
//
//}

protocol CloudZoneAvailablityOperation : Operating {

// Modifying and syncing record zones.
//    class CKFetchRecordZonesOperation
//    class CKModifyRecordZonesOperation
//    
    
    var zoneIdsToCreate:[CKRecordZone.ID] { get set }
    var zoneIdsToDelete:[CKRecordZone.ID] { get set }

    
    
    //var delegate: CloudZoneAvailablityOperationDelegate? { get set }
    
}


class CloudKitOperationProducer: CloudOperationProducing {
    
    func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation {
        return CloudKitZoneAvailablityOperation()
    }
    
    func newPullOperation(delegate:CloudRecordPullOperationDelegate) -> CloudRecordPullOperation {
        return CloudKitRecordPullOperation(delegate: delegate)
    }
    
    func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation{
        return CloudKitRecordPushOperation(delegate: delegate)
    }
    
}

protocol Operating : AnyObject {
    func start()
    var completionBlock: (() -> Void)? { get set }
}

extension Operation: Operating {}
