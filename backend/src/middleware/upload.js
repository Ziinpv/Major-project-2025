const multer = require('multer');
const { getStorage } = require('../config/firebase');
// Simple UUID generator
const generateUUID = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

// Configure multer for memory storage
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB default
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = (process.env.ALLOWED_FILE_TYPES || 'jpg,jpeg,png,webp').split(',');
    const fileExtension = file.originalname.split('.').pop().toLowerCase();
    
    if (allowedTypes.includes(fileExtension)) {
      cb(null, true);
    } else {
      cb(new Error(`File type .${fileExtension} not allowed. Allowed types: ${allowedTypes.join(', ')}`));
    }
  },
});

// Upload to Firebase Storage
const uploadToFirebase = async (file, folder = 'uploads') => {
  try {
    const storage = getStorage();
    if (!storage) {
      throw new Error('Firebase Storage is not initialized');
    }

    const bucket = storage.bucket();
    if (!bucket) {
      throw new Error('Firebase Storage bucket is not available');
    }

    const fileName = `${folder}/${generateUUID()}-${file.originalname}`;
    const fileUpload = bucket.file(fileName);

    console.log('Uploading to Firebase Storage:', {
      bucket: bucket.name,
      fileName: fileName,
      contentType: file.mimetype,
      size: file.size
    });

    const stream = fileUpload.createWriteStream({
      metadata: {
        contentType: file.mimetype,
      },
      public: true,
    });

    return new Promise((resolve, reject) => {
      stream.on('error', (error) => {
        console.error('Stream error during upload:', error);
        reject(error);
      });

      stream.on('finish', async () => {
        try {
          // Make file publicly accessible
          await fileUpload.makePublic();
          const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
          console.log('File uploaded successfully:', publicUrl);
          resolve(publicUrl);
        } catch (error) {
          console.error('Error making file public:', error);
          // Even if makePublic fails, we can still return the URL
          const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
          resolve(publicUrl);
        }
      });

      if (!file.buffer) {
        reject(new Error('File buffer is empty'));
        return;
      }

      stream.end(file.buffer);
    });
  } catch (error) {
    console.error('Error in uploadToFirebase:', error);
    throw error;
  }
};

module.exports = {
  upload,
  uploadToFirebase,
};

