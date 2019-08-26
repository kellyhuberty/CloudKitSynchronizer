//
//  AsynchronousOperation.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/18/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation

class AsynchronousOperation : Operation {
    
    class Token {
        
        weak var operation: AsynchronousOperation?
        
        init(operation: AsynchronousOperation) {
            self.operation = operation
        }
        
        func finish(){
            operation?.finish()
        }
        
    }
    
    
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
    
    override func start() {
        _isExecuting = true
        self.start(completionToken: Token(operation: self))
    }
    
    func start(completionToken:Token){
        fatalError("func \(#function) on subclass of \(type(of: self)) Requires overriding.")
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
    
    private func finish(){
        _isExecuting = false
        _isFinished = true
    }
    
}
