Pod::Spec.new do |spec|
  spec.name         = 'CloudKitSynchronizer'
  spec.ios.deployment_target  = '16.0'
  spec.osx.deployment_target  = '15.0'
  spec.version      = '0.2.0'
  spec.license      = { :type => 'Unavailable' }
  spec.source       = { :git => 'git@github.com:kellyhuberty/CloudKitSynchronizer.git' }
  spec.homepage     = 'https://github.com/kellyhuberty/CloudKitSynchronizer'
  spec.authors      = { 'Kelly Huberty' => 'kellyhuberty@gmail.com' }
  spec.summary      = "Cloud Kit Synchronizer (CKS) is an addition to a Cocoa app's data stack for syncing data between tables in an SQLite database to corresponding entities in CloudKit. CKS is based off of features of GRDB, and is written in Swift."
  spec.source_files = 'Sources/CloudKitSynchronizer/**/*.{swift}'
  spec.dependency 'GRDB.swift'
  spec.swift_version = '5.3'
end