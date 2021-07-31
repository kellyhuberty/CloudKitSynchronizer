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
                        
            if let error = error as? CKError {
                self.processModificationError(saving: savedRecords , deleted: deletedRecordIds, ckError: error)
                return
            }
            
            self.delegate?.cloudPushOperation(self,
                                              processedDeletedRecords: deletedRecordIds ?? [],
                                              status: .success)
            
        }
                
        return _pushOperation
    }
    
    func processModificationError(saving: [CKRecord]?, deleted: [CKRecord.ID]?, ckError: CKError) {
        let status = CloudRecordOperationStatus.error(CloudKitError(error: ckError))

        let erroredUpdatedRecords: [CKRecord]?
        let erroredDeletedRecordIDs: [CKRecord.ID]?

        if saving?.count ?? 0 > 0 {
            erroredUpdatedRecords = saving
        }
        else {
            erroredUpdatedRecords = _pushOperation.recordsToSave
        }
        
        if deleted?.count ?? 0 > 0 {
            erroredDeletedRecordIDs = deleted
        }
        else {
            erroredDeletedRecordIDs = _pushOperation.recordIDsToDelete
        }
        
        if let recordIds = erroredDeletedRecordIDs, recordIds.count > 0 {
            self.delegate?.cloudPushOperation(self,
                                              processedDeletedRecords: recordIds,
                                              status: status)
        }
        
        if let records = erroredUpdatedRecords, records.count > 0 {
            self.delegate?.cloudPushOperation(self,
                                              processedUpdatedRecords: records,
                                              status: status)

        }
                
    }
    
    
}

class CloudRecordError : Error{
    
    let description: String
    let status: CloudRecordErrorType?
    let serverRecord: CKRecord?
    
    init(description: String, status: CloudRecordErrorType? = nil, serverRecord: CKRecord? ) {
        self.description = description
        self.status = status
        self.serverRecord = serverRecord
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
        self.serverRecord = cloudKitError.underlyingError.serverRecord
    }
}
