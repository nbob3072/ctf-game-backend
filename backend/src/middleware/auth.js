const jwt = require('jsonwebtoken');
const db = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'your_secret_key';

// Generate JWT token
function generateToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      username: user.username,
      teamId: user.team_id,
    },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

// Verify JWT token middleware
async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Optional: Check if session exists in database
    const sessionCheck = await db.query(
      'SELECT * FROM sessions WHERE user_id = $1 AND expires_at > NOW() LIMIT 1',
      [decoded.userId]
    );

    if (sessionCheck.rows.length === 0) {
      return res.status(401).json({ error: 'Session expired or invalid' });
    }

    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

// Optional: Check if user belongs to a team
function requireTeam(req, res, next) {
  if (!req.user.teamId) {
    return res.status(403).json({ error: 'You must join a team first' });
  }
  next();
}

module.exports = {
  generateToken,
  authenticateToken,
  requireTeam,
};
