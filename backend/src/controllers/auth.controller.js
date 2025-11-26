const authService = require('../services/auth.service');

class AuthController {
  async registerWithFirebase(req, res, next) {
    try {
      const { firebaseToken, ...userData } = req.body;
      const result = await authService.registerWithFirebase(firebaseToken, userData);
      res.status(201).json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async loginWithFirebase(req, res, next) {
    try {
      const { firebaseToken } = req.body;
      const result = await authService.loginWithFirebase(firebaseToken);
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async registerWithEmail(req, res, next) {
    try {
      const { email, password, ...userData } = req.body;
      const result = await authService.registerWithEmail(email, password, userData);
      res.status(201).json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async loginWithEmail(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await authService.loginWithEmail(email, password);
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async getMe(req, res, next) {
    try {
      res.json({
        success: true,
        data: {
          user: req.user.toPublicJSON()
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();

