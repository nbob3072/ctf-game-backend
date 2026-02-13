# CTF Backend Deployment - Solutions for Tonight

**Status**: Railway CLI has authentication issues. Multiple working alternatives below.

**Current Setup**:
- ✅ Backend ready at ~/projects/ctf-game/backend
- ✅ Already using Supabase hosted PostgreSQL (db.qapziqecutkgvuqnfzsd.supabase.co)
- ✅ Dockerfile exists and ready
- ✅ Node.js Express app on port 3000, WebSocket on 3001

---

## 🚀 RECOMMENDED: Deploy with Render.com (15 minutes)

**Why Render**: Similar to Railway, free tier, dead simple, great for MVP.

### Step 1: Create Render Account
1. Go to https://render.com
2. Sign up with GitHub (fastest)
3. Click "New +" → "Web Service"

### Step 2: Connect Repository
**Option A - If code is on GitHub**:
- Select your repository
- Skip to Step 3

**Option B - Deploy without GitHub** (fastest for tonight):
```bash
cd ~/projects/ctf-game/backend

# Initialize git if not already
git init
git add .
git commit -m "Initial commit for deployment"

# Push to a new GitHub repo (or GitLab/Bitbucket)
# OR use Render's manual deploy (they'll give you a git remote)
```

### Step 3: Configure Web Service

**In Render Dashboard**:
- **Name**: `ctf-game-backend`
- **Region**: Oregon (US West) or closest to you
- **Branch**: `main`
- **Root Directory**: leave blank
- **Runtime**: Docker
- **Instance Type**: Free (can upgrade later)

### Step 4: Set Environment Variables

Click "Environment" tab and add these:

```bash
NODE_ENV=production
PORT=3000
WS_PORT=3001

# Database (already configured in Supabase)
DB_HOST=db.qapziqecutkgvuqnfzsd.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=nixqyG-qovnen-zijby2

# Redis (add free Redis on Render or use Upstash)
REDIS_HOST=<will add after Redis setup>
REDIS_PORT=6379

# JWT Secret (generate new one)
JWT_SECRET=<generate with: openssl rand -hex 32>
```

**Generate JWT Secret**:
```bash
openssl rand -hex 32
# Copy output and paste into Render
```

### Step 5: Add Redis (Optional but Recommended)

Two options:

**Option A - Render Redis (Paid, $7/month)**:
1. New + → Redis
2. Name: `ctf-redis`
3. Copy the Internal Redis URL
4. Add to environment variables

**Option B - Upstash Free Redis**:
1. Go to https://upstash.com
2. Create free account
3. Create Redis database
4. Copy endpoint and password
5. Add to Render environment variables:
   ```
   REDIS_HOST=<upstash-endpoint>
   REDIS_PORT=6379
   REDIS_PASSWORD=<upstash-password>
   ```

### Step 6: Deploy!

1. Click "Create Web Service"
2. Wait 3-5 minutes for build
3. Your app will be live at: `https://ctf-game-backend.onrender.com`

### Step 7: Test Deployment

```bash
# Health check
curl https://ctf-game-backend.onrender.com/health

# Test API
curl https://ctf-game-backend.onrender.com/api/health
```

---

## 🎯 ALTERNATIVE 1: Fly.io (Docker-first, Great Free Tier)

### Setup (10 minutes)

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login (works better than Railway)
fly auth login
# Opens browser, click "Authorize"

# Navigate to backend
cd ~/projects/ctf-game/backend

# Launch app (interactive setup)
fly launch

# Follow prompts:
# - App name: ctf-game-backend
# - Region: Choose closest
# - Postgres: NO (you have Supabase)
# - Redis: NO for now (can add Upstash)
# - Deploy now: YES
```

### Configure Environment Variables

```bash
# Set secrets (encrypted)
fly secrets set \
  NODE_ENV=production \
  DB_HOST=db.qapziqecutkgvuqnfzsd.supabase.co \
  DB_PORT=5432 \
  DB_NAME=postgres \
  DB_USER=postgres \
  DB_PASSWORD=nixqyG-qovnen-zijby2 \
  JWT_SECRET=$(openssl rand -hex 32) \
  WS_PORT=3001

# Deploy
fly deploy

# Get URL
fly status
# Your app: https://ctf-game-backend.fly.dev
```

### Fix WebSocket Port (if needed)

Create `fly.toml` if not exists:
```toml
app = "ctf-game-backend"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "3000"
  WS_PORT = "3001"

[[services]]
  internal_port = 3000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

# Add second service for WebSocket if needed
[[services]]
  internal_port = 3001
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 3001
```

---

## 🔧 ALTERNATIVE 2: One More Railway Attempt

**If you want to try Railway one more time** (I can assist):

### Manual Dashboard Deployment (Skip CLI)

1. **Go to https://railway.app**
2. **Sign up/Login** (GitHub fastest)
3. **New Project** → **Deploy from GitHub repo**
4. **OR use "Empty Project"**:
   - Click "Deploy from GitHub"
   - Connect your repo
   - Or create empty project and use Railway CLI later

5. **Add PostgreSQL** (or use existing Supabase):
   - Skip this, you have Supabase

6. **Add Redis** (optional):
   - Click "New" → Redis
   - Or use Upstash (free)

7. **Add Environment Variables**:
   ```
   NODE_ENV=production
   PORT=3000
   WS_PORT=3001
   DB_HOST=db.qapziqecutkgvuqnfzsd.supabase.co
   DB_PORT=5432
   DB_NAME=postgres
   DB_USER=postgres
   DB_PASSWORD=nixqyG-qovnen-zijby2
   JWT_SECRET=<generate new>
   ```

8. **Deploy**:
   - Railway auto-detects Dockerfile
   - Deploys automatically
   - Get URL from dashboard

---

## 🆘 QUICKEST OPTION: Supabase Edge Functions

**Since you're already on Supabase**, consider their edge functions:

### Pros:
- Already have account
- Integrated with your database
- Free tier generous

### Cons:
- Different deployment model (Deno, not Node.js)
- Would require code changes

**Not recommended for tonight** unless you're familiar with Deno.

---

## 📱 For iOS TestFlight Connection

Once deployed, update your iOS app config:

```swift
// Update base URL
let baseURL = "https://ctf-game-backend.onrender.com"  // or .fly.dev
let wsURL = "wss://ctf-game-backend.onrender.com/ws"
```

---

## 🎯 My Recommendation for Tonight

**Use Render.com**:
1. Simplest setup (15 min)
2. Free tier perfect for MVP/TestFlight
3. Auto-deploys on git push
4. Easy to add Redis later
5. Good logging/monitoring dashboard

**Or use Fly.io if you like CLI**:
1. Better free tier than Render
2. Docker-first (your Dockerfile works perfectly)
3. Login works reliably (unlike Railway)
4. 10 minute setup

---

## 🚨 Common Issues & Fixes

### Issue: "Cannot connect to database"
**Fix**: Check Supabase firewall rules
```bash
# Supabase Dashboard → Settings → Database → Connection Pooling
# Ensure "IPv4" connection allowed
```

### Issue: "WebSocket connection failed"
**Fix**: Most platforms auto-handle WebSocket upgrades on the main port
- Try connecting to `wss://your-app.onrender.com/ws` (same domain, different path)
- Or configure separate WebSocket service

### Issue: "App crashes on startup"
**Check logs**:
```bash
# Render: Dashboard → Logs tab
# Fly.io: fly logs
# Railway: Dashboard → Deployments → Logs
```

---

## 📊 Platform Comparison

| Platform | Setup Time | Free Tier | CLI Login | Docker Support |
|----------|-----------|-----------|-----------|----------------|
| **Render** | 15 min | ✅ Good | N/A (dashboard) | ✅ Excellent |
| **Fly.io** | 10 min | ✅ Best | ✅ Works | ✅ Excellent |
| **Railway** | Would be 10 min | ✅ Good | ❌ Broken | ✅ Excellent |
| Heroku | 15 min | ❌ No free tier | ✅ Works | ✅ Good |

---

## 🎬 Next Steps

**After deployment**:
1. ✅ Get public URL
2. ✅ Test all endpoints
3. ✅ Update iOS app config
4. ✅ Test TestFlight build
5. ✅ Monitor logs for issues

**Before going to production** (post-TestFlight):
- Add proper Redis
- Set up monitoring (Sentry, LogRocket)
- Configure custom domain
- Add rate limiting
- Set up CI/CD

---

**Need help?** Let me know which platform you choose and I'll guide you through it step-by-step.

**Want me to deploy it?** I can do it if you give me GitHub access or want to try Fly.io together.
