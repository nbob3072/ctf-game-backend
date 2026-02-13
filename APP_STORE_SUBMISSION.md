# App Store Submission Guide

## Status: TestFlight Upload Complete ✅
**Build:** CTFGame 1.0 (1)  
**Upload Date:** February 7, 2026

---

## 📋 Remaining Tasks

### 1. Host Legal Pages (5 minutes) 🔴 CRITICAL
**Why:** Apple requires publicly accessible Privacy Policy & Terms of Service URLs.

**Easiest Method - Netlify Drop:**
1. Go to https://app.netlify.com/drop
2. Drag and drop this folder: `~/Projects/ctf-game/legal-pages/`
3. Netlify will give you URLs like:
   - `https://random-name-123.netlify.app/privacy-policy.html`
   - `https://random-name-123.netlify.app/terms-of-service.html`
4. **Save these URLs** - you'll enter them in App Store Connect

**Alternative - GitHub Pages:**
- Create a public repo, upload the HTML files, enable GitHub Pages
- Takes ~10 minutes

---

### 2. App Store Connect Metadata (15-20 minutes)

Go to https://appstoreconnect.apple.com

#### App Name (30 characters max)
**Recommended:** `CTF Game` or `Capture The Flag`

#### Subtitle (30 characters)
**Options:**
- `Real-World Territory Game`
- `GPS Team Competition`
- `Capture Flags Worldwide`

#### Description (4,000 characters max)
```
Capture The Flag brings the classic game into the real world! Join one of three teams—Titans, Guardians, or Phantoms—and compete to capture virtual flags at real locations around your city.

HOW TO PLAY
• Choose your team
• Explore your city to find flags
• Capture flags by walking within range
• Earn XP and level up
• Compete on the global leaderboard

FEATURES
✓ Real-world GPS gameplay
✓ Three competitive teams
✓ Level up and earn XP
✓ Global leaderboards
✓ Hundreds of flag locations worldwide
✓ Safe, family-friendly competition

EXPLORE YOUR CITY
Flags are placed at parks, landmarks, popular spots, and hidden gems. Discover new places while competing with players worldwide!

JOIN A TEAM
• Titans - Orange/Red
• Guardians - Blue
• Phantoms - Green

Coordinate with teammates, track your progress, and climb the leaderboard. Every capture counts!

PRIVACY & SAFETY
Your location is only used during active gameplay to enable flag captures. We never share your data with third parties. Always stay safe—respect private property and local laws while playing.

Download now and start capturing!
```

#### Keywords (100 characters, comma-separated)
```
gps,game,capture,flag,territory,location,team,compete,explore,outdoor,maps,adventure,multiplayer
```

#### Primary Category
**Games → Adventure** or **Games → Strategy**

#### Age Rating
- Select **4+** (no objectionable content)
- Answer questionnaire: all "None" except:
  - "Unrestricted Web Access" → Yes (maps)

#### Support URL
Use your GitHub repo or create a simple page:
`https://github.com/yourusername/ctf-game` (set repo to public)

#### Privacy Policy URL
**Use the Netlify URL from Step 1**  
Example: `https://ctfgame-legal.netlify.app/privacy-policy.html`

---

### 3. App Store Screenshots (Required: 6.7" display)

**Required Sizes:**
- iPhone 6.7" (1290 x 2796) - **PRIORITY**
- iPhone 6.5" (1242 x 2688)
- iPhone 5.5" (1242 x 2208) - optional

**Screenshots to Include (in order):**
1. **Login Screen** - showing the clean interface
2. **Team Selection** - showing all 3 teams
3. **Map View** - with flags visible
4. **Leaderboard** - showing team competition
5. **Profile** - showing XP and level
6. **Flag Capture** - (if we have this screen)

**Screenshots already available on Desktop:**
- `login-filled.png`
- `team-selection.png`
- `map-with-flags.png` / `with-flags.png`
- Various other gameplay screens

**To resize for App Store:**
```bash
cd ~/Desktop
# Resize to 6.7" display (1290 x 2796)
sips -z 2796 1290 team-selection.png --out appstore-1.png
sips -z 2796 1290 map-with-flags.png --out appstore-2.png
# etc.
```

---

### 4. App Preview Video (Optional)
Not required, but can increase downloads by 20-30%.  
Can be added later after launch.

---

### 5. TestFlight Beta Testing (Recommended)

**Before submitting to App Store:**
1. In App Store Connect → TestFlight tab
2. Add external testers (friends' emails)
3. They download TestFlight app → get your build
4. Test gameplay in Princeton to catch bugs
5. Fix any issues → upload new build

**External testers can start testing immediately** (no App Store review needed for TestFlight).

---

### 6. Submit for Review

**Once metadata + screenshots + URLs are complete:**
1. App Store Connect → App Store tab
2. Click "Submit for Review"
3. Answer questionnaire:
   - Does your app use encryption? → **No** (standard HTTPS only)
   - Does your app use advertising identifier? → **No**
4. Click Submit

**Review Timeline:** 24-48 hours typically

---

## 📱 Build Info for App Store Connect

When filling out the form, you may need:
- **Bundle ID:** `com.matt.ctfgame`
- **Version:** `1.0`
- **Build:** `1`
- **Export Compliance:** Not using non-standard encryption

---

## 🚨 Common Rejection Reasons (Already Fixed)

✅ Account deletion - implemented  
✅ Privacy manifest - included  
✅ Username profanity filter - implemented  
✅ Privacy policy - created (needs hosting)  
✅ App icon - finalized  
✅ Face ID usage description - included  

---

## 📧 Next Steps Summary

**YOU NEED TO DO:**
1. ⬆️ **Host legal pages** (5 min - Netlify Drop)
2. 📝 **Fill in App Store Connect** (15 min - use text above)
3. 📸 **Upload screenshots** (10 min - resize from Desktop)
4. 🧪 **Test on TestFlight** (optional, recommended)
5. ✅ **Submit for Review**

**TOTAL TIME:** ~30-40 minutes

---

Let me know when you've hosted the legal pages and I can help with the next steps!
