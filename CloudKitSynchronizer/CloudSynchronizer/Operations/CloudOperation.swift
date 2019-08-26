//
//  CloudOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudOperation : AsynchronousOperation {
    
    private var _operation:CKOperation!

    override func start(completionToken:Token){
        
        _operation = createOperation()
        _operation.completionBlock = {
            completionToken.finish()
        }
        _operation.start()
    }

    func createOperation() -> CKOperation {

        fatalError("Operation not configured")

    }

}
