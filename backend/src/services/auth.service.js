const jwt = require('jsonwebtoken');
const { verifyFirebaseToken } = require('../config/firebase');
const userRepository = require('../repositories/user.repository');

class AuthService {
  generateToken(userId) {
    return jwt.sign(
      { userId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }

  async registerWithFirebase(firebaseToken, userData) {
    // Verify Firebase token
    const firebaseUser = await verifyFirebaseToken(firebaseToken);

    // Check if user already exists
    let user = await userRepository.findByFirebaseUid(firebaseUser.uid);

    if (user) {
      throw new Error('User already exists');
    }

    // Check if email already exists
    if (firebaseUser.email) {
      const existingUser = await userRepository.findByEmail(firebaseUser.email);
      if (existingUser) {
        throw new Error('Email already registered');
      }
    }

    // Chuẩn hoá dữ liệu đầu vào, fallback an toàn nếu frontend không gửi đủ
    // Tên
    const namePartsFromFirebase = firebaseUser.name?.split(' ') || [];
    const fallbackFirstName = namePartsFromFirebase.length > 0 ? namePartsFromFirebase[0] : 'User';
    const fallbackLastName = namePartsFromFirebase.length > 1 ? namePartsFromFirebase.slice(1).join(' ') : '';

    const firstName = (userData.firstName || '').trim() || fallbackFirstName;
    const lastName = (userData.lastName || '').trim() || fallbackLastName;

    // Ngày sinh
    let dateOfBirth;
    if (userData.dateOfBirth) {
      dateOfBirth = new Date(userData.dateOfBirth);
      if (Number.isNaN(dateOfBirth.getTime())) {
        dateOfBirth = undefined;
      }
    }
    if (!dateOfBirth) {
      dateOfBirth = new Date();
      dateOfBirth.setFullYear(dateOfBirth.getFullYear() - 18);
    }

    // Giới tính
    const gender = (userData.gender || '').toString().toLowerCase();
    const allowedGenders = ['male', 'female', 'non-binary', 'other'];
    const normalizedGender = allowedGenders.includes(gender) ? gender : 'other';

    // Tạo user mới
    user = await userRepository.create({
      firebaseUid: firebaseUser.uid,
      email: firebaseUser.email || userData.email,
      phone: firebaseUser.phone_number || userData.phone,
      firstName,
      lastName,
      dateOfBirth,
      gender: normalizedGender,
      interestedIn: userData.interestedIn || [],
      isProfileComplete: false
    });

    const token = this.generateToken(user._id);

    return {
      user: user.toPublicJSON(),
      token
    };
  }

  async loginWithFirebase(firebaseToken) {
    const firebaseUser = await verifyFirebaseToken(firebaseToken);
    
    let user = await userRepository.findByFirebaseUid(firebaseUser.uid);

    if (!user) {
      // Create user if doesn't exist (for first-time login)
      // Note: dateOfBirth and gender are required, so we use defaults
      // User will need to complete profile setup later
      const defaultDateOfBirth = new Date();
      defaultDateOfBirth.setFullYear(defaultDateOfBirth.getFullYear() - 18); // Default to 18 years old
      
      // Parse name from Firebase user
      const nameParts = firebaseUser.name?.split(' ') || [];
      const firstName = nameParts.length > 0 ? nameParts[0] : 'User';
      const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';
      
      user = await userRepository.create({
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email,
        phone: firebaseUser.phone_number,
        firstName: firstName,
        lastName: lastName, // Can be empty string
        dateOfBirth: defaultDateOfBirth,
        gender: 'other', // Default gender, user will update in profile setup
        isProfileComplete: false
      });
    }

    // Update last active
    await userRepository.updateLastActive(user._id);

    const token = this.generateToken(user._id);

    return {
      user: user.toPublicJSON(),
      token
    };
  }

  async registerWithEmail(email, password, userData) {
    // Check if user exists
    const existingUser = await userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // Create user
    const user = await userRepository.create({
      email,
      password,
      firstName: userData.firstName,
      lastName: userData.lastName,
      dateOfBirth: userData.dateOfBirth,
      gender: userData.gender,
      interestedIn: userData.interestedIn || []
    });

    const token = this.generateToken(user._id);

    return {
      user: user.toPublicJSON(),
      token
    };
  }

  async loginWithEmail(email, password) {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Invalid credentials');
    }

    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    await userRepository.updateLastActive(user._id);

    const token = this.generateToken(user._id);

    return {
      user: user.toPublicJSON(),
      token
    };
  }
}

module.exports = new AuthService();

