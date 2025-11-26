const userRepository = require('../repositories/user.repository');
const swipeRepository = require('../repositories/swipe.repository');
const recommendationService = require('./recommendation.service');
const { getCoordinates } = require('../utils/vietnam_coordinates');
const {
  INTEREST_OPTIONS,
  LIFESTYLE_OPTIONS,
  DEFAULT_PREFERENCES,
  DISCOVERY_SORT_OPTIONS
} = require('../utils/constants');

class UserService {
  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }

  async updateProfile(userId, payload) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    const updates = {};

    if (payload.bio !== undefined) {
      if (typeof payload.bio !== 'string' || payload.bio.length > 300) {
        const error = new Error('Bio must be a string up to 300 characters');
        error.statusCode = 400;
        throw error;
      }
      updates.bio = payload.bio.trim();
    }

    if (payload.job !== undefined) {
      if (payload.job && payload.job.length > 120) {
        const error = new Error('Job must be 120 characters or less');
        error.statusCode = 400;
        throw error;
      }
      updates.job = payload.job ? payload.job.trim() : '';
    }

    if (payload.school !== undefined) {
      if (payload.school && payload.school.length > 120) {
        const error = new Error('School must be 120 characters or less');
        error.statusCode = 400;
        throw error;
      }
      updates.school = payload.school ? payload.school.trim() : '';
    }

    if (payload.interests !== undefined) {
      if (!Array.isArray(payload.interests)) {
        const error = new Error('Interests must be an array');
        error.statusCode = 400;
        throw error;
      }
      const uniqueInterests = [...new Set(payload.interests)].map(item => String(item));
      if (uniqueInterests.length > 5) {
        const error = new Error('You can select up to 5 interests');
        error.statusCode = 400;
        throw error;
      }
      const invalid = uniqueInterests.filter(interest => !INTEREST_OPTIONS.includes(interest));
      if (invalid.length > 0) {
        const error = new Error(`Invalid interests: ${invalid.join(', ')}`);
        error.statusCode = 400;
        throw error;
      }
      updates.interests = uniqueInterests;
    }

    if (payload.gender !== undefined) {
      const allowedGenders = ['male', 'female', 'non-binary', 'other'];
      if (!allowedGenders.includes(payload.gender)) {
        const error = new Error('Invalid gender value');
        error.statusCode = 400;
        throw error;
      }
      updates.gender = payload.gender;
    }

    if (payload.lifestyle !== undefined) {
      if (!Array.isArray(payload.lifestyle)) {
        const error = new Error('Lifestyle must be an array');
        error.statusCode = 400;
        throw error;
      }
      const uniqueLifestyle = [...new Set(payload.lifestyle)].map(item => String(item));
      if (uniqueLifestyle.length > 5) {
        const error = new Error('You can select up to 5 lifestyle tags');
        error.statusCode = 400;
        throw error;
      }
      const invalidLifestyle = uniqueLifestyle.filter(item => !LIFESTYLE_OPTIONS.includes(item));
      if (invalidLifestyle.length > 0) {
        const error = new Error(`Invalid lifestyle: ${invalidLifestyle.join(', ')}`);
        error.statusCode = 400;
        throw error;
      }
      updates.lifestyle = uniqueLifestyle;
    }

    Object.assign(user, updates);

    // Re-check profile completeness
    const isComplete = this.checkProfileComplete(user);
    if (isComplete) {
      user.isProfileComplete = true;
    }

    await user.save();
    return user;
  }

  async updateProfilePhotos(userId, payload) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    if (!Array.isArray(payload.photos)) {
      const error = new Error('Photos array is required');
      error.statusCode = 400;
      throw error;
    }

    const removedIds = new Set((payload.removedPhotoIds || []).map(id => id.toString()));
    const existingPhotos = new Map(
      user.photos.map(photo => [photo._id.toString(), photo])
    );

    let workingPhotos = [];

    payload.photos.forEach((photo, index) => {
      if (!photo || !photo.url) return;
      if (photo.id && removedIds.has(photo.id.toString())) {
        return;
      }

      if (photo.id && existingPhotos.has(photo.id.toString())) {
        const existing = existingPhotos.get(photo.id.toString());
        workingPhotos.push({
          ...existing.toObject(),
          url: photo.url,
          order: typeof photo.order === 'number' ? photo.order : index
        });
      } else {
        workingPhotos.push({
          url: photo.url,
          order: typeof photo.order === 'number' ? photo.order : index,
          isPrimary: false
        });
      }
    });

    if (workingPhotos.length > 6) {
      const error = new Error('Maximum of 6 photos allowed');
      error.statusCode = 400;
      throw error;
    }

    // Normalize order ascending and ensure unique
    workingPhotos = workingPhotos
      .sort((a, b) => (a.order || 0) - (b.order || 0))
      .map((photo, index) => {
        photo.order = index;
        photo.isPrimary = index === 0;
        return photo;
      });

    user.photos = workingPhotos;

    const isComplete = this.checkProfileComplete(user);
    if (isComplete) {
      user.isProfileComplete = true;
    }

    await user.save();
    return user;
  }

  checkProfileComplete(user) {
    return Boolean(
      user?.firstName &&
      user?.dateOfBirth &&
      user?.gender &&
      Array.isArray(user?.photos) &&
      user.photos.length > 0 &&
      user?.location &&
      user.location.province &&
      user.location.city
    );
  }

  async getDiscovery(userId, filters = {}) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    const swipedIds = await swipeRepository.getSwipedUserIds(userId);
    const parsedFilters = this.parseDiscoveryFilters(filters);

    const candidates = await userRepository.findCandidatesForDiscovery(
      user,
      swipedIds,
      parsedFilters
    );

    const enriched = candidates.map(candidate => {
      const { score, breakdown, distanceKm } = recommendationService.computeScore(
        user,
        candidate,
        { maxDistance: parsedFilters.maxDistance }
      );
      return {
        user: candidate,
        score,
        breakdown,
        distanceKm
      };
    });

    if (parsedFilters.sort !== DISCOVERY_SORT_OPTIONS.NEWEST) {
      enriched.sort((a, b) => b.score - a.score);
    }

    await recommendationService.logDiscoveryResults(
      user._id,
      enriched,
      parsedFilters
    );

    return enriched;
  }

  parseDiscoveryFilters(rawFilters = {}) {
    const parsed = {};

    if (rawFilters.ageMin || rawFilters.ageMax) {
      const min = this.#sanitizeNumber(rawFilters.ageMin, DEFAULT_PREFERENCES.MIN_AGE);
      const max = this.#sanitizeNumber(rawFilters.ageMax, DEFAULT_PREFERENCES.MAX_AGE);
      parsed.ageMin = Math.max(DEFAULT_PREFERENCES.MIN_AGE, Math.min(min, max));
      parsed.ageMax = Math.max(parsed.ageMin, max);
    }

    if (rawFilters.distance) {
      parsed.maxDistance = Math.max(1, this.#sanitizeNumber(rawFilters.distance, DEFAULT_PREFERENCES.MAX_DISTANCE));
    } else if (rawFilters.maxDistance) {
      parsed.maxDistance = Math.max(1, this.#sanitizeNumber(rawFilters.maxDistance, DEFAULT_PREFERENCES.MAX_DISTANCE));
    }

    const lifestyle = this.#sanitizeArray(rawFilters.lifestyle, LIFESTYLE_OPTIONS);
    if (lifestyle.length > 0) {
      parsed.lifestyle = lifestyle;
    }

    const interests = this.#sanitizeArray(rawFilters.interests, INTEREST_OPTIONS);
    if (interests.length > 0) {
      parsed.interests = interests;
    }

    const showMe = this.#sanitizeArray(rawFilters.showMe, ['male', 'female', 'non-binary', 'other']);
    if (showMe.length > 0) {
      parsed.showMe = showMe;
    }

    if (typeof rawFilters.onlyOnline !== 'undefined') {
      parsed.onlyOnline = this.#toBoolean(rawFilters.onlyOnline);
    }

    if (rawFilters.sort && Object.values(DISCOVERY_SORT_OPTIONS).includes(rawFilters.sort)) {
      parsed.sort = rawFilters.sort;
    } else {
      parsed.sort = DISCOVERY_SORT_OPTIONS.BEST;
    }

    if (rawFilters.limit) {
      parsed.limit = Math.min(this.#sanitizeNumber(rawFilters.limit, 50), 100);
    }

    return parsed;
  }

  #sanitizeNumber(value, fallback) {
    const num = Number(value);
    return Number.isFinite(num) ? num : fallback;
  }

  #sanitizeArray(value, allowList) {
    if (!value) return [];
    const arr = Array.isArray(value)
      ? value
      : String(value).includes(',')
        ? String(value).split(',')
        : [value];
    const set = new Set();
    arr.forEach(item => {
      const str = String(item).trim();
      if (allowList.includes(str)) {
        set.add(str);
      }
    });
    return Array.from(set);
  }

  #toBoolean(value) {
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      return ['true', '1', 'yes', 'on'].includes(value.toLowerCase());
    }
    if (typeof value === 'number') {
      return value === 1;
    }
    return false;
  }

  async updateLocation(userId, locationData) {
    if (!locationData.province || !locationData.city) {
      const error = new Error('Province and city are required');
      error.statusCode = 400;
      throw error;
    }

    let coordinates;

    // 1. Ưu tiên toạ độ gửi trực tiếp từ client (nếu có)
    if (Array.isArray(locationData.coordinates) && locationData.coordinates.length === 2) {
      coordinates = [
        Number(locationData.coordinates[0]),
        Number(locationData.coordinates[1])
      ];
    } else if (
      typeof locationData.longitude === 'number' &&
      typeof locationData.latitude === 'number'
    ) {
      coordinates = [Number(locationData.longitude), Number(locationData.latitude)];
    }

    // 2. Nếu client không gửi toạ độ, tra cứu theo tên tỉnh/thành
    if (!coordinates && locationData.province) {
      const lookedUp = getCoordinates(locationData.province);
      if (Array.isArray(lookedUp) && lookedUp.length === 2) {
        coordinates = [Number(lookedUp[0]), Number(lookedUp[1])];
      }
    }

    const location = {
      province: locationData.province,
      city: locationData.city,
      district: locationData.district || '',
      address: locationData.address || '',
      country: locationData.country || 'Vietnam',
      lastUpdatedAt: new Date()
    };

    if (coordinates) {
      // Lưu theo chuẩn Geo (lng, lat)
      location.type = 'Point';
      location.coordinates = coordinates;
    }

    return await userRepository.update(userId, { location });
  }
}

module.exports = new UserService();

