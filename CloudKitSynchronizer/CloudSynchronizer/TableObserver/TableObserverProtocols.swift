//
//  TableObserverProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/22/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation


protocol TableObserverProducing : AnyObject {
    func newTableObserver(_ tableName: String) -> TableObserving
}

protocol TableObserving: AnyObject {
    var tableName:String { get }
    var columnNames:[String] { get }
    var isObserving: Bool { get set }
    var delegate: TableObserverDelegate? { get set }
}

extension TableObserving {
    var mapper: CloudRecordMapper {
        return CloudRecordMapper(tableName: tableName, columnNames: columnNames)
    }
}

protocol TableObserverDelegate : AnyObject {
    func tableObserver(_ observer:TableObserving, created:[TableRow], updated:[TableRow], deleted:[TableRow])
}
