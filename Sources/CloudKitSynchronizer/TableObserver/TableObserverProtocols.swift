//
//  TableObserverProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/22/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation


protocol TableObserverProducing : AnyObject {
    func newTableObserver(_ tableConfiguration: TableConfigurable) -> TableObserving
}

protocol TableObserving: AnyObject {
    var tableConfiguration: TableConfigurable { get }
    var columnNames:[String] { get }
    var isObserving: Bool { get set }
    var delegate: TableObserverDelegate? { get set }
}

extension TableObserving {
    var tableName:String {
        return tableConfiguration.tableName
    }
}

protocol TableObserverDelegate : AnyObject {
    func tableObserver(_ observer:TableObserving, created:[TableRow], updated:[TableRow], deleted:[TableRow.Identifier])
}
