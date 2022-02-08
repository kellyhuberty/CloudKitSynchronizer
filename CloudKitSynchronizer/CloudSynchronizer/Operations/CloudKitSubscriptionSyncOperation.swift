//
//  CloudKitSubscriptionSyncOperation.swift
//  Pods
//
//  Created by Kelly Huberty on 1/16/22.
//

import Foundation
import CloudKit

fileprivate typealias SubscriptionDictionary = [CKSubscription.ID: CKSubscription]

@available (iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)
class CloudKitSubscriptionSyncOperation: AsyncCloudKitOperation, CloudSubscriptionSyncOperation {
        
    var configurations: [TableConfigurable] = []
        
    private var fetchOperation: CKFetchSubscriptionsOperation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
    
    private var modifyOperation: CKModifySubscriptionsOperation?

    override func start(completionToken: AsynchronousOperation.Token) {
                        
        let requiredSubscriptions = generateCKSubscriptions()
        
        if (requiredSubscriptions.count == 0) {
            completionToken.finish()
        }
        
        if #available(iOS 15, tvOS 15, macOS 12, watchOS 8, *) {
            Task { [weak self] in
                let currentSubscriptions = await self?.pullCurrentSubscriptions() ?? [:]
                
                let requiredSubscriptions = self?.generateCKSubscriptions() ?? [:]
                
                let subscriptionIdsToRemove = Set(currentSubscriptions.keys).subtracting(requiredSubscriptions.keys)
                let subscriptionIdsToAdd = Set(requiredSubscriptions.keys).subtracting(currentSubscriptions.keys)
                
                let subscriptionsToAdd = requiredSubscriptions.filter { id, sub in subscriptionIdsToAdd.contains(id) }.values
                
                await modifySubscriptions(add: Array(subscriptionsToAdd), remove: Array(subscriptionIdsToRemove))
                
                completionToken.finish()
            }
        } else {


        }
    }

    @available(iOSApplicationExtension 13.0.0, *)
    private func pullCurrentSubscriptions() async -> SubscriptionDictionary {
        
        fetchOperation.qualityOfService = .userInteractive
        fetchOperation.database = database

        var currentSubscriptions = [CKSubscription.ID: CKSubscription]()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var fetchError: Error?
        
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            fetchOperation.perSubscriptionResultBlock = {
                (id: CKSubscription.ID, result: Result<CKSubscription, Error>) in
                
                switch result {
                case .success(let subscription):
                    currentSubscriptions[id] = subscription
                case .failure(let error):
                    fetchError = error
                }
            }
        }
        else {
            fetchOperation.fetchSubscriptionCompletionBlock = {
                (subscriptionsById: [CKSubscription.ID: CKSubscription]?, error: Error?) in
                
                guard error == nil else {
                    fetchError = error
                    return
                }
                
                guard let subscriptionsById = subscriptionsById else{
                    return
                }
                
                currentSubscriptions.merge(subscriptionsById, uniquingKeysWith: { (k1, k2) in return k2 })
            }
        }
        
        fetchOperation.completionBlock = {
            semaphore.signal()
        }
        
        fetchOperation.start()
        
        semaphore.wait()
        
        return currentSubscriptions
    }
    
    private func modifySubscriptions(add: [CKSubscription], remove: [CKSubscription.ID]) async {
        
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: add, subscriptionIDsToDelete: remove)
        
        modifyOperation.qualityOfService = .userInteractive
        modifyOperation.database = database
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var modifyError: Error?
        
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {

            modifyOperation.perSubscriptionSaveBlock = { id, result in
                if case .failure(let error) = result {
                    modifyError = error
                }
            }
            
            modifyOperation.perSubscriptionDeleteBlock = { id, result in
                if case .failure(let error) = result {
                    modifyError = error
                }
            }
            
        }
        else {
            
            modifyOperation.modifySubscriptionsCompletionBlock = { _, _, error in
                if let error = error {
                    modifyError = error
                }
            }
            
        }
        
        modifyOperation.completionBlock = {
            semaphore.signal()
        }

        semaphore.wait()
        
    }
    
    private func generateCKSubscriptions() -> SubscriptionDictionary {
        
        var subscriptions = SubscriptionDictionary()
        
        for table in configurations {
            subscriptions.merge(table.ckSubscriptions) { lh, rh in return lh }
        }
        
        return subscriptions
    }
    
    
}

fileprivate extension TableConfigurable {
    
    var ckSubscriptions: SubscriptionDictionary {
        get{
            guard let subscription = subscription else {
                return [:]
            }
            
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

            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            newSubscription.notificationInfo = notificationInfo
            
            return [newSubscription.subscriptionID: newSubscription]
                        
        }
    }
    
}


