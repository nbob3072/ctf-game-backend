const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const redis = require('../redis');

const JWT_SECRET = process.env.JWT_SECRET || 'your_secret_key';

class WebSocketServer {
  constructor(port) {
    this.wss = new WebSocket.Server({ port });
    this.clients = new Map(); // userId -> WebSocket connection
    this.setupServer();
    this.subscribeToRedis();
  }

  setupServer() {
    this.wss.on('connection', (ws, req) => {
      console.log('New WebSocket connection');

      // Authenticate connection
      const token = new URL(req.url, 'http://localhost').searchParams.get('token');

      if (!token) {
        ws.close(1008, 'Authentication required');
        return;
      }

      try {
        const decoded = jwt.verify(token, JWT_SECRET);
        ws.userId = decoded.userId;
        ws.username = decoded.username;
        ws.teamId = decoded.teamId;

        // Store connection
        this.clients.set(decoded.userId, ws);
        console.log(`User ${decoded.username} connected via WebSocket`);

        // Send welcome message
        ws.send(
          JSON.stringify({
            type: 'connected',
            message: 'WebSocket connection established',
            userId: decoded.userId,
          })
        );

        // Handle messages from client
        ws.on('message', (message) => {
          this.handleClientMessage(ws, message);
        });

        // Handle disconnect
        ws.on('close', () => {
          this.clients.delete(ws.userId);
          console.log(`User ${ws.username} disconnected`);
        });

        // Handle errors
        ws.on('error', (error) => {
          console.error('WebSocket error:', error);
          this.clients.delete(ws.userId);
        });
      } catch (error) {
        console.error('WebSocket authentication failed:', error);
        ws.close(1008, 'Invalid token');
      }
    });

    console.log(`✅ WebSocket server running on port ${this.wss.options.port}`);
  }

  handleClientMessage(ws, message) {
    try {
      const data = JSON.parse(message);

      switch (data.type) {
        case 'ping':
          ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
          break;

        case 'subscribe_flag':
          // Subscribe to specific flag updates
          ws.subscribedFlags = ws.subscribedFlags || new Set();
          ws.subscribedFlags.add(data.flagId);
          ws.send(
            JSON.stringify({
              type: 'subscribed',
              flagId: data.flagId,
            })
          );
          break;

        case 'unsubscribe_flag':
          if (ws.subscribedFlags) {
            ws.subscribedFlags.delete(data.flagId);
          }
          break;

        default:
          console.log('Unknown message type:', data.type);
      }
    } catch (error) {
      console.error('Error handling client message:', error);
    }
  }

  // Subscribe to Redis pub/sub for real-time events
  async subscribeToRedis() {
    const subscriber = redis.client.duplicate();
    await subscriber.connect();

    // Subscribe to global events
    await subscriber.subscribe('global:events', (message) => {
      const event = JSON.parse(message);
      this.broadcastToAll({
        type: 'global_event',
        event: event.event,
        data: event.data,
        timestamp: event.timestamp,
      });
    });

    // Subscribe to flag updates (pattern matching)
    await subscriber.pSubscribe('flag:*:updates', (message, channel) => {
      const event = JSON.parse(message);
      const flagId = channel.split(':')[1];

      // Broadcast to clients subscribed to this flag
      this.broadcastToFlagSubscribers(flagId, {
        type: 'flag_update',
        flagId,
        event: event.event,
        data: event.data,
        timestamp: event.timestamp,
      });
    });

    console.log('✅ WebSocket server subscribed to Redis events');
  }

  // Broadcast message to all connected clients
  broadcastToAll(message) {
    const payload = JSON.stringify(message);
    this.clients.forEach((ws) => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(payload);
      }
    });
  }

  // Broadcast to clients subscribed to specific flag
  broadcastToFlagSubscribers(flagId, message) {
    const payload = JSON.stringify(message);
    this.clients.forEach((ws) => {
      if (
        ws.readyState === WebSocket.OPEN &&
        ws.subscribedFlags &&
        ws.subscribedFlags.has(flagId)
      ) {
        ws.send(payload);
      }
    });
  }

  // Send message to specific user
  sendToUser(userId, message) {
    const ws = this.clients.get(userId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  // Broadcast to team
  broadcastToTeam(teamId, message) {
    const payload = JSON.stringify(message);
    this.clients.forEach((ws) => {
      if (ws.readyState === WebSocket.OPEN && ws.teamId === teamId) {
        ws.send(payload);
      }
    });
  }
}

module.exports = WebSocketServer;
