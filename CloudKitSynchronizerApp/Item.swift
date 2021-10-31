//
//  Item.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKitSynchronizer

struct Item : Model, Hashable, Codable {
    
    init() {
        identifier = UUID().uuidString
    }
    
    var identifier: String
    var text:String?
    var nextIdentifier:String?
    var imageAsset: SyncedAsset = SyncedAsset()

    var image: UIImage?{
        
        get {
            var image: UIImage?
            imageAsset.syncedRead { imagePath in
                image = UIImage(contentsOfFile: imagePath.path)
            }
            return image
        }
        set {

            let image = newValue
            
            imageAsset.syncedWrite { imageUrl in

                let data = newValue?.jpegData(compressionQuality: 2)
                
                guard let data = data else { return }
                
                do {
                    try data.write(to: imageUrl)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
}

//extension Item: Hashable {
//    static func == (lhs: Item, rhs: Item) -> Bool {
//        return lhs.identifier == rhs.identifier
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//    }
//}

//extension Item: Identifiable{
//    var id: ObjectIdentifier {
//        return identifier
//    }
//}
