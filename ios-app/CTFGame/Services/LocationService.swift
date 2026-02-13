import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // Update every 10 meters
        return manager
    }()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    
    var lastFlagRefreshLocation: CLLocation?
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        // Location manager is initialized lazily when first accessed
        // This prevents crashes during app initialization
        
        // For background location updates (when capturing flags)
        // Note: Background location requires UIBackgroundModes in project capabilities
        // TODO: Enable after configuring background modes properly
        // locationManager.allowsBackgroundLocationUpdates = true
        // locationManager.showsBackgroundLocationIndicator = true
        
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Permissions
    
    func requestPermission() {
        Logger.debug("Requesting location permission")
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            Logger.error("Location access denied or restricted")
            
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    func requestAlwaysAuthorization() {
        // For background location updates
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Updates
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            Logger.error("Cannot start location updates: not authorized")
            return
        }
        
        Logger.debug("Starting location updates")
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    func stopUpdatingLocation() {
        Logger.debug("Stopping location updates")
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    // MARK: - Distance Calculations
    
    func distance(from location: CLLocationCoordinate2D) -> Double? {
        guard let currentLocation = currentLocation else { return nil }
        
        let targetLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        return currentLocation.distance(from: targetLocation)
    }
    
    func isWithinRadius(_ radius: Double, of location: CLLocationCoordinate2D) -> Bool {
        guard let distance = distance(from: location) else { return false }
        return distance <= radius
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filter out inaccurate locations
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 100 else {
            Logger.debug("Ignoring inaccurate location: \(location.horizontalAccuracy)m")
            return
        }
        
        Logger.debug("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.error("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        Logger.debug("Location authorization changed: \(authorizationStatus.rawValue)")
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        case .denied, .restricted:
            stopUpdatingLocation()
            
        default:
            break
        }
    }
}
