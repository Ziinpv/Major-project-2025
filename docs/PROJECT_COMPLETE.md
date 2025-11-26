## Tổng quan tiến độ dự án Matcha

Tài liệu này tóm tắt **mức độ hoàn thành** của các phần trong hệ thống ở thời điểm hiện tại.

Ký hiệu:

- ✅ Hoàn thành & đã dùng trong app
- 🟡 Đang hoàn thiện / beta
- ⏳ Chưa làm hoặc chỉ mới ở mức thiết kế

---

### 1. Backend

- ✅ Cấu trúc dự án Express + Socket.IO + MongoDB
- ✅ Kết nối MongoDB + Firebase (Admin SDK)
- ✅ Hệ thống log (Winston) + request logger
- ✅ Auth:
  - Nhận Firebase token → tạo/lấy user → trả JWT
  - Middleware `authenticate` cho tất cả route /api/*
- ✅ User/Profile:
  - Schema mở rộng: photos, interests, lifestyle, job, school, preferences, location
  - API:
    - `GET /api/users/profile`
    - `PATCH /api/users/profile`
    - `PATCH /api/users/profile/photos`
    - `PUT /api/users/location`
- ✅ Discover:
  - Tính điểm recommendation (interests, lifestyle, age, activity, distance)
  - Lọc theo giới tính, tuổi, lifestyle, interests, online-only, khoảng cách
  - `GET /api/discover`
  - Defensive coding cho `$near` (không crash khi thiếu toạ độ)
  - Log kết quả vào `DiscoveryLog`
- ✅ Swipe / Match:
  - `POST /api/swipes`
  - Bảng `swipes`, `matches`, index unique 2 user
  - Tạo match + chatRoom tự động khi mutual like
  - Script `seed.js` & `seed_swipes.js`
- ✅ Chat:
  - Bảng `chatrooms`, `messages`
  - API:
    - `GET /api/chat/rooms`
    - `GET /api/chat/rooms/:roomId/messages`
    - `PUT /api/chat/rooms/:roomId/read`
  - Socket.IO:
    - join-chat-rooms, join-chat-room, leave-chat-room
    - send-message, typing, mark-read
  - Fix các lỗi:
    - Duplicate message do REST + socket
    - Serialize ObjectId (ChatRoom, Match…)
    - unreadCount format
- ✅ Upload ảnh:
  - `POST /api/upload/image` → Firebase Storage
- 🟡 Upload media chat (`/api/upload/chat-media`)
- 🟡 Proxy GIF (`/api/chat/gifs`)

---

### 2. Frontend (Flutter)

- ✅ App shell:
  - Navigation (GoRouter)
  - Tabs: Discover, Matches, Messages, Profile
  - Theme + localization + text scale (Riverpod providers)
- ✅ Auth & Onboarding:
  - Đăng nhập Firebase → gọi backend để lấy JWT
  - Lưu token vào `SharedPreferences`
  - Onboarding cơ bản
- ✅ Discover:
  - Hiển thị danh sách user theo `GET /api/discover`
  - Hiển thị:
    - Ảnh chính, tên, tuổi, city/province
    - Interests (tối đa 3 chip)
    - Match Score % + thanh progress
    - Distance (km) nếu có
  - Bộ lọc (bottom sheet):
    - Tuổi, giới tính, distance
    - Interests, lifestyle (tối đa 5 mỗi loại)
    - Only show online
    - Sort: best/newest
  - Lưu filter vào `SharedPreferences`, tự áp dụng lại khi mở app
  - Banner khuyến khích hoàn thiện hồ sơ
- ✅ Swipe:
  - Button like / pass / superlike
  - Dialog “It’s a match!” khi được match
  - Fix crash setState sau dispose
- ✅ Matches:
  - Grid các match, hiển thị avatar + tên đầy đủ
  - Chạm để mở Chat
- ✅ Chat:
  - ChatList theo `GET /api/chat/rooms`
  - ChatScreen theo `GET /api/chat/rooms/:roomId/messages`
  - Gửi tin nhắn text (REST + socket)
  - Realtime nhận tin nhắn mới, typing, đọc tin
  - Fix duplicate tin nhắn (logic `_pendingLocalIds`)
- ✅ Profile:
  - Màn Profile + Edit Profile:
    - Quản lý ảnh (reorder, xóa, upload)
    - Bio, công việc, trường học
    - Interests + lifestyle với giới hạn 5
    - Preview card
  - Lưu thông tin & ảnh qua API mới
- ✅ Settings:
  - Thông tin app (version cơ bản)
  - Theme, language, text scale
  - Logout
- 🟡 UI/UX:
  - Media trong chat (ảnh/GIF/sticker)
  - Tab “Media” trong chat
  - Push notification nội dung media

---

### 3. Tài liệu & DevOps

- ✅ Tài liệu tiếng Việt:
  - `docs/SETUP.md`: hướng dẫn chạy dự án local
  - `docs/HUONG_DAN_KET_NOI_BACKEND.md`: cấu hình MongoDB + Firebase
  - `docs/API.md`: tóm tắt endpoint chính
  - `docs/DATABASE.md`: schema CSDL
  - `docs/PROJECT_ROADMAP.md`: roadmap chi tiết
- 🟡 Tài liệu triển khai production (CI/CD, monitoring…)
- ⏳ Script migrate / rollback tự động cho các thay đổi schema lớn

---

### 4. Đánh giá hiện tại

- **Có thể demo trọn luồng**:
  - Đăng nhập → cập nhật hồ sơ → Discover → Swipe → Match → Chat text.
- **Phù hợp cho dev / demo nội bộ**:
  - Hầu hết core flow hoạt động ổn, đã xử lý nhiều bug edge cases.
- **Cần làm thêm để production**:
  - Media chat đầy đủ
  - Push notification hoàn chỉnh
  - Nâng cấp bảo mật, logging, monitoring, backup DB
  - Làm sạch & chuẩn hoá data seed / script admin.


