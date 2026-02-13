# CTF Game iOS App - Complete File Structure

## Overview

This document lists all files created for the iOS app. Use this as a checklist when setting up the Xcode project.

## Files Created

### 📱 Root Level
```
ios-app/
├── README.md                    # Main documentation
├── SETUP.md                     # Setup instructions
├── LICENSE                      # MIT License
└── FILE_STRUCTURE.md           # This file
```

### 🎯 App Entry Point
```
CTFGame/
├── CTFGameApp.swift            # Main app entry (@main)
└── App/
    └── AppState.swift          # Global application state
```

### 📦 Models (Data Structures)
```
Models/
├── User.swift                  # User, UserStats, Auth models
├── Team.swift                  # Team, TeamStats models
├── Flag.swift                  # Flag, FlagType, FlagAnnotation
├── Defender.swift              # Defender, DefenderType models
└── Capture.swift               # Capture history models
```

### 🎮 ViewModels (Business Logic)
```
ViewModels/
├── AuthViewModel.swift         # Authentication logic
├── MapViewModel.swift          # Map and flag management
├── LeaderboardViewModel.swift  # Rankings logic
└── ProfileViewModel.swift      # User profile logic
```

### 🎨 Views (UI Components)

#### Onboarding Flow
```
Views/Onboarding/
├── OnboardingView.swift        # Welcome carousel
└── TeamSelectionView.swift     # Choose team screen
```

#### Authentication
```
Views/Auth/
├── LoginView.swift             # Login screen
└── RegisterView.swift          # Registration screen
```

#### Main Screens
```
Views/Map/
├── MapView.swift               # Main map interface with flags
└── FlagDetailView.swift        # Flag details and capture UI

Views/Leaderboard/
└── LeaderboardView.swift       # Global and team rankings

Views/Profile/
└── ProfileView.swift           # User stats and settings
```

#### Reusable Components
```
Views/Components/
└── LoadingView.swift           # Loading spinner overlay
```

### ⚙️ Services (Backend Integration)
```
Services/
├── APIService.swift            # REST API client
├── WebSocketService.swift      # Real-time updates
├── LocationService.swift       # GPS tracking
├── KeychainService.swift       # Secure token storage
└── NotificationService.swift   # Push notifications
```

### 🛠️ Utilities (Helpers)
```
Utilities/
├── Logger.swift                # Logging utility
├── Constants.swift             # App-wide constants
└── Extensions.swift            # Swift extensions
```

### ⚙️ Configuration
```
CTFGame/
└── Info.plist                  # App configuration and permissions
```

## Total Files: 28

## File Count by Category

- **Documentation**: 4 files (README, SETUP, LICENSE, FILE_STRUCTURE)
- **App Core**: 2 files (CTFGameApp, AppState)
- **Models**: 5 files
- **ViewModels**: 4 files
- **Views**: 9 files
- **Services**: 5 files
- **Utilities**: 3 files
- **Configuration**: 1 file

## Key Features Implemented

### ✅ User Flow
- [x] Onboarding with team selection
- [x] Login and registration
- [x] Persistent authentication (Keychain)

### ✅ Map & Gameplay
- [x] MapKit integration
- [x] Custom flag pins (color-coded)
- [x] GPS proximity detection
- [x] Flag detail view
- [x] Capture mechanics
- [x] Defender deployment
- [x] Real-time flag updates (WebSocket)

### ✅ Backend Integration
- [x] REST API client (Codable)
- [x] JWT token management
- [x] WebSocket real-time updates
- [x] Error handling
- [x] Automatic reconnection

### ✅ User Experience
- [x] Dark mode optimized
- [x] Loading states
- [x] Error messages
- [x] XP progress bars
- [x] Level display
- [x] Team color theming

### ✅ Additional Features
- [x] Global leaderboard
- [x] Team leaderboard
- [x] User profile with stats
- [x] Location services
- [x] Push notification setup
- [x] Offline mode handling
- [x] Comprehensive logging

## Architecture Pattern

**MVVM (Model-View-ViewModel)**
- Models: Pure data structures (Codable)
- Views: SwiftUI views (declarative UI)
- ViewModels: Business logic (@Published properties)
- Services: External integrations (API, WebSocket, etc.)

## Dependencies

**Zero external dependencies!**
- All functionality uses native iOS frameworks:
  - SwiftUI (UI)
  - MapKit (Maps)
  - CoreLocation (GPS)
  - Combine (Reactive programming)
  - URLSession (Networking)
  - Security (Keychain)
  - UserNotifications (Push)

## Next Steps

1. **Create Xcode project** (see SETUP.md)
2. **Add all files** to project
3. **Configure backend URLs** in APIService and WebSocketService
4. **Set up signing** with your Apple Developer account
5. **Test on simulator** with local backend
6. **Test on device** with real GPS

## Notes

- All files use Swift 5.7+ features
- Minimum iOS version: 16.0
- SwiftUI-only (no UIKit)
- Dark mode by default
- Ready for App Store submission (with configuration)

---

**Created for Matt's CTF Game MVP**  
Built with ❤️ using SwiftUI
