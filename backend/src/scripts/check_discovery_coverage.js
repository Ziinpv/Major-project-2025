require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const userRepository = require('../repositories/user.repository');
const userService = require('../services/user.service');
const recommendationService = require('../services/recommendation.service');

const TARGET_USER_ID = process.argv[2] || '69244d283d675e7fe8c4af9e'; // Long

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const targetUser = await User.findById(TARGET_USER_ID);
    if (!targetUser) {
      console.log('❌ Target user not found');
      process.exit(1);
    }

    console.log(`📊 Analyzing Discovery for: ${targetUser.firstName} ${targetUser.lastName}\n`);

    // 1. Tổng số user seed
    const allSeedUsers = await User.find({
      email: { $regex: /@example\.com$/ },
      isActive: true,
      isProfileComplete: true
    }).countDocuments();
    console.log(`📋 Total seed users (active + complete): ${allSeedUsers}`);

    // 2. Số user đã swipe
    const swipedIds = await Swipe.find({ swiper: TARGET_USER_ID }).distinct('swiped');
    console.log(`👆 Already swiped: ${swipedIds.length} users`);

    // 3. Lấy candidates từ DB (không tính score)
    const candidates = await userRepository.findCandidatesForDiscovery(
      targetUser,
      swipedIds,
      {} // no filters
    );
    console.log(`🔍 Candidates from DB query: ${candidates.length}`);

    // 4. Tính score cho tất cả candidates
    const withScores = candidates.map(candidate => {
      const { score, breakdown, distanceKm } = recommendationService.computeScore(
        targetUser,
        candidate,
        { maxDistance: targetUser.preferences?.maxDistance || 50 }
      );
      return {
        id: candidate._id.toString(),
        name: `${candidate.firstName} ${candidate.lastName}`,
        score,
        distanceKm,
        breakdown
      };
    });

    // 5. Phân tích score distribution
    const scoreRanges = {
      '0-10': 0,
      '11-20': 0,
      '21-30': 0,
      '31-40': 0,
      '41-50': 0,
      '51-60': 0,
      '61-70': 0,
      '71-80': 0,
      '81-90': 0,
      '91-100': 0
    };

    withScores.forEach(item => {
      const range = Math.floor(item.score / 10) * 10;
      const key = range === 0 ? '0-10' : `${range + 1}-${range + 10}`;
      if (scoreRanges[key]) scoreRanges[key]++;
    });

    console.log('\n📈 Score Distribution:');
    Object.entries(scoreRanges).forEach(([range, count]) => {
      if (count > 0) {
        console.log(`   ${range}%: ${count} users`);
      }
    });

    // 6. Top 50 sau khi sort
    withScores.sort((a, b) => b.score - a.score);
    const top50 = withScores.slice(0, 50);
    const minScoreInTop50 = top50.length > 0 ? top50[top50.length - 1].score : 0;
    console.log(`\n🏆 Top 50 users (after sort by score):`);
    console.log(`   Min score in top 50: ${minScoreInTop50.toFixed(1)}%`);
    console.log(`   Max score: ${top50[0]?.score.toFixed(1)}%`);

    // 7. Users bị loại do limit
    const excluded = withScores.slice(50);
    console.log(`\n❌ Excluded due to limit (50): ${excluded.length} users`);
    if (excluded.length > 0) {
      console.log(`   Score range of excluded: ${excluded[excluded.length - 1].score.toFixed(1)}% - ${excluded[0].score.toFixed(1)}%`);
    }

    // 8. Check nếu có filter score >= 40%
    const above40 = withScores.filter(u => u.score >= 40);
    console.log(`\n✅ Users with score >= 40%: ${above40.length}`);
    console.log(`   In top 50: ${top50.filter(u => u.score >= 40).length}`);

    // 9. Sample một vài user bị loại
    if (excluded.length > 0) {
      console.log('\n📝 Sample excluded users (first 5):');
      excluded.slice(0, 5).forEach(u => {
        console.log(`   - ${u.name}: ${u.score.toFixed(1)}%`);
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

