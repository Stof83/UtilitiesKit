//
//  Utilities.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 19/06/23.
//

import Foundation

/// Helper for removing boilerplate code when dispatching a block asynchronously
public func dispatchOnMainThread(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
