const { upload, uploadToFirebase } = require('../middleware/upload');

class UploadController {
  async uploadImage(req, res, next) {
    try {
      const uploadSingle = upload.single('image');

      uploadSingle(req, res, async (err) => {
        if (err) {
          return res.status(400).json({
            success: false,
            error: err.message
          });
        }

        if (!req.file) {
          return res.status(400).json({
            success: false,
            error: 'No file uploaded'
          });
        }

        try {
          const folder = req.body.folder || 'users';
          console.log('Uploading file to Firebase:', {
            fileName: req.file.originalname,
            size: req.file.size,
            mimetype: req.file.mimetype,
            folder: folder
          });
          
          const url = await uploadToFirebase(req.file, folder);
          console.log('File uploaded successfully:', url);

          res.json({
            success: true,
            data: {
              url,
              fileName: req.file.originalname,
              size: req.file.size,
              mimetype: req.file.mimetype
            }
          });
        } catch (error) {
          console.error('Error uploading to Firebase:', error);
          console.error('Error stack:', error.stack);
          next(error);
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async uploadMultipleImages(req, res, next) {
    try {
      const uploadMultiple = upload.array('images', 10); // Max 10 images

      uploadMultiple(req, res, async (err) => {
        if (err) {
          return res.status(400).json({
            success: false,
            error: err.message
          });
        }

        if (!req.files || req.files.length === 0) {
          return res.status(400).json({
            success: false,
            error: 'No files uploaded'
          });
        }

        try {
          const folder = req.body.folder || 'users';
          const uploadPromises = req.files.map(file => uploadToFirebase(file, folder));
          const urls = await Promise.all(uploadPromises);

          res.json({
            success: true,
            data: {
              urls,
              count: urls.length
            }
          });
        } catch (error) {
          next(error);
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new UploadController();

