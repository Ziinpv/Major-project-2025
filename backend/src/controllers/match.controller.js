const matchRepository = require('../repositories/match.repository');

class MatchController {
  async getMatches(req, res, next) {
    try {
      const matches = await matchRepository.findByUserId(req.userId);
      const formattedMatches = matches.map(m => {
        if (typeof m.toPublicJSON === 'function') {
          return m.toPublicJSON();
        }
        // Fallback: manually format if method doesn't exist
        const match = m.toObject ? m.toObject({ virtuals: true }) : m;
        if (match._id) {
          match.id = match._id.toString();
          delete match._id;
        }
        delete match.__v;
        if (match.users && Array.isArray(match.users)) {
          match.users = match.users.map(user => {
            if (user && typeof user === 'object') {
              const userObj = { ...user };
              if (userObj._id) {
                userObj.id = userObj._id.toString();
                delete userObj._id;
              }
              if (userObj.lastName === null || userObj.lastName === undefined) {
                userObj.lastName = '';
              }
              if (!userObj.photos) userObj.photos = [];
              if (!userObj.interests) userObj.interests = [];
              if (!userObj.interestedIn) userObj.interestedIn = [];
              delete userObj.__v;
              return userObj;
            }
            return user;
          });
        }
        if (match.matchedAt) {
          match.matchedAt = new Date(match.matchedAt).toISOString();
        }
        if (match.unmatchedAt) {
          match.unmatchedAt = new Date(match.unmatchedAt).toISOString();
        }
        if (match.lastMessageAt) {
          match.lastMessageAt = new Date(match.lastMessageAt).toISOString();
        }
        return match;
      });
      res.json({
        success: true,
        data: { matches: formattedMatches }
      });
    } catch (error) {
      next(error);
    }
  }

  async getMatch(req, res, next) {
    try {
      const match = await matchRepository.findById(req.params.matchId);
      if (!match) {
        return res.status(404).json({
          success: false,
          error: 'Match not found'
        });
      }

      // Verify user is part of the match
      if (!match.users.some(u => u._id.toString() === req.userId)) {
        return res.status(403).json({
          success: false,
          error: 'Not authorized'
        });
      }

      res.json({
        success: true,
        data: { match: match.toPublicJSON ? match.toPublicJSON() : match }
      });
    } catch (error) {
      next(error);
    }
  }

  async unmatch(req, res, next) {
    try {
      const match = await matchRepository.findById(req.params.matchId);
      if (!match) {
        return res.status(404).json({
          success: false,
          error: 'Match not found'
        });
      }

      // Verify user is part of the match
      if (!match.users.some(u => u._id.toString() === req.userId)) {
        return res.status(403).json({
          success: false,
          error: 'Not authorized'
        });
      }

      const updatedMatch = await matchRepository.unmatch(req.params.matchId, req.userId);
      res.json({
        success: true,
        data: { match: updatedMatch.toPublicJSON ? updatedMatch.toPublicJSON() : updatedMatch }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new MatchController();

