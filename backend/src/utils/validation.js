const { body, param, query } = require('express-validator');

const validateObjectId = (field) => {
  return param(field).isMongoId().withMessage(`Invalid ${field} format`);
};

const validateEmail = () => {
  return body('email').isEmail().normalizeEmail().withMessage('Invalid email format');
};

const validatePassword = () => {
  return body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters');
};

const validateGender = () => {
  return body('gender')
    .isIn(['male', 'female', 'non-binary', 'other'])
    .withMessage('Invalid gender');
};

const validateAgeRange = () => {
  return [
    body('ageRange.min')
      .optional()
      .isInt({ min: 18, max: 100 })
      .withMessage('Min age must be between 18 and 100'),
    body('ageRange.max')
      .optional()
      .isInt({ min: 18, max: 100 })
      .withMessage('Max age must be between 18 and 100'),
  ];
};

const validateSwipeAction = () => {
  return body('action')
    .isIn(['like', 'pass', 'superlike'])
    .withMessage('Invalid swipe action');
};

const validateCoordinates = () => {
  return [
    body('longitude')
      .isFloat({ min: -180, max: 180 })
      .withMessage('Invalid longitude'),
    body('latitude')
      .isFloat({ min: -90, max: 90 })
      .withMessage('Invalid latitude'),
  ];
};

module.exports = {
  validateObjectId,
  validateEmail,
  validatePassword,
  validateGender,
  validateAgeRange,
  validateSwipeAction,
  validateCoordinates,
};

