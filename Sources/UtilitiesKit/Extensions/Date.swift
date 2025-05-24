//
//  Date.swift
//
//
//  Created by El Mostafa El Ouatri on 29/06/23.
//

import Foundation
import SwiftDate

extension Date {
    public var isExpired: Bool {
        self.isInPast
    }

    public func toData(maxLength: Int) -> Data {
        let dateInt = Int(self.timeIntervalSince1970)
        return withUnsafeBytes(of: dateInt.bigEndian) { Data($0) }.suffix(maxLength)
    }
}
