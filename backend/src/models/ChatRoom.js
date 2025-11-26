const mongoose = require('mongoose');

const chatRoomSchema = new mongoose.Schema({
  match: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Match',
    required: true,
    unique: true,
    index: true
  },
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  lastMessage: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  },
  lastMessageAt: {
    type: Date
  },
  unreadCount: {
    type: Map,
    of: Number,
    default: {}
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Index for finding user's chat rooms
chatRoomSchema.index({ participants: 1, isActive: 1, lastMessageAt: -1 });

// Method to get public JSON (without sensitive data, with proper formatting)
const safeObjectIdString = (value) => {
  if (!value) return '';
  if (typeof value === 'string') return value;
  if (typeof value === 'object' && value !== null && typeof value.toHexString === 'function') {
    try {
      return value.toHexString();
    } catch {
      return '';
    }
  }
  if (typeof value === 'object' && value !== null) {
    if (value._id && value._id !== value) {
      const nested = safeObjectIdString(value._id);
      if (nested) return nested;
    }
    if (typeof value.id === 'string') {
      return value.id;
    }
    if (typeof value.toString === 'function') {
      try {
        return value.toString();
      } catch {
        return '';
      }
    }
    return '';
  }
  return String(value);
};

chatRoomSchema.methods.toPublicJSON = function() {
  const room = this.toObject({ virtuals: true });
  
  // Convert _id to id
  if (room._id) {
    room.id = safeObjectIdString(room._id);
    delete room._id;
  }
  
  // Convert match ObjectId to string
  if (room.match) {
    room.match = safeObjectIdString(room.match);
  }
  
  // Format participants array
  if (room.participants && Array.isArray(room.participants)) {
    room.participants = room.participants.map(participant => {
      if (!participant) return participant;
      if (typeof participant.toPublicJSON === 'function') {
        return participant.toPublicJSON();
      }
      if (typeof participant === 'object') {
        const participantObj = { ...participant };
        if (participantObj._id) {
          participantObj.id = safeObjectIdString(participantObj._id);
          delete participantObj._id;
        }
        // Ensure arrays are not null
        if (!participantObj.photos) participantObj.photos = [];
        if (!participantObj.interests) participantObj.interests = [];
        if (!participantObj.interestedIn) participantObj.interestedIn = [];
        return participantObj;
      }
      return participant;
    });
  } else {
    room.participants = [];
  }
  
  // Format lastMessage if populated
  if (room.lastMessage) {
    if (typeof room.lastMessage === 'object' && room.lastMessage !== null) {
      const msgObj = typeof room.lastMessage.toObject === 'function'
        ? room.lastMessage.toObject({ virtuals: true })
        : { ...room.lastMessage };

      if (msgObj._id) {
        msgObj.id = safeObjectIdString(msgObj._id);
        delete msgObj._id;
      }

      if (msgObj.sender) {
        const looksLikeObjectId =
          typeof msgObj.sender === 'object' &&
          msgObj.sender !== null &&
          typeof msgObj.sender.toHexString === 'function' &&
          Object.keys(msgObj.sender).length <= 1;

        const isPopulatedSender =
          typeof msgObj.sender === 'object' &&
          msgObj.sender !== null &&
          !looksLikeObjectId &&
          (typeof msgObj.sender.toObject === 'function' || msgObj.sender._id);

        if (isPopulatedSender) {
          const senderObj = typeof msgObj.sender.toObject === 'function'
            ? msgObj.sender.toObject({ virtuals: true })
            : { ...msgObj.sender };
          if (senderObj._id) {
            senderObj.id = safeObjectIdString(senderObj._id);
            delete senderObj._id;
          }
          msgObj.sender = senderObj;
        } else {
          msgObj.sender = safeObjectIdString(msgObj.sender);
        }
      }

      if (msgObj.chatRoom) {
        msgObj.chatRoom = safeObjectIdString(msgObj.chatRoom);
      }
      if (msgObj.createdAt) {
        msgObj.createdAt = new Date(msgObj.createdAt).toISOString();
      }
      if (msgObj.updatedAt) {
        msgObj.updatedAt = new Date(msgObj.updatedAt).toISOString();
      }
      room.lastMessage = msgObj;
    } else if (typeof room.lastMessage.toString === 'function') {
      // If it's just an ObjectId, convert to string
      room.lastMessage = safeObjectIdString(room.lastMessage);
    }
  }
  
  // Convert dates to ISO strings
  if (room.lastMessageAt) {
    room.lastMessageAt = new Date(room.lastMessageAt).toISOString();
  }
  if (room.createdAt) {
    room.createdAt = new Date(room.createdAt).toISOString();
  }
  if (room.updatedAt) {
    room.updatedAt = new Date(room.updatedAt).toISOString();
  }
  
  // Convert unreadCount Map to plain object
  if (room.unreadCount instanceof Map) {
    const unreadObj = {};
    room.unreadCount.forEach((value, key) => {
      unreadObj[key] = value;
    });
    room.unreadCount = unreadObj;
  } else if (!room.unreadCount || typeof room.unreadCount !== 'object') {
    room.unreadCount = {};
  }
  
  // Ensure boolean defaults
  if (room.isActive === undefined || room.isActive === null) {
    room.isActive = true;
  }
  
  return room;
};

module.exports = mongoose.model('ChatRoom', chatRoomSchema);

