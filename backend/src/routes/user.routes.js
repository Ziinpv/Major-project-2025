const express = require('express');
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate); // All routes require authentication

router.get('/profile', userController.getProfile.bind(userController));
router.patch('/profile', userController.updateProfile.bind(userController));
router.patch('/profile/photos', userController.updateProfilePhotos.bind(userController));
router.get('/discovery', userController.getDiscovery.bind(userController));
router.put('/location', userController.updateLocation.bind(userController));

module.exports = router;

