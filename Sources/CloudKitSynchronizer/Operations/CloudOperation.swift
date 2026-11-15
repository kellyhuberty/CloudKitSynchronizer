//
//  CloudOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudOperation : AsyncCloudKitOperation, @unchecked Sendable {
    
    private var _operation:CKDatabaseOperation!

    override func start(completionToken:Token){
        
        syncQueue.sync {
            _operation = createOperation()
            _operation.completionBlock = {
                print(self)
                completionToken.finish()
            }
            _operation.start()
        }
    }

    func createOperation() -> CKDatabaseOperation {

        fatalError("Operation not configured")

    }
}
