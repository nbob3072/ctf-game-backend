const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const pool = require('../db');

// DELETE /account - Delete user account and all associated data
router.delete('/', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const userId = req.user.userId;
    
    // Log the deletion attempt
    console.log(`Account deletion requested for user ID: ${userId}`);
    
    // Delete all user data in order (due to foreign key constraints)
    
    // 1. Delete active defenders placed by user
    await client.query('DELETE FROM active_defenders WHERE user_id = $1', [userId]);
    
    // 2. Delete capture history
    await client.query('DELETE FROM captures WHERE user_id = $1', [userId]);
    
    // 3. Delete game sessions
    await client.query('DELETE FROM sessions WHERE user_id = $1', [userId]);
    
    // 4. Remove user as flag owner (set to NULL instead of deleting flags)
    await client.query(
      'UPDATE flags SET current_owner_user_id = NULL, current_owner_team_id = NULL WHERE current_owner_user_id = $1',
      [userId]
    );
    
    // 5. Delete the user account itself
    const deleteResult = await client.query(
      'DELETE FROM users WHERE id = $1 RETURNING username, email',
      [userId]
    );
    
    if (deleteResult.rows.length === 0) {
      throw new Error('User not found');
    }
    
    const deletedUser = deleteResult.rows[0];
    
    await client.query('COMMIT');
    
    console.log(`Account deleted successfully: ${deletedUser.username} (${deletedUser.email})`);
    
    res.json({
      message: 'Account deleted successfully',
      deletedData: {
        username: deletedUser.username,
        email: deletedUser.email
      }
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Account deletion error:', error);
    res.status(500).json({
      error: 'Failed to delete account',
      message: error.message
    });
  } finally {
    client.release();
  }
});

module.exports = router;
