//
//  Transformer.swift
//  Transformer
//
//  Created by Kelly Huberty on 9/1/21.
//

import Foundation
import GRDB
import CloudKit
import AppKit

protocol Transformer {
    
    func transformToLocal(_ inValue: CKRecordValue, from record: CKRecord) -> DatabaseValueConvertible?
    func transformToRemote(_ inValue: DatabaseValueConvertible, to record: CKRecord) -> CKRecordValue?
}

class AssetTransformer {
    
    let tableName: String
    let assetConfig: AssetConfigurable
    let processor: AssetProcessing
    
    private let fileManager = FileManager.default
    
    init(table: String, assetConfig: AssetConfigurable, processor: AssetProcessing){
        self.tableName = table
        self.assetConfig = assetConfig
        self.processor = processor
    }
}

extension AssetTransformer: Transformer {

    func transformToLocal(_ inValue: CKRecordValue, from record: CKRecord) -> DatabaseValueConvertible? {
        guard let asset = inValue as? CKAsset else { return nil }
        guard let tempUrl = asset.fileURL else { return nil }
        guard fileManager.fileExists(atPath: tempUrl.absoluteString) else { return nil }
    
        let permUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        let permDirectory = permUrl.deletingLastPathComponent()
                
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = fileManager.fileExists(atPath: permDirectory.absoluteString, isDirectory: &isDirectory)
        
        
        if exists && !isDirectory.boolValue {
            try? fileManager.createDirectory(at: permDirectory.absoluteURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        _ = try? fileManager.replaceItemAt(permUrl, withItemAt: tempUrl, backupItemName: "BAK", options: FileManager.ItemReplacementOptions.usingNewMetadataOnly)
        
        return permUrl.absoluteString
    }
    
    func transformToRemote(_ inValue: DatabaseValueConvertible, to record: CKRecord) -> CKRecordValue? {
        
        guard let filePath = inValue as? String else { return nil }
        let fileUrl = URL(fileURLWithPath: filePath)
        
        if fileManager.fileExists(atPath: fileUrl.absoluteString) {
            return CKAsset(fileURL: fileUrl)
        }
        
        return nil
    }
    
}
