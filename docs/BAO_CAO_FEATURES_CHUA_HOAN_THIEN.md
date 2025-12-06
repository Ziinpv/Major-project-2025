# BÁO CÁO FEATURES ĐÃ CÓ NHƯNG CHƯA HOÀN THIỆN

**Ngày lập báo cáo:** 02/12/2025  
**Phiên bản dự án:** 1.0  
**Mục đích:** Liệt kê và phân tích các tính năng đã được implement một phần nhưng chưa hoàn thiện

---

## 📋 MỤC LỤC

1. [Tổng Quan](#1-tổng-quan)
2. [Account Management Features](#2-account-management-features)
3. [Security Features](#3-security-features)
4. [Chat & Messaging Features](#4-chat--messaging-features)
5. [Notification Features](#5-notification-features)
6. [Settings & Privacy Features](#6-settings--privacy-features)
7. [Admin & Moderation Features](#7-admin--moderation-features)
8. [Khuyến Nghị Hoàn Thiện](#8-khuyến-nghị-hoàn-thiện)

---

## 1. TỔNG QUAN

### 1.1. Thống Kê Features Chưa Hoàn Thiện

| Hạng Mục | Số Lượng | Mức Độ Hoàn Thiện | Ưu Tiên |
|----------|----------|-------------------|---------|
| **Account Management** | 3 | 20-40% | 🔴 Cao |
| **Security** | 2 | 30-50% | 🔴 Cao |
| **Chat Media** | 3 | 10-30% | 🟡 Trung bình |
| **Notifications** | 2 | 60-70% | 🟡 Trung bình |
| **Settings** | 4 | 0-50% | 🟡 Trung bình |
| **Admin Features** | 2 | 40-60% | 🟢 Thấp |

**Tổng:** 16 features chưa hoàn thiện

### 1.2. Phân Loại Theo Mức Độ

**🔴 Critical (Cần hoàn thiện ngay):**
- Đổi mật khẩu
- Xóa tài khoản
- FCM token registration

**🟡 Important (Cần hoàn thiện sớm):**
- Chat media upload
- Block user
- Privacy settings
- Account deactivation

**🟢 Nice to Have:**
- Admin dashboard
- Advanced moderation tools

---

## 2. ACCOUNT MANAGEMENT FEATURES

### 2.1. ❌ Đổi Mật Khẩu (Change Password)

**Trạng thái:** Chưa có API endpoint và UI

**Đã có:**
- ✅ `comparePassword()` method trong User model (`backend/src/models/User.js:311`)
- ✅ Password hashing với bcrypt (tự động khi save)
- ✅ Password validation (min 6 characters)

**Thiếu:**
- ❌ API endpoint: `PUT /api/users/password` hoặc `PATCH /api/users/password`
- ❌ Controller method trong `user.controller.js`
- ❌ Service method trong `user.service.js`
- ❌ Route trong `user.routes.js`
- ❌ UI screen/component trong frontend
- ❌ Validation cho old password
- ❌ Validation cho new password (strength requirements)
- ❌ Email notification khi đổi mật khẩu

**Code hiện tại:**
```javascript
// backend/src/models/User.js
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};
```

**Cần implement:**

**Backend:**
```javascript
// backend/src/routes/user.routes.js
router.put('/password', 
  [
    body('oldPassword').notEmpty().withMessage('Old password is required'),
    body('newPassword').isLength({ min: 8 })
      .matches(/[a-z]/).withMessage('Password must contain lowercase')
      .matches(/[A-Z]/).withMessage('Password must contain uppercase')
      .matches(/[0-9]/).withMessage('Password must contain number')
  ],
  validate,
  userController.changePassword.bind(userController)
);

// backend/src/controllers/user.controller.js
async changePassword(req, res, next) {
  try {
    const { oldPassword, newPassword } = req.body;
    const userId = req.userId;
    
    const user = await User.findById(userId).select('+password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const isValid = await user.comparePassword(oldPassword);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid old password' });
    }
    
    user.password = newPassword;
    await user.save();
    
    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    next(error);
  }
}
```

**Frontend:**
- Settings screen cần thêm "Change Password" option
- Dialog/Sheet để nhập old password và new password
- Validation và error handling

**Ước tính thời gian:** 4-6 giờ

---

### 2.2. ❌ Xóa Tài Khoản (Delete Account)

**Trạng thái:** Chỉ có script cleanup, chưa có API và UI

**Đã có:**
- ✅ Script cleanup: `backend/src/scripts/cleanup_real_users_data.js`
- ✅ Logic xóa swipes, matches, messages, chatrooms

**Thiếu:**
- ❌ API endpoint: `DELETE /api/users/account`
- ❌ Controller method
- ❌ Service method
- ❌ Route trong `user.routes.js`
- ❌ UI trong Settings screen
- ❌ Confirmation dialog với password verification
- ❌ Soft delete vs hard delete option
- ❌ GDPR compliance (data export trước khi xóa)
- ❌ Email notification
- ❌ Grace period (30 days để recover)

**Code hiện tại:**
```javascript
// backend/src/scripts/cleanup_real_users_data.js
// Chỉ là script, không phải API endpoint
await Swipe.deleteMany({...});
await Match.deleteMany({...});
await Message.deleteMany({...});
await ChatRoom.deleteMany({...});
```

**Cần implement:**

**Backend:**
```javascript
// backend/src/routes/user.routes.js
router.delete('/account',
  [
    body('password').notEmpty().withMessage('Password is required for account deletion'),
    body('confirm').equals('DELETE').withMessage('Must type DELETE to confirm')
  ],
  validate,
  userController.deleteAccount.bind(userController)
);

// backend/src/controllers/user.controller.js
async deleteAccount(req, res, next) {
  try {
    const { password } = req.body;
    const userId = req.userId;
    
    // Verify password
    const user = await User.findById(userId).select('+password');
    const isValid = await user.comparePassword(password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }
    
    // Option 1: Soft delete (recommended)
    await User.findByIdAndUpdate(userId, {
      deletedAt: new Date(),
      isActive: false,
      email: `deleted_${userId}@deleted.com`,
      phone: null
    });
    
    // Option 2: Hard delete (delete all related data)
    // await cleanupUserData(userId);
    
    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    next(error);
  }
}
```

**Frontend:**
- Settings screen cần thêm "Delete Account" option (màu đỏ, warning)
- Confirmation dialog với:
  - Password input
  - Warning message
  - Checkbox "I understand this action cannot be undone"
  - Type "DELETE" to confirm

**Ước tính thời gian:** 6-8 giờ

---

### 2.3. 🟡 Tạm Khóa Tài Khoản (Deactivate Account)

**Trạng thái:** Chưa có

**Thiếu:**
- ❌ API endpoint: `PUT /api/users/deactivate`
- ❌ `isDeactivated` field trong User model
- ❌ `deactivatedAt` timestamp
- ❌ Logic để hide deactivated users từ discovery
- ❌ UI trong Settings
- ❌ Reactivation endpoint

**Cần implement:**
- Thêm fields vào User schema
- API để deactivate/reactivate
- Update discovery query để exclude deactivated users
- UI trong Settings

**Ước tính thời gian:** 4-6 giờ

---

## 3. SECURITY FEATURES

### 3.1. ❌ Reset Password / Forgot Password

**Trạng thái:** Hoàn toàn chưa có

**Thiếu:**
- ❌ API endpoint: `POST /api/auth/forgot-password`
- ❌ API endpoint: `POST /api/auth/reset-password`
- ❌ Email service integration
- ❌ Password reset token generation
- ❌ Token expiry mechanism
- ❌ UI screens (ForgotPasswordScreen, ResetPasswordScreen)
- ❌ Email template

**Cần implement:**

**Backend:**
```javascript
// backend/src/routes/auth.routes.js
router.post('/forgot-password',
  [body('email').isEmail()],
  validate,
  authController.forgotPassword.bind(authController)
);

router.post('/reset-password',
  [
    body('token').notEmpty(),
    body('password').isLength({ min: 8 })
  ],
  validate,
  authController.resetPassword.bind(authController)
);

// backend/src/models/User.js - Thêm fields
passwordResetToken: String,
passwordResetExpires: Date
```

**Frontend:**
- ForgotPasswordScreen với email input
- ResetPasswordScreen với token và new password
- Link trong LoginScreen

**Ước tính thời gian:** 8-10 giờ

---

### 3.2. 🟡 Two-Factor Authentication (2FA)

**Trạng thái:** Đã được đề cập trong báo cáo bảo mật nhưng chưa implement

**Thiếu:**
- ❌ 2FA setup endpoint
- ❌ 2FA verification trong login
- ❌ QR code generation
- ❌ Backup codes
- ❌ TOTP library integration (speakeasy)
- ❌ UI screens

**Ước tính thời gian:** 12-16 giờ

---

## 4. CHAT & MESSAGING FEATURES

### 4.1. ❌ Chat Media Upload

**Trạng thái:** Có constants nhưng chưa có implementation

**Đã có:**
- ✅ Constants: `MESSAGE_TYPES.GIF`, `MESSAGE_TYPES.STICKER` (`backend/src/utils/constants.js:21-22`)
- ✅ Image upload endpoint: `POST /api/upload/image`
- ✅ Message model có thể support `type` và `mediaUrl`

**Thiếu:**
- ❌ API endpoint: `POST /api/upload/chat-media`
- ❌ Route trong `upload.routes.js`
- ❌ Controller method
- ❌ Validation cho media types (image, GIF, video)
- ❌ Thumbnail generation
- ❌ Media compression
- ❌ UI trong ChatScreen (camera, gallery picker)
- ❌ Media preview trước khi gửi
- ❌ Media tab trong chat
- ❌ Media message bubbles

**Code hiện tại:**
```javascript
// backend/src/utils/constants.js
MESSAGE_TYPES: {
  TEXT: 'text',
  IMAGE: 'image',
  GIF: 'gif',
  STICKER: 'sticker'
}
```

**Cần implement:**

**Backend:**
```javascript
// backend/src/routes/upload.routes.js
router.post('/chat-media', 
  upload.single('media'),
  uploadController.uploadChatMedia.bind(uploadController)
);

// backend/src/controllers/upload.controller.js
async uploadChatMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }
    
    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(req.file.mimetype)) {
      return res.status(400).json({ error: 'Invalid file type' });
    }
    
    // Upload to Firebase Storage
    const url = await uploadToFirebase(req.file, 'chat-media');
    
    // Generate thumbnail if needed
    // const thumbnailUrl = await generateThumbnail(req.file);
    
    res.json({
      success: true,
      data: {
        url,
        type: req.file.mimetype.startsWith('image/') ? 'image' : 'gif',
        // thumbnailUrl
      }
    });
  } catch (error) {
    next(error);
  }
}
```

**Frontend:**
- Thêm media picker button trong ChatScreen
- Image picker integration
- Media preview dialog
- Media message bubble component
- Media tab trong chat

**Ước tính thời gian:** 12-16 giờ

---

### 4.2. ❌ GIF Picker Integration

**Trạng thái:** Chưa có

**Thiếu:**
- ❌ API endpoint: `GET /api/chat/gifs?query=...`
- ❌ Giphy/Tenor API integration
- ❌ GIF search functionality
- ❌ GIF picker UI component
- ❌ Trending GIFs
- ❌ GIF categories

**Cần implement:**
- Backend proxy endpoint để call Giphy/Tenor API
- Frontend GIF picker widget
- Search và trending GIFs

**Ước tính thời gian:** 8-10 giờ

---

### 4.3. ❌ Sticker Support

**Trạng thái:** Chưa có

**Thiếu:**
- ❌ Sticker pack management
- ❌ Sticker upload endpoint
- ❌ Sticker picker UI
- ❌ Default sticker packs

**Ước tính thời gian:** 10-12 giờ

---

## 5. NOTIFICATION FEATURES

### 5.1. 🟡 FCM Token Registration

**Trạng thái:** Có service nhưng chưa gửi token lên backend

**Đã có:**
- ✅ `NotificationService.initialize()` (`frontend/lib/core/services/notification_service.dart`)
- ✅ FCM token retrieval
- ✅ Permission request
- ✅ Device token model (`backend/src/models/DeviceToken.js`)
- ✅ API endpoint: `POST /api/devices/token`

**Thiếu:**
- ❌ Gửi token lên backend sau khi lấy được
- ❌ Token refresh khi token thay đổi
- ❌ Token cleanup khi logout

**Code hiện tại:**
```dart
// frontend/lib/core/services/notification_service.dart:33
// TODO: Send token to backend
final token = await _messaging.getToken();
print('FCM Token: $token');
```

**Cần implement:**

**Frontend:**
```dart
// frontend/lib/core/services/notification_service.dart
static Future<void> initialize() async {
  // ... existing code ...
  
  // Get FCM token
  final token = await _messaging.getToken();
  print('FCM Token: $token');
  
  // Send token to backend
  if (token != null) {
    await _registerToken(token);
  }
  
  // Listen for token refresh
  _messaging.onTokenRefresh.listen((newToken) {
    _registerToken(newToken);
  });
}

static Future<void> _registerToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    
    if (authToken == null) return;
    
    await ApiService().post('/devices/token', data: {
      'token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios'
    });
  } catch (e) {
    print('Error registering FCM token: $e');
  }
}
```

**Backend:** Đã có endpoint, chỉ cần frontend gọi

**Ước tính thời gian:** 2-3 giờ

---

### 5.2. 🟡 Rich Notifications

**Trạng thái:** Có basic notifications, thiếu rich content

**Đã có:**
- ✅ Basic notification với title và body
- ✅ Notification data payload

**Thiếu:**
- ❌ Image preview trong notification
- ❌ Action buttons (Reply, Mark as read)
- ❌ Custom notification sound
- ❌ Notification grouping
- ❌ Deep linking từ notification

**Ước tính thời gian:** 6-8 giờ

---

## 6. SETTINGS & PRIVACY FEATURES

### 6.1. ❌ Block User

**Trạng thái:** Hoàn toàn chưa có

**Thiếu:**
- ❌ Block model hoặc field trong User model
- ❌ API endpoint: `POST /api/users/block`
- ❌ API endpoint: `POST /api/users/unblock`
- ❌ API endpoint: `GET /api/users/blocked`
- ❌ Logic để hide blocked users từ discovery
- ❌ Logic để prevent messages từ blocked users
- ❌ UI trong profile screen hoặc chat screen

**Cần implement:**

**Backend:**
```javascript
// backend/src/models/User.js - Thêm field
blockedUsers: [{
  type: mongoose.Schema.Types.ObjectId,
  ref: 'User',
  index: true
}]

// backend/src/routes/user.routes.js
router.post('/block/:userId', userController.blockUser.bind(userController));
router.post('/unblock/:userId', userController.unblockUser.bind(userController));
router.get('/blocked', userController.getBlockedUsers.bind(userController));
```

**Frontend:**
- Block button trong profile detail modal
- Blocked users list trong Settings
- Unblock functionality

**Ước tính thời gian:** 8-10 giờ

---

### 6.2. ❌ Privacy Settings

**Trạng thái:** Chưa có

**Thiếu:**
- ❌ Privacy settings model hoặc fields
- ❌ API endpoint: `GET /api/users/privacy`
- ❌ API endpoint: `PUT /api/users/privacy`
- ❌ Settings như:
  - Show age
  - Show distance
  - Show last active
  - Who can see my profile
  - Read receipts
- ❌ UI trong Settings screen

**Cần implement:**
- Privacy settings schema
- API endpoints
- UI với toggles và options

**Ước tính thời gian:** 6-8 giờ

---

### 6.3. ❌ Account Settings

**Trạng thái:** Chưa có trong Settings screen

**Thiếu:**
- ❌ Change password option (đã nêu ở trên)
- ❌ Delete account option (đã nêu ở trên)
- ❌ Email settings (notifications preferences)
- ❌ Connected accounts (social media links)

**Ước tính thời gian:** 4-6 giờ (không tính change password và delete account)

---

### 6.4. 🟡 Help & Support

**Trạng thái:** Có UI nhưng links là placeholder

**Đã có:**
- ✅ Settings screen có FAQ, Contact Support, Report Bug options

**Thiếu:**
- ❌ Actual FAQ content
- ❌ Support ticket system
- ❌ Bug report form
- ❌ In-app help center

**Code hiện tại:**
```dart
// frontend/lib/presentation/screens/settings/settings_screen.dart:191-201
ListTile(
  title: Text(l10n.settings_faq),
  onTap: () => _openUrl('https://example.com/faq'), // Placeholder
),
```

**Ước tính thời gian:** 8-10 giờ

---

## 7. ADMIN & MODERATION FEATURES

### 7.1. 🟡 Report Review System

**Trạng thái:** Có report model nhưng thiếu admin endpoints

**Đã có:**
- ✅ Report model (`backend/src/models/Report.js`)
- ✅ Report creation endpoint: `POST /api/reports`
- ✅ Report status tracking

**Thiếu:**
- ❌ Admin endpoints để review reports
- ❌ Admin dashboard
- ❌ Auto-moderation rules
- ❌ Ban user functionality
- ❌ Report analytics

**Cần implement:**
- Admin authentication/authorization
- Admin routes và controllers
- Admin dashboard UI
- Report review workflow

**Ước tính thời gian:** 16-20 giờ

---

### 7.2. 🟡 Admin Dashboard

**Trạng thái:** Chưa có

**Thiếu:**
- ❌ Admin authentication
- ❌ Admin routes
- ❌ Dashboard UI
- ❌ User management
- ❌ Content moderation
- ❌ Analytics và statistics

**Ước tính thời gian:** 20-30 giờ

---

## 8. KHUYẾN NGHỊ HOÀN THIỆN

### 8.1. 🔴 Ưu Tiên Cao (1-2 tuần)

#### Phase 1: Critical Account Features
1. **Đổi mật khẩu** (4-6 giờ)
   - Backend API
   - Frontend UI
   - Validation và error handling

2. **Xóa tài khoản** (6-8 giờ)
   - Backend API với password verification
   - Frontend UI với confirmation
   - GDPR compliance (data export)

3. **FCM Token Registration** (2-3 giờ)
   - Hoàn thiện notification service
   - Token refresh handling
   - Token cleanup on logout

**Tổng:** 12-17 giờ

---

### 8.2. 🟡 Ưu Tiên Trung Bình (2-3 tuần)

#### Phase 2: Important Features
1. **Chat Media Upload** (12-16 giờ)
   - Backend endpoint
   - Frontend UI
   - Media preview và compression

2. **Block User** (8-10 giờ)
   - Backend API
   - Frontend UI
   - Discovery và chat filtering

3. **Privacy Settings** (6-8 giờ)
   - Settings model
   - API endpoints
   - UI implementation

4. **Reset Password** (8-10 giờ)
   - Email service integration
   - Token generation
   - UI screens

**Tổng:** 34-44 giờ

---

### 8.3. 🟢 Ưu Tiên Thấp (1-2 tháng)

#### Phase 3: Nice to Have
1. **GIF Picker** (8-10 giờ)
2. **Sticker Support** (10-12 giờ)
3. **Rich Notifications** (6-8 giờ)
4. **2FA** (12-16 giờ)
5. **Admin Dashboard** (20-30 giờ)
6. **Help & Support System** (8-10 giờ)

**Tổng:** 64-86 giờ

---

### 8.4. Checklist Hoàn Thiện

#### Đổi Mật Khẩu
- [ ] Backend route
- [ ] Controller method
- [ ] Service method
- [ ] Password validation (strength)
- [ ] Frontend UI
- [ ] Error handling
- [ ] Email notification

#### Xóa Tài Khoản
- [ ] Backend route
- [ ] Password verification
- [ ] Data cleanup logic
- [ ] Soft delete option
- [ ] Frontend UI
- [ ] Confirmation dialog
- [ ] GDPR data export
- [ ] Email notification

#### FCM Token Registration
- [ ] Send token to backend
- [ ] Token refresh handling
- [ ] Token cleanup on logout
- [ ] Error handling

#### Chat Media
- [ ] Backend upload endpoint
- [ ] File validation
- [ ] Thumbnail generation
- [ ] Frontend picker
- [ ] Media preview
- [ ] Media bubbles
- [ ] Media tab

#### Block User
- [ ] User model field
- [ ] Block/unblock endpoints
- [ ] Discovery filtering
- [ ] Chat filtering
- [ ] Frontend UI

---

## 9. KẾT LUẬN

### 9.1. Tổng Kết

**Features Chưa Hoàn Thiện:** 16 features

**Phân Bổ:**
- 🔴 Critical: 3 features (12-17 giờ)
- 🟡 Important: 7 features (34-44 giờ)
- 🟢 Nice to Have: 6 features (64-86 giờ)

**Tổng Thời Gian Ước Tính:** 110-147 giờ (~3-4 tuần full-time)

### 9.2. Khuyến Nghị

**Ngay Lập Tức:**
1. Hoàn thiện đổi mật khẩu
2. Hoàn thiện xóa tài khoản
3. Fix FCM token registration

**Trong 2 Tuần:**
1. Chat media upload
2. Block user
3. Privacy settings

**Trong 1 Tháng:**
1. Reset password
2. GIF picker
3. Rich notifications

### 9.3. Impact Assessment

**High Impact Features:**
- ✅ Đổi mật khẩu - **Critical** cho user security
- ✅ Xóa tài khoản - **Critical** cho GDPR compliance
- ✅ Block user - **Important** cho user safety
- ✅ Chat media - **Important** cho user experience

**Medium Impact Features:**
- Privacy settings
- FCM token registration
- Reset password

**Low Impact Features:**
- GIF picker
- Sticker support
- Admin dashboard (chỉ cần nếu có admin team)

---

**Báo cáo được tạo bởi:** Feature Analysis Tool  
**Phiên bản:** 1.0  
**Ngày:** 02/12/2025

---

© 2025 Matcha Dating App. All rights reserved.

