require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const userRepository = require('../repositories/user.repository');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const ANH_ID = '6925d58e438e74a43c43f1cb';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // 1. Lấy tất cả user thật (active + complete)
    const allRealUsers = await User.find({
      email: { $not: { $regex: /@example\.com$/ } },
      isActive: true,
      isProfileComplete: true
    }).select('_id firstName lastName email gender dateOfBirth location');

    console.log(`📋 Real users (active + complete): ${allRealUsers.length}`);
    allRealUsers.forEach(u => {
      const age = new Date().getFullYear() - new Date(u.dateOfBirth).getFullYear();
      console.log(`   - ${u.firstName} ${u.lastName} (${u.gender}, age ${age})`);
    });

    // 2. Kiểm tra swipe history của Long
    console.log('\n🔍 === LONG\'S SWIPE HISTORY ===');
    const longSwipes = await Swipe.find({ swiper: LONG_ID })
      .populate('swiped', 'firstName lastName email gender')
      .lean();

    console.log(`Long has swiped ${longSwipes.length} users:`);
    longSwipes.forEach(s => {
      const target = s.swiped;
      console.log(`   - ${target.firstName} ${target.lastName} (${target.email}) - Action: ${s.action}`);
    });

    const longSwipedIds = longSwipes.map(s => s.swiped._id.toString());
    const longNotSwiped = allRealUsers.filter(u => 
      u._id.toString() !== LONG_ID && !longSwipedIds.includes(u._id.toString())
    );
    console.log(`\nLong has NOT swiped: ${longNotSwiped.length} real users`);
    longNotSwiped.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName} (${u.email})`);
    });

    // 3. Kiểm tra swipe history của Ánh
    console.log('\n🔍 === ÁNH\'S SWIPE HISTORY ===');
    const anhSwipes = await Swipe.find({ swiper: ANH_ID })
      .populate('swiped', 'firstName lastName email gender')
      .lean();

    console.log(`Ánh has swiped ${anhSwipes.length} users:`);
    anhSwipes.forEach(s => {
      const target = s.swiped;
      console.log(`   - ${target.firstName} ${target.lastName} (${target.email}) - Action: ${s.action}`);
    });

    const anhSwipedIds = anhSwipes.map(s => s.swiped._id.toString());
    const anhNotSwiped = allRealUsers.filter(u => 
      u._id.toString() !== ANH_ID && !anhSwipedIds.includes(u._id.toString())
    );
    console.log(`\nÁnh has NOT swiped: ${anhNotSwiped.length} real users`);
    anhNotSwiped.forEach(u => {
      console.log(`   - ${u.firstName} ${u.lastName} (${u.email})`);
    });

    // 4. Kiểm tra Discovery candidates cho Long
    console.log('\n🔍 === LONG\'S DISCOVERY CANDIDATES ===');
    const longUser = await User.findById(LONG_ID);
    const longCandidates = await userRepository.findCandidatesForDiscovery(
      longUser,
      longSwipedIds,
      { ageMin: 18, ageMax: 35, showMe: ['male', 'female'], distance: 50 }
    );

    console.log(`Total candidates: ${longCandidates.length}`);
    longCandidates.forEach(c => {
      const age = new Date().getFullYear() - new Date(c.dateOfBirth).getFullYear();
      const isReal = !c.email.match(/@example\.com$/);
      console.log(`   - ${c.firstName} ${c.lastName} (${c.gender}, age ${age}) ${isReal ? '⭐ REAL USER' : '🌱 SEED'}`);
    });

    // 5. Kiểm tra Discovery candidates cho Ánh
    console.log('\n🔍 === ÁNH\'S DISCOVERY CANDIDATES ===');
    const anhUser = await User.findById(ANH_ID);
    const anhCandidates = await userRepository.findCandidatesForDiscovery(
      anhUser,
      anhSwipedIds,
      { ageMin: 18, ageMax: 35, showMe: ['male', 'female'], distance: 50 }
    );

    console.log(`Total candidates: ${anhCandidates.length}`);
    anhCandidates.forEach(c => {
      const age = new Date().getFullYear() - new Date(c.dateOfBirth).getFullYear();
      const isReal = !c.email.match(/@example\.com$/);
      console.log(`   - ${c.firstName} ${c.lastName} (${c.gender}, age ${age}) ${isReal ? '⭐ REAL USER' : '🌱 SEED'}`);
    });

    // 6. Kiểm tra xem Long và Ánh có trong danh sách của nhau không
    console.log('\n🔗 === MUTUAL VISIBILITY ===');
    const longSeesAnh = longCandidates.some(c => c._id.toString() === ANH_ID);
    const anhSeesLong = anhCandidates.some(c => c._id.toString() === LONG_ID);
    console.log(`Long sees Ánh: ${longSeesAnh}`);
    console.log(`Ánh sees Long: ${anhSeesLong}`);

    // 7. Kiểm tra các user thật khác có trong candidates không
    console.log('\n📊 === REAL USERS IN CANDIDATES ===');
    const otherRealUsers = allRealUsers.filter(u => 
      u._id.toString() !== LONG_ID && u._id.toString() !== ANH_ID
    );

    console.log('For Long:');
    otherRealUsers.forEach(u => {
      const inCandidates = longCandidates.some(c => c._id.toString() === u._id.toString());
      console.log(`   ${u.firstName} ${u.lastName}: ${inCandidates ? '✅ YES' : '❌ NO'}`);
    });

    console.log('\nFor Ánh:');
    otherRealUsers.forEach(u => {
      const inCandidates = anhCandidates.some(c => c._id.toString() === u._id.toString());
      console.log(`   ${u.firstName} ${u.lastName}: ${inCandidates ? '✅ YES' : '❌ NO'}`);
    });

    await mongoose.disconnect();
    console.log('\n✅ Analysis complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

