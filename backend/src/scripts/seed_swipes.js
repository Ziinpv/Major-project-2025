require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const Match = require('../models/Match');
const ChatRoom = require('../models/ChatRoom');

const targetUserId = process.argv[2];

if (!targetUserId) {
  console.error('❌ Missing target user id. Usage: node src/scripts/seed_swipes.js <userId>');
  process.exit(1);
}

const upsertSwipe = async (swiperId, swipedId) => {
  await Swipe.updateOne(
    { swiper: swiperId, swiped: swipedId },
    {
      $set: { action: 'like' },
      $setOnInsert: { swiper: swiperId, swiped: swipedId }
    },
    { upsert: true }
  );
};

const ensureMatchAndChatRoom = async (userA, userB) => {
  // Sort users array to ensure consistent indexing (for unique index on users.0 and users.1)
  const sortedUsers = [userA, userB].sort((a, b) => {
    const idA = a.toString ? a.toString() : a;
    const idB = b.toString ? b.toString() : b;
    return idA.localeCompare(idB);
  });
  
  let match = await Match.findOne({ users: { $all: [userA, userB] } });
  if (!match) {
    match = await Match.create({ users: sortedUsers, matchedAt: new Date() });
  }
  let chatRoom = await ChatRoom.findOne({ match: match._id });
  if (!chatRoom) {
    chatRoom = await ChatRoom.create({ 
      match: match._id, 
      participants: [userA, userB], 
      unreadCount: new Map([
        [userA.toString(), 0],
        [userB.toString(), 0]
      ])
    });
  }
};

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const targetUser = await User.findById(targetUserId);
    if (!targetUser) {
      console.error('❌ Target user not found');
      process.exit(1);
    }

    const otherUsers = await User.find({
      isProfileComplete: true,
      _id: { $ne: targetUserId }
    }).select('_id firstName');

    console.log(`🔄 Preparing ${otherUsers.length} users to match with ${targetUser.firstName}`);

    for (const other of otherUsers) {
      await upsertSwipe(other._id, targetUserId);
      await upsertSwipe(targetUserId, other._id);
      await ensureMatchAndChatRoom(other._id, targetUserId);
    }

    console.log('🎉 Completed seeding mutual matches & chat rooms');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed swipe script failed:', error);
    process.exit(1);
  }
})();

