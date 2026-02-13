# CTF Game API Documentation

Quick reference for all API endpoints.

## Base URL
```
Development: http://localhost:3000
Production: https://api.ctfgame.com
```

## Authentication

All authenticated endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

---

## 🔐 Auth Endpoints

### POST /auth/register
Register new user account.

**Request:**
```json
{
  "username": "string (3-50 chars)",
  "email": "string (valid email)",
  "password": "string (min 8 chars)",
  "teamId": "number (optional, 1-3)"
}
```

**Response: 201 Created**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "teamId": "number|null",
    "level": 1,
    "xp": 0
  },
  "token": "jwt_token"
}
```

**Errors:**
- `409`: Username or email already exists
- `400`: Invalid team ID or validation errors

---

### POST /auth/login
Login existing user.

**Request:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response: 200 OK**
```json
{
  "message": "Login successful",
  "user": { ... },
  "token": "jwt_token"
}
```

**Errors:**
- `401`: Invalid credentials

---

### POST /auth/logout
Logout current user (invalidate session).

**Headers:** `Authorization: Bearer <token>`

**Response: 200 OK**
```json
{
  "message": "Logged out successfully"
}
```

---

## 👥 Team Endpoints

### GET /teams
Get all teams/factions.

**Response: 200 OK**
```json
{
  "teams": [
    {
      "id": 1,
      "name": "Titans",
      "color": "#E74C3C",
      "description": "Strength through unity, aggressive expansion"
    },
    {
      "id": 2,
      "name": "Guardians",
      "color": "#3498DB",
      "description": "Protect and defend, honor above all"
    },
    {
      "id": 3,
      "name": "Phantoms",
      "color": "#2ECC71",
      "description": "Speed and stealth, strike from shadows"
    }
  ]
}
```

---

### GET /teams/:id/stats
Get detailed team statistics.

**Response: 200 OK**
```json
{
  "team": {
    "id": 1,
    "name": "Titans",
    "color": "#E74C3C",
    "description": "...",
    "stats": {
      "memberCount": 42,
      "flagsControlled": 15,
      "totalCaptures": 523,
      "totalTeamXp": 125000,
      "avgLevel": 8.3
    },
    "topMembers": [
      {
        "id": "uuid",
        "username": "topplayer",
        "level": 15,
        "xp": 25600,
        "captureCount": 312
      }
    ],
    "recentCaptures": [
      {
        "id": "uuid",
        "capturedAt": "2026-02-06T17:30:00Z",
        "xpEarned": 150,
        "username": "player1",
        "flagName": "Golden Gate Park"
      }
    ]
  }
}
```

**Errors:**
- `404`: Team not found

---

### POST /teams/:id/join
Join a team (authenticated).

**Headers:** `Authorization: Bearer <token>`

**Response: 200 OK**
```json
{
  "message": "Successfully joined Titans!",
  "team": {
    "id": 1,
    "name": "Titans",
    "color": "#E74C3C",
    "description": "..."
  }
}
```

**Errors:**
- `404`: Team not found
- `401`: Not authenticated

---

## 🚩 Flag Endpoints

### GET /flags
Get nearby flags based on GPS location.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `latitude` (required): User's latitude (-90 to 90)
- `longitude` (required): User's longitude (-180 to 180)
- `radius` (optional): Search radius in meters (default: 1000)

**Example:**
```
GET /flags?latitude=37.7749&longitude=-122.4194&radius=2000
```

**Response: 200 OK**
```json
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
    }
  ],
  "count": 5
}
```

**Notes:**
- `capturable`: `true` if within 30m (capture radius)
- Updates user's last known location

**Errors:**
- `400`: Invalid coordinates
- `401`: Not authenticated

---

### GET /flags/:id
Get detailed flag information.

**Headers:** `Authorization: Bearer <token>`

**Response: 200 OK**
```json
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
    "recentCaptures": [
      {
        "capturedAt": "2026-02-06T17:00:00Z",
        "xpEarned": 100,
        "username": "player42",
        "teamName": "Titans",
        "teamColor": "#E74C3C"
      }
    ]
  }
}
```

**Errors:**
- `404`: Flag not found
- `401`: Not authenticated

---

### POST /flags/:id/capture
Capture a flag (core gameplay mechanic).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "latitude": 37.8199,
  "longitude": -122.4783,
  "defenderTypeId": 2
}
```

**Parameters:**
- `latitude` (required): User's current latitude
- `longitude` (required): User's current longitude
- `defenderTypeId` (optional): Deploy defender after capture (1-4)

**Response: 200 OK**
```json
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

**Capture Logic:**
1. Validates user is within 30m of flag
2. Checks if flag already owned by user's team (reject if true)
3. If defender present, 50% chance to break through
4. Awards XP (100 base + 50 bonus for defeating defender)
5. Updates user stats and level
6. Deploys defender if provided
7. Triggers real-time WebSocket event
8. Creates notification for previous owner

**Errors:**
- `400`: Too far from flag / Already owned by your team / Failed to break defender
- `403`: Must join a team first
- `404`: Flag not found
- `401`: Not authenticated

**Defender Types:**
| ID | Name | Strength | Duration | Unlock Level |
|----|------|----------|----------|--------------|
| 1 | Scout Bot | 20 | 60 min | 1 |
| 2 | Sentinel | 50 | 120 min | 5 |
| 3 | Guardian Titan | 80 | 240 min | 10 |
| 4 | Phantom Shadow | 100 | 360 min | 15 |

---

## 🏆 Leaderboard Endpoints

### GET /leaderboard
Get leaderboards (global or team-based).

**Query Parameters:**
- `type` (optional): `"global"` (default) or `"team"`
- `limit` (optional): Number of results (default: 100)
- `offset` (optional): Pagination offset (default: 0)

**Example:**
```
GET /leaderboard?type=global&limit=50
```

**Response: 200 OK (Global)**
```json
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
    }
  ],
  "cached": true
}
```

**Response: 200 OK (Team)**
```json
{
  "type": "team",
  "leaderboard": [
    {
      "teamId": 1,
      "teamName": "Titans",
      "memberCount": 42,
      "flagsControlled": 18,
      "totalCaptures": 523,
      "totalTeamXp": 125000,
      "avgLevel": "8.3"
    }
  ]
}
```

**Notes:**
- Global leaderboard cached in Redis for performance
- Team stats use materialized view (refreshed on captures)

---

### GET /leaderboard/me
Get current user's rank and nearby players.

**Headers:** `Authorization: Bearer <token>`

**Response: 200 OK**
```json
{
  "user": {
    "id": "uuid",
    "username": "player1",
    "teamId": 1,
    "teamName": "Titans",
    "level": 8,
    "xp": 6400,
    "captureCount": 87,
    "globalRank": 47,
    "teamRank": 12
  },
  "nearby": [
    {
      "rank": 42,
      "username": "player42",
      "level": 8,
      "xp": 6520
    },
    {
      "rank": 43,
      "username": "player43",
      "level": 8,
      "xp": 6490
    }
  ]
}
```

**Notes:**
- `nearby`: Players ranked ±5 positions around you

**Errors:**
- `404`: User not found
- `401`: Not authenticated

---

## 🌐 WebSocket Events

### Connection

Connect to WebSocket server with JWT token:

```javascript
const ws = new WebSocket('ws://localhost:3001?token=YOUR_JWT_TOKEN');
```

### Client → Server Messages

**Ping (Keep-Alive):**
```json
{
  "type": "ping"
}
```

**Subscribe to Flag Updates:**
```json
{
  "type": "subscribe_flag",
  "flagId": "uuid"
}
```

**Unsubscribe from Flag:**
```json
{
  "type": "unsubscribe_flag",
  "flagId": "uuid"
}
```

### Server → Client Messages

**Connection Established:**
```json
{
  "type": "connected",
  "message": "WebSocket connection established",
  "userId": "uuid"
}
```

**Pong (Heartbeat Response):**
```json
{
  "type": "pong",
  "timestamp": 1707248400000
}
```

**Flag Update (Real-Time Capture):**
```json
{
  "type": "flag_update",
  "flagId": "uuid",
  "event": "captured",
  "data": {
    "flagId": "uuid",
    "flagName": "Golden Gate Park",
    "userId": "uuid",
    "username": "player42",
    "teamId": 1
  },
  "timestamp": 1707248400000
}
```

**Global Event:**
```json
{
  "type": "global_event",
  "event": "legendary_flag_spawned",
  "data": {
    "flagName": "Golden Gate Bridge",
    "location": {
      "latitude": 37.8199,
      "longitude": -122.4783
    }
  },
  "timestamp": 1707248400000
}
```

---

## 🔢 Error Responses

All errors follow this format:

```json
{
  "error": "Error message here",
  "errors": ["validation error 1", "validation error 2"]
}
```

**Status Codes:**
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (missing/invalid token)
- `403`: Forbidden (no permission)
- `404`: Not Found
- `409`: Conflict (duplicate username/email)
- `429`: Too Many Requests (rate limited)
- `500`: Internal Server Error

---

## 🚀 Rate Limits

**Auth Endpoints:**
- 100 requests per 15 minutes per IP

**Other Endpoints:**
- No rate limit (add in production as needed)

---

## 🧪 Testing with cURL

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
TOKEN="your_jwt_token_here"
curl -X GET "http://localhost:3000/flags?latitude=37.7749&longitude=-122.4194&radius=2000" \
  -H "Authorization: Bearer $TOKEN"
```

**Capture Flag:**
```bash
TOKEN="your_jwt_token_here"
FLAG_ID="flag_uuid_here"
curl -X POST "http://localhost:3000/flags/$FLAG_ID/capture" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7694,
    "longitude": -122.4862,
    "defenderTypeId": 2
  }'
```

---

## 📊 Database Functions

**Get Nearby Flags (SQL):**
```sql
SELECT * FROM get_nearby_flags(37.7749, -122.4194, 1000);
```

**Update User XP:**
```sql
SELECT update_user_xp('user-uuid-here', 150);
```

**Clean Expired Defenders:**
```sql
SELECT cleanup_expired_defenders();
```

---

## 🔐 JWT Token Format

**Payload:**
```json
{
  "userId": "uuid",
  "username": "string",
  "teamId": "number|null",
  "iat": 1707248400,
  "exp": 1707853200
}
```

**Expiration:** 7 days from issue

---

## 📝 Notes

- All timestamps are ISO 8601 format (UTC)
- UUIDs are version 4
- Coordinates: Latitude first, longitude second
- Distance calculations use Haversine formula (accurate to ~1m)
- XP to Level formula: `level = floor(sqrt(xp / 100))`

---

**Last Updated:** February 6, 2026
