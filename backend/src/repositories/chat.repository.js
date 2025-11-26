const ChatRoom = require('../models/ChatRoom');
const Message = require('../models/Message');

const PUBLIC_USER_FIELDS = [
  'firstName',
  'lastName',
  'dateOfBirth',
  'gender',
  'photos',
  'interests',
  'interestedIn',
  'bio',
  'location',
  'isVerified',
  'isActive',
  'isProfileComplete',
  'lastActive',
  'preferences'
].join(' ');

const formatMessage = (messageDoc) => {
  if (!messageDoc) return null;
  const message = messageDoc.toObject({ virtuals: true });
  message.id = message._id.toString();
  delete message._id;

  if (message.sender && message.sender._id) {
    message.sender.id = message.sender._id.toString();
    delete message.sender._id;
  }

  return message;
};

class ChatRepository {
  async findChatRoomByMatch(matchId) {
    return await ChatRoom.findOne({ match: matchId })
      .populate('participants', PUBLIC_USER_FIELDS)
      .populate({
        path: 'lastMessage',
        populate: { path: 'sender', select: PUBLIC_USER_FIELDS }
      });
  }

  async findChatRoomById(chatRoomId) {
    return await ChatRoom.findById(chatRoomId)
      .populate('participants', PUBLIC_USER_FIELDS)
      .populate({
        path: 'lastMessage',
        populate: { path: 'sender', select: PUBLIC_USER_FIELDS }
      });
  }

  async findChatRoomsByUser(userId) {
    return await ChatRoom.find({
      participants: userId,
      isActive: true
    })
      .populate('participants', PUBLIC_USER_FIELDS)
      .populate('match', 'matchedAt')
      .populate({
        path: 'lastMessage',
        populate: { path: 'sender', select: PUBLIC_USER_FIELDS }
      })
      .sort({ lastMessageAt: -1 });
  }

  async createMessage(messageData) {
    const chatRoom = await ChatRoom.findById(messageData.chatRoom);
    if (!chatRoom) {
      throw new Error('Chat room not found');
    }

    const message = await Message.create({
      chatRoom: messageData.chatRoom,
      sender: messageData.sender,
      content: messageData.content,
      type: messageData.type || 'text',
      mediaUrl: messageData.mediaUrl
    });

    const unreadIncrement = {};
    chatRoom.participants.forEach(participant => {
      const participantId = participant.toString();
      if (participantId !== messageData.sender.toString()) {
        unreadIncrement[`unreadCount.${participantId}`] = 1;
      }
    });

    const updatePayload = {
      lastMessage: message._id,
      lastMessageAt: message.createdAt
    };

    await ChatRoom.findByIdAndUpdate(messageData.chatRoom, {
      $set: updatePayload,
      ...(Object.keys(unreadIncrement).length ? { $inc: unreadIncrement } : {})
    });

    return formatMessage(await message.populate('sender', PUBLIC_USER_FIELDS));
  }

  async getMessages(chatRoomId, limit = 50, before = null) {
    const query = { chatRoom: chatRoomId, isDeleted: false };
    if (before) {
      query.createdAt = { $lt: before };
    }

    const messages = await Message.find(query)
      .populate('sender', PUBLIC_USER_FIELDS)
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    return messages
      .reverse()
      .map(message => {
        const formatted = {
          ...message,
          id: message._id.toString()
        };
        delete formatted._id;
        if (formatted.sender?._id) {
          formatted.sender.id = formatted.sender._id.toString();
          delete formatted.sender._id;
        }
        return formatted;
      });
  }

  async markAsRead(chatRoomId, userId) {
    await Message.updateMany(
      {
        chatRoom: chatRoomId,
        sender: { $ne: userId },
        isRead: false
      },
      {
        isRead: true,
        readAt: new Date()
      }
    );

    // Reset unread count
    await ChatRoom.findByIdAndUpdate(chatRoomId, {
      $set: { [`unreadCount.${userId}`]: 0 }
    });
  }

  async updateTypingStatus(chatRoomId, userId, isTyping) {
    // This would typically be handled via WebSocket, but we can store it here if needed
    // For now, we'll handle typing indicators via WebSocket only
  }
}

module.exports = new ChatRepository();

