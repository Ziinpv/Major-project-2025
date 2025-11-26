const express = require('express');
const preferenceController = require('../controllers/preference.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.get('/', preferenceController.getPreferences.bind(preferenceController));
router.put('/', preferenceController.updatePreferences.bind(preferenceController));

module.exports = router;

