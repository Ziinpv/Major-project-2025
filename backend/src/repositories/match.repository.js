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

class MatchRepository {
  async findById(matchId) {
    return await Match.findById(matchId).populate('users', PUBLIC_USER_FIELDS);
  }

  async findByUserId(userId) {
    return await Match.find({
      users: userId,
      isActive: true
    })
      .populate('users', PUBLIC_USER_FIELDS)
      .sort({ matchedAt: -1 });
  }

  async findMatchBetweenUsers(user1Id, user2Id) {
    return await Match.findOne({
      users: { $all: [user1Id, user2Id] },
      isActive: true
    }).populate('users', PUBLIC_USER_FIELDS);
  }

  async unmatch(matchId, userId) {
    return await Match.findByIdAndUpdate(
      matchId,
      {
        isActive: false,
        unmatchedAt: new Date(),
        unmatchedBy: userId
      },
      { new: true }
    );
  }

  async updateLastMessage(matchId, messageId, messageContent) {
    await Match.findByIdAndUpdate(matchId, {
      lastMessageAt: new Date(),
      lastMessage: messageContent
    });

    // Also update chat room
    await ChatRoom.findOneAndUpdate(
      { match: matchId },
      {
        lastMessage: messageId,
        lastMessageAt: new Date()
      }
    );
  }
}

module.exports = new MatchRepository();

