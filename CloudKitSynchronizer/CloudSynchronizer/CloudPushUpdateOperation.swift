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

        _pushOperation.perRecordCompletionBlock = { [weak self] (record, error) in

            guard let self = self else { return }
            self.delegate?.cloudPushOperation(self, processedRecords: [record], status: .success)
        }
        
        // Completion
        _pushOperation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIds, error) in
            
            
        }
        
        return _pushOperation
    }
    
}


class CloudRecordError : Error{
    let record:CKRecord
    let error:Error
    
    init(record:CKRecord, error:Error) {
        self.record = record
        self.error = error
    }
    
}
