//
//  Optional.swift
//  wetaxi
//
//  Created by El Mostafa El Ouatri on 18/02/22.
//  Copyright © 2022 Wetaxi. All rights reserved.
//

import Foundation

public protocol OptionalType {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}

extension Optional {
    public var isNil: Bool {
        return self == nil
    }

    public var isNotNil: Bool {
        return self != nil
    }
}


extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}
