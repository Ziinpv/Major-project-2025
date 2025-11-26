const express = require('express');
const { body } = require('express-validator');
const reportController = require('../controllers/report.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.use(authenticate);

router.post(
  '/',
  [
    body('reported').isMongoId().withMessage('Valid user ID is required'),
    body('reason').isIn([
      'spam',
      'inappropriate_content',
      'harassment',
      'fake_profile',
      'underage',
      'other'
    ]).withMessage('Valid reason is required'),
    body('description').optional().isLength({ max: 1000 }).withMessage('Description too long')
  ],
  reportController.createReport.bind(reportController)
);

router.get('/', reportController.getReports.bind(reportController));
router.put('/:reportId', reportController.updateReportStatus.bind(reportController));

module.exports = router;

