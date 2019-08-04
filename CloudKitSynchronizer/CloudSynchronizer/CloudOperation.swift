//
//  CloudOperation.swift
//  VHX
//
//  Created by Kelly Huberty on 3/17/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudOperation : Operation {
    
    private var _operation:CKOperation!
    
    private var _isExecuting:Bool = false{
        willSet{
            self.willChangeValue(for: \.isExecuting )
        }
        didSet{
            self.didChangeValue(for: \.isExecuting )
        }
    }
    
    private var _isFinished:Bool = false{
        willSet{
            self.willChangeValue(for: \.isFinished)
        }
        didSet{
            self.didChangeValue(for: \.isFinished)
        }
    }
    
//    init(operation:CKOperation) {
//        _operation = operation
//
//        _operation.completionBlock = { [weak self] in
//            self?.finish()
//        }
//
//        super.init()
//    }

    override func start() {

        _isExecuting = true

        
        _operation = createOperation()
        _operation.completionBlock = { [weak self] in
            self?.finish()
        }
        _operation.start()
    }

    func createOperation() -> CKOperation {

        fatalError("Operation not configured")

    }
    
    override var isAsynchronous: Bool{
        return true
    }
    
    override var isExecuting: Bool{
        get{
            return _isExecuting
        }
    }
    
    override var isFinished: Bool{
        get{
            return _isFinished
        }
    }
    
    func finish(){
        _isExecuting = false
        _isFinished = true
    }
    
    
}

