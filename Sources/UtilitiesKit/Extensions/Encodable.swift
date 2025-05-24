//
//  Encodable.swift
//
//  Created by El Mostafa El Ouatri on 01/03/23.
//
//

import Foundation

extension Encodable {

    public var toDictionary: [String: Any]? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        if let encoded = try? encoder.encode(self) {
            return (try? JSONSerialization.jsonObject(
                with: encoded,
                options: .allowFragments)
            ).flatMap {
                $0 as? [String: Any]
            }
        }
        
        return nil
    }

}
