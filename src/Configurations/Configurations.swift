//
//  Configurations.swift
//  Pods
//
//  Created by Kelly Huberty on 1/16/22.
//

import Foundation
import CloudKit



public class TableConfiguration : TableConfigurable {
    public let tableName: String
    public var syncedAssets: [AssetConfigurable]
    public var subscriptions: [Subscription]
    public var excludedColumns: [String]?
    
    public init(table:String, assets: [AssetConfigurable] = [], excludedColumns: [String]? = nil, subscriptions: [Subscription] = []){
        self.tableName = table
        self.syncedAssets = assets
        self.subscriptions = subscriptions
        self.excludedColumns = excludedColumns
    }
}

typealias TableConfig = TableConfiguration

public protocol TableConfigurable {
    var tableName:String { get }
    var syncedAssets: [AssetConfigurable] { get }
    var excludedColumns: [String]? { get }
    var subscriptions: [Subscription] { get }
}

public protocol AssetConfigurable {
    var column: String { get }
    func localFilePath(rowIdentifier: String, table: String, column: String) -> URL
    func stagedFilePath(rowIdentifier: String, table: String, column: String) -> URL
}

public extension AssetConfigurable {
    func stagedFilePath(rowIdentifier: String, table: String, column: String) -> URL {
        return localFilePath(rowIdentifier: rowIdentifier, table: table, column: column)
            //.appendingPathExtension("staging")
    }
}

public class AssetConfiguration: AssetConfigurable {
    
    public let column: String
    private let filePathHandler: (_ rowIdentifier: String, _ table: String, _ column: String) -> URL
    
    private static func newDefaultFilePathHandler(directory: URL, fileExtension: String? = nil)
    -> ((_ rowIdentifier: String, _ table: String, _ column: String) -> URL) {
        return {(_ rowIdentifier: String, _ table: String, _ column: String) in
            /// Due to some narly cases with case sensitive files systems on iOS, going to enforce some items here to be lowercased.
            var url = directory.appendingPathComponent("\(table.lowercased())")
                               .appendingPathComponent("\(column.lowercased())")
                               .appendingPathComponent("\(rowIdentifier)")
            if let fileExtension = fileExtension {
                url.appendPathExtension(fileExtension)
            }
            return url
        }
    }

    public convenience init(column: String, directory: URL, fileExtension: String? = nil) {
        self.init(column: column,
                  filePathHandler: AssetConfiguration.newDefaultFilePathHandler(directory: directory, fileExtension: fileExtension))
    }
    
    public init(column: String, filePathHandler: @escaping(_ rowIdentifier: String, _ table: String, _ column: String) -> URL) {
        self.column = column
        self.filePathHandler = filePathHandler
    }
    
    public func localFilePath(rowIdentifier: String, table: String, column: String) -> URL {
        return filePathHandler(rowIdentifier, table, column)
    }
}

typealias AssetConfig = AssetConfiguration

public struct Subscription: Hashable {
    public enum Event: String, Hashable {
        case create
        case update
        case delete
    }
    
    public init(triggers: [Event] = [.create, .update, .delete], notificationInfo: CKSubscription.NotificationInfo) {
        self.sendEvents = triggers
        self.notificationInfo = notificationInfo
    }
    
    public init() {

    }
    
    public var sendEvents: [Event] = [.create, .update, .delete]
    
    public var notificationInfo: CKSubscription.NotificationInfo = CKSubscription.NotificationInfo()
}

