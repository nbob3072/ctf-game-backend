const redis = require('redis');
require('dotenv').config();

const client = redis.createClient({
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
  await client.connect();
})();

// Helper functions for common Redis operations
const redisHelpers = {
  // Flag state management
  async setFlagState(flagId, state) {
    await client.set(`flag:${flagId}`, JSON.stringify(state), {
      EX: 3600, // Expire after 1 hour (refresh on updates)
    });
  },

  async getFlagState(flagId) {
    const data = await client.get(`flag:${flagId}`);
    return data ? JSON.parse(data) : null;
  },

  // Leaderboard (sorted set)
  async updateLeaderboard(userId, username, xp) {
    await client.zAdd('leaderboard:global', {
      score: xp,
      value: JSON.stringify({ userId, username }),
    });
  },

  async getTopPlayers(limit = 100) {
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
    await client.zAdd('leaderboard:teams', {
      score,
      value: teamId.toString(),
    });
  },

  async getTopTeams() {
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
    await client.set(`session:${userId}`, JSON.stringify(userData), {
      EX: ttl,
    });
  },

  async getUserSession(userId) {
    const data = await client.get(`session:${userId}`);
    return data ? JSON.parse(data) : null;
  },

  // Pub/Sub for real-time updates
  async publishFlagUpdate(flagId, event, data) {
    await client.publish(
      `flag:${flagId}:updates`,
      JSON.stringify({ event, data, timestamp: Date.now() })
    );
  },

  async publishGlobalEvent(event, data) {
    await client.publish(
      'global:events',
      JSON.stringify({ event, data, timestamp: Date.now() })
    );
  },

  // Rate limiting
  async checkRateLimit(key, limit, windowSeconds) {
    const current = await client.incr(key);
    
    if (current === 1) {
      await client.expire(key, windowSeconds);
    }
    
    return current <= limit;
  },
};

module.exports = {
  client,
  ...redisHelpers,
};
