require('dotenv').config();
const mongoose = require('mongoose');

const userRepository = require('../repositories/user.repository');
const swipeRepository = require('../repositories/swipe.repository');
const userService = require('../services/user.service');
const recommendationService = require('../services/recommendation.service');

const ANH_ID = '6925d58e438e74a43c43f1cb';
const LONG_ID = '69244d283d675e7fe8c4af9e';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const longUser = await userRepository.findById(LONG_ID);
    const anhUser = await userRepository.findById(ANH_ID);

    if (!longUser || !anhUser) {
      console.log('User not found:', { long: !!longUser, anh: !!anhUser });
      process.exit(0);
    }

    console.log('\n=== BASIC PROFILE CHECK ===');
    console.log('Long:', {
      id: longUser._id.toString(),
      gender: longUser.gender,
      isActive: longUser.isActive,
      isProfileComplete: longUser.isProfileComplete,
      location: longUser.location,
      preferences: longUser.preferences,
    });

    console.log('Ánh:', {
      id: anhUser._id.toString(),
      gender: anhUser.gender,
      isActive: anhUser.isActive,
      isProfileComplete: anhUser.isProfileComplete,
      location: anhUser.location,
      interests: anhUser.interests,
      lifestyle: anhUser.lifestyle,
    });

    console.log('\n=== SWIPED IDS FOR LONG ===');
    const swipedIds = await swipeRepository.getSwipedUserIds(LONG_ID);
    console.log('Long has swiped:', swipedIds);
    console.log('Contains Ánh?', swipedIds.includes(ANH_ID));

    console.log('\n=== RAW CANDIDATES FROM findCandidatesForDiscovery ===');
    const filters = {}; // dùng filter mặc định của Long
    const candidates = await userRepository.findCandidatesForDiscovery(
      longUser,
      swipedIds,
      filters
    );
    console.log('Total candidates:', candidates.length);

    const foundAnhInCandidates = candidates.some(
      c => c._id.toString() === ANH_ID
    );
    console.log('Ánh in candidates?', foundAnhInCandidates);

    if (foundAnhInCandidates) {
      const anhInList = candidates.find(c => c._id.toString() === ANH_ID);
      console.log('Anh candidate entry:', {
        id: anhInList._id.toString(),
        gender: anhInList.gender,
        isActive: anhInList.isActive,
        isProfileComplete: anhInList.isProfileComplete,
        location: anhInList.location,
      });
    }

    console.log('\n=== RECOMMENDATION SCORE Long <-> Ánh ===');
    const { score, breakdown, distanceKm } = recommendationService.computeScore(
      longUser,
      anhUser,
      { maxDistance: longUser.preferences?.maxDistance }
    );
    console.log('Score:', score);
    console.log('Breakdown:', breakdown);
    console.log('DistanceKm:', distanceKm);

    console.log('\n=== FINAL DISCOVERY FROM userService.getDiscovery ===');
    const finalResults = await userService.getDiscovery(LONG_ID, {}); // không filter thêm
    console.log('Total results from getDiscovery:', finalResults.length);

    const finalHasAnh = finalResults.some(
      item => (item.user?._id || item.user?.id || item.userId)?.toString() === ANH_ID
    );
    console.log('Ánh in final results?', finalHasAnh);

    if (finalHasAnh) {
      const anhResult = finalResults.find(
        item => (item.user?._id || item.user?.id || item.userId)?.toString() === ANH_ID
      );
      console.log('Anh final entry:', {
        id: (anhResult.user._id || anhResult.user.id).toString(),
        score: anhResult.score,
        breakdown: anhResult.breakdown,
        distanceKm: anhResult.distanceKm,
      });
    } else {
      console.log('⚠️ Ánh không xuất hiện trong kết quả cuối cùng – cần so sánh candidates vs finalResults.');
    }

    await mongoose.disconnect();
    console.log('\n✅ Debug complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Debug error:', err);
    process.exit(1);
  }
})();