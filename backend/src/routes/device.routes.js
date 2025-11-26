const express = require('express');
const { body } = require('express-validator');
const DeviceToken = require('../models/DeviceToken');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

// Register device token for push notifications
router.post(
  '/tokens',
  [
    body('token').notEmpty().withMessage('Token is required'),
    body('platform').isIn(['ios', 'android', 'web']).withMessage('Valid platform is required')
  ],
  async (req, res, next) => {
    try {
      const { token, platform, deviceId } = req.body;

      // Check if token already exists
      let deviceToken = await DeviceToken.findOne({ token });

      if (deviceToken) {
        // Update existing token
        deviceToken.user = req.userId;
        deviceToken.platform = platform;
        deviceToken.deviceId = deviceId;
        deviceToken.isActive = true;
        deviceToken.lastUsed = new Date();
        await deviceToken.save();
      } else {
        // Create new token
        deviceToken = await DeviceToken.create({
          user: req.userId,
          token,
          platform,
          deviceId,
          isActive: true
        });
      }

      res.json({
        success: true,
        data: { deviceToken }
      });
    } catch (error) {
      next(error);
    }
  }
);

// Remove device token
router.delete('/tokens/:tokenId', async (req, res, next) => {
  try {
    await DeviceToken.findByIdAndDelete(req.params.tokenId);
    res.json({
      success: true,
      message: 'Device token removed'
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

