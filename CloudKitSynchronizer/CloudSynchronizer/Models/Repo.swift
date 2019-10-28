//
//  Repo.swift
//  VHX
//
//  Created by Kelly Huberty on 12/23/18.
//  Copyright © 2018 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

class Repo{
    
    static let shared = Repo()
    
    let cloudSynchronizer:CloudSynchronizer!
    
    let databaseQueue:DatabaseQueue = {
        
        let directory = URL(string:Directories.documents)!.appendingPathComponent("data.db")
        
        print("Database Path: ")
        print(directory.path + "\n")
        
        let dbPool = try! DatabaseQueue(path: directory.path)
        let migrator = setupMigrator()
        
        try! migrator.migrate(dbPool)
        
        return dbPool
    
    }()
    
    init() {
        
        cloudSynchronizer = try! CloudSynchronizer(databaseQueue: databaseQueue)
        cloudSynchronizer.synchronizedTables = [SynchronizedTable(table:"Item")]
        cloudSynchronizer.startSync()
    
    }
    
    static func setupMigrator() -> DatabaseMigrator{
    
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1.0.0.1") { (db) in
            try! db.create(table: "Item", body: { (table) in
                table.column("identifier", Database.ColumnType.text).unique(onConflict: Database.ConflictResolution.replace).primaryKey()
                table.column("text", Database.ColumnType.text)
            })
        }
        
// NextMigration

        
// NextMigration
//        migrator.registerMigration("v1.0.0.3") { (db) in
//
//        }
        
        return migrator
        
    }
    
}
