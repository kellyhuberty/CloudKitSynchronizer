//
//  TableObserver.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 5/11/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit
import GRDB

class TableObserver {
    
    
    let tableName:String
    let columnNames:[String]
    let mapper:CloudRecordMapper
    
    
    
    let resultsController:FetchedRecordsController<TableRow>
    
    var currentPushOperation:CloudRecordPushOperation?
    var currentRowsCreatingUp:[TableRow] = []
    var currentRowsUpdatingUp:[TableRow] = []
    var currentRowsDeletingUp:[TableRow] = []
    
    var isObserving: Bool = true

    init(tableName:String, columnNames:[String], controller:FetchedRecordsController<TableRow>) {
        self.tableName = tableName
        self.columnNames = columnNames
        self.resultsController = controller
        self.mapper = CloudRecordMapper(tableName:tableName, columnNames:columnNames)
    }
    
    
    
}

extension TableObserver : TableObserverProtocol {

}
protocol TableObserverProtocol {
    var tableName:String { get }
}

