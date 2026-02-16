# CTF Game - Project Checklist
**Last Updated:** February 16, 2026

---

## 🔴 BLOCKING ISSUES

- [ ] **Fix database connection** (Railway credentials needed)
  - File: `backend/.env` needs valid DB credentials
  - Test: Run `node test-db.js` in backend directory
  - Impact: Nothing works without this

---

## 🟡 CRITICAL PATH (After database fix)

### Backend Verification
- [ ] `/health` endpoint returns 200 ✅ (already passing)
- [ ] `/api/teams` returns 3 teams
- [ ] `/api/auth/register` creates new user
- [ ] `/api/auth/login` authenticates user (with email)
- [ ] `/api/auth/login` authenticates user (with username)
- [ ] `/api/flags` returns nearby flags (requires auth + location)
- [ ] `/api/leaderboard` returns rankings

### Database Verification
- [ ] Teams table has 3 teams (Titans, Guardians, Phantoms)
- [ ] Flags table has location data
- [ ] Defender_types table has 4 defender types
- [ ] PostGIS extension is enabled
- [ ] All indexes are created

### iOS App Testing (Simulator)
- [ ] App builds without errors
- [ ] Onboarding screen displays
- [ ] "Get Started" navigates to login
- [ ] "Sign Up" opens team selection
- [ ] Team selection shows 3 teams with colors
- [ ] Registration form works
- [ ] User can register new account
- [ ] User can login with credentials
- [ ] Map view loads
- [ ] User location shows on map
- [ ] Flags display as pins on map
- [ ] Flag pins are color-coded by team
- [ ] Tapping flag shows detail view
- [ ] Profile view shows user stats
- [ ] Leaderboard displays rankings

### iOS App Testing (Physical Device)
- [ ] TestFlight build installs
- [ ] Location permission requested
- [ ] User can register
- [ ] User can login
- [ ] Map shows real location
- [ ] Nearby flags appear
- [ ] Walking toward flag updates distance
- [ ] Can capture flag within 30m radius
- [ ] Capture updates user XP and level
- [ ] Flag changes color after capture
- [ ] Profile reflects new stats
- [ ] Leaderboard updates with capture

---

## 🟢 NICE TO HAVE (Post-MVP)

### Backend Enhancements
- [ ] Add Redis for WebSocket real-time updates
- [ ] Set up monitoring (Sentry, LogRocket)
- [ ] Add rate limiting to more endpoints
- [ ] Implement flag respawn logic
- [ ] Add battle animations data
- [ ] Email verification for new accounts
- [ ] Password reset functionality (code exists, needs testing)

### iOS App Enhancements
- [ ] WebSocket integration for live updates
- [ ] Push notifications setup (APNs)
- [ ] Offline mode improvements
- [ ] Map pin clustering for dense areas
- [ ] AR flag visualization (ARKit)
- [ ] Sound effects
- [ ] Haptic feedback
- [ ] Apple Watch companion app
- [ ] Widget for nearby flags

### DevOps
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Automated tests
- [ ] Staging environment
- [ ] Database backups
- [ ] Monitoring dashboards
- [ ] Error tracking
- [ ] Performance monitoring

---

## 🏪 APP STORE SUBMISSION

### Required Before Submission
- [ ] Host privacy policy (Netlify Drop, 5 min)
  - File ready: `legal-pages/privacy-policy.html`
  - Upload to Netlify and get URL
- [ ] Host terms of service
  - File ready: `legal-pages/terms-of-service.html`
  - Upload to Netlify and get URL
- [ ] Create App Store screenshots (6.7" display)
  - Use simulator to capture screens
  - Resize to 1290 x 2796
  - Upload 4-5 screenshots
- [ ] Fill out App Store Connect metadata
  - App name: "CTF Game"
  - Subtitle: "Real-World Territory Game"
  - Description: (template in APP_STORE_SUBMISSION.md)
  - Keywords: "gps,game,capture,flag,territory..."
  - Category: Games → Strategy or Adventure

### TestFlight Beta Testing (Optional)
- [ ] Add external testers
- [ ] Send TestFlight invitations
- [ ] Collect feedback
- [ ] Fix critical bugs
- [ ] Upload new build if needed

### Final Submission
- [ ] All metadata complete
- [ ] Screenshots uploaded
- [ ] Legal pages URLs added
- [ ] Demo account provided (for reviewer)
- [ ] Explanation of location usage
- [ ] Submit for review
- [ ] Wait 24-48 hours for review

---

## 📊 PROJECT METRICS

### Code Status
- **Backend:** ✅ Complete and deployed
- **iOS App:** ✅ Complete and in TestFlight
- **Database Schema:** ✅ Complete
- **API Documentation:** ✅ Complete
- **iOS Documentation:** ✅ Complete

### Technical Debt
- Multiple .env files (minor)
- No automated tests (medium)
- No CI/CD (medium)
- No error monitoring (medium)
- Hardcoded test data in docs (low)

### Completion Estimate
- **Core Functionality:** 95% (blocked by DB connection)
- **Polish & UX:** 90%
- **Documentation:** 100%
- **Production Ready:** 85% (needs testing)

---

## 🎯 MILESTONES

### ✅ Completed
- [x] Backend architecture designed
- [x] Database schema created
- [x] API endpoints implemented
- [x] iOS app designed and built
- [x] Railway deployment configured
- [x] TestFlight build uploaded
- [x] Documentation written
- [x] Navigation issues fixed
- [x] Security features added (biometric, keychain)
- [x] Location services integrated

### 🔄 In Progress
- [ ] Database connection (waiting for credentials)
- [ ] End-to-end testing
- [ ] Bug fixes from testing

### 📅 Upcoming
- [ ] TestFlight beta testing
- [ ] App Store submission prep
- [ ] Initial launch
- [ ] User feedback collection
- [ ] v2 planning

---

## 🚀 LAUNCH CHECKLIST

### Week 1: Fix & Test
- [ ] Fix database connection
- [ ] Verify all API endpoints
- [ ] Test iOS app end-to-end
- [ ] Fix any bugs found

### Week 2: Beta Testing
- [ ] Recruit beta testers (5-10 people)
- [ ] Distribute TestFlight build
- [ ] Collect feedback
- [ ] Iterate on critical issues

### Week 3: App Store Prep
- [ ] Host legal pages
- [ ] Create screenshots
- [ ] Write App Store description
- [ ] Prepare demo account
- [ ] Submit for review

### Week 4: Launch
- [ ] App approved by Apple
- [ ] Set release date
- [ ] Announce launch
- [ ] Monitor for issues
- [ ] Respond to reviews

---

## 📞 CONTACTS & RESOURCES

### Platforms
- **Railway:** https://railway.app (backend hosting)
- **Supabase:** https://supabase.com (database)
- **TestFlight:** https://testflight.apple.com
- **App Store Connect:** https://appstoreconnect.apple.com

### Documentation
- **This Project:** https://github.com/nbob3072/ctf-game-backend
- **Railway Docs:** https://docs.railway.app
- **Supabase Docs:** https://supabase.com/docs
- **SwiftUI Docs:** https://developer.apple.com/documentation/swiftui

### Tools
- **Xcode:** iOS development
- **Postman/Insomnia:** API testing
- **jq:** JSON formatting in terminal
- **pgAdmin/Postico:** PostgreSQL GUI (optional)

---

**Next Action:** Fix database connection using `IMMEDIATE_FIXES.md`  
**Time Estimate:** 5-30 minutes  
**Impact:** Unblocks everything else
