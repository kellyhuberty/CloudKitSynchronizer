//
//  Filepaths.swift
//  VHX
//
//  Created by Kelly Huberty on 12/23/18.
//  Copyright © 2018 Kelly Huberty. All rights reserved.
//

import Foundation

public class Directories {
    public static var documents: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
}

class Domain {
    public static let current: String = "com.kellyhuberty.CloudKitSynchronizer"
}
