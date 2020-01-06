//
//  LSTDatabaseMigrator.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 1/4/20.
//  Copyright © 2020 Kelly Huberty. All rights reserved.
//

import GRDB

class LSTDatabaseMigrator {
    
    static func setupMigrator() -> DatabaseMigrator {
    
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1.0.0.1") { (db) in
            try! db.create(table: "Item", body: { (table) in
                table.column("identifier", Database.ColumnType.text).unique(onConflict: Database.ConflictResolution.replace).primaryKey()
                table.column("text", Database.ColumnType.text)
            })
        }
        
        migrator.registerMigration("v1.0.0.2") { (db) in
            try! db.alter(table: "Item", body: { (table) in
                table.add(column:"nextIdentifier", Database.ColumnType.text)
            })
        }
        
        return migrator
    }
    
}
