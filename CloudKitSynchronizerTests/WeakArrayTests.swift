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

    var subject: WeakArray<TestObject>!
    
    class TestObject: Identifiable, Equatable {
    
        let id: String
        
        init() {
            id = UUID().uuidString
        }
        
        static func == (lhs: WeakArrayTests.TestObject, rhs: WeakArrayTests.TestObject) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    override func setUpWithError() throws {
        
        subject = WeakArray<TestObject>()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        subject = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddObject() throws {
        
        var object: TestObject? = TestObject()
        subject.append(object!)
        
        XCTAssertEqual(subject.count, 1)
        object = nil
        XCTAssertEqual(subject.count, 0)
    }

    func testRemoveObject() throws {
        
        var object: TestObject? = TestObject()
        subject.append(object!)
        
        XCTAssertEqual(subject.count, 1)
        subject.removeAll()
        XCTAssertEqual(subject.count, 0)
    }
    
    func testAddObjects() throws {
        
        let object1: TestObject = TestObject()
        var object2: TestObject = TestObject()
        let object3: TestObject = TestObject()

        subject.append(object1)
        subject.append(object2)
        subject.append(object3)

        XCTAssertEqual(subject.count, 3)
        
        XCTAssert(subject[0] == object1)
        XCTAssert(subject[1] == object2)
        XCTAssert(subject[2] == object3)

    }

    func testRemoveObjects() throws {
        
        let object1: TestObject = TestObject()
        var object2: TestObject? = TestObject()
        let object3: TestObject = TestObject()

        subject.append(object1)
        subject.append(object2!)
        subject.append(object3)

        
        XCTAssertEqual(subject.count, 3)
        object2 = nil
        XCTAssertEqual(subject.count, 2)
        
        XCTAssert(subject.contains(object1))
        XCTAssert(subject.contains(object3))

    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
