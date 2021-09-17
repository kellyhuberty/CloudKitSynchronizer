//
//  Transformer.swift
//  Transformer
//
//  Created by Kelly Huberty on 9/1/21.
//

import Foundation
import GRDB
import CloudKit

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

    fileprivate func moveOrReplace(fileAt permUrl: URL, with tempUrl: URL) throws {
        let permDirectory = permUrl.deletingLastPathComponent()
        
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = fileManager.fileExists(atPath: permDirectory.path, isDirectory: &isDirectory)
        
        
        if !exists {
            try fileManager.createDirectory(atPath: permDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        if !fileManager.fileExists(atPath: permUrl.path) {
            try fileManager.moveItem(atPath: tempUrl.path, toPath: permUrl.path)
        }
        else {
            _ = try fileManager.replaceItemAt(permUrl, withItemAt: tempUrl, backupItemName: "BAK", options: FileManager.ItemReplacementOptions.usingNewMetadataOnly)
        }
    }
    
    func transformToLocal(_ inValue: CKRecordValue, from record: CKRecord) -> DatabaseValueConvertible? {
        guard let asset = inValue as? CKAsset else { return nil }
        guard let tempUrl = asset.fileURL else { return nil }
        guard fileManager.fileExists(atPath: tempUrl.path) else { return nil }
    
        let permUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        do {
            try moveOrReplace(fileAt: permUrl, with: tempUrl)
        }
        catch {
            print(error)
        }
        
        return permUrl.path
    }
    
    func transformToRemote(_ inValue: DatabaseValueConvertible, to record: CKRecord) -> CKRecordValue? {
        
        guard case let .string(tempFilePath) = inValue.databaseValue.storage else { return nil }
        let tempFileUrl = URL(fileURLWithPath: tempFilePath)
        
        
        let permUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        if tempFileUrl.absoluteString.lowercased() != permUrl.absoluteString.lowercased() {
            do {
                try moveOrReplace(fileAt: permUrl, with: tempFileUrl)
            }
            catch {
                print(error)
            }
        }
        
        if fileManager.fileExists(atPath: permUrl.path) {
            let path = URL(fileURLWithPath: permUrl.path)
            return CKAsset(fileURL: path)
        }
        
        return nil
    }
    
}
