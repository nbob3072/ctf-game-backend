# CTF Game iOS App - Setup Guide

## Quick Start (For Xcode)

### 1. Create New Xcode Project

Since we don't have a `.xcodeproj` file yet, you'll need to create one:

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Fill in:
   - Product Name: `CTFGame`
   - Team: Your development team
   - Organization Identifier: `com.yourcompany` (change this!)
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - Include Tests: Optional
5. Save to: `~/Projects/ctf-game/ios-app/`

### 2. Replace Default Files

Xcode will create a default project structure. Delete these files:
- `ContentView.swift`
- The default `CTFGameApp.swift`

Then copy all the files from this directory into your Xcode project:

```bash
# From Finder, drag and drop these folders into Xcode's project navigator:
- App/
- Models/
- ViewModels/
- Views/
- Services/
- Utilities/
```

Or use Xcode:
- Right-click project in navigator → Add Files to "CTFGame"
- Select all folders
- Make sure "Copy items if needed" is checked
- Add to target: CTFGame

### 3. Configure Project Settings

#### General Tab:
- **Bundle Identifier**: Change to your own (e.g., `com.yourname.ctfgame`)
- **Deployment Target**: iOS 16.0
- **Supported Destinations**: iPhone

#### Signing & Capabilities Tab:
1. **Signing**: Select your development team
2. **Add Capabilities**:
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes" → Check:
     - Location updates
     - Remote notifications
     - Background fetch

#### Build Settings:
- **iOS Deployment Target**: 16.0
- **Swift Language Version**: Swift 5

### 4. Configure Backend URLs

Update these files with your backend URL:

**APIService.swift** (line ~15):
```swift
private let baseURL = "http://YOUR_BACKEND_URL:3000"
```

**WebSocketService.swift** (line ~10):
```swift
private let wsURL = "ws://YOUR_BACKEND_URL:3001"
```

**For local development:**
```swift
// APIService.swift
private let baseURL = "http://localhost:3000"

// WebSocketService.swift
private let wsURL = "ws://localhost:3001"
```

**For simulator testing with local backend:**
```swift
// Use your Mac's IP address instead of localhost
private let baseURL = "http://192.168.1.XXX:3000"
private let wsURL = "ws://192.168.1.XXX:3001"
```

Find your Mac's IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 5. Info.plist Setup

The `Info.plist` file is already configured with:
- Location permissions
- Background modes
- App Transport Security (allows HTTP for development)

**⚠️ IMPORTANT**: Before App Store submission:
1. Remove `NSAllowsArbitraryLoads` from `NSAppTransportSecurity`
2. Use HTTPS only in production

### 6. Build and Run

1. Select iPhone simulator or connected device
2. Press `Cmd + R` to build and run
3. Allow location permissions when prompted
4. Create account or login

## Project Structure

```
CTFGame/
├── App/
│   ├── CTFGameApp.swift         # App entry point
│   └── AppState.swift            # Global state
├── Models/
│   ├── User.swift
│   ├── Team.swift
│   ├── Flag.swift
│   ├── Defender.swift
│   └── Capture.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── MapViewModel.swift
│   ├── LeaderboardViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Onboarding/
│   ├── Auth/
│   ├── Map/
│   ├── Leaderboard/
│   ├── Profile/
│   └── Components/
├── Services/
│   ├── APIService.swift
│   ├── WebSocketService.swift
│   ├── LocationService.swift
│   ├── KeychainService.swift
│   └── NotificationService.swift
├── Utilities/
│   ├── Logger.swift
│   ├── Constants.swift
│   └── Extensions.swift
└── Info.plist
```

## Testing

### Simulator Testing

**Note**: Simulator limitations:
- Cannot test actual GPS movement
- Cannot receive real push notifications
- Cannot test background location updates

**To simulate location:**
1. Run app in simulator
2. Debug menu → Location → Custom Location
3. Enter coordinates:
   - San Francisco: `37.7749, -122.4194`
   - New York: `40.7128, -74.0060`
   - Chicago: `41.8781, -87.6298`
   - Austin: `30.2672, -97.7431`

**To test flag capture:**
1. Run backend with seeded flags
2. Set simulator location near a flag
3. Open map view
4. Tap flag and attempt capture

### Device Testing

1. Connect iPhone via USB
2. Select device in Xcode
3. Trust computer on device if prompted
4. Build and run (Cmd + R)
5. Walk near actual flag locations to test GPS

### Backend Connection

Ensure backend is running:
```bash
cd ~/Projects/ctf-game/backend
npm run dev
```

Check health endpoint:
```bash
curl http://localhost:3000/health
```

Should return:
```json
{"status":"ok","timestamp":"..."}
```

## Common Issues

### "Failed to load flags: The Internet connection appears to be offline"
- **Fix**: Check backend URL in `APIService.swift`
- For simulator: Use Mac's IP address, not `localhost`
- Ensure backend is running
- Check firewall settings

### "Location Services Disabled"
- **Fix**: Settings → Privacy → Location Services
- Enable for simulator or device
- Enable for CTF Game app

### "Could not find module 'MapKit'"
- **Fix**: Add MapKit framework
- Project → Targets → CTFGame → Frameworks
- Click "+" → Add `MapKit.framework`

### Build errors about missing files
- **Fix**: Make sure all files are added to target
- Select file → File Inspector (right panel)
- Check "Target Membership" → CTFGame

### "Keychain error -34018"
- **Fix**: Enable Keychain Sharing capability
- Signing & Capabilities → "+ Capability" → Keychain Sharing

## Next Steps

1. **Test authentication**: Register and login
2. **Test map**: View nearby flags
3. **Test capture**: Walk to flag and capture
4. **Test WebSocket**: Verify real-time updates work
5. **Test leaderboards**: Check rankings display

## Production Checklist

Before releasing to App Store:

- [ ] Change bundle identifier to unique ID
- [ ] Update backend URLs to production (HTTPS)
- [ ] Remove `NSAllowsArbitraryLoads` from Info.plist
- [ ] Add App Store icons (1024x1024)
- [ ] Add launch screen assets
- [ ] Configure App Store Connect
- [ ] Set up push notification certificates
- [ ] Test on multiple devices
- [ ] Add crash reporting (e.g., Crashlytics)
- [ ] Add analytics (e.g., Firebase)
- [ ] Review privacy policy
- [ ] Prepare App Store screenshots
- [ ] Write app description

## Support

Questions? Check:
1. Main README.md
2. Backend README.md
3. Xcode console for error logs

Good luck! 🚩
