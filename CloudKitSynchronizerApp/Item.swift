//
//  Item.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKitSynchronizer

struct Item : IdentifiableModel, Codable {
    
    enum AssetConfigs {
        static let imagePath = AssetConfiguration(column: "image",
                                                  directory: Repo.assetURL)
    }
    
    init() {
        identifier = UUID().uuidString
    }
    
    var identifier: String
    var text:String?
    var nextIdentifier:String?
    var imagePath: String? //SyncedAsset = SyncedAsset()

    lazy var imageAsset: SyncedAsset = {
        SyncedAsset(self, configuration: AssetConfigs.imagePath)
    }()
}

extension Item: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Item: Equatable {
    
}
