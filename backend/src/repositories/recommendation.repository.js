const DiscoveryLog = require('../models/DiscoveryLog');

class RecommendationRepository {
  async logDiscovery(payload) {
    try {
      await DiscoveryLog.create({
        viewer: payload.viewer,
        candidate: payload.candidate,
        score: payload.score,
        breakdown: payload.breakdown,
        filters: payload.filters,
        distanceKm: payload.distanceKm
      });
    } catch (error) {
      // Logging failures should not break discovery flow
      console.warn('[recommendation] Failed to persist discovery log', error.message);
    }
  }
}

module.exports = new RecommendationRepository();

