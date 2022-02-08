//
//  Repo.swift
//  VHX
//
//  Created by Kelly Huberty on 12/23/18.
//  Copyright © 2018 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB
import CloudKit

public protocol RepoManufacturing {
    func loadRepo(for domain:String) -> Repo?
}

public class Repo {
    
    public let databaseQueue: DatabaseQueue
    
    var cloudSynchronizer: CloudSynchronizer?
    
    public init(domain: String,
         path: String,
         migrator: DatabaseMigrator,
         synchronizedTables: [TableConfiguration]? ) {
        
        let dirPath = URL(fileURLWithPath: path).deletingLastPathComponent()
        File.makeDirectoryIfUnavailable(dirPath)
                
        let dbPool = try! DatabaseQueue(path: path)
        
        self.databaseQueue = dbPool
        try! migrator.migrate(dbPool)
        
        if let synchronizedTables = synchronizedTables {
            let synchronizer = try! CloudSynchronizer(databaseQueue: databaseQueue,
                                                      container: CKContainer(identifier: domain)
            )
            synchronizer.synchronizedTables = synchronizedTables
            synchronizer.startSync()
            self.cloudSynchronizer = synchronizer
        }
    }
    
    public func refreshFromCloud(_ completion: @escaping (() -> Void)) {
        cloudSynchronizer?.refreshFromCloud(completion)
    }

    @available(iOS 13, macOS 10.15, watchOS 6, *)
    public func refreshFromCloud() async {
        await cloudSynchronizer?.refreshFromCloud()
    }
    
}

extension Repo {
    
    public func registeredForRemoteNotifications(deviceTokens: Data) {
        cloudSynchronizer?.setupSubscriptions {
            
        }
    }
    
    @available(iOS 13, macOS 10.15, watchOS 6, *)
    public func processRemoteNotification(_ userInfo: [AnyHashable : Any]) async -> Bool {
        await refreshFromCloud()
        return true
    }

}
