//
//  ErrorReceiving.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 4/10/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import Foundation

protocol CloudSynchronizerErrorReceiving: AnyObject {
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwError error: CloudSynchronizerError) -> Bool
    
//    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUnhandledError error: CloudKitError) -> Bool
//
//    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, haltedSyncError error: CloudKitError) -> Bool
//
//    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, willRetryLaterDueTo error: CloudKitError) -> Bool
//
//    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwConstraintViolationError error: CloudKitError) -> Bool
//
//    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUserDisplayableError error: CloudKitError) -> Bool
    
}

//extension CloudSyncErrorReceiving {
//
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwError error: CloudKitError) -> Bool {
////
////        switch error.code {
////        case .unhandled:
////            return cloudSynchronizer(synchronizer, threwUnhandledError: error)
////        case .haltSync:
////            return cloudSynchronizer(synchronizer, haltedSyncError: error)
////        case .retryLater:
////            return cloudSynchronizer(synchronizer, willRetryLaterDueTo: error)
////        case .recordConflict:
////            break
////        case .constraintViolation:
////            return cloudSynchronizer(synchronizer, threwConstraintViolationError: error)
////        case .fullRepull:
////            return cloudSynchronizer(synchronizer, haltedSyncError: error)
////        case .message:
////            return cloudSynchronizer(synchronizer, threwUserDisplayableError: error)
////        }
////
////        return false
////    }
////
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUnhandledError: CloudKitError) -> Bool {
////        return false
////    }
////
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, haltedSyncError: CloudKitError) -> Bool {
////        return false
////    }
////
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, willRetryLaterDueTo: CloudKitError) -> Bool {
////        return false
////    }
////
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwConstraintViolationError: CloudKitError) -> Bool {
////        return false
////    }
////
////    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUserDisplayableError: CloudKitError) -> Bool {
////        return false
////    }
//
//}

class ErrorDispatcher: CloudSynchronizerErrorReceiving {
    
    var errorHandler: ((_ cloudSynchronizer: CloudSynchronizer, _ error: CloudSynchronizerError) -> Bool)?
    
    init() {
        
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwError error: CloudSynchronizerError) -> Bool {
        return errorHandler?(synchronizer, error) ?? false
    }
}

class ErrorDispatchTable<CloudSynchronizerErrorReceiving> {}   


class DispatchTable<Type> {
        
    var dispatchers = WeakArray<Type>()
    
    func iterate(_ dispatchFunction: (_ dispatcher: Type) -> Bool) {
        for dispatcher in dispatchers {
            let result = dispatchFunction(dispatcher)
            if result {
                break
            }
        }
    }
    
    func add(_ item: Type) {
        dispatchers.append(item)
    }
}

class WeakArray<Type> {
    
    typealias Index = Int
    typealias Element = Type

    private var wrappedContent = [WeakContainer<Type>]()
    
    private var content: [Type] {
        get {
            cleanup()
            return wrappedContent.compactMap { $0.get() }
        }
        set {
            wrappedContent = newValue.map{ WeakContainer($0) }
        }
    }
    
    private struct WeakContainer<Type> {
        
        let _valueFunction: () -> Type?

        init (_ value: Type) {
            
            let reference = value as AnyObject
            _valueFunction = { [weak reference] in
                return reference as? Type
            }
        }

        func get() -> Type? {
            return _valueFunction()
        }
    }
    
    required init() {
    
    }
    
    private func cleanup() {
        wrappedContent = wrappedContent.filter { $0.get() != nil }
    }
}

extension WeakArray: Sequence {
    func makeIterator() -> IndexingIterator<[Type]> {
        return content.makeIterator()
    }
}

extension WeakArray: Collection, MutableCollection {
    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return content.startIndex }
    var endIndex: Index { return content.endIndex }

    // Required subscript, based on a dictionary index
    subscript(index: Index) -> Type {
        get { return content[index] }
        set (newValue) {
            let container = WeakContainer(newValue)
            wrappedContent[index] = container
        }
    }

    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        
        cleanup()
        
        return content.index(after: i)
    }
 
}

extension WeakArray: RangeReplaceableCollection {
    func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Type == C.Element {
        content.replaceSubrange(subrange, with: newElements)
    }
}
