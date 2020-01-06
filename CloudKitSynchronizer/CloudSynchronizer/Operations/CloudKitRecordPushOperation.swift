//
//  CloudPushUpdateOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitRecordPushOperation : CloudOperation, CloudRecordPushOperation {

    
    weak var delegate: CloudRecordPushOperationDelegate?
    
    var updates:[CKRecord] = []
    
    var deleteIds:[CKRecord.ID] = []

    private var _pushOperation:CKModifyRecordsOperation!

    init(delegate: CloudRecordPushOperationDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    override func createOperation() -> CKOperation {
        
        _pushOperation = CKModifyRecordsOperation(recordsToSave: updates, recordIDsToDelete: deleteIds)

        _pushOperation.perRecordCompletionBlock = { (record, error) in

            //guard let self = self else { return }
            
            let status: CloudRecordOperationStatus
            
            if let error = error as? CKError{
                status = .error(CloudKitError(error: error))
            }
            else {
                status = .success
            }
            
            self.delegate?.cloudPushOperation(self, processedUpdatedRecords: [record], status: status)
            
        }
                
        // Completion
        _pushOperation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIds, error) in
                        
            let status: CloudRecordOperationStatus
            
            if let error = error as? CKError{
                status = .error(CloudKitError(error: error))
            }
            else {
                status = .success
            }
            
            self.delegate?.cloudPushOperation(self,
                                              processedDeletedRecords: deletedRecordIds ?? [],
                                              status: status)
            
        }
        
        return _pushOperation
    }
    
}

class CloudRecordError : Error{
    
    var description: String
    let status: CloudRecordErrorType?
    
    init(description: String, status: CloudRecordErrorType? = nil) {
        self.description = description
        self.status = status
    }
    
    init(_ cloudKitError:CloudKitError) {
        
        let status: CloudRecordErrorType?

        switch cloudKitError.code {
        case .unhandled:
            status = nil
        case .haltSync:
            status = .retryLater
        case .retryLater:
            status = .retryLater
        case .recordConflict:
            status = .conflict
        case .constraintViolation:
            status = .retryLater
        case .fullRepull:
            status = .retryLater
        case .message:
            status = nil
        }
        
        self.description = cloudKitError.localizedDescription
        self.status = status
    }
}


class CloudKitError : Error, LocalizedError {

    enum RecoveryType {
        /// This particular item isn't handled by this verson's scopr of CKS.
        case unhandled
        /// An issue occured that requires pausing syncing until a later date.
        case haltSync
        /// Retry syncing the offending Records later.
        case retryLater
        /// Particular record has a conflict with another record in the cloud.
        case recordConflict
        /// There is a constraint voilation that needs to be addressed.
        case constraintViolation
        /// A full repull of CloudKit data needs to be preformed before syncing can continue.
        case fullRepull
        /// Non-actionary error occured. Recommend logging and reviewing for later.
        case message
    }
    
    let underlyingError: CKError
    let code: RecoveryType

    init(error:CKError) {
        
        switch error.code {
        case .alreadyShared:
            code = .unhandled
        case .assetFileModified:
            code = .unhandled
        case .assetFileNotFound:
            code = .unhandled
        case .badContainer:
            code = .haltSync
        case .badDatabase:
            code = .haltSync
        case .batchRequestFailed:
            code = .retryLater
        case .changeTokenExpired:
            code = .fullRepull
        case .constraintViolation:
            code = .constraintViolation
        case .incompatibleVersion:
            code = .haltSync
        case .internalError:
            code = .haltSync
        case .invalidArguments:
            code = .message
        case .limitExceeded:
            code = .retryLater
        case .managedAccountRestricted:
            code = .haltSync
        case .missingEntitlement:
            code = .haltSync
        case .networkFailure:
            code = .retryLater
        case .networkUnavailable:
            code = .retryLater
        case .notAuthenticated:
            code = .haltSync
        case .operationCancelled:
            code = .retryLater
        case .partialFailure:
            code = .retryLater
        case .participantMayNeedVerification:
            code = .unhandled
        case .permissionFailure:
            code = .unhandled
        case .quotaExceeded:
            code = .retryLater
        case .referenceViolation:
            code = .unhandled
        case .requestRateLimited:
            code = .retryLater
        case .serverRecordChanged:
            code = .recordConflict
        case .serverRejectedRequest:
            code = .message
        case .serverResponseLost:
            code = .retryLater
        case .serviceUnavailable:
            code = .retryLater
        case .tooManyParticipants:
            code = .unhandled
        case .unknownItem:
            code = .unhandled
        case .userDeletedZone:
            code = .unhandled
        case .zoneBusy:
            code = .retryLater
        case .zoneNotFound:
            code = .unhandled
        case .resultsTruncated:
            code = .unhandled
        case .assetNotAvailable:
            code = .unhandled
        @unknown default:
            code = .haltSync
        }
     
        underlyingError = error
    }
        
    static func ~=(p: CloudKitError, v: Error) -> Bool {
        return p.code == (v as? CloudKitError)?.code
    }
    
    var localizedDescription: String {
        return underlyingError.localizedDescription
    }
    
}

