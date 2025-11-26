const express = require('express');
const { body } = require('express-validator');
const chatController = require('../controllers/chat.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.get('/rooms', chatController.getChatRooms.bind(chatController));
router.get('/rooms/:matchId', chatController.getChatRoomByMatch.bind(chatController));
router.get('/room-id/:chatRoomId', chatController.getChatRoomById.bind(chatController));
router.post(
  '/messages',
  [
    body('matchId').notEmpty().withMessage('Match ID is required'),
    body('content').notEmpty().withMessage('Message content is required')
  ],
  chatController.sendMessage.bind(chatController)
);
router.get('/rooms/:chatRoomId/messages', chatController.getMessages.bind(chatController));
router.put('/rooms/:chatRoomId/read', chatController.markAsRead.bind(chatController));

module.exports = router;

