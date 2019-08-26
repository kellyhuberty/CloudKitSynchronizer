//
//  TableObserver.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 5/11/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

protocol TableObserverDelegate : class{
    func tableObserver(_ observer:TableObserver, created:[TableRow], updated:[TableRow], deleted:[TableRow])
}


protocol TableObserver: class {
    var tableName:String { get }
    var columnNames:[String] { get }
    var isObserving: Bool { get set }
    var delegate: TableObserverDelegate? { get set }
}

extension TableObserver {
    
    var mapper: CloudRecordMapper {
        
        return CloudRecordMapper(tableName: tableName, columnNames: columnNames)
        
    }

}

class SQLiteTableObserverFactory: TableObserverFactory {
    
    private let databaseQueue:DatabaseQueue
    
    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }
    
    func newTableObserver(_ tableName: String) -> TableObserver {
        return SQLiteTableObserver(tableName: tableName, databaseQueue: databaseQueue)
    }
    
}
