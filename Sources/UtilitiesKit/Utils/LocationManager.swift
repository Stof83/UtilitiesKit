//
//  LocationManager.swift
//  UtilitiesKit
//
//  Created by El Mostafa El Ouatri on 08/08/23.
//

import Foundation
import CoreLocation
import Combine

/// A singleton class for managing location services and authorization status.
/// It provides real-time location updates and handles location-related errors.
public class LocationManager: NSObject, ObservableObject {
    
    /// Shared instance of `LocationManager`.
    public static let shared = LocationManager()
    
    /// The latest known location of the user.
    @Published public private(set) var location: CLLocation?
    
    /// The current authorization status for location access.
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Indicates whether location services are available.
    @Published public private(set) var isLocationAvailable = true
    
    /// If set to `true`, prevents automatic location updates from being overridden.
    public var isLocationOverridden = false
    
    private let locationManager = CLLocationManager()
    private var lastUpdateTimestamp: Date?
    private var retryCount = 0
    private let maxRetries = 3
    
    /// Private initializer to enforce singleton pattern.
    override private init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: - Public Methods
    
    /// Requests permission for accessing the user's location when the app is in use.
    public func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Requests permission for accessing the user's location at all times.
    public func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Starts monitoring and updating the user's location.
    public func startUpdatingLocation() {
        stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    /// Stops monitoring and updating the user's location.
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Checks and updates the authorization status.
    /// If authorized, starts updating the location; otherwise, disables location access.
    public func checkLocationAuthorization() {
        authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAvailable = true
            startUpdatingLocation()
        
        case .denied, .restricted:
            Task { @MainActor in
                self.location = nil
                self.isLocationAvailable = false
            }
            print("❌ Location access denied. Please enable it in settings.")
        
        case .notDetermined:
            print("ℹ️ Requesting location permission...")
            requestWhenInUseAuthorization()
        
        @unknown default:
            Task { @MainActor in
                self.location = nil
                self.isLocationAvailable = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Configures the location manager with appropriate settings.
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    /// Handles successful location updates.
    /// - Parameter manager: The location manager instance.
    /// - Parameter locations: Array of location updates, where the last element is the most recent.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Throttle updates to avoid excessive processing
        if let lastUpdate = lastUpdateTimestamp, Date().timeIntervalSince(lastUpdate) < 10 {
            return
        }
        lastUpdateTimestamp = Date()
        
        Task { @MainActor in
            if !isLocationOverridden {
                self.location = newLocation
                self.retryCount = 0 // Reset retry counter on success
            }
        }
    }
    
    /// Handles errors that occur during location updates.
    /// - Parameter manager: The location manager instance.
    /// - Parameter error: The error that occurred.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            print("❌ Unknown error: \(error.localizedDescription)")
            return
        }
        
        switch clError.code {
        case .locationUnknown:
            print("⚠️ Location unknown. Retrying...")
            retryFetchingLocation()
            
        case .denied:
            print("❌ Location permission denied. Clearing location data.")
            Task { @MainActor in
                self.location = nil
                self.isLocationAvailable = false
            }
            
        case .network:
            print("⚠️ Network issue detected. Keeping last known location.")
            
        case .headingFailure:
            print("⚠️ Heading failure. Try recalibrating the compass.")
            
        default:
            print("⚠️ Unhandled location error: \(clError.localizedDescription)")
        }
    }
    
    /// Handles changes in location authorization status.
    /// - Parameter manager: The location manager instance.
    /// - Parameter status: The new authorization status.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.checkLocationAuthorization()
        }
    }
    
    // MARK: - Error Recovery Mechanisms
    
    /// Attempts to retrieve the user's location with a limited number of retries.
    private func retryFetchingLocation() {
        if retryCount < maxRetries {
            retryCount += 1
            print("🔄 Retrying location update (\(retryCount)/\(maxRetries))...")
            locationManager.requestLocation()
        } else {
            print("❌ Max retries reached. Unable to get location.")
        }
    }
}
