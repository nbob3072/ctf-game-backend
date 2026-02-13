const express = require('express');
const db = require('../db');
const redis = require('../redis');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// GET /leaderboard - Get global leaderboard
router.get('/', async (req, res) => {
  try {
    const { limit = 100, offset = 0, type = 'global' } = req.query;

    let result;

    if (type === 'global') {
      // Try Redis cache first (faster)
      const cachedLeaderboard = await redis.getTopPlayers(parseInt(limit));
      
      if (cachedLeaderboard && cachedLeaderboard.length > 0) {
        return res.json({
          type: 'global',
          leaderboard: cachedLeaderboard,
          cached: true,
        });
      }

      // Fallback to database
      result = await db.query(
        `SELECT 
          u.id,
          u.username,
          u.team_id,
          t.name AS team_name,
          t.color AS team_color,
          u.level,
          u.xp,
          u.capture_count,
          RANK() OVER (ORDER BY u.xp DESC) AS rank
        FROM users u
        LEFT JOIN teams t ON u.team_id = t.id
        ORDER BY u.xp DESC
        LIMIT $1 OFFSET $2`,
        [parseInt(limit), parseInt(offset)]
      );

      return res.json({
        type: 'global',
        leaderboard: result.rows,
        cached: false,
      });
    }

    if (type === 'team') {
      // Team leaderboard
      result = await db.query(`
        SELECT * FROM team_stats
        ORDER BY total_team_xp DESC
      `);

      return res.json({
        type: 'team',
        leaderboard: result.rows,
      });
    }

    res.status(400).json({ error: 'Invalid leaderboard type' });
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// GET /leaderboard/me - Get current user's rank
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT * FROM user_leaderboard WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = result.rows[0];

    // Get nearby players (±10 ranks)
    const nearbyResult = await db.query(
      `SELECT * FROM user_leaderboard
       WHERE global_rank BETWEEN $1 AND $2
       ORDER BY global_rank`,
      [Math.max(1, userData.global_rank - 5), userData.global_rank + 5]
    );

    res.json({
      user: userData,
      nearby: nearbyResult.rows,
    });
  } catch (error) {
    console.error('Error fetching user rank:', error);
    res.status(500).json({ error: 'Failed to fetch user rank' });
  }
});

// GET /leaderboard/city/:city - City-specific leaderboard (future feature)
router.get('/city/:city', async (req, res) => {
  try {
    const { city } = req.params;
    const { limit = 50 } = req.query;

    // This would require adding city field to users table
    // For now, return placeholder
    res.json({
      message: 'City leaderboards coming soon!',
      city,
    });
  } catch (error) {
    console.error('Error fetching city leaderboard:', error);
    res.status(500).json({ error: 'Failed to fetch city leaderboard' });
  }
});

module.exports = router;
