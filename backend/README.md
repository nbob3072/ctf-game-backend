# CTF Game Backend API

Backend API for Matt's nationwide Capture The Flag (CTF) game MVP.

## 🎮 Features

- **User Authentication**: Register, login, JWT-based sessions
- **Team Management**: 3 factions (Titans, Guardians, Phantoms)
- **Flag System**: GPS-based flag capture with real-time updates
- **Defender Mechanics**: Deploy virtual defenders on captured flags
- **Real-time Updates**: WebSocket support for live gameplay
- **Leaderboards**: Global, team, and player rankings
- **Geospatial Queries**: PostGIS-powered proximity searches
- **Push Notifications**: Queue system for APNs/FCM integration

## 🛠️ Tech Stack

- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: PostgreSQL 14+ with PostGIS extension
- **Cache/Real-time**: Redis 7+
- **WebSocket**: ws library
- **Authentication**: JWT (jsonwebtoken)
- **Security**: bcryptjs, helmet, express-rate-limit

## 📋 Prerequisites

Before you begin, ensure you have:

- Node.js 18+ installed
- PostgreSQL 14+ with PostGIS extension
- Redis 7+ installed and running
- Git

### Installing PostgreSQL with PostGIS

**macOS (Homebrew):**
```bash
brew install postgresql postgis
brew services start postgresql
```

**Ubuntu/Debian:**
```bash
sudo apt-get install postgresql postgresql-contrib postgis
sudo systemctl start postgresql
```

**Create Database:**
```bash
psql -U postgres
CREATE DATABASE ctf_game;
\c ctf_game
CREATE EXTENSION postgis;
\q
```

### Installing Redis

**macOS:**
```bash
brew install redis
brew services start redis
```

**Ubuntu/Debian:**
```bash
sudo apt-get install redis-server
sudo systemctl start redis
```

## 🚀 Quick Start

### 1. Clone & Install

```bash
cd ~/Projects/ctf-game/backend
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and update values:

```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=ctf_game
DB_USER=postgres
DB_PASSWORD=your_password_here

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=your_super_secret_jwt_key_change_this_in_production

WS_PORT=3001
```

**⚠️ IMPORTANT:** Change `JWT_SECRET` to a strong random string in production!

### 3. Run Database Migrations

```bash
npm run migrate
```

This creates all tables, indexes, views, and functions.

### 4. Seed Database

```bash
npm run seed
```

This populates:
- 3 teams (Titans, Guardians, Phantoms)
- 4 defender types
- 10 sample flags in San Francisco

### 5. Start Server

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

The API will be available at:
- **HTTP API**: `http://localhost:3000`
- **WebSocket**: `ws://localhost:3001`
- **Health Check**: `http://localhost:3000/health`

## 📡 API Endpoints

### Authentication

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "username": "player1",
  "email": "player1@example.com",
  "password": "securepass123",
  "teamId": 1  // Optional: 1=Titans, 2=Guardians, 3=Phantoms
}

Response: 201 Created
{
  "message": "User registered successfully",
  "user": {
    "id": "uuid",
    "username": "player1",
    "email": "player1@example.com",
    "teamId": 1,
    "level": 1,
    "xp": 0
  },
  "token": "jwt_token_here"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "player1@example.com",
  "password": "securepass123"
}

Response: 200 OK
{
  "message": "Login successful",
  "user": { ... },
  "token": "jwt_token_here"
}
```

#### Logout
```http
POST /auth/logout
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Logged out successfully"
}
```

### Teams

#### Get All Teams
```http
GET /teams

Response: 200 OK
{
  "teams": [
    {
      "id": 1,
      "name": "Titans",
      "color": "#E74C3C",
      "description": "Strength through unity, aggressive expansion"
    },
    ...
  ]
}
```

#### Get Team Stats
```http
GET /teams/:id/stats

Response: 200 OK
{
  "team": {
    "id": 1,
    "name": "Titans",
    "color": "#E74C3C",
    "stats": {
      "memberCount": 42,
      "flagsControlled": 15,
      "totalCaptures": 237,
      "totalTeamXp": 45600,
      "avgLevel": 8.3
    },
    "topMembers": [...],
    "recentCaptures": [...]
  }
}
```

#### Join Team
```http
POST /teams/:id/join
Authorization: Bearer <token>

Response: 200 OK
{
  "message": "Successfully joined Titans!",
  "team": { ... }
}
```

### Flags

#### Get Nearby Flags
```http
GET /flags?latitude=37.7749&longitude=-122.4194&radius=1000
Authorization: Bearer <token>

Response: 200 OK
{
  "userLocation": {
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "flags": [
    {
      "id": "uuid",
      "name": "Golden Gate Park",
      "latitude": 37.7694,
      "longitude": -122.4862,
      "type": "common",
      "distanceMeters": 567,
      "ownerTeam": {
        "name": "Guardians",
        "color": "#3498DB"
      },
      "hasDefender": true,
      "capturable": false
    },
    ...
  ],
  "count": 5
}
```

#### Get Flag Details
```http
GET /flags/:id
Authorization: Bearer <token>

Response: 200 OK
{
  "flag": {
    "id": "uuid",
    "name": "Golden Gate Bridge",
    "latitude": 37.8199,
    "longitude": -122.4783,
    "type": "legendary",
    "totalCaptures": 142,
    "currentOwner": {
      "username": "player42",
      "team": {
        "name": "Titans",
        "color": "#E74C3C"
      }
    },
    "defender": {
      "name": "Guardian Titan",
      "strength": 80,
      "deployedBy": "player42",
      "expiresAt": "2026-02-06T18:30:00Z"
    },
    "recentCaptures": [...]
  }
}
```

#### Capture Flag
```http
POST /flags/:id/capture
Authorization: Bearer <token>
Content-Type: application/json

{
  "latitude": 37.8199,
  "longitude": -122.4783,
  "defenderTypeId": 2  // Optional: deploy defender after capture
}

Response: 200 OK
{
  "message": "Successfully captured Golden Gate Bridge!",
  "capture": {
    "flagId": "uuid",
    "flagName": "Golden Gate Bridge",
    "xpEarned": 150,
    "battleOccurred": true,
    "newLevel": 9,
    "totalXp": 8250,
    "deployedDefender": {
      "name": "Sentinel",
      "strength": 50,
      "expiresAt": "2026-02-06T20:00:00Z"
    }
  }
}
```

**Capture Validation:**
- User must be within 30 meters (configurable per flag)
- Cannot capture flag already owned by your team
- If defender present, 50% chance to break through (can be enhanced)
- Defeating defender grants +50 bonus XP

### Leaderboards

#### Get Global Leaderboard
```http
GET /leaderboard?limit=100&offset=0&type=global

Response: 200 OK
{
  "type": "global",
  "leaderboard": [
    {
      "rank": 1,
      "id": "uuid",
      "username": "topplayer",
      "teamName": "Titans",
      "teamColor": "#E74C3C",
      "level": 15,
      "xp": 25600,
      "captureCount": 312
    },
    ...
  ],
  "cached": true
}
```

#### Get Team Leaderboard
```http
GET /leaderboard?type=team

Response: 200 OK
{
  "type": "team",
  "leaderboard": [
    {
      "teamId": 1,
      "teamName": "Titans",
      "memberCount": 42,
      "flagsControlled": 18,
      "totalCaptures": 523,
      "totalTeamXp": 125000
    },
    ...
  ]
}
```

#### Get My Rank
```http
GET /leaderboard/me
Authorization: Bearer <token>

Response: 200 OK
{
  "user": {
    "rank": 47,
    "username": "player1",
    "level": 8,
    "xp": 6400
  },
  "nearby": [
    // Players ranked 42-52
  ]
}
```

## 🔌 WebSocket Real-Time Updates

Connect to WebSocket server for live gameplay events:

```javascript
const ws = new WebSocket('ws://localhost:3001?token=YOUR_JWT_TOKEN');

ws.onopen = () => {
  console.log('Connected to game server');
  
  // Subscribe to flag updates
  ws.send(JSON.stringify({
    type: 'subscribe_flag',
    flagId: 'flag-uuid-here'
  }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  switch (data.type) {
    case 'connected':
      console.log('WebSocket authenticated');
      break;
      
    case 'flag_update':
      console.log('Flag captured:', data.data);
      // Update UI in real-time
      break;
      
    case 'global_event':
      console.log('Global event:', data.event);
      break;
  }
};

// Ping-pong for connection health
setInterval(() => {
  ws.send(JSON.stringify({ type: 'ping' }));
}, 30000);
```

### WebSocket Events

**Client → Server:**
- `ping` - Keep-alive heartbeat
- `subscribe_flag` - Subscribe to flag updates
- `unsubscribe_flag` - Unsubscribe from flag

**Server → Client:**
- `connected` - Connection established
- `pong` - Heartbeat response
- `flag_update` - Flag captured/defended
- `global_event` - Worldwide events

## 🗄️ Database Schema

### Key Tables

- **users**: Player accounts, XP, levels, team affiliation
- **teams**: Factions (Titans, Guardians, Phantoms)
- **flags**: Physical flag locations with GPS coordinates
- **active_defenders**: Virtual defenders deployed on flags
- **captures**: Capture history for analytics
- **notifications**: Push notification queue

### Geospatial Queries

PostGIS enables efficient proximity searches:

```sql
-- Find flags within 1km of user location
SELECT * FROM get_nearby_flags(37.7749, -122.4194, 1000);

-- Calculate distance between two points
SELECT ST_Distance(
  ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326)::geography,
  ST_SetSRID(ST_MakePoint(-122.4862, 37.7694), 4326)::geography
);
```

## 🔐 Security Features

- **JWT Authentication**: Stateless, secure token-based auth
- **Password Hashing**: bcrypt with salt (10 rounds)
- **Rate Limiting**: 100 requests per 15 minutes on auth endpoints
- **Helmet.js**: Security headers (XSS, clickjacking protection)
- **CORS**: Configurable cross-origin policies
- **SQL Injection Protection**: Parameterized queries only

## 📊 Redis Caching Strategy

- **Leaderboards**: Sorted sets for O(log N) lookups
- **Flag State**: TTL-based caching (1 hour)
- **User Sessions**: Fast session validation
- **Pub/Sub**: Real-time event broadcasting

## 🚀 Deployment

### AWS Deployment (Recommended)

**1. Infrastructure Setup:**
- **EC2**: t3.medium instance (2 vCPU, 4GB RAM)
- **RDS**: PostgreSQL 14 with PostGIS
- **ElastiCache**: Redis cluster
- **ALB**: Application Load Balancer
- **CloudWatch**: Logging and monitoring

**2. Environment Variables:**
```bash
NODE_ENV=production
PORT=3000
DB_HOST=your-rds-endpoint.amazonaws.com
REDIS_HOST=your-elasticache-endpoint.amazonaws.com
JWT_SECRET=strong-random-secret-256-bits
```

**3. Process Management:**
```bash
# Install PM2 for process management
npm install -g pm2

# Start server
pm2 start src/server.js --name ctf-api

# Auto-restart on crash
pm2 startup
pm2 save
```

**4. Nginx Reverse Proxy:**
```nginx
server {
  listen 80;
  server_name api.ctfgame.com;

  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }

  location /ws {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
  }
}
```

### Heroku Deployment

```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login and create app
heroku login
heroku create ctf-game-api

# Add PostgreSQL and Redis
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set JWT_SECRET=your-secret
heroku config:set NODE_ENV=production

# Deploy
git push heroku main

# Run migrations
heroku run npm run migrate
heroku run npm run seed
```

## 🧪 Testing

### Manual Testing with cURL

**Register:**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testplayer",
    "email": "test@example.com",
    "password": "password123",
    "teamId": 1
  }'
```

**Get Nearby Flags:**
```bash
curl -X GET "http://localhost:3000/flags?latitude=37.7749&longitude=-122.4194&radius=2000" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Capture Flag:**
```bash
curl -X POST http://localhost:3000/flags/FLAG_UUID/capture \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7694,
    "longitude": -122.4862,
    "defenderTypeId": 2
  }'
```

## 📈 Scaling Considerations

### For 10,000+ Concurrent Users:

1. **Horizontal Scaling**: Auto-scaling groups with load balancer
2. **Database Read Replicas**: Separate read/write traffic
3. **Redis Cluster**: Multi-node Redis for high availability
4. **CDN**: CloudFront for static assets
5. **WebSocket Sharding**: Multiple WS servers with sticky sessions
6. **Database Partitioning**: Shard by geographic region

### Performance Optimizations:

- **Materialized Views**: Pre-compute team stats (refresh every 5 min)
- **Spatial Indexes**: GIST indexes on flag locations
- **Connection Pooling**: Reuse database connections
- **Caching Strategy**: Redis for hot data, PostgreSQL for cold storage

## 🐛 Troubleshooting

### Database Connection Failed
```bash
# Check PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Test connection
psql -U postgres -d ctf_game
```

### Redis Connection Failed
```bash
# Check Redis is running
redis-cli ping  # Should return "PONG"

# Start Redis
brew services start redis  # macOS
sudo systemctl start redis  # Linux
```

### PostGIS Extension Missing
```bash
psql -U postgres -d ctf_game
CREATE EXTENSION IF NOT EXISTS postgis;
\dx  # List extensions
```

## 📝 Future Enhancements

- [ ] Push notification integration (APNs/FCM)
- [ ] Advanced battle mechanics (rock-paper-scissors defenders)
- [ ] AR verification for high-value flags
- [ ] City-specific leaderboards
- [ ] Achievements and badges system
- [ ] Social features (friend lists, chat)
- [ ] Seasonal events and limited-time flags
- [ ] Anti-cheat: GPS spoofing detection
- [ ] Admin dashboard for game management

## 🤝 Contributing

This is an MVP. Contributions welcome!

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🎯 MVP Goals

This backend supports Matt's MVP with:
- ✅ User authentication and team management
- ✅ GPS-based flag capture mechanics
- ✅ Real-time gameplay via WebSocket
- ✅ Defender deployment system
- ✅ Leaderboards (global, team, player)
- ✅ Geospatial queries for nearby flags
- ✅ Scalable architecture (ready for nationwide deployment)

**Next Steps:**
1. Build iOS app (Swift/SwiftUI)
2. Integrate MapKit for flag visualization
3. Implement push notifications
4. Deploy to AWS/Heroku for beta testing
5. Launch in San Francisco as geo-fenced pilot

---

**Built with ❤️ for Matt's CTF Game**

Questions? Open an issue or contact the team.
