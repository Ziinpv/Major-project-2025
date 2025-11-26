const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post(
  '/register/firebase',
  [
    body('firebaseToken').notEmpty().withMessage('Firebase token is required'),
    body('firstName').notEmpty().withMessage('First name is required'),
    body('lastName').notEmpty().withMessage('Last name is required'),
    body('dateOfBirth').isISO8601().withMessage('Valid date of birth is required'),
    body('gender').isIn(['male', 'female', 'non-binary', 'other']).withMessage('Valid gender is required')
  ],
  authController.registerWithFirebase.bind(authController)
);

router.post(
  '/login/firebase',
  [
    body('firebaseToken').notEmpty().withMessage('Firebase token is required')
  ],
  authController.loginWithFirebase.bind(authController)
);

router.post(
  '/register/email',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('firstName').notEmpty().withMessage('First name is required'),
    body('lastName').notEmpty().withMessage('Last name is required'),
    body('dateOfBirth').isISO8601().withMessage('Valid date of birth is required'),
    body('gender').isIn(['male', 'female', 'non-binary', 'other']).withMessage('Valid gender is required')
  ],
  authController.registerWithEmail.bind(authController)
);

router.post(
  '/login/email',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required')
  ],
  authController.loginWithEmail.bind(authController)
);

router.get('/me', authenticate, authController.getMe.bind(authController));

module.exports = router;

