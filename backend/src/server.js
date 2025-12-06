require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const http = require('http');
const { Server } = require('socket.io');

const { initializeFirebase } = require('./config/firebase');
const { errorHandler } = require('./middleware/errorHandler');
const requestLogger = require('./middleware/requestLogger');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const discoverRoutes = require('./routes/discover.routes');
const swipeRoutes = require('./routes/swipe.routes');
const matchRoutes = require('./routes/match.routes');
const chatRoutes = require('./routes/chat.routes');
const preferenceRoutes = require('./routes/preference.routes');
const deviceRoutes = require('./routes/device.routes');
const uploadRoutes = require('./routes/upload.routes');
const reportRoutes = require('./routes/report.routes');
const { setupSocket } = require('./websocket/socket');

const app = express();
const server = http.createServer(app);

// Initialize Socket.IO
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Initialize Firebase Admin
initializeFirebase();

// Middleware
app.use(helmet());
app.use(compression());

// CORS must be before other middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

app.use(requestLogger);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Health check
const healthHandler = (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
};
app.get('/health', healthHandler);
app.get('/api/health', healthHandler);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/discover', discoverRoutes);
app.use('/api/swipes', swipeRoutes);
app.use('/api/matches', matchRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/preferences', preferenceRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/reports', reportRoutes);

// Initialize Socket.IO handlers with logging
setupSocket(io);

// Error handling
app.use(errorHandler);

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
  .then(() => {
    console.log('✅ MongoDB connected');
    const PORT = process.env.PORT || 3000;
    const HOST = process.env.HOST || '0.0.0.0'; // Listen on all network interfaces
    
    server.listen(PORT, HOST, () => {
      console.log(`🚀 Server running on http://${HOST}:${PORT}`);
      console.log(`📱 Access from mobile device:`);
      console.log(`   - http://192.168.1.43:${PORT} (Local WiFi/Ethernet)`);
      console.log(`   - http://26.197.138.220:${PORT} (VPN/Virtual network)`);
      console.log(`💻 Access from localhost: http://localhost:${PORT}`);
      console.log(`\n✅ Backend is ready to receive requests!`);
      console.log(`📊 Request logging is ENABLED - All incoming requests will be logged`);
    });
  })
  .catch((error) => {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  });

module.exports = { app, server, io };

