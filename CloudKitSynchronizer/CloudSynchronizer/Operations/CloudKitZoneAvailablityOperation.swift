//
//  CloudKitZoneAvailablityOperation.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/18/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitZoneAvailablityOperation: AsynchronousOperation, CloudZoneAvailablityOperation {
    
    var zoneIds: [CKRecordZone.ID] = []
    
    var completionToken: AsynchronousOperation.Token?
    
    override func start(completionToken: AsynchronousOperation.Token) {
        
        self.completionToken = completionToken
        
        let createZoneOperation = CKModifyRecordZonesOperation()
        
        var zones = [CKRecordZone]()
        
        for zoneId in zoneIds {
            let zoneToCreate = CKRecordZone(zoneID: zoneId)
            zones.append(zoneToCreate)
        }
        
        createZoneOperation.recordZonesToSave = zones
        
        createZoneOperation.modifyRecordZonesCompletionBlock = { (zones, zoneIds, error) in
            //Args are (zones, zoneIds, error)
            
            //Error: Zone create error
            // Right now this is unhandeled because
            // It will error every time but the initial to create
            // The cloud synchronizer default zone.
            
            self.completionToken?.finish()
            
        }
        
        createZoneOperation.completionBlock = {
            self.completionToken?.finish()

        }
        
        createZoneOperation.start()
        
    }
    
}
