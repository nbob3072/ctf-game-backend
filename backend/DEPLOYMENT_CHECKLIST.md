# 🚀 Deployment Checklist - Tonight's Plan

**Goal**: Get CTF backend deployed with public URL for iOS TestFlight  
**Time**: 10:09 PM → Target: Live by 10:45 PM (35 minutes)

---

## Phase 1: Choose Platform (2 minutes)

Pick ONE:
- [ ] **Render** - Easiest, dashboard-based (recommended)
- [ ] **Fly.io** - Terminal-based, automated script
- [ ] **Railway** - Dashboard only (CLI broken)

**Decision**: ________________

---

## Phase 2: Deploy Backend (15 minutes)

### If using Render:
- [ ] Read `deploy-render.md`
- [ ] Push code to GitHub
- [ ] Sign up at render.com
- [ ] Create Web Service from GitHub repo
- [ ] Set environment variables (copy from `.env`)
- [ ] Generate JWT_SECRET: `openssl rand -hex 32`
- [ ] Click "Create Web Service"
- [ ] Wait for build (3-5 min)
- [ ] Note your URL: `https://__________________.onrender.com`

### If using Fly.io:
- [ ] Run: `cd ~/projects/ctf-game/backend`
- [ ] Run: `./deploy-fly.sh`
- [ ] Follow prompts
- [ ] Note your URL: `https://__________________.fly.dev`

### If using Railway:
- [ ] Go to railway.app
- [ ] Sign up with GitHub
- [ ] New Project → Deploy from GitHub
- [ ] Select `ctf-game-backend` repo
- [ ] Add environment variables in dashboard
- [ ] Deploy
- [ ] Note your URL: `https://__________________.up.railway.app`

---

## Phase 3: Test Deployment (5 minutes)

```bash
# Replace YOUR_URL with your actual deployment URL
export BACKEND_URL="https://YOUR_URL_HERE"

# Test health endpoint
curl $BACKEND_URL/health
# Expected: {"status":"ok"} or similar

# Test API
curl $BACKEND_URL/api/health

# If both work, continue! ✅
```

- [ ] Health endpoint works
- [ ] API endpoint works
- [ ] Check logs for any errors
- [ ] No database connection errors

---

## Phase 4: Setup Redis (Optional - 5 minutes)

**Can skip for initial testing, add later**

- [ ] Go to console.upstash.com
- [ ] Sign up with GitHub
- [ ] Create database → Regional → US West
- [ ] Copy credentials (host, port, password)
- [ ] Add to deployment platform:
  - `REDIS_HOST=_______________`
  - `REDIS_PORT=6379`
  - `REDIS_PASSWORD=_______________`
  - `REDIS_TLS=true`
- [ ] Redeploy (auto-triggers on env change)
- [ ] Check logs for "Connected to Redis"

**OR Skip for MVP**:
- [ ] Deploy without Redis (leaderboards won't work)
- [ ] Add Redis tomorrow after TestFlight upload

---

## Phase 5: Update iOS App (5 minutes)

Update these values in your iOS project:

```swift
// Find and update in your Config.swift or API.swift file
let apiBaseURL = "https://YOUR_BACKEND_URL"
let websocketURL = "wss://YOUR_BACKEND_URL"
```

- [ ] Updated `apiBaseURL`
- [ ] Updated `websocketURL`
- [ ] Build successful
- [ ] Test on simulator
- [ ] Test basic API call (register/login)

---

## Phase 6: TestFlight Submission (10-15 minutes)

- [ ] Archive build in Xcode
- [ ] Upload to App Store Connect
- [ ] Fill in "What to Test" notes
- [ ] Submit for TestFlight review
- [ ] Add internal testers
- [ ] Wait for processing (10-30 min usually)

---

## 🎯 Success Criteria

### Minimum (MVP):
- [x] Backend deployed with public URL
- [x] Health check returns 200
- [x] Database queries work (Supabase connection)
- [x] iOS app can connect to API
- [x] TestFlight build uploaded

### Nice to Have:
- [ ] Redis connected (leaderboards work)
- [ ] WebSocket connections work
- [ ] Rate limiting enabled
- [ ] Logs monitoring set up

---

## 📱 URLs & Credentials

**Backend URL**: ___________________________________

**Redis** (if configured):
- Host: ___________________________________
- Port: 6379
- Password: ___________________________________

**Platform Dashboard**:
- URL: ___________________________________
- Email: ___________________________________

---

## 🆘 If Something Goes Wrong

### Build fails:
1. Check logs in platform dashboard
2. Look for missing env variables
3. Verify Dockerfile syntax
4. Check `package.json` has `"start": "node src/server.js"`

### Database connection fails:
1. Check Supabase is not paused/sleeping
2. Verify DB_HOST, DB_USER, DB_PASSWORD are correct
3. Check Supabase allows connections from deployment platform
4. Look for SSL/TLS errors (add `?ssl=true` to connection string if needed)

### App deployed but crashes:
1. Check logs immediately
2. Look for "Cannot find module" errors
3. Verify all dependencies in `package.json`
4. Check PORT env variable is set

### iOS app can't connect:
1. Test backend URL in browser
2. Check CORS settings in backend
3. Verify URL has `https://` (not `http://`)
4. Check for SSL certificate errors

---

## ⏱️ Timeline

| Time | Task | Duration |
|------|------|----------|
| 10:09 PM | Choose platform | 2 min |
| 10:11 PM | Deploy backend | 15 min |
| 10:26 PM | Test & verify | 5 min |
| 10:31 PM | (Optional) Setup Redis | 5 min |
| 10:36 PM | Update iOS app | 5 min |
| 10:41 PM | TestFlight upload | 15 min |
| **10:56 PM** | **DONE!** | ✅ |

---

## 📝 Notes & Issues

Use this space to track problems, solutions, URLs:

```
[10:__ PM] Started deployment with: __________

[10:__ PM] Issue: ___________________________
          Solution: _________________________

[10:__ PM] Backend URL: ______________________

[10:__ PM] TestFlight submitted! 🎉
```

---

**You got this! Let's ship it! 🚀**
