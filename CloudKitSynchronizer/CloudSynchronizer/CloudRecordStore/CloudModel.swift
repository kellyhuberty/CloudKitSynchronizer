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

protocol CloudModel {
    var cloudRecordStatus:CloudRecordMutationType { get }
}

enum CloudRecordMutationType : String, Codable {
    case pushingUpdate = "pushing.update"
    case pushingDelete = "pushing.delete"
    
    case pullingUpdate = "pulling.update"
    case pullingDelete = "pulling.delete"

    case synced = "synced"
}

enum CloudRecordErrorType : String, Codable {
    case conflict = "conflict"
    case retryLater = "retryLater"
}

enum CloudRecordStatus {
    case mutation(_ mutationType: CloudRecordMutationType)
    case error(_ error: CloudRecordError)
}

extension CloudModel{
    
    static func addCloudDatabaseAttributes(_ table:TableAlteration){
        table.add(column:"cloudRecordStatus", Database.ColumnType.text)
    }
    
}