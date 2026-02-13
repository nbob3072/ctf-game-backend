import Foundation
import CoreLocation
import Combine
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    @Published var flags: [Flag] = []
    @Published var selectedFlag: Flag?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var captureInProgress = false
    @Published var lastCaptureResult: CaptureResult?
    @Published var defenderTypes: [DefenderType] = []
    
    private let apiService = APIService.shared
    private let locationService = LocationService.shared
    private let wsService = WebSocketService.shared
    
    private var cancellables = Set<AnyCancellable>()
    private var flagRefreshTimer: Timer?
    
    init() {
        setupLocationUpdates()
        setupWebSocketListeners()
        loadDefenderTypes()
    }
    
    // MARK: - Location Updates
    
    private func setupLocationUpdates() {
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.userLocation = location.coordinate
                
                // Auto-refresh flags when user moves significantly
                if self?.shouldRefreshFlags(for: location) == true {
                    self?.loadNearbyFlags()
                }
            }
            .store(in: &cancellables)
    }
    
    private func shouldRefreshFlags(for location: CLLocation) -> Bool {
        // Refresh if user hasn't loaded flags yet
        guard let lastLocation = locationService.lastFlagRefreshLocation else {
            return true
        }
        
        // Refresh if user moved more than 500m
        let distance = location.distance(from: lastLocation)
        return distance > 500
    }
    
    // MARK: - WebSocket Listeners
    
    private func setupWebSocketListeners() {
        wsService.onFlagUpdate = { [weak self] update in
            self?.handleFlagUpdate(update)
        }
    }
    
    private func handleFlagUpdate(_ update: [String: Any]) {
        guard let flagId = update["flagId"] as? String else { return }
        
        // Refresh the specific flag or all flags
        Task {
            await refreshFlag(flagId)
        }
    }
    
    // MARK: - Load Flags
    
    func loadNearbyFlags(radius: Double = 2000) {
        guard let location = userLocation else {
            Logger.debug("Cannot load flags: user location unknown")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.getNearbyFlags(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    radius: radius
                )
                
                self.flags = response.flags
                self.isLoading = false
                
                // Update last refresh location
                if let currentLocation = locationService.currentLocation {
                    locationService.lastFlagRefreshLocation = currentLocation
                }
                
                // Subscribe to all flag updates
                subscribeToFlags()
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                Logger.error("Failed to load flags: \(error)")
            }
        }
    }
    
    func refreshFlag(_ flagId: String) async {
        do {
            let response = try await apiService.getFlagDetail(flagId: flagId)
            
            // Update flag in array
            if let index = flags.firstIndex(where: { $0.id == flagId }) {
                // Create updated flag from detail
                let updatedFlag = Flag(
                    id: response.flag.id,
                    name: response.flag.name,
                    latitude: response.flag.latitude,
                    longitude: response.flag.longitude,
                    type: response.flag.type,
                    distanceMeters: calculateDistance(to: response.flag),
                    ownerTeam: response.flag.currentOwner?.team,
                    ownerUsername: response.flag.currentOwner?.username,
                    hasDefender: response.flag.defender != nil,
                    defender: response.flag.defender,
                    totalCaptures: response.flag.totalCaptures,
                    capturedAt: nil,
                    captureRadius: nil
                )
                
                flags[index] = updatedFlag
                
                // Update selected flag if it's the same
                if selectedFlag?.id == flagId {
                    selectedFlag = updatedFlag
                }
            }
            
        } catch {
            Logger.error("Failed to refresh flag \(flagId): \(error)")
        }
    }
    
    private func calculateDistance(to flagDetail: FlagDetail) -> Double {
        guard let userLoc = userLocation else { return 0 }
        
        let flagLocation = CLLocation(
            latitude: flagDetail.latitude,
            longitude: flagDetail.longitude
        )
        let userCLLocation = CLLocation(
            latitude: userLoc.latitude,
            longitude: userLoc.longitude
        )
        
        return userCLLocation.distance(from: flagLocation)
    }
    
    // MARK: - Capture Flag
    
    func captureFlag(_ flag: Flag, withDefender defenderTypeId: Int?) async throws {
        guard let location = userLocation else {
            throw CTFError.locationUnavailable
        }
        
        captureInProgress = true
        errorMessage = nil
        
        do {
            let response = try await apiService.captureFlag(
                flagId: flag.id,
                latitude: location.latitude,
                longitude: location.longitude,
                defenderTypeId: defenderTypeId
            )
            
            self.lastCaptureResult = response.capture
            self.captureInProgress = false
            
            // Refresh flags to show updated state
            await refreshFlag(flag.id)
            
            // Show success notification
            NotificationService.shared.showLocalNotification(
                title: "Flag Captured! 🎉",
                body: "You captured \(flag.name) and earned \(response.capture.xpEarned) XP!"
            )
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.captureInProgress = false
            throw error
        }
    }
    
    // MARK: - Defender Types
    
    private func loadDefenderTypes() {
        Task {
            do {
                let types = try await apiService.getDefenderTypes()
                self.defenderTypes = types
            } catch {
                Logger.error("Failed to load defender types: \(error)")
            }
        }
    }
    
    // MARK: - WebSocket Subscriptions
    
    private func subscribeToFlags() {
        for flag in flags {
            wsService.subscribeToFlag(flagId: flag.id)
        }
    }
    
    // MARK: - Helper Methods
    
    func distanceToFlag(_ flag: Flag) -> Double? {
        guard let userLoc = userLocation else { return nil }
        
        let flagLocation = CLLocation(
            latitude: flag.latitude,
            longitude: flag.longitude
        )
        let userCLLocation = CLLocation(
            latitude: userLoc.latitude,
            longitude: userLoc.longitude
        )
        
        return userCLLocation.distance(from: flagLocation)
    }
    
    func canCaptureFlag(_ flag: Flag) -> Bool {
        guard let distance = distanceToFlag(flag) else { return false }
        let radius = flag.captureRadius ?? 30.0
        return distance <= radius
    }
    
    // MARK: - Cleanup
    
    deinit {
        flagRefreshTimer?.invalidate()
        cancellables.removeAll()
    }
}

enum CTFError: LocalizedError {
    case locationUnavailable
    case tooFarFromFlag
    case alreadyOwnedByTeam
    
    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            return "Location services unavailable"
        case .tooFarFromFlag:
            return "You're too far from the flag"
        case .alreadyOwnedByTeam:
            return "Your team already owns this flag"
        }
    }
}
