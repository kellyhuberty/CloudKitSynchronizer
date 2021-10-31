//
//  CloudPullUpdateOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit




class CloudKitRecordPullOperation : CloudOperation, CloudRecordPullOperation {
    
    var zoneId: CKRecordZone.ID?
    
    var previousServerChangeToken: CKServerChangeToken?
    
    weak var delegate: CloudRecordPullOperationDelegate?

    private var _pullOperation: CKFetchRecordZoneChangesOperation!
    
    init(delegate: CloudRecordPullOperationDelegate){
        self.delegate = delegate
        super.init()
    }
    
    override func createOperation() -> CKOperation {
        
        var zoneIds = [CKRecordZone.ID]()
        var zoneIdsConfigurations =
            [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()

        if let zoneId = zoneId {
            zoneIds.append(zoneId)
            
            let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            configuration.previousServerChangeToken = previousServerChangeToken
            
            zoneIdsConfigurations = [zoneId: configuration]
            
        }
        
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = previousServerChangeToken

        _pullOperation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: zoneIds,
            configurationsByRecordZoneID: zoneIdsConfigurations
        )
        
        _pullOperation.recordChangedBlock = { [weak self] (record) in
            
            guard let self = self else {
                return
            }
         
            self.delegate?.cloudPullOperation(self,
                                              processedUpdatedRecords: [record],
                                              status: .success)
        }
        
        #if os(iOS)
        if #available(iOS 15, tvOS 15, watchOS 8, *){
            _pullOperation.recordWasChangedBlock = { [weak self] (recordId, recordResult) in
                
                guard let self = self else {
                    return
                }
            
                switch recordResult{
                case .failure(let error):
                    self.delegate?.cloudPullOperation(self,
                                                      processedUpdatedRecords: [],
                                                      status: .error(CloudKitError(error: error)))
                case .success(let record):
                    
                    if record.recordID == nil  {
                        print("wtf")
                    }
                    
                    self.delegate?.cloudPullOperation(self,
                                                      processedUpdatedRecords: [record],
                                                      status: .success)
                }
            }
            _pullOperation.recordChangedBlock = nil
        }
        #endif
        _pullOperation.recordWithIDWasDeletedBlock = { (recordId, recordType) in
            
            
            self.delegate?.cloudPullOperation(self,
                                              processedDeletedRecordIds: [recordId],
                                              status: .success)
            
        }
        
        _pullOperation.recordZoneChangeTokensUpdatedBlock = { (_, serverChangeToken, _) in
            
            self.delegate?.cloudPullOperation(
                self,
                pulledNewChangeTag: serverChangeToken
            )
            
        }
        
        _pullOperation.fetchRecordZoneChangesCompletionBlock = { (error) in
            
        }
        
        _pullOperation.recordZoneFetchCompletionBlock = { (_, serverChangeToken, _, _, error) in
            
            
            self.delegate?.cloudPullOperationDidComplete(self)
            
            self.delegate?.cloudPullOperation(
                self,
                pulledNewChangeTag: serverChangeToken
            )
            
        }
        
        
        return _pullOperation
        
    }
    
}
