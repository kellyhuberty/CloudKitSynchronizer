# Modernization Progress

Tracks the Swift 6 migration and the removal of CocoaPods support.

## Swift 6 migration — merged (#17)

The library and TestApp compile in the Swift 6 language mode with complete
concurrency checking. Public API changes were deliberately deferred.

### Follow-ups (~19 warnings remain, no errors)

- [ ] Make `CloudSynchronizer` `Sendable` / `async`, starting with
      `refreshFromCloud`, then delete `Util/SendingWrapper.swift`.
- [ ] Make `TableRow` `Sendable` so `SQLiteTableObserver` can hand rows to its
      delegate across queues safely.
- [ ] Replace the `@unchecked Sendable` `Operation` subclasses and deprecated
      `CKOperation` completion blocks with async `CKDatabase` APIs.
      (`CloudOperator.swift` and the empty `CloudKitOperationQueue` actor are
      early scaffolding for this.)

## Remove CocoaPods — merged (#18)

Goal: one supported distribution (Swift Package Manager) and a TestApp with a
single app target, so there's no duplicate build configuration to keep in sync.

### Done

- [x] `pod deintegrate`; deleted the `CloudKitSynchronizerAppPod` and pod
      `CloudKitSynchronizerTests` targets and their schemes.
- [x] Deleted `CloudKitSynchronizer.podspec`, `podfile`, `Podfile.lock`, the
      committed `Pods/` directory (213 files), and the tracked workspace files.
- [x] Renamed `CloudKitSynchronizerAppPkg` → `CloudKitSynchronizerApp` and
      `CloudKitSynchronizerPkgTests` → `CloudKitSynchronizerIntegrationTests`.
- [x] Fixed test wiring: the integration tests previously depended on, were
      hosted by, and `@testable import`ed the **Pod** app. They now use the SPM app.
- [x] The app links GRDB explicitly (it imports GRDB directly). The test bundle
      no longer links its own copies of the packages; it gets those symbols from
      the host app through `BUNDLE_LOADER`.
- [x] Test targets use `GENERATE_INFOPLIST_FILE`; deleted the duplicate test plists.
- [x] Removed dead files: Cuckoo script phases and `GeneratedMocks.swift`, the
      broken template test, the empty `CloudSynchronizerTests.swift`, stale
      `libsqlite3`/framework references, the empty `TestApp.xcconfig`, and the
      tracked `.swiftpm` `xcuserdata`.
- [x] Added a `CloudKitSynchronizerTests` `.testTarget` to `Package.swift` and moved
      `WeakArrayTests` into it.
- [x] README: added Installation (SPM only) and Testing sections.

### Verified

- [x] `swift test` — 4 `WeakArrayTests` pass.
- [x] `xcodebuild build-for-testing` (scheme `CloudKitSynchronizerApp`) succeeds
      from a clean build folder.
- [x] Integration test bundle loads and runs inside `CloudKitSynchronizerApp` on a simulator.

### Remaining

- [x] Delete the leftover `TestApp/CloudKitSynchronizer.xcworkspace/` folder (it
      only contains untracked `xcuserdata`), then open
      `TestApp/CloudKitSynchronizer.xcodeproj` directly.
- [x] Run the integration tests signed in to iCloud.
- [x] Run `swift package update` at the root. The root `Package.resolved` now
      pins GRDB 7.12.0 (was 7.8.0), matching the TestApp.
- [x] Commit and open a PR. Note it as a breaking change for anyone installing
      with CocoaPods.

## Flatten layout — branch `flatten-layout`

Goal: with CocoaPods gone, drop the nested `TestApp/` project so the repo root
holds the package, the Xcode project, and one workspace that runs every test.
(Paths in the sections above are from before this change.)

### Done

- [x] Moved `TestApp/CloudKitSynchronizer.xcodeproj` → `CloudKitSynchronizer.xcodeproj`,
      `TestApp/CloudKitSynchronizerApp/*` → `TestApp/*`, and
      `TestApp/Tests/IntegrationTests/*` → `Tests/IntegrationTests/*`. The local
      package reference is now `relativePath = .`.
- [x] Added `CloudKitSynchronizer.xcworkspace` with the package root and the
      project as roots, so one scheme can see the package's test targets.
- [x] Moved the `CloudKitSynchronizerApp` scheme into the workspace and added
      `CloudKitSynchronizerTests` to it.
- [x] Shared the `CloudKitSynchronizer` package scheme (`.swiftpm/xcode/xcshareddata`).
- [x] `.gitignore`: un-ignored the root `CloudKitSynchronizer.xcodeproj` (the
      `/*.xcodeproj` rule matched it after the move).
- [x] README: Testing section points at the workspace.

### Remaining

- [ ] ⌘U on `CloudKitSynchronizerApp` in the workspace runs both test bundles.
- [ ] `swift build` / `swift test` still pass from the root.

### Follow-up PR

- [ ] Remove the force-unwraps in `testCloudKitAddDelete` / `testCloudKitAddEdit`
      (`CloudSyncIntegrationTests.swift:256`, `:323`). On a signed-out simulator
      the tests fail with `This request requires an authenticated account`, then
      crash on the unwrap instead of failing cleanly.

### Ideas for later

- Convert `WeakArrayTests` (XCTest) to Swift Testing.
- Move more CloudKit-free logic tests into the package test target so they run
  without a simulator or signing.
