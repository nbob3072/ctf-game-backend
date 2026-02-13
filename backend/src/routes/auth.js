const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { generateToken } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const { validateUsername } = require('../utils/profanityFilter');

const router = express.Router();

// POST /auth/register - Register new user
router.post(
  '/register',
  validateRequest({
    username: { required: true, type: 'username' },
    email: { required: true, type: 'email' },
    password: { required: true, type: 'password' },
  }),
  async (req, res) => {
    try {
      const { username, email, password, teamId } = req.body;

      // Validate username (profanity filter + format)
      const usernameValidation = validateUsername(username);
      if (!usernameValidation.valid) {
        return res.status(400).json({ error: usernameValidation.error });
      }

      // Check if user already exists
      const existing = await db.query(
        'SELECT id FROM users WHERE username = $1 OR email = $2',
        [username, email]
      );

      if (existing.rows.length > 0) {
        return res.status(409).json({ error: 'Username or email already exists' });
      }

      // Validate team if provided
      if (teamId) {
        const teamCheck = await db.query('SELECT id FROM teams WHERE id = $1', [teamId]);
        if (teamCheck.rows.length === 0) {
          return res.status(400).json({ error: 'Invalid team ID' });
        }
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 10);

      // Create user
      const result = await db.query(
        `INSERT INTO users (username, email, password_hash, team_id)
         VALUES ($1, $2, $3, $4)
         RETURNING id, username, email, team_id, level, xp, created_at`,
        [username, email, passwordHash, teamId || null]
      );

      const user = result.rows[0];

      // Generate JWT token
      const token = generateToken(user);

      // Create session
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
      await db.query(
        `INSERT INTO sessions (user_id, token_hash, expires_at)
         VALUES ($1, $2, $3)`,
        [user.id, token, expiresAt]
      );

      res.status(201).json({
        message: 'User registered successfully',
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          teamId: user.team_id,
          level: user.level,
          xp: user.xp,
        },
        token,
      });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ error: 'Registration failed' });
    }
  }
);

// POST /auth/login - Login user
router.post(
  '/login',
  validateRequest({
    email: { required: true }, // Can be email or username
    password: { required: true },
  }),
  async (req, res) => {
    try {
      const { email, password } = req.body;

      // Find user by email or username
      const result = await db.query(
        `SELECT id, username, email, password_hash, team_id, level, xp
         FROM users WHERE email = $1 OR username = $1`,
        [email]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const user = result.rows[0];

      // Verify password
      const validPassword = await bcrypt.compare(password, user.password_hash);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate JWT token
      const token = generateToken(user);

      // Create session
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
      await db.query(
        `INSERT INTO sessions (user_id, token_hash, expires_at)
         VALUES ($1, $2, $3)`,
        [user.id, token, expiresAt]
      );

      res.json({
        message: 'Login successful',
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          teamId: user.team_id,
          level: user.level,
          xp: user.xp,
        },
        token,
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ error: 'Login failed' });
    }
  }
);

// POST /auth/logout - Logout user
router.post('/logout', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      await db.query('DELETE FROM sessions WHERE token_hash = $1', [token]);
    }

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Logout failed' });
  }
});

module.exports = router;
