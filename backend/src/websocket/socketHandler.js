const jwt = require('jsonwebtoken');
const { verifyFirebaseToken } = require('../config/firebase');
const User = require('../models/User');
const chatRepository = require('../repositories/chat.repository');
const matchRepository = require('../repositories/match.repository');
const ChatRoom = require('../models/ChatRoom');

const connectedUsers = new Map(); // userId -> socketId
let ioInstance = null;

const initializeSocketIO = (io) => {
  ioInstance = io;
  // Authentication middleware for Socket.IO
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      // Try JWT first
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userId);
        if (!user) {
          return next(new Error('Authentication error: User not found'));
        }
        socket.userId = user._id.toString();
        socket.user = user;
      } catch (jwtError) {
        // Try Firebase token
        try {
          const firebaseUser = await verifyFirebaseToken(token);
          const user = await User.findOne({ firebaseUid: firebaseUser.uid });
          if (!user) {
            return next(new Error('Authentication error: User not found'));
          }
          socket.userId = user._id.toString();
          socket.user = user;
        } catch (firebaseError) {
          return next(new Error('Authentication error: Invalid token'));
        }
      }

      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`✅ User connected: ${socket.userId}`);

    // Store user connection
    connectedUsers.set(socket.userId, socket.id);

    // Join user's personal room
    socket.join(`user:${socket.userId}`);

    // Send list of currently online users to the newly connected user
    const onlineUserIds = Array.from(connectedUsers.keys()).filter(id => id !== socket.userId);
    socket.emit('online-users-list', {
      userIds: onlineUserIds,
      timestamp: new Date().toISOString()
    });

    // Notify all OTHER connected users that this user is now online
    socket.broadcast.emit('user-online', {
      userId: socket.userId,
      timestamp: new Date().toISOString()
    });

    // Join all user's chat rooms
    socket.on('join-chat-rooms', async () => {
      try {
        const chatRooms = await chatRepository.findChatRoomsByUser(socket.userId);
        chatRooms.forEach(room => {
          socket.join(`chat:${room._id}`);
        });
        socket.emit('chat-rooms-joined', { count: chatRooms.length });
      } catch (error) {
        socket.emit('error', { message: 'Failed to join chat rooms' });
      }
    });

    // Join a specific chat room
    socket.on('join-chat-room', async (chatRoomId) => {
      try {
        socket.join(`chat:${chatRoomId}`);
        socket.emit('chat-room-joined', { chatRoomId });
      } catch (error) {
        socket.emit('error', { message: 'Failed to join chat room' });
      }
    });

    // Leave a chat room
    socket.on('leave-chat-room', (chatRoomId) => {
      socket.leave(`chat:${chatRoomId}`);
      socket.emit('chat-room-left', { chatRoomId });
    });

    // Send message
    socket.on('send-message', async (data) => {
      try {
        const { chatRoomId, content, type, mediaUrl } = data;

        if (!chatRoomId || !content) {
          return socket.emit('error', { message: 'chatRoomId and content are required' });
        }

        const chatRoom = await ChatRoom.findById(chatRoomId);
        if (!chatRoom) {
          return socket.emit('error', { message: 'Chat room not found' });
        }

        if (!chatRoom.participants.some(p => p.toString() === socket.userId)) {
          return socket.emit('error', { message: 'Not authorized to send message in this chat room' });
        }

        const message = await chatRepository.createMessage({
          chatRoom: chatRoomId,
          sender: socket.userId,
          content,
          type,
          mediaUrl
        });

        await matchRepository.updateLastMessage(chatRoom.match, message.id, content);

        io.to(`chat:${chatRoomId}`).emit('new-message', {
          chatRoomId,
          message
        });
      } catch (error) {
        console.error('Socket send-message error:', error);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // Typing indicator
    socket.on('typing', (data) => {
      const { chatRoomId, isTyping } = data;
      socket.to(`chat:${chatRoomId}`).emit('user-typing', {
        userId: socket.userId,
        isTyping
      });
    });

    // Mark messages as read
    socket.on('mark-read', async (data) => {
      try {
        const { chatRoomId } = data;
        await chatRepository.markAsRead(chatRoomId, socket.userId);
        
        // Notify other users in the room
        socket.to(`chat:${chatRoomId}`).emit('messages-read', {
          userId: socket.userId,
          chatRoomId
        });
      } catch (error) {
        socket.emit('error', { message: 'Failed to mark messages as read' });
      }
    });

    // Disconnect
    socket.on('disconnect', () => {
      console.log(`❌ User disconnected: ${socket.userId}`);
      
      // Notify all connected users that this user is now offline
      socket.broadcast.emit('user-offline', {
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });
      
      connectedUsers.delete(socket.userId);
    });
  });
};

const getSocketId = (userId) => {
  return connectedUsers.get(userId?.toString());
};

const emitToUser = (userId, event, data) => {
  if (!ioInstance) return;
  const socketId = getSocketId(userId);
  if (socketId) {
    ioInstance.to(socketId).emit(event, data);
  }
};

const emitToChatRoom = (chatRoomId, event, data) => {
  if (!ioInstance || !chatRoomId) return;
  ioInstance.to(`chat:${chatRoomId}`).emit(event, data);
};

module.exports = {
  initializeSocketIO,
  getSocketId,
  emitToUser,
  emitToChatRoom
};

