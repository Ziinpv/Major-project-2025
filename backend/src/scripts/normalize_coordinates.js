/* eslint-disable no-console */
// Usage:
//   node src/scripts/normalize_coordinates.js
//
// Chuẩn hoá toạ độ cho các user cũ:
// - user.location.province đã có giá trị
// - nhưng location.coordinates bị thiếu hoặc rỗng

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const { getCoordinates } = require('../utils/vietnam_coordinates');

(async () => {
  try {
    if (!process.env.MONGODB_URI) {
      console.error('❌ MONGODB_URI is not defined. Please set it in .env');
      process.exit(1);
    }

    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Tìm các user có province nhưng thiếu hoặc rỗng coordinates
    const users = await User.find({
      'location.province': { $ne: null, $ne: '' },
      $or: [
        { 'location.coordinates': { $exists: false } },
        { 'location.coordinates': { $size: 0 } },
        { 'location.coordinates.0': { $exists: false } },
      ],
    }).select('firstName lastName email location');

    if (!users.length) {
      console.log('✅ Không có user nào cần chuẩn hoá toạ độ.');
      await mongoose.disconnect();
      process.exit(0);
    }

    console.log(`🔍 Found ${users.length} users with missing coordinates.`);

    let updatedCount = 0;
    let skippedCount = 0;

    for (const user of users) {
      const province = user.location?.province;
      const coords = getCoordinates(province);

      if (!coords) {
        console.warn(
          `⚠️  Không tìm được toạ độ cho: ${province} (user=${user._id.toString()} email=${user.email})`
        );
        skippedCount += 1;
        continue;
      }

      const [lng, lat] = coords;

      user.location = {
        ...(user.location || {}),
        type: 'Point',
        coordinates: [Number(lng), Number(lat)],
        lastUpdatedAt: new Date(),
      };

      await user.save();
      updatedCount += 1;

      console.log(
        `✅ Updated user=${user._id.toString()} ` +
          `(${user.email || user.firstName}) → province="${province}", coords=[${lng}, ${lat}]`
      );
    }

    console.log('\n🎉 Normalize coordinates completed.');
    console.log(`   ✅ Updated users : ${updatedCount}`);
    console.log(`   ⚠️  Skipped users : ${skippedCount}`);

    await mongoose.disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ Error while normalizing coordinates:', err);
    try {
      await mongoose.disconnect();
    } catch (_) {
      // ignore
    }
    process.exit(1);
  }
})();


