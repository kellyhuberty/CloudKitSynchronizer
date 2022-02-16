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
            return
        }
        
        if #available(iOS 15, tvOS 15, macOS 12, watchOS 8, *) {
            Task { [weak self] in
                let currentSubscriptions = await self?.pullCurrentSubscriptions() ?? [:]
                
                let requiredSubscriptions = self?.generateCKSubscriptions() ?? [:]

/// Eventually going to add diffing here and remove all unneded subscriptions, but for now we're just going to add all required.
//                let subscriptionIdsToRemove = Set(currentSubscriptions.keys).subtracting(requiredSubscriptions.keys)
//                let subscriptionsToRemove = currentSubscriptions.filter { id, sub in subscriptionIdsToRemove.contains(id) }.values
//                let subscriptionIdsToAdd = Set(requiredSubscriptions.keys).subtracting(currentSubscriptions.keys)
//                let subscriptionsToAdd = requiredSubscriptions.filter { id, sub in subscriptionIdsToAdd.contains(id) }.values
                
                await modifySubscriptions(add: Array(requiredSubscriptions.values), remove: Array([]))
                
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
        
        /// This block of code was the original way I was modifying suscriptions, and I'd like to restore this
        /// as some point as it is probably faster. -kh
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

        modifyOperation.start()
        
        semaphore.wait()
        
        
//        for subscription in add {
//            do {
//                let _ = try await database.save(subscription)
//            }
//            catch let err {
//                print("can't save subscription \(subscription). Error: \(err)")
//            }
//        }
//
//        for subscription in remove {
//            do {
//                let _ = try await database.delete(withSubscriptionID: <#T##CKSubscription.ID#>, completionHandler: <#T##(String?, Error?) -> Void#>)
//            }
//            catch let err {
//                print("can't save subscription \(subscription). Error: \(err)")
//            }
//        }
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
                        
            
//            let subscription = CKDatabaseSubscription(subscriptionID: "test")
//            subscription.recordType = "Page"
//
//            //subscription.zoneId = CKRecordZone.ID(zoneName: CloudSynchronizer.ZoneName.defaultZoneName, ownerName: CKCurrentUserDefaultName)
//
//
//            let notificationInfo = CKSubscription.NotificationInfo()
//            notificationInfo.shouldSendContentAvailable = false
//            notificationInfo.alertBody = "Hey"
//            notificationInfo.soundName = "default"
//            notificationInfo.shouldBadge = true
//
//            subscription.notificationInfo = notificationInfo
        
            
//            return ["test": subscription]
        }
    }
    
}


