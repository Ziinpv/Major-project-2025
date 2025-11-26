const admin = require('firebase-admin');

let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) {
    return;
  }

  try {
    // Validate required environment variables
    if (!process.env.FIREBASE_PROJECT_ID) {
      throw new Error('FIREBASE_PROJECT_ID is not set');
    }
    if (!process.env.FIREBASE_PRIVATE_KEY) {
      throw new Error('FIREBASE_PRIVATE_KEY is not set');
    }
    if (!process.env.FIREBASE_CLIENT_EMAIL) {
      throw new Error('FIREBASE_CLIENT_EMAIL is not set');
    }
    if (!process.env.FIREBASE_STORAGE_BUCKET) {
      throw new Error('FIREBASE_STORAGE_BUCKET is not set');
    }

    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin initialized');
    console.log('✅ Storage Bucket:', process.env.FIREBASE_STORAGE_BUCKET);
  } catch (error) {
    console.error('❌ Firebase initialization error:', error);
    console.error('❌ Error details:', error.message);
    throw error;
  }
};

const getFirebaseAdmin = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin;
};

const getStorage = () => {
  return getFirebaseAdmin().storage();
};

const getMessaging = () => {
  return getFirebaseAdmin().messaging();
};

const verifyFirebaseToken = async (idToken) => {
  try {
    const decodedToken = await getFirebaseAdmin().auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    throw new Error('Invalid Firebase token');
  }
};

module.exports = {
  initializeFirebase,
  getFirebaseAdmin,
  getStorage,
  getMessaging,
  verifyFirebaseToken
};

