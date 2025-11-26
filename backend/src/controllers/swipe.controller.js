const swipeService = require('../services/swipe.service');

class SwipeController {
  async swipe(req, res, next) {
    try {
      const { userId: swipedUserId, action } = req.body;
      const result = await swipeService.swipe(req.userId, swipedUserId, action);
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  async getSwipeHistory(req, res, next) {
    try {
      const history = await swipeService.getSwipeHistory(req.userId);
      res.json({
        success: true,
        data: { history }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new SwipeController();

