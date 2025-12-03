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

/**************************************
 * 🔥 FIX 1 — Socket.IO cors mở rộng
 *************************************/
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  }
});

/**************************************
 * 🔥 FIX 2 — Firebase Admin init
 *************************************/
initializeFirebase();

/**************************************
 * Middleware
 *************************************/
app.use(helmet());
app.use(compression());
app.use(requestLogger);

/**************************************
 * 🔥 FIX 3 — Mở full CORS cho Flutter
 *************************************/
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  credentials: true
}));

/**************************************
 * Body parser
 *************************************/
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

/**************************************
 * Rate Limiting
 *************************************/
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200
});
app.use("/api/", limiter);

/**************************************
 * Health Check
 *************************************/
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

/**************************************
 * Routes
 *************************************/
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/discover", discoverRoutes);
app.use("/api/swipes", swipeRoutes);
app.use("/api/matches", matchRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/preferences", preferenceRoutes);
app.use("/api/devices", deviceRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/reports", reportRoutes);

/**************************************
 * Socket.IO Setup
 *************************************/
setupSocket(io);

/**************************************
 * Error Handler
 *************************************/
app.use(errorHandler);

/**************************************
 * Database & Server Start
 *************************************/
mongoose.connect(process.env.MONGODB_URI, {})
  .then(() => {
    console.log("✅ MongoDB connected");

    const PORT = process.env.PORT || 3000;

    /*****************************************
     * 🔥 FIX 4 — SERVER LISTEN 0.0.0.0
     * BẮT BUỘC để emulator truy cập được
     ****************************************/
    server.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server running on 0.0.0.0:${PORT}`);
    });
  })
  .catch((error) => {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1);
  });

module.exports = { app, server, io };
