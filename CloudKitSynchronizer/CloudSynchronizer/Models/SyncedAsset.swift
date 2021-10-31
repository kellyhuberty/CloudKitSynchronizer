//
//  SyncedAsset.swift
//  SyncedAsset
//
//  Created by Kelly Huberty on 8/23/21.
//

import Foundation

public class SyncedAsset: Codable {
    
    private let processor: AssetProcessing
    
    private let queue: DispatchQueue = {
        return DispatchQueue(label: "com.kellyhuberty.CloudKitSynchronizer.SyncedAssetWriteQueue")
    }()
    
    private var tempURL: URL?
    
    private var permURL: URL?
    
    private var currentTempURL: URL {
        get{
            let url: URL
            if let tempURL = tempURL {
                url = tempURL
            } else {
                url = loadFileURL()
                tempURL = url
            }
            return url
        }
    }
    
    public init(processor: AssetProcessing? = nil) {
        self.tempURL = nil
        self.permURL = nil
        self.processor = processor ?? AssetProcessor.shared
    }
    
    required public init(from decoder: Decoder) {
        self.processor = AssetProcessor.shared
        do {
            let container = try decoder.singleValueContainer()

            let path = try? container.decode(String.self)
            
            if let path = path {
                permURL = URL(fileURLWithPath: path)
            }
        }
        catch let error {
            self.permURL = nil
            self.tempURL = nil
            print("Can't decode SyncedAsset \(self): \(error)")
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
    
    public func write(_ block: @escaping (_ url: URL) -> Void ) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            block(self.currentTempURL)
        }
    }
    
    public func read(_ block: @escaping (_ url: URL) -> Void ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            block(self.currentTempURL)
        }
    }
    
    public func syncedWrite(_ block: (_ url: URL) -> Void ) {
        queue.sync(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            block(self.currentTempURL)
        }
    }
    
    public func syncedRead(_ block: (_ url: URL) -> Void ) {
        queue.sync { [weak self] in
            guard let self = self else { return }
            block(self.currentTempURL)
        }
    }
    
    private func loadFileURL() -> URL {
        let newTempURL = generateTempPath()
        if let originalURL = permURL, FileManager.default.fileExists(atPath: originalURL.path) {
            try? FileManager.default.copyItem(at: originalURL, to: newTempURL)
        }
        return newTempURL
    }
    
    private func generateTempPath() -> URL {
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


