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

    var window: UIWindow?

    lazy var repo:Repo! = {
        loadRepo(for: "")!
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        
        let navVC = UINavigationController(rootViewController: WordListViewController(repo: self.repo))
        
        window?.rootViewController = navVC
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: RepoManufacturing {
    
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
