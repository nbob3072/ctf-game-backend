# CTF Game - Xcode Setup Walkthrough

**Backend is already running!** ✅  
**Files are ready at:** `~/Projects/ctf-game/ios-app/` ✅  
**Backend URLs updated:** `192.168.9.206:3000` ✅

---

## Step 1: Create New Xcode Project

1. **Open Xcode** (from Applications or Spotlight)

2. **Click "Create New Project"** or **File → New → Project**

3. **Choose template:**
   ```
   ┌─────────────────────────────────────┐
   │  iOS  │ macOS │ watchOS │ tvOS     │
   ├─────────────────────────────────────┤
   │                                     │
   │   [📱 App] ← SELECT THIS            │
   │   Game                              │
   │   Augmented Reality App             │
   │   Document App                      │
   │   ...                               │
   └─────────────────────────────────────┘
   ```
   - Select **iOS** tab at the top
   - Click **App**
   - Click **Next**

---

## Step 2: Configure Project

Fill in these fields:

```
┌─────────────────────────────────────────────┐
│ Product Name: CTFGame                       │
│ Team: [Select your Apple ID team]          │
│ Organization Identifier: com.yourname      │
│ Bundle Identifier: com.yourname.CTFGame    │
│ Interface: SwiftUI ← IMPORTANT             │
│ Language: Swift                            │
│ Storage: None                              │
│ [ ] Include Tests (optional)               │
└─────────────────────────────────────────────┘
```

**Click Next**

---

## Step 3: Choose Save Location

```
Save As: CTFGame
Where: Projects/ctf-game/ios-app/

┌─────────────────────────────────────────────┐
│ Projects/                                   │
│   └─ ctf-game/                             │
│       ├─ backend/                          │
│       └─ ios-app/ ← SAVE HERE              │
└─────────────────────────────────────────────┘
```

**Click Create**

⚠️ **IMPORTANT:** Xcode will create a NEW folder called `CTFGame` inside `ios-app/`, so your path will be:
```
~/Projects/ctf-game/ios-app/CTFGame/
```

---

## Step 4: Close Default Project

Xcode creates default files we don't need. **Close Xcode** for now.

---

## Step 5: Move Our Files Into Xcode Project

Open **Terminal** and run:

```bash
# Navigate to the new Xcode project
cd ~/Projects/ctf-game/ios-app/CTFGame/

# Remove default files
rm ContentView.swift
rm CTFGameApp.swift

# Copy our complete app into the Xcode project
cp -R ../CTFGame/* .

# Verify files are there
ls -la
```

You should see:
```
App/
Models/
ViewModels/
Views/
Services/
Utilities/
Info.plist
```

---

## Step 6: Re-open in Xcode

```bash
open ~/Projects/ctf-game/ios-app/CTFGame/CTFGame.xcodeproj
```

Or: File → Open → Navigate to `CTFGame.xcodeproj`

---

## Step 7: Add Files to Xcode

In Xcode, the **left sidebar** (Project Navigator) shows your files:

```
┌─────────────────────────────────────┐
│ 📁 CTFGame                          │
│   📄 CTFGameApp.swift ← DELETE THIS │
│   📄 ContentView.swift ← DELETE THIS│
│   📁 Assets.xcassets                │
│   📄 Info.plist                     │
│   📁 Preview Content                │
└─────────────────────────────────────┘
```

**Right-click `CTFGame` folder → Delete** (Move to Trash):
- `CTFGameApp.swift` (the default one)
- `ContentView.swift`

**Right-click `CTFGame` folder → Add Files to "CTFGame"...**

Navigate to: `~/Projects/ctf-game/ios-app/CTFGame/`

**Select ALL these folders** (hold Cmd to multi-select):
```
✅ App/
✅ Models/
✅ ViewModels/
✅ Views/
✅ Services/
✅ Utilities/
```

**Options at bottom:**
```
☑️ Copy items if needed
☑️ Create groups (not folder references)
☑️ Add to targets: CTFGame
```

**Click Add**

---

## Step 8: Project Navigator Should Look Like This

```
┌─────────────────────────────────────┐
│ 📁 CTFGame                          │
│   📁 App                            │
│     📄 CTFGameApp.swift             │
│     📄 AppState.swift               │
│   📁 Models                         │
│     📄 User.swift                   │
│     📄 Team.swift                   │
│     📄 Flag.swift                   │
│     📄 Defender.swift               │
│     📄 Capture.swift                │
│   📁 ViewModels                     │
│     📄 AuthViewModel.swift          │
│     📄 MapViewModel.swift           │
│     📄 LeaderboardViewModel.swift   │
│     📄 ProfileViewModel.swift       │
│   📁 Views                          │
│     📁 Onboarding/                  │
│     📁 Auth/                        │
│     📁 Map/                         │
│     📁 Leaderboard/                 │
│     📁 Profile/                     │
│     📁 Components/                  │
│   📁 Services                       │
│     📄 APIService.swift             │
│     📄 WebSocketService.swift       │
│     📄 LocationService.swift        │
│     📄 KeychainService.swift        │
│     📄 NotificationService.swift    │
│   📁 Utilities                      │
│     📄 Logger.swift                 │
│     📄 Constants.swift              │
│     📄 Extensions.swift             │
│   📁 Assets.xcassets                │
│   📄 Info.plist                     │
│   📁 Preview Content                │
└─────────────────────────────────────┘
```

---

## Step 9: Add Required Capabilities

**Click `CTFGame` at the top of Project Navigator**

Select **Signing & Capabilities** tab

### Add Capability #1: Background Modes
1. Click **+ Capability** (top left)
2. Search "Background"
3. Double-click **Background Modes**
4. Check these boxes:
   ```
   ☑️ Location updates
   ☑️ Remote notifications
   ☑️ Background fetch
   ```

### Add Capability #2: Push Notifications
1. Click **+ Capability** again
2. Search "Push"
3. Double-click **Push Notifications**

---

## Step 10: Configure Signing

Still in **Signing & Capabilities** tab:

```
┌────────────────────────────────────────┐
│ Signing (Debug)                        │
│ ☑️ Automatically manage signing        │
│ Team: [Select your Apple ID]          │
│ Bundle Identifier: com.yourname.CTFGame│
│ Signing Certificate: Apple Development │
│ Provisioning Profile: Xcode Managed    │
└────────────────────────────────────────┘
```

If you see **errors** about bundle identifier:
- Change `com.yourname.CTFGame` to something unique (e.g., `com.matt.ctf2025`)

---

## Step 11: Set Deployment Target

Click **General** tab (next to Signing & Capabilities)

```
┌────────────────────────────────────────┐
│ Deployment Info                        │
│ iOS: 16.0 ← Make sure this is 16.0    │
│ iPhone                                 │
└────────────────────────────────────────┘
```

---

## Step 12: Build the App

**Press Cmd + B** (or Product → Build)

**Wait for build to complete** (~30 seconds first time)

If you see errors about missing frameworks:
1. Click the error
2. Xcode will auto-fix most import issues

---

## Step 13: Select a Simulator

At the top of Xcode:

```
┌────────────────────────────────────┐
│ CTFGame  │  iPhone 15 Pro ▾       │
└────────────────────────────────────┘
```

Click **iPhone 15 Pro** → Select any iPhone model (14+)

---

## Step 14: Run the App!

**Press Cmd + R** (or click ▶️ Play button)

Simulator will launch (~20 seconds)

---

## Step 15: First Launch

You'll see the **Onboarding screen**:

```
┌─────────────────────────────────┐
│                                 │
│        🚩 CTF GAME 🚩          │
│                                 │
│  Capture flags. Dominate       │
│  your city. Become legend.     │
│                                 │
│     [Get Started] →            │
│                                 │
└─────────────────────────────────┘
```

Tap **Get Started** → Choose a team → Create account

---

## Step 16: Grant Location Permissions

Simulator will prompt:
```
"CTFGame" Would Like to Use Your Location
[Allow While Using App]  [Allow Once]  [Don't Allow]
```

**Tap: Allow While Using App**

---

## Step 17: Test Flag Capture

The map will load but show **no flags** because simulator location is random.

### Set Simulator Location:

In Xcode menu bar:
```
Debug → Location → Custom Location...
```

Enter coordinates for **San Francisco** (where many flags are):
```
Latitude: 37.7749
Longitude: -122.4194
```

Click **OK**

---

## Step 18: Verify Backend Connection

In Xcode **Console** (bottom panel), you should see:
```
✅ Connected to API: http://192.168.9.206:3000
🗺️ Loaded 19 flags in SF
```

If you see errors:
- Check backend is still running: `http://localhost:3000/health`
- Check Mac IP hasn't changed

---

## You're Done! 🎉

### What Works Now:
- ✅ Create account / Login
- ✅ View flags on map
- ✅ Capture flags (walk within 30m)
- ✅ Real-time updates via WebSocket
- ✅ Leaderboards
- ✅ Profile / team stats

### What to Test:
1. **Create account** → Pick a team
2. **Simulate location** near a flag (see Step 17)
3. **Tap flag** on map → Tap "Capture"
4. **Check leaderboard** → See your points
5. **Change location** → See new flags load

---

## Common Issues

### "Failed to connect to backend"
```bash
# Terminal: Check backend is running
curl http://localhost:3000/health

# Should return: {"status":"ok", ...}
```

### "No flags visible on map"
- Set simulator location (Debug → Location → Custom Location)
- Use coordinates from Step 17

### Build errors
- Clean build: **Cmd + Shift + K**
- Rebuild: **Cmd + B**

---

## Next Steps

1. **Test on real iPhone** (way better than simulator)
   - Connect iPhone via USB
   - Select device instead of simulator
   - Build and run (Cmd + R)
   - Walk to actual flag locations!

2. **Deploy backend to production**
   - Get a server (AWS, DigitalOcean, etc.)
   - Use HTTPS for production
   - Update Constants.swift with production URL

3. **Submit to App Store**
   - Add app icon (Assets.xcassets)
   - Add screenshots
   - Write description
   - Submit for review

---

**Need help?** Check:
- ~/Projects/ctf-game/ios-app/SETUP.md
- ~/Projects/ctf-game/backend/README.md
- Xcode console for error logs

**Backend running at:** http://192.168.9.206:3000  
**76 flags loaded** across NYC, Chicago, Austin, SF!

Good luck! 🚩🗺️
