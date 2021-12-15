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
    
    func transformToLocal(_ inValue: CKRecordValue?, from record: CKRecord) -> DatabaseValueConvertible?
    func transformToRemote(_ inValue: DatabaseValueConvertible?, to record: CKRecord) -> CKRecordValue?
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
    
    fileprivate func moveOrReplace(fileAt newUrl: URL, with currentUrl: URL) throws {
        let newDirectory = newUrl.deletingLastPathComponent()
        
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = fileManager.fileExists(atPath: newDirectory.path, isDirectory: &isDirectory)
        
        
        if !exists {
            try fileManager.createDirectory(atPath: newDirectory.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }
        
        if !fileManager.fileExists(atPath: newUrl.path) {
            try fileManager.moveItem(atPath: currentUrl.path, toPath: newUrl.path)
            print("Moving item \(currentUrl) to path \(newUrl)")
        }
        else {
            _ = try fileManager.replaceItemAt(newUrl, withItemAt: currentUrl, backupItemName: "BAK", options: FileManager.ItemReplacementOptions.usingNewMetadataOnly)
            print("Replacing item at \(newUrl) with item \(newUrl)")
        }
    }
    
    fileprivate func copyOrReplace(fileAt newUrl: URL, with currentUrl: URL) throws {
        let newDirectory = newUrl.deletingLastPathComponent()
        
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = fileManager.fileExists(atPath: newDirectory.path, isDirectory: &isDirectory)
        
        
        if !exists {
            try fileManager.createDirectory(atPath: newDirectory.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        }
        
        if !fileManager.fileExists(atPath: newUrl.path) {
            try fileManager.copyItem(atPath: currentUrl.path, toPath: newUrl.path)
            print("Copying item \(currentUrl) to path \(newUrl)")
        }
        else {
            _ = try fileManager.replaceItemAt(newUrl, withItemAt: currentUrl, backupItemName: nil, options: FileManager.ItemReplacementOptions.usingNewMetadataOnly)
            print("Replacing item at \(newUrl) with item \(newUrl)")
        }

    }
    
    fileprivate func remove(at url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
}

extension AssetTransformer: Transformer {
    
    func transformToLocal(_ inValue: CKRecordValue?, from record: CKRecord) -> DatabaseValueConvertible? {
    
        let localUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        do {
            if let asset = inValue as? CKAsset,
                let tempUrl = asset.fileURL{
                try moveOrReplace(fileAt: localUrl, with: tempUrl)
            }
            else if inValue == nil {
                try remove(at: localUrl)
            }
        }
        catch {
            print(error)
        }
        
        return localUrl.path
    }
    
    func transformToRemote(_ inValue: DatabaseValueConvertible?, to record: CKRecord) -> CKRecordValue? {
        
        let localUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        if fileManager.fileExists(atPath: localUrl.path) {
            return CKAsset(fileURL: localUrl)
        }
        
        return nil
    }
    
}
