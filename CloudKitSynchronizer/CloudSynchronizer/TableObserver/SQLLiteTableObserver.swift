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
//
//    struct RecordIdentifier {
//
//    }
    
    // MARK: - Public Vars
    let tableConfiguration: TableConfigurable
    let columnNames:[String]
    
    private var resultsController: DatabaseRegionObservation!
    
    weak var delegate: TableObserverDelegate?
    
    var isObserving: Bool = true
    
    // MARK: - Private Vars
    private var currentRowsCreatingUp:[TableRow] = []
    private var currentRowsUpdatingUp:[TableRow] = []
    private var currentRowsDeletingUp:[TableRow] = []
    
    private var databaseQueue: DatabaseQueue
    
    
    // MARK: - inits
    init(tableConfiguration: TableConfigurable, databaseQueue:DatabaseQueue) {
        self.tableConfiguration = tableConfiguration
        self.columnNames = try! SQLiteTableObserver.columnNames(for: tableConfiguration.tableName, in: databaseQueue)
        self.databaseQueue = databaseQueue
        self.databaseQueue.add(transactionObserver: self)
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
    
    /*
    private func setupResultsController(_ table:String, queue:DatabaseQueue ) throws ->
    DatabaseRegionObservation<TableRow> {
                    
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
    */
    
    let queue: DispatchQueue = {
        DispatchQueue(label: "TableObserver", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
        
    }()
    
    private func sendTableRowsAndReset() {
        
        guard currentRowsCreatingUp.count > 0 ||
                currentRowsUpdatingUp.count > 0 ||
                    currentRowsDeletingUp.count > 0 else {
            return
        }
        
        let creatingUp = currentRowsCreatingUp
        let updatingUp = currentRowsUpdatingUp
        let deletingUp = currentRowsDeletingUp

        resetForNextTransaction()
        
        queue.async { [weak self] in
            guard let self = self else {return}
            self.delegate?.tableObserver(self, created: creatingUp, updated: updatingUp, deleted: deletingUp)
        }
        
    }
    
    private func resetForNextTransaction() {
        currentRowsCreatingUp = []
        currentRowsUpdatingUp = []
        currentRowsDeletingUp = []
    }
    
}

extension SQLiteTableObserver : TableObserving {
}


extension SQLiteTableObserver : TransactionObserver {
    func observes(eventsOfKind eventKind: DatabaseEventKind) -> Bool {
        guard self.isObserving else {
            return false
        }
        let isSameTable = eventKind.tableName == self.tableName
        NSLog("log \(eventKind.tableName) == \(self.tableName) \(isSameTable)")
        return isSameTable
    }
    
    /// Cannot touch the database.
    func databaseDidChange(with event: DatabaseEvent) {
        
    }
    
    func databaseDidCommit(_ db: Database) {
        guard self.isObserving else {
            return
        }
        sendTableRowsAndReset()
    }
    
    func databaseDidRollback(_ db: Database) {
        guard self.isObserving else {
            return
        }
        resetForNextTransaction()
    }
    
    func databaseWillChange(with event: DatabasePreUpdateEvent) {
        guard self.isObserving else {
            return
        }
        
        switch event.kind {
        case .insert:
            if let tableRow = event.finalTableRow(for: columnNames) {
                currentRowsCreatingUp.append(tableRow)
            }
        case .delete:
            if let tableRow = event.initialTableRow(for: columnNames) {
                currentRowsDeletingUp.append(tableRow)
            }
        case .update:
            if let tableRow = event.finalTableRow(for: columnNames) {
                currentRowsUpdatingUp.append(tableRow)
            }
        }
    }
}

extension DatabasePreUpdateEvent {
    
    func initialTableRow(for columnNames: [String]) -> TableRow? {
        guard let values = initialDatabaseValues else {
            return nil
        }
        return tableRow(values: values, columnNames: columnNames)
    }
    
    func finalTableRow(for columnNames: [String]) -> TableRow? {
        guard let values = finalDatabaseValues else {
            return nil
        }
        return tableRow(values: values, columnNames: columnNames)
    }
    
    func tableRow(values:[DatabaseValue], columnNames:[String]) -> TableRow?  {
        guard columnNames.count == values.count else {
            return nil
        }
        
        var columnValues = [String: DatabaseValueConvertible?]()
        
        for i in 0 ..< columnNames.count {
            columnValues[columnNames[i]] = values[i]
        }
                
        let tableRow = TableRow(row: Row(columnValues))
        
        return tableRow
    }
    
}
