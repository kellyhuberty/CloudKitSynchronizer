//
//  CloudSyncIntegrationTests.swift
//  CloudKitSynchronizerTests
//
//  Created by Kelly Huberty on 3/10/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import XCTest
@testable import CloudKitSynchronizerAppPod
@testable import CloudKitSynchronizer
import GRDB

class CloudSyncIntegrationTests: XCTestCase {
    
    var repo1: Repo!
    var repo2: Repo!
    
    var repo1AssetURL: URL!
    var repo2AssetURL: URL!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override class func setUp() {
        removeItemAtPath(URL(fileURLWithPath: Directories.testing))
    }
    
    override func setUp() {
        //Init repo 1
        (repo1, repo1AssetURL) = repo(identifier: "1")
        
        // Perform cleanup, since data from a previous test might be laying around.
        let expectation = self.expectation(description: "resetZones")
        repo1.cloudSynchronizer?.resetZones {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 60)
        
        //Init repo 2
        (repo2, repo2AssetURL)  = repo(identifier: "2")
    }
    
    override func tearDown() {

    }
    
    fileprivate func removeItemAtPath(_ directory: URL){
        CloudSyncIntegrationTests.removeItemAtPath(directory)
    }
    
    static fileprivate func removeItemAtPath(_ directory: URL) {
        let fileManager = FileManager.default
        
        // Check if file exists
        if fileManager.fileExists(atPath: directory.path) {
            // Delete file
            try! fileManager.removeItem(atPath: directory.path)
        } else {
            print("File does not exist")
        }
    }
    
    func repo(identifier: String) -> (Repo, URL) {
        
        let directory = URL(fileURLWithPath: Directories.testing).appendingPathComponent("\(cleanedClassName()).\(cleanedTestName())--\(identifier)")
        
        let dbFile = directory.appendingPathComponent("data.db")
        let assetsDirectoryFile = directory.appendingPathComponent("assets")
        
        removeItemAtPath(directory)
        
        print("Database Path: ")
        print(dbFile.path + "\n")
       
        print("Assets Path: ")
        print(assetsDirectoryFile.path + "\n")

        let assetConfig = AssetConfiguration(
            column: Item.AssetConfigs.imagePath.column,
            directory: assetsDirectoryFile)
        
        let repo = Repo(domain: "com.kellyhuberty.cloudkitsynchronizer.test",
                        path: dbFile.path,
                        migrator: LSTDatabaseMigrator.setupMigrator(),
                        synchronizedTables: [TableConfiguration(table:"Item",
                                                                assets: [assetConfig])] )
                
        return (repo, assetsDirectoryFile)
    }
    
    func cleanedTestName() -> String {
        
        var components = cleanedClassNameComponents()
        
        components.append(".")
        components.append("-")
        components.append("[")
        components.append("]")
        components.append(" ")

        var currentTestName = self.name
        
        for component in components {
            currentTestName = currentTestName.replacingOccurrences(of: component, with: "")
        }
        
        return currentTestName
    }
    
    func cleanedClassName() -> String {
        
        return cleanedClassNameComponents().last ?? ""
    }
    
    func cleanedClassNameComponents() -> [String] {
        
        let classStr = NSStringFromClass(type(of:self))

        let components = classStr.components(separatedBy: ".")
        
        return components
    }

    func testCloudKitAdd() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)

        var daphne = Item()
        daphne.text = "Daphne"
        
        var shaggy = Item()
        shaggy.text = "Shaggy"
        
        var scooby = Item()
        scooby.text = "Scooby"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! daphne.save(db)
            try! shaggy.save(db)
            try! scooby.save(db)
        }
        
        var items1:[Item] = []
        var items2:[Item] = []

        try! repo1.databaseQueue.read { (db) in
            items1 = try! Item.fetchAll(db)
        }
        
        waitReload(repo2) { (db) -> Bool in
            items2 = try! Item.fetchAll(db)
            return Set(items1) == Set(items2)
        }
        XCTAssertEqual(items1.count, 3)
        XCTAssertEqual(items2.count, 3)

        XCTAssertEqual(Set(items1), Set(items2))
    }
    
    func testCloudKitAddEdit() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)

        var daphne = Item()
        daphne.text = "Daphne"
        
        var shaggy = Item()
        shaggy.text = "Shaggy"
        
        var scooby = Item()
        scooby.text = "Scooby"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! daphne.save(db)
            try! shaggy.save(db)
            try! scooby.save(db)
        }
        
        var items1:[Item] = []
        var items2:[Item] = []

        try! repo1.databaseQueue.read { (db) in
            items1 = try! Item.fetchAll(db)
        }
        
        waitReload(repo2) { (db) -> Bool in
            items2 = try! Item.fetchAll(db)
            return Set(items1) == Set(items2)
        }
        XCTAssertEqual(items1.count, 3)
        XCTAssertEqual(items2.count, 3)
        XCTAssertEqual(Set(items1), Set(items2))
        
        var editedItem = (items2.first { $0.text == "Daphne" })!
        editedItem.text = "Daphne Blake"
        
        var items1Edited:[Item] = []
        var items2Edited:[Item] = []
        
        try! repo2.databaseQueue.write { (db) in
            try! editedItem.save(db)
        }
        
        try! repo2.databaseQueue.read { (db) in
            items2Edited = try! Item.fetchAll(db)
        }
        
        waitReload(repo1) { (db) -> Bool in
            items1Edited = try! Item.fetchAll(db)
            return Set(items1Edited) == Set(items2Edited)
        }
        
        XCTAssertEqual(items1Edited.count, 3)
        XCTAssertEqual(items2Edited.count, 3)
        XCTAssertEqual(Set(items1Edited), Set(items2Edited))
        
        let names = items1Edited.map { $0.text }
        
        XCTAssertTrue(names.contains("Daphne Blake"))
        
    }
    
    func testCloudKitAddDelete() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)

        var daphne = Item()
        daphne.text = "Daphne"
        
        var shaggy = Item()
        shaggy.text = "Shaggy"
        
        var scooby = Item()
        scooby.text = "Scooby"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! daphne.save(db)
            try! shaggy.save(db)
            try! scooby.save(db)
        }
        
        var items1:[Item] = []
        var items2:[Item] = []

        try! repo1.databaseQueue.read { (db) in
            items1 = try! Item.fetchAll(db)
        }
        
        waitReload(repo2) { (db) -> Bool in
            items2 = try! Item.fetchAll(db)
            return Set(items1) == Set(items2)
        }
        XCTAssertEqual(items1.count, 3)
        XCTAssertEqual(items2.count, 3)
        XCTAssertEqual(Set(items1), Set(items2))
        
        let deletedItem = (items2.first { $0.text == "Daphne" })!
        
        var items1Edited:[Item] = []
        var items2Edited:[Item] = []
        
        _ = try! repo2.databaseQueue.write { (db) in
            try! deletedItem.delete(db)
        }
        
        try! repo2.databaseQueue.read { (db) in
            items2Edited = try! Item.fetchAll(db)
        }
        
        waitReload(repo1) { (db) -> Bool in
            items1Edited = try! Item.fetchAll(db)
            return Set(items1Edited) == Set(items2Edited)
        }
        
        XCTAssertEqual(items1Edited.count, 2)
        XCTAssertEqual(items2Edited.count, 2)
        XCTAssertEqual(Set(items1Edited), Set(items2Edited))
        
        let names = items1Edited.map { $0.text }
        
        XCTAssertTrue(names.contains("Shaggy"))
        XCTAssertTrue(names.contains("Scooby"))

    }
    
    func testSyncedAssetAddSync() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)
        let image = UIImage(named: "daphne.jpg", in: Bundle.init(for: type(of: self)), compatibleWith: nil)
        
        var daphne = Item()
        daphne.text = "Daphne"
        daphne.imageAsset.testing(repo1AssetURL).uiimage = image
                
        XCTAssertNotNil(image)

        try! repo1.databaseQueue.write { (db) in
            try! daphne.save(db)
        }
        
        var items1:[Item] = []
        var items2:[Item] = []

        try! repo1.databaseQueue.read { (db) in
            items1 = try! Item.fetchAll(db)
        }
        
        waitReload(repo2) { (db) -> Bool in
            items2 = try! Item.fetchAll(db)
            return items1.count == items2.count
        }

        var first1 = items1.first
        var first2 = items2.first

        XCTAssertEqual(items1.first, items2.first)
        
        XCTAssertNotNil(first1?.imageAsset.testing(repo1AssetURL).uiimage)
        
        XCTAssertEqual(first1?.imageAsset.testing(repo1AssetURL).data,
                       first2?.imageAsset.testing(repo1AssetURL).data)

    }
    
    func testSyncedAssetRemoveSync() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)
        let image = UIImage(named: "daphne.jpg", in: Bundle.init(for: type(of: self)), compatibleWith: nil)
        
        var daphne = Item()
        daphne.text = "Daphne"
        daphne.imageAsset.testing(repo1AssetURL).uiimage = image
                
        XCTAssertNotNil(image)
        XCTAssertNotNil(daphne.imageAsset.testing(repo1AssetURL).uiimage)

        try! repo1.databaseQueue.write { (db) in
            try! daphne.save(db)
        }
        
        var items1:[Item] = []
        var items2:[Item] = []
        var items3:[Item] = []

        try! repo1.databaseQueue.read { (db) in
            items1 = try! Item.fetchAll(db)
        }
              
        var first1:Item?
        var first2:Item?
        
        waitReload(repo2) { (db) -> Bool in
            items2 = try! Item.fetchAll(db)
            
            first1 = items1.first
            first2 = items2.first
            
            let data1 = first1?.imageAsset.testing(self.repo1AssetURL).data
            let data2 = first2?.imageAsset.testing(self.repo2AssetURL).data
            
//            print("\(items1) == \(items2)")
//            print("\(first1) == \(first2)")
//            print("\(data1) == \(data2)")
            
            return items1.count == items2.count &&
                    first1 == first2 &&
                    data1 == data2
        }

        XCTAssertNotNil(first1)
        XCTAssertNotNil(first2)
        XCTAssertEqual(items1.first, items2.first)
        XCTAssertNotNil(first2?.imageAsset.testing(repo2AssetURL).uiimage)

        XCTAssertEqual(first1?.imageAsset.testing(repo1AssetURL).data,
                       first2?.imageAsset.testing(repo2AssetURL).data)
        
        first2?.imageAsset.testing(repo2AssetURL).uiimage = nil

        try! repo2.databaseQueue.write { (db) in
            try! first2?.save(db)
        }

        var first3: Item? = nil
                
        waitReload(repo1) { (db) -> Bool in
            items3 = try! Item.fetchAll(db)
            first3 = items3.first
            let data3 = first3?.imageAsset.testing(self.repo1AssetURL).data
            let data2 = first2?.imageAsset.testing(self.repo2AssetURL).data

            print(data3)
            print(data2)

            return data3 == data2
        }

        XCTAssertNotNil(first3)


        XCTAssertEqual(first3, first2)

        XCTAssertNil(first3?.imageAsset.testing(repo1AssetURL).uiimage)

        XCTAssertEqual(first1?.imageAsset.testing(repo1AssetURL).data,
                       first2?.imageAsset.testing(repo1AssetURL).data)
        
    }
     
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func waitReload(_ repo:Repo,  _ until: @escaping (_ db:Database) -> Bool ){
        
        var fulfilled = false
        var tryCount = 100
        
        while !fulfilled && tryCount > 0 {
            let expectation = self.expectation(description: "waitReload")
            
            sleep(2)
            
            repo.cloudSynchronizer?.refreshFromCloud {
                fulfilled = try! repo.databaseQueue.write { (db) -> Bool in
                    let expect = until(db)
                    expectation.fulfill()
                    return expect
                }
            }
            
            self.wait(for: [expectation], timeout: 30)
            tryCount = tryCount - 1
        }
    }

    func waitUntilSyncing(_ repo:Repo){
        
        let expect = self.expectation(description: "cloudSyncingStatus")
        
        DispatchQueue.global().async {
            var notSyncing = false
            while !notSyncing {
                if case .syncing = repo.cloudSynchronizer?.status {
                    notSyncing = true
                }
            }
            expect.fulfill()
        }
    
        self.wait(for: [expect], timeout: 60)
    }

}

