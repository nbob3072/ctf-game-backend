# Quick Render.com Deployment - Copy/Paste Commands

## Step 1: Prepare Your Code

```bash
cd ~/projects/ctf-game/backend

# Make sure git is initialized
git init
git add .
git commit -m "Ready for deployment"
```

## Step 2: Create GitHub Repository (if needed)

**Option A - Using GitHub CLI** (if installed):
```bash
gh repo create ctf-game-backend --public --source=. --remote=origin
git push -u origin main
```

**Option B - Manual** (if no GitHub CLI):
1. Go to https://github.com/new
2. Name: `ctf-game-backend`
3. Public or Private (your choice)
4. Don't initialize with README
5. Copy the commands shown, run them:
```bash
git remote add origin https://github.com/YOUR_USERNAME/ctf-game-backend.git
git branch -M main
git push -u origin main
```

## Step 3: Deploy on Render

### 3.1: Sign Up
1. Go to https://render.com
2. Click "Get Started"
3. Sign up with GitHub (recommended) or email

### 3.2: Create Web Service
1. Click "New +" → "Web Service"
2. Connect your GitHub account (if not already)
3. Find and select `ctf-game-backend` repository
4. Click "Connect"

### 3.3: Configure Service

**Basic Settings**:
- **Name**: `ctf-game-backend`
- **Region**: Oregon (US West) or closest to you
- **Branch**: `main`
- **Root Directory**: *(leave blank)*
- **Runtime**: Docker
- **Instance Type**: Free

**Environment Variables** (click "Advanced" → "Add Environment Variable"):

```
NODE_ENV=production
PORT=3000
WS_PORT=3001
DB_HOST=db.qapziqecutkgvuqnfzsd.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=nixqyG-qovnen-zijby2
```

**Generate and add JWT_SECRET**:
```bash
# Run this locally to generate:
openssl rand -hex 32
```
Copy the output and add as environment variable in Render:
```
JWT_SECRET=<paste the generated value>
```

### 3.4: Deploy
1. Click "Create Web Service"
2. Wait 3-5 minutes for build
3. Watch the logs - it will show Docker build progress
4. Once complete, you'll see "Live" with a green dot

### 3.5: Get Your URL
Your app will be at: `https://ctf-game-backend.onrender.com`

## Step 4: Test Deployment

```bash
# Replace with your actual Render URL
RENDER_URL="https://ctf-game-backend.onrender.com"

# Test health endpoint
curl $RENDER_URL/health

# Expected response: {"status":"ok"} or similar

# Test API
curl $RENDER_URL/api/health

# If these work, your backend is live! 🎉
```

## Step 5: Add Redis (Optional - can do later)

### Option A: Upstash (Free Redis)

1. Go to https://console.upstash.com
2. Sign up (GitHub or email)
3. Click "Create Database"
4. Name: `ctf-redis`
5. Type: Regional
6. Region: Choose same as Render (us-west-2 for Oregon)
7. Click "Create"

8. Copy connection details:
   - Endpoint (e.g., `us1-working-firefly-12345.upstash.io`)
   - Port: `6379`
   - Password: `<shown in dashboard>`

9. Add to Render environment variables:
   ```
   REDIS_HOST=us1-working-firefly-12345.upstash.io
   REDIS_PORT=6379
   REDIS_PASSWORD=<your-upstash-password>
   ```

10. Render will automatically redeploy with new env vars

### Option B: Render Redis ($7/month)

1. In Render dashboard, click "New +" → "Redis"
2. Name: `ctf-redis`
3. Region: Same as your web service
4. Plan: Starter ($7/month)
5. Click "Create Redis"
6. Copy the "Internal Redis URL"
7. Add to your web service environment variables:
   ```
   REDIS_URL=<paste internal redis url>
   ```

## Step 6: Update iOS App

In your iOS app, update the base URL:

```swift
// Update this in your app config
let apiBaseURL = "https://ctf-game-backend.onrender.com"
let websocketURL = "wss://ctf-game-backend.onrender.com"
```

## Troubleshooting

### "Build failed" in Render logs
- Check that Dockerfile is in repository root
- Check Docker build logs for errors
- Make sure package.json exists

### "Application failed to respond"
- Check Render logs (Dashboard → Logs tab)
- Look for database connection errors
- Verify Supabase allows connections from Render IPs

### "WebSocket connection failed"
- Try using the same domain: `wss://your-app.onrender.com/ws`
- Check if your Express server has proper WebSocket upgrade handling
- Render automatically handles WebSocket upgrades

### Redis connection issues
- If using Upstash: Check TLS is enabled (add `REDIS_TLS=true`)
- Verify credentials are correct
- Check Redis logs in respective dashboard

## 🎉 Success Checklist

- [ ] Code pushed to GitHub
- [ ] Render web service created
- [ ] All environment variables configured
- [ ] Build completed successfully
- [ ] Health endpoint returns 200
- [ ] API endpoints accessible
- [ ] (Optional) Redis connected
- [ ] iOS app config updated with new URL
- [ ] TestFlight build connects successfully

---

**Estimated total time**: 15-20 minutes

**Render Free Tier Limits**:
- 750 hours/month (enough for 24/7 MVP)
- Spins down after 15 min of inactivity (cold starts ~30 sec)
- 512 MB RAM, 0.5 CPU

**To upgrade**: $7/month for always-on, 512MB RAM
