//
//  Item.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 3/21/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation


class Item : Model, Codable {
    
    init() {
        identifier = UUID().uuidString
    }
    
    var identifier:String
    var text:String?
    var nextIdentifier:String?
    
}
