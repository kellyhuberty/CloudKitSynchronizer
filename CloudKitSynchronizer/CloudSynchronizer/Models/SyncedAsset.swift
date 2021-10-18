//
//  SyncedAsset.swift
//  SyncedAsset
//
//  Created by Kelly Huberty on 8/23/21.
//

import Foundation
import UIKit

@propertyWrapper public class SyncedAsset: Codable {
    
    private var tempURL: URL?
    
    private var permURL: URL?
    
    public init() {
        tempURL = nil
        permURL = nil
    }
    
    required public init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()

            let path = try? container.decode(String.self)
            
            if let path = path {
                permURL = URL(fileURLWithPath: path)
            }
            
        }
        catch let error {
            print("Can't decode SyncedAsset \(self): \(error)")
            permURL = nil
            tempURL = nil
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        if let currentPath = tempURL?.path ?? permURL?.path {
            var container = encoder.singleValueContainer()
            do {
                try container.encode(currentPath)
            }
            catch let error {
                print("Can't encode SyncedAsset \(self): \(error)")
            }
        }
        
    }
    
    public var wrappedValue: URL? {
        get {
            if let tempURL = tempURL {
                return tempURL
            }
            tempURL = loadFileURL()
            return tempURL
        }
    }
    
    func loadFileURL() -> URL {
        let newTempURL = generateTempPath()
        
        if let originalURL = permURL, FileManager.default.fileExists(atPath: originalURL.path) {
            
            try? FileManager.default.copyItem(at: originalURL, to: newTempURL)
            
        }
        
        return newTempURL
    }
    
    func generateTempPath() -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = UUID().uuidString
        
        let directoryURL = URL(fileURLWithPath: directory)
        
        let fullURL = directoryURL.appendingPathComponent(fileName)
        
        return fullURL
    }
}

extension SyncedAsset: Equatable {
    public static func == (lhs: SyncedAsset, rhs: SyncedAsset) -> Bool {
        return lhs.permURL == rhs.permURL
    }
}

extension SyncedAsset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tempURL)
        hasher.combine(permURL)
    }
}

public struct File {
    
}
