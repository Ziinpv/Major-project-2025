const mongoose = require('mongoose');

const preferenceSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
    index: true
  },
  ageRange: {
    min: {
      type: Number,
      default: 18,
      min: 18
    },
    max: {
      type: Number,
      default: 100,
      max: 100
    }
  },
  maxDistance: {
    type: Number,
    default: 50, // kilometers
    min: 1,
    max: 1000
  },
  showMe: {
    type: [String],
    enum: ['male', 'female', 'non-binary', 'other'],
    default: []
  },
  dealBreakers: [{
    type: String
  }],
  mustHaves: [{
    type: String
  }]
}, {
  timestamps: true
});

module.exports = mongoose.model('Preference', preferenceSchema);

