//
//  ValidatorType.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 26/02/25.
//

import Foundation

/// Enum to define various validation types that can be applied to a string.
public enum ValidatorType {
    case emailAddress
    case taxCode
    case name
    case fullName
    case password
    case url
    case mobile
    case zipCode
    case custom(String)
    
    /// Validates a string against the associated validation type.
    /// - Parameter value: The string value to validate.
    /// - Returns: A Boolean indicating whether the value passes the validation criteria.
    public func validate(_ value: String) -> Bool {
        switch self {
        case .emailAddress:
            return value.isValidEmail
        case .taxCode:
            return value.isValidTaxCode
        case .name:
            return value.isValidName
        case .fullName:
            return value.isValidFullname
        case .password:
            return value.isValidPassword
        case .url:
            return value.isValidURL
        case .mobile:
            return value.isValidMobile
        case .zipCode:
            return value.isValidZipCode
        case .custom(let pattern):
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: value)
        }
    }
}
