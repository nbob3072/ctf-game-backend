# CTF Game - iOS App

SwiftUI iOS application for Matt's nationwide Capture The Flag (CTF) game MVP.

## 🎮 Features

### Core Gameplay
- **Team Selection**: Choose between Titans, Guardians, or Phantoms
- **Map View**: Real-time MapKit integration showing flags and user location
- **Flag Capture**: GPS proximity-based capturing (within 30m)
- **Defender Deployment**: Deploy virtual defenders after capturing flags
- **Real-time Updates**: WebSocket integration for live flag state changes
- **Attack System**: Challenge enemy-controlled flags

### User Experience
- **Onboarding Flow**: Smooth team selection and account setup
- **Authentication**: Email/password login and registration
- **Profile Management**: View stats, level, XP, and capture history
- **Leaderboards**: Global, team, and personal rankings
- **Push Notifications**: APNs setup for flag alerts

### Technical Features
- **Offline Mode**: Graceful handling of network loss
- **JWT Token Management**: Secure authentication persistence
- **Location Services**: Background location tracking with privacy controls
- **City Filtering**: Show flags only for current city
- **Color-Coded Pins**: Team ownership visualization

## 📋 Requirements

- **iOS**: 16.0+
- **Xcode**: 14.0+
- **Swift**: 5.7+
- **Device**: iPhone (location services required)

## 🚀 Setup Instructions

### 1. Clone Project

```bash
cd ~/Projects/ctf-game/ios-app
```

### 2. Configure Backend

Update `APIService.swift` with your backend URL:

```swift
private let baseURL = "http://YOUR_BACKEND_URL:3000"
private let wsURL = "ws://YOUR_BACKEND_URL:3001"
```

**For local development:**
```swift
private let baseURL = "http://localhost:3000"
private let wsURL = "ws://localhost:3001"
```

**For production:**
```swift
private let baseURL = "https://api.ctfgame.com"
private let wsURL = "wss://api.ctfgame.com/ws"
```

### 3. Open in Xcode

```bash
open CTFGame.xcodeproj
```

Or double-click `CTFGame.xcodeproj` in Finder.

### 4. Configure Signing

1. Select project in Xcode navigator
2. Select "CTFGame" target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Change bundle identifier: `com.yourcompany.ctfgame`

### 5. Configure Capabilities

Required capabilities (already configured in project):

- **Location Services**: Always and When In Use
- **Background Modes**: Location updates
- **Push Notifications**: APNs integration

### 6. Update Info.plist

Privacy descriptions are already included, but verify:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`

### 7. Build and Run

1. Select iPhone simulator or connected device
2. Press `Cmd + R` to build and run
3. Allow location permissions when prompted

## 📱 App Architecture

### MVVM Pattern

```
CTFGame/
├── App/
│   ├── CTFGameApp.swift         # Main app entry point
│   └── AppState.swift            # Global app state management
├── Models/
│   ├── User.swift                # User data model
│   ├── Team.swift                # Team data model
│   ├── Flag.swift                # Flag data model
│   ├── Defender.swift            # Defender data model
│   └── Capture.swift             # Capture history model
├── ViewModels/
│   ├── AuthViewModel.swift       # Authentication logic
│   ├── MapViewModel.swift        # Map and flag management
│   ├── LeaderboardViewModel.swift # Rankings logic
│   └── ProfileViewModel.swift    # User profile logic
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift  # Welcome screen
│   │   └── TeamSelectionView.swift # Choose team
│   ├── Auth/
│   │   ├── LoginView.swift       # Login screen
│   │   └── RegisterView.swift    # Registration screen
│   ├── Map/
│   │   ├── MapView.swift         # Main map interface
│   │   ├── FlagAnnotation.swift  # Custom map pins
│   │   └── FlagDetailView.swift  # Flag info sheet
│   ├── Profile/
│   │   └── ProfileView.swift     # User stats
│   ├── Leaderboard/
│   │   └── LeaderboardView.swift # Rankings
│   └── Components/
│       ├── LoadingView.swift     # Loading spinner
│       └── ErrorView.swift       # Error display
├── Services/
│   ├── APIService.swift          # REST API client
│   ├── WebSocketService.swift    # Real-time updates
│   ├── LocationService.swift     # GPS tracking
│   ├── NotificationService.swift # Push notifications
│   └── KeychainService.swift     # Secure token storage
└── Utilities/
    ├── Extensions.swift          # Helper extensions
    ├── Constants.swift           # App constants
    └── Logger.swift              # Logging utility
```

## 🗺️ Main User Flow

### 1. First Launch
```
OnboardingView → TeamSelectionView → RegisterView → MapView
```

### 2. Returning User
```
Launch → (Auto-login) → MapView
```

### 3. Capture Flow
```
MapView → Tap Flag → FlagDetailView → Capture Button → Deploy Defender → Success
```

### 4. Navigation
```
TabView:
├── Map (main)
├── Leaderboard
└── Profile
```

## 🔌 API Integration

### Authentication

```swift
// Register
try await APIService.shared.register(
    username: "player1",
    email: "player1@example.com",
    password: "password",
    teamId: 1
)

// Login
try await APIService.shared.login(
    email: "player1@example.com",
    password: "password"
)
```

### Flag Operations

```swift
// Get nearby flags
let flags = try await APIService.shared.getNearbyFlags(
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 2000
)

// Capture flag
let result = try await APIService.shared.captureFlag(
    flagId: flagId,
    latitude: userLocation.latitude,
    longitude: userLocation.longitude,
    defenderTypeId: 2
)
```

### WebSocket Real-time Updates

```swift
// Connect
WebSocketService.shared.connect()

// Subscribe to flag updates
WebSocketService.shared.subscribeToFlag(flagId: "uuid")

// Listen for events
WebSocketService.shared.onFlagUpdate = { update in
    // Update UI when flag is captured
}
```

## 🎨 UI Design

### Color Scheme

- **Titans (Red)**: `#E74C3C`
- **Guardians (Blue)**: `#3498DB`
- **Phantoms (Green)**: `#2ECC71`
- **Background**: Dark mode optimized
- **Accents**: Gold for legendary flags

### Map Pins

- **Team Owned**: Color-coded by team
- **Neutral**: Gray
- **Capturable**: Pulsing animation when within range
- **Legendary**: Gold with special icon

## 📍 Location Services

### Permission Handling

App requests location permissions on first launch:

1. **When In Use**: For map display
2. **Always**: For background notifications (optional)

### GPS Proximity Detection

- Checks distance to flags every 5 seconds
- Enables capture button when within 30m
- Visual feedback (pulsing pin) when in range
- Background location updates for notifications

### Privacy

- Location only used for gameplay
- Not shared with third parties
- User can revoke permissions anytime

## 🔔 Push Notifications

### Setup

1. **Developer Portal**: Create APNs certificate
2. **Xcode**: Enable Push Notifications capability
3. **Backend**: Configure APNs tokens

### Notification Types

- **Flag Under Attack**: "Your flag at [location] is under attack!"
- **Flag Captured**: "Team Titans captured [location]!"
- **Level Up**: "Congratulations! You reached Level 10!"
- **Legendary Flag**: "A legendary flag appeared nearby!"

### Implementation

```swift
// Request permission
NotificationService.shared.requestAuthorization()

// Register device token
NotificationService.shared.registerDeviceToken(token)

// Handle notifications
func userNotificationCenter(_ center: UNUserNotificationCenter, 
                          didReceive response: UNNotificationResponse) {
    // Navigate to flag or event
}
```

## 🧪 Testing

### Simulator Testing

**Note**: Simulator cannot test:
- Actual GPS movement (use simulated location)
- Push notifications (test on device)
- Background location updates

**To simulate location:**
1. Run app in simulator
2. Debug → Simulate Location → Custom Location
3. Enter coordinates (e.g., San Francisco: 37.7749, -122.4194)

### Device Testing

1. Connect iPhone via USB
2. Trust computer on device
3. Select device in Xcode
4. Build and run
5. Walk near test flags to verify proximity detection

### Backend Testing

Ensure backend is running:

```bash
cd ~/Projects/ctf-game/backend
npm run dev
```

Check health endpoint:
```bash
curl http://localhost:3000/health
```

## 🚢 Deployment

### TestFlight Beta

1. **Archive App**:
   - Product → Archive
   - Wait for build to complete

2. **Upload to App Store Connect**:
   - Distribute App → App Store Connect
   - Select team and upload

3. **Configure TestFlight**:
   - Add beta testers
   - Provide test notes
   - Submit for beta review

4. **Distribute**:
   - Share TestFlight link with beta testers
   - Collect feedback

### App Store Release

1. **Prepare Metadata**:
   - App name: "CTF Game"
   - Description: (see below)
   - Screenshots: (generate from simulator)
   - Keywords: "capture flag, location game, team game"
   - Category: Games → Strategy

2. **App Review Information**:
   - Demo account credentials
   - Test locations with flags
   - Explanation of location usage

3. **Submit for Review**:
   - Submit via App Store Connect
   - Typical review time: 1-3 days

### App Description (Template)

```
🚩 CTF Game - Nationwide Capture The Flag

Turn your city into a massive real-world game! Capture flags, defend territory, and compete with teams nationwide.

🎮 GAMEPLAY
• Choose your team: Titans, Guardians, or Phantoms
• Explore your city to find and capture flags
• Deploy defenders to protect your captures
• Attack enemy flags and break through defenses
• Climb the leaderboards and prove your team's dominance

🗺️ EXPLORE YOUR CITY
• Flags appear at landmarks, parks, and interesting locations
• Real-time map shows all nearby flags
• Color-coded by team ownership
• Legendary flags at major monuments

⚔️ STRATEGIC DEPTH
• Deploy different defender types with unique abilities
• Coordinate with teammates for major captures
• Balance offense and defense for maximum points
• Earn XP to level up and unlock powerful defenders

🏆 COMPETE NATIONALLY
• Global leaderboards
• City and state rankings
• Team wars for exclusive rewards
• Seasonal events and limited-time flags

📍 REQUIRES LOCATION SERVICES
Location is used only for gameplay and is not shared with third parties.

Join thousands of players nationwide in the ultimate location-based strategy game!
```

## 🛠️ Development Tips

### Hot Reload

SwiftUI supports live previews:

```swift
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(MapViewModel())
    }
}
```

Press `Option + Cmd + P` to refresh preview.

### Debugging

```swift
// Logger utility
Logger.debug("Map loaded with \(flags.count) flags")
Logger.error("API call failed: \(error)")
```

View logs in Xcode console or Console.app.

### Common Issues

**"Location Services Disabled"**
- Enable in Settings → Privacy → Location Services

**"Network Request Failed"**
- Check backend is running
- Verify API URL in APIService.swift
- Check device/simulator has internet

**"Token Expired"**
- Logout and login again
- Check JWT expiration in backend

**"Map Not Loading"**
- Verify MapKit entitlement
- Check location permissions granted

## 🔐 Security

### Token Storage

JWT tokens stored securely in Keychain (not UserDefaults):

```swift
KeychainService.shared.save(token: token, for: .authToken)
let token = KeychainService.shared.load(for: .authToken)
```

### API Security

- HTTPS only in production
- Certificate pinning (optional, for high security)
- API calls require valid JWT token
- Sensitive data never logged

### Location Privacy

- Location only sent during gameplay actions
- Not continuously uploaded
- User can disable background location
- Clear privacy policy in app

## 📊 Analytics (Future)

Recommended events to track:

- App opens
- Team selection
- Flag captures
- Battles won/lost
- Time spent on map
- Distance traveled
- Retention metrics

Suggested tools:
- Firebase Analytics
- Amplitude
- Mixpanel

## 🐛 Known Issues

- [ ] Simulator cannot test actual GPS movement
- [ ] Background location uses battery (optimize in v2)
- [ ] WebSocket reconnection delay on network switch
- [ ] Map pins can overlap in dense areas (need clustering)

## 🚀 Future Enhancements

### Planned Features
- [ ] AR flag visualization (ARKit integration)
- [ ] In-app chat (team communication)
- [ ] Friend system (add players, private teams)
- [ ] Achievements and badges
- [ ] Battle animations
- [ ] Sound effects and haptics
- [ ] Apple Watch companion app
- [ ] Widget for nearby flags
- [ ] Offline mode improvements

### Optimization
- [ ] Map pin clustering
- [ ] Image caching for user avatars
- [ ] Reduce API calls (batch requests)
- [ ] Optimize battery usage
- [ ] Reduce app size

## 📝 Contributing

This is Matt's MVP. If you're working on enhancements:

1. Create feature branch: `git checkout -b feature/amazing-feature`
2. Follow SwiftUI best practices
3. Add preview providers for views
4. Document new ViewModels
5. Test on device (not just simulator)
6. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Credits

- **Game Design**: Based on Rabbit's research (see RABBIT_RESEARCH.md)
- **Backend**: Node.js API (see backend/README.md)
- **iOS Development**: SwiftUI + MapKit
- **Inspiration**: Pokémon GO, Ingress, classic CTF games

## 📞 Support

Questions or issues?

1. Check this README first
2. Review backend README for API issues
3. Check Xcode console for error logs
4. Open issue on GitHub
5. Contact Matt

---

**Built with ❤️ for Matt's CTF Game**

Good luck capturing flags! 🚩
