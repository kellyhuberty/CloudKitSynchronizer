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
    
    var zoneID: CKRecordZone.ID?
    
    var previousServerChangeToken: CKServerChangeToken?
    
    weak var delegate: CloudRecordPullOperationDelegate?

    init(delegate: CloudRecordPullOperationDelegate){
        self.delegate = delegate
        super.init()
    }
    
    override func createOperation() -> CKOperation {
    
        fatalError("Unable to load")
    
    }
    
}
