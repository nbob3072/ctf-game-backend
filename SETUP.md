# CTF Game - Backend Setup Guide

## Prerequisites

### 1. Install PostgreSQL with PostGIS
```bash
# Install PostgreSQL
brew install postgresql@15

# Install PostGIS
brew install postgis

# Start PostgreSQL
brew services start postgresql@15

# Create database
createdb ctf_game

# Connect and enable PostGIS
psql ctf_game -c "CREATE EXTENSION postgis;"
```

### 2. Install Redis
```bash
# Install Redis
brew install redis

# Start Redis
brew services start redis
```

### 3. Install Node Dependencies
```bash
cd ~/Projects/ctf-game/backend
npm install
```

## Database Setup

### 1. Run Migrations
```bash
cd ~/Projects/ctf-game/backend
node migrations/001_initial_schema.js
```

This creates:
- `users` table
- `flags` table (with PostGIS geometry)
- `captures` table
- `teams` table
- Indexes for performance

### 2. Create Initial Data

**Seed Teams:**
```bash
psql ctf_game << EOF
INSERT INTO teams (name, color, description) VALUES
('Titans', '#FF6B35', 'Strength in unity. Brute force and determination.'),
('Guardians', '#4ECDC4', 'Defenders of order. Strategic and methodical.'),
('Phantoms', '#9B59B6', 'Masters of stealth. Quick and unpredictable.');
EOF
```

## Flag Data Creation

You'll need to create 40-80 flags across 4 cities. Here's the structure:

### Flag Template (SQL):
```sql
INSERT INTO flags (
  name, 
  description, 
  hint, 
  location, 
  points, 
  city, 
  difficulty
) VALUES (
  'Flag Name',
  'Short description of the location',
  'Cryptic hint to find it',
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326),
  100,
  'NYC',
  'medium'
);
```

### Example Flags:

**NYC Examples:**
```sql
-- Times Square
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'The Crossroads',
  'Where a million dreams intersect daily',
  'The center of the world, or so they say. Look where the lights never sleep.',
  ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326),
  100,
  'NYC',
  'easy'
);

-- Central Park Bethesda Fountain
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Angel Waters',
  'Where the angel watches over the water',
  'In the heart of green, beneath the guardian angel, waters flow.',
  ST_SetSRID(ST_MakePoint(-73.9712, 40.7722), 4326),
  150,
  'NYC',
  'medium'
);

-- Brooklyn Bridge
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Steel Web',
  'Gothic arches span the river',
  'Walk where thousands cross between boroughs on cables of steel.',
  ST_SetSRID(ST_MakePoint(-73.9969, 40.7061), 4326),
  150,
  'NYC',
  'medium'
);
```

**Chicago Examples:**
```sql
-- Cloud Gate (The Bean)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mirror Sky',
  'Where the city reflects itself',
  'A silver bean that holds the skyline in its curves.',
  ST_SetSRID(ST_MakePoint(-87.6233, 41.8827), 4326),
  100,
  'Chicago',
  'easy'
);

-- Willis Tower
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Skyline Giant',
  'Once the tallest in the world',
  'Stand on glass 103 floors up, if you dare.',
  ST_SetSRID(ST_MakePoint(-87.6359, 41.8789), 4326),
  150,
  'Chicago',
  'medium'
);
```

**Austin Examples:**
```sql
-- Texas State Capitol
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lone Star Dome',
  'Where state power resides under a pink dome',
  'Taller than the US Capitol, and they want you to know it.',
  ST_SetSRID(ST_MakePoint(-97.7407, 30.2747), 4326),
  100,
  'Austin',
  'easy'
);

-- Barton Springs Pool
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Spring Eternal',
  'Nature''s pool in the heart of the city',
  '68 degrees, year-round. The locals'' secret oasis.',
  ST_SetSRID(ST_MakePoint(-97.7701, 30.2638), 4326),
  150,
  'Austin',
  'medium'
);
```

**San Francisco Examples:**
```sql
-- Golden Gate Bridge
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Red Gateway',
  'The bridge that defines the bay',
  'International orange spans the strait where fog rolls in.',
  ST_SetSRID(ST_MakePoint(-122.4783, 37.8199), 4326),
  100,
  'SF',
  'easy'
);

-- Lombard Street
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Serpent Road',
  'The crookedest street in the world',
  'Eight hairpin turns down Russian Hill. Tourists love it, locals avoid it.',
  ST_SetSRID(ST_MakePoint(-122.4187, 37.8021), 4326),
  150,
  'SF',
  'medium'
);
```

### Pro Tip: Finding Coordinates
Use Google Maps:
1. Right-click on any location
2. Click the coordinates to copy them
3. Format: `ST_MakePoint(longitude, latitude)`

**Note:** Longitude comes FIRST (east/west), then latitude (north/south)

## Configuration

### 1. Create .env file:
```bash
cd ~/Projects/ctf-game/backend
cat > .env << EOF
PORT=3000
DATABASE_URL=postgresql://localhost/ctf_game
REDIS_URL=redis://localhost:6379
JWT_SECRET=$(openssl rand -base64 32)
NODE_ENV=development
EOF
```

### 2. Update iOS App URLs

Edit `~/Projects/ctf-game/ios-app/CTFGame/Config.swift`:
```swift
struct Config {
    static let apiBaseURL = "http://YOUR_IP:3000"
    static let wsURL = "ws://YOUR_IP:3000"
}
```

**Find your local IP:**
```bash
ipconfig getifaddr en0  # WiFi
# or
ipconfig getifaddr en1  # Ethernet
```

## Start Backend

```bash
cd ~/Projects/ctf-game/backend
npm start
```

Server runs on: http://localhost:3000

### Test Endpoints:
```bash
# Health check
curl http://localhost:3000/health

# Get flags (after creating them)
curl http://localhost:3000/api/flags
```

## Next Steps

1. ✅ Run PostgreSQL + Redis setup
2. ✅ Run migrations
3. ✅ Seed teams
4. ⏳ Create flag data (40-80 flags)
5. ⏳ Start backend server
6. ⏳ Open iOS app in Xcode
7. ⏳ Test on device

## Quick Flag Creation Script

Want me to create a sub-agent task to generate 60 flags (15 per city) with real locations, hints, and descriptions?
