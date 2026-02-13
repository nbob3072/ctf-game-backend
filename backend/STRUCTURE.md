# Project Structure

Overview of the CTF Game backend codebase organization.

```
ctf-game-backend/
│
├── src/
│   ├── db/
│   │   ├── index.js           # PostgreSQL connection pool
│   │   ├── migrate.js         # Migration runner
│   │   ├── seed.js            # Database seeding script
│   │   └── schema.sql         # Complete database schema
│   │
│   ├── redis/
│   │   └── index.js           # Redis client + helper functions
│   │
│   ├── middleware/
│   │   ├── auth.js            # JWT authentication middleware
│   │   └── validation.js      # Input validation helpers
│   │
│   ├── routes/
│   │   ├── auth.js            # Authentication endpoints
│   │   ├── teams.js           # Team management endpoints
│   │   ├── flags.js           # Flag capture endpoints
│   │   └── leaderboard.js     # Leaderboard endpoints
│   │
│   ├── websocket/
│   │   └── server.js          # WebSocket real-time server
│   │
│   └── server.js              # Main Express server
│
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── package.json               # Dependencies and scripts
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Local dev environment
│
├── README.md                  # Main documentation
├── API.md                     # API endpoint reference
├── DEPLOYMENT.md              # Deployment guide
└── STRUCTURE.md               # This file
```

## 📁 Directory Breakdown

### `/src/db/`
Database layer - PostgreSQL connection, migrations, and schema.

**Files:**
- `index.js`: Connection pool configuration
- `migrate.js`: Creates all tables, indexes, views, functions
- `seed.js`: Populates initial data (teams, defenders, sample flags)
- `schema.sql`: Complete SQL schema with PostGIS

**Key Features:**
- PostGIS for geospatial queries
- Materialized views for performance
- Stored procedures for common operations
- Spatial indexes on flag locations

### `/src/redis/`
Redis client for caching and real-time features.

**Helper Functions:**
- `setFlagState()` / `getFlagState()`: Cache flag ownership
- `updateLeaderboard()`: Sorted set for global rankings
- `publishFlagUpdate()`: Pub/Sub for real-time events
- `checkRateLimit()`: API rate limiting

### `/src/middleware/`
Express middleware for authentication and validation.

**auth.js:**
- `generateToken()`: Create JWT tokens
- `authenticateToken()`: Verify JWT on protected routes
- `requireTeam()`: Ensure user has joined a team

**validation.js:**
- `validateEmail()`: Email format validation
- `validateUsername()`: Username rules (3-50 chars, alphanumeric)
- `validatePassword()`: Password strength (min 8 chars)
- `validateCoordinates()`: GPS lat/lng validation
- `validateRequest()`: Generic request validation middleware

### `/src/routes/`
API endpoint handlers.

**auth.js:**
- `POST /auth/register`: Create new user account
- `POST /auth/login`: Authenticate user
- `POST /auth/logout`: Invalidate session

**teams.js:**
- `GET /teams`: List all teams
- `GET /teams/:id/stats`: Team statistics and members
- `POST /teams/:id/join`: Join a team

**flags.js:**
- `GET /flags`: Get nearby flags (GPS-based)
- `GET /flags/:id`: Flag details
- `POST /flags/:id/capture`: Capture flag (core gameplay)

**leaderboard.js:**
- `GET /leaderboard`: Global or team leaderboards
- `GET /leaderboard/me`: Current user's rank

### `/src/websocket/`
WebSocket server for real-time updates.

**Features:**
- JWT authentication for connections
- Subscribe to specific flag updates
- Broadcast captures to nearby players
- Team-based messaging
- Ping/pong heartbeat

**Events:**
- `flag_update`: Flag captured/defended
- `global_event`: Worldwide announcements
- `connected`: Client authenticated
- `pong`: Heartbeat response

### `/src/server.js`
Main application entry point.

**Sets up:**
- Express app with security middleware (helmet, CORS)
- Rate limiting on auth routes
- Route mounting
- WebSocket server initialization
- Error handling
- Graceful shutdown

## 🗃️ Database Schema

### Core Tables

**users**
- Authentication and user profile
- Team affiliation
- Level and XP tracking
- Last known GPS location (PostGIS)

**teams**
- 3 factions: Titans, Guardians, Phantoms
- Team colors and descriptions

**flags**
- GPS coordinates (PostGIS geography type)
- Current owner (team + user)
- Flag type (common/rare/legendary)
- Capture radius (default 30m)

**active_defenders**
- Virtual defenders deployed on flags
- Strength and expiration time
- One defender per flag

**captures**
- Historical capture events
- XP earned per capture
- Previous owner tracking
- Battle outcome

**sessions**
- JWT session management
- Token invalidation support
- Device info tracking

### Views

**team_stats (Materialized View)**
- Aggregated team statistics
- Refreshed on flag captures
- Used for team leaderboard

**user_leaderboard (View)**
- Real-time player rankings
- Global and team-based ranks
- Used for leaderboard endpoints

### Functions

**get_nearby_flags(lat, lng, radius)**
- Returns flags within radius (meters)
- Uses PostGIS spatial index
- Includes distance calculation

**update_user_xp(userId, xpGain)**
- Add XP to user
- Auto-calculate new level
- Level formula: `floor(sqrt(xp/100))`

**cleanup_expired_defenders()**
- Remove defenders past expiration
- Run periodically or before captures

## 🔌 API Flow Examples

### Capture Flag Flow

```
1. Client sends GPS coordinates to /flags/:id/capture
2. Server validates:
   - User is within 30m of flag
   - User has joined a team
   - Flag not already owned by user's team
3. If defender present:
   - Run battle logic (50% success chance)
   - If failed, return error
   - If success, award bonus XP and remove defender
4. Update flag ownership in database
5. Record capture in history
6. Update user XP and level
7. Deploy new defender if requested
8. Update Redis cache (leaderboard, flag state)
9. Publish WebSocket event to subscribed clients
10. Create notification for previous owner
11. Return success response to client
```

### Real-Time Update Flow

```
1. Player A captures flag
2. Server publishes to Redis: "flag:uuid:updates"
3. WebSocket server subscribed to Redis channel
4. WebSocket broadcasts to all clients subscribed to that flag
5. Player B's app receives flag_update event
6. Player B's UI updates in real-time
```

## 🔐 Security Layers

**Authentication:**
1. Password hashed with bcrypt (10 rounds)
2. JWT token with 7-day expiration
3. Session stored in database (can be revoked)
4. Token sent in Authorization header

**Authorization:**
1. Middleware checks JWT validity
2. Extracts userId and teamId
3. Validates session not expired
4. Attaches user info to request

**Input Validation:**
1. Validates all user inputs
2. Sanitizes GPS coordinates
3. Checks username/email format
4. Prevents SQL injection (parameterized queries)

**Rate Limiting:**
1. 100 requests per 15 minutes on /auth/*
2. Prevents brute-force attacks
3. Can be extended to other endpoints

## 📊 Performance Optimizations

**Database:**
- Connection pooling (max 20 connections)
- Spatial indexes on flag locations (GIST)
- Materialized views for expensive queries
- Efficient query patterns (avoid N+1)

**Caching:**
- Redis for leaderboards (O(log N) sorted sets)
- Flag state caching (1-hour TTL)
- User session caching
- Pub/Sub for real-time events

**WebSocket:**
- Selective broadcasting (only subscribed clients)
- Message compression
- Heartbeat to detect dead connections

## 🧪 Testing Approach

**Manual Testing:**
- cURL examples in README
- Postman collection (can be added)
- WebSocket testing tools

**Automated Testing (Future):**
```javascript
// Example test structure
describe('POST /flags/:id/capture', () => {
  it('should capture flag when within radius', async () => {
    // Test implementation
  });
  
  it('should reject capture when too far', async () => {
    // Test implementation
  });
  
  it('should award XP for successful capture', async () => {
    // Test implementation
  });
});
```

## 🚀 Scalability Considerations

**Horizontal Scaling:**
- Stateless API servers (scale to 100s of instances)
- Load balancer distributes traffic
- WebSocket sticky sessions (route user to same server)

**Database Scaling:**
- Read replicas for leaderboard queries
- Sharding by geographic region (future)
- Separate analytics database

**Caching:**
- Redis cluster for high availability
- CDN for static assets
- Application-level caching

**Geographic Distribution:**
- Multi-region deployment
- Route users to nearest region
- Replicate flag data per region

## 📝 Code Conventions

**Naming:**
- `camelCase` for variables and functions
- `PascalCase` for classes
- `snake_case` for database columns

**Error Handling:**
- Try-catch blocks in all async functions
- Consistent error response format
- Log errors to console (production: CloudWatch)

**Comments:**
- Explain "why", not "what"
- Document complex logic
- Keep comments updated

**Git Workflow:**
- Feature branches from `main`
- Descriptive commit messages
- Pull requests for review

## 🔄 Future Enhancements

**Planned Features:**
- [ ] Push notifications (APNs/FCM integration)
- [ ] Advanced battle mechanics (rock-paper-scissors)
- [ ] Achievements and badges
- [ ] Friend system
- [ ] In-app chat
- [ ] Admin dashboard
- [ ] Analytics tracking
- [ ] A/B testing framework
- [ ] Seasonal events system
- [ ] Anti-cheat (GPS spoofing detection)

**Technical Improvements:**
- [ ] GraphQL API (alternative to REST)
- [ ] gRPC for internal services
- [ ] Message queue (RabbitMQ/SQS) for async tasks
- [ ] Elasticsearch for advanced search
- [ ] Kubernetes deployment
- [ ] Service mesh (Istio)

---

**Last Updated:** February 6, 2026
