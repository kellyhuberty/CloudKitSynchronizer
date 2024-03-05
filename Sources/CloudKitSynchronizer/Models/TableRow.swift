//
//  TableRow.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/25/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB


class TableRow : FetchableRecord {
    
    typealias RawIdentifier = Int64

    
    typealias Identifier = String
    
    let dict:[String: DatabaseValue?]
        
    required init(row: Row){
        dict = Dictionary(row, uniquingKeysWith: { (left, _) in left })
    }
    
    var identifier: Identifier {
        
        guard let recordId = dict["identifier"] else{
            fatalError()
        }
        guard let stringValue = String.fromDatabaseValue(recordId!) else{
            fatalError()
        }
        return stringValue
    }
    
    
}

extension TableRow: Hashable{
    
    static func == (lhs: TableRow, rhs: TableRow) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
