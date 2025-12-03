const Swipe = require('../models/Swipe');
const Match = require('../models/Match');
const ChatRoom = require('../models/ChatRoom');

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

class SwipeRepository {

  // Tạo swipe mới
  async create(swipeData) {
    return await Swipe.create(swipeData);
  }

  // Kiểm tra swipe trước đó
  async findExisting(swiperId, swipedId) {
    return await Swipe.findOne({ swiper: swiperId, swiped: swipedId });
  }

  // Check xem có phải match không
  async checkForMatch(swiperId, swipedId) {
    const mutualLike = await Swipe.findOne({
      swiper: swipedId,
      swiped: swiperId,
      action: { $in: ['like', 'superlike'] }
    });

    return mutualLike !== null;
  }

  // Tạo match + chatroom
  async createMatch(user1Id, user2Id) {
    const existingMatch = await Match.findOne({
      users: { $all: [user1Id, user2Id] }
    });

    if (existingMatch) {
      const chatRoom = await ChatRoom.findOne({ match: existingMatch._id }).populate('participants', PUBLIC_USER_FIELDS);
      const populatedMatch = await existingMatch.populate('users', PUBLIC_USER_FIELDS);

      return {
        match: populatedMatch.toPublicJSON(),
        chatRoom: chatRoom ? chatRoom.toPublicJSON() : null
      };
    }

    const sortedUsers = [user1Id, user2Id].sort((a, b) => {
      const idA = a.toString();
      const idB = b.toString();
      return idA.localeCompare(idB);
    });

    const match = await Match.create({
      users: sortedUsers,
      matchedAt: new Date()
    });

    const chatRoom = await ChatRoom.create({
      match: match._id,
      participants: [user1Id, user2Id],
      unreadCount: new Map([
        [user1Id.toString(), 0],
        [user2Id.toString(), 0]
      ])
    });

    const populatedMatch = await match.populate('users', PUBLIC_USER_FIELDS);
    const populatedRoom = await ChatRoom.findById(chatRoom._id).populate('participants', PUBLIC_USER_FIELDS);

    return {
      match: populatedMatch.toPublicJSON(),
      chatRoom: populatedRoom.toPublicJSON()
    };
  }

  // Lấy danh sách đã swipe
  async getSwipedUserIds(userId) {
    const swipes = await Swipe.find({ swiper: userId }).select('swiped');
    return swipes.map(swipe => swipe.swiped.toString());
  }

  // Lịch sử swipe
  async getUserSwipeHistory(userId, limit = 50) {
    return await Swipe.find({ swiper: userId })
      .populate('swiped', PUBLIC_USER_FIELDS)
      .sort({ createdAt: -1 })
      .limit(limit);
  }

  // 🔥 Hàm mới — xóa toàn bộ swipe của 1 người
  async deleteByUser(userId) {
    await Swipe.deleteMany({
      $or: [
        { swiper: userId },
        { swiped: userId }
      ]
    });
  }
}

module.exports = new SwipeRepository();
