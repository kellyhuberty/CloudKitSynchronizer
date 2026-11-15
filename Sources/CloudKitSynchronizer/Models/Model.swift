//
//  Model.swift
//  VHX
//
//  Created by Kelly Huberty on 2/3/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

public protocol Model : Codable, FetchableRecord, PersistableRecord {

}

public protocol IdentifiableModel: Model, Sendable {
    var identifier: String { get }
}
