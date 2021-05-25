//
//  WeakArrayTests.swift
//  CloudKitSynchronizerTests
//
//  Created by Kelly Huberty on 5/24/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import XCTest
@testable import CloudKitSynchronizer

class WeakArrayTests: XCTestCase {

    var subject: WeakArray<NSObject>!
    
    override func setUpWithError() throws {
        
        subject = WeakArray<NSObject>()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        subject = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddObject() throws {
        
        var indexPath: NSObject? = NSObject()
        subject.append(indexPath!)
        
        XCTAssertEqual(subject.count, 1)
        indexPath = nil
        XCTAssertEqual(subject.count, 0)
    }

    func testRemoveObject() throws {
        
        var indexPath: NSObject? = NSObject()
        subject.append(indexPath!)
        
        XCTAssertEqual(subject.count, 1)
        subject.removeAll()
        XCTAssertEqual(subject.count, 0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
