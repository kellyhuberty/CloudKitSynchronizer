//
//  TableObserver.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 5/11/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

class SQLiteTableObserverFactory: TableObserverProducing {
    
    private let databaseQueue:DatabaseQueue
    
    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }
    
    func newTableObserver(_ tableName: String) -> TableObserving {
        return SQLiteTableObserver(tableName: tableName, databaseQueue: databaseQueue)
    }
    
}
