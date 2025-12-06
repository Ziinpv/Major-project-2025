const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

router.use(authenticate); // All routes require authentication

router.get('/profile', userController.getProfile.bind(userController));
router.patch('/profile', userController.updateProfile.bind(userController));
router.patch('/profile/photos', userController.updateProfilePhotos.bind(userController));
router.get('/discovery', userController.getDiscovery.bind(userController));
router.put('/location', userController.updateLocation.bind(userController));

// Change password endpoint
router.put('/password',
  [
    body('oldPassword').notEmpty().withMessage('Old password is required'),
    body('newPassword')
      .isLength({ min: 8 }).withMessage('New password must be at least 8 characters')
      .matches(/[a-z]/).withMessage('New password must contain at least one lowercase letter')
      .matches(/[A-Z]/).withMessage('New password must contain at least one uppercase letter')
      .matches(/[0-9]/).withMessage('New password must contain at least one number')
  ],
  validate,
  userController.changePassword.bind(userController)
);

// Delete account endpoint
router.delete('/account',
  [
    body('password').notEmpty().withMessage('Password is required to delete account')
  ],
  validate,
  userController.deleteAccount.bind(userController)
);

module.exports = router;

