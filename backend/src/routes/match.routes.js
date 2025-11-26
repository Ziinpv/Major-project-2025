const express = require('express');
const matchController = require('../controllers/match.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.get('/', matchController.getMatches.bind(matchController));
router.get('/:matchId', matchController.getMatch.bind(matchController));
router.delete('/:matchId', matchController.unmatch.bind(matchController));

module.exports = router;

