## Tài liệu API Matcha (tóm tắt – tiếng Việt)

Tài liệu này không liệt kê *từng* field như Swagger, mà tập trung vào **những endpoint quan trọng đang dùng trong app hiện tại**.

Base URL (dev):

- `http://<IP_MAY_BACKEND>:3000/api`

---

### 1. Auth

#### `POST /api/auth/firebase`

Đăng nhập / đăng ký bằng Firebase token.

- Body:
  ```json
  {
    "token": "<firebase-id-token>"
  }
  ```
- Response:
  ```json
  {
    "success": true,
    "data": {
      "user": { /* User public JSON */ },
      "token": "<jwt-access-token>"
    }
  }
  ```

JWT trả về sẽ được frontend lưu, gửi trong header:

```http
Authorization: Bearer <jwt>
```

#### `GET /api/auth/me`

Lấy lại thông tin user hiện tại (dựa trên JWT).

---

### 2. User / Profile

#### `GET /api/users/profile`

Lấy hồ sơ của user đang đăng nhập.

#### `PATCH /api/users/profile`

Cập nhật thông tin text:

- Body (tất cả optional):
  ```json
  {
    "bio": "string, <= 300 kí tự",
    "interests": ["travel", "music", "..."],   // tối đa 5, phải đúng danh sách
    "job": "string, <= 120",
    "school": "string, <= 120",
    "lifestyle": ["fitness", "night-owl"]      // tối đa 5, đúng danh sách LIFESTYLE_OPTIONS
  }
  ```

#### `PATCH /api/users/profile/photos`

Quản lý danh sách ảnh:

- Body:
  ```json
  {
    "photos": [
      { "id": "existingId?", "url": "https://...", "order": 0, "isPrimary": true },
      { "url": "https://...", "order": 1 }
    ],
    "removedPhotoIds": ["..."]
  }
  ```

Server sẽ:

- Giới hạn tối đa 6 ảnh.
- Chuẩn hoá `order` thành 0..n-1.
- Đặt ảnh `order = 0` là `isPrimary = true`.

#### `PUT /api/users/location`

Cập nhật vị trí dựa trên dropdown:

- Body:
  ```json
  {
    "province": "TP. Hồ Chí Minh",
    "city": "Quận 1",
    "district": "Bến Nghé",
    "address": "tuỳ chọn",
    "country": "Vietnam"
  }
  ```

Toạ độ `[lng, lat]` có thể được set bằng script riêng hoặc qua API khác (tuỳ môi trường dev).

---

### 3. Discover

#### `GET /api/discover`

Endpoint chính cho màn hình Discover (Smart Recommendation).

Query params:

- `ageMin`, `ageMax`: số tuổi.
- `distance`: số km tối đa.
- `showMe`: có thể truyền nhiều lần (`showMe=male&showMe=female`).
- `lifestyle`: nhiều lần (tuỳ chọn).
- `interests`: nhiều lần (tuỳ chọn).
- `onlyOnline`: `true/false`.
- `sort`: `'best' | 'newest'`.

Ví dụ:

```http
GET /api/discover?ageMin=22&ageMax=32&distance=50&showMe=female&onlyOnline=false&sort=best
```

Response:

```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "...",
        "firstName": "Lan",
        "age": 27,
        "photos": [...],
        "interests": ["travel", "music"],
        "lifestyle": ["fitness"],
        "location": { "province": "Hà Nội", "city": "Cầu Giấy", "coordinates": [105.79, 21.03] },
        "score": 86.5,
        "scoreBreakdown": {
          "interests": 30,
          "lifestyle": 20,
          "age": 15,
          "activity": 10,
          "distance": 11.5
        },
        "distanceKm": 3.2
      }
    ]
  }
}
```

---

### 4. Swipe & Match

#### `POST /api/swipes`

- Body:
  ```json
  {
    "userId": "<id user bị swipe>",
    "action": "like | pass | superlike"
  }
  ```

- Response (ví dụ `like` có match):
  ```json
  {
    "success": true,
    "data": {
      "swipe": { /* bản ghi swipe */ },
      "match": { /* match public JSON hoặc null */ },
      "chatRoom": { /* chatroom public JSON hoặc null */ },
      "isMatch": true
    }
  }
  ```

#### `GET /api/matches`

Trả về danh sách match của user hiện tại (dùng ở màn Matches).

---

### 5. Chat

#### `GET /api/chat/rooms`

Lấy danh sách chatroom của user:

- Trả về:
  ```json
  {
    "success": true,
    "data": {
      "rooms": [
        {
          "id": "...",
          "match": "...",
          "participants": [ { /* user public */ }, { /* user public */ } ],
          "lastMessage": { /* message public */ },
          "lastMessageAt": "2025-11-26T14:00:00.000Z",
          "unreadCount": {
            "<userId1>": 0,
            "<userId2>": 3
          }
        }
      ]
    }
  }
  ```

#### `GET /api/chat/rooms/:roomId/messages`

Query:

- `limit`: số tin tối đa (mặc định 50).
- `before`: `ISO date` – phân trang lùi.

#### `PUT /api/chat/rooms/:roomId/read`

Đánh dấu đã đọc tất cả tin nhắn trong room cho user hiện tại.

---

### 6. Upload

#### `POST /api/upload/image`

Upload ảnh (cho avatar/profile).

- Form-data:
  - `image`: file ảnh.
- Response:
  ```json
  {
    "success": true,
    "data": {
      "url": "https://firebasestorage.googleapis.com/..."
    }
  }
  ```

Media cho chat (`/api/upload/chat-media`) đang trong quá trình thiết kế; UI đã chuẩn bị nhưng backend sẽ được bổ sung sau.

---

### 7. Health-check & debug

- `GET /api/health` – kiểm tra backend sống.
- `GET /api/users/profile` – test JWT + auth.
- Socket.IO:
  - Đã bọc logger trong `src/websocket/socket.js` → mọi event gửi/nhận đều log ra console (dễ debug realtime).

---

### Trạng thái hiện tại

- ✅ API Auth, User/Profile, Discover, Swipe/Match, Chat, Upload ảnh cơ bản.
- ✅ Tích hợp với Firebase (Auth + Storage + FCM token lưu DB).
- ⏳ Đang làm:
  - API upload media cho chat (image/gif/sticker).
  - API proxy Giphy/Tenor cho tìm GIF.
  - Một số endpoint quản trị / debug (thống kê socket, cleanup dữ liệu). 


