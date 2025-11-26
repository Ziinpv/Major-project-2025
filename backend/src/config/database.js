const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Removed deprecated options: useNewUrlParser and useUnifiedTopology
    // These are no longer needed in Mongoose 6+
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);

    await dropLegacyLocationIndexes(conn);
  } catch (error) {
    console.error(`❌ MongoDB connection error: ${error.message}`);
    process.exit(1);
  }
};

const dropLegacyLocationIndexes = async (conn) => {
  try {
    const collection = conn.connection.db.collection('users');
    const indexes = await collection.indexes();

    for (const index of indexes) {
      const keys = index.key || {};
      const hasLegacyKey = Object.entries(keys).some(
        ([field, type]) => field.startsWith('location') && type === '2dsphere'
      );

      if (hasLegacyKey) {
        try {
          await collection.dropIndex(index.name);
          console.log(`✅ Dropped legacy location index: ${index.name}`);
        } catch (dropError) {
          const isMissingIndex = dropError.codeName === 'IndexNotFound';
          const isMissingNamespace = dropError.code === 26 || dropError.codeName === 'NamespaceNotFound';
          if (!isMissingIndex && !isMissingNamespace) {
            console.warn(`⚠️ Unable to drop legacy index ${index.name}:`, dropError.message);
          }
        }
      }
    }
  } catch (error) {
    console.warn('⚠️ Failed to inspect location indexes:', error.message);
  }
};

module.exports = connectDB;

