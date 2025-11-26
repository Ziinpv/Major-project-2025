const mongoose = require('mongoose');

const matchSchema = new mongoose.Schema({
  users: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  matchedAt: {
    type: Date,
    default: Date.now
  },
  isActive: {
    type: Boolean,
    default: true
  },
  unmatchedAt: {
    type: Date
  },
  unmatchedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  lastMessageAt: {
    type: Date
  },
  lastMessage: {
    type: String
  }
}, {
  timestamps: true
});

// Index to ensure unique matches between two specific users
// Note: We sort users array before saving to ensure consistency
matchSchema.index({ 'users.0': 1, 'users.1': 1 }, { unique: true });
matchSchema.index({ isActive: 1, matchedAt: -1 });

// Method to get the other user in a match
matchSchema.methods.getOtherUser = function(currentUserId) {
  return this.users.find(userId => userId.toString() !== currentUserId.toString());
};

// Method to get public JSON (without sensitive data, with proper formatting)
matchSchema.methods.toPublicJSON = function() {
  const match = this.toObject({ virtuals: true });
  
  // Convert _id to id
  if (match._id) {
    match.id = match._id.toString();
    delete match._id;
  }
  
  // Format users array
  if (match.users && Array.isArray(match.users)) {
    match.users = match.users.map(user => {
      if (!user) return user;
      if (typeof user.toPublicJSON === 'function') {
        return user.toPublicJSON();
      }
      if (typeof user === 'object') {
        const userObj = { ...user };
        if (userObj._id) {
          userObj.id = userObj._id.toString();
          delete userObj._id;
        }
        // Ensure arrays are not null
        if (!userObj.photos) userObj.photos = [];
        if (!userObj.interests) userObj.interests = [];
        if (!userObj.interestedIn) userObj.interestedIn = [];
        // Ensure lastName is not null (can be empty string)
        if (userObj.lastName === null || userObj.lastName === undefined) {
          userObj.lastName = '';
        }
        // Remove __v and other internal fields
        delete userObj.__v;
        return userObj;
      }
      return user;
    });
  } else {
    match.users = [];
  }
  
  // Convert dates to ISO strings
  if (match.matchedAt) {
    match.matchedAt = new Date(match.matchedAt).toISOString();
  }
  if (match.unmatchedAt) {
    match.unmatchedAt = new Date(match.unmatchedAt).toISOString();
  }
  if (match.lastMessageAt) {
    match.lastMessageAt = new Date(match.lastMessageAt).toISOString();
  }
  
  // Ensure boolean defaults
  if (match.isActive === undefined || match.isActive === null) {
    match.isActive = true;
  }
  
  // Remove internal MongoDB fields
  delete match.__v;
  
  return match;
};

module.exports = mongoose.model('Match', matchSchema);

