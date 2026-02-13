const express = require('express');
const db = require('../db');
const redis = require('../redis');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// GET /teams - Get all teams
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT id, name, color, description 
      FROM teams 
      ORDER BY name
    `);

    res.json({
      teams: result.rows,
    });
  } catch (error) {
    console.error('Error fetching teams:', error);
    res.status(500).json({ error: 'Failed to fetch teams' });
  }
});

// GET /teams/:id/stats - Get team statistics
router.get('/:id/stats', async (req, res) => {
  try {
    const { id } = req.params;

    // Get team info
    const teamResult = await db.query(
      'SELECT * FROM teams WHERE id = $1',
      [id]
    );

    if (teamResult.rows.length === 0) {
      return res.status(404).json({ error: 'Team not found' });
    }

    const team = teamResult.rows[0];

    // Get team stats from materialized view
    const statsResult = await db.query(
      'SELECT * FROM team_stats WHERE team_id = $1',
      [id]
    );

    const stats = statsResult.rows[0] || {
      member_count: 0,
      flags_controlled: 0,
      total_captures: 0,
      total_team_xp: 0,
      avg_level: 0,
    };

    // Get top 10 team members
    const topMembersResult = await db.query(`
      SELECT id, username, level, xp, capture_count
      FROM users
      WHERE team_id = $1
      ORDER BY xp DESC
      LIMIT 10
    `, [id]);

    // Get recent captures
    const recentCapturesResult = await db.query(`
      SELECT 
        c.id,
        c.captured_at,
        c.xp_earned,
        u.username,
        f.name AS flag_name
      FROM captures c
      JOIN users u ON c.user_id = u.id
      JOIN flags f ON c.flag_id = f.id
      WHERE c.team_id = $1
      ORDER BY c.captured_at DESC
      LIMIT 20
    `, [id]);

    res.json({
      team: {
        ...team,
        stats: {
          memberCount: parseInt(stats.member_count),
          flagsControlled: parseInt(stats.flags_controlled),
          totalCaptures: parseInt(stats.total_captures),
          totalTeamXp: parseInt(stats.total_team_xp),
          avgLevel: parseFloat(stats.avg_level).toFixed(1),
        },
        topMembers: topMembersResult.rows,
        recentCaptures: recentCapturesResult.rows,
      },
    });
  } catch (error) {
    console.error('Error fetching team stats:', error);
    res.status(500).json({ error: 'Failed to fetch team stats' });
  }
});

// POST /teams/:id/join - Join a team
router.post('/:id/join', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Check if team exists
    const teamResult = await db.query(
      'SELECT * FROM teams WHERE id = $1',
      [id]
    );

    if (teamResult.rows.length === 0) {
      return res.status(404).json({ error: 'Team not found' });
    }

    // Update user's team
    await db.query(
      'UPDATE users SET team_id = $1, updated_at = NOW() WHERE id = $2',
      [id, userId]
    );

    // Refresh materialized view
    await db.query('REFRESH MATERIALIZED VIEW team_stats');

    res.json({
      message: `Successfully joined ${teamResult.rows[0].name}!`,
      team: teamResult.rows[0],
    });
  } catch (error) {
    console.error('Error joining team:', error);
    res.status(500).json({ error: 'Failed to join team' });
  }
});

module.exports = router;
