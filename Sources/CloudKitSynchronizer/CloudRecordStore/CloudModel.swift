//
//  CloudModel.swift
//  VHX
//
//  Created by Kelly Huberty on 2/14/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit
import GRDB

enum CloudRecordMutationType : String, Codable {
    case processing = "processing"
    
    case pushingUpdate = "pushing.update"
    case pushingDelete = "pushing.delete"
    
    case pullingUpdate = "pulling.update"
    case pullingDelete = "pulling.delete"

    case synced = "synced"
    
    static let Synced: [CloudRecordMutationType] = [.synced]
    static let Pushing: [CloudRecordMutationType] = [.pushingDelete, .pushingUpdate]
    static let Pulling: [CloudRecordMutationType] = [.pullingUpdate, .pullingDelete]
    static let All: [CloudRecordMutationType] = [.pushingUpdate,
                                                 .pushingDelete,
                                                 .pullingUpdate,
                                                 .pullingDelete]

}

enum CloudRecordErrorType : String, Codable {
    case conflict = "conflict"
    case retryLater = "retryLater"
}

enum CloudRecordStatus {
    case mutation(_ mutationType: CloudRecordMutationType)
    case error(_ error: CloudRecordError)
}
