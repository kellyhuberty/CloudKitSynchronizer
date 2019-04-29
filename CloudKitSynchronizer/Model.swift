//
//  Model.swift
//  VHX
//
//  Created by Kelly Huberty on 2/3/19.
//  Copyright © 2019 Kelly Huberty. All rights reserved.
//

import Foundation
import GRDB

protocol Model : Codable, FetchableRecord, TableRecord, PersistableRecord{
    
//    func save(_ completion:((ModelSaveStatus) -> Void)? )
//    
//    func delete(_ completion:((ModelSaveStatus) -> Void)? )

}

enum ModelSaveStatus {
    case success
    case fail(_ error:Error?)
}

extension Model {
    
    var databasePool:DatabasePool {
        
        return Repo.shared.databaseQueue
        
    }
    
    func save(_ completion:((ModelSaveStatus) -> Void)? ) {

        do {
            try databasePool.writeInTransaction { (database) -> Database.TransactionCompletion in
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
            try databasePool.writeInTransaction { (database) -> Database.TransactionCompletion in
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
