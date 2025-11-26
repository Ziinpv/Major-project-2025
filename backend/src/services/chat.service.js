const chatRepository = require('../repositories/chat.repository');
const matchRepository = require('../repositories/match.repository');
const { getMessaging } = require('../config/firebase');
const DeviceToken = require('../models/DeviceToken');
const User = require('../models/User');

class ChatService {
  async getChatRooms(userId) {
    return await chatRepository.findChatRoomsByUser(userId);
  }

  async getChatRoomByMatch(matchId, userId) {
    const chatRoom = await chatRepository.findChatRoomByMatch(matchId);
    if (!chatRoom) {
      throw new Error('Chat room not found');
    }
    if (!chatRoom.participants.some(p => p._id.toString() === userId.toString())) {
      throw new Error('Not authorized to access this chat room');
    }
    return chatRoom;
  }

  async getChatRoomById(chatRoomId, userId) {
    const chatRoom = await chatRepository.findChatRoomById(chatRoomId);
    if (!chatRoom) {
      throw new Error('Chat room not found');
    }
    if (!chatRoom.participants.some(p => p._id.toString() === userId.toString())) {
      throw new Error('Not authorized to access this chat room');
    }
    return chatRoom;
  }

  async sendMessage(userId, matchId, content, type = 'text', mediaUrl = null) {
    if (!content) {
      throw new Error('Message content is required');
    }

    const match = await matchRepository.findById(matchId);
    if (!match || !match.users.some(u => u._id.toString() === userId.toString())) {
      throw new Error('Not authorized to send message in this match');
    }

    const chatRoom = await chatRepository.findChatRoomByMatch(matchId);
    if (!chatRoom) {
      throw new Error('Chat room not found');
    }

    const message = await chatRepository.createMessage({
      chatRoom: chatRoom._id,
      sender: userId,
      content,
      type,
      mediaUrl
    });

    await matchRepository.updateLastMessage(matchId, message.id, content);
    await this.notifyNewMessage(chatRoom, userId, content);

    return {
      message,
      chatRoomId: chatRoom._id.toString()
    };
  }

  async getMessages(chatRoomId, userId, limit = 50, before = null) {
    // Verify user has access to this chat room
    const ChatRoom = require('../models/ChatRoom');
    const chatRoom = await ChatRoom.findById(chatRoomId);
    if (!chatRoom || !chatRoom.participants.some(p => p.toString() === userId)) {
      throw new Error('Not authorized to access this chat room');
    }

    const messages = await chatRepository.getMessages(chatRoomId, limit, before);
    
    // Mark as read
    await chatRepository.markAsRead(chatRoomId, userId);

    return messages;
  }

  async markAsRead(chatRoomId, userId) {
    await chatRepository.markAsRead(chatRoomId, userId);
  }

  async notifyNewMessage(chatRoom, senderId, content) {
    try {
      // Get recipient (the other user in the chat)
      const recipientId = chatRoom.participants.find(
        p => p._id.toString() !== senderId.toString()
      );

      if (!recipientId) return;

      // Get recipient's device tokens
      const tokens = await DeviceToken.find({
        user: recipientId,
        isActive: true
      });

      if (tokens.length === 0) return;

      // Get sender info
      const sender = await User.findById(senderId).select('firstName');

      // Send notifications
      const messaging = getMessaging();
      const messages = tokens.map(token => ({
        token: token.token,
        notification: {
          title: sender.firstName,
          body: content.length > 50 ? content.substring(0, 50) + '...' : content
        },
        data: {
          type: 'message',
          chatRoomId: chatRoom._id.toString(),
          senderId: senderId.toString()
        }
      }));

      await messaging.sendEach(messages);
    } catch (error) {
      console.error('Error sending message notification:', error);
    }
  }
}

module.exports = new ChatService();

