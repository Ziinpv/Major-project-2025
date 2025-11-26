const User = require('../models/User');
const {
  DEFAULT_PREFERENCES,
  DISCOVERY_SORT_OPTIONS
} = require('../utils/constants');

class UserRepository {
  async create(userData) {
    return await User.create(userData);
  }

  async findById(userId) {
    return await User.findById(userId);
  }

  async findByEmail(email) {
    return await User.findOne({ email: email.toLowerCase() });
  }

  async findByFirebaseUid(firebaseUid) {
    return await User.findOne({ firebaseUid });
  }

  async update(userId, updateData) {
    return await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );
  }

  async findNearbyUsers(userId, location = {}, maxDistance, filters = {}) {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    const query = {
      _id: { $ne: userId },
      isActive: true,
      isProfileComplete: true
    };

    if (location.province) {
      query['location.province'] = location.province;
    }
    if (location.city) {
      query['location.city'] = location.city;
    }

    // Age filter
    if (filters.ageRange) {
      const today = new Date();
      const minBirthDate = new Date(today.getFullYear() - filters.ageRange.max, today.getMonth(), today.getDate());
      const maxBirthDate = new Date(today.getFullYear() - filters.ageRange.min, today.getMonth(), today.getDate());
      query.dateOfBirth = { $gte: minBirthDate, $lte: maxBirthDate };
    }

    // Gender filter
    if (filters.showMe && filters.showMe.length > 0) {
      query.gender = { $in: filters.showMe };
    }

    return await User.find(query).limit(100);
  }

  async findPotentialMatches(userId, excludeIds = []) {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    const baseQuery = {
      _id: { $ne: userId },
      isActive: true,
      isProfileComplete: true
    };

    // Exclude already swiped users
    if (excludeIds.length > 0) {
      baseQuery._id = { $ne: userId, $nin: excludeIds };
    }

    const applyPreferenceFilters = query => {
      if (user.preferences?.showMe && user.preferences.showMe.length > 0) {
        query.gender = { $in: user.preferences.showMe };
      }

      if (user.preferences?.ageRange) {
        const today = new Date();
        const minBirthDate = new Date(today.getFullYear() - user.preferences.ageRange.max, today.getMonth(), today.getDate());
        const maxBirthDate = new Date(today.getFullYear() - user.preferences.ageRange.min, today.getMonth(), today.getDate());
        query.dateOfBirth = { $gte: minBirthDate, $lte: maxBirthDate };
      }
    };

    const applyLocationFilters = query => {
      if (user.location?.province) {
        query['location.province'] = user.location.province;
        if (user.location.city) {
          query['location.city'] = user.location.city;
        }
      }
    };

    const withLocationQuery = { ...baseQuery };
    applyPreferenceFilters(withLocationQuery);
    applyLocationFilters(withLocationQuery);

    let matches = await User.find(withLocationQuery).limit(50);

    // Fallback: if no users in same location, broaden search
    if (matches.length === 0) {
      const fallbackQuery = { ...baseQuery };
      applyPreferenceFilters(fallbackQuery);
      matches = await User.find(fallbackQuery).limit(50);
    }

    return matches;
  }

  async findCandidatesForDiscovery(currentUser, excludeIds = [], filters = {}) {
    const query = {
      _id: { $ne: currentUser._id, $nin: excludeIds },
      isActive: true,
      isProfileComplete: true
    };

    const showMe = (filters.showMe && filters.showMe.length > 0)
      ? filters.showMe
      : currentUser.preferences?.showMe || [];
    if (showMe.length > 0) {
      query.gender = { $in: showMe };
    }

    const ageMin = filters.ageMin || currentUser.preferences?.ageRange?.min || DEFAULT_PREFERENCES.MIN_AGE;
    const ageMax = filters.ageMax || currentUser.preferences?.ageRange?.max || DEFAULT_PREFERENCES.MAX_AGE;
    if (ageMin || ageMax) {
      const today = new Date();
      // minBirthDate: oldest person (ageMax years old) - set to start of day
      const minBirthDate = new Date(today.getFullYear() - ageMax, today.getMonth(), today.getDate());
      // maxBirthDate: youngest person (ageMin years old) - set to end of day to include all times
      const maxBirthDate = new Date(today.getFullYear() - ageMin, today.getMonth(), today.getDate(), 23, 59, 59, 999);
      query.dateOfBirth = { $gte: minBirthDate, $lte: maxBirthDate };
    }

    if (filters.lifestyle && filters.lifestyle.length > 0) {
      query.lifestyle = { $in: filters.lifestyle };
    }

    if (filters.interests && filters.interests.length > 0) {
      query.interests = { $in: filters.interests };
    }

    if (filters.onlyOnline || currentUser.preferences?.onlyShowOnline) {
      const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
      query.lastActive = { $gte: fiveMinutesAgo };
    }

    let dbQuery = User.find(query);

    // Determine maxDistance: if explicitly provided in filters, use it; otherwise use user preferences or default
    // If maxDistance is very large (> 1000km), treat it as "no distance filter"
    const maxDistance = filters.maxDistance !== undefined && filters.maxDistance !== null
      ? Number(filters.maxDistance)
      : (currentUser.preferences?.maxDistance || DEFAULT_PREFERENCES.MAX_DISTANCE);

    const coords = currentUser.location?.coordinates;
    const hasValidCoordinates =
      Array.isArray(coords) &&
      coords.length === 2 &&
      coords.every(
        (value) =>
          value !== null &&
          value !== undefined &&
          !Number.isNaN(Number(value))
      );

    // Only apply $near query if:
    // 1. User has valid coordinates
    // 2. maxDistance is set and reasonable (< 1000km, or if > 1000km, it means "no limit" so skip $near)
    // 3. maxDistance is not null/undefined
    const shouldApplyDistanceFilter = hasValidCoordinates && 
      maxDistance && 
      maxDistance > 0 && 
      maxDistance < 1000; // If >= 1000km, treat as "no distance limit"

    if (shouldApplyDistanceFilter) {
      const [lng, lat] = coords.map((v) => Number(v));
      dbQuery = dbQuery.where({
        'location.coordinates': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [lng, lat]
            },
            $maxDistance: maxDistance * 1000 // km -> m
          }
        }
      });
    }

    const sortMode = filters.sort || DISCOVERY_SORT_OPTIONS.BEST;
    if (sortMode === DISCOVERY_SORT_OPTIONS.NEWEST) {
      dbQuery = dbQuery.sort({ createdAt: -1 });
    } else {
      dbQuery = dbQuery.sort({ lastActive: -1 });
    }

    const limit = Math.min(filters.limit || 50, 100);
    return await dbQuery.limit(limit);
  }

  async updateLastActive(userId) {
    return await User.findByIdAndUpdate(
      userId,
      { lastActive: new Date() },
      { new: true }
    );
  }
}

module.exports = new UserRepository();

