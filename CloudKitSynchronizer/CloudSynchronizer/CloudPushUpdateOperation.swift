//
//  CloudPushUpdateOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudPushUpdateOperation : CloudOperation {

    let _pushOperation:CKModifyRecordsOperation
    
    private var updated:[CKRecord] = []
    private var errors:[CloudRecordError] = []
    
    init(updateRecords: [CKRecord], deleteRecordIds: [CKRecord.ID]) {
        _pushOperation = CKModifyRecordsOperation(recordsToSave: updateRecords, recordIDsToDelete: deleteRecordIds)
        
        
        super.init(operation: _pushOperation)
        configurePush()
    }
    
    @available(*, unavailable)
    override init(operation: CKOperation) {
        fatalError()
    }
    
    private func configurePush(){
        
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
            self.process()
            self.finish()
        }
        
    }
    
    func process(){
        
        
        
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
