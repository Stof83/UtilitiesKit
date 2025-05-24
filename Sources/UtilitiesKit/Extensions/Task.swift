//
//  Task.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 12/02/25.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
    
    static func sleep(milliseconds: Int) async throws {
        let duration = UInt64(milliseconds * 1_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
