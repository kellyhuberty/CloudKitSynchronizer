//
//  Repo.swift
//  VHX
//
//  Created by Kelly Huberty on 12/23/18.
//  Copyright © 2018 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

protocol RepoManufacturing {
    func loadRepo(for domain:String) -> Repo?
}

public class Repo{
    
    public private(set) static var shared: Repo = {
        Repo.applicationDelegate(for: "")
    }()
    
    public let databaseQueue: DatabaseQueue
    
    var cloudSynchronizer: CloudSynchronizer?
    
    init(domain: String,
         path: String,
         migrator: DatabaseMigrator,
         synchronizedTables: [SynchronizedTable]? ) {
        
        let dbPool = try! DatabaseQueue(path: path)
        
        self.databaseQueue = dbPool
        try! migrator.migrate(dbPool)
        
        
        if let synchronizedTables = synchronizedTables {
            let synchronizer = try! CloudSynchronizer(databaseQueue: databaseQueue)
            synchronizer.synchronizedTables = synchronizedTables
            synchronizer.startSync()
            self.cloudSynchronizer = synchronizer
        }
    }
    
    static func applicationDelegate(for domain:String) -> Repo {
        guard let appDelegate = UIApplication.shared.delegate as? RepoManufacturing else {
            fatalError("Cannot load Repo")
        }
        guard let repo = appDelegate.loadRepo(for: domain) else {
            fatalError("Cannot load Repo")
        }
        return repo
    }
}
