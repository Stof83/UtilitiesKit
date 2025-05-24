//
//  CaseIterableDefaultsFirst.swift
//
//  Created by El Mostafa El Ouatri on 24/03/23.
//
//

public protocol CaseIterableDefaultsFirst: Codable & CaseIterable & RawRepresentable

where RawValue: Codable, AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsFirst {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.first!
    }
}
