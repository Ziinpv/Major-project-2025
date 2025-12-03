# Backend Architecture & API Integration
## Matcha - Ứng dụng Hẹn hò & Chat

---

## 📋 Tổng quan

Tài liệu này mô tả chi tiết về **kiến trúc Backend** và **quy chuẩn tích hợp API** của hệ thống Matcha, bao gồm:

- **Mô hình kiến trúc**: Clean Architecture với Layered Architecture pattern
- **API Specification**: RESTful API conventions và response format
- **Third-party Services**: Các dịch vụ bên thứ 3 và cách tích hợp

---

## 1. 🏗️ Mô hình Kiến trúc

### 1.1. Kiến trúc Tổng quan

Hệ thống Backend được xây dựng theo mô hình **Layered Architecture** (Clean Architecture), chia thành các tầng rõ ràng với trách nhiệm riêng biệt:

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│  Routes (HTTP Endpoints) + WebSocket Handlers           │
│  - Định nghĩa API endpoints                             │
│  - Xử lý HTTP requests/responses                        │
│  - Authentication middleware                            │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  APPLICATION LAYER                       │
│  Controllers                                            │
│  - Nhận requests từ routes                              │
│  - Validate input data                                  │
│  - Gọi services và format responses                     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  BUSINESS LOGIC LAYER                    │
│  Services                                               │
│  - Chứa business logic                                  │
│  - Orchestrate giữa các repositories                    │
│  - Xử lý business rules                                 │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  DATA ACCESS LAYER                       │
│  Repositories                                           │
│  - Abstract database operations                         │
│  - Query building và data transformation                │
│  - Database-agnostic interface                          │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  DOMAIN LAYER                            │
│  Models (Mongoose Schemas)                              │
│  - Định nghĩa data structures                           │
│  - Validation rules                                     │
│  - Business entities                                    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                    │
│  MongoDB, Firebase, Socket.IO                           │
│  - External services                                    │
│  - Database connections                                 │
└─────────────────────────────────────────────────────────┘
```

---

### 1.2. Cấu trúc Folder/Module

Cấu trúc thư mục backend được tổ chức theo từng layer:

```
backend/
├── src/
│   ├── config/              # Configuration Layer
│   │   ├── database.js      # MongoDB connection config
│   │   └── firebase.js      # Firebase Admin SDK config
│   │
│   ├── routes/              # Presentation Layer - HTTP Routes
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   ├── discover.routes.js
│   │   ├── swipe.routes.js
│   │   ├── match.routes.js
│   │   ├── chat.routes.js
│   │   ├── preference.routes.js
│   │   ├── device.routes.js
│   │   ├── upload.routes.js
│   │   └── report.routes.js
│   │
│   ├── websocket/           # Presentation Layer - WebSocket
│   │   ├── socket.js        # Socket.IO setup & logging
│   │   └── socketHandler.js # WebSocket event handlers
│   │
│   ├── controllers/         # Application Layer
│   │   ├── auth.controller.js
│   │   ├── user.controller.js
│   │   ├── chat.controller.js
│   │   ├── match.controller.js
│   │   ├── swipe.controller.js
│   │   ├── preference.controller.js
│   │   ├── report.controller.js
│   │   └── upload.controller.js
│   │
│   ├── services/            # Business Logic Layer
│   │   ├── auth.service.js
│   │   ├── user.service.js
│   │   ├── chat.service.js
│   │   ├── swipe.service.js
│   │   └── recommendation.service.js
│   │
│   ├── repositories/        # Data Access Layer
│   │   ├── user.repository.js
│   │   ├── chat.repository.js
│   │   ├── match.repository.js
│   │   ├── swipe.repository.js
│   │   └── recommendation.repository.js
│   │
│   ├── models/              # Domain Layer
│   │   ├── User.js
│   │   ├── Swipe.js
│   │   ├── Match.js
│   │   ├── ChatRoom.js
│   │   ├── Message.js
│   │   ├── DiscoveryLog.js
│   │   ├── DeviceToken.js
│   │   ├── Preference.js
│   │   └── Report.js
│   │
│   ├── middleware/          # Cross-cutting Concerns
│   │   ├── auth.js          # Authentication middleware
│   │   ├── errorHandler.js  # Global error handler
│   │   ├── requestLogger.js # Request logging
│   │   ├── validation.js    # Input validation
│   │   └── upload.js        # File upload handling
│   │
│   ├── utils/               # Utility Functions
│   │   ├── constants.js     # Application constants
│   │   ├── logger.js        # Winston logger config
│   │   ├── validation.js    # Validation helpers
│   │   └── vietnam_coordinates.js  # Location lookup
│   │
│   ├── scripts/             # Utility Scripts
│   │   ├── seed.js          # Database seeding
│   │   └── ...
│   │
│   └── server.js            # Application Entry Point
│
├── package.json
├── .env                     # Environment variables
└── Dockerfile
```

---

### 1.3. Chi tiết từng Layer

#### **1.3.1. Presentation Layer (Routes + WebSocket)**

**Trách nhiệm:**
- Định nghĩa API endpoints (HTTP routes)
- Xử lý WebSocket connections và events
- Authentication middleware
- Request/Response formatting

**Ví dụ Routes:**

```javascript
// routes/user.routes.js
const express = require('express');
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Tất cả routes trong module này đều yêu cầu authentication
router.use(authenticate);

// Route definitions
router.get('/profile', userController.getProfile.bind(userController));
router.patch('/profile', userController.updateProfile.bind(userController));
router.patch('/profile/photos', userController.updateProfilePhotos.bind(userController));
router.put('/location', userController.updateLocation.bind(userController));

module.exports = router;
```

**Đặc điểm:**
- Routes được nhóm theo domain (user, chat, match, etc.)
- Middleware authentication được apply ở route level
- Controllers được bind để giữ context `this`

---

#### **1.3.2. Application Layer (Controllers)**

**Trách nhiệm:**
- Nhận requests từ routes
- Validate input data (hoặc delegate cho middleware)
- Gọi services để xử lý business logic
- Format responses theo chuẩn API

**Ví dụ Controller:**

```javascript
// controllers/user.controller.js
const userService = require('../services/user.service');

class UserController {
  async getProfile(req, res, next) {
    try {
      const user = await userService.getProfile(req.userId);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error); // Pass to error handler middleware
    }
  }

  async updateProfile(req, res, next) {
    try {
      const user = await userService.updateProfile(req.userId, req.body);
      res.json({
        success: true,
        data: { user: user.toPublicJSON() }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new UserController();
```

**Đặc điểm:**
- Controllers chỉ làm thin layer, không chứa business logic
- Sử dụng `next(error)` để pass errors đến error handler
- Response format chuẩn: `{ success: true, data: {...} }`

---

#### **1.3.3. Business Logic Layer (Services)**

**Trách nhiệm:**
- Chứa business logic và business rules
- Orchestrate giữa các repositories
- Validate business constraints
- Xử lý complex workflows

**Ví dụ Service:**

```javascript
// services/user.service.js
const userRepository = require('../repositories/user.repository');
const recommendationService = require('./recommendation.service');

class UserService {
  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }

  async updateProfile(userId, payload) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Business validation
    if (payload.bio && payload.bio.length > 300) {
      const error = new Error('Bio must be up to 300 characters');
      error.statusCode = 400;
      throw error;
    }

    // Update logic
    Object.assign(user, payload);
    await user.save();
    return user;
  }

  async getDiscovery(userId, filters = {}) {
    // Business logic: Find candidates and calculate scores
    const user = await userRepository.findById(userId);
    const swipedIds = await swipeRepository.getSwipedUserIds(userId);
    
    const candidates = await userRepository.findCandidatesForDiscovery(
      user, 
      swipedIds, 
      filters
    );

    // Calculate matching scores
    const enriched = candidates.map(candidate => {
      const { score, breakdown } = recommendationService.computeScore(user, candidate);
      return { user: candidate, score, breakdown };
    });

    return enriched;
  }
}

module.exports = new UserService();
```

**Đặc điểm:**
- Services orchestrate giữa nhiều repositories
- Business validation được thực hiện ở layer này
- Throws errors với `statusCode` để error handler xử lý

---

#### **1.3.4. Data Access Layer (Repositories)**

**Trách nhiệm:**
- Abstract database operations
- Query building và data transformation
- Database-agnostic interface (có thể thay MongoDB bằng DB khác)

**Ví dụ Repository:**

```javascript
// repositories/user.repository.js
const User = require('../models/User');

class UserRepository {
  async findById(userId) {
    return await User.findById(userId);
  }

  async findByEmail(email) {
    return await User.findOne({ email: email.toLowerCase() });
  }

  async update(userId, updateData) {
    return await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );
  }

  async findCandidatesForDiscovery(currentUser, excludeIds = [], filters = {}) {
    const query = {
      _id: { $ne: currentUser._id, $nin: excludeIds },
      isActive: true,
      isProfileComplete: true
    };

    // Apply filters
    if (filters.gender) {
      query.gender = { $in: filters.gender };
    }

    // Geospatial query với 2dsphere index
    if (filters.maxDistance && currentUser.location?.coordinates) {
      query['location.coordinates'] = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: currentUser.location.coordinates
          },
          $maxDistance: filters.maxDistance * 1000
        }
      };
    }

    return await User.find(query).limit(50);
  }
}

module.exports = new UserRepository();
```

**Đặc điểm:**
- Repositories chỉ làm database operations, không có business logic
- Có thể dễ dàng mock trong tests
- Database-specific queries (MongoDB) được encapsulated ở đây

---

#### **1.3.5. Domain Layer (Models)**

**Trách nhiệm:**
- Định nghĩa data structures (Mongoose schemas)
- Validation rules
- Business entities với methods

**Ví dụ Model:**

```javascript
// models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: { type: String, sparse: true, unique: true },
  email: { type: String, sparse: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  gender: {
    type: String,
    enum: ['male', 'female', 'non-binary', 'other'],
    required: true
  },
  interests: [{ type: String }],
  lifestyle: [{ type: String }],
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: [Number], // [longitude, latitude]
    province: String,
    city: String,
    // ...
  },
  // ...
}, { timestamps: true });

// 2dsphere index cho geospatial queries
userSchema.index({ 'location.coordinates': '2dsphere' });

// Instance method
userSchema.methods.toPublicJSON = function() {
  const obj = this.toObject();
  delete obj.email;
  delete obj.phone;
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
```

**Đặc điểm:**
- Models định nghĩa structure và validation
- Indexes được define trong schema
- Instance methods cho business operations

---

### 1.4. Dependency Flow

**Luồng phụ thuộc (Dependency Flow):**

```
Routes → Controllers → Services → Repositories → Models → Database
   │         │           │            │           │
   │         │           │            │           └── MongoDB
   │         │           │            │
   │         │           │            └── (Can be swapped)
   │         │           │
   │         │           └── (Business Logic)
   │         │
   │         └── (Thin layer, no business logic)
   │
   └── (HTTP/WebSocket endpoints)
```

**Quy tắc:**
- ✅ Outer layers có thể import inner layers
- ❌ Inner layers KHÔNG được import outer layers
- ✅ Services có thể gọi nhiều repositories
- ✅ Controllers có thể gọi nhiều services

---

### 1.5. Benefits của Kiến trúc này

1. **Separation of Concerns**: Mỗi layer có trách nhiệm rõ ràng
2. **Testability**: Dễ dàng mock và test từng layer
3. **Maintainability**: Dễ maintain và refactor
4. **Scalability**: Có thể scale từng layer độc lập
5. **Flexibility**: Dễ dàng thay đổi database hoặc framework

---

## 2. 📡 API Specification

### 2.1. RESTful API Conventions

Hệ thống tuân thủ **RESTful API conventions** với các quy tắc sau:

#### **2.1.1. HTTP Methods**

| Method | Usage | Example |
|--------|-------|---------|
| **GET** | Lấy dữ liệu (read-only) | `GET /api/users/profile` |
| **POST** | Tạo mới resource | `POST /api/swipes` |
| **PUT** | Thay thế toàn bộ resource | `PUT /api/users/location` |
| **PATCH** | Cập nhật một phần resource | `PATCH /api/users/profile` |
| **DELETE** | Xóa resource | `DELETE /api/matches/:id` (future) |

#### **2.1.2. URL Naming Convention**

- **Plural nouns**: `/api/users`, `/api/matches`, `/api/messages`
- **Nested resources**: `/api/chat/rooms/:roomId/messages`
- **Query parameters**: `/api/discover?ageMin=25&maxDistance=50`
- **URL params**: `/api/users/:userId`, `/api/chat/rooms/:chatRoomId`

**Ví dụ:**

```
✅ Correct:
GET    /api/users/profile
PATCH  /api/users/profile
GET    /api/discover?ageMin=25&maxDistance=50
GET    /api/chat/rooms/:chatRoomId/messages

❌ Incorrect:
GET    /api/user/profile          (singular)
GET    /api/getUserProfile        (verb in URL)
GET    /api/discover?age_min=25   (snake_case)
```

#### **2.1.3. HTTP Status Codes**

| Status Code | Meaning | Usage |
|-------------|---------|-------|
| **200 OK** | Success | GET, PUT, PATCH thành công |
| **201 Created** | Resource created | POST tạo resource mới |
| **400 Bad Request** | Invalid input | Validation errors |
| **401 Unauthorized** | Not authenticated | Missing/invalid token |
| **403 Forbidden** | Not authorized | Không có quyền |
| **404 Not Found** | Resource not found | ID không tồn tại |
| **500 Internal Server Error** | Server error | Unexpected errors |

---

### 2.2. Response Format

Tất cả API responses tuân theo format chuẩn:

#### **2.2.1. Success Response**

```json
{
  "success": true,
  "data": {
    // Response data here
  }
}
```

**Ví dụ:**

```json
// GET /api/users/profile
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "firstName": "Nguyễn",
      "lastName": "Văn A",
      "age": 28,
      "gender": "male",
      "photos": [...],
      "interests": ["travel", "music"],
      "location": {
        "province": "TP. Hồ Chí Minh",
        "city": "Quận 1"
      }
    }
  }
}
```

```json
// GET /api/discover
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "...",
        "firstName": "Lan",
        "age": 27,
        "score": 86,
        "scoreBreakdown": {
          "interests": 30,
          "lifestyle": 20,
          "distance": 20,
          "activity": 10,
          "age": 10
        },
        "distanceKm": 5.2
      }
    ]
  }
}
```

#### **2.2.2. Error Response**

```json
{
  "success": false,
  "error": "Error message here"
}
```

**Ví dụ:**

```json
// 400 Bad Request
{
  "success": false,
  "error": "Bio must be up to 300 characters"
}

// 401 Unauthorized
{
  "success": false,
  "error": "No token provided"
}

// 404 Not Found
{
  "success": false,
  "error": "User not found"
}

// 500 Internal Server Error (development only)
{
  "success": false,
  "error": "Internal Server Error",
  "stack": "Error stack trace...",
  "details": "Error details..."
}
```

#### **2.2.3. Pagination Response (Future)**

```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

---

### 2.3. Authentication & Authorization

#### **2.3.1. Authentication Header**

Tất cả protected endpoints yêu cầu JWT token trong header:

```http
Authorization: Bearer <jwt-token>
```

**Example:**

```bash
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### **2.3.2. Token Generation**

- **Firebase Auth**: Client đăng nhập với Firebase, nhận Firebase ID token
- **Backend JWT**: Backend verify Firebase token, tạo JWT token
- **Token Expiry**: JWT token có thời hạn 7 ngày (configurable)

---

### 2.4. Request/Response Examples

#### **2.4.1. User Profile APIs**

```http
# Get Profile
GET /api/users/profile
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "user": { /* user object */ }
  }
}
```

```http
# Update Profile
PATCH /api/users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "bio": "Love traveling and coffee ☕",
  "interests": ["travel", "music", "coffee"],
  "job": "Software Engineer",
  "school": "University of Technology",
  "lifestyle": ["fitness", "early-bird"]
}

Response:
{
  "success": true,
  "data": {
    "user": { /* updated user object */ }
  }
}
```

#### **2.4.2. Discovery API**

```http
# Get Discovery Results
GET /api/discover?ageMin=25&ageMax=35&maxDistance=50&showMe=female&sort=best
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "507f1f77bcf86cd799439011",
        "firstName": "Lan",
        "lastName": "Nguyễn",
        "age": 27,
        "photos": [...],
        "interests": ["travel", "music"],
        "location": {
          "province": "TP. Hồ Chí Minh",
          "city": "Quận 1",
          "coordinates": [106.6297, 10.8231]
        },
        "score": 86,
        "scoreBreakdown": {
          "interests": 30,
          "lifestyle": 20,
          "distance": 20,
          "activity": 10,
          "age": 10
        },
        "distanceKm": 5.2
      }
    ]
  }
}
```

#### **2.4.3. Swipe API**

```http
# Create Swipe
POST /api/swipes
Authorization: Bearer <token>
Content-Type: application/json

{
  "swipedUserId": "507f1f77bcf86cd799439012",
  "action": "like"  // "like" | "pass" | "superlike"
}

Response (if match):
{
  "success": true,
  "data": {
    "swipe": { /* swipe object */ },
    "match": { /* match object */ },
    "chatRoom": { /* chatroom object */ },
    "isMatch": true
  }
}

Response (if no match):
{
  "success": true,
  "data": {
    "swipe": { /* swipe object */ },
    "isMatch": false
  }
}
```

#### **2.4.4. Chat APIs**

```http
# Get Chat Rooms
GET /api/chat/rooms
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "rooms": [
      {
        "id": "507f1f77bcf86cd799439013",
        "match": { /* match object */ },
        "participants": [...],
        "lastMessage": {
          "content": "Hey! How are you?",
          "createdAt": "2025-01-20T15:00:00Z"
        },
        "lastMessageAt": "2025-01-20T15:00:00Z",
        "unreadCount": 3
      }
    ]
  }
}
```

```http
# Get Messages
GET /api/chat/rooms/:chatRoomId/messages?page=1&limit=20
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "507f1f77bcf86cd799439014",
        "sender": { /* user object */ },
        "content": "Hey! How are you?",
        "type": "text",
        "createdAt": "2025-01-20T15:00:00Z",
        "readAt": "2025-01-20T15:05:00Z"
      }
    ]
  }
}
```

---

## 3. 🔌 Third-party Services

### 3.1. Firebase Services

#### **3.1.1. Firebase Authentication**

**Mục đích**: Xác thực người dùng với Email/Password và Google Sign-In

**Tích hợp:**

```javascript
// config/firebase.js
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET
});

// Verify Firebase token
const verifyFirebaseToken = async (idToken) => {
  const decodedToken = await admin.auth().verifyIdToken(idToken);
  return decodedToken;
};
```

**Vai trò trong hệ thống:**
- ✅ Client-side authentication (Flutter app)
- ✅ Server-side token verification
- ✅ User identity management
- ✅ Google Sign-In integration

**Environment Variables:**
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
```

---

#### **3.1.2. Firebase Storage**

**Mục đích**: Lưu trữ ảnh profile của users

**Tích hợp:**

```javascript
// config/firebase.js
const getStorage = () => {
  return admin.storage();
};

// Upload image
const bucket = getStorage().bucket();
const file = bucket.file(`users/${userId}/${filename}`);
await file.save(buffer, { contentType: 'image/jpeg' });
const url = await file.getSignedUrl({ action: 'read', expires: '03-09-2491' });
```

**Vai trò trong hệ thống:**
- ✅ Store user profile photos (up to 6 photos per user)
- ✅ CDN distribution for fast image loading
- ✅ Automatic image optimization
- ✅ Secure access với signed URLs

**Upload Flow:**
1. Client uploads image to backend endpoint
2. Backend validates image (size, type)
3. Backend uploads to Firebase Storage
4. Backend returns Firebase Storage URL
5. Frontend displays image from Firebase Storage

---

#### **3.1.3. Firebase Cloud Messaging (FCM)**

**Mục đích**: Gửi push notifications cho match và messages

**Tích hợp:**

```javascript
// services/swipe.service.js
const { getMessaging } = require('../config/firebase');
const DeviceToken = require('../models/DeviceToken');

async notifyMatch(user1Id, user2Id) {
  const messaging = getMessaging();
  
  // Get device tokens for both users
  const tokens1 = await DeviceToken.find({ user: user1Id, isActive: true });
  const tokens2 = await DeviceToken.find({ user: user2Id, isActive: true });
  
  // Send notifications
  await messaging.sendToDevice(
    tokens2.map(t => t.token),
    {
      notification: {
        title: 'New Match! 🎉',
        body: 'You have a new match!'
      },
      data: {
        type: 'match',
        matchId: match._id.toString()
      }
    }
  );
}
```

**Vai trò trong hệ thống:**
- ✅ Push notifications khi có match mới
- ✅ Push notifications khi có message mới
- ✅ Cross-platform support (Android, iOS, Web)
- ✅ Delivery tracking

**Notification Types:**
- `match`: New match created
- `message`: New message received
- `superlike`: Received super like

---

### 3.2. MongoDB Atlas

**Mục đích**: Database chính cho toàn bộ hệ thống

**Tích hợp:**

```javascript
// config/database.js
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Connection events
mongoose.connection.on('connected', () => {
  console.log('✅ MongoDB connected');
});

mongoose.connection.on('error', (err) => {
  console.error('❌ MongoDB connection error:', err);
});
```

**Vai trò trong hệ thống:**
- ✅ Store user data (profiles, preferences)
- ✅ Store interaction data (swipes, matches)
- ✅ Store chat data (messages, chatrooms)
- ✅ Geospatial queries với 2dsphere index
- ✅ Horizontal scaling với sharding

**Collections:**
- `users`: User profiles và preferences
- `swipes`: Swipe history
- `matches`: Match records
- `chatrooms`: Chat rooms
- `messages`: Chat messages
- `discoverylogs`: Discovery analytics
- `devicetokens`: FCM device tokens
- `reports`: User reports

**Environment Variable:**
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/matcha?retryWrites=true&w=majority
```

---

### 3.3. Socket.IO (WebSocket)

**Mục đích**: Real-time bidirectional communication cho chat

**Tích hợp:**

```javascript
// websocket/socketHandler.js
const { Server } = require('socket.io');

const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Authentication middleware
io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  const user = await verifyToken(token);
  socket.userId = user.id;
  next();
});

// Event handlers
io.on('connection', (socket) => {
  socket.on('send-message', async (data) => {
    // Handle message
    io.to(`chat:${data.chatRoomId}`).emit('new-message', message);
  });
});
```

**Vai trò trong hệ thống:**
- ✅ Real-time chat messaging
- ✅ Typing indicators
- ✅ Message delivery status
- ✅ Online/offline status
- ✅ Match notifications

**Events:**
- Client → Server: `send-message`, `typing`, `mark-read`, `join-chat-room`
- Server → Client: `new-message`, `user-typing`, `messages-read`, `match:created`

---

### 3.4. Tổng hợp Third-party Services

| Service | Mục đích | Vai trò | Cost Model |
|---------|----------|---------|------------|
| **Firebase Auth** | Authentication | Xác thực users, Google Sign-In | Free tier: 50k MAU |
| **Firebase Storage** | File Storage | Lưu trữ ảnh profile | Pay per GB stored |
| **Firebase Messaging** | Push Notifications | Match & message notifications | Free tier: Unlimited |
| **MongoDB Atlas** | Database | Primary database | Pay per cluster size |
| **Socket.IO** | Real-time | WebSocket server | Open-source (free) |

---

## 4. 📊 API Endpoints Summary

### 4.1. Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register/firebase` | Đăng ký với Firebase | ❌ |
| POST | `/api/auth/login/firebase` | Đăng nhập với Firebase | ❌ |
| GET | `/api/auth/me` | Lấy thông tin user hiện tại | ✅ |

### 4.2. User Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users/profile` | Lấy profile | ✅ |
| PATCH | `/api/users/profile` | Cập nhật profile | ✅ |
| PATCH | `/api/users/profile/photos` | Cập nhật ảnh | ✅ |
| PUT | `/api/users/location` | Cập nhật vị trí | ✅ |

### 4.3. Discovery Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/discover` | Tìm kiếm users phù hợp | ✅ |

### 4.4. Swipe Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/swipes` | Tạo swipe (like/pass/superlike) | ✅ |

### 4.5. Match Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/matches` | Lấy danh sách matches | ✅ |

### 4.6. Chat Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/chat/rooms` | Lấy danh sách chat rooms | ✅ |
| GET | `/api/chat/rooms/:chatRoomId/messages` | Lấy messages | ✅ |
| PUT | `/api/chat/rooms/:chatRoomId/read` | Đánh dấu đã đọc | ✅ |

### 4.7. Upload Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/upload/image` | Upload ảnh | ✅ |

---

## 5. 🔐 Security Considerations

### 5.1. Authentication Flow

```
1. Client → Firebase Auth → Firebase ID Token
2. Client → Backend API (with Firebase token) → Backend JWT
3. Client stores JWT → Uses for subsequent requests
4. Backend verifies JWT on each request
```

### 5.2. Security Middleware

- **helmet**: HTTP security headers
- **cors**: Cross-origin resource sharing
- **express-rate-limit**: Rate limiting (anti-DDoS)
- **express-validator**: Input validation

---

**Version**: 1.0  
**Last Updated**: January 2025  
**Author**: Matcha Engineering Team  
**Status**: Production Ready ✅

