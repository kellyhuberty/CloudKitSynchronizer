//
//  AssetProcessor.swift
//  AssetProcessor
//
//  Created by Kelly Huberty on 8/26/21.
//

import CloudKit
import GRDB
protocol AssetProcessing {
    
    func processReceivedCKAssets(_ ckRecord: CKRecord) -> [String: DatabaseValue]
    
    func processOutgoingCKAssets(_ values: [String: DatabaseValue]) -> [String: CKAsset]


}

class AssetProcessor {
    
    
    
    
    
    
}
