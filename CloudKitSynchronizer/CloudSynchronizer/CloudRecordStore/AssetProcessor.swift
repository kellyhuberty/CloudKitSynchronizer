//
//  AssetProcessor.swift
//  AssetProcessor
//
//  Created by Kelly Huberty on 8/26/21.
//

import CloudKit
import GRDB
import UIKit
protocol AssetProcessing {
    
    var configurations: [SyncedAssetConfiguring] { get set }
    
    func processReceivedCKAssets(_ ckRecord: CKRecord) throws -> [String: DatabaseValue]
    
    func processOutgoingCKAssets(_ values: [String: DatabaseValue]) throws -> [String: CKAsset]
    
    func removeAllAssets(for identifier:String) throws
}


/*
class AssetProcessor: AssetProcessing {
    
    struct AssetKey: Hashable {
        var table: String
        var column: String
        
        var hashValue: Int { return table.hashValue }
    }
    
    var configurations: [SyncedAssetConfiguring] {
        get {
            Array(configs.values)
        }
        set {
            configs = newValue.reduce(into: [AssetKey: SyncedAssetConfiguring]()) { partialResult, config in
                partialResult[AssetKey(table: config.table, column: config.column)] = config
            }
        }
    }
    
    private var configs: [AssetKey: SyncedAssetConfiguring] = [:]

    init(){
        
    }
    
    private func configurationsFor(table: String, column: String?) -> [SyncedAssetConfiguring] {
        
        
        var filtered = configurations.filter { $0.table == table }
        
        if let column = column {
            filtered = filtered.filter { $0.column == column }
        }
        
        return filtered
    }
    
    func processReceivedCKAssets(_ ckRecord: CKRecord) throws -> [String : DatabaseValue] {
        
        
        
    }
    
    func processOutgoingCKAssets(_ values: [String : DatabaseValue]) throws -> [String : CKAsset] {
        
    }
    
    func removeAllAssets(for identifier:String) {
        
    }
    
}
*/
