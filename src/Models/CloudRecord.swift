//
//  CloudRecord.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/25/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import GRDB
import CloudKit


/// Represents a row in the cloud record table, complete with being able to serialize and
/// deserialize a cloud record.
class CloudRecord : Model, Codable{
    
    static var databaseTableName: String {
        return TableNames.CloudRecords
    }
    
    struct Identifier{
        let identifier:String
        let tableName:String
    }
    
    enum CodingKeys : CodingKey {
        case identifier
        case tableName
        case ckRecordData
        case cloudChangeTag
        case changeDate
        case status
        case errorType
        case errorDescription
    }
    
    init(identifier:String, tableName:String, status: CloudRecordMutationType, error: CloudRecordError? = nil) {
        self.identifier = identifier
        self.tableName = tableName
        self.status = status
        self.error = error
    }
    
    let identifier:String
    let tableName:String
    var ckRecordData:Data? = nil
    var conflictedCkRecordData:Data? = nil
    var cloudChangeTag:String? = nil
    var changeDate:Date? = nil
    var status: CloudRecordMutationType
    var errorType: CloudRecordErrorType?
    var errorDescription: String?

    //Cached data
    private var _record:CKRecord? = nil
    private var _conflictedServerRecord:CKRecord? = nil
    
    var record:CKRecord?{
        get{
            if let record = _record {
                return record
            }
            _record = CloudRecord.ckRecord(from: ckRecordData)
            return _record
        }
        set{
            ckRecordData = CloudRecord.data(from: newValue)
            _conflictedServerRecord = newValue
        }
    }
    
    var conflictedServerRecord:CKRecord?{
        get{
            if let record = _conflictedServerRecord {
                return record
            }
            _conflictedServerRecord = CloudRecord.ckRecord(from: conflictedCkRecordData)
            return _conflictedServerRecord
        }
        set{
            conflictedCkRecordData = CloudRecord.data(from: newValue)
            _conflictedServerRecord = newValue
        }
    }
    
    var error: CloudRecordError? {
        get {
            guard let errorDescription = errorDescription else{
                return nil
            }
            
            return CloudRecordError(description: errorDescription, status: errorType, serverRecord: self.conflictedServerRecord)
        }
        set {
            errorType = newValue?.status
            errorDescription = newValue?.description
        }
    }
    
    static func ckRecord(from data:Data?) -> CKRecord? {
        
        guard let data = data else{
            return nil
        }
        
        let record: CKRecord?
        
        do{
            record = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.self, from: data)
        }catch{
            NSLog("Record Decode warning: \(error)")
            record = nil
        }
        return record
        
    }
 
    static func data(from ckRecord:CKRecord?) -> Data? {
        
        guard let ckRecord = ckRecord else {
            return nil
        }
        
        let ckRecordData = try? NSKeyedArchiver.archivedData(withRootObject: ckRecord as Any, requiringSecureCoding: true)
        return ckRecordData
        
    }
    
}
