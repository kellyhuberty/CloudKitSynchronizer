//
//  ErrorReceiving.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 4/10/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import Foundation

public protocol CloudSyncErrorReceiving {
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwError error: CloudKitError) -> Bool
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUnhandledError error: CloudKitError) -> Bool
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, haltedSyncError error: CloudKitError) -> Bool
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, willRetryLaterDueTo error: CloudKitError) -> Bool
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwConstraintViolationError error: CloudKitError) -> Bool
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUserDisplayableError error: CloudKitError) -> Bool
    
}

extension CloudSyncErrorReceiving {
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwError error: CloudKitError) -> Bool {
        
        switch error.code {
        case .unhandled:
            return cloudSynchronizer(synchronizer, threwUnhandledError: error)
        case .haltSync:
            return cloudSynchronizer(synchronizer, haltedSyncError: error)
        case .retryLater:
            return cloudSynchronizer(synchronizer, willRetryLaterDueTo: error)
        case .recordConflict:
            break
        case .constraintViolation:
            return cloudSynchronizer(synchronizer, threwConstraintViolationError: error)
        case .fullRepull:
            return cloudSynchronizer(synchronizer, haltedSyncError: error)
        case .message:
            return cloudSynchronizer(synchronizer, threwUserDisplayableError: error)
        }
        
        return false
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUnhandledError: CloudKitError) -> Bool {
        return false
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, haltedSyncError: CloudKitError) -> Bool {
        return false
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, willRetryLaterDueTo: CloudKitError) -> Bool {
        return false
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwConstraintViolationError: CloudKitError) -> Bool {
        return false
    }
    
    func cloudSynchronizer(_ synchronizer: CloudSynchronizer, threwUserDisplayableError: CloudKitError) -> Bool {
        return false
    }
    
}

