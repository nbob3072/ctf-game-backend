const express = require('express');
const db = require('../db');
const redis = require('../redis');
const { authenticateToken, requireTeam } = require('../middleware/auth');
const { validateCoordinates } = require('../middleware/validation');
const { getDistance } = require('geolib');

const router = express.Router();

// GET /flags - Get nearby flags based on GPS
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, radius = 1000 } = req.query;

    if (!validateCoordinates(latitude, longitude)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const radiusMeters = parseInt(radius);

    // Update user's last known location
    await db.query(
      `UPDATE users 
       SET last_location = ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
           last_location_update = NOW()
       WHERE id = $3`,
      [lng, lat, req.user.userId]
    );

    // Get nearby flags using PostGIS function
    const result = await db.query(
      'SELECT * FROM get_nearby_flags($1, $2, $3)',
      [lat, lng, radiusMeters]
    );

    // Enrich with team names
    const flagsWithDetails = await Promise.all(
      result.rows.map(async (flag) => {
        let ownerTeam = null;
        if (flag.current_owner_team_id) {
          const teamResult = await db.query(
            'SELECT name, color FROM teams WHERE id = $1',
            [flag.current_owner_team_id]
          );
          ownerTeam = teamResult.rows[0] || null;
        }

        return {
          id: flag.id,
          name: flag.name,
          latitude: parseFloat(flag.latitude),
          longitude: parseFloat(flag.longitude),
          type: flag.flag_type,
          distanceMeters: Math.round(flag.distance_meters),
          ownerTeam,
          hasDefender: flag.has_defender,
          capturable: flag.distance_meters <= 30, // Within 30m
        };
      })
    );

    res.json({
      userLocation: { latitude: lat, longitude: lng },
      flags: flagsWithDetails,
      count: flagsWithDetails.length,
    });
  } catch (error) {
    console.error('Error fetching flags:', error);
    res.status(500).json({ error: 'Failed to fetch flags' });
  }
});

// GET /flags/:id - Get flag details
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        f.*,
        t.name AS owner_team_name,
        t.color AS owner_team_color,
        u.username AS owner_username
      FROM flags f
      LEFT JOIN teams t ON f.current_owner_team_id = t.id
      LEFT JOIN users u ON f.current_owner_user_id = u.id
      WHERE f.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Flag not found' });
    }

    const flag = result.rows[0];

    // Get active defender if exists
    const defenderResult = await db.query(
      `SELECT 
        ad.*,
        dt.name AS defender_name,
        u.username AS deployed_by
      FROM active_defenders ad
      JOIN defender_types dt ON ad.defender_type_id = dt.id
      JOIN users u ON ad.user_id = u.id
      WHERE ad.flag_id = $1 AND ad.expires_at > NOW()`,
      [id]
    );

    const defender = defenderResult.rows[0] || null;

    // Get recent capture history
    const historyResult = await db.query(
      `SELECT 
        c.captured_at,
        c.xp_earned,
        u.username,
        t.name AS team_name,
        t.color AS team_color
      FROM captures c
      JOIN users u ON c.user_id = u.id
      JOIN teams t ON c.team_id = t.id
      WHERE c.flag_id = $1
      ORDER BY c.captured_at DESC
      LIMIT 10`,
      [id]
    );

    res.json({
      flag: {
        id: flag.id,
        name: flag.name,
        latitude: parseFloat(flag.latitude),
        longitude: parseFloat(flag.longitude),
        type: flag.flag_type,
        totalCaptures: flag.total_captures,
        currentOwner: flag.owner_username
          ? {
              username: flag.owner_username,
              team: {
                name: flag.owner_team_name,
                color: flag.owner_team_color,
              },
            }
          : null,
        defender: defender
          ? {
              name: defender.defender_name,
              strength: defender.strength,
              deployedBy: defender.deployed_by,
              expiresAt: defender.expires_at,
            }
          : null,
        recentCaptures: historyResult.rows,
      },
    });
  } catch (error) {
    console.error('Error fetching flag details:', error);
    res.status(500).json({ error: 'Failed to fetch flag details' });
  }
});

// POST /flags/:id/capture - Capture a flag
router.post('/:id/capture', authenticateToken, requireTeam, async (req, res) => {
  try {
    const { id } = req.params;
    const { latitude, longitude, defenderTypeId } = req.body;
    const userId = req.user.userId;
    const teamId = req.user.teamId;

    if (!validateCoordinates(latitude, longitude)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }

    // Get flag details
    const flagResult = await db.query(
      'SELECT * FROM flags WHERE id = $1 AND is_active = TRUE',
      [id]
    );

    if (flagResult.rows.length === 0) {
      return res.status(404).json({ error: 'Flag not found or inactive' });
    }

    const flag = flagResult.rows[0];

    // Check if user is within capture radius
    const distance = getDistance(
      { latitude, longitude },
      { latitude: parseFloat(flag.latitude), longitude: parseFloat(flag.longitude) }
    );

    if (distance > flag.capture_radius_meters) {
      return res.status(400).json({
        error: 'You are too far from the flag',
        distanceMeters: distance,
        requiredDistance: flag.capture_radius_meters,
      });
    }

    // Check if flag is already owned by user's team
    if (flag.current_owner_team_id === teamId) {
      return res.status(400).json({ error: 'Your team already controls this flag' });
    }

    // Clean up expired defenders
    await db.query('SELECT cleanup_expired_defenders()');

    // Check for active defender
    const defenderCheck = await db.query(
      `SELECT * FROM active_defenders 
       WHERE flag_id = $1 AND expires_at > NOW()`,
      [id]
    );

    let battleOccurred = false;
    let xpEarned = 100; // Base XP

    if (defenderCheck.rows.length > 0) {
      // Battle logic (simplified for MVP - can be expanded)
      battleOccurred = true;
      const defender = defenderCheck.rows[0];
      
      // 50% chance to break through (can be made more complex)
      const battleSuccess = Math.random() > 0.5;
      
      if (!battleSuccess) {
        return res.status(400).json({
          error: 'Failed to break through the defender!',
          defender: {
            strength: defender.strength,
            expiresAt: defender.expires_at,
          },
        });
      }
      
      // Bonus XP for defeating defender
      xpEarned += 50;
      
      // Remove defender
      await db.query('DELETE FROM active_defenders WHERE id = $1', [defender.id]);
    }

    // Calculate duration held by previous owner
    let durationHeldSeconds = null;
    if (flag.captured_at) {
      durationHeldSeconds = Math.floor((Date.now() - new Date(flag.captured_at)) / 1000);
    }

    // Capture the flag!
    await db.query(
      `UPDATE flags 
       SET current_owner_team_id = $1,
           current_owner_user_id = $2,
           captured_at = NOW(),
           total_captures = total_captures + 1
       WHERE id = $3`,
      [teamId, userId, id]
    );

    // Record capture in history
    await db.query(
      `INSERT INTO captures 
       (flag_id, user_id, team_id, xp_earned, previous_owner_team_id, duration_held_seconds, battle_occurred)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [id, userId, teamId, xpEarned, flag.current_owner_team_id, durationHeldSeconds, battleOccurred]
    );

    // Update user stats and XP
    await db.query(
      'UPDATE users SET capture_count = capture_count + 1 WHERE id = $1',
      [userId]
    );
    await db.query('SELECT update_user_xp($1, $2)', [userId, xpEarned]);

    // Get updated user info
    const userResult = await db.query(
      'SELECT level, xp FROM users WHERE id = $1',
      [userId]
    );
    const updatedUser = userResult.rows[0];

    // Deploy defender if provided
    let deployedDefender = null;
    if (defenderTypeId) {
      const defenderTypeResult = await db.query(
        'SELECT * FROM defender_types WHERE id = $1',
        [defenderTypeId]
      );

      if (defenderTypeResult.rows.length > 0) {
        const defenderType = defenderTypeResult.rows[0];

        // Check if user has unlocked this defender
        if (updatedUser.level >= defenderType.unlock_level) {
          const expiresAt = new Date(Date.now() + defenderType.duration_minutes * 60 * 1000);

          await db.query(
            `INSERT INTO active_defenders (flag_id, user_id, defender_type_id, strength, expires_at)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (flag_id) DO UPDATE 
             SET user_id = $2, defender_type_id = $3, strength = $4, expires_at = $5, deployed_at = NOW()`,
            [id, userId, defenderTypeId, defenderType.strength, expiresAt]
          );

          deployedDefender = {
            name: defenderType.name,
            strength: defenderType.strength,
            expiresAt,
          };
        }
      }
    }

    // Update Redis leaderboard
    await redis.updateLeaderboard(userId, req.user.username, updatedUser.xp);

    // Publish real-time update via Redis
    await redis.publishFlagUpdate(id, 'captured', {
      flagId: id,
      flagName: flag.name,
      userId,
      username: req.user.username,
      teamId,
    });

    // Create notification for previous owner (if exists)
    if (flag.current_owner_user_id) {
      await db.query(
        `INSERT INTO notifications (user_id, type, title, body, data)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          flag.current_owner_user_id,
          'flag_lost',
          'Flag Lost!',
          `${req.user.username} captured ${flag.name}`,
          JSON.stringify({ flagId: id, capturedBy: req.user.username }),
        ]
      );
    }

    // Refresh team stats
    await db.query('REFRESH MATERIALIZED VIEW team_stats');

    res.json({
      message: `Successfully captured ${flag.name}!`,
      capture: {
        flagId: id,
        flagName: flag.name,
        xpEarned,
        battleOccurred,
        newLevel: updatedUser.level,
        totalXp: updatedUser.xp,
        deployedDefender,
      },
    });
  } catch (error) {
    console.error('Error capturing flag:', error);
    res.status(500).json({ error: 'Failed to capture flag' });
  }
});

module.exports = router;
