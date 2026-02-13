# Redis Setup Options

**Status**: Your backend uses Redis for leaderboards, flag states, and pub/sub. You'll need Redis for full functionality.

---

## Quick Options (Choose One)

### Option 1: Upstash (FREE - Recommended for MVP)

**Time**: 5 minutes | **Cost**: Free forever (up to 10K commands/day)

1. Go to https://console.upstash.com
2. Sign up with GitHub or email
3. Click "Create Database"
   - Name: `ctf-redis`
   - Type: Regional
   - Region: Choose closest to your backend (e.g., us-west-2)
   - Primary Region: Same as above
4. Click "Create"
5. Copy credentials from dashboard:
   - **Endpoint**: `us1-example-12345.upstash.io`
   - **Port**: `6379`
   - **Password**: (shown in dashboard)

6. Add to your deployment platform:

**For Render**:
```bash
REDIS_HOST=us1-example-12345.upstash.io
REDIS_PORT=6379
REDIS_PASSWORD=your_upstash_password
REDIS_TLS=true
```

**For Fly.io**:
```bash
fly secrets set \
  REDIS_HOST=us1-example-12345.upstash.io \
  REDIS_PORT=6379 \
  REDIS_PASSWORD=your_upstash_password \
  REDIS_TLS=true
```

**For Railway**:
- Add variables in dashboard under "Variables" tab

---

### Option 2: Platform-Provided Redis

#### Render Redis
**Cost**: $7/month (Starter plan)

1. In Render dashboard → "New +" → "Redis"
2. Name: `ctf-redis`
3. Plan: Starter
4. Region: Same as your web service
5. Create
6. Copy "Internal Redis URL"
7. Add to web service environment:
   ```
   REDIS_URL=<internal redis url>
   ```

**Pros**: Integrated, no extra configuration  
**Cons**: $7/month, minimum commitment

---

#### Railway Redis
**Cost**: Uses your $5 free credit

1. In project dashboard → "New Service" → "Database" → "Redis"
2. Name: `ctf-redis`
3. Deploy
4. Copy connection string from Variables tab
5. Add to backend service environment variables

**Pros**: Easy integration with Railway  
**Cons**: Uses your free credit faster

---

#### Fly.io Redis (via Upstash)
Fly.io partners with Upstash, so use Option 1 (Upstash Free) above.

---

## ⚠️ Update Your Backend Code for Redis TLS

If using Upstash (or any TLS Redis), update `src/redis/index.js`:

### Before:
```javascript
const client = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
});
```

### After:
```javascript
const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    tls: process.env.REDIS_TLS === 'true',
  },
  password: process.env.REDIS_PASSWORD,
});
```

---

## 🚀 Quick Deploy Without Redis (MVP Only)

If you want to deploy immediately and add Redis later, you can temporarily disable Redis features:

### Create `src/redis/mock.js`:
```javascript
// Mock Redis for initial deployment (remove after adding real Redis)
const mockClient = {
  connect: async () => console.log('⚠️  Using mock Redis'),
  on: () => {},
};

const mockHelpers = {
  setFlagState: async () => {},
  getFlagState: async () => null,
  updateLeaderboard: async () => {},
  getTopPlayers: async () => [],
  updateTeamScore: async () => {},
  getTopTeams: async () => [],
  cacheUserSession: async () => {},
  getUserSession: async () => null,
  publishFlagUpdate: async () => {},
  publishGlobalEvent: async () => {},
  checkRateLimit: async () => true,
};

module.exports = {
  client: mockClient,
  ...mockHelpers,
};
```

### Update imports:
```javascript
// In files that use Redis:
// const redis = require('./redis'); // OLD
const redis = require('./redis/mock'); // TEMPORARY - use mock
```

**WARNING**: This disables leaderboards and real-time features! Only use for initial deployment testing.

---

## 🎯 Recommended Approach

**For tonight's MVP deployment**:

1. ✅ Deploy backend WITHOUT Redis first
2. ✅ Get public URL, test basic API endpoints
3. ✅ Update iOS app, submit TestFlight build
4. ✅ While TestFlight is uploading, set up Upstash (free)
5. ✅ Add Upstash credentials to your deployment
6. ✅ Redeploy with Redis enabled
7. ✅ Test leaderboards and real-time features

**Total time**: 20 min deploy + 5 min Redis setup = 25 minutes

---

## 🧪 Test Redis Connection

After deploying with Redis:

```bash
# Get shell access to your app
# Render: Not easily accessible
# Fly.io: fly ssh console -a ctf-game-backend
# Railway: railway run bash

# Test Redis connection
node -e "
const redis = require('redis');
const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: process.env.REDIS_TLS === 'true'
  },
  password: process.env.REDIS_PASSWORD
});
client.connect().then(() => {
  console.log('✅ Redis connected!');
  client.quit();
}).catch(err => {
  console.error('❌ Redis error:', err);
});
"
```

Or check logs:
- **Render**: Dashboard → Logs tab
- **Fly.io**: `fly logs -a ctf-game-backend`
- **Railway**: Dashboard → Deployments → Logs

Look for: `✅ Connected to Redis`

---

## 📊 Which Option Should I Choose?

| Use Case | Recommendation |
|----------|----------------|
| **TestFlight MVP** | Upstash Free |
| **Production Launch** | Upstash Paid or Render Redis |
| **High Traffic** | Render Redis or dedicated Redis Cloud |
| **Just Testing** | Mock Redis (temporary) |

---

## 🆘 Troubleshooting

### "Redis connection timeout"
- Check REDIS_HOST is correct (no `redis://` prefix)
- Ensure REDIS_TLS=true for Upstash
- Verify firewall allows your deployment IP

### "WRONGPASS invalid username-password pair"
- Double-check REDIS_PASSWORD
- Make sure there are no extra spaces in env var

### "Redis is not defined" error
- Update redis client creation code (see TLS section above)
- Restart deployment after code changes

---

**Next Step**: Choose your Redis option, then continue with your deployment!
