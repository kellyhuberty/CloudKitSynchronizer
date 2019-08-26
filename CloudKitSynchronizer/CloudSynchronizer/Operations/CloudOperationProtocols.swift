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


//protocol CloudZoneAvailablityOperationDelegate: class {
//
//}

protocol CloudZoneAvailablityOperation : Operation {

// Modifying and syncing record zones.
//    class CKFetchRecordZonesOperation
//    class CKModifyRecordZonesOperation
//    
    
    var zoneIds:[CKRecordZone.ID] { get set }
    
    //var delegate: CloudZoneAvailablityOperationDelegate? { get set }
    
}


class CloudKitOperationFactory: OperationFactory {
    
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
