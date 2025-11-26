require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const Match = require('../models/Match');
const ChatRoom = require('../models/ChatRoom');
const Message = require('../models/Message');

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // 1. Tìm tất cả user thật (không phải seed)
    const realUsers = await User.find({
      email: { $not: { $regex: /@example\.com$/ } }
    }).select('_id email firstName lastName');

    console.log(`📋 Found ${realUsers.length} real users (non-seed):`);
    realUsers.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName} (${u.email})`);
    });

    if (realUsers.length === 0) {
      console.log('\n✅ No real users found. Nothing to clean.');
      await mongoose.disconnect();
      process.exit(0);
    }

    const realUserIds = realUsers.map(u => u._id);

    console.log(`\n⚠️  WARNING: This will delete ALL swipe, match, and chat data for ${realUsers.length} real users!`);
    console.log('   This action CANNOT be undone.\n');

    // 2. Đếm dữ liệu sẽ bị xóa
    const swipeCount = await Swipe.countDocuments({
      $or: [
        { swiper: { $in: realUserIds } },
        { swiped: { $in: realUserIds } }
      ]
    });

    const matchCount = await Match.countDocuments({
      users: { $in: realUserIds }
    });

    const chatRoomCount = await ChatRoom.countDocuments({
      participants: { $in: realUserIds }
    });

    const messageCount = await Message.countDocuments({
      sender: { $in: realUserIds }
    });

    console.log('📊 Data to be deleted:');
    console.log(`   - Swipes: ${swipeCount}`);
    console.log(`   - Matches: ${matchCount}`);
    console.log(`   - Chat Rooms: ${chatRoomCount}`);
    console.log(`   - Messages: ${messageCount}`);

    // 3. Xác nhận
    console.log('\n❓ Type "DELETE" to confirm deletion:');
    
    // Trong môi trường script, có thể bỏ qua confirmation hoặc dùng readline
    // Để an toàn, tôi sẽ yêu cầu user chạy với flag --confirm
    const args = process.argv.slice(2);
    const confirmed = args.includes('--confirm');

    if (!confirmed) {
      console.log('\n⚠️  To actually delete, run with --confirm flag:');
      console.log('   node src/scripts/cleanup_real_users_data.js --confirm');
      await mongoose.disconnect();
      process.exit(0);
    }

    console.log('\n🗑️  Starting deletion...\n');

    // 4. Xóa Swipes
    console.log('Deleting Swipes...');
    const swipeResult = await Swipe.deleteMany({
      $or: [
        { swiper: { $in: realUserIds } },
        { swiped: { $in: realUserIds } }
      ]
    });
    console.log(`   ✅ Deleted ${swipeResult.deletedCount} swipes`);

    // 5. Xóa Matches
    console.log('Deleting Matches...');
    const matchResult = await Match.deleteMany({
      users: { $in: realUserIds }
    });
    console.log(`   ✅ Deleted ${matchResult.deletedCount} matches`);

    // 6. Xóa Messages (trước khi xóa ChatRoom)
    console.log('Deleting Messages...');
    const chatRoomIds = await ChatRoom.find({
      participants: { $in: realUserIds }
    }).distinct('_id');

    const messageResult = await Message.deleteMany({
      $or: [
        { sender: { $in: realUserIds } },
        { chatRoom: { $in: chatRoomIds } }
      ]
    });
    console.log(`   ✅ Deleted ${messageResult.deletedCount} messages`);

    // 7. Xóa ChatRooms
    console.log('Deleting Chat Rooms...');
    const chatRoomResult = await ChatRoom.deleteMany({
      participants: { $in: realUserIds }
    });
    console.log(`   ✅ Deleted ${chatRoomResult.deletedCount} chat rooms`);

    console.log('\n✅ Cleanup completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - Swipes deleted: ${swipeResult.deletedCount}`);
    console.log(`   - Matches deleted: ${matchResult.deletedCount}`);
    console.log(`   - Messages deleted: ${messageResult.deletedCount}`);
    console.log(`   - Chat Rooms deleted: ${chatRoomResult.deletedCount}`);

    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

