//
//  AssetProcessor.swift
//  AssetProcessor
//
//  Created by Kelly Huberty on 8/26/21.
//

import CloudKit
import GRDB

public protocol AssetProcessing {
//    func register(_ object: AnyObject, for assetId: String, changeBlock: @escaping () -> Void)
//    func unregister(_ object: AnyObject, for assetId: String)
//    func unregisterAll(for object: AnyObject)
//    func notifyChange(for assetId: String)
    func notifyChange(for assetId: String?) 
    func register(_ asset: AssetSyncing)
    func unregister(_ asset: AssetSyncing)

}

public protocol AssetSyncing: AnyObject {
    var assetId: String? { get }
    func assetDidChange()
}

class AssetProcessor {
    
    static private(set) var shared: AssetProcessor = {
        AssetProcessor()
    }()
    
    private let center = NotificationCenter.default
    
    private func register(_ object: AnyObject, for assetId: String, changeBlock: @escaping () -> Void) {
        let name = name(for: assetId)
        center.addObserver(forName: name, object: object, queue: OperationQueue.main) { notification in
            changeBlock()
        }
    }
    
    private func unregister(_ object: AnyObject, for assetId: String) {
        let name = name(for: assetId)
        center.removeObserver(object, name: name, object: nil)
    }
    
    private func unregisterAll(for object: AnyObject) {
        center.removeObserver(object)
    }
    
    func notifyChange(for assetId: String?) {
        guard let assetId = assetId else { return }

        let name = name(for: assetId)
        center.post(name: name, object: nil, userInfo: nil)
    }
    
    private func name(for assetId: String) -> Notification.Name {
        let name = "SyncedAssetChange_" + assetId
        return Notification.Name(rawValue: name)
    }
}

extension AssetProcessor: AssetProcessing {
    func register(_ asset: AssetSyncing) {
        guard let assetId = asset.assetId else { return }
        
        register(asset, for: assetId) {
            asset.assetDidChange()
        }
    }

    func unregister(_ asset: AssetSyncing) {
        guard let assetId = asset.assetId else { return }
        unregister(asset, for: assetId)
    }
}

extension URL {
    var assetId: String? {
        self.pathComponents.last
    }
}
