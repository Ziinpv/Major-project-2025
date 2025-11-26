const {
  DEFAULT_PREFERENCES,
  DISCOVERY_SCORE_WEIGHTS
} = require('../utils/constants');
const recommendationRepository = require('../repositories/recommendation.repository');

class RecommendationService {
  computeScore(currentUser, candidate, options = {}) {
    let score = 0;
    const breakdown = {};

    const interestScore = this.#calcOverlapScore(
      currentUser.interests,
      candidate.interests,
      DISCOVERY_SCORE_WEIGHTS.INTERESTS
    );
    score += interestScore.points;
    breakdown.interests = interestScore.points;

    const lifestyleScore = this.#calcOverlapScore(
      currentUser.lifestyle,
      candidate.lifestyle,
      DISCOVERY_SCORE_WEIGHTS.LIFESTYLE
    );
    score += lifestyleScore.points;
    breakdown.lifestyle = lifestyleScore.points;

    const ageScore = this.#calcAgeScore(currentUser, candidate);
    score += ageScore;
    breakdown.age = ageScore;

    const activityScore = this.#calcActivityScore(candidate);
    score += activityScore;
    breakdown.activity = activityScore;

    const distanceScore = this.#calcDistanceScore(
      currentUser,
      candidate,
      options.maxDistance ?? currentUser.preferences?.maxDistance ?? DEFAULT_PREFERENCES.MAX_DISTANCE
    );
    score += distanceScore.points;
    breakdown.distance = distanceScore.points;

    const totalWeights = Object.values(DISCOVERY_SCORE_WEIGHTS).reduce((sum, value) => sum + value, 0);
    const normalized = Math.min(100, Math.round((score / totalWeights) * 100));

    return {
      score: normalized,
      breakdown,
      distanceKm: distanceScore.distance ?? null
    };
  }

  async logDiscoveryResults(viewerId, results, filters = {}) {
    if (!viewerId || !Array.isArray(results) || results.length === 0) {
      return;
    }
    const payloadFilters = { ...filters };
    const slice = results.slice(0, 25);
    await Promise.allSettled(slice.map(item => {
      const candidateId = item.user?._id || item.userId || item.candidateId;
      if (!candidateId) return Promise.resolve();
      return recommendationRepository.logDiscovery({
        viewer: viewerId,
        candidate: candidateId,
        score: item.score,
        breakdown: item.breakdown,
        distanceKm: item.distanceKm,
        filters: payloadFilters
      });
    }));
  }

  #calcOverlapScore(listA = [], listB = [], weight = 20) {
    if (!Array.isArray(listA) || !Array.isArray(listB) || listA.length === 0 || listB.length === 0) {
      return { points: 0 };
    }
    const setB = new Set(listB);
    const overlap = listA.filter(item => setB.has(item));
    const denominator = Math.max(listA.length, listB.length);
    return { points: Math.min(weight, (overlap.length / denominator) * weight) };
  }

  #calcAgeScore(user, candidate) {
    const agePref = user.preferences?.ageRange;
    if (!agePref) return 0;
    const candidateAge = this.#calculateAge(candidate.dateOfBirth);
    if (!candidateAge) return 0;
    if (candidateAge >= agePref.min && candidateAge <= agePref.max) {
      return DISCOVERY_SCORE_WEIGHTS.AGE;
    }
    const diff = candidateAge < agePref.min
      ? agePref.min - candidateAge
      : candidateAge - agePref.max;
    return Math.max(0, DISCOVERY_SCORE_WEIGHTS.AGE - diff * 2);
  }

  #calcActivityScore(candidate) {
    const lastActive = candidate.lastActive ? new Date(candidate.lastActive) : candidate.updatedAt ? new Date(candidate.updatedAt) : null;
    if (!lastActive) {
      return 0;
    }
    const daysInactive = (Date.now() - lastActive.getTime()) / (1000 * 60 * 60 * 24);
    if (daysInactive <= 1) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY;
    if (daysInactive <= 7) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY - 2;
    if (daysInactive <= 14) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY - 5;
    if (daysInactive <= 30) return 2;
    return 0;
  }

  #calcDistanceScore(currentUser, candidate, maxDistanceKm) {
    const userCoords = currentUser.location?.coordinates;
    const candidateCoords = candidate.location?.coordinates;
    if (!this.#isGeoPoint(userCoords) || !this.#isGeoPoint(candidateCoords)) {
      return { points: 0, distance: null };
    }
    const distance = this.#haversine(userCoords, candidateCoords);
    if (distance > maxDistanceKm) {
      return { points: 0, distance };
    }
    // closer distance => higher points
    const points = Math.max(
      0,
      DISCOVERY_SCORE_WEIGHTS.DISTANCE - (distance / Math.max(maxDistanceKm, 1)) * DISCOVERY_SCORE_WEIGHTS.DISTANCE
    );
    return { points, distance };
  }

  #isGeoPoint(value) {
    return Array.isArray(value)
      && value.length === 2
      && value.every(item => typeof item === 'number' && !Number.isNaN(item));
  }

  #haversine([lng1, lat1], [lng2, lat2]) {
    const toRad = deg => (deg * Math.PI) / 180;
    const R = 6371; // km
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lng2 - lng1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  #calculateAge(date) {
    if (!date) return null;
    const dob = new Date(date);
    if (Number.isNaN(dob.getTime())) return null;
    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const m = today.getMonth() - dob.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
      age--;
    }
    return age;
  }
}

module.exports = new RecommendationService();

