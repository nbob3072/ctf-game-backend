-- Database schema for CTF Game MVP
-- PostgreSQL + PostGIS for geospatial queries

-- Enable PostGIS extension for geospatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- Teams/Factions table
CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  color VARCHAR(7) NOT NULL, -- Hex color code
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  team_id INTEGER REFERENCES teams(id),
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  capture_count INTEGER DEFAULT 0,
  defense_count INTEGER DEFAULT 0,
  last_location GEOGRAPHY(POINT, 4326), -- PostGIS geography type
  last_location_update TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Defenders (virtual units deployed on flags)
CREATE TABLE defender_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  strength INTEGER NOT NULL, -- 1-100 scale
  duration_minutes INTEGER NOT NULL, -- How long they last
  unlock_level INTEGER DEFAULT 1, -- Level required to unlock
  description TEXT
);

-- Flags (physical locations to capture)
CREATE TABLE flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  location GEOGRAPHY(POINT, 4326) NOT NULL, -- PostGIS geography
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  flag_type VARCHAR(20) DEFAULT 'common', -- common, rare, legendary
  capture_radius_meters INTEGER DEFAULT 30,
  current_owner_team_id INTEGER REFERENCES teams(id),
  current_owner_user_id UUID REFERENCES users(id),
  captured_at TIMESTAMP,
  total_captures INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create spatial index on flag locations for fast proximity queries
CREATE INDEX idx_flags_location ON flags USING GIST(location);
CREATE INDEX idx_flags_active ON flags(is_active) WHERE is_active = TRUE;

-- Active defenders on flags
CREATE TABLE active_defenders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_id UUID REFERENCES flags(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  defender_type_id INTEGER REFERENCES defender_types(id),
  strength INTEGER NOT NULL,
  deployed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  UNIQUE(flag_id) -- Only one defender per flag
);

-- Capture history (analytics and leaderboards)
CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_id UUID REFERENCES flags(id),
  user_id UUID REFERENCES users(id),
  team_id INTEGER REFERENCES teams(id),
  captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  xp_earned INTEGER DEFAULT 100,
  previous_owner_team_id INTEGER REFERENCES teams(id),
  duration_held_seconds INTEGER, -- How long previous owner held it
  battle_occurred BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_captures_user ON captures(user_id);
CREATE INDEX idx_captures_team ON captures(team_id);
CREATE INDEX idx_captures_timestamp ON captures(captured_at DESC);

-- User sessions (for JWT token management)
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  device_info TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

-- Push notification tokens (for APNs/FCM)
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) NOT NULL,
  platform VARCHAR(10) NOT NULL, -- 'ios' or 'android'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, token)
);

-- Notifications queue (for async processing)
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- 'flag_captured', 'flag_under_attack', etc.
  title VARCHAR(100),
  body TEXT,
  data JSONB,
  sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_pending ON notifications(sent, created_at) WHERE sent = FALSE;

-- Team statistics (materialized view for performance)
CREATE MATERIALIZED VIEW team_stats AS
SELECT 
  t.id AS team_id,
  t.name AS team_name,
  COUNT(DISTINCT u.id) AS member_count,
  COUNT(DISTINCT f.id) AS flags_controlled,
  SUM(u.capture_count) AS total_captures,
  SUM(u.xp) AS total_team_xp,
  AVG(u.level) AS avg_level
FROM teams t
LEFT JOIN users u ON u.team_id = t.id
LEFT JOIN flags f ON f.current_owner_team_id = t.id
GROUP BY t.id, t.name;

CREATE UNIQUE INDEX idx_team_stats_id ON team_stats(team_id);

-- User leaderboard view
CREATE VIEW user_leaderboard AS
SELECT 
  u.id,
  u.username,
  u.team_id,
  t.name AS team_name,
  u.level,
  u.xp,
  u.capture_count,
  u.defense_count,
  RANK() OVER (ORDER BY u.xp DESC) AS global_rank,
  RANK() OVER (PARTITION BY u.team_id ORDER BY u.xp DESC) AS team_rank
FROM users u
LEFT JOIN teams t ON u.team_id = t.id;

-- Function to update user XP and level
CREATE OR REPLACE FUNCTION update_user_xp(
  p_user_id UUID,
  p_xp_gain INTEGER
) RETURNS void AS $$
DECLARE
  v_new_xp INTEGER;
  v_new_level INTEGER;
BEGIN
  -- Add XP
  UPDATE users 
  SET xp = xp + p_xp_gain,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_user_id
  RETURNING xp INTO v_new_xp;
  
  -- Calculate new level (simple formula: level = floor(sqrt(xp/100)))
  v_new_level := FLOOR(SQRT(v_new_xp::FLOAT / 100));
  
  IF v_new_level < 1 THEN
    v_new_level := 1;
  END IF;
  
  -- Update level
  UPDATE users 
  SET level = v_new_level
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired defenders
CREATE OR REPLACE FUNCTION cleanup_expired_defenders() RETURNS void AS $$
BEGIN
  DELETE FROM active_defenders WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Function to get nearby flags (uses PostGIS)
CREATE OR REPLACE FUNCTION get_nearby_flags(
  p_latitude DECIMAL,
  p_longitude DECIMAL,
  p_radius_meters INTEGER DEFAULT 1000
) RETURNS TABLE (
  id UUID,
  name VARCHAR,
  latitude DECIMAL,
  longitude DECIMAL,
  flag_type VARCHAR,
  distance_meters FLOAT,
  current_owner_team_id INTEGER,
  has_defender BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.name,
    f.latitude,
    f.longitude,
    f.flag_type,
    ST_Distance(
      f.location,
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography
    )::FLOAT AS distance_meters,
    f.current_owner_team_id,
    EXISTS(
      SELECT 1 FROM active_defenders ad 
      WHERE ad.flag_id = f.id AND ad.expires_at > CURRENT_TIMESTAMP
    ) AS has_defender
  FROM flags f
  WHERE f.is_active = TRUE
    AND ST_DWithin(
      f.location,
      ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
      p_radius_meters
    )
  ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
