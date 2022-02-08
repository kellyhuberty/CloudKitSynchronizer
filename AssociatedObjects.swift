//
//  AssociatedObjects.swift
//  AssociatedObjects
//
//  Created by Kelly Huberty on 9/14/21.
//  Copyright © 2021 Kelly Huberty. All rights reserved.
//

import Foundation

//extension NSObject {
//
//    private class NSObjectWrapper<T>: NSObject {
//
//        init(_ item: T) {
//            self.item = item
//            super.init()
//        }
//
//        var item: T
//    }
//
//    func setAssociatedItem<T>(_ item: T, for key: Void){
//        let wrapper = NSObjectWrapper(item)
//        key.hashValue
//        objc_setAssociatedObject(self, &key, wrapper, .OBJC_ASSOCIATION_RETAIN)
//
//    }
//
//    func getAssociatedItem<T>(for key: Void) -> T {
//
//
//        let wrapper = objc_getAssociatedObject(self, &key) as? String
//
//    }
//
//
//}
