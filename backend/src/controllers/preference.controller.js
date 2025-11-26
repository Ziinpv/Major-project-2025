const Preference = require('../models/Preference');
const User = require('../models/User');

class PreferenceController {
  async getPreferences(req, res, next) {
    try {
      let preference = await Preference.findOne({ user: req.userId });
      
      if (!preference) {
        // Get from user model
        const user = await User.findById(req.userId);
        preference = {
          ageRange: user.preferences?.ageRange || { min: 18, max: 100 },
          maxDistance: user.preferences?.maxDistance || 50,
          showMe: user.preferences?.showMe || []
        };
      }

      res.json({
        success: true,
        data: { preference }
      });
    } catch (error) {
      next(error);
    }
  }

  async updatePreferences(req, res, next) {
    try {
      let preference = await Preference.findOne({ user: req.userId });
      
      if (preference) {
        preference = await Preference.findByIdAndUpdate(
          preference._id,
          { $set: req.body },
          { new: true, runValidators: true }
        );
      } else {
        preference = await Preference.create({
          user: req.userId,
          ...req.body
        });
      }

      // Also update user preferences
      await User.findByIdAndUpdate(req.userId, {
        $set: {
          'preferences.ageRange': preference.ageRange,
          'preferences.maxDistance': preference.maxDistance,
          'preferences.showMe': preference.showMe
        }
      });

      res.json({
        success: true,
        data: { preference }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new PreferenceController();

