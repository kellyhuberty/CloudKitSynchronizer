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
        return CloudSynchronizer.TableNames.CloudRecords
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
    }
    
    init(identifier:String, tableName:String, status: CloudRecordStatus) {
        self.identifier = identifier
        self.tableName = tableName
        self.status = status
    }
    
    let identifier:String
    let tableName:String
    var ckRecordData:Data? = nil
    var cloudChangeTag:String? = nil
    var changeDate:Date? = nil
    var status: CloudRecordStatus
    
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
}
