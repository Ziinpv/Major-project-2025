require('dotenv').config();
const mongoose = require('mongoose');
const admin = require('firebase-admin');

console.log('🔍 Testing connections...\n');

// Test MongoDB
console.log('📦 Testing MongoDB connection...');
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ MongoDB connected successfully!');
    console.log(`   Database: ${mongoose.connection.name}`);
    console.log(`   Host: ${mongoose.connection.host}`);
    mongoose.connection.close();
    
    // Test Firebase
    console.log('\n🔥 Testing Firebase connection...');
    try {
      if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
        throw new Error('Missing Firebase environment variables');
      }

      const serviceAccount = {
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL
      };
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET
      });
      
      console.log('✅ Firebase initialized successfully!');
      console.log(`   Project ID: ${process.env.FIREBASE_PROJECT_ID}`);
      console.log(`   Storage Bucket: ${process.env.FIREBASE_STORAGE_BUCKET}`);
      
      console.log('\n🎉 All connections successful!');
      process.exit(0);
    } catch (error) {
      console.error('❌ Firebase error:', error.message);
      console.error('\n💡 Tips:');
      console.error('   - Check FIREBASE_PROJECT_ID in .env');
      console.error('   - Check FIREBASE_PRIVATE_KEY format (should have \\n)');
      console.error('   - Check FIREBASE_CLIENT_EMAIL in .env');
      console.error('   - Check FIREBASE_STORAGE_BUCKET in .env');
      process.exit(1);
    }
  })
  .catch((error) => {
    console.error('❌ MongoDB error:', error.message);
    console.error('\n💡 Tips:');
    console.error('   - Check MONGODB_URI in .env');
    console.error('   - Verify username and password');
    console.error('   - Check IP whitelist in MongoDB Atlas');
    console.error('   - Ensure cluster is running');
    process.exit(1);
  });

