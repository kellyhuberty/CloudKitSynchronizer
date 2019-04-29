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
    
//    var cloudChangeTag:String? { get }
//    var changedDate:Date? { get }
//    var cloudRecordData:Data? { get }
    var cloudRecordStatus:CloudRecordStatus { get }
    
}

enum CloudRecordStatus : String, Codable {
    case pushingUpdate = "pushing.update"
    case pushingDelete = "pushing.delete"

    case pullingUpdate = "pulling.update"
    case pullingDelete = "pulling.delete"

    case synced = "synced"
}

extension CloudModel{
    
    static func addCloudDatabaseAttributes(_ table:TableAlteration){
//        table.add(column:"cloudChangeTag", Database.ColumnType.text)
//        table.add(column:"changedDate", Database.ColumnType.date)
//        table.add(column:"cloudRecordData", Database.ColumnType.date)
        table.add(column:"cloudRecordStatus", Database.ColumnType.text)
    }
    
}


//protocol CloudModelInline {
//    
//    var cloudChangeTag:String? { get }
//    var changedDate:Date? { get }
//    var cloudRecordData:Data? { get }
//    var cloudRecordStatus:Data? { get }
//
//}
//
//extension CloudModelInline{
//    
//    static func addCloudDatabaseAttributes(_ table:TableAlteration){
//        table.add(column:"cloudChangeTag", Database.ColumnType.text)
//        table.add(column:"changedDate", Database.ColumnType.date)
//        table.add(column:"cloudRecordData", Database.ColumnType.date)
//        table.add(column:"cloudRecordStatus", Database.ColumnType.text)
//    }
//}
//

