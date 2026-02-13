# Privacy Compliance

## Privacy Manifest (PrivacyInfo.xcprivacy)

**Location:** `/ios-app/CTFGame/PrivacyInfo.xcprivacy`

**Required by Apple since iOS 17** - All apps must declare data collection practices.

### What We Declare:

#### 1. **Precise Location** (NSPrivacyCollectedDataTypePreciseLocation)
- **Purpose:** Gameplay
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Why:** Required for core gameplay - users capture flags based on real-world GPS location

#### 2. **Email Address** (NSPrivacyCollectedDataTypeEmailAddress)
- **Purpose:** App Functionality
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Why:** User account creation and authentication

#### 3. **User ID** (NSPrivacyCollectedDataTypeUserID)
- **Purpose:** App Functionality
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Why:** Identify user for leaderboards and game progress

#### 4. **Gameplay Content** (NSPrivacyCollectedDataTypeGameplayContent)
- **Purpose:** Gameplay
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Why:** Stores captured flags, XP, team affiliation

### No Third-Party Tracking
- `NSPrivacyTracking: false` - We do NOT track users across apps/websites
- `NSPrivacyTrackingDomains: []` - No third-party domains

### Accessed APIs
- **UserDefaults** (CA92.1) - Used for app preferences and settings only

## Info.plist Declarations

### Location Permissions
- `NSLocationWhenInUseUsageDescription` - Explains why we need location
- `NSFaceIDUsageDescription` - Explains Face ID/Touch ID usage

## App Store Privacy Nutrition Labels

When submitting to App Store, you'll need to fill out the privacy questionnaire:

### Data Linked to User:
- [x] Location (Precise)
- [x] Email Address  
- [x] User ID
- [x] Gameplay Content (captures, XP, team)

### Data Used to Track You:
- [ ] None

### Location Usage:
- **Purpose:** Gameplay - capture flags at real-world locations
- **Frequency:** While using app
- **Background:** No (only when app is active)

## Privacy Policy

**Required for App Store submission** - Create a privacy policy page that covers:

1. What data we collect (location, email, username)
2. How we use it (gameplay, authentication, leaderboards)
3. Who we share it with (nobody - first-party only)
4. User rights (account deletion available in-app)
5. Contact information

**Recommended URL structure:**
- `https://yourdomain.com/privacy-policy`
- Host on GitHub Pages, Notion, or your own site

## Account Deletion

✅ **Implemented** - Users can delete their account and all data via Profile → Delete Account

This satisfies Apple's requirement (mandatory since June 2022).

## Next Steps for Submission

1. ✅ Privacy Manifest created
2. ✅ Account deletion implemented
3. ✅ Info.plist permissions declared
4. ⏳ Create privacy policy webpage
5. ⏳ Fill out App Store privacy questionnaire during submission
6. ⏳ Ensure no third-party SDKs collect data without disclosure
