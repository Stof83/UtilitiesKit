//
//  MapKit.swift
//  
//
//  Created by El Mostafa El Ouatri on 27/08/23.
//

import MapKit

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        if lhs.center.latitude == rhs.center.latitude && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta {
            return true
        } else {
            return false
        }
    }
}

extension CLLocationDistance {
    public var string: String {
        let measurement = Measurement(value: self.rounded(), unit: UnitLength.meters)
        
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

extension CLLocationCoordinate2D {
    public var location: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    public func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        location.distance(from: other.location)
    }
}

extension MKMultiPoint {
    public var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
