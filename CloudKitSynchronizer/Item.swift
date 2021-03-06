//
//  Item.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation


struct Item : Model, Hashable, Codable {
    
    init() {
        identifier = UUID().uuidString
    }
    
    var identifier:String
    var text:String?
    var nextIdentifier:String?
    
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
