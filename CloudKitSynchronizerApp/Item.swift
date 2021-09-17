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
    
    var identifier:String
    var text:String?
    var nextIdentifier:String?
    var imagePath:String?

    var image: UIImage? {
        get {
            guard let imagePath = imagePath else { return nil }
            
            let image = UIImage(contentsOfFile: imagePath)
            
            return image
        }
        set {
            let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
            let data = newValue?.jpegData(compressionQuality: 2)
            do {
                try data?.write(to: tempUrl)
            }
            catch {
                print(error)
            }
            imagePath = tempUrl.path
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
