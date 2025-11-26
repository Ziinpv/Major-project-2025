const swipeRepository = require('../repositories/swipe.repository');
const { getMessaging } = require('../config/firebase');
const DeviceToken = require('../models/DeviceToken');
const { emitToUser } = require('../websocket/socketHandler');

class SwipeService {
  async swipe(userId, swipedUserId, action) {
    // Check if already swiped
    const existingSwipe = await swipeRepository.findExisting(userId, swipedUserId);
    if (existingSwipe) {
      throw new Error('Already swiped on this user');
    }

    // Create swipe
    const swipe = await swipeRepository.create({
      swiper: userId,
      swiped: swipedUserId,
      action
    });

    // Check for match (only if action is 'like' or 'superlike')
    let match = null;
    let chatRoom = null;
    if (action === 'like' || action === 'superlike') {
      const isMatch = await swipeRepository.checkForMatch(userId, swipedUserId);
      
      if (isMatch) {
        const result = await swipeRepository.createMatch(userId, swipedUserId);
        match = result.match;
        chatRoom = result.chatRoom;
        
        // Send push notification to both users
        await this.notifyMatch(userId, swipedUserId);
        emitToUser(userId, 'match:created', { match, chatRoom });
        emitToUser(swipedUserId, 'match:created', { match, chatRoom });
      }
    }

    return {
      swipe,
      match,
      chatRoom,
      isMatch: match !== null
    };
  }

  async notifyMatch(user1Id, user2Id) {
    try {
      // Get device tokens for both users
      const tokens1 = await DeviceToken.find({ user: user1Id, isActive: true });
      const tokens2 = await DeviceToken.find({ user: user2Id, isActive: true });

      // Get user info for notification
      const User = require('../models/User');
      const user1 = await User.findById(user1Id).select('firstName');
      const user2 = await User.findById(user2Id).select('firstName');

      const messaging = getMessaging();

      // Send notification to user1
      if (tokens1.length > 0) {
        const messages1 = tokens1.map(token => ({
          token: token.token,
          notification: {
            title: 'New Match! 🎉',
            body: `You and ${user2.firstName} liked each other!`
          },
          data: {
            type: 'match',
            matchId: user2Id.toString()
          }
        }));

        await messaging.sendEach(messages1);
      }

      // Send notification to user2
      if (tokens2.length > 0) {
        const messages2 = tokens2.map(token => ({
          token: token.token,
          notification: {
            title: 'New Match! 🎉',
            body: `You and ${user1.firstName} liked each other!`
          },
          data: {
            type: 'match',
            matchId: user1Id.toString()
          }
        }));

        await messaging.sendEach(messages2);
      }
    } catch (error) {
      console.error('Error sending match notification:', error);
      // Don't throw - notification failure shouldn't break the swipe
    }
  }

  async getSwipeHistory(userId) {
    return await swipeRepository.getUserSwipeHistory(userId);
  }
}

module.exports = new SwipeService();

