// Usage: node src/scripts/update_coordinates.js <userId> <longitude> <latitude>
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');

const [userId, lngArg, latArg] = process.argv.slice(2);

if (!userId || !lngArg || !latArg) {
  console.error('❌ Missing arguments. Usage: node src/scripts/update_coordinates.js <userId> <longitude> <latitude>');
  process.exit(1);
}

const longitude = Number(lngArg);
const latitude = Number(latArg);

if (Number.isNaN(longitude) || Number.isNaN(latitude)) {
  console.error('❌ Longitude and latitude must be numeric values');
  process.exit(1);
}

(async () => {
  try {
    if (!process.env.MONGODB_URI) {
      throw new Error('MONGODB_URI is not defined. Please set it in your environment or .env file.');
    }

    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const user = await User.findById(userId);
    if (!user) {
      console.error('❌ User not found');
      process.exit(1);
    }

    user.location = user.location || {};
    user.location.coordinates = [longitude, latitude];
    user.location.lastUpdatedAt = new Date();
    await user.save();

    console.log(`🎯 Updated coordinates for ${user.firstName} ${user.lastName || ''} -> [${longitude}, ${latitude}]`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Failed to update coordinates:', error.message);
    process.exit(1);
  }
})();

