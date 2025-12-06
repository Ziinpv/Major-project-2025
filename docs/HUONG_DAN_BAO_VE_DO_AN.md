# HƯỚNG DẪN BẢO VỆ ĐỒ ÁN - MATCHA DATING APP
## Tài liệu giải thích chi tiết về cơ chế vận hành hệ thống

**Người hướng dẫn:** Lead Developer  
**Đối tượng:** Sinh viên sắp bảo vệ đồ án  
**Ngày:** 2025

---

## 📋 MỤC LỤC

1. [Luồng Dữ Liệu (Data Flow)](#1-luồng-dữ-liệu-data-flow)
   - [1.1. Discovery (Khám phá)](#11-discovery-khám-phá)
   - [1.2. Swipe & Match (Tương tác)](#12-swipe--match-tương-tác)
   - [1.3. Chat Real-time](#13-chat-real-time)
2. [Logic Matching Score](#2-logic-matching-score)
3. [Mapping Code - Tên File và Hàm](#3-mapping-code---tên-file-và-hàm)
4. [Câu Hỏi Phản Biện](#4-câu-hỏi-phản-biện)

---

## 1. LUỒNG DỮ LIỆU (DATA FLOW)

### 1.1. Discovery (Khám phá)

#### **Sơ đồ luồng dữ liệu:**

```
┌─────────────────┐
│  User mở màn    │
│  Discovery      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  DiscoveryScreen        │
│  - _loadUsers()         │
│  - Gọi API với filters  │
└────────┬────────────────┘
         │
         │ HTTP GET /api/discover
         │ Headers: Authorization: Bearer <JWT>
         │ Query: ?ageMin=25&ageMax=35&maxDistance=50&...
         ▼
┌─────────────────────────┐
│  Backend:                │
│  user.controller.js     │
│  getDiscovery()          │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  user.service.js        │
│  getDiscovery()         │
│  - Lấy user hiện tại    │
│  - Lấy danh sách đã swipe│
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  swipe.repository.js    │
│  getSwipedUserIds()     │
│  Query MongoDB:          │
│  Swipe.find({swiper: userId})│
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  user.repository.js     │
│  findCandidatesForDiscovery()│
│  MongoDB Query:          │
│  - Hard Filters:         │
│    * _id: {$ne, $nin}   │
│    * isActive: true     │
│    * isProfileComplete: true│
│    * gender: {$in: showMe}│
│    * dateOfBirth: {$gte, $lte}│
│    * location: {$near} (2dsphere)│
│  - Sort: lastActive DESC│
│  - Limit: 50            │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  recommendation.service.js│
│  computeScore()         │
│  - Tính điểm cho mỗi candidate│
│  - Trả về: score, breakdown│
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  user.service.js        │
│  - Enrich candidates với score│
│  - Sort theo score (nếu best)│
│  - Log vào DiscoveryLog│
└────────┬────────────────┘
         │
         │ JSON Response
         ▼
┌─────────────────────────┐
│  Frontend nhận data:     │
│  - List<UserModel>       │
│  - Mỗi user có:          │
│    * score (0-100)      │
│    * breakdown           │
│    * distanceKm          │
│  - Hiển thị trên SwipeCard│
└─────────────────────────┘
```

#### **Chi tiết từng bước:**

**Bước 1: Frontend gửi request**
- **File:** `frontend/lib/presentation/screens/discovery/discovery_screen.dart`
- **Hàm:** `_loadUsers()`
- **Code:**
```dart
final repository = ref.read(userRepositoryProvider);
final users = await repository.getDiscovery(_currentFilters);
```

**Bước 2: Backend nhận request**
- **File:** `backend/src/controllers/user.controller.js`
- **Hàm:** `getDiscovery(req, res, next)`
- **Route:** `GET /api/discover`
- **Middleware:** `authMiddleware` (verify JWT token)

**Bước 3: Service xử lý logic**
- **File:** `backend/src/services/user.service.js`
- **Hàm:** `getDiscovery(userId, filters)`
- **Logic:**
  1. Lấy user hiện tại từ DB
  2. Lấy danh sách user đã swipe (để loại trừ)
  3. Parse filters từ query params
  4. Gọi repository để tìm candidates

**Bước 4: Repository query MongoDB**
- **File:** `backend/src/repositories/user.repository.js`
- **Hàm:** `findCandidatesForDiscovery(currentUser, excludeIds, filters)`
- **MongoDB Query:**
```javascript
User.find({
  _id: { $ne: currentUser._id, $nin: excludeIds },
  isActive: true,
  isProfileComplete: true,
  gender: { $in: showMe },
  dateOfBirth: { $gte: minBirthDate, $lte: maxBirthDate },
  'location.coordinates': {
    $near: {
      $geometry: { type: 'Point', coordinates: [lng, lat] },
      $maxDistance: maxDistance * 1000 // km -> m
    }
  }
})
.sort({ lastActive: -1 })
.limit(50)
```

**Bước 5: Tính Matching Score**
- **File:** `backend/src/services/recommendation.service.js`
- **Hàm:** `computeScore(currentUser, candidate, options)`
- **Xem chi tiết ở mục 2**

**Bước 6: Trả về kết quả**
- Response format:
```json
[
  {
    "user": { /* UserModel */ },
    "score": 75,
    "breakdown": {
      "interests": 30,
      "lifestyle": 15,
      "distance": 18,
      "activity": 8,
      "age": 10
    },
    "distanceKm": 12.5
  }
]
```

---

### 1.2. Swipe & Match (Tương tác)

#### **Sơ đồ luồng dữ liệu:**

```
┌─────────────────┐
│  User swipe     │
│  (Like/Pass/Super)│
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  DiscoveryScreen        │
│  _handleSwipe(action)  │
│  - action: 'like'/'pass'/'superlike'│
└────────┬────────────────┘
         │
         │ HTTP POST /api/swipes
         │ Body: {userId, action}
         ▼
┌─────────────────────────┐
│  Backend:               │
│  swipe.controller.js    │
│  swipe()                │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  swipe.service.js       │
│  swipe(userId, swipedUserId, action)│
│  Bước 1: Kiểm tra đã swipe chưa│
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  swipe.repository.js    │
│  findExisting()         │
│  Query: Swipe.findOne({│
│    swiper: userId,      │
│    swiped: swipedUserId │
│  })                     │
└────────┬────────────────┘
         │
         │ Nếu chưa swipe:
         ▼
┌─────────────────────────┐
│  swipe.repository.js    │
│  create()               │
│  - Tạo record Swipe     │
│  - action: 'like'/'pass'/'superlike'│
└────────┬────────────────┘
         │
         │ Nếu action = 'like' hoặc 'superlike':
         ▼
┌─────────────────────────┐
│  swipe.repository.js    │
│  checkForMatch()         │
│  Query: Swipe.findOne({│
│    swiper: swipedUserId,│
│    swiped: userId,       │
│    action: {$in: ['like', 'superlike']}│
│  })                     │
└────────┬────────────────┘
         │
         │ Nếu có mutual like:
         ▼
┌─────────────────────────┐
│  swipe.repository.js    │
│  createMatch()           │
│  Bước 1: Kiểm tra match đã tồn tại│
│  Bước 2: Tạo Match record│
│  Bước 3: Tạo ChatRoom   │
│  Bước 4: Populate users │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  swipe.service.js       │
│  notifyMatch()          │
│  - Gửi FCM notification │
│  - Emit Socket.IO event │
└────────┬────────────────┘
         │
         │ Socket.IO: 'match:created'
         ▼
┌─────────────────────────┐
│  Frontend nhận:         │
│  - isMatch: true        │
│  - match object         │
│  - chatRoom object      │
│  - Hiển thị Match Dialog│
└─────────────────────────┘
```

#### **Chi tiết từng bước:**

**Bước 1: User thực hiện swipe**
- **File:** `frontend/lib/presentation/screens/discovery/discovery_screen.dart`
- **Hàm:** `_handleSwipe(String action)`
- **Code:**
```dart
final result = await _swipeRepository.swipe(
  userId: user.id, 
  action: action // 'like', 'pass', 'superlike'
);
```

**Bước 2: Backend nhận request**
- **File:** `backend/src/controllers/swipe.controller.js`
- **Hàm:** `swipe(req, res, next)`
- **Route:** `POST /api/swipes`
- **Body:** `{ userId: string, action: 'like'|'pass'|'superlike' }`

**Bước 3: Service xử lý**
- **File:** `backend/src/services/swipe.service.js`
- **Hàm:** `swipe(userId, swipedUserId, action)`
- **Logic:**
  1. Kiểm tra đã swipe chưa (tránh duplicate)
  2. Tạo Swipe record
  3. Nếu là 'like' hoặc 'superlike': kiểm tra match
  4. Nếu match: tạo Match + ChatRoom
  5. Gửi notification

**Bước 4: Kiểm tra Match**
- **File:** `backend/src/repositories/swipe.repository.js`
- **Hàm:** `checkForMatch(swiperId, swipedId)`
- **MongoDB Query:**
```javascript
Swipe.findOne({
  swiper: swipedId,  // Người được swipe đã like người swipe chưa?
  swiped: swiperId,
  action: { $in: ['like', 'superlike'] }
})
```

**Bước 5: Tạo Match (nếu có mutual like)**
- **File:** `backend/src/repositories/swipe.repository.js`
- **Hàm:** `createMatch(user1Id, user2Id)`
- **MongoDB Operations:**
  1. Tạo Match:
```javascript
Match.create({
  users: [user1Id, user2Id].sort(), // Sort để consistent
  matchedAt: new Date()
})
```
  2. Tạo ChatRoom:
```javascript
ChatRoom.create({
  match: match._id,
  participants: [user1Id, user2Id],
  unreadCount: new Map([
    [user1Id.toString(), 0],
    [user2Id.toString(), 0]
  ])
})
```

**Bước 6: Gửi Notification**
- **File:** `backend/src/services/swipe.service.js`
- **Hàm:** `notifyMatch(user1Id, user2Id)`
- **Actions:**
  1. Lấy FCM tokens của cả 2 users
  2. Gửi push notification qua Firebase
  3. Emit Socket.IO event: `match:created`

**Bước 7: Frontend nhận kết quả**
- Response format:
```json
{
  "success": true,
  "data": {
    "swipe": { /* Swipe object */ },
    "match": { /* Match object nếu có */ },
    "chatRoom": { /* ChatRoom object nếu có */ },
    "isMatch": true/false
  }
}
```

---

### 1.3. Chat Real-time

#### **Sơ đồ luồng dữ liệu:**

```
┌─────────────────┐
│  User mở Chat   │
│  Screen         │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  ChatScreen.initState()  │
│  - Load messages (REST) │
│  - Connect Socket.IO    │
│  - Join chat room       │
└────────┬────────────────┘
         │
         ├─ HTTP GET /api/chat/rooms/:roomId/messages
         │
         ▼
┌─────────────────────────┐
│  Backend:               │
│  chat.controller.js      │
│  getMessages()           │
│  - Trả về 50 messages   │
│  - Pagination với 'before'│
└─────────────────────────┘
         │
         ├─ Socket.IO Connection
         │
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  SocketService.connect()│
│  - Kết nối với token    │
│  - Emit 'join-chat-room'│
└────────┬────────────────┘
         │
         │ WebSocket Connection
         ▼
┌─────────────────────────┐
│  Backend:               │
│  socketHandler.js       │
│  - Verify JWT/Firebase token│
│  - socket.userId = user._id│
│  - socket.join('chat:roomId')│
└────────┬────────────────┘
         │
         │ User gửi tin nhắn
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  SocketService.sendMessage()│
│  - Emit 'send-message'   │
│  - {chatRoomId, content}│
└────────┬────────────────┘
         │
         │ Socket.IO Event
         ▼
┌─────────────────────────┐
│  Backend:               │
│  socketHandler.js       │
│  socket.on('send-message')│
│  Bước 1: Validate        │
│  Bước 2: Tạo Message     │
│  Bước 3: Update Match    │
│  Bước 4: Broadcast       │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  chat.repository.js     │
│  createMessage()         │
│  - Tạo Message record    │
│  - Update ChatRoom       │
│  - Increment unreadCount│
└────────┬────────────────┘
         │
         │ Socket.IO Broadcast
         │ io.to('chat:roomId').emit('new-message')
         ▼
┌─────────────────────────┐
│  Frontend:              │
│  ChatScreen              │
│  _handleIncomingMessage()│
│  - Append message        │
│  - Auto-scroll           │
│  - Mark as read          │
└─────────────────────────┘
```

#### **Chi tiết từng bước:**

**Bước 1: Load messages ban đầu (REST)**
- **File:** `frontend/lib/presentation/screens/chat/chat_screen.dart`
- **Hàm:** `initState()`
- **Code:**
```dart
final messages = await repository.getMessages(widget.chatRoomId);
ref.read(chatMessagesProvider.notifier).setMessages(messages);
```

**Bước 2: Backend trả về messages**
- **File:** `backend/src/controllers/chat.controller.js`
- **Hàm:** `getMessages(req, res, next)`
- **Route:** `GET /api/chat/rooms/:roomId/messages?limit=50&before=messageId`
- **MongoDB Query:**
```javascript
Message.find({ chatRoom: roomId })
  .sort({ createdAt: -1 })
  .limit(limit)
  .populate('sender', PUBLIC_USER_FIELDS)
```

**Bước 3: Kết nối Socket.IO**
- **File:** `frontend/lib/core/services/socket_service.dart`
- **Hàm:** `connect()`
- **Code:**
```dart
_socket = IO.io(
  AppConfig.wsUrl,
  IO.OptionBuilder()
    .setTransports(['websocket'])
    .setAuth({'token': token})
    .build()
);
```

**Bước 4: Backend authenticate Socket**
- **File:** `backend/src/websocket/socketHandler.js`
- **Middleware:** Authentication
- **Logic:**
  1. Lấy token từ `socket.handshake.auth.token`
  2. Verify JWT hoặc Firebase token
  3. Lưu `socket.userId` và `socket.user`
  4. Join room: `socket.join('chat:${chatRoomId}')`

**Bước 5: User gửi tin nhắn**
- **File:** `frontend/lib/presentation/screens/chat/chat_screen.dart`
- **Hàm:** `_sendMessage()`
- **Code:**
```dart
_socketService.sendMessage(
  widget.chatRoomId,
  _messageController.text,
  type: 'text'
);
```

**Bước 6: Backend xử lý tin nhắn**
- **File:** `backend/src/websocket/socketHandler.js`
- **Event Handler:** `socket.on('send-message')`
- **Logic:**
  1. Validate: `chatRoomId`, `content`
  2. Kiểm tra user có trong room không
  3. Tạo Message record
  4. Update Match.lastMessage
  5. Broadcast: `io.to('chat:${chatRoomId}').emit('new-message')`

**Bước 7: Tạo Message record**
- **File:** `backend/src/repositories/chat.repository.js`
- **Hàm:** `createMessage(messageData)`
- **MongoDB Operation:**
```javascript
Message.create({
  chatRoom: chatRoomId,
  sender: userId,
  content: content,
  type: 'text',
  createdAt: new Date()
})
```

**Bước 8: Frontend nhận tin nhắn**
- **File:** `frontend/lib/presentation/screens/chat/chat_screen.dart`
- **Hàm:** `_handleIncomingMessage(data)`
- **Logic:**
  1. Parse message từ JSON
  2. Append vào messages list
  3. Auto-scroll to bottom
  4. Nếu là tin nhắn từ người khác: mark as read

**Bước 9: Typing Indicator**
- **Frontend:** `_onTextChanged()` → `_socketService.onTyping(roomId, true)`
- **Backend:** `socket.on('typing')` → `socket.to('chat:roomId').emit('user-typing')`
- **Frontend:** `_handleUserTyping()` → Hiển thị "Đang gõ..."

**Bước 10: Read Receipts**
- **Frontend:** `_socketService.markAsRead(roomId)`
- **Backend:** `socket.on('mark-read')` → Update Message.readBy
- **Broadcast:** `io.to('chat:roomId').emit('messages-read')`

---

## 2. LOGIC MATCHING SCORE

### 2.1. Tổng quan

**File xử lý:** `backend/src/services/recommendation.service.js`  
**Hàm chính:** `computeScore(currentUser, candidate, options)`

### 2.2. Công thức tổng quát

**Raw Score:**
```
S_raw = S_interests + S_lifestyle + S_distance + S_activity + S_age
```

**Normalized Score (0-100):**
```
S_final = min(100, round((S_raw / W_total) × 100))
```

Trong đó:
- `W_total = 40 + 20 + 20 + 10 + 10 = 100` (tổng trọng số)

### 2.3. Chi tiết từng thành phần

#### **2.3.1. Interests Score (40 điểm - 40%)**

**File:** `backend/src/services/recommendation.service.js`  
**Hàm:** `#calcOverlapScore(listA, listB, weight)`

**Công thức:**
```
S_interests = w_interests × (|I_A ∩ I_B| / max(|I_A|, |I_B|))
```

**Trong đó:**
- `I_A`: Danh sách sở thích của User A
- `I_B`: Danh sách sở thích của User B
- `|I_A ∩ I_B|`: Số lượng sở thích chung
- `w_interests = 40`

**Code:**
```javascript
#calcOverlapScore(listA = [], listB = [], weight = 20) {
  if (!Array.isArray(listA) || !Array.isArray(listB) || 
      listA.length === 0 || listB.length === 0) {
    return { points: 0 };
  }
  const setB = new Set(listB);
  const overlap = listA.filter(item => setB.has(item));
  const denominator = Math.max(listA.length, listB.length);
  return { points: Math.min(weight, (overlap.length / denominator) * weight) };
}
```

**Ví dụ:**
- User A: `['travel', 'music', 'coffee', 'photography', 'cooking']` (5 items)
- User B: `['music', 'coffee', 'gaming']` (3 items)
- Chung: `['music', 'coffee']` (2 items)
- `S_interests = 40 × (2/5) = 16` điểm

---

#### **2.3.2. Lifestyle Score (20 điểm - 20%)**

**File:** `backend/src/services/recommendation.service.js`  
**Hàm:** `#calcOverlapScore(listA, listB, weight)` (cùng hàm với Interests)

**Công thức:**
```
S_lifestyle = w_lifestyle × (|L_A ∩ L_B| / max(|L_A|, |L_B|))
```

**Trong đó:**
- `L_A`: Danh sách lối sống của User A
- `L_B`: Danh sách lối sống của User B
- `w_lifestyle = 20`

**Ví dụ:**
- User A: `['fitness', 'early-bird', 'pet-lover']` (3 items)
- User B: `['fitness', 'night-owl']` (2 items)
- Chung: `['fitness']` (1 item)
- `S_lifestyle = 20 × (1/3) ≈ 6.67` điểm

---

#### **2.3.3. Distance Score (20 điểm - 20%)**

**File:** `backend/src/services/recommendation.service.js`  
**Hàm:** `#calcDistanceScore(currentUser, candidate, maxDistanceKm)`

**Công thức Haversine (tính khoảng cách):**
```
a = sin²(Δφ/2) + cos(φ₁) × cos(φ₂) × sin²(Δλ/2)
c = 2 × atan2(√a, √(1-a))
d = R × c
```

**Trong đó:**
- `φ₁, φ₂`: Vĩ độ (latitude) của User A và User B (rad)
- `λ₁, λ₂`: Kinh độ (longitude) của User A và User B (rad)
- `R = 6371` km (bán kính Trái Đất)
- `d`: Khoảng cách (km)

**Công thức điểm:**
```
S_distance = max(0, w_distance × (1 - d/d_max))
```

**Trong đó:**
- `d`: Khoảng cách thực tế (km)
- `d_max`: Khoảng cách tối đa cho phép (từ preferences)
- `w_distance = 20`

**Code:**
```javascript
#calcDistanceScore(currentUser, candidate, maxDistanceKm) {
  const userCoords = currentUser.location?.coordinates;
  const candidateCoords = candidate.location?.coordinates;
  if (!this.#isGeoPoint(userCoords) || !this.#isGeoPoint(candidateCoords)) {
    return { points: 0, distance: null };
  }
  const distance = this.#haversine(userCoords, candidateCoords);
  if (distance > maxDistanceKm) {
    return { points: 0, distance };
  }
  const points = Math.max(
    0,
    DISCOVERY_SCORE_WEIGHTS.DISTANCE - 
    (distance / Math.max(maxDistanceKm, 1)) * DISCOVERY_SCORE_WEIGHTS.DISTANCE
  );
  return { points, distance };
}

#haversine([lng1, lat1], [lng2, lat2]) {
  const toRad = deg => (deg * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
```

**Ví dụ:**
- User A đặt `d_max = 50` km
- User B cách User A `d = 10` km
- `S_distance = 20 × (1 - 10/50) = 20 × 0.8 = 16` điểm

---

#### **2.3.4. Activity Score (10 điểm - 10%)**

**File:** `backend/src/services/recommendation.service.js`  
**Hàm:** `#calcActivityScore(candidate)`

**Công thức:**
```
S_activity = {
  10  nếu Δt ≤ 1 ngày
  8   nếu 1 < Δt ≤ 7 ngày
  5   nếu 7 < Δt ≤ 14 ngày
  2   nếu 14 < Δt ≤ 30 ngày
  0   nếu Δt > 30 ngày
}
```

**Trong đó:**
- `Δt`: Số ngày kể từ lần hoạt động cuối cùng (`lastActive`)

**Code:**
```javascript
#calcActivityScore(candidate) {
  const lastActive = candidate.lastActive ? 
    new Date(candidate.lastActive) : 
    candidate.updatedAt ? new Date(candidate.updatedAt) : null;
  if (!lastActive) {
    return 0;
  }
  const daysInactive = (Date.now() - lastActive.getTime()) / (1000 * 60 * 60 * 24);
  if (daysInactive <= 1) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY; // 10
  if (daysInactive <= 7) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY - 2; // 8
  if (daysInactive <= 14) return DISCOVERY_SCORE_WEIGHTS.ACTIVITY - 5; // 5
  if (daysInactive <= 30) return 2;
  return 0;
}
```

**Lý do:** Ưu tiên người dùng hoạt động gần đây để tăng khả năng match thành công.

---

#### **2.3.5. Age Score (10 điểm - 10%)**

**File:** `backend/src/services/recommendation.service.js`  
**Hàm:** `#calcAgeScore(user, candidate)`

**Công thức:**
```
S_age = {
  w_age                    nếu age_B ∈ [age_min, age_max]
  max(0, w_age - 2×|age_B - age_nearest|)  nếu age_B ∉ [age_min, age_max]
}
```

**Trong đó:**
- `age_B`: Tuổi của User B
- `[age_min, age_max]`: Khoảng tuổi ưa thích của User A
- `age_nearest`: Điểm gần nhất trong khoảng
  - Nếu `age_B < age_min`: `age_nearest = age_min`
  - Nếu `age_B > age_max`: `age_nearest = age_max`
- `w_age = 10`

**Code:**
```javascript
#calcAgeScore(user, candidate) {
  const agePref = user.preferences?.ageRange;
  if (!agePref) return 0;
  const candidateAge = this.#calculateAge(candidate.dateOfBirth);
  if (!candidateAge) return 0;
  if (candidateAge >= agePref.min && candidateAge <= agePref.max) {
    return DISCOVERY_SCORE_WEIGHTS.AGE; // 10
  }
  const diff = candidateAge < agePref.min
    ? agePref.min - candidateAge
    : candidateAge - agePref.max;
  return Math.max(0, DISCOVERY_SCORE_WEIGHTS.AGE - diff * 2);
}
```

**Ví dụ:**
- User A preferences: 25-35 tuổi
- User B: 28 tuổi → `S_age = 10` (trong khoảng)
- User B: 40 tuổi → Chênh lệch: `40 - 35 = 5` → `S_age = max(0, 10 - 2×5) = 0`
- User B: 23 tuổi → Chênh lệch: `25 - 23 = 2` → `S_age = max(0, 10 - 2×2) = 6`

---

### 2.4. Ví dụ tính toán hoàn chỉnh

**Giả sử:**
- **User A:**
  - Interests: `['travel', 'music', 'coffee', 'photography', 'cooking']`
  - Lifestyle: `['fitness', 'early-bird', 'pet-lover']`
  - Location: `[106.6297, 10.8231]` (Sài Gòn)
  - Preferences: Age 25-35, maxDistance 50km
  - Gender preference: `['female']`

- **User B:**
  - Interests: `['music', 'coffee', 'reading', 'gaming']`
  - Lifestyle: `['fitness', 'pet-lover']`
  - Location: `[106.7000, 10.8500]` (Cách ~10km)
  - Age: 28
  - Gender: `female`
  - Last active: 2 ngày trước

**Tính toán:**

1. **Interests Score:**
   - Chung: `['music', 'coffee']` (2/5)
   - `S_interests = 40 × (2/5) = 16`

2. **Lifestyle Score:**
   - Chung: `['fitness', 'pet-lover']` (2/3)
   - `S_lifestyle = 20 × (2/3) ≈ 13.33`

3. **Distance Score:**
   - `d = 10` km, `d_max = 50` km
   - `S_distance = 20 × (1 - 10/50) = 16`

4. **Activity Score:**
   - `Δt = 2` ngày (1 < 2 < 7)
   - `S_activity = 10 - 2 = 8`

5. **Age Score:**
   - Age B = 28, trong khoảng [25, 35]
   - `S_age = 10`

**Tổng hợp:**
```
S_raw = 16 + 13.33 + 16 + 8 + 10 = 63.33
S_final = round((63.33 / 100) × 100) = 63
```

**Kết quả:** User B có **Matching Score = 63%** với User A.

---

### 2.5. Tại sao dùng công thức này?

1. **Jaccard Similarity cho Interests/Lifestyle:**
   - Đo lường độ trùng lặp chính xác
   - Chuẩn hóa theo độ dài danh sách (tránh bias)
   - Được sử dụng rộng rãi trong recommendation systems

2. **Haversine Formula cho Distance:**
   - Công thức chính xác để tính khoảng cách trên bề mặt Trái Đất
   - Xử lý được độ cong của Trái Đất
   - Được sử dụng trong MongoDB geospatial queries

3. **Linear Decay cho Distance Score:**
   - Đơn giản, dễ hiểu
   - Phản ánh đúng: càng gần càng tốt
   - Có thể điều chỉnh dễ dàng

4. **Time-based Decay cho Activity:**
   - Ưu tiên người dùng hoạt động gần đây
   - Giảm số lượng profile "ma" (inactive)
   - Tăng khả năng match thành công

5. **Range-based Scoring cho Age:**
   - Tôn trọng preferences của người dùng
   - Vẫn cho điểm nếu gần khoảng (flexible)
   - Phản ánh thực tế: tuổi tác ít quan trọng hơn sở thích

---

## 3. MAPPING CODE - TÊN FILE VÀ HÀM

### 3.1. Discovery (Khám phá)

| Logic nghiệp vụ | File | Hàm/Class | Mô tả |
|----------------|------|-----------|-------|
| **Frontend: Load users** | `frontend/lib/presentation/screens/discovery/discovery_screen.dart` | `_loadUsers()` | Gọi API và cập nhật state |
| **Frontend: Repository** | `frontend/lib/data/repositories/user_repository.dart` | `getDiscovery(filters)` | HTTP GET request |
| **Backend: Controller** | `backend/src/controllers/user.controller.js` | `getDiscovery(req, res, next)` | Route handler |
| **Backend: Service** | `backend/src/services/user.service.js` | `getDiscovery(userId, filters)` | Business logic chính |
| **Backend: Parse filters** | `backend/src/services/user.service.js` | `parseDiscoveryFilters(rawFilters)` | Parse query params |
| **Backend: Get swiped IDs** | `backend/src/repositories/swipe.repository.js` | `getSwipedUserIds(userId)` | Query: `Swipe.find({swiper: userId})` |
| **Backend: Find candidates** | `backend/src/repositories/user.repository.js` | `findCandidatesForDiscovery(currentUser, excludeIds, filters)` | MongoDB query với hard filters |
| **Backend: Geospatial query** | `backend/src/repositories/user.repository.js` | `findCandidatesForDiscovery()` | `location.coordinates: {$near}` với 2dsphere index |
| **Backend: Calculate score** | `backend/src/services/recommendation.service.js` | `computeScore(currentUser, candidate, options)` | Tính matching score |
| **Backend: Log results** | `backend/src/services/recommendation.service.js` | `logDiscoveryResults(viewerId, results, filters)` | Lưu vào DiscoveryLog |

---

### 3.2. Matching Score Calculation

| Logic nghiệp vụ | File | Hàm/Class | Mô tả |
|----------------|------|-----------|-------|
| **Main calculation** | `backend/src/services/recommendation.service.js` | `computeScore(currentUser, candidate, options)` | Hàm chính tính điểm |
| **Interests overlap** | `backend/src/services/recommendation.service.js` | `#calcOverlapScore(listA, listB, weight)` | Jaccard similarity |
| **Lifestyle overlap** | `backend/src/services/recommendation.service.js` | `#calcOverlapScore(listA, listB, weight)` | Jaccard similarity |
| **Distance calculation** | `backend/src/services/recommendation.service.js` | `#calcDistanceScore(currentUser, candidate, maxDistanceKm)` | Tính điểm khoảng cách |
| **Haversine formula** | `backend/src/services/recommendation.service.js` | `#haversine([lng1, lat1], [lng2, lat2])` | Tính khoảng cách địa lý |
| **Activity score** | `backend/src/services/recommendation.service.js` | `#calcActivityScore(candidate)` | Time-based decay |
| **Age score** | `backend/src/services/recommendation.service.js` | `#calcAgeScore(user, candidate)` | Range-based scoring |
| **Age calculation** | `backend/src/services/recommendation.service.js` | `#calculateAge(date)` | Tính tuổi từ dateOfBirth |
| **Constants (weights)** | `backend/src/utils/constants.js` | `DISCOVERY_SCORE_WEIGHTS` | Trọng số: INTERESTS=40, LIFESTYLE=20, DISTANCE=20, ACTIVITY=10, AGE=10 |

---

### 3.3. Swipe & Match

| Logic nghiệp vụ | File | Hàm/Class | Mô tả |
|----------------|------|-----------|-------|
| **Frontend: Handle swipe** | `frontend/lib/presentation/screens/discovery/discovery_screen.dart` | `_handleSwipe(String action)` | Xử lý swipe action |
| **Frontend: Repository** | `frontend/lib/data/repositories/swipe_repository.dart` | `swipe(userId, action)` | HTTP POST request |
| **Backend: Controller** | `backend/src/controllers/swipe.controller.js` | `swipe(req, res, next)` | Route handler |
| **Backend: Service** | `backend/src/services/swipe.service.js` | `swipe(userId, swipedUserId, action)` | Business logic chính |
| **Backend: Check existing** | `backend/src/repositories/swipe.repository.js` | `findExisting(swiperId, swipedId)` | Query: `Swipe.findOne({swiper, swiped})` |
| **Backend: Create swipe** | `backend/src/repositories/swipe.repository.js` | `create(swipeData)` | `Swipe.create({swiper, swiped, action})` |
| **Backend: Check match** | `backend/src/repositories/swipe.repository.js` | `checkForMatch(swiperId, swipedId)` | Query: `Swipe.findOne({swiper: swipedId, swiped: swiperId, action: {$in: ['like', 'superlike']}})` |
| **Backend: Create match** | `backend/src/repositories/swipe.repository.js` | `createMatch(user1Id, user2Id)` | Tạo Match + ChatRoom |
| **Backend: Notify match** | `backend/src/services/swipe.service.js` | `notifyMatch(user1Id, user2Id)` | FCM + Socket.IO |
| **Backend: Socket emit** | `backend/src/websocket/socketHandler.js` | `emitToUser(userId, 'match:created', data)` | Emit Socket.IO event |

---

### 3.4. Chat Real-time

| Logic nghiệp vụ | File | Hàm/Class | Mô tả |
|----------------|------|-----------|-------|
| **Frontend: Load messages** | `frontend/lib/presentation/screens/chat/chat_screen.dart` | `initState()` | Load messages ban đầu |
| **Frontend: Repository** | `frontend/lib/data/repositories/chat_repository.dart` | `getMessages(roomId)` | HTTP GET request |
| **Backend: Controller** | `backend/src/controllers/chat.controller.js` | `getMessages(req, res, next)` | Route handler |
| **Backend: Service** | `backend/src/services/chat.service.js` | `getMessages(chatRoomId, userId, limit, before)` | Business logic |
| **Backend: Repository** | `backend/src/repositories/chat.repository.js` | `getMessages(chatRoomId, limit, before)` | Query: `Message.find({chatRoom}).sort({createdAt: -1}).limit(limit)` |
| **Frontend: Socket connect** | `frontend/lib/core/services/socket_service.dart` | `connect()` | Kết nối Socket.IO |
| **Backend: Socket auth** | `backend/src/websocket/socketHandler.js` | Authentication middleware | Verify JWT/Firebase token |
| **Backend: Join room** | `backend/src/websocket/socketHandler.js` | `socket.on('join-chat-room')` | `socket.join('chat:${chatRoomId}')` |
| **Frontend: Send message** | `frontend/lib/core/services/socket_service.dart` | `sendMessage(chatRoomId, content)` | Emit 'send-message' |
| **Backend: Handle message** | `backend/src/websocket/socketHandler.js` | `socket.on('send-message')` | Xử lý tin nhắn |
| **Backend: Create message** | `backend/src/repositories/chat.repository.js` | `createMessage(messageData)` | `Message.create({chatRoom, sender, content, type})` |
| **Backend: Update match** | `backend/src/repositories/match.repository.js` | `updateLastMessage(matchId, messageId, content)` | Update Match.lastMessage |
| **Backend: Broadcast** | `backend/src/websocket/socketHandler.js` | `io.to('chat:${chatRoomId}').emit('new-message')` | Broadcast tin nhắn |
| **Frontend: Handle incoming** | `frontend/lib/presentation/screens/chat/chat_screen.dart` | `_handleIncomingMessage(data)` | Append message |
| **Frontend: Typing** | `frontend/lib/core/services/socket_service.dart` | `onTyping(chatRoomId, isTyping)` | Emit 'typing' |
| **Backend: Typing handler** | `backend/src/websocket/socketHandler.js` | `socket.on('typing')` | Broadcast 'user-typing' |
| **Frontend: Mark read** | `frontend/lib/core/services/socket_service.dart` | `markAsRead(chatRoomId)` | Emit 'mark-read' |
| **Backend: Mark read** | `backend/src/websocket/socketHandler.js` | `socket.on('mark-read')` | Update Message.readBy |

---

### 3.5. MongoDB Queries

| Logic nghiệp vụ | File | Query | Index |
|----------------|------|-------|-------|
| **Find candidates** | `backend/src/repositories/user.repository.js` | `User.find({_id: {$ne, $nin}, isActive: true, isProfileComplete: true, gender: {$in}, dateOfBirth: {$gte, $lte}, 'location.coordinates': {$near}})` | `location.coordinates: 2dsphere`, `isActive: 1`, `isProfileComplete: 1` |
| **Get swiped IDs** | `backend/src/repositories/swipe.repository.js` | `Swipe.find({swiper: userId}).select('swiped')` | `swiper: 1`, `{swiper: 1, swiped: 1}: unique` |
| **Check match** | `backend/src/repositories/swipe.repository.js` | `Swipe.findOne({swiper: swipedId, swiped: swiperId, action: {$in: ['like', 'superlike']}})` | `{swiped: 1, action: 1}` |
| **Get messages** | `backend/src/repositories/chat.repository.js` | `Message.find({chatRoom: roomId}).sort({createdAt: -1}).limit(limit).populate('sender')` | `chatRoom: 1, createdAt: -1` |
| **Find chat rooms** | `backend/src/repositories/chat.repository.js` | `ChatRoom.find({participants: userId}).populate('participants').populate('match')` | `participants: 1` |

---

## 4. CÂU HỎI PHẢN BIỆN

### Câu hỏi 1: "Tại sao lại dùng MongoDB thay vì PostgreSQL? Làm thế nào để đảm bảo tính nhất quán dữ liệu (consistency) khi tạo Match và ChatRoom?"

**Gợi ý trả lời:**

**Lý do chọn MongoDB:**
1. **Schema linh hoạt:** User profiles có cấu trúc linh hoạt (interests, lifestyle là arrays), dễ thay đổi trong giai đoạn phát triển
2. **Geospatial queries:** MongoDB có native support cho 2dsphere index, phù hợp với location-based queries
3. **Horizontal scaling:** Dễ dàng shard data khi số users tăng
4. **JSON documents:** Dễ serialize với JavaScript, giảm overhead

**Đảm bảo consistency:**
1. **MongoDB Transactions:** Từ MongoDB 4.0+, hỗ trợ multi-document transactions
2. **Code hiện tại:** Trong `swipe.repository.js`, hàm `createMatch()` tạo Match và ChatRoom tuần tự, nhưng có thể cải thiện bằng transaction:
```javascript
const session = await mongoose.startSession();
session.startTransaction();
try {
  const match = await Match.create([{ users: sortedUsers }], { session });
  const chatRoom = await ChatRoom.create([{ match: match[0]._id, participants: [user1Id, user2Id] }], { session });
  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```
3. **Unique indexes:** Sử dụng unique index trên `{swiper: 1, swiped: 1}` để tránh duplicate swipes
4. **Race condition:** Có thể xảy ra nếu 2 users swipe cùng lúc, nhưng unique index đảm bảo chỉ 1 match được tạo

**Trade-offs:**
- ACID transactions có overhead, nhưng đảm bảo data integrity
- Có thể implement optimistic locking nếu cần

---

### Câu hỏi 2: "Hệ thống Matching Score có vấn đề gì khi người dùng mới (Cold Start Problem)? Làm thế nào để xử lý?"

**Gợi ý trả lời:**

**Vấn đề Cold Start:**
1. **New User làm Viewer:** Chưa có preferences, chưa có hành vi swipe
2. **New User làm Candidate:** Chưa có đủ dữ liệu (interests, lifestyle), sẽ bị điểm thấp

**Giải pháp hiện tại:**
1. **Default values:** Sử dụng `DEFAULT_PREFERENCES` khi user chưa đặt preferences:
   - Age range: 18-100
   - Max distance: 50km
   - Show me: Tất cả (trừ giới tính của chính họ nếu straight)

2. **Boosting new users:** Trong `#calcActivityScore()`, người dùng mới (< 7 ngày) có thể được boost:
```javascript
// Có thể thêm logic:
if (candidate.createdAt && (Date.now() - candidate.createdAt) < 7 * 24 * 60 * 60 * 1000) {
  return DISCOVERY_SCORE_WEIGHTS.ACTIVITY; // Luôn 10 điểm
}
```

3. **Onboarding:** Yêu cầu user chọn ít nhất 3-5 interests trong quá trình onboarding

**Giải pháp cải thiện (chưa implement):**
1. **Popular profiles:** Ưu tiên hiển thị profiles có tỷ lệ match cao
2. **Collaborative filtering:** "Người dùng giống bạn cũng thích những profile này"
3. **Random exploration:** 10-15% kết quả là random để discover profiles mới
4. **Minimum score guarantee:** Đảm bảo tối thiểu 5-10 điểm cho bất kỳ profile nào vượt qua Hard Filters

**Code cải thiện:**
```javascript
// Trong recommendation.service.js
computeScore(currentUser, candidate, options = {}) {
  // ... existing code ...
  
  // Cold start handling
  if (candidate.interests.length < 3) {
    breakdown.interests = 0.3 * DISCOVERY_SCORE_WEIGHTS.INTERESTS; // 12 điểm cơ bản
  }
  if (candidate.lifestyle.length < 2) {
    breakdown.lifestyle = 0.2 * DISCOVERY_SCORE_WEIGHTS.LIFESTYLE; // 4 điểm cơ bản
  }
  
  // Minimum score guarantee
  const finalScore = Math.max(5, normalized);
  return { score: finalScore, breakdown, distanceKm };
}
```

---

### Câu hỏi 3: "Làm thế nào để scale hệ thống khi số lượng users tăng lên? Có bottleneck nào không?"

**Gợi ý trả lời:**

**Bottlenecks hiện tại:**
1. **Discovery query:** Khi có 100k+ users, query `findCandidatesForDiscovery()` có thể chậm
2. **Matching score calculation:** Tính điểm cho mỗi candidate là CPU-intensive
3. **Socket.IO connections:** Mỗi connection giữ state, có thể tốn memory
4. **MongoDB:** Single instance có giới hạn

**Giải pháp scaling:**

**1. Database:**
- **MongoDB Sharding:** Shard theo user ID hoặc location
- **Read Replicas:** Tách read/write operations
- **Indexes:** Đảm bảo có indexes cho tất cả queries (đã có: `location.coordinates: 2dsphere`, `swiper: 1, swiped: 1`)

**2. Caching:**
- **Redis Cache:** Cache discovery results cho user trong 5-10 phút
- **Cache key:** `discovery:${userId}:${filtersHash}`
- **Invalidation:** Khi user swipe hoặc update profile

**3. Application:**
- **Load Balancer:** Nginx/HAProxy để distribute requests
- **Multiple Express servers:** Stateless, dễ scale horizontal
- **Socket.IO Redis Adapter:** Share socket connections across servers
```javascript
const redisAdapter = require('@socket.io/redis-adapter');
const { createClient } = require('redis');
const pubClient = createClient({ host: 'localhost', port: 6379 });
const subClient = pubClient.duplicate();
io.adapter(redisAdapter(pubClient, subClient));
```

**4. Matching Score:**
- **Background jobs:** Tính điểm trước, cache kết quả
- **Batch processing:** Tính điểm cho nhiều candidates cùng lúc
- **Machine Learning:** Train model offline, serve predictions online

**5. Geospatial queries:**
- **Pre-filtering:** Filter theo city/province trước, sau đó mới dùng $near
- **Grid-based:** Chia map thành grid, query theo grid cells

**6. Monitoring:**
- **APM:** Application Performance Monitoring (New Relic, Datadog)
- **Database monitoring:** MongoDB Atlas monitoring
- **Alerting:** Alert khi response time > threshold

**Code example (caching):**
```javascript
// Trong user.service.js
async getDiscovery(userId, filters = {}) {
  const cacheKey = `discovery:${userId}:${JSON.stringify(filters)}`;
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // ... existing logic ...
  
  const result = enriched;
  await redis.setex(cacheKey, 300, JSON.stringify(result)); // 5 phút
  return result;
}
```

**Timeline scaling:**
- **0-10k users:** Single server, MongoDB single instance (hiện tại)
- **10k-100k users:** Load balancer + 2-3 Express servers, MongoDB replica set
- **100k+ users:** Multiple servers, MongoDB sharding, Redis cache, CDN

---

## 📚 TÀI LIỆU THAM KHẢO

1. **Matching Score System:** `docs/MATCHING_SCORE_SYSTEM.md`
2. **Technical Stack:** `docs/TECHNICAL_STACK_DECISION_LOG.md`
3. **API Documentation:** `docs/API.md`
4. **Project Roadmap:** `docs/PROJECT_ROADMAP.md`

---

**Chúc bạn bảo vệ thành công! 🎓**

