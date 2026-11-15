//
//  AppDelegate.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import UIKit
import GRDB
import CloudKitSynchronizer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var repo:Repo! = {
        loadRepo(for: "")!
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Window and root view controller setup happens in SceneDelegate.
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    
    func loadRepo(for domain: String) -> Repo? {
        
        let directory = URL(fileURLWithPath: Directories.documents)
        let dataURLPath = directory.appendingPathComponent("data.db")
        let assetURL = directory.appendingPathComponent("assets")
        
        print("Database Path: ")
        print(dataURLPath.path + "\n")
        
        //let dbPool = try! DatabaseQueue(path: directory.path)
        
        let migrator = setupMigrator()
        
        let repo = Repo(domain: "iCloud.com.kellyhuberty.CloudKitSynchronizer",
                        path: dataURLPath.path,
                        migrator: migrator,
                        synchronizedTables: [ TableConfiguration(table: "Item", assets: [Item.AssetConfigs.imagePath])] )
                
        return repo
    }
    
    func setupMigrator() -> DatabaseMigrator {
        return LSTDatabaseMigrator.setupMigrator()
    }
    
}

extension Repo {
    static let assetURL: URL = {
        let directory = URL(fileURLWithPath:Directories.documents)
        let assetURL = directory.appendingPathComponent("assets")
        return assetURL
    }()
}
