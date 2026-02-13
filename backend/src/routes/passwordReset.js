const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { validateRequest } = require('../middleware/validation');
const { sendPasswordResetEmail } = require('../utils/email');

const router = express.Router();

// POST /auth/reset-password-request - Request password reset
router.post(
  '/reset-password-request',
  validateRequest({
    email: { required: true, type: 'email' },
  }),
  async (req, res) => {
    try {
      const { email } = req.body;

      // Find user by email
      const userResult = await db.query(
        'SELECT id, username, email FROM users WHERE email = $1',
        [email]
      );

      // Always return success even if email doesn't exist (security best practice)
      // This prevents email enumeration attacks
      if (userResult.rows.length === 0) {
        return res.json({
          message: 'If that email exists, a password reset link has been sent.',
        });
      }

      const user = userResult.rows[0];

      // Clean up any existing tokens for this user
      await db.query('DELETE FROM password_reset_tokens WHERE user_id = $1', [user.id]);

      // Generate reset token
      const resetToken = uuidv4();
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

      // Store token in database
      await db.query(
        `INSERT INTO password_reset_tokens (user_id, token, expires_at)
         VALUES ($1, $2, $3)`,
        [user.id, resetToken, expiresAt]
      );

      // Send email with reset link
      await sendPasswordResetEmail(user.email, user.username, resetToken);

      res.json({
        message: 'If that email exists, a password reset link has been sent.',
      });
    } catch (error) {
      console.error('Password reset request error:', error);
      // Don't expose internal errors
      res.json({
        message: 'If that email exists, a password reset link has been sent.',
      });
    }
  }
);

// POST /auth/reset-password - Complete password reset
router.post(
  '/reset-password',
  validateRequest({
    token: { required: true },
    newPassword: { required: true, type: 'password' },
  }),
  async (req, res) => {
    try {
      const { token, newPassword } = req.body;

      // Find valid reset token
      const tokenResult = await db.query(
        `SELECT user_id, expires_at, used 
         FROM password_reset_tokens 
         WHERE token = $1`,
        [token]
      );

      if (tokenResult.rows.length === 0) {
        return res.status(400).json({ error: 'Invalid or expired reset token' });
      }

      const resetToken = tokenResult.rows[0];

      // Check if token is expired
      if (new Date() > new Date(resetToken.expires_at)) {
        return res.status(400).json({ error: 'Reset token has expired' });
      }

      // Check if token was already used
      if (resetToken.used) {
        return res.status(400).json({ error: 'Reset token has already been used' });
      }

      // Hash new password
      const passwordHash = await bcrypt.hash(newPassword, 10);

      // Update user password
      await db.query(
        'UPDATE users SET password_hash = $1 WHERE id = $2',
        [passwordHash, resetToken.user_id]
      );

      // Mark token as used
      await db.query(
        'UPDATE password_reset_tokens SET used = TRUE WHERE token = $1',
        [token]
      );

      // Invalidate all existing sessions for security
      await db.query('DELETE FROM sessions WHERE user_id = $1', [resetToken.user_id]);

      res.json({
        message: 'Password successfully reset. Please log in with your new password.',
      });
    } catch (error) {
      console.error('Password reset error:', error);
      res.status(500).json({ error: 'Failed to reset password' });
    }
  }
);

// GET /auth/reset-password/verify/:token - Verify reset token is valid
router.get('/reset-password/verify/:token', async (req, res) => {
  try {
    const { token } = req.params;

    const tokenResult = await db.query(
      `SELECT expires_at, used 
       FROM password_reset_tokens 
       WHERE token = $1`,
      [token]
    );

    if (tokenResult.rows.length === 0) {
      return res.status(400).json({ valid: false, error: 'Invalid token' });
    }

    const resetToken = tokenResult.rows[0];

    if (new Date() > new Date(resetToken.expires_at)) {
      return res.status(400).json({ valid: false, error: 'Token expired' });
    }

    if (resetToken.used) {
      return res.status(400).json({ valid: false, error: 'Token already used' });
    }

    res.json({ valid: true });
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(500).json({ valid: false, error: 'Verification failed' });
  }
});

module.exports = router;
