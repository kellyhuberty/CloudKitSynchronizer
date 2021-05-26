//
//  CloudSyncIntegrationTests.swift
//  CloudKitSynchronizerTests
//
//  Created by Kelly Huberty on 3/10/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import XCTest
@testable import CloudKitSynchronizer
import GRDB

class CloudSyncIntegrationTests: XCTestCase {
    
    var repo1: Repo!
    var repo2: Repo!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func setUp() {
        repo1 = repo(identifier: "1")
        
        let expectation = self.expectation(description: "resetZones")
        repo1.cloudSynchronizer?.resetZones {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 60)
        
        repo2 = repo(identifier: "2")
    }
    
    override func tearDown() {

    }
    
    func repo(identifier: String) -> Repo {
        
        let directory = URL(string:Directories.documents)!.appendingPathComponent("\(cleanedClassName()).\(cleanedTestName())--\(identifier).db")
        
        let fileManager = FileManager.default
       
       // Check if file exists
        if fileManager.fileExists(atPath: directory.path) {
           // Delete file
           try! fileManager.removeItem(atPath: directory.path)
       } else {
           print("File does not exist")
       }
        
        print("Database Path: ")
        print(directory.path + "\n")
        
        let repo = Repo(domain: "com.kellyhuberty.cloudkitsynchronizer.test",
                        path: directory.path,
                        migrator: LSTDatabaseMigrator.setupMigrator(),
                        synchronizedTables: [SynchronizedTable(table:"Item")] )
        
        return repo
    }
    
    func cleanedTestName() -> String {
                
        // get the name and remove the class name and what comes before the class name
        var currentTestName = self.name.replacingOccurrences(of: "-[\(cleanedClassName()) ", with: "")

        // And then you'll need to remove the closing square bracket at the end of the test name

        currentTestName = currentTestName.replacingOccurrences(of: "]", with: "")
        
        return currentTestName
    }
    
    func cleanedClassName() -> String {
        
        let classStr = NSStringFromClass(type(of:self))

        return classStr
    }

    func testCloudKitAdd() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)

        var stella = Item()
        stella.text = "Stella"
        
        var theo = Item()
        theo.text = "Theo"
        
        var gemma = Item()
        gemma.text = "Gemma"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! stella.save(db)
            try! theo.save(db)
            try! gemma.save(db)
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

        var stella = Item()
        stella.text = "Stella"
        
        var theo = Item()
        theo.text = "Theo"
        
        var gemma = Item()
        gemma.text = "Gemma"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! stella.save(db)
            try! theo.save(db)
            try! gemma.save(db)
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
        
        var editedItem = (items2.first { $0.text == "Stella" })!
        editedItem.text = "Stella Jean"
        
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
        
        XCTAssertTrue(names.contains("Stella Jean"))
        
    }
    
    func testCloudKitAddDelete() {
        
        waitUntilSyncing(repo1)
        waitUntilSyncing(repo2)

        var stella = Item()
        stella.text = "Stella"
        
        var theo = Item()
        theo.text = "Theo"
        
        var gemma = Item()
        gemma.text = "Gemma"
        
        
        try! repo1.databaseQueue.write { (db) in
            try! stella.save(db)
            try! theo.save(db)
            try! gemma.save(db)
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
        
        let deletedItem = (items2.first { $0.text == "Stella" })!
        
        var items1Edited:[Item] = []
        var items2Edited:[Item] = []
        
        try! repo2.databaseQueue.write { (db) in
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
        
        XCTAssertTrue(names.contains("Theo"))
        XCTAssertTrue(names.contains("Gemma"))

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

