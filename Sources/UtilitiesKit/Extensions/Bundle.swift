//
//  Bundle.swift
//  
//
//  Created by El Mostafa El Ouatri on 10/08/23.
//

import Foundation

extension Bundle {
    public func data(_ file: String, withExtension: String = "json") -> Data {
        guard let url = self.url(forResource: file, withExtension: withExtension) else {
            fatalError("failed to locate \(file)")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file)")
        }
        return data
    }
    
    public func decode<T: Decodable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("failed to locate \(file)")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file)")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "y-MM-dd"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("failed to decode \(file)")
        }
        
        return loaded
    }
}
