require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const userRepository = require('../repositories/user.repository');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const SANG_ID = '692442f1a9f3953326a32fed';
const MONO_ID = '692732661c247d8acd64c1b0';

// Haversine formula để tính khoảng cách
function haversine([lng1, lat1], [lng2, lat2]) {
  const toRad = deg => (deg * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const longUser = await User.findById(LONG_ID).lean();
    const sangUser = await User.findById(SANG_ID).lean();
    const monoUser = await User.findById(MONO_ID).lean();

    // 1. Kiểm tra MONO tại sao không pass base query
    console.log('🔍 === MONO BASE QUERY CHECK ===\n');
    const today = new Date();
    const minBirthDate = new Date(today.getFullYear() - 35, today.getMonth(), today.getDate());
    const maxBirthDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
    
    const monoAge = today.getFullYear() - new Date(monoUser.dateOfBirth).getFullYear();
    const monoDob = new Date(monoUser.dateOfBirth);
    
    console.log('MONO details:');
    console.log(`   dateOfBirth: ${monoDob.toISOString()}`);
    console.log(`   Age: ${monoAge}`);
    console.log(`   Gender: ${monoUser.gender}`);
    console.log(`   isActive: ${monoUser.isActive}`);
    console.log(`   isProfileComplete: ${monoUser.isProfileComplete}`);
    console.log(`\n   Age range filter: 18-35`);
    console.log(`   Birth date range: ${minBirthDate.toISOString()} to ${maxBirthDate.toISOString()}`);
    console.log(`   MONO birth date: ${monoDob.toISOString()}`);
    console.log(`   Passes age filter: ${monoDob >= minBirthDate && monoDob <= maxBirthDate}`);
    console.log(`   Passes gender filter: ${['male', 'female'].includes(monoUser.gender)}`);

    // 2. Tính khoảng cách
    console.log('\n📍 === DISTANCE CALCULATION ===\n');
    
    const longCoords = longUser.location?.coordinates;
    const sangCoords = sangUser.location?.coordinates;
    const monoCoords = monoUser.location?.coordinates;

    if (longCoords && sangCoords) {
      const distance = haversine(longCoords, sangCoords);
      console.log(`Long → Sang: ${distance.toFixed(2)} km`);
      console.log(`   Max distance: ${longUser.preferences?.maxDistance || 50} km`);
      console.log(`   Within range: ${distance <= (longUser.preferences?.maxDistance || 50)}`);
    }

    if (longCoords && monoCoords) {
      const distance = haversine(longCoords, monoCoords);
      console.log(`Long → MONO: ${distance.toFixed(2)} km`);
      console.log(`   Max distance: ${longUser.preferences?.maxDistance || 50} km`);
      console.log(`   Within range: ${distance <= (longUser.preferences?.maxDistance || 50)}`);
    }

    // 3. Test query với distance = null (tắt filter)
    console.log('\n🔍 === TEST WITHOUT DISTANCE FILTER ===\n');
    
    const filtersNoDistance = {
      ageMin: 18,
      ageMax: 35,
      showMe: ['male', 'female']
      // Không có distance
    };

    console.log('Testing with filters:', filtersNoDistance);
    const candidatesNoDistance = await userRepository.findCandidatesForDiscovery(
      longUser,
      [],
      filtersNoDistance
    );

    console.log(`\nCandidates (no distance filter): ${candidatesNoDistance.length}`);
    candidatesNoDistance.forEach(c => {
      const isReal = !c.email.match(/@example\.com$/);
      console.log(`   - ${c.firstName} ${c.lastName} ${isReal ? '⭐' : '🌱'}`);
    });

    const sangInNoDistance = candidatesNoDistance.some(c => c._id.toString() === SANG_ID);
    const monoInNoDistance = candidatesNoDistance.some(c => c._id.toString() === MONO_ID);

    console.log(`\nSang in results (no distance): ${sangInNoDistance}`);
    console.log(`MONO in results (no distance): ${monoInNoDistance}`);

    // 4. Test với distance rất lớn
    console.log('\n🔍 === TEST WITH LARGE DISTANCE (1000km) ===\n');
    
    const filtersLargeDistance = {
      ageMin: 18,
      ageMax: 35,
      showMe: ['male', 'female'],
      distance: 1000
    };

    const candidatesLargeDistance = await userRepository.findCandidatesForDiscovery(
      longUser,
      [],
      filtersLargeDistance
    );

    console.log(`Candidates (distance = 1000km): ${candidatesLargeDistance.length}`);
    const sangInLarge = candidatesLargeDistance.some(c => c._id.toString() === SANG_ID);
    const monoInLarge = candidatesLargeDistance.some(c => c._id.toString() === MONO_ID);

    console.log(`Sang in results (1000km): ${sangInLarge}`);
    console.log(`MONO in results (1000km): ${monoInLarge}`);

    await mongoose.disconnect();
    console.log('\n✅ Analysis complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

