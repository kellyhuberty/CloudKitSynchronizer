//
//  Model.swift
//  VHX
//
//  Created by Kelly Huberty on 2/3/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

protocol Model : Codable, FetchableRecord, TableRecord, PersistableRecord {

}

enum ModelSaveStatus {
    case success
    case fail(_ error:Error?)
}

extension Model {
    
    var databaseQueue:DatabaseQueue {
        
        return Repo.shared.databaseQueue
        
    }
    
    func save(_ completion:((ModelSaveStatus) -> Void)? ) {

        do {
            try databaseQueue.inTransaction { (database) -> Database.TransactionCompletion in
                do{
                    try self.save(database)
                    completion?(.success)
                    return .commit
                }catch{
                    completion?(.fail(error))
                    return .rollback
                }
            }
        } catch {
            completion?(.fail(error))
        }
        
    }
    
    func delete(_ completion:((ModelSaveStatus) -> Void)? ) {
        
        do {
            try databaseQueue.inTransaction { (database) -> Database.TransactionCompletion in
                do{
                    try self.delete(database)
                    completion?(.success)
                    return .commit
                }catch{
                    completion?(.fail(error))
                    return .rollback
                }
            }
        } catch {
            completion?(.fail(error))
        }
        
    }
    
}
