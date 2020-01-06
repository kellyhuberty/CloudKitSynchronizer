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
    var cloudChangeTag:String? = nil
    var changeDate:Date? = nil
    var status: CloudRecordMutationType
    var errorType: CloudRecordErrorType?
    var errorDescription: String?

    private var _record:CKRecord? = nil
    
    var record:CKRecord?{
        get{
            
            guard let data = ckRecordData else{
                return nil
            }
            
            if let record = _record {
                return record
            }
            
            do{
                _record = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.self, from: data)
            }catch{
                NSLog("Record Decode warning: \(error)")
                _record = nil
            }
            return _record
            
        }
        set{
            ckRecordData = try? NSKeyedArchiver.archivedData(withRootObject: newValue as Any, requiringSecureCoding: true)
            _record = newValue
        }
    }
    
    var error: CloudRecordError? {
        get {
            guard let errorDescription = errorDescription else{
                return nil
            }
            
            return CloudRecordError(description: errorDescription, status: errorType)
        }
        set {
            errorType = newValue?.status
            errorDescription = newValue?.description
        }
    }
    
}
