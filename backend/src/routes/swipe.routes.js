const express = require('express');
const { body } = require('express-validator');
const swipeController = require('../controllers/swipe.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.post(
  '/',
  [
    body('userId').notEmpty().withMessage('User ID is required'),
    body('action').isIn(['like', 'pass', 'superlike']).withMessage('Valid action is required')
  ],
  swipeController.swipe.bind(swipeController)
);

router.get('/history', swipeController.getSwipeHistory.bind(swipeController));

module.exports = router;

