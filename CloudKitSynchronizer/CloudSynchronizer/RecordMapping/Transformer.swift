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
    func transformToRemoteDidFinish(_ inValue: CKRecordValue?, on record: CKRecord)
}

class AssetTransformer {
    
    let tableName: String
    let assetConfig: AssetConfigurable
    let processor: AssetProcessing
    
    static let fileAttributeKey = "com.kellyhuberty.CloudKitSynchronizer.AssetTransformerWriteFlag"
    
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
                try localUrl.setExtendedAttribute(data: Data(), forName: Self.fileAttributeKey)
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
        
        if fileManager.fileExists(atPath: localUrl.path),
            (try? localUrl.extendedAttribute(forName: Self.fileAttributeKey)) == nil {
            return CKAsset(fileURL: localUrl)
        }
        
        return nil 
    }

    func transformToRemoteDidFinish(_ inValue: CKRecordValue?, on record: CKRecord) {

        let localUrl = assetConfig.localFilePath(
            rowIdentifier: record.recordID.identifier,
                    table: tableName,
                   column: assetConfig.column
        )
        
        if fileManager.fileExists(atPath: localUrl.path) {
            try? localUrl.setExtendedAttribute(data: Data(), forName: Self.fileAttributeKey)
        }
    }
    
}


extension URL {

    /// Get extended attribute.
    func extendedAttribute(forName name: String) throws -> Data  {

        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in

            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var data = Data(count: length)

            // Retrieve attribute:
            let result =  data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }

    /// Set extended attribute.
    func setExtendedAttribute(data: Data, forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Remove extended attribute.
    func removeExtendedAttribute(forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {

        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var namebuf = Array<CChar>(repeating: 0, count: length)

            // Retrieve attribute list:
            let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
            guard result >= 0 else { throw URL.posixError(errno) }

            // Extract attribute names:
            let list = namebuf.split(separator: 0).compactMap {
                $0.withUnsafeBufferPointer {
                    $0.withMemoryRebound(to: UInt8.self) {
                        String(bytes: $0, encoding: .utf8)
                    }
                }
            }
            return list
        }
        return list
    }

    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
