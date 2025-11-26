require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const ANH_ID = '6925d58e438e74a43c43f1cb';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // 1. Lấy tất cả user thật
    const allRealUsers = await User.find({
      email: { $not: { $regex: /@example\.com$/ } }
    }).select('_id firstName lastName email isActive isProfileComplete lastActive createdAt');

    console.log(`📋 Total real users: ${allRealUsers.length}\n`);

    // 2. Kiểm tra trạng thái của từng user
    const now = new Date();
    const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    console.log('📊 User Status Analysis:\n');
    allRealUsers.forEach(user => {
      const lastActive = user.lastActive ? new Date(user.lastActive) : null;
      const isOnline = lastActive && lastActive >= fiveMinutesAgo;
      const isActiveToday = lastActive && lastActive >= oneDayAgo;
      
      let status = '';
      if (!user.isActive) status = '❌ INACTIVE';
      else if (!user.isProfileComplete) status = '⚠️ INCOMPLETE';
      else if (isOnline) status = '🟢 ONLINE (last 5 min)';
      else if (lastActive && lastActive >= oneHourAgo) status = '🟡 RECENT (last hour)';
      else if (isActiveToday) status = '🟠 TODAY';
      else if (lastActive) status = `🔴 OFFLINE (${Math.floor((now - lastActive) / (1000 * 60 * 60))}h ago)`;
      else status = '⚫ NEVER ACTIVE';

      console.log(`${user.firstName} ${user.lastName} (${user.email}):`);
      console.log(`   Status: ${status}`);
      console.log(`   isActive: ${user.isActive}, isProfileComplete: ${user.isProfileComplete}`);
      console.log(`   lastActive: ${lastActive ? lastActive.toISOString() : 'null'}`);
      console.log(`   createdAt: ${new Date(user.createdAt).toISOString()}`);
      console.log('');
    });

    // 3. Kiểm tra filter onlyShowOnline
    const longUser = await User.findById(LONG_ID);
    const anhUser = await User.findById(ANH_ID);

    console.log('🔍 Filter Settings:\n');
    console.log(`Long - onlyShowOnline: ${longUser.preferences?.onlyShowOnline || false}`);
    console.log(`Ánh - onlyShowOnline: ${anhUser.preferences?.onlyShowOnline || false}\n`);

    // 4. Đếm user thỏa điều kiện "online" (lastActive trong 5 phút)
    const onlineUsers = allRealUsers.filter(u => {
      if (!u.isActive || !u.isProfileComplete) return false;
      if (!u.lastActive) return false;
      return new Date(u.lastActive) >= fiveMinutesAgo;
    });

    console.log(`🟢 Users considered "online" (last 5 min): ${onlineUsers.length}`);
    onlineUsers.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName}`);
    });

    // 5. Đếm user active trong 24h
    const activeToday = allRealUsers.filter(u => {
      if (!u.isActive || !u.isProfileComplete) return false;
      if (!u.lastActive) return false;
      return new Date(u.lastActive) >= oneDayAgo;
    });

    console.log(`\n🟠 Users active in last 24h: ${activeToday.length}`);
    activeToday.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName}`);
    });

    // 6. Kiểm tra xem có user nào chưa có lastActive không
    const neverActive = allRealUsers.filter(u => !u.lastActive);
    if (neverActive.length > 0) {
      console.log(`\n⚫ Users never active (lastActive = null): ${neverActive.length}`);
      neverActive.forEach(u => {
        console.log(`   - ${u.firstName} ${u.lastName}`);
      });
    }

    await mongoose.disconnect();
    console.log('\n✅ Analysis complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

