require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const userRepository = require('../repositories/user.repository');
const userService = require('../services/user.service');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const ANH_ID = '6925d58e438e74a43c43f1cb';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // 1. Tổng số user thật (non-seed)
    const allRealUsers = await User.find({
      email: { $not: { $regex: /@example\.com$/ } },
      isActive: true,
      isProfileComplete: true
    });

    console.log(`📋 Total real users (active + complete): ${allRealUsers.length}`);
    allRealUsers.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName} (${u.email}) - ${u.gender}`);
    });

    // 2. Kiểm tra cho Long
    console.log('\n🔍 === DISCOVERY FOR LONG ===');
    const longUser = await User.findById(LONG_ID);
    if (!longUser) {
      console.log('❌ Long not found');
      process.exit(1);
    }

    console.log(`User: ${longUser.firstName} ${longUser.lastName}`);
    console.log(`Gender: ${longUser.gender}`);
    console.log(`Preferences:`, {
      showMe: longUser.preferences?.showMe || [],
      ageRange: longUser.preferences?.ageRange,
      maxDistance: longUser.preferences?.maxDistance,
      onlyShowOnline: longUser.preferences?.onlyShowOnline
    });
    console.log(`Location: ${longUser.location?.province}, ${longUser.location?.city}`);
    console.log(`Has coordinates: ${!!longUser.location?.coordinates}`);

    const longSwiped = await Swipe.find({ swiper: LONG_ID }).distinct('swiped');
    console.log(`Already swiped: ${longSwiped.length} users`);

    // Test với filters mặc định
    const longCandidates = await userRepository.findCandidatesForDiscovery(
      longUser,
      longSwiped,
      {} // no filters
    );
    console.log(`\nCandidates from DB (no filters): ${longCandidates.length}`);

    // Test với filters từ frontend (age 20-35, showMe male/female)
    const frontendFilters = {
      ageMin: 20,
      ageMax: 35,
      showMe: ['male', 'female'],
      distance: 50
    };
    const longCandidatesFiltered = await userRepository.findCandidatesForDiscovery(
      longUser,
      longSwiped,
      frontendFilters
    );
    console.log(`Candidates with frontend filters (age 20-35, showMe male/female): ${longCandidatesFiltered.length}`);

    // Chi tiết từng user bị loại
    const excluded = longCandidates.filter(c => !longCandidatesFiltered.includes(c));
    console.log(`\nExcluded by filters: ${excluded.length}`);
    excluded.slice(0, 5).forEach(u => {
      const age = new Date().getFullYear() - new Date(u.dateOfBirth).getFullYear();
      console.log(`   - ${u.firstName} ${u.lastName}: age=${age}, gender=${u.gender}`);
    });

    // 3. Kiểm tra cho Ánh
    console.log('\n🔍 === DISCOVERY FOR ÁNH ===');
    const anhUser = await User.findById(ANH_ID);
    if (!anhUser) {
      console.log('❌ Ánh not found');
      process.exit(1);
    }

    console.log(`User: ${anhUser.firstName} ${anhUser.lastName}`);
    console.log(`Gender: ${anhUser.gender}`);
    console.log(`Preferences:`, {
      showMe: anhUser.preferences?.showMe || [],
      ageRange: anhUser.preferences?.ageRange,
      maxDistance: anhUser.preferences?.maxDistance,
      onlyShowOnline: anhUser.preferences?.onlyShowOnline
    });
    console.log(`Location: ${anhUser.location?.province}, ${anhUser.location?.city}`);
    console.log(`Has coordinates: ${!!anhUser.location?.coordinates}`);

    const anhSwiped = await Swipe.find({ swiper: ANH_ID }).distinct('swiped');
    console.log(`Already swiped: ${anhSwiped.length} users`);

    const anhCandidates = await userRepository.findCandidatesForDiscovery(
      anhUser,
      anhSwiped,
      {}
    );
    console.log(`\nCandidates from DB (no filters): ${anhCandidates.length}`);

    const anhCandidatesFiltered = await userRepository.findCandidatesForDiscovery(
      anhUser,
      anhSwiped,
      frontendFilters
    );
    console.log(`Candidates with frontend filters: ${anhCandidatesFiltered.length}`);

    // 4. Kiểm tra xem Long và Ánh có trong danh sách của nhau không
    console.log('\n🔗 === MUTUAL VISIBILITY ===');
    const longSeesAnh = longCandidatesFiltered.some(c => c._id.toString() === ANH_ID);
    const anhSeesLong = anhCandidatesFiltered.some(c => c._id.toString() === LONG_ID);
    console.log(`Long sees Ánh: ${longSeesAnh}`);
    console.log(`Ánh sees Long: ${anhSeesLong}`);

    // 5. Phân tích tại sao các user thật khác không xuất hiện
    console.log('\n📊 === ANALYSIS ===');
    const otherRealUsers = allRealUsers.filter(u => 
      u._id.toString() !== LONG_ID && u._id.toString() !== ANH_ID
    );
    console.log(`Other real users: ${otherRealUsers.length}`);

    if (otherRealUsers.length > 0) {
      console.log('\nChecking why other real users are not visible to Long:');
      for (const otherUser of otherRealUsers.slice(0, 5)) {
        const age = new Date().getFullYear() - new Date(otherUser.dateOfBirth).getFullYear();
        const inSwiped = longSwiped.includes(otherUser._id.toString());
        const inCandidates = longCandidatesFiltered.some(c => c._id.toString() === otherUser._id.toString());
        
        console.log(`\n   ${otherUser.firstName} ${otherUser.lastName}:`);
        console.log(`     - Age: ${age} (filter: 20-35)`);
        console.log(`     - Gender: ${otherUser.gender} (filter: male/female)`);
        console.log(`     - Already swiped: ${inSwiped}`);
        console.log(`     - In filtered candidates: ${inCandidates}`);
        console.log(`     - Has coordinates: ${!!otherUser.location?.coordinates}`);
        console.log(`     - isActive: ${otherUser.isActive}, isProfileComplete: ${otherUser.isProfileComplete}`);
      }
    }

    await mongoose.disconnect();
    console.log('\n✅ Analysis complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

