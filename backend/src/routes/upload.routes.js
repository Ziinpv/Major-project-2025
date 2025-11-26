const express = require('express');
const uploadController = require('../controllers/upload.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.post('/image', uploadController.uploadImage.bind(uploadController));
router.post('/images', uploadController.uploadMultipleImages.bind(uploadController));

module.exports = router;

