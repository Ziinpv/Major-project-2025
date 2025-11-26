const mongoose = require('mongoose');

const discoveryLogSchema = new mongoose.Schema({
  viewer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  candidate: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  score: {
    type: Number,
    min: 0,
    max: 100
  },
  breakdown: {
    type: Map,
    of: Number,
    default: {}
  },
  filters: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
    default: {}
  },
  distanceKm: {
    type: Number
  }
}, {
  timestamps: true
});

discoveryLogSchema.index({ viewer: 1, candidate: 1, createdAt: -1 });

module.exports = mongoose.model('DiscoveryLog', discoveryLogSchema);

