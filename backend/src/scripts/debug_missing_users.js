require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const userRepository = require('../repositories/user.repository');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const ANH_ID = '6925d58e438e74a43c43f1cb';
const SANG_ID = '692442f1a9f3953326a32fed';
const MONO_ID = '692732661c247d8acd64c1b0';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const longUser = await User.findById(LONG_ID).lean();
    const anhUser = await User.findById(ANH_ID).lean();
    const sangUser = await User.findById(SANG_ID).lean();
    const monoUser = await User.findById(MONO_ID).lean();

    console.log('📍 === LOCATION CHECK ===\n');
    
    console.log('Long:');
    console.log(`   Location: ${longUser.location?.province}, ${longUser.location?.city}`);
    console.log(`   Coordinates: ${JSON.stringify(longUser.location?.coordinates)}`);
    console.log(`   Has coordinates: ${!!longUser.location?.coordinates}`);
    console.log(`   Max distance: ${longUser.preferences?.maxDistance || 50} km\n`);

    console.log('Ánh:');
    console.log(`   Location: ${anhUser.location?.province}, ${anhUser.location?.city}`);
    console.log(`   Coordinates: ${JSON.stringify(anhUser.location?.coordinates)}`);
    console.log(`   Has coordinates: ${!!anhUser.location?.coordinates}`);
    console.log(`   Max distance: ${anhUser.preferences?.maxDistance || 50} km\n`);

    console.log('Nguyễn Hoàng Sang:');
    console.log(`   Location: ${sangUser.location?.province}, ${sangUser.location?.city}`);
    console.log(`   Coordinates: ${JSON.stringify(sangUser.location?.coordinates)}`);
    console.log(`   Has coordinates: ${!!sangUser.location?.coordinates}\n`);

    console.log('MONO:');
    console.log(`   Location: ${monoUser.location?.province}, ${monoUser.location?.city}`);
    console.log(`   Coordinates: ${JSON.stringify(monoUser.location?.coordinates)}`);
    console.log(`   Has coordinates: ${!!monoUser.location?.coordinates}\n`);

    // Kiểm tra query thủ công
    console.log('🔍 === MANUAL QUERY CHECK ===\n');

    // Query cho Long với filters
    const filters = {
      ageMin: 18,
      ageMax: 35,
      showMe: ['male', 'female'],
      distance: 50
    };

    console.log('Testing query for Long with filters:', filters);
    console.log('Long coordinates:', longUser.location?.coordinates);
    
    // Build query manually
    const query = {
      _id: { $ne: LONG_ID, $nin: [] },
      isActive: true,
      isProfileComplete: true,
      gender: { $in: ['male', 'female'] }
    };

    // Age filter
    const today = new Date();
    const minBirthDate = new Date(today.getFullYear() - 35, today.getMonth(), today.getDate());
    const maxBirthDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
    query.dateOfBirth = { $gte: minBirthDate, $lte: maxBirthDate };

    console.log('\nBase query (without distance):');
    console.log(JSON.stringify(query, null, 2));

    // Check if Sang and MONO pass base query
    const sangPassBase = 
      sangUser.isActive &&
      sangUser.isProfileComplete &&
      ['male', 'female'].includes(sangUser.gender) &&
      new Date(sangUser.dateOfBirth) >= minBirthDate &&
      new Date(sangUser.dateOfBirth) <= maxBirthDate;

    const monoPassBase = 
      monoUser.isActive &&
      monoUser.isProfileComplete &&
      ['male', 'female'].includes(monoUser.gender) &&
      new Date(monoUser.dateOfBirth) >= minBirthDate &&
      new Date(monoUser.dateOfBirth) <= maxBirthDate;

    console.log(`\nSang passes base query: ${sangPassBase}`);
    console.log(`MONO passes base query: ${monoPassBase}`);

    // Check distance filter
    if (longUser.location?.coordinates && Array.isArray(longUser.location.coordinates) && longUser.location.coordinates.length === 2) {
      console.log('\n⚠️  Long has coordinates - distance filter will be applied!');
      console.log('   Users without coordinates will be EXCLUDED by $near query');
      
      console.log(`\nSang has coordinates: ${!!sangUser.location?.coordinates}`);
      console.log(`MONO has coordinates: ${!!monoUser.location?.coordinates}`);
      
      if (!sangUser.location?.coordinates) {
        console.log('❌ Sang will be EXCLUDED due to missing coordinates');
      }
      if (!monoUser.location?.coordinates) {
        console.log('❌ MONO will be EXCLUDED due to missing coordinates');
      }
    } else {
      console.log('\n✅ Long has NO coordinates - distance filter will NOT be applied');
      console.log('   All users should appear regardless of coordinates');
    }

    // Test actual query
    console.log('\n🔍 === ACTUAL QUERY TEST ===\n');
    const candidates = await userRepository.findCandidatesForDiscovery(
      longUser,
      [],
      filters
    );

    console.log(`Candidates returned: ${candidates.length}`);
    candidates.forEach(c => {
      const isReal = !c.email.match(/@example\.com$/);
      console.log(`   - ${c.firstName} ${c.lastName} ${isReal ? '⭐' : '🌱'} (has coords: ${!!c.location?.coordinates})`);
    });

    const sangInResults = candidates.some(c => c._id.toString() === SANG_ID);
    const monoInResults = candidates.some(c => c._id.toString() === MONO_ID);

    console.log(`\nSang in results: ${sangInResults}`);
    console.log(`MONO in results: ${monoInResults}`);

    await mongoose.disconnect();
    console.log('\n✅ Analysis complete');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
})();

