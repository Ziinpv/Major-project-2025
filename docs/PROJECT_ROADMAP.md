## Roadmap Dự Án Matcha (Cập nhật theo tiến độ hiện tại)

Tài liệu này liệt kê các hạng mục chính, trạng thái thực tế, và định hướng tiếp theo.

Ký hiệu:

- ✅ Hoàn thành & đang sử dụng
- 🟡 Đang thực hiện / beta
- ⏳ Chưa bắt đầu / mới ở mức thiết kế

---

### 1. Nền tảng & Kiến trúc

- ✅ Backend Node.js + Express + MongoDB
- ✅ Flutter app (Android), Riverpod làm state management
- ✅ Tích hợp Firebase (Auth, Storage, FCM token)
- ✅ Socket.IO cho realtime chat

---

### 2. Onboarding & Auth

- ✅ Đăng nhập / đăng ký bằng Firebase token → Backend trả JWT
- ✅ Lưu token vào `SharedPreferences`, tự động đăng nhập lại
- ✅ Onboarding sơ bộ (giới tính, ngày sinh, ảnh đầu tiên…)
- 🟡 Kiểm soát multi-device / revoke token cũ (ý tưởng)

---

### 3. Hồ sơ người dùng (Profile)

- ✅ Schema `User` mở rộng:
  - Ảnh: tối đa 6, có `isPrimary` + `order`
  - Bio, công việc, trường học
  - Interests (tối đa 5 – theo `assets/data/interests.json`)
  - Lifestyle (tối đa 5 – theo `assets/data/lifestyles.json`)
  - Location (tỉnh/thành, quận/huyện, toạ độ, thời gian cập nhật)
  - Preferences (ageRange, maxDistance, lifestyle, showMe, onlyShowOnline)
- ✅ API:
  - `PATCH /api/users/profile`
  - `PATCH /api/users/profile/photos`
  - `PUT /api/users/location`
- ✅ UI Edit Profile:
  - Lưới ảnh kéo thả (reorderable_grid_view)
  - Upload ảnh (Firebase Storage)
  - Sở thích + lifestyle bằng FilterChip
  - Nút **Xem trước** card profile

---

### 4. Discover & Recommendation

- ✅ Nâng cấp schema & index:
  - `location.coordinates` 2dsphere
  - `LIFESTYLE_OPTIONS`, `DISCOVERY_SORT_OPTIONS`
- ✅ Service gợi ý:
  - `recommendation.service.js`: tính điểm theo interests, lifestyle, độ tuổi, hoạt động, khoảng cách
  - `DiscoveryLog` + `recommendation.repository` để log hành vi cho ML sau này
- ✅ API:
  - `GET /api/discover` với filter:
    - ageMin/ageMax, distance
    - lifestyle, interests
    - showMe (đa giới tính)
    - onlyOnline
    - sort: best/newest
- ✅ Frontend Discover:
  - Bộ lọc nâng cao (bottom sheet) + lưu vào `SharedPreferences`
  - Hiển thị `Match Score`, distance, breakdown
  - Banner nhắc hoàn thiện hồ sơ (interests + lifestyle)
- 🟡 Tối ưu thêm: log/analytics, A/B testing rule scoring

---

### 5. Swipe, Match & Chat

- ✅ Swipe:
  - `POST /api/swipes` + chống swipe trùng
  - Script `seed_swipes.js` để seed match hàng loạt (cho demo)
- ✅ Match:
  - Bảng `matches` với unique index 2 user
  - API `GET /api/matches`
  - Thông tin `lastMessage` / `lastMessageAt`
- ✅ Chat:
  - Bảng `chatrooms` + `messages`
  - API:
    - `GET /api/chat/rooms`
    - `GET /api/chat/rooms/:roomId/messages`
    - `PUT /api/chat/rooms/:roomId/read`
  - Socket.IO:
    - join-chat-rooms, join-chat-room / leave-chat-room
    - send-message, typing, mark-read
  - Fix lỗi:
    - Trùng tin nhắn do REST + socket (bỏ qua socket echo cho message vừa gửi local)
    - Lỗi serialize ObjectId trong ChatRoom
    - Lỗi redirect onboarding khi save profile

---

### 6. Media & Realtime Nâng Cao

- 🟡 Thiết kế:
  - Mở rộng `messages`:
    - `type`: text / image / gif / sticker
    - `mediaUrl`, `thumbnailUrl`, `metadata`
    - `deliveredAt`, `readAt`
  - Endpoint upload media:
    - `POST /api/upload/chat-media`
  - Proxy GIF:
    - `GET /api/chat/gifs?query=...` (Giphy/Tenor)
  - Socket event:
    - `message-delivered`, `message-read`
    - Typing “đang gửi ảnh…”
- 🟡 Frontend:
  - Thanh công cụ trong composer (ảnh/GIF/sticker)
  - Preview trước khi gửi, thanh tiến trình upload
  - Tab “Media” trong ChatScreen
  - Push notification cho media

Hiện tại phần này mới ở mức **thiết kế + stubs**; chưa triển khai full backend/frontend.

---

### 7. Settings & UX

- ✅ Màn Settings:
  - Thông tin app (version, link, policy…)
  - Theme (light/dark/system)
  - Ngôn ngữ cơ bản
  - Text scale
  - Logout
- 🟡 Xoá tài khoản / tạm khoá tài khoản
- ⏳ Trung tâm trợ giúp, báo cáo bug trực tiếp từ app

---

### 8. Kế hoạch tiếp theo (ngắn hạn)

1. Hoàn thiện **chat media** (backend + frontend).
2. Bổ sung **proxy GIF** + UI chọn GIF/sticker.
3. Ổn định push notification:
   - Match mới
   - Tin nhắn mới (text + media)
4. Dọn dẹp & script:
   - Script kiểm tra và sửa swipe/match/chatroom bất thường.
   - Script migrate dữ liệu khi thay đổi schema.
5. Viết thêm test:
   - Unit test cho recommendation, user.service, chat.service.
   - Widget test cho Discover & Chat.


