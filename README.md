# Cloud Kit Synchronizer #

Cloud Kit Synchronizer (CKS) is an addition to a Cocoa app's data stack for
syncing data between tables in an SQLite database to corresponding entities in
CloudKit. CKS is based off of features of GRDB, and is written in Swift.

## Features
* Automatic syncing of SQLite tables using Apple CloudKit. * SQLite querying
using GRDB. * Error notifications using observers. * Conflict Resolution. *
Tested for reliability.

## Usage

### Getting started.

Create a `Repo` to start making SQLite queries and syncing your tables.

```swift
	let repo = Repo(domain: "iCloud.com.kellyhuberty.CloudKitSynchronizer", 
					path: directory.path, 
					migrator: LSTDatabaseMigrator.setupMigrator(),
					synchronizedTables: [SynchronizedTable(table:"Item")] )
```

In this example `Item` is the name of the table getting synced.

To start making queries, use the Repo's `databaseQueue` property. This Database
queue is provided by GRDB, so any GRDB features can be used with it.

```swift
	try! repo.databaseQueue.write { (db) -> Void in
		try! item.save(db)
	}
```

To perform a resync of the latest changes, call `repo.cloudSyncrhonizer.refreshFromCloud(_:)`. The `cloudSyncrhonizer` coordinates all changes between your SQLite database and CloudKit.

```swift
        repo.cloudSynchronizer?.refreshFromCloud {
            DispatchQueue.main.async {
				//Do something to your UI here, because you're now in sync.
            }
        }
```

## Using CloudKit Assets
_More Info Coming Soon_

## Subscribing to Data Changes
_More Info Coming Soon_

## Error Handling
_In Dev_

## Resolving Conflicts
_In Dev_

