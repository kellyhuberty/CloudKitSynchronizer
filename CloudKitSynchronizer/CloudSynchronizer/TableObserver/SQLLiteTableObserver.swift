//
//  SQLLiteTableObserver.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/25/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

class SQLiteTableObserver {
    
    // MARK: - Public Vars
    
    let tableName:String
    let columnNames:[String]
    
    private var resultsController:FetchedRecordsController<TableRow>!
    
    weak var delegate: TableObserverDelegate?
    
    var isObserving: Bool = true
    
    
    // MARK: - Private Vars
    private var currentRowsCreatingUp:[TableRow] = []
    private var currentRowsUpdatingUp:[TableRow] = []
    private var currentRowsDeletingUp:[TableRow] = []
    
    // MARK: - inits
    init(tableName:String, databaseQueue:DatabaseQueue) {
        self.tableName = tableName
        self.columnNames = try! SQLiteTableObserver.columnNames(for: tableName, in: databaseQueue)
        self.resultsController = try! setupResultsController(tableName, queue:databaseQueue )
    }
    
    
    private static func columnNames(for table:String, in databaseQueue:DatabaseQueue) throws -> [String] {
        let columnNames = try databaseQueue.read { (db) -> [String] in
            let columns:[Row]
            
            columns = try Row.fetchAll(db,  sql: "PRAGMA table_info(\(table))")
            return columns.compactMap({ (row) -> String in
                return row["name"]
            })
        }
        return columnNames
    }
    
    private func setupResultsController(_ table:String, queue:DatabaseQueue ) throws ->
        FetchedRecordsController<TableRow> {
            
            let request = SQLRequest<TableRow>(sql: "SELECT `\(table)`.* FROM `\(table)`")
            
            let controller = try FetchedRecordsController<TableRow>(queue, request: request)
            
            try controller.performFetch()
            
            controller.trackChanges(willChange: { [weak self] (contoller) in
                
                guard let self = self, self.isObserving else {
                    return
                }
                
                }, onChange: { [weak self] (controller, tableRow, change) in
                    
                    guard let self = self, self.isObserving else {
                        return
                    }
                    
                    switch change{
                    case .deletion:
                        self.currentRowsDeletingUp.append(tableRow)
                    case .insertion:
                        self.currentRowsCreatingUp.append(tableRow)
                    case .update:
                        self.currentRowsUpdatingUp.append(tableRow)
                    case .move:
                        self.currentRowsUpdatingUp.append(tableRow)
                    }
                    
            }) { [weak self] (controller) in
                
                guard let self = self, self.isObserving == true else {
                    return
                }
                
                var deleteSet = Set(self.currentRowsDeletingUp)
                var updateSet = Set(self.currentRowsUpdatingUp)
                var createSet = Set(self.currentRowsCreatingUp)
                
                let otherUpdateSet = createSet.intersection(deleteSet)
                
                deleteSet.subtract(otherUpdateSet)
                createSet.subtract(otherUpdateSet)
                updateSet.formUnion(otherUpdateSet)
                
                self.delegate?.tableObserver(self, created: Array(createSet), updated: Array(updateSet), deleted: Array(deleteSet))
                
                self.currentRowsDeletingUp = []
                self.currentRowsUpdatingUp = []
                self.currentRowsCreatingUp = []
                
            }
            
            return controller
            
    }
    
    
}

extension SQLiteTableObserver : TableObserving {
    
}
