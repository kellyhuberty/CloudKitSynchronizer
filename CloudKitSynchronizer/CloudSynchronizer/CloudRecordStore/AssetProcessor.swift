//
//  AssetProcessor.swift
//  AssetProcessor
//
//  Created by Kelly Huberty on 8/26/21.
//

import CloudKit
import GRDB

public protocol AssetProcessing {
    func register(_ object: AnyClass, for assetId: String, changeBlock: @escaping () -> Void)
    func unregister(_ object: AnyClass, for assetId: String)
    func unregisterAll(for object: AnyClass)
    func notifyChange(for assetId: String)
}

class AssetProcessor: AssetProcessing {
    
    static private(set) var shared: AssetProcessor = {
        AssetProcessor()
    }()
    
    let center = NotificationCenter.default
    
    func register(_ object: AnyClass, for assetId: String, changeBlock: @escaping () -> Void) {
        let name = name(for: assetId)
        center.addObserver(forName: name, object: object, queue: OperationQueue.main) { notification in
            changeBlock()
        }
    }
    
    func unregister(_ object: AnyClass, for assetId: String) {
        let name = name(for: assetId)
        center.removeObserver(object, name: name, object: nil)
    }
    
    func unregisterAll(for object: AnyClass) {
        center.removeObserver(object)
    }
    
    func notifyChange(for assetId: String) {
        let name = name(for: assetId)
        center.post(name: name, object: nil, userInfo: nil)
    }
    
    private func name(for assetId: String) -> Notification.Name {
        let name = "SyncedAssetChange_" + assetId
        return Notification.Name(rawValue: name)
    }
}

extension URL {
    var assetId: String? {
        self.pathComponents.last
    }
}
