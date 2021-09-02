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
    func map(record:CKRecord) -> [String:DatabaseValue?]
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
        
        let rows = records.map { (record) -> [String:DatabaseValueConvertible?] in
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
        
        let rows = records.map { (record) -> [String:DatabaseValueConvertible?] in
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

        for (key, value) in data{
            guard let value = value else{
                record.setValue(nil, forKey: key)
                continue
            }
            
            if let transform = transforms[key] {
                if let transformedValue = transform.transformToRemote(value, to: record) {
                    record.setValue(transformedValue, forKey: key)
                }
                else {
                    record.setValue(nil, forKey: key)
                }
                continue
            }
            
            switch value.storage {
            case .blob(let data):
                record.setValue(data, forKey: key)
            case .double(let double):
                record.setValue(double, forKey: key)
            case .int64(let integer):
                record.setValue(integer, forKey: key)
            case .string(let string):
                record.setValue(string, forKey: key)
            case .null:
                record.setValue(nil, forKey: key)
            }
            
        }

        return record
    }
    
    func map(record:CKRecord) -> [String:DatabaseValue?]{
        
        var allValues = [String:DatabaseValue?]()
        
        for key in record.allKeys() {

            guard let value = record[key] else{
                allValues[key] = nil
                continue
            }
            
            if let transform = transforms[key] {
                if let transformedValue = transform.transformToLocal(value, from: record) {
                    allValues[key] = DatabaseValue(value: transformedValue)
                }
                else {
                    allValues[key] = nil
                }
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
        
        return allValues
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
