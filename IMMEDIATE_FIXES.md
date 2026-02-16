# CTF Game - Immediate Fixes Required
**Date:** February 16, 2026  
**Status:** Database connection issue blocking all API endpoints

---

## 🚨 Critical Issue: Database Connection

### Problem
The backend API is deployed and running on Railway, but:
- The `/api/teams` endpoint returns 500 error
- Local .env files have outdated/invalid Supabase hostnames
- Cannot test or verify database locally

### Root Cause
Railway deployment has correct credentials (health check passes), but we don't have access to:
1. The actual Supabase credentials Railway is using
2. OR the Supabase project may have been recreated with new credentials

---

## ✅ Quick Fix Option 1: Get Railway Credentials

### Steps:
1. Go to https://railway.app
2. Log in to your account
3. Open the "CTF Game Backend" project
4. Click on the service
5. Go to "Variables" tab
6. Look for these variables:
   ```
   DB_HOST=...
   DB_PORT=...
   DB_NAME=...
   DB_USER=...
   DB_PASSWORD=...
   ```
7. Copy these values to `~/projects/ctf-game/backend/.env`

8. Test locally:
   ```bash
   cd ~/projects/ctf-game/backend
   node test-db.js
   ```

### Expected Output:
```
✅ Database connected successfully
📋 Tables found:
  - teams
  - users
  - flags
🎯 Teams in database: 3
  1. Titans (#E74C3C)
  2. Guardians (#3498DB)
  3. Phantoms (#2ECC71)
```

---

## ✅ Quick Fix Option 2: Create New Supabase Project

### If the old Supabase project is gone:

1. **Create New Supabase Project**
   - Go to https://supabase.com
   - Create new project: "ctf-game-db"
   - Choose region closest to you
   - Wait 2-3 minutes for provisioning

2. **Get Connection Info**
   - Project Settings → Database
   - Copy "Connection string" (Direct connection)
   - Extract: host, port, database, user, password

3. **Apply Database Schema**
   ```bash
   cd ~/projects/ctf-game/backend
   
   # Update .env with new credentials
   vim .env  # or nano .env
   
   # Test connection
   node test-db.js
   
   # Apply schema
   node src/db/migrate.js
   
   # Seed data (teams, flags, defenders)
   node src/db/seed.js
   ```

4. **Update Railway Environment Variables**
   - Railway.app → Project → Variables
   - Update DB_HOST, DB_PASSWORD, etc.
   - Save (triggers redeploy)

5. **Test API**
   ```bash
   # Wait 2-3 minutes for Railway redeploy
   curl https://ctf-game-backend-production.up.railway.app/api/teams
   
   # Should return:
   # {
   #   "teams": [
   #     {"id": 1, "name": "Titans", "color": "#E74C3C", ...},
   #     ...
   #   ]
   # }
   ```

---

## ✅ Quick Fix Option 3: Use Railway PostgreSQL

### Add Database Directly on Railway:

1. **Railway Dashboard**
   - Open your project
   - Click "New" → "Database" → "Add PostgreSQL"
   - Wait for provisioning (2 min)

2. **Get Generated Credentials**
   - Click on the PostgreSQL service
   - Copy connection string
   - Or copy individual variables (PGHOST, PGPORT, etc.)

3. **Connect Backend to Database**
   - Variables tab on your backend service
   - Add reference variables:
     ```
     DB_HOST=${{Postgres.PGHOST}}
     DB_PORT=${{Postgres.PGPORT}}
     DB_NAME=${{Postgres.PGDATABASE}}
     DB_USER=${{Postgres.PGUSER}}
     DB_PASSWORD=${{Postgres.PGPASSWORD}}
     ```
   - Save (triggers redeploy)

4. **Initialize Database**
   ```bash
   # Update local .env with Railway PostgreSQL credentials
   cd ~/projects/ctf-game/backend
   
   # Apply schema
   node src/db/migrate.js
   
   # Seed data
   node src/db/seed.js
   ```

5. **Verify**
   ```bash
   curl https://ctf-game-backend-production.up.railway.app/api/teams
   ```

---

## 🧪 Testing Script

Save this as `~/projects/ctf-game/backend/test-api.sh`:

```bash
#!/bin/bash

# Test CTF Game Backend API
API_URL="https://ctf-game-backend-production.up.railway.app/api"

echo "Testing CTF Game Backend API..."
echo "================================"

echo -e "\n1. Health Check:"
curl -s "$API_URL/../health" | jq

echo -e "\n2. Get Teams:"
curl -s "$API_URL/teams" | jq

echo -e "\n3. Register Test User:"
curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser'$(date +%s)'",
    "email": "test'$(date +%s)'@example.com",
    "password": "password123",
    "teamId": 1
  }' | jq

echo -e "\n4. Login Test User:"
curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }' | jq

echo -e "\nDone!"
```

Make executable and run:
```bash
chmod +x ~/projects/ctf-game/backend/test-api.sh
~/projects/ctf-game/backend/test-api.sh
```

---

## 📋 Verification Checklist

After applying fix, verify:

- [ ] `node test-db.js` connects successfully
- [ ] Database has 3 teams (Titans, Guardians, Phantoms)
- [ ] Database has flags data (at least a few test flags)
- [ ] Database has defender_types data (4 types)
- [ ] `/api/teams` returns 200 with teams array
- [ ] `/api/auth/register` creates new user
- [ ] `/api/auth/login` authenticates user
- [ ] Railway logs show no database errors

---

## 🐛 Common Errors & Fixes

### Error: "ENOTFOUND db.something.supabase.co"
**Cause:** Invalid hostname  
**Fix:** Get correct credentials from Railway or create new Supabase project

### Error: "password authentication failed"
**Cause:** Wrong password  
**Fix:** Copy exact password from Supabase/Railway dashboard

### Error: "relation 'teams' does not exist"
**Cause:** Schema not applied  
**Fix:** Run `node src/db/migrate.js`

### Error: "Failed to fetch teams" (empty response)
**Cause:** No seed data  
**Fix:** Run `node src/db/seed.js`

### Error: "Cannot connect to database" (timeout)
**Cause:** Firewall or wrong host  
**Fix:** Check Supabase connection pooling settings, use "Direct connection" string

---

## 🎯 What to Do Right Now

**Pick ONE option based on your access:**

### If you have Railway access:
→ Use **Option 1** (get credentials from Railway)

### If Supabase project is gone:
→ Use **Option 2** (create new Supabase project)

### If you want simplest solution:
→ Use **Option 3** (add Railway PostgreSQL)

**Estimated time:** 15-30 minutes

---

## 📞 Need Help?

If you get stuck:
1. Run the commands
2. Copy any error messages
3. Share with developer
4. Include Railway project name and region

---

**After fixing database, the iOS app should work immediately!**
