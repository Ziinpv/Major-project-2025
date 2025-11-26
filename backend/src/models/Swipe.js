const mongoose = require('mongoose');

const swipeSchema = new mongoose.Schema({
  swiper: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  swiped: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  action: {
    type: String,
    enum: ['like', 'pass', 'superlike'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: true
});

// Compound index to prevent duplicate swipes
swipeSchema.index({ swiper: 1, swiped: 1 }, { unique: true });

// Index for finding mutual likes
swipeSchema.index({ swiped: 1, action: 'like' });

module.exports = mongoose.model('Swipe', swipeSchema);

