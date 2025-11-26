const chatService = require('../services/chat.service');
const { emitToChatRoom } = require('../websocket/socketHandler');

class ChatController {
  async getChatRooms(req, res, next) {
    try {
      const chatRooms = await chatService.getChatRooms(req.userId);
      res.json({
        success: true,
        data: { chatRooms: chatRooms.map(room => room.toPublicJSON ? room.toPublicJSON() : room) }
      });
    } catch (error) {
      next(error);
    }
  }

  async getChatRoomByMatch(req, res, next) {
    try {
      const chatRoom = await chatService.getChatRoomByMatch(req.params.matchId, req.userId);
      res.json({
        success: true,
        data: { chatRoom: chatRoom.toPublicJSON ? chatRoom.toPublicJSON() : chatRoom }
      });
    } catch (error) {
      next(error);
    }
  }

  async getChatRoomById(req, res, next) {
    try {
      const chatRoom = await chatService.getChatRoomById(req.params.chatRoomId, req.userId);
      res.json({
        success: true,
        data: { chatRoom: chatRoom.toPublicJSON ? chatRoom.toPublicJSON() : chatRoom }
      });
    } catch (error) {
      next(error);
    }
  }

  async sendMessage(req, res, next) {
    try {
      const { matchId, content, type, mediaUrl } = req.body;
      const { message, chatRoomId } = await chatService.sendMessage(
        req.userId,
        matchId,
        content,
        type,
        mediaUrl
      );
      emitToChatRoom(chatRoomId, 'new-message', {
        chatRoomId,
        message
      });
      res.status(201).json({
        success: true,
        data: { message }
      });
    } catch (error) {
      next(error);
    }
  }

  async getMessages(req, res, next) {
    try {
      const { chatRoomId } = req.params;
      const { limit = 50, before } = req.query;
      const messages = await chatService.getMessages(
        chatRoomId,
        req.userId,
        parseInt(limit),
        before ? new Date(before) : null
      );
      res.json({
        success: true,
        data: { messages }
      });
    } catch (error) {
      next(error);
    }
  }

  async markAsRead(req, res, next) {
    try {
      await chatService.markAsRead(req.params.chatRoomId, req.userId);
      emitToChatRoom(req.params.chatRoomId, 'messages-read', {
        chatRoomId: req.params.chatRoomId,
        userId: req.userId.toString()
      });
      res.json({
        success: true,
        message: 'Messages marked as read'
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ChatController();

