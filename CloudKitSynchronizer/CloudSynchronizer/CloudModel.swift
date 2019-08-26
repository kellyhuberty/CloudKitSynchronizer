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
    var cloudRecordStatus:CloudRecordStatus { get }
}

enum CloudRecordStatus : String, Codable {
    case pushingUpdate = "pushing.update"
    case pushingDelete = "pushing.delete"
    
    case pullingUpdate = "pulling.update"
    case pullingDelete = "pulling.delete"

    case synced = "synced"
}

enum CloudRecordErrorStatus : String, Codable {
    case conflict = "conflict"
    case retryLater = "retryLater"
}

extension CloudModel{
    
    static func addCloudDatabaseAttributes(_ table:TableAlteration){
        table.add(column:"cloudRecordStatus", Database.ColumnType.text)
    }
    
}
