const userService = require('../services/user.service');

class UserController {
  async getProfile(req, res, next) {
    try {
      const user = await userService.getProfile(req.userId);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      // Debug payload từ client
      console.log('📝 [updateProfile] body:', req.body);
      const user = await userService.updateProfile(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateProfilePhotos(req, res, next) {
    try {
      // Debug payload từ client
      console.log('🖼️ [updateProfilePhotos] body:', req.body);
      const user = await userService.updateProfilePhotos(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async getDiscovery(req, res, next) {
    try {
      const results = await userService.getDiscovery(req.userId, req.query || {});
      res.json({
        success: true,
        data: {
          users: results.map(item => ({
            ...item.user.toPublicJSON(),
            score: item.score,
            scoreBreakdown: item.breakdown,
            distanceKm: item.distanceKm
          }))
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateLocation(req, res, next) {
    try {
      const user = await userService.updateLocation(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async changePassword(req, res, next) {
    try {
      const { oldPassword, newPassword } = req.body;
      const userId = req.userId;

      console.log('🔐 [changePassword] userId:', userId);

      // Import User model directly to access password field
      const User = require('../models/User');
      
      // Find user with password field (which is normally excluded)
      const user = await User.findById(userId).select('+password +firebaseUid');
      
      if (!user) {
        console.log('❌ [changePassword] User not found');
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }

      // Check if user has a password (users who sign in with Firebase/Google don't have password)
      if (!user.password || user.firebaseUid) {
        console.log('❌ [changePassword] User logged in via social auth, no password to change');
        return res.status(400).json({
          success: false,
          error: 'Cannot change password. You signed in with Google/Firebase. Please use "Forgot Password" to set a password first.'
        });
      }

      // Verify old password using existing comparePassword method
      const isValidPassword = await user.comparePassword(oldPassword);
      
      if (!isValidPassword) {
        console.log('❌ [changePassword] Current password is incorrect');
        return res.status(401).json({
          success: false,
          error: 'Current password is incorrect'
        });
      }

      // Set new password (will be automatically hashed by pre-save middleware)
      user.password = newPassword;
      await user.save();

      console.log('✅ [changePassword] Password changed successfully for user:', userId);

      res.json({
        success: true,
        message: 'Password changed successfully'
      });
    } catch (error) {
      console.error('❌ [changePassword] Error:', error.message);
      console.error('❌ [changePassword] Stack:', error.stack);
      next(error);
    }
  }

  async deleteAccount(req, res, next) {
    try {
      const { password } = req.body;
      const userId = req.userId;

      console.log('🗑️ [deleteAccount] userId:', userId);

      // Import all required models
      const User = require('../models/User');
      const DeviceToken = require('../models/DeviceToken');
      const Swipe = require('../models/Swipe');
      const Match = require('../models/Match');
      const Message = require('../models/Message');
      const ChatRoom = require('../models/ChatRoom');
      const Report = require('../models/Report');
      
      // Find user
      const user = await User.findById(userId).select('+password +firebaseUid');
      
      if (!user) {
        console.log('❌ [deleteAccount] User not found');
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }

      // Verify password for MongoDB-only users (non-Firebase)
      // Firebase users have password verified on frontend before calling this API
      if (user.password && !user.firebaseUid) {
        console.log('🔐 [deleteAccount] Verifying MongoDB password...');
        const isValidPassword = await user.comparePassword(password);
        
        if (!isValidPassword) {
          console.log('❌ [deleteAccount] Password verification failed');
          return res.status(401).json({
            success: false,
            error: 'Incorrect password'
          });
        }
        console.log('✅ [deleteAccount] MongoDB password verified');
      } else if (user.firebaseUid) {
        console.log('ℹ️ [deleteAccount] Firebase user - password already verified on client');
      }

      console.log('🔄 [deleteAccount] Starting HARD DELETE of all user data...');

      // 1. Delete all device tokens
      const deletedTokens = await DeviceToken.deleteMany({ user: userId });
      console.log(`   ✅ Deleted ${deletedTokens.deletedCount} device tokens`);

      // 2. Delete all swipes (both as swiper and swiped)
      const deletedSwipes = await Swipe.deleteMany({
        $or: [{ swiper: userId }, { swiped: userId }]
      });
      console.log(`   ✅ Deleted ${deletedSwipes.deletedCount} swipes`);

      // 3. Find all chat rooms involving this user
      const userChatRooms = await ChatRoom.find({ participants: userId }).select('_id');
      const chatRoomIds = userChatRooms.map(room => room._id);
      
      // 4. Delete all messages in those chat rooms
      if (chatRoomIds.length > 0) {
        const deletedMessages = await Message.deleteMany({ chatRoom: { $in: chatRoomIds } });
        console.log(`   ✅ Deleted ${deletedMessages.deletedCount} messages`);
      }

      // 5. Delete all chat rooms involving this user
      const deletedChatRooms = await ChatRoom.deleteMany({ participants: userId });
      console.log(`   ✅ Deleted ${deletedChatRooms.deletedCount} chat rooms`);

      // 6. Delete all matches involving this user
      const deletedMatches = await Match.deleteMany({ users: userId });
      console.log(`   ✅ Deleted ${deletedMatches.deletedCount} matches`);

      // 7. Delete all reports by/about this user
      const deletedReports = await Report.deleteMany({
        $or: [{ reporter: userId }, { reported: userId }]
      });
      console.log(`   ✅ Deleted ${deletedReports.deletedCount} reports`);

      // 8. Finally, delete the user record
      await User.findByIdAndDelete(userId);
      console.log(`   ✅ Deleted user record`);

      console.log('✅ [deleteAccount] HARD DELETE completed for user:', userId);
      console.log('📊 [deleteAccount] Summary:');
      console.log(`   - Device Tokens: ${deletedTokens.deletedCount}`);
      console.log(`   - Swipes: ${deletedSwipes.deletedCount}`);
      console.log(`   - Chat Rooms: ${deletedChatRooms.deletedCount}`);
      console.log(`   - Matches: ${deletedMatches.deletedCount}`);
      console.log(`   - Reports: ${deletedReports.deletedCount}`);

      res.json({
        success: true,
        message: 'Account and all associated data deleted permanently'
      });
    } catch (error) {
      console.error('❌ [deleteAccount] Error:', error.message);
      console.error('❌ [deleteAccount] Stack:', error.stack);
      next(error);
    }
  }
}

module.exports = new UserController();

