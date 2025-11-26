const jwt = require('jsonwebtoken');
const { verifyFirebaseToken } = require('../config/firebase');
const User = require('../models/User');

/**
 * Middleware to authenticate requests using JWT or Firebase token
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);

    // Try JWT first (for backend-generated tokens)
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId).select('-password');
      
      if (!user) {
        return res.status(401).json({ error: 'User not found' });
      }

      req.user = user;
      req.userId = user._id.toString();
      return next();
    } catch (jwtError) {
      // If JWT fails, try Firebase token
      try {
        const firebaseUser = await verifyFirebaseToken(token);
        
        // Find user by Firebase UID
        const user = await User.findOne({ firebaseUid: firebaseUser.uid });
        
        if (!user) {
          return res.status(401).json({ error: 'User not found' });
        }

        req.user = user;
        req.userId = user._id.toString();
        req.firebaseUser = firebaseUser;
        return next();
      } catch (firebaseError) {
        return res.status(401).json({ error: 'Invalid token' });
      }
    }
  } catch (error) {
    return res.status(401).json({ error: 'Authentication failed' });
  }
};

module.exports = { authenticate };

