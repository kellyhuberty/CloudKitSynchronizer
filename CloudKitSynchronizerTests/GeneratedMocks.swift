// MARK: - Mocks generated from file: CloudKitSynchronizer/CloudSynchronizer/CloudRecordStore/CloudRecordStoringProtocols.swift at 2019-12-24 16:29:32 +0000

//
//  CloudRecordStoringProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/24/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Cuckoo
@testable import CloudKitSynchronizer

import CloudKit
import Foundation
import GRDB


 class MockCloudRecordStoring: CloudRecordStoring, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudRecordStoring
    
     typealias Stubbing = __StubbingProxy_CloudRecordStoring
     typealias Verification = __VerificationProxy_CloudRecordStoring

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudRecordStoring?

     func enableDefaultImplementation(_ stub: CloudRecordStoring) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func checkoutRecord(with ids: [String], from table: String, for status: CloudRecordStatus, sorted: Bool, using db: Database) throws -> [CKRecord] {
        
    return try cuckoo_manager.callThrows("checkoutRecord(with: [String], from: String, for: CloudRecordStatus, sorted: Bool, using: Database) throws -> [CKRecord]",
            parameters: (ids, table, status, sorted, db),
            escapingParameters: (ids, table, status, sorted, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.checkoutRecord(with: ids, from: table, for: status, sorted: sorted, using: db))
        
    }
    
    
    
     func checkinCloudRecords(_ records: [CKRecord], with status: CloudRecordStatus, using db: Database) throws {
        
    return try cuckoo_manager.callThrows("checkinCloudRecords(_: [CKRecord], with: CloudRecordStatus, using: Database) throws",
            parameters: (records, status, db),
            escapingParameters: (records, status, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.checkinCloudRecords(records, with: status, using: db))
        
    }
    
    
    
     func checkinCloudRecordIds(_ recordIds: [CKRecord.ID], with status: CloudRecordStatus, using db: Database) throws {
        
    return try cuckoo_manager.callThrows("checkinCloudRecordIds(_: [CKRecord.ID], with: CloudRecordStatus, using: Database) throws",
            parameters: (recordIds, status, db),
            escapingParameters: (recordIds, status, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.checkinCloudRecordIds(recordIds, with: status, using: db))
        
    }
    
    
    
     func checkinCloudRecords(identifiers: [String], with status: CloudRecordStatus, using db: Database) throws {
        
    return try cuckoo_manager.callThrows("checkinCloudRecords(identifiers: [String], with: CloudRecordStatus, using: Database) throws",
            parameters: (identifiers, status, db),
            escapingParameters: (identifiers, status, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.checkinCloudRecords(identifiers: identifiers, with: status, using: db))
        
    }
    
    
    
     func removeCloudRecords(identifiers: [String], using db: Database) throws {
        
    return try cuckoo_manager.callThrows("removeCloudRecords(identifiers: [String], using: Database) throws",
            parameters: (identifiers, db),
            escapingParameters: (identifiers, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.removeCloudRecords(identifiers: identifiers, using: db))
        
    }
    
    
    
     func cloudRecords(with status: CloudRecordStatus, using db: Database) throws -> [CloudRecord] {
        
    return try cuckoo_manager.callThrows("cloudRecords(with: CloudRecordStatus, using: Database) throws -> [CloudRecord]",
            parameters: (status, db),
            escapingParameters: (status, db),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudRecords(with: status, using: db))
        
    }
    

	 struct __StubbingProxy_CloudRecordStoring: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func checkoutRecord<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable, M5: Cuckoo.Matchable>(with ids: M1, from table: M2, for status: M3, sorted: M4, using db: M5) -> Cuckoo.ProtocolStubThrowingFunction<([String], String, CloudRecordStatus, Bool, Database), [CKRecord]> where M1.MatchedType == [String], M2.MatchedType == String, M3.MatchedType == CloudRecordStatus, M4.MatchedType == Bool, M5.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], String, CloudRecordStatus, Bool, Database)>] = [wrap(matchable: ids) { $0.0 }, wrap(matchable: table) { $0.1 }, wrap(matchable: status) { $0.2 }, wrap(matchable: sorted) { $0.3 }, wrap(matchable: db) { $0.4 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "checkoutRecord(with: [String], from: String, for: CloudRecordStatus, sorted: Bool, using: Database) throws -> [CKRecord]", parameterMatchers: matchers))
	    }
	    
	    func checkinCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ records: M1, with status: M2, using db: M3) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<([CKRecord], CloudRecordStatus, Database)> where M1.MatchedType == [CKRecord], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([CKRecord], CloudRecordStatus, Database)>] = [wrap(matchable: records) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "checkinCloudRecords(_: [CKRecord], with: CloudRecordStatus, using: Database) throws", parameterMatchers: matchers))
	    }
	    
	    func checkinCloudRecordIds<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ recordIds: M1, with status: M2, using db: M3) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<([CKRecord.ID], CloudRecordStatus, Database)> where M1.MatchedType == [CKRecord.ID], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([CKRecord.ID], CloudRecordStatus, Database)>] = [wrap(matchable: recordIds) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "checkinCloudRecordIds(_: [CKRecord.ID], with: CloudRecordStatus, using: Database) throws", parameterMatchers: matchers))
	    }
	    
	    func checkinCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(identifiers: M1, with status: M2, using db: M3) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<([String], CloudRecordStatus, Database)> where M1.MatchedType == [String], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], CloudRecordStatus, Database)>] = [wrap(matchable: identifiers) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "checkinCloudRecords(identifiers: [String], with: CloudRecordStatus, using: Database) throws", parameterMatchers: matchers))
	    }
	    
	    func removeCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(identifiers: M1, using db: M2) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<([String], Database)> where M1.MatchedType == [String], M2.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], Database)>] = [wrap(matchable: identifiers) { $0.0 }, wrap(matchable: db) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "removeCloudRecords(identifiers: [String], using: Database) throws", parameterMatchers: matchers))
	    }
	    
	    func cloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(with status: M1, using db: M2) -> Cuckoo.ProtocolStubThrowingFunction<(CloudRecordStatus, Database), [CloudRecord]> where M1.MatchedType == CloudRecordStatus, M2.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordStatus, Database)>] = [wrap(matchable: status) { $0.0 }, wrap(matchable: db) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordStoring.self, method: "cloudRecords(with: CloudRecordStatus, using: Database) throws -> [CloudRecord]", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudRecordStoring: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func checkoutRecord<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable, M5: Cuckoo.Matchable>(with ids: M1, from table: M2, for status: M3, sorted: M4, using db: M5) -> Cuckoo.__DoNotUse<([String], String, CloudRecordStatus, Bool, Database), [CKRecord]> where M1.MatchedType == [String], M2.MatchedType == String, M3.MatchedType == CloudRecordStatus, M4.MatchedType == Bool, M5.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], String, CloudRecordStatus, Bool, Database)>] = [wrap(matchable: ids) { $0.0 }, wrap(matchable: table) { $0.1 }, wrap(matchable: status) { $0.2 }, wrap(matchable: sorted) { $0.3 }, wrap(matchable: db) { $0.4 }]
	        return cuckoo_manager.verify("checkoutRecord(with: [String], from: String, for: CloudRecordStatus, sorted: Bool, using: Database) throws -> [CKRecord]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func checkinCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ records: M1, with status: M2, using db: M3) -> Cuckoo.__DoNotUse<([CKRecord], CloudRecordStatus, Database), Void> where M1.MatchedType == [CKRecord], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([CKRecord], CloudRecordStatus, Database)>] = [wrap(matchable: records) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return cuckoo_manager.verify("checkinCloudRecords(_: [CKRecord], with: CloudRecordStatus, using: Database) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func checkinCloudRecordIds<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ recordIds: M1, with status: M2, using db: M3) -> Cuckoo.__DoNotUse<([CKRecord.ID], CloudRecordStatus, Database), Void> where M1.MatchedType == [CKRecord.ID], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([CKRecord.ID], CloudRecordStatus, Database)>] = [wrap(matchable: recordIds) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return cuckoo_manager.verify("checkinCloudRecordIds(_: [CKRecord.ID], with: CloudRecordStatus, using: Database) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func checkinCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(identifiers: M1, with status: M2, using db: M3) -> Cuckoo.__DoNotUse<([String], CloudRecordStatus, Database), Void> where M1.MatchedType == [String], M2.MatchedType == CloudRecordStatus, M3.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], CloudRecordStatus, Database)>] = [wrap(matchable: identifiers) { $0.0 }, wrap(matchable: status) { $0.1 }, wrap(matchable: db) { $0.2 }]
	        return cuckoo_manager.verify("checkinCloudRecords(identifiers: [String], with: CloudRecordStatus, using: Database) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func removeCloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(identifiers: M1, using db: M2) -> Cuckoo.__DoNotUse<([String], Database), Void> where M1.MatchedType == [String], M2.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<([String], Database)>] = [wrap(matchable: identifiers) { $0.0 }, wrap(matchable: db) { $0.1 }]
	        return cuckoo_manager.verify("removeCloudRecords(identifiers: [String], using: Database) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cloudRecords<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(with status: M1, using db: M2) -> Cuckoo.__DoNotUse<(CloudRecordStatus, Database), [CloudRecord]> where M1.MatchedType == CloudRecordStatus, M2.MatchedType == Database {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordStatus, Database)>] = [wrap(matchable: status) { $0.0 }, wrap(matchable: db) { $0.1 }]
	        return cuckoo_manager.verify("cloudRecords(with: CloudRecordStatus, using: Database) throws -> [CloudRecord]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudRecordStoringStub: CloudRecordStoring {
    

    

    
     func checkoutRecord(with ids: [String], from table: String, for status: CloudRecordStatus, sorted: Bool, using db: Database) throws -> [CKRecord]  {
        return DefaultValueRegistry.defaultValue(for: ([CKRecord]).self)
    }
    
     func checkinCloudRecords(_ records: [CKRecord], with status: CloudRecordStatus, using db: Database) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func checkinCloudRecordIds(_ recordIds: [CKRecord.ID], with status: CloudRecordStatus, using db: Database) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func checkinCloudRecords(identifiers: [String], with status: CloudRecordStatus, using db: Database) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func removeCloudRecords(identifiers: [String], using db: Database) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func cloudRecords(with status: CloudRecordStatus, using db: Database) throws -> [CloudRecord]  {
        return DefaultValueRegistry.defaultValue(for: ([CloudRecord]).self)
    }
    
}


// MARK: - Mocks generated from file: CloudKitSynchronizer/CloudSynchronizer/Operations/CloudOperationProtocols.swift at 2019-12-24 16:29:32 +0000

//
//  CloudOperationProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 7/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Cuckoo
@testable import CloudKitSynchronizer

import CloudKit


 class MockCloudRecordPushOperationDelegate: CloudRecordPushOperationDelegate, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudRecordPushOperationDelegate
    
     typealias Stubbing = __StubbingProxy_CloudRecordPushOperationDelegate
     typealias Verification = __VerificationProxy_CloudRecordPushOperationDelegate

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudRecordPushOperationDelegate?

     func enableDefaultImplementation(_ stub: CloudRecordPushOperationDelegate) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func cloudPushOperation(_ operation: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus)  {
        
    return cuckoo_manager.call("cloudPushOperation(_: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus)",
            parameters: (operation, processedRecords, status),
            escapingParameters: (operation, processedRecords, status),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPushOperation(operation, processedRecords: processedRecords, status: status))
        
    }
    
    
    
     func cloudPushOperationDidComplete(_ operation: CloudRecordPushOperation)  {
        
    return cuckoo_manager.call("cloudPushOperationDidComplete(_: CloudRecordPushOperation)",
            parameters: (operation),
            escapingParameters: (operation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPushOperationDidComplete(operation))
        
    }
    

	 struct __StubbingProxy_CloudRecordPushOperationDelegate: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func cloudPushOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedRecords: M2, status: M3) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPushOperation, [CKRecord], CloudRecordOperationStatus)> where M1.MatchedType == CloudRecordPushOperation, M2.MatchedType == [CKRecord], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperation, [CKRecord], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedRecords) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPushOperationDelegate.self, method: "cloudPushOperation(_: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus)", parameterMatchers: matchers))
	    }
	    
	    func cloudPushOperationDidComplete<M1: Cuckoo.Matchable>(_ operation: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPushOperation)> where M1.MatchedType == CloudRecordPushOperation {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperation)>] = [wrap(matchable: operation) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPushOperationDelegate.self, method: "cloudPushOperationDidComplete(_: CloudRecordPushOperation)", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudRecordPushOperationDelegate: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func cloudPushOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedRecords: M2, status: M3) -> Cuckoo.__DoNotUse<(CloudRecordPushOperation, [CKRecord], CloudRecordOperationStatus), Void> where M1.MatchedType == CloudRecordPushOperation, M2.MatchedType == [CKRecord], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperation, [CKRecord], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedRecords) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return cuckoo_manager.verify("cloudPushOperation(_: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cloudPushOperationDidComplete<M1: Cuckoo.Matchable>(_ operation: M1) -> Cuckoo.__DoNotUse<(CloudRecordPushOperation), Void> where M1.MatchedType == CloudRecordPushOperation {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperation)>] = [wrap(matchable: operation) { $0 }]
	        return cuckoo_manager.verify("cloudPushOperationDidComplete(_: CloudRecordPushOperation)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudRecordPushOperationDelegateStub: CloudRecordPushOperationDelegate {
    

    

    
     func cloudPushOperation(_ operation: CloudRecordPushOperation, processedRecords: [CKRecord], status: CloudRecordOperationStatus)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func cloudPushOperationDidComplete(_ operation: CloudRecordPushOperation)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



 class MockCloudRecordPushOperation: CloudRecordPushOperation, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudRecordPushOperation
    
     typealias Stubbing = __StubbingProxy_CloudRecordPushOperation
     typealias Verification = __VerificationProxy_CloudRecordPushOperation

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudRecordPushOperation?

     func enableDefaultImplementation(_ stub: CloudRecordPushOperation) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var delegate: CloudRecordPushOperationDelegate? {
        get {
            return cuckoo_manager.getter("delegate",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate)
        }
        
        set {
            cuckoo_manager.setter("delegate",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate = newValue)
        }
        
    }
    
    
    
     var updates: [CKRecord] {
        get {
            return cuckoo_manager.getter("updates",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.updates)
        }
        
        set {
            cuckoo_manager.setter("updates",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.updates = newValue)
        }
        
    }
    
    
    
     var deleteIds: [CKRecord.ID] {
        get {
            return cuckoo_manager.getter("deleteIds",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.deleteIds)
        }
        
        set {
            cuckoo_manager.setter("deleteIds",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.deleteIds = newValue)
        }
        
    }
    
    
    
     var completionBlock: (() -> Void)? {
        get {
            return cuckoo_manager.getter("completionBlock",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock)
        }
        
        set {
            cuckoo_manager.setter("completionBlock",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock = newValue)
        }
        
    }
    

    

    
    
    
     func start()  {
        
    return cuckoo_manager.call("start()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.start())
        
    }
    

	 struct __StubbingProxy_CloudRecordPushOperation: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var delegate: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPushOperation, CloudRecordPushOperationDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate")
	    }
	    
	    
	    var updates: Cuckoo.ProtocolToBeStubbedProperty<MockCloudRecordPushOperation, [CKRecord]> {
	        return .init(manager: cuckoo_manager, name: "updates")
	    }
	    
	    
	    var deleteIds: Cuckoo.ProtocolToBeStubbedProperty<MockCloudRecordPushOperation, [CKRecord.ID]> {
	        return .init(manager: cuckoo_manager, name: "deleteIds")
	    }
	    
	    
	    var completionBlock: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPushOperation, (() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock")
	    }
	    
	    
	    func start() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPushOperation.self, method: "start()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudRecordPushOperation: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var delegate: Cuckoo.VerifyOptionalProperty<CloudRecordPushOperationDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var updates: Cuckoo.VerifyProperty<[CKRecord]> {
	        return .init(manager: cuckoo_manager, name: "updates", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var deleteIds: Cuckoo.VerifyProperty<[CKRecord.ID]> {
	        return .init(manager: cuckoo_manager, name: "deleteIds", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var completionBlock: Cuckoo.VerifyOptionalProperty<(() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func start() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("start()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudRecordPushOperationStub: CloudRecordPushOperation {
    
    
     var delegate: CloudRecordPushOperationDelegate? {
        get {
            return DefaultValueRegistry.defaultValue(for: (CloudRecordPushOperationDelegate?).self)
        }
        
        set { }
        
    }
    
    
     var updates: [CKRecord] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([CKRecord]).self)
        }
        
        set { }
        
    }
    
    
     var deleteIds: [CKRecord.ID] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([CKRecord.ID]).self)
        }
        
        set { }
        
    }
    
    
     var completionBlock: (() -> Void)? {
        get {
            return DefaultValueRegistry.defaultValue(for: ((() -> Void)?).self)
        }
        
        set { }
        
    }
    

    

    
     func start()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



 class MockCloudRecordPullOperationDelegate: CloudRecordPullOperationDelegate, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudRecordPullOperationDelegate
    
     typealias Stubbing = __StubbingProxy_CloudRecordPullOperationDelegate
     typealias Verification = __VerificationProxy_CloudRecordPullOperationDelegate

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudRecordPullOperationDelegate?

     func enableDefaultImplementation(_ stub: CloudRecordPullOperationDelegate) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus)  {
        
    return cuckoo_manager.call("cloudPullOperation(_: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus)",
            parameters: (operation, processedUpdatedRecords, status),
            escapingParameters: (operation, processedUpdatedRecords, status),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPullOperation(operation, processedUpdatedRecords: processedUpdatedRecords, status: status))
        
    }
    
    
    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus)  {
        
    return cuckoo_manager.call("cloudPullOperation(_: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus)",
            parameters: (operation, processedDeletedRecordIds, status),
            escapingParameters: (operation, processedDeletedRecordIds, status),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPullOperation(operation, processedDeletedRecordIds: processedDeletedRecordIds, status: status))
        
    }
    
    
    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?)  {
        
    return cuckoo_manager.call("cloudPullOperation(_: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?)",
            parameters: (operation, pulledNewChangeTag),
            escapingParameters: (operation, pulledNewChangeTag),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPullOperation(operation, pulledNewChangeTag: pulledNewChangeTag))
        
    }
    
    
    
     func cloudPullOperationDidComplete(_ operation: CloudRecordPullOperation)  {
        
    return cuckoo_manager.call("cloudPullOperationDidComplete(_: CloudRecordPullOperation)",
            parameters: (operation),
            escapingParameters: (operation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cloudPullOperationDidComplete(operation))
        
    }
    

	 struct __StubbingProxy_CloudRecordPullOperationDelegate: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedUpdatedRecords: M2, status: M3) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPullOperation, [CKRecord], CloudRecordOperationStatus)> where M1.MatchedType == CloudRecordPullOperation, M2.MatchedType == [CKRecord], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, [CKRecord], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedUpdatedRecords) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPullOperationDelegate.self, method: "cloudPullOperation(_: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus)", parameterMatchers: matchers))
	    }
	    
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedDeletedRecordIds: M2, status: M3) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPullOperation, [CKRecord.ID], CloudRecordOperationStatus)> where M1.MatchedType == CloudRecordPullOperation, M2.MatchedType == [CKRecord.ID], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, [CKRecord.ID], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedDeletedRecordIds) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPullOperationDelegate.self, method: "cloudPullOperation(_: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus)", parameterMatchers: matchers))
	    }
	    
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ operation: M1, pulledNewChangeTag: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPullOperation, CKServerChangeToken?)> where M1.MatchedType == CloudRecordPullOperation, M2.OptionalMatchedType == CKServerChangeToken {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, CKServerChangeToken?)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: pulledNewChangeTag) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPullOperationDelegate.self, method: "cloudPullOperation(_: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?)", parameterMatchers: matchers))
	    }
	    
	    func cloudPullOperationDidComplete<M1: Cuckoo.Matchable>(_ operation: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(CloudRecordPullOperation)> where M1.MatchedType == CloudRecordPullOperation {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation)>] = [wrap(matchable: operation) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPullOperationDelegate.self, method: "cloudPullOperationDidComplete(_: CloudRecordPullOperation)", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudRecordPullOperationDelegate: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedUpdatedRecords: M2, status: M3) -> Cuckoo.__DoNotUse<(CloudRecordPullOperation, [CKRecord], CloudRecordOperationStatus), Void> where M1.MatchedType == CloudRecordPullOperation, M2.MatchedType == [CKRecord], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, [CKRecord], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedUpdatedRecords) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return cuckoo_manager.verify("cloudPullOperation(_: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(_ operation: M1, processedDeletedRecordIds: M2, status: M3) -> Cuckoo.__DoNotUse<(CloudRecordPullOperation, [CKRecord.ID], CloudRecordOperationStatus), Void> where M1.MatchedType == CloudRecordPullOperation, M2.MatchedType == [CKRecord.ID], M3.MatchedType == CloudRecordOperationStatus {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, [CKRecord.ID], CloudRecordOperationStatus)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: processedDeletedRecordIds) { $0.1 }, wrap(matchable: status) { $0.2 }]
	        return cuckoo_manager.verify("cloudPullOperation(_: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cloudPullOperation<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ operation: M1, pulledNewChangeTag: M2) -> Cuckoo.__DoNotUse<(CloudRecordPullOperation, CKServerChangeToken?), Void> where M1.MatchedType == CloudRecordPullOperation, M2.OptionalMatchedType == CKServerChangeToken {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation, CKServerChangeToken?)>] = [wrap(matchable: operation) { $0.0 }, wrap(matchable: pulledNewChangeTag) { $0.1 }]
	        return cuckoo_manager.verify("cloudPullOperation(_: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cloudPullOperationDidComplete<M1: Cuckoo.Matchable>(_ operation: M1) -> Cuckoo.__DoNotUse<(CloudRecordPullOperation), Void> where M1.MatchedType == CloudRecordPullOperation {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperation)>] = [wrap(matchable: operation) { $0 }]
	        return cuckoo_manager.verify("cloudPullOperationDidComplete(_: CloudRecordPullOperation)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudRecordPullOperationDelegateStub: CloudRecordPullOperationDelegate {
    

    

    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, processedUpdatedRecords: [CKRecord], status: CloudRecordOperationStatus)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, processedDeletedRecordIds: [CKRecord.ID], status: CloudRecordOperationStatus)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func cloudPullOperation(_ operation: CloudRecordPullOperation, pulledNewChangeTag: CKServerChangeToken?)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func cloudPullOperationDidComplete(_ operation: CloudRecordPullOperation)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



 class MockCloudRecordPullOperation: CloudRecordPullOperation, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudRecordPullOperation
    
     typealias Stubbing = __StubbingProxy_CloudRecordPullOperation
     typealias Verification = __VerificationProxy_CloudRecordPullOperation

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudRecordPullOperation?

     func enableDefaultImplementation(_ stub: CloudRecordPullOperation) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var zoneId: CKRecordZone.ID? {
        get {
            return cuckoo_manager.getter("zoneId",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.zoneId)
        }
        
        set {
            cuckoo_manager.setter("zoneId",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.zoneId = newValue)
        }
        
    }
    
    
    
     var previousServerChangeToken: CKServerChangeToken? {
        get {
            return cuckoo_manager.getter("previousServerChangeToken",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.previousServerChangeToken)
        }
        
        set {
            cuckoo_manager.setter("previousServerChangeToken",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.previousServerChangeToken = newValue)
        }
        
    }
    
    
    
     var delegate: CloudRecordPullOperationDelegate? {
        get {
            return cuckoo_manager.getter("delegate",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate)
        }
        
        set {
            cuckoo_manager.setter("delegate",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate = newValue)
        }
        
    }
    
    
    
     var completionBlock: (() -> Void)? {
        get {
            return cuckoo_manager.getter("completionBlock",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock)
        }
        
        set {
            cuckoo_manager.setter("completionBlock",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock = newValue)
        }
        
    }
    

    

    
    
    
     func start()  {
        
    return cuckoo_manager.call("start()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.start())
        
    }
    

	 struct __StubbingProxy_CloudRecordPullOperation: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var zoneId: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPullOperation, CKRecordZone.ID> {
	        return .init(manager: cuckoo_manager, name: "zoneId")
	    }
	    
	    
	    var previousServerChangeToken: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPullOperation, CKServerChangeToken> {
	        return .init(manager: cuckoo_manager, name: "previousServerChangeToken")
	    }
	    
	    
	    var delegate: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPullOperation, CloudRecordPullOperationDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate")
	    }
	    
	    
	    var completionBlock: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudRecordPullOperation, (() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock")
	    }
	    
	    
	    func start() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudRecordPullOperation.self, method: "start()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudRecordPullOperation: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var zoneId: Cuckoo.VerifyOptionalProperty<CKRecordZone.ID> {
	        return .init(manager: cuckoo_manager, name: "zoneId", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var previousServerChangeToken: Cuckoo.VerifyOptionalProperty<CKServerChangeToken> {
	        return .init(manager: cuckoo_manager, name: "previousServerChangeToken", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var delegate: Cuckoo.VerifyOptionalProperty<CloudRecordPullOperationDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var completionBlock: Cuckoo.VerifyOptionalProperty<(() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func start() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("start()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudRecordPullOperationStub: CloudRecordPullOperation {
    
    
     var zoneId: CKRecordZone.ID? {
        get {
            return DefaultValueRegistry.defaultValue(for: (CKRecordZone.ID?).self)
        }
        
        set { }
        
    }
    
    
     var previousServerChangeToken: CKServerChangeToken? {
        get {
            return DefaultValueRegistry.defaultValue(for: (CKServerChangeToken?).self)
        }
        
        set { }
        
    }
    
    
     var delegate: CloudRecordPullOperationDelegate? {
        get {
            return DefaultValueRegistry.defaultValue(for: (CloudRecordPullOperationDelegate?).self)
        }
        
        set { }
        
    }
    
    
     var completionBlock: (() -> Void)? {
        get {
            return DefaultValueRegistry.defaultValue(for: ((() -> Void)?).self)
        }
        
        set { }
        
    }
    

    

    
     func start()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



 class MockCloudZoneAvailablityOperation: CloudZoneAvailablityOperation, Cuckoo.ProtocolMock {
    
     typealias MocksType = CloudZoneAvailablityOperation
    
     typealias Stubbing = __StubbingProxy_CloudZoneAvailablityOperation
     typealias Verification = __VerificationProxy_CloudZoneAvailablityOperation

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CloudZoneAvailablityOperation?

     func enableDefaultImplementation(_ stub: CloudZoneAvailablityOperation) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var zoneIds: [CKRecordZone.ID] {
        get {
            return cuckoo_manager.getter("zoneIds",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.zoneIds)
        }
        
        set {
            cuckoo_manager.setter("zoneIds",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.zoneIds = newValue)
        }
        
    }
    
    
    
     var completionBlock: (() -> Void)? {
        get {
            return cuckoo_manager.getter("completionBlock",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock)
        }
        
        set {
            cuckoo_manager.setter("completionBlock",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock = newValue)
        }
        
    }
    

    

    
    
    
     func start()  {
        
    return cuckoo_manager.call("start()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.start())
        
    }
    

	 struct __StubbingProxy_CloudZoneAvailablityOperation: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var zoneIds: Cuckoo.ProtocolToBeStubbedProperty<MockCloudZoneAvailablityOperation, [CKRecordZone.ID]> {
	        return .init(manager: cuckoo_manager, name: "zoneIds")
	    }
	    
	    
	    var completionBlock: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockCloudZoneAvailablityOperation, (() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock")
	    }
	    
	    
	    func start() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudZoneAvailablityOperation.self, method: "start()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudZoneAvailablityOperation: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var zoneIds: Cuckoo.VerifyProperty<[CKRecordZone.ID]> {
	        return .init(manager: cuckoo_manager, name: "zoneIds", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var completionBlock: Cuckoo.VerifyOptionalProperty<(() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func start() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("start()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudZoneAvailablityOperationStub: CloudZoneAvailablityOperation {
    
    
     var zoneIds: [CKRecordZone.ID] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([CKRecordZone.ID]).self)
        }
        
        set { }
        
    }
    
    
     var completionBlock: (() -> Void)? {
        get {
            return DefaultValueRegistry.defaultValue(for: ((() -> Void)?).self)
        }
        
        set { }
        
    }
    

    

    
     func start()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



 class MockCloudKitOperationProducer: CloudKitOperationProducer, Cuckoo.ClassMock {
    
     typealias MocksType = CloudKitOperationProducer
    
     typealias Stubbing = __StubbingProxy_CloudKitOperationProducer
     typealias Verification = __VerificationProxy_CloudKitOperationProducer

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: CloudKitOperationProducer?

     func enableDefaultImplementation(_ stub: CloudKitOperationProducer) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     override func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation {
        
    return cuckoo_manager.call("newZoneAvailablityOperation() -> CloudZoneAvailablityOperation",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.newZoneAvailablityOperation()
                ,
            defaultCall: __defaultImplStub!.newZoneAvailablityOperation())
        
    }
    
    
    
     override func newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation {
        
    return cuckoo_manager.call("newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation",
            parameters: (delegate),
            escapingParameters: (delegate),
            superclassCall:
                
                super.newPullOperation(delegate: delegate)
                ,
            defaultCall: __defaultImplStub!.newPullOperation(delegate: delegate))
        
    }
    
    
    
     override func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation {
        
    return cuckoo_manager.call("newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation",
            parameters: (delegate),
            escapingParameters: (delegate),
            superclassCall:
                
                super.newPushOperation(delegate: delegate)
                ,
            defaultCall: __defaultImplStub!.newPushOperation(delegate: delegate))
        
    }
    

	 struct __StubbingProxy_CloudKitOperationProducer: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func newZoneAvailablityOperation() -> Cuckoo.ClassStubFunction<(), CloudZoneAvailablityOperation> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudKitOperationProducer.self, method: "newZoneAvailablityOperation() -> CloudZoneAvailablityOperation", parameterMatchers: matchers))
	    }
	    
	    func newPullOperation<M1: Cuckoo.Matchable>(delegate: M1) -> Cuckoo.ClassStubFunction<(CloudRecordPullOperationDelegate), CloudRecordPullOperation> where M1.MatchedType == CloudRecordPullOperationDelegate {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperationDelegate)>] = [wrap(matchable: delegate) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudKitOperationProducer.self, method: "newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation", parameterMatchers: matchers))
	    }
	    
	    func newPushOperation<M1: Cuckoo.Matchable>(delegate: M1) -> Cuckoo.ClassStubFunction<(CloudRecordPushOperationDelegate), CloudRecordPushOperation> where M1.MatchedType == CloudRecordPushOperationDelegate {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperationDelegate)>] = [wrap(matchable: delegate) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCloudKitOperationProducer.self, method: "newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_CloudKitOperationProducer: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func newZoneAvailablityOperation() -> Cuckoo.__DoNotUse<(), CloudZoneAvailablityOperation> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("newZoneAvailablityOperation() -> CloudZoneAvailablityOperation", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func newPullOperation<M1: Cuckoo.Matchable>(delegate: M1) -> Cuckoo.__DoNotUse<(CloudRecordPullOperationDelegate), CloudRecordPullOperation> where M1.MatchedType == CloudRecordPullOperationDelegate {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPullOperationDelegate)>] = [wrap(matchable: delegate) { $0 }]
	        return cuckoo_manager.verify("newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func newPushOperation<M1: Cuckoo.Matchable>(delegate: M1) -> Cuckoo.__DoNotUse<(CloudRecordPushOperationDelegate), CloudRecordPushOperation> where M1.MatchedType == CloudRecordPushOperationDelegate {
	        let matchers: [Cuckoo.ParameterMatcher<(CloudRecordPushOperationDelegate)>] = [wrap(matchable: delegate) { $0 }]
	        return cuckoo_manager.verify("newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class CloudKitOperationProducerStub: CloudKitOperationProducer {
    

    

    
     override func newZoneAvailablityOperation() -> CloudZoneAvailablityOperation  {
        return DefaultValueRegistry.defaultValue(for: (CloudZoneAvailablityOperation).self)
    }
    
     override func newPullOperation(delegate: CloudRecordPullOperationDelegate) -> CloudRecordPullOperation  {
        return DefaultValueRegistry.defaultValue(for: (CloudRecordPullOperation).self)
    }
    
     override func newPushOperation(delegate: CloudRecordPushOperationDelegate) -> CloudRecordPushOperation  {
        return DefaultValueRegistry.defaultValue(for: (CloudRecordPushOperation).self)
    }
    
}



 class MockOperating: Operating, Cuckoo.ProtocolMock {
    
     typealias MocksType = Operating
    
     typealias Stubbing = __StubbingProxy_Operating
     typealias Verification = __VerificationProxy_Operating

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: Operating?

     func enableDefaultImplementation(_ stub: Operating) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var completionBlock: (() -> Void)? {
        get {
            return cuckoo_manager.getter("completionBlock",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock)
        }
        
        set {
            cuckoo_manager.setter("completionBlock",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.completionBlock = newValue)
        }
        
    }
    

    

    
    
    
     func start()  {
        
    return cuckoo_manager.call("start()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.start())
        
    }
    

	 struct __StubbingProxy_Operating: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var completionBlock: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockOperating, (() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock")
	    }
	    
	    
	    func start() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockOperating.self, method: "start()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_Operating: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var completionBlock: Cuckoo.VerifyOptionalProperty<(() -> Void)> {
	        return .init(manager: cuckoo_manager, name: "completionBlock", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func start() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("start()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class OperatingStub: Operating {
    
    
     var completionBlock: (() -> Void)? {
        get {
            return DefaultValueRegistry.defaultValue(for: ((() -> Void)?).self)
        }
        
        set { }
        
    }
    

    

    
     func start()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: CloudKitSynchronizer/CloudSynchronizer/TableObserver/TableObserverProtocols.swift at 2019-12-24 16:29:32 +0000

//
//  TableObserverProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/22/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Cuckoo
@testable import CloudKitSynchronizer

import Foundation


 class MockTableObserverProducing: TableObserverProducing, Cuckoo.ProtocolMock {
    
     typealias MocksType = TableObserverProducing
    
     typealias Stubbing = __StubbingProxy_TableObserverProducing
     typealias Verification = __VerificationProxy_TableObserverProducing

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: TableObserverProducing?

     func enableDefaultImplementation(_ stub: TableObserverProducing) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func newTableObserver(_ tableName: String) -> TableObserving {
        
    return cuckoo_manager.call("newTableObserver(_: String) -> TableObserving",
            parameters: (tableName),
            escapingParameters: (tableName),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.newTableObserver(tableName))
        
    }
    

	 struct __StubbingProxy_TableObserverProducing: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func newTableObserver<M1: Cuckoo.Matchable>(_ tableName: M1) -> Cuckoo.ProtocolStubFunction<(String), TableObserving> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: tableName) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTableObserverProducing.self, method: "newTableObserver(_: String) -> TableObserving", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_TableObserverProducing: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func newTableObserver<M1: Cuckoo.Matchable>(_ tableName: M1) -> Cuckoo.__DoNotUse<(String), TableObserving> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: tableName) { $0 }]
	        return cuckoo_manager.verify("newTableObserver(_: String) -> TableObserving", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class TableObserverProducingStub: TableObserverProducing {
    

    

    
     func newTableObserver(_ tableName: String) -> TableObserving  {
        return DefaultValueRegistry.defaultValue(for: (TableObserving).self)
    }
    
}



 class MockTableObserving: TableObserving, Cuckoo.ProtocolMock {
    
     typealias MocksType = TableObserving
    
     typealias Stubbing = __StubbingProxy_TableObserving
     typealias Verification = __VerificationProxy_TableObserving

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: TableObserving?

     func enableDefaultImplementation(_ stub: TableObserving) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var tableName: String {
        get {
            return cuckoo_manager.getter("tableName",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.tableName)
        }
        
    }
    
    
    
     var columnNames: [String] {
        get {
            return cuckoo_manager.getter("columnNames",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.columnNames)
        }
        
    }
    
    
    
     var isObserving: Bool {
        get {
            return cuckoo_manager.getter("isObserving",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.isObserving)
        }
        
        set {
            cuckoo_manager.setter("isObserving",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.isObserving = newValue)
        }
        
    }
    
    
    
     var delegate: TableObserverDelegate? {
        get {
            return cuckoo_manager.getter("delegate",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate)
        }
        
        set {
            cuckoo_manager.setter("delegate",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.delegate = newValue)
        }
        
    }
    

    

    

	 struct __StubbingProxy_TableObserving: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var tableName: Cuckoo.ProtocolToBeStubbedReadOnlyProperty<MockTableObserving, String> {
	        return .init(manager: cuckoo_manager, name: "tableName")
	    }
	    
	    
	    var columnNames: Cuckoo.ProtocolToBeStubbedReadOnlyProperty<MockTableObserving, [String]> {
	        return .init(manager: cuckoo_manager, name: "columnNames")
	    }
	    
	    
	    var isObserving: Cuckoo.ProtocolToBeStubbedProperty<MockTableObserving, Bool> {
	        return .init(manager: cuckoo_manager, name: "isObserving")
	    }
	    
	    
	    var delegate: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockTableObserving, TableObserverDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate")
	    }
	    
	    
	}

	 struct __VerificationProxy_TableObserving: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var tableName: Cuckoo.VerifyReadOnlyProperty<String> {
	        return .init(manager: cuckoo_manager, name: "tableName", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var columnNames: Cuckoo.VerifyReadOnlyProperty<[String]> {
	        return .init(manager: cuckoo_manager, name: "columnNames", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var isObserving: Cuckoo.VerifyProperty<Bool> {
	        return .init(manager: cuckoo_manager, name: "isObserving", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	    
	    var delegate: Cuckoo.VerifyOptionalProperty<TableObserverDelegate> {
	        return .init(manager: cuckoo_manager, name: "delegate", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	}
}

 class TableObservingStub: TableObserving {
    
    
     var tableName: String {
        get {
            return DefaultValueRegistry.defaultValue(for: (String).self)
        }
        
    }
    
    
     var columnNames: [String] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([String]).self)
        }
        
    }
    
    
     var isObserving: Bool {
        get {
            return DefaultValueRegistry.defaultValue(for: (Bool).self)
        }
        
        set { }
        
    }
    
    
     var delegate: TableObserverDelegate? {
        get {
            return DefaultValueRegistry.defaultValue(for: (TableObserverDelegate?).self)
        }
        
        set { }
        
    }
    

    

    
}



 class MockTableObserverDelegate: TableObserverDelegate, Cuckoo.ProtocolMock {
    
     typealias MocksType = TableObserverDelegate
    
     typealias Stubbing = __StubbingProxy_TableObserverDelegate
     typealias Verification = __VerificationProxy_TableObserverDelegate

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: TableObserverDelegate?

     func enableDefaultImplementation(_ stub: TableObserverDelegate) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func tableObserver(_ observer: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow])  {
        
    return cuckoo_manager.call("tableObserver(_: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow])",
            parameters: (observer, created, updated, deleted),
            escapingParameters: (observer, created, updated, deleted),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.tableObserver(observer, created: created, updated: updated, deleted: deleted))
        
    }
    

	 struct __StubbingProxy_TableObserverDelegate: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func tableObserver<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable>(_ observer: M1, created: M2, updated: M3, deleted: M4) -> Cuckoo.ProtocolStubNoReturnFunction<(TableObserving, [TableRow], [TableRow], [TableRow])> where M1.MatchedType == TableObserving, M2.MatchedType == [TableRow], M3.MatchedType == [TableRow], M4.MatchedType == [TableRow] {
	        let matchers: [Cuckoo.ParameterMatcher<(TableObserving, [TableRow], [TableRow], [TableRow])>] = [wrap(matchable: observer) { $0.0 }, wrap(matchable: created) { $0.1 }, wrap(matchable: updated) { $0.2 }, wrap(matchable: deleted) { $0.3 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTableObserverDelegate.self, method: "tableObserver(_: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow])", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_TableObserverDelegate: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func tableObserver<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable>(_ observer: M1, created: M2, updated: M3, deleted: M4) -> Cuckoo.__DoNotUse<(TableObserving, [TableRow], [TableRow], [TableRow]), Void> where M1.MatchedType == TableObserving, M2.MatchedType == [TableRow], M3.MatchedType == [TableRow], M4.MatchedType == [TableRow] {
	        let matchers: [Cuckoo.ParameterMatcher<(TableObserving, [TableRow], [TableRow], [TableRow])>] = [wrap(matchable: observer) { $0.0 }, wrap(matchable: created) { $0.1 }, wrap(matchable: updated) { $0.2 }, wrap(matchable: deleted) { $0.3 }]
	        return cuckoo_manager.verify("tableObserver(_: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow])", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class TableObserverDelegateStub: TableObserverDelegate {
    

    

    
     func tableObserver(_ observer: TableObserving, created: [TableRow], updated: [TableRow], deleted: [TableRow])   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}

