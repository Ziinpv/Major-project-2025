## Tài liệu CSDL Matcha (MongoDB)

Tài liệu này tóm tắt **schema chính** trong MongoDB, đã cập nhật theo trạng thái hiện tại của dự án.

---

### 1. users

**Collection:** `users`

Các field quan trọng:

- `_id`: `ObjectId`
- `firebaseUid`: `String | null` – liên kết với Firebase Auth
- `email`, `phone`: `String | null` (ẩn với client trong `toPublicJSON`)
- `firstName`, `lastName`: `String`
- `dateOfBirth`: `Date`
- `gender`: `String` – `'male' | 'female' | 'non-binary' | 'other'`
- `interestedIn`: `String[]`
- `bio`: `String | null`
- `photos`: `[{ _id, url, isPrimary, order }]`
  - Tối đa 6 ảnh
  - `order` chuẩn hoá từ 0..n-1, `order = 0` luôn là `isPrimary = true`
- `location`:
  - `province`, `city`, `district`, `address`, `country`
  - `coordinates`: `[lng, lat]` (2dsphere index)
  - `lastUpdatedAt`: `Date`
- `interests`: `String[]` – id theo `assets/data/interests.json`, tối đa 5
- `lifestyle`: `String[]` – id theo `LIFESTYLE_OPTIONS` / `assets/data/lifestyles.json`, tối đa 5
- `job`, `school`: `String | null`
- `isVerified`, `isActive`, `isProfileComplete`: `Boolean`
- `lastActive`: `Date | null`
- `preferences`:
  - `ageRange`: `{ min: Number, max: Number }`
  - `maxDistance`: `Number` – km
  - `lifestyle`: `String[]`
  - `showMe`: `String[]`
  - `onlyShowOnline`: `Boolean`

**Index chính:**

- `location.coordinates`: `2dsphere` (dùng cho `$near` trong Discover)

---

### 2. swipes

**Collection:** `swipes`

- `_id`: `ObjectId`
- `swiper`: `ObjectId` → `users._id`
- `swiped`: `ObjectId` → `users._id`
- `action`: `'like' | 'pass' | 'superlike'`
- `createdAt`, `updatedAt`: `Date`

Sử dụng để:

- Kiểm tra đã swipe chưa (chặn double swipe)
- Tìm mutual like để tạo `matches` + `chatrooms`

---

### 3. matches

**Collection:** `matches`

- `_id`: `ObjectId`
- `users`: `[ObjectId, ObjectId]` – 2 user đã match
- `matchedAt`: `Date`
- `isActive`: `Boolean`
- `unmatchedAt`, `unmatchedBy`: phục vụ chức năng unmatch
- `lastMessageAt`: `Date | null`
- `lastMessage`: `String | null` – nội dung/text tóm tắt

**Index:**

- `{'users.0': 1, 'users.1': 1}` – unique, đảm bảo 1 cặp user chỉ có 1 match

**Liên quan:**

- `matches._id` → `chatrooms.match`

---

### 4. chatrooms

**Collection:** `chatrooms`

- `_id`: `ObjectId`
- `match`: `ObjectId` → `matches._id`
- `participants`: `ObjectId[]` → `users._id` (thường là 2 user)
- `lastMessage`: `ObjectId | null` → `messages._id`
- `lastMessageAt`: `Date | null`
- `unreadCount`: `Map<String, Number>` – key là `userId` (string), value là số tin chưa đọc
- `isActive`: `Boolean`
- `createdAt`, `updatedAt`: `Date`

**Index:**

- `{ participants: 1, isActive: 1, lastMessageAt: -1 }` – phục vụ ChatList

---

### 5. messages

*(phần này chỉ tóm tắt, media nâng cao đang trong giai đoạn thiết kế)*

- `_id`: `ObjectId`
- `chatRoom`: `ObjectId` → `chatrooms._id`
- `sender`: `ObjectId` → `users._id`
- `type`: `'text' | 'image' | 'gif' | 'sticker'` *(hiện tại chủ yếu dùng `text`, phần media WIP)*
- `content`: `String` – text hoặc caption
- `mediaUrl`: `String | null`
- `thumbnailUrl`: `String | null`
- `metadata`: `Object | null`
- `createdAt`, `updatedAt`: `Date`
- `deliveredAt`, `readAt`: `Date | null`

---

### 6. discovery_logs (phục vụ gợi ý thông minh)

**Collection:** `discoverylogs`

- `_id`: `ObjectId`
- `userId`: `ObjectId` – người đang Discover
- `candidateId`: `ObjectId` – user được xuất hiện
- `action`: `'view' | 'like' | 'pass' | 'superlike' | 'match'`
- `timestamp`: `Date`
- `score`: `Number | null` – điểm recommendation tại thời điểm đó
- `filters`: `Object` – snapshot filter (ageMin, ageMax, distance, interests, lifestyle…)
- `location`: `Object` – snapshot location của user

Hiện tại được dùng để log; trong tương lai có thể train mô hình ML/Ranking.

---

### 7. device_tokens

Lưu FCM token cho push notification:

- `user`: `ObjectId` → `users._id`
- `token`: `String`
- `platform`: `'android' | 'ios' | 'web'`
- `isActive`: `Boolean`

---

### Trạng thái hoàn thành

- ✅ Cấu trúc CSDL cho **user / swipe / match / chatroom / message / discovery_logs / device_tokens** đã ổn định cho môi trường dev.
- ✅ Đã có index quan trọng cho:
  - `users.location.coordinates` (2dsphere)
  - `matches.users` (unique pair)
  - `chatrooms.participants + lastMessageAt`
- ⏳ Các phần đang tiếp tục hoàn thiện:
  - Bổ sung index tối ưu cho Discover nâng cao (theo interests/lifestyle nếu cần).
  - Logging & cleanup tự động cho `discovery_logs` (tránh phình dữ liệu).
  - Bổ sung migration script nếu schema thay đổi ở các phiên bản sau. 


