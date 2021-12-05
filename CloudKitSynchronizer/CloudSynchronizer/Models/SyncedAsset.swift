//
//  SyncedAsset.swift
//  SyncedAsset
//
//  Created by Kelly Huberty on 8/23/21.
//

import Foundation

public class SyncedAsset<EnclosingType: IdentifiableModel>: Codable {
    
    private let enclosingObject: EnclosingType
    
    private let processor: AssetProcessing

    private let configuration: AssetConfigurable

    private let queue: DispatchQueue = {
        return DispatchQueue(label: "com.kellyhuberty.CloudKitSynchronizer.SyncedAssetWriteQueue")
    }()
    
    public var changed: (()->Void)? = nil {
        didSet {
            queue.async { [weak self] in
                guard let self = self else { return }
                self.changed?()
            }
        }
    }
        
    private var url: URL {
        return configuration.localFilePath(rowIdentifier: enclosingObject.identifier,
                                           table: EnclosingType.databaseTableName,
                                           column: configuration.column)
    }
    
    private var currentURL: URL {
        get{
            return url
        }
    }
    
    public init(_ object: EnclosingType, processor: AssetProcessing? = nil, configuration: AssetConfigurable) {

        self.processor = processor ?? AssetProcessor.shared
        self.configuration = configuration
        self.enclosingObject = object
        
        self.setup()
    }
    
    required public init(from decoder: Decoder) {
        fatalError("Must be lazy loaded")
    }
    
    public func encode(to encoder: Encoder) throws {
        print("actually used codeable")
    }
    
    var fsObject: DispatchSourceFileSystemObject?
    
    private func setup() {
        
        let directory = currentURL.deletingLastPathComponent()
                
        if !FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: directory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            }
            catch {
                print(error)
            }
        }
        
        let descriptor = open(directory.path, O_EVTONLY)
        let fileObserver = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor,
                                                                     eventMask: .write,
                                                                     queue: .main)
        
        fileObserver.setEventHandler { [weak self] in
            self?.assetDidChange()
        }
        
        fileObserver.resume()
        
        fsObject = fileObserver
    }
    
    public func write(_ block: @escaping (_ url: URL) -> Void ) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            block(self.currentURL)
        }
    }
    
    public func read(_ block: @escaping (_ url: URL) -> Void ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            block(self.currentURL)
        }
    }
    
    public func syncedWrite(_ block: (_ url: URL) -> Void ) {
        queue.sync(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            block(self.currentURL)
        }
    }
    
    public func syncedRead(_ block: (_ url: URL) -> Void ) {
        queue.sync { [weak self] in
            guard let self = self else { return }
            block(self.currentURL)
        }
    }
    
    private func generateTempPath() -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = UUID().uuidString
        let directoryURL = URL(fileURLWithPath: directory)
        let fullURL = directoryURL.appendingPathComponent(fileName)
        return fullURL
    }
}

extension SyncedAsset: AssetSyncing {
    
    public var assetId: String? {
        return url.assetId
    }
    
    public func assetDidChange() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.changed?()
        }
    }
}

extension SyncedAsset: Equatable {
    public static func == (lhs: SyncedAsset, rhs: SyncedAsset) -> Bool {
        return lhs.url == rhs.url
    }
}

extension SyncedAsset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(assetId)
    }
}

public extension SyncedAsset {
    
    var image: UIImage? {
        get {
            var image: UIImage?
            syncedRead { imagePath in
                print(imagePath)
                image = UIImage(contentsOfFile: imagePath.path)
            }
            return image
        }
        set {
            syncedWrite { imageUrl in

                let data = newValue?.jpegData(compressionQuality: 2)
                guard let data = data else { return }

                do {
                    print(imageUrl)
                    try data.write(to: imageUrl)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    var data: Data? {
        get {
            var data: Data? = nil
            syncedRead { imagePath in
                do {
                    data = try Data(contentsOf: currentURL, options: [])
                }
                catch {
                    print(error)
                }
            }
            return data
        }
        set {
            syncedWrite { imageUrl in
                do {
                    try newValue?.write(to: currentURL, options: [])
                }
                catch {
                    print(error)
                }
            }
        }
    }
}
