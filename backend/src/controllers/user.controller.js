const userService = require('../services/user.service');

class UserController {
  async getProfile(req, res, next) {
    try {
      const user = await userService.getProfile(req.userId);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      // Debug payload từ client
      console.log('📝 [updateProfile] body:', req.body);
      const user = await userService.updateProfile(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateProfilePhotos(req, res, next) {
    try {
      // Debug payload từ client
      console.log('🖼️ [updateProfilePhotos] body:', req.body);
      const user = await userService.updateProfilePhotos(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async getDiscovery(req, res, next) {
    try {
      const results = await userService.getDiscovery(req.userId, req.query || {});
      res.json({
        success: true,
        data: {
          users: results.map(item => ({
            ...item.user.toPublicJSON(),
            score: item.score,
            scoreBreakdown: item.breakdown,
            distanceKm: item.distanceKm
          }))
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateLocation(req, res, next) {
    try {
      const user = await userService.updateLocation(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }

  async deleteAccount(req, res, next) {
    try {
      const userId = req.userId;   // lấy từ JWT

      await userService.deleteAccount(userId);

      return res.json({
        success: true,
        message: "Account deleted successfully"
      });
    } catch (error) {
      next(error);
    }
  }

}

module.exports = new UserController();

