//
//  CloudSyncIntegrationTests.swift
//  CloudKitSynchronizerTests
//
//  Created by Kelly Huberty on 3/10/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import XCTest
@testable import CloudKitSynchronizer


class CloudSyncIntegrationTests: XCTestCase {
    
    
    var repo1: Repo!
    var repo2: Repo!

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func repo(with name: String) {
        
        let repo = Repo(domain: "com.kellyhuberty.cloudkitsynchronizer",
                        path: directory.path,
                        migrator: migrator,
                        synchronizedTables: [SynchronizedTable(table:"Item")] )
        
        let directory = URL(string:Directories.documents)!.appendingPathComponent("\(#file)-\(name).db")
        
        print("Database Path: ")
        print(directory.path + "\n")
         
        let migrator = LSTDatabaseMigrator.setupMigrator()
            
        let repo = Repo(domain: "com.kellyhuberty.cloudkitsynchronizer",
                        path: directory.path,
                        migrator: migrator,
                        synchronizedTables: [SynchronizedTable(table:"Item")] )
        
        
    }
    
    override func cleanedTestName() -> String {
        
        let classStr = NSStringFromClass(self.class)
        
        // get the name and remove the class name and what comes before the class name
        var currentTestName = self.name.replacingOccurrences(of: "-[\(cleanedClassName()) ", with: "")

        // And then you'll need to remove the closing square bracket at the end of the test name

        currentTestName = currentTestName.replacingOccurrences(of: "]", with: "")
        
        return currentTestName
    }
    
    override func cleanedClassName() -> String {
        
        let classStr = NSStringFromClass(self.class)
        
        return classStr
    }
    
    override func tearDown() {
        
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

}
