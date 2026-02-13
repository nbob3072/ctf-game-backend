require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Import routes
const authRoutes = require('./routes/auth');
const passwordResetRoutes = require('./routes/passwordReset');
const teamsRoutes = require('./routes/teams');
const flagsRoutes = require('./routes/flags');
const leaderboardRoutes = require('./routes/leaderboard');
const accountRoutes = require('./routes/account');

// Import WebSocket server
const WebSocketServer = require('./websocket/server');

const app = express();
const PORT = process.env.PORT || 3000;
const WS_PORT = process.env.WS_PORT || 3001;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json()); // Parse JSON bodies

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  message: 'Too many requests, please try again later',
});
app.use('/auth/', limiter); // Apply to auth routes

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// API routes
app.use('/auth', authRoutes);
app.use('/auth', passwordResetRoutes);
app.use('/teams', teamsRoutes);
app.use('/flags', flagsRoutes);
app.use('/leaderboard', leaderboardRoutes);
app.use('/account', accountRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Start HTTP server
app.listen(PORT, () => {
  console.log(`🚀 CTF Game API server running on port ${PORT}`);
  console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`   Health check: http://localhost:${PORT}/health`);
});

// Start WebSocket server (only if Redis is available)
if (process.env.REDIS_URL && process.env.REDIS_URL !== 'redis://localhost:6379') {
  const wsServer = new WebSocketServer(WS_PORT);
  console.log(`🔌 WebSocket server running on port ${WS_PORT}`);
} else {
  console.log(`⚠️  WebSocket server disabled (Redis not configured)`);
}

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  process.exit(0);
});
