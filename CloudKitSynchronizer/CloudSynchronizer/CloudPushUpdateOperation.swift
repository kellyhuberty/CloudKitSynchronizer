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
    
//    var currentRowsCreatingUp:[TableRow] = []
//    var currentRowsUpdatingUp:[TableRow] = []
//    var currentRowsDeletingUp:[TableRow] = []

    init(delegate: CloudRecordPushOperationDelegate) {
        self.delegate = delegate
        super.init()
    }
    //private var errors:[CloudRecordError] = []
    
//    init(updateRecords: [CKRecord], deleteRecordIds: [CKRecord.ID]) {
//        _pushOperation = CKModifyRecordsOperation(recordsToSave: updateRecords, recordIDsToDelete: deleteRecordIds)
//        
//        
//        super.init(operation: _pushOperation)
//    }
//    
//    @available(*, unavailable)
//    override init(operation: CKOperation) {
//        fatalError()
//    }
    
    override func createOperation() -> CKOperation {
        
        _pushOperation = CKModifyRecordsOperation(recordsToSave: updates, recordIDsToDelete: deleteIds)
        /*
        _pushOperation.perRecordCompletionBlock = { [weak self] (record, error) in
            
            guard let self = self else {return}
            
            if let error = error {
                
                let cloudError = CloudRecordError(record: record, error: error)
                self.errors.append(cloudError)
                
            }else{
                self.updated.append(record)
            }
            
        }
        
        _pushOperation.modifyRecordsCompletionBlock = { [weak self] (ckRecords, ckRecordIds, error) in
            guard let self = self else {return}
        }
        */
        
        
        
        _pushOperation.perRecordCompletionBlock = { [weak self] (record, error) in

            guard let self = self else { return }

            //self?.checkinCloudRecords([record], with: .synced)
            
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
