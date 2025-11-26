const mongoose = require('mongoose');

const deviceTokenSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  token: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  platform: {
    type: String,
    enum: ['ios', 'android', 'web'],
    required: true
  },
  deviceId: {
    type: String
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastUsed: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for finding active tokens for a user
deviceTokenSchema.index({ user: 1, isActive: 1 });

module.exports = mongoose.model('DeviceToken', deviceTokenSchema);

