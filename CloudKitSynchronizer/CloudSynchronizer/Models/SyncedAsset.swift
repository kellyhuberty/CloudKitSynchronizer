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
                
        File.makeDirectoryIfUnavailable(directory)
        
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
    
    private func exists() -> Bool {
        return FileManager.default.fileExists(atPath: currentURL.path)
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
    
    var data: Data? {
        get {
            var data: Data? = nil
            syncedRead { imagePath in
                do {
                    if !exists() {
                        data = nil
                    }
                    else {
                        data = try Data(contentsOf: currentURL, options: [])
                    }
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
                    if exists() {
                        try FileManager.default.removeItem(at: currentURL)
                    }
                    
                    guard let data = newValue, data.count > 0 else {
                        return
                    }
                                        
                    try data.write(to: currentURL, options: [])
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

class File {
    static func makeDirectoryIfUnavailable(_ directory: URL, recursive: Bool = true) {
        if !FileManager.default.fileExists(atPath: directory.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: directory,
                                                        withIntermediateDirectories: recursive,
                                                        attributes: nil)
            }
            catch {
                print(error)
            }
        }
    }
}

public extension SyncedAsset {
    
    func testing(_ assetURL: URL) -> SyncedAsset<EnclosingType> {
        
        let testingConfiguration = AssetConfiguration(column: configuration.column,
                                                      directory: assetURL)
        
        return SyncedAsset<EnclosingType>(enclosingObject, configuration: testingConfiguration)
    }
    
    
}

#if canImport(UIKit)
public extension SyncedAsset {
    var uiimage: UIImage? {
        get {
            var image: UIImage?
            syncedRead { imagePath in
                print(imagePath)
                if !exists() {
                    image = nil
                }
                else {
                    image = UIImage(contentsOfFile: imagePath.path)
                }
            }
            return image
        }
        set {
            data = newValue?.jpegData(compressionQuality: 2)
        }
    }
}
#endif

#if canImport(AppKit) && os(macOS)
public extension SyncedAsset {
    var nsimage: NSImage? {
        get {
            var image: NSImage?
            syncedRead { imagePath in
                print(imagePath)
                if !exists() {
                    image = nil
                }
                else {
                    image = NSImage(contentsOfFile: imagePath.path)
                }
            }
            return image
        }
        set {
            guard let image = image else {
                data = nil
                return
            }
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            data = jpegData
        }
    }
}
#endif
