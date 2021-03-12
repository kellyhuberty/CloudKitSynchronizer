//
//  CloudKitSynchronizerTests.swift
//  CloudKitSynchronizerTests
//
//  Created by Kelly Huberty on 3/20/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import XCTest
//import Cuckoo
@testable import CloudKitSynchronizer
import GRDB

extension XCTestCase {
    
    var currentTestName: String {
        let regex = try! NSRegularExpression(pattern: "-\\[[a-zA-Z0-9]*[\\s]")
                
        var currentTestName = regex.stringByReplacingMatches(in: self.name,
                                                             options: [],
                                                             range: NSRange(location: 0, length: self.name.count - 1),
                                                             withTemplate: "")
        
        currentTestName = currentTestName.replacingOccurrences(of: "]", with: "")
        
        return currentTestName
    }
}

//class MockOperationFactory: CloudOperationProducing {
//    func newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation
//    func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation
//    func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation
//}

class CloudSynchronizerTests: XCTestCase {

    
    var databaseQueue: DatabaseQueue!
    
    var pullOperation: MockCloudRecordPullOperation!
    var pushOperation: MockCloudRecordPushOperation!
    var zoneAvailablityOperation: MockCloudZoneAvailablityOperation!
 
    var mockOperationProducer: MockCloudKitOperationProducer?
    var mockCloudRecordStore: MockCloudRecordStoring?
    var mockTableObserverProducer: MockTableObserverProducing?

    var subject: CloudSynchronizer?
    
    
//    var operationFactory: 
    
    override func setUp() {
        /*
        databaseQueue = try! DatabaseQueue(path: Directories.documents + "/" + currentTestName + ".db")
        mockOperationProducer = MockCloudKitOperationProducer()
        mockTableObserverProducer = MockTableObserverProducing()
        mockCloudRecordStore = MockCloudRecordStoring()

        pullOperation = MockCloudRecordPullOperation()
        pushOperation = MockCloudRecordPushOperation()
        zoneAvailablityOperation = MockCloudZoneAvailablityOperation()
        
        stub(mockOperationProducer!) { stub in
            when(stub.newPullOperation(delegate: any())).thenReturn(pullOperation)
            when(stub.newPushOperation(delegate: any())).thenReturn(pushOperation)
            when(stub.newZoneAvailablityOperation()).thenReturn(zoneAvailablityOperation)
        }
        
        subject = try! CloudSynchronizer(
            databaseQueue: databaseQueue,
            operationFactory: mockOperationProducer,
            tableObserverFactory: mockTableObserverProducer,
            cloudRecordStore: mockCloudRecordStore
        )
 */
//
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

