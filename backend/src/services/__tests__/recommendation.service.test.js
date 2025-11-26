const recommendationService = require('../recommendation.service');

describe('RecommendationService.computeScore', () => {
  const baseUser = {
    interests: ['travel', 'music', 'sports'],
    lifestyle: ['fitness', 'nightlife'],
    preferences: {
      ageRange: { min: 24, max: 34 },
      maxDistance: 50
    },
    location: {
      coordinates: [105.8, 21.03]
    }
  };

  it('rewards shared interests, lifestyle, activity and distance', () => {
    const candidate = {
      interests: ['music', 'reading', 'sports'],
      lifestyle: ['fitness'],
      dateOfBirth: new Date(new Date().setFullYear(new Date().getFullYear() - 28)),
      lastActive: new Date(),
      location: { coordinates: [105.81, 21.04] }
    };

    const result = recommendationService.computeScore(baseUser, candidate);

    expect(result.score).toBeGreaterThan(0);
    expect(result.score).toBeLessThanOrEqual(100);
    expect(result.breakdown.interests).toBeGreaterThan(0);
    expect(result.breakdown.distance).toBeGreaterThan(0);
    expect(result.distanceKm).toBeGreaterThanOrEqual(0);
  });

  it('returns zero distance score when candidate is beyond max distance', () => {
    const farCandidate = {
      interests: [],
      lifestyle: [],
      dateOfBirth: new Date(new Date().setFullYear(new Date().getFullYear() - 30)),
      lastActive: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
      location: { coordinates: [106.8, 16.04] }
    };

    const result = recommendationService.computeScore(baseUser, farCandidate, { maxDistance: 10 });

    expect(result.breakdown.distance).toBe(0);
    expect(result.distanceKm).toBeGreaterThan(10);
    expect(result.score).toBeLessThan(40);
  });
});

