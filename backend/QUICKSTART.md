# Quick Start Guide

Get the CTF Game backend running locally in 5 minutes.

## Prerequisites

- Node.js 18+ installed ([Download](https://nodejs.org/))
- PostgreSQL 14+ with PostGIS ([Install guide](https://postgis.net/install/))
- Redis 7+ ([Install guide](https://redis.io/docs/getting-started/installation/))

## 🚀 5-Minute Setup

### 1. Install Dependencies

```bash
cd ~/Projects/ctf-game/backend
npm install
```

### 2. Start PostgreSQL and Redis

**macOS (Homebrew):**
```bash
brew services start postgresql
brew services start redis
```

**Ubuntu/Linux:**
```bash
sudo systemctl start postgresql
sudo systemctl start redis
```

**Windows:**
- Start PostgreSQL from Services
- Start Redis from Services

### 3. Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database and enable PostGIS
CREATE DATABASE ctf_game;
\c ctf_game
CREATE EXTENSION postgis;
\q
```

### 4. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your settings
nano .env  # or use your preferred editor
```

**Minimal .env for local development:**
```env
PORT=3000
WS_PORT=3001
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=ctf_game
DB_USER=postgres
DB_PASSWORD=postgres

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=dev_secret_change_in_production
```

### 5. Run Migrations & Seed Data

```bash
# Create database schema
npm run migrate

# Add sample data (3 teams, 10 flags in SF)
npm run seed
```

### 6. Start Server

```bash
# Development mode (auto-reload on changes)
npm run dev
```

**You should see:**
```
✅ Connected to Redis
🚀 CTF Game API server running on port 3000
   Environment: development
   Health check: http://localhost:3000/health
🔌 WebSocket server running on port 3001
✅ WebSocket server subscribed to Redis events
```

## ✅ Verify Installation

### Test Health Endpoint

```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp": "2026-02-06T22:30:00.000Z",
  "uptime": 12.345
}
```

### Test Registration

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "teamId": 1
  }'
```

**Expected response:**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "...",
    "username": "testuser",
    "email": "test@example.com",
    "teamId": 1,
    "level": 1,
    "xp": 0
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Test Flag Query

**Save your token from registration, then:**

```bash
TOKEN="your_token_here"

curl -X GET "http://localhost:3000/flags?latitude=37.7749&longitude=-122.4194&radius=10000" \
  -H "Authorization: Bearer $TOKEN"
```

**Expected response:**
```json
{
  "userLocation": {
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "flags": [
    {
      "id": "...",
      "name": "Golden Gate Park",
      "latitude": 37.7694,
      "longitude": -122.4862,
      "type": "common",
      "distanceMeters": 567,
      "ownerTeam": null,
      "hasDefender": false,
      "capturable": false
    }
  ],
  "count": 10
}
```

## 🎮 Test Gameplay

### 1. Register Two Players

**Player 1 (Titans):**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "player1",
    "email": "player1@test.com",
    "password": "password123",
    "teamId": 1
  }'

# Save TOKEN_1
```

**Player 2 (Guardians):**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "player2",
    "email": "player2@test.com",
    "password": "password123",
    "teamId": 2
  }'

# Save TOKEN_2
```

### 2. Capture a Flag

**Get flag ID from previous query, then:**

```bash
FLAG_ID="your_flag_id_here"
TOKEN="TOKEN_1"

curl -X POST "http://localhost:3000/flags/$FLAG_ID/capture" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7694,
    "longitude": -122.4862,
    "defenderTypeId": 1
  }'
```

**Response:**
```json
{
  "message": "Successfully captured Golden Gate Park!",
  "capture": {
    "flagId": "...",
    "flagName": "Golden Gate Park",
    "xpEarned": 100,
    "battleOccurred": false,
    "newLevel": 1,
    "totalXp": 100,
    "deployedDefender": {
      "name": "Scout Bot",
      "strength": 20,
      "expiresAt": "2026-02-06T23:30:00Z"
    }
  }
}
```

### 3. Check Leaderboard

```bash
curl http://localhost:3000/leaderboard?type=global
```

## 🔧 Common Issues

### "pg_hba.conf rejects connection"

**Fix:**
```bash
# Find pg_hba.conf
psql -U postgres -c "SHOW hba_file"

# Edit the file and add:
# host    all    all    127.0.0.1/32    trust

# Restart PostgreSQL
brew services restart postgresql  # macOS
sudo systemctl restart postgresql # Linux
```

### "Redis connection refused"

**Fix:**
```bash
# Check Redis is running
redis-cli ping  # Should return "PONG"

# If not running, start it
brew services start redis  # macOS
sudo systemctl start redis # Linux
```

### "PostGIS extension not found"

**Fix:**
```bash
# Install PostGIS
brew install postgis  # macOS
sudo apt install postgis  # Ubuntu

# Enable in database
psql -U postgres -d ctf_game
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

### "Port 3000 already in use"

**Fix:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change port in .env
PORT=4000
```

## 🐳 Docker Alternative

**Prefer Docker? Use this instead:**

```bash
# Start everything (PostgreSQL + Redis + API)
docker-compose up -d

# Run migrations
docker-compose exec api npm run migrate
docker-compose exec api npm run seed

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

**No installation required!** Docker handles PostgreSQL, Redis, and the API.

## 📚 Next Steps

**After setup:**

1. **Read API Documentation:** [API.md](API.md)
2. **Explore Database Schema:** [src/db/schema.sql](src/db/schema.sql)
3. **Test WebSocket:** Use [websocketking.com](https://websocketking.com/) or write a simple client
4. **Add Custom Flags:** Insert your own flags in the database
5. **Build iOS App:** Connect to `http://localhost:3000`

## 🧪 Development Workflow

**Making changes:**

```bash
# 1. Make code changes
nano src/routes/flags.js

# 2. Server auto-reloads (if using npm run dev)

# 3. Test with cURL or Postman

# 4. Commit changes
git add .
git commit -m "Add feature X"
git push
```

**Database changes:**

```bash
# 1. Edit schema.sql
nano src/db/schema.sql

# 2. Drop and recreate database
psql -U postgres
DROP DATABASE ctf_game;
CREATE DATABASE ctf_game;
\c ctf_game
CREATE EXTENSION postgis;
\q

# 3. Re-run migrations
npm run migrate
npm run seed
```

## 📊 Monitoring During Development

**Watch logs:**
```bash
# API logs
npm run dev  # Built-in console logs

# PostgreSQL logs (macOS)
tail -f /usr/local/var/log/postgresql@14.log

# Redis logs (macOS)
tail -f /usr/local/var/log/redis.log
```

**Database queries:**
```bash
# Connect to database
psql -U postgres -d ctf_game

# Useful queries
SELECT * FROM users;
SELECT * FROM flags;
SELECT * FROM captures ORDER BY captured_at DESC LIMIT 10;
SELECT * FROM team_stats;

# Check PostGIS
SELECT PostGIS_Version();
```

**Redis monitoring:**
```bash
# Connect to Redis
redis-cli

# Monitor commands in real-time
MONITOR

# Check keys
KEYS *

# Get leaderboard
ZRANGE leaderboard:global 0 -1 WITHSCORES
```

## 🎯 Ready to Deploy?

Once everything works locally:

1. **Read Deployment Guide:** [DEPLOYMENT.md](DEPLOYMENT.md)
2. **Choose Platform:** AWS, Heroku, DigitalOcean
3. **Configure Production Environment**
4. **Run Load Tests**
5. **Launch!**

## 💬 Need Help?

- **Documentation:** Check [README.md](README.md)
- **API Reference:** See [API.md](API.md)
- **Architecture:** Read [STRUCTURE.md](STRUCTURE.md)
- **Issues:** Open a GitHub issue

---

**Happy hacking! 🚀**

Now go build that CTF game MVP and take over the world (one flag at a time).
