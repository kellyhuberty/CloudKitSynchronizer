//
//  CloudChangeTag.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 8/25/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import CloudKit

class CloudChangeTag : Model, Codable{
    
    static var databaseTableName: String {
        return TableNames.ChangeTags
    }
    
    var changeTokenData: Data
    let processDate: Date
    
    init(token: CKServerChangeToken, processDate: Date = Date()) throws {
        self.changeTokenData = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        self.processDate = processDate
    }
    
    func getChangeToken() throws -> CKServerChangeToken{
        //Error: .changeTokenArchiveError
        return try! NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: changeTokenData)!
    }
    
    func setChangeToken(_ newToken: CKServerChangeToken) throws{
        //Error: .changeTokenArchiveError
        changeTokenData = try! NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: true)
    }
}
