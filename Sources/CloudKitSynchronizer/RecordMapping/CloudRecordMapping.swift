//
//  CloudRecordMapping.swift
//  CloudRecordMapping
//
//  Created by Kelly Huberty on 9/1/21.
//

import Foundation
import GRDB
import CloudKit

protocol CloudRecordMapping: AnyObject {
    
    var transforms: [String: Transformer] { get }
    var sortedColumns:[String] { get }
    func map(data:[String:DatabaseValue?], to record:CKRecord) -> CKRecord
    func map(record:CKRecord) -> [String:DatabaseValue?]?
    func finishMap(record: CKRecord)
}

extension CloudRecordMapping {
    func sortedSqlColumnString() -> String {
        return "(" + sortedColumns.joined(separator: ", ") + ")"
    }
    
    func sortedSqlValues(_ sqlValues:[String:DatabaseValueConvertible?]) -> [DatabaseValueConvertible?] {
        
        return sortedColumns.map { (key) -> DatabaseValueConvertible? in
            return sqlValues[key] ?? nil
        }
        
    }
    
    func sqlValues(forRecords records:[CKRecord]) -> [DatabaseValueConvertible?] {
        
        let rows = records.compactMap { (record) -> [String:DatabaseValueConvertible?]? in
            return map(record: record)
        }
        
        return sqlValues(forRows: rows)
    }
    
    func sqlValues(forRows dictionaries:[[String:DatabaseValueConvertible?]]) -> [DatabaseValueConvertible?]{
        
        var valuesArray = [DatabaseValueConvertible?]()
        
        for dictionary in dictionaries {
            
            let sortedValues = sortedSqlValues(dictionary)
            valuesArray.append(contentsOf: sortedValues)
            
        }
        return valuesArray
    }
    
    func sqlValuesString(forRecords records:[CKRecord]) -> String {
        
        let rows = records.compactMap { (record) -> [String:DatabaseValueConvertible?]? in
            return map(record: record)
        }
        
        return sqlValuesString(rows:rows)
    }
    
    private func sqlValuesString(rows:[[String:DatabaseValueConvertible?]]) -> String {
        
        let placeholderArray = sortedColumns.map { (_) -> String in
            return "?"
        }
        
        let recordPlaceholderArray = rows.map { (_) -> String in
            return "(" + placeholderArray.joined(separator: ", ") + ")"
        }
        
        return recordPlaceholderArray.joined(separator: ", ")
    }
    
}

extension CloudRecordMapper: CloudRecordMapping {
    func map(data:[String:DatabaseValue?], to record:CKRecord) -> CKRecord {

        if isRecordEmpty(data) {
            fatalError("CKRecord data \(data) is empty at map.")
        }
        
        var allKeys = Set(data.keys)
        allKeys.formUnion(transforms.keys)
        
        let newRecord: CKRecord = record.copy() as! CKRecord
        
        for (key) in allKeys {
            
            let value: DatabaseValue? = data[key] ?? nil
            
//            guard let value = data[key] else{
//                record.setValue(nil, forKey: key)
//                continue
//            }
            
            
            if let transform = transforms[key] {
                if let transformedValue = transform.transformToRemote(value, to: record) {
                    newRecord.setValue(transformedValue, forKey: key)
                }
                else {
                    newRecord.setValue(nil, forKey: key)
                }
                continue
            }
            
            guard let value = value else {
                newRecord.setValue(nil, forKey: key)
                continue
            }
            
            switch value.storage {
            case .blob(let data):
                if data == record.value(forKey: key) as? Data { continue }
                newRecord.setValue(data, forKey: key)
            case .double(let double):
                if double == record.value(forKey: key) as? Double { continue }
                newRecord.setValue(double, forKey: key)
            case .int64(let integer):
                if integer == record.value(forKey: key) as? Int64 { continue }
                newRecord.setValue(integer, forKey: key)
            case .string(let string):
                if string == record.value(forKey: key) as? String { continue }
                newRecord.setValue(string, forKey: key)
            case .null:
                if nil == record.value(forKey: key) { continue }
                newRecord.setValue(nil, forKey: key)
            }
            
        }

        return newRecord
    }
    
    func map(record:CKRecord) -> [String:DatabaseValue?]?{
        
        var allValues = [String:DatabaseValue?]()
         
        var allKeys = Set(record.allKeys())
        allKeys.formUnion(transforms.keys)
    
        for key in allKeys {

            let value = record[key]
            
            if let transform = transforms[key] {
                if let transformedValue = transform.transformToLocal(value, from: record) {
                    allValues[key] = DatabaseValue(value: transformedValue)
                }
                else {
                    allValues[key] = nil
                }
                continue
            }
            
            guard let value = value else{
                allValues[key] = nil
                continue
            }
            
            switch value {
            case let value as Data:
                allValues[key] = DatabaseValue(value: value)
            case let value as Double:
                allValues[key] = DatabaseValue(value: value)
            case let value as Int:
                allValues[key] = DatabaseValue(value: value)
            case let value as String:
                allValues[key] = DatabaseValue(value: value)
            default:
                fatalError("Unsupported CKRecord Type")
            }
            
        }
        
        if isRecordEmpty(allValues) {
            /// We need FlightRecorder here.
            print("CKRecord \(record.recordID) is empty at map.")
            return nil
        }
        
        return allValues
    }
    
    func finishMap(record: CKRecord) {
                 
        var allKeys = Set(record.allKeys())
        allKeys.formUnion(transforms.keys)
    
        for key in allKeys {

            let value = record[key]
            
            if let transform = transforms[key] {
                transform.transformToRemoteDidFinish(value, on: record)
            }
        }
    }
    
    func isRecordEmpty(_ data: [String:DatabaseValue?]) -> Bool {
        let valuesCopy = data.reduce(into: [String:DatabaseValue?]()) { partialResult, keyValue in
            if keyValue.value != nil {
                partialResult[keyValue.key] = keyValue.value
            }
        }
        return valuesCopy.count == 0
    }
}

class CloudRecordMapper {
    
    let columns:[String]
    let tableName:String
    let transforms: [String : Transformer]
    
    let sortedColumns:[String]
    
    init(tableName:String, columnNames:[String], transforms: [String : Transformer]) {
        self.columns = columnNames
        self.tableName = tableName
        self.transforms = transforms

        var newColumns = columns
        newColumns.sort()
        if let index = newColumns.firstIndex(of: "identifier") {
            newColumns.remove(at: index)
            newColumns.insert("identifier", at: 0)
        }
        sortedColumns = newColumns
    }
    
}
