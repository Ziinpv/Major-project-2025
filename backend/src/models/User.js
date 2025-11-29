const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const {
  INTEREST_OPTIONS,
  LIFESTYLE_OPTIONS,
  DEFAULT_PREFERENCES
} = require('../utils/constants');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    unique: true,
    sparse: true
    // Note: unique: true automatically creates an index, so we don't need index: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
    // Note: unique: true automatically creates an index, so we don't need to add it again
  },
  phone: {
    type: String,
    sparse: true,
    index: true
  },
  password: {
    type: String,
    select: false // Don't return password by default
  },
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: false,
    default: '',
    trim: true
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'non-binary', 'other'],
    required: true
  },
  interestedIn: {
    type: [String],
    enum: ['male', 'female', 'non-binary', 'other'],
    default: []
  },
  bio: {
    type: String,
    maxlength: 500,
    default: ''
  },
  photos: [{
    url: {
      type: String,
      required: true,
      trim: true
    },
    isPrimary: {
      type: Boolean,
      default: false
    },
    order: {
      type: Number,
      min: 0,
      default: 0
    }
  }],
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      index: '2dsphere',
      validate: {
        validator: function(value) {
          if (!value || value.length === 0) return true;
          return Array.isArray(value) && value.length === 2 && value.every(num => typeof num === 'number');
        },
        message: 'Coordinates must be an array [lng, lat]'
      }
    },
    province: {
      type: String,
      trim: true,
      default: ''
    },
    city: {
      type: String,
      trim: true,
      default: ''
    },
    district: {
      type: String,
      trim: true,
      default: ''
    },
    address: {
      type: String,
      trim: true,
      default: ''
    },
    country: {
      type: String,
      trim: true,
      default: 'Vietnam'
    },
    lastUpdatedAt: {
      type: Date
    }
  },
  interests: [{
    type: String,
    enum: INTEREST_OPTIONS,
    trim: true
  }],
  lifestyle: [{
    type: String,
    enum: LIFESTYLE_OPTIONS,
    trim: true
  }],
  job: {
    type: String,
    trim: true,
    maxlength: 120
  },
  school: {
    type: String,
    trim: true,
    maxlength: 120
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isProfileComplete: {
    type: Boolean,
    default: false
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  preferences: {
    ageRange: {
      min: { type: Number, default: DEFAULT_PREFERENCES.MIN_AGE },
      max: { type: Number, default: DEFAULT_PREFERENCES.MAX_AGE }
    },
    maxDistance: {
      type: Number,
      default: DEFAULT_PREFERENCES.MAX_DISTANCE // kilometers
    },
    lifestyle: [{
      type: String,
      enum: LIFESTYLE_OPTIONS,
      trim: true
    }],
    showMe: {
      type: [String],
      enum: ['male', 'female', 'non-binary', 'other'],
      default: [],
    },
    onlyShowOnline: {
      type: Boolean,
      default: false
    }
  },
  subscription: {
    type: {
      type: String,
      enum: ['free', 'premium'],
      default: 'free'
    },
    expiresAt: Date
  }
}, {
  timestamps: true
});

// Indexes
// Note: email and firebaseUid already have indexes from unique: true
userSchema.index({ isActive: 1, isProfileComplete: 1 });
//userSchema.index({ 'location.coordinates': '2dsphere' });

// Virtual for age
userSchema.virtual('age').get(function() {
  if (!this.dateOfBirth) return null;
  const today = new Date();
  const birthDate = new Date(this.dateOfBirth);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  if (this.password) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

userSchema.pre('validate', function(next) {
  if (Array.isArray(this.photos)) {
    if (this.photos.length > 6) {
      return next(new Error('Maximum of 6 photos allowed'));
    }
    const orders = new Set();
    let primaryCount = 0;

    for (let i = 0; i < this.photos.length; i += 1) {
      const photo = this.photos[i];
      if (photo.order === undefined || photo.order === null) {
        photo.order = i;
      }
      if (orders.has(photo.order)) {
        return next(new Error('Photo order must be unique'));
      }
      orders.add(photo.order);
      if (photo.isPrimary) {
        primaryCount += 1;
      }
    }

    if (primaryCount > 1) {
      return next(new Error('Only one photo can be primary'));
    }
  }

  if (Array.isArray(this.interests) && this.interests.length > 0) {
    const uniqueInterests = [...new Set(this.interests.map(item => String(item)))];
    if (uniqueInterests.length !== this.interests.length) {
      this.interests = uniqueInterests;
    }

    if (this.interests.length > 5) {
      return next(new Error('You can select up to 5 interests'));
    }

    const invalid = this.interests.filter(interest => !INTEREST_OPTIONS.includes(interest));
    if (invalid.length > 0) {
      return next(new Error(`Invalid interests: ${invalid.join(', ')}`));
    }
  }

  if (Array.isArray(this.lifestyle) && this.lifestyle.length > 0) {
    const uniqueLifestyle = [...new Set(this.lifestyle.map(item => String(item)))];
    if (uniqueLifestyle.length !== this.lifestyle.length) {
      this.lifestyle = uniqueLifestyle;
    }

    const invalidLifestyle = this.lifestyle.filter(item => !LIFESTYLE_OPTIONS.includes(item));
    if (invalidLifestyle.length > 0) {
      return next(new Error(`Invalid lifestyle values: ${invalidLifestyle.join(', ')}`));
    }
  }

  if (this.preferences) {
    if (this.preferences.ageRange) {
      const { min, max } = this.preferences.ageRange;
      if (min && max && min > max) {
        return next(new Error('Age range min must be less than or equal to max'));
      }
    }

    if (Array.isArray(this.preferences.showMe)) {
      this.preferences.showMe = [...new Set(this.preferences.showMe)];
    }

    if (Array.isArray(this.preferences.lifestyle) && this.preferences.lifestyle.length > 0) {
      const uniquePrefLifestyle = [...new Set(this.preferences.lifestyle.map(item => String(item)))];
      const invalidPrefLifestyle = uniquePrefLifestyle.filter(item => !LIFESTYLE_OPTIONS.includes(item));
      if (invalidPrefLifestyle.length > 0) {
        return next(new Error(`Invalid lifestyle filter: ${invalidPrefLifestyle.join(', ')}`));
      }
      this.preferences.lifestyle = uniquePrefLifestyle;
    }
  }

  if (this.location && Array.isArray(this.location.coordinates) && this.location.coordinates.length > 0) {
    if (this.location.coordinates.length !== 2) {
      return next(new Error('Location coordinates must contain [lng, lat]'));
    }
  }

  next();
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to get public profile (without sensitive data)
userSchema.methods.toPublicJSON = function() {
  const user = this.toObject({ virtuals: true });
  delete user.password;
  delete user.email;
  delete user.phone;
  delete user.firebaseUid;
  delete user.subscription;
  
  // Convert _id to id for consistency with frontend
  if (user._id) {
    user.id = user._id.toString();
    delete user._id;
  }
  
  // Ensure arrays are always arrays (not null/undefined)
  if (!user.photos) user.photos = [];
  if (!user.interests) user.interests = [];
  if (!user.interestedIn) user.interestedIn = [];
  if (!user.lifestyle) user.lifestyle = [];
  
  // Ensure required fields have values
  // Chỉ fallback về 'User' nếu firstName thực sự không có (null/undefined/empty)
  // Không override nếu đã có giá trị hợp lệ từ database
  if (!user.firstName || (typeof user.firstName === 'string' && user.firstName.trim().length === 0)) {
    user.firstName = 'User';
  }
  if (user.lastName == null || user.lastName === undefined) {
    user.lastName = '';
  }
  if (!user.gender) user.gender = 'other';
  
  // Convert dates to ISO strings
  if (user.dateOfBirth) {
    user.dateOfBirth = new Date(user.dateOfBirth).toISOString();
  } else {
    // If no dateOfBirth, set a default (18 years ago)
    const defaultDate = new Date();
    defaultDate.setFullYear(defaultDate.getFullYear() - 18);
    user.dateOfBirth = defaultDate.toISOString();
  }
  
  if (user.lastActive) {
    user.lastActive = new Date(user.lastActive).toISOString();
  }
  
  // Ensure preferences exist
  if (!user.preferences) {
    user.preferences = {
      ageRange: { min: DEFAULT_PREFERENCES.MIN_AGE, max: DEFAULT_PREFERENCES.MAX_AGE },
      maxDistance: DEFAULT_PREFERENCES.MAX_DISTANCE,
      lifestyle: [],
      showMe: [],
      onlyShowOnline: false
    };
  } else {
    user.preferences = {
      ageRange: {
        min: user.preferences.ageRange?.min ?? DEFAULT_PREFERENCES.MIN_AGE,
        max: user.preferences.ageRange?.max ?? DEFAULT_PREFERENCES.MAX_AGE
      },
      maxDistance: user.preferences.maxDistance ?? DEFAULT_PREFERENCES.MAX_DISTANCE,
      lifestyle: user.preferences.lifestyle ?? [],
      showMe: user.preferences.showMe ?? [],
      onlyShowOnline: Boolean(user.preferences.onlyShowOnline)
    };
  }
  
  if (user.location && user.location.coordinates && user.location.coordinates.length === 2) {
    user.location.coordinates = [
      Number(user.location.coordinates[0]),
      Number(user.location.coordinates[1])
    ];
  }
  
  return user;
};

module.exports = mongoose.model('User', userSchema);

