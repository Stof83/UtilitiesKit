//
//  File.swift
//  
//
//  Created by El Mostafa El Ouatri on 18/06/23.
//

import Foundation

extension Int {
    
    public var toTimeInterval: TimeInterval {
        TimeInterval(self)
    }
    
    public func toPrice(with currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency

        return formatter.string(from: NSNumber(value: Double(self) / 100)) ?? " - "
    }
    
    public var toKilometers: String {
        let measurement = Measurement(value: Double(self), unit: UnitLength.kilometers)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .medium
        formatter.locale = Locale.current
        formatter.numberFormatter = numberFormatter
        return formatter.string(from: measurement)
    }
}
