const express = require('express');
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);
router.get('/', userController.getDiscovery.bind(userController));

module.exports = router;

