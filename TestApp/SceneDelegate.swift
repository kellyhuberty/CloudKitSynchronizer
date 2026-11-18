//
//  SceneDelegate.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 11/15/26.
//  Copyright © 2026 Kelly Huberty. All rights reserved.
//

import UIKit
import CloudKitSynchronizer

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        let navVC = UINavigationController(rootViewController: WordListViewController(repo: appDelegate.repo))

        window?.rootViewController = navVC

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}
