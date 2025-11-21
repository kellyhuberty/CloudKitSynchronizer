//
//  CloudKitSubscriptionSyncOperation.swift
//  Pods
//
//  Created by Kelly Huberty on 1/16/22.
//

import Foundation
import CloudKit

//fileprivate typealias SubscriptionDictionary = [CKSubscription.ID: CKSubscription]

typealias SubscriptionDictionary = [CKSubscription.ID: CKSubscription]



@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)
class CloudKitSubscriptionSyncOperation: AsyncCloudKitOperation, CloudSubscriptionSyncOperation {
    
    var configurations: [TableConfigurable] = []
    
    private var fetchOperation: CKFetchSubscriptionsOperation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
    
    private var modifyOperation: CKModifySubscriptionsOperation?
    
    override func start(completionToken: AsynchronousOperation.Token) {
        
        let requiredSubscriptions = generateCKSubscriptions()
        
        if (requiredSubscriptions.count == 0) {
            completionToken.finish()
            return
        }
        
        Task { [weak self] in
            
            guard let self else { return }
            do {
                _ = try await self.pullCurrentSubscriptions()
                
                let requiredSubscriptions = self.generateCKSubscriptions()
                
                /// Eventually going to add diffing here and remove all unneded subscriptions, but for now we're just going to add all required.
                //   let subscriptionIdsToRemove = Set(currentSubscriptions.keys).subtracting(requiredSubscriptions.keys)
                //   let subscriptionsToRemove = currentSubscriptions.filter { id, sub in subscriptionIdsToRemove.contains(id) }.values
                //   let subscriptionIdsToAdd = Set(requiredSubscriptions.keys).subtracting(currentSubscriptions.keys)
                //   let subscriptionsToAdd = requiredSubscriptions.filter { id, sub in subscriptionIdsToAdd.contains(id) }.values
                
                try await self.modifySubscriptions(add: Array(requiredSubscriptions.values), remove: Array([]))
                
                completionToken.finish()
                
            }
            catch {
                print("Error pulling current subscriptions: \(error)")
                completionToken.finish()
            }
        }
        
    }
    
    @available(iOSApplicationExtension 13.0.0, *)
    private func pullCurrentSubscriptions() async throws -> SubscriptionDictionary {
        let subscriptions = try await database.allSubscriptions()
        var currentSubscriptions = SubscriptionDictionary()
        
        subscriptions.forEach { subscription in
            currentSubscriptions[subscription.subscriptionID] = subscription
        }
        return currentSubscriptions
    }

    private func modifySubscriptions(add: [CKSubscription], remove: [CKSubscription.ID]) async throws {
        _ = try await database.modifySubscriptions(saving: add, deleting: remove)
    }
    
    private func generateCKSubscriptions() -> SubscriptionDictionary {
        
        var subscriptions = SubscriptionDictionary()
        
        for table in configurations {
            subscriptions.merge(table.ckSubscriptions) { lh, rh in return lh }
        }
        
        return subscriptions
    }
    
    
}

//fileprivate extension CKDatabase{
//    func deleteSubscriptionAsync(_ subscriptionId: CKSubscription.ID ) async throws {
//
//        withCheckedThrowingContinuation { continuation: CheckedContinuation<T, Error> in
//            self.delete(withSubscriptionID: subscriptionId, completionHandler: T##(String?, Error?) -> Void)
//
//        }
//
//        self.delete(withSubscriptionID: <#T##CKSubscription.ID#>) { <#String?#>, <#Error?#> in
//            <#code#>
//        }
//
//    }
//}

fileprivate extension TableConfigurable {
    
    var ckSubscriptions: SubscriptionDictionary {
        get{
            guard subscriptions.count > 0 else {
                return [:]
            }

            var returnedSubscriptions = SubscriptionDictionary()
            
            
            for subscription in subscriptions {
                var options: CKQuerySubscription.Options = []

                var identifier = "\(self.tableName)"

                if subscription.sendEvents.contains(.create) {
                    identifier = identifier + "Create"
                    options = options.union(.firesOnRecordCreation)
                }
                if subscription.sendEvents.contains(.update) {
                    identifier = identifier + "Update"
                    options = options.union(.firesOnRecordUpdate)
                }
                if subscription.sendEvents.contains(.delete) {
                    identifier = identifier + "Delete"
                    options = options.union(.firesOnRecordDeletion)
                }

                identifier = identifier + "_\(String(describing: subscription.hash))"

                let newSubscription = CKQuerySubscription(recordType: self.tableName,
                                                          predicate: NSPredicate(value: true),
                                                          subscriptionID: identifier,
                                                          options: options)

                newSubscription.zoneID = CKRecordZone.ID(zoneName: CloudSynchronizer.ZoneName.defaultZoneName, ownerName: CKCurrentUserDefaultName)

                newSubscription.notificationInfo = subscription.notificationInfo
                
                
                returnedSubscriptions[newSubscription.subscriptionID] = newSubscription
            }
                
            return returnedSubscriptions
        }
    }
    
}


