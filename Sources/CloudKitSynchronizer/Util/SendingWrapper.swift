//
//  SendingWrapper.swift
//  CloudKitSynchronizer
//
//  Created by Kelly Huberty on 11/15/26.
//  Copyright © 2026 Kelly Huberty. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "SendingWrapper is by definition unsafe and should be eliminated where possible")
struct SendingWrapper<InputType, OutputType>: @unchecked Sendable {
    var block: (InputType) -> OutputType

    init(_ block: @escaping (InputType) -> OutputType) {
        self.block = block
    }

    func invoke(_ arg: InputType) -> OutputType {
        block(arg)
    }
}

extension SendingWrapper where InputType == Void {
    func invoke() -> OutputType {
        block(())
    }
}

extension SendingWrapper where OutputType == Void {
    func invoke(_ arg: InputType) {
        block(arg)
    }
}

extension SendingWrapper where InputType == Void, OutputType == Void {
    func invoke() {
        block(())
    }
}
