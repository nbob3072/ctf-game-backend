const redis = require('redis');
require('dotenv').config();

// Check if Redis should be enabled
const REDIS_ENABLED = process.env.REDIS_URL && process.env.REDIS_URL !== 'redis://localhost:6379';

let client = null;

if (REDIS_ENABLED) {
  client = redis.createClient({
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
  });

  client.on('error', (err) => {
    console.error('Redis error:', err);
  });

  client.on('connect', () => {
    console.log('✅ Connected to Redis');
  });

  // Connect to Redis
  (async () => {
    try {
      await client.connect();
    } catch (err) {
      console.error('Failed to connect to Redis:', err);
      client = null;
    }
  })();
} else {
  console.log('⚠️  Redis disabled (no REDIS_URL configured)');
}

// Helper functions for common Redis operations
// If Redis is not available, these are no-op stubs
const redisHelpers = {
  // Flag state management
  async setFlagState(flagId, state) {
    if (!client) return;
    await client.set(`flag:${flagId}`, JSON.stringify(state), {
      EX: 3600, // Expire after 1 hour (refresh on updates)
    });
  },

  async getFlagState(flagId) {
    if (!client) return null;
    const data = await client.get(`flag:${flagId}`);
    return data ? JSON.parse(data) : null;
  },

  // Leaderboard (sorted set)
  async updateLeaderboard(userId, username, xp) {
    if (!client) return;
    await client.zAdd('leaderboard:global', {
      score: xp,
      value: JSON.stringify({ userId, username }),
    });
  },

  async getTopPlayers(limit = 100) {
    if (!client) return [];
    const results = await client.zRangeWithScores('leaderboard:global', 0, limit - 1, {
      REV: true,
    });
    return results.map((item, index) => ({
      rank: index + 1,
      ...JSON.parse(item.value),
      xp: item.score,
    }));
  },

  // Team leaderboard
  async updateTeamScore(teamId, score) {
    if (!client) return;
    await client.zAdd('leaderboard:teams', {
      score,
      value: teamId.toString(),
    });
  },

  async getTopTeams() {
    if (!client) return [];
    const results = await client.zRangeWithScores('leaderboard:teams', 0, -1, {
      REV: true,
    });
    return results.map((item, index) => ({
      rank: index + 1,
      teamId: parseInt(item.value),
      score: item.score,
    }));
  },

  // User session cache
  async cacheUserSession(userId, userData, ttl = 3600) {
    if (!client) return;
    await client.set(`session:${userId}`, JSON.stringify(userData), {
      EX: ttl,
    });
  },

  async getUserSession(userId) {
    if (!client) return null;
    const data = await client.get(`session:${userId}`);
    return data ? JSON.parse(data) : null;
  },

  // Pub/Sub for real-time updates
  async publishFlagUpdate(flagId, event, data) {
    if (!client) return;
    await client.publish(
      `flag:${flagId}:updates`,
      JSON.stringify({ event, data, timestamp: Date.now() })
    );
  },

  async publishGlobalEvent(event, data) {
    if (!client) return;
    await client.publish(
      'global:events',
      JSON.stringify({ event, data, timestamp: Date.now() })
    );
  },

  // Rate limiting
  async checkRateLimit(key, limit, windowSeconds) {
    if (!client) return true; // Allow all requests when Redis is unavailable
    const current = await client.incr(key);
    
    if (current === 1) {
      await client.expire(key, windowSeconds);
    }
    
    return current <= limit;
  },
};

module.exports = {
  client,
  isEnabled: REDIS_ENABLED,
  ...redisHelpers,
};
