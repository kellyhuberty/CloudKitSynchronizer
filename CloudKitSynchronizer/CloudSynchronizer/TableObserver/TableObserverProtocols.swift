//
//  TableObserverProtocols.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 12/22/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation


protocol TableObserverProducing : AnyObject {
    func newTableObserver(_ tableConfiguration: SynchronizedTableProtocol) -> TableObserving
}

protocol TableObserving: AnyObject {
    var tableConfiguration: SynchronizedTableProtocol { get }
    var columnNames:[String] { get }
    var isObserving: Bool { get set }
    var delegate: TableObserverDelegate? { get set }
}

extension TableObserving {
    var mapper: CloudRecordMapper {
        return CloudRecordMapper(tableName: tableName, columnNames: columnNames)
    }
    
    var tableName:String {
        return tableConfiguration.tableName
    }
}

protocol TableObserverDelegate : AnyObject {
    func tableObserver(_ observer:TableObserving, created:[TableRow], updated:[TableRow], deleted:[TableRow])
}
