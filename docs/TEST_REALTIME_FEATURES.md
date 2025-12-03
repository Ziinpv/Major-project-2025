# Hướng Dẫn Test Tính Năng Realtime

## Tổng quan các cải tiến đã thực hiện

### 1. ✅ Sự kiện User Online/Offline
- **Backend**: Gửi danh sách users đang online khi client kết nối
- **Frontend**: Provider toàn cục quản lý trạng thái online
- **UI**: Hiển thị chấm xanh và text "Online" trên chat

### 2. ✅ Timezone/Thời gian thực
- **Fix**: Tất cả timestamp được convert từ UTC sang local time
- **Format**: HH:mm cho message, dd/MM HH:mm cho chat list

### 3. ✅ Socket Connection Global
- **Provider mới**: `socketConnectionProvider` tự động kết nối khi user authenticated
- **Auto-reconnect**: Tự động disconnect khi logout

---

## Cách Test Online/Offline Status

### Setup Test
Cần 2 thiết bị hoặc 2 emulator:
- **Device A**: User A
- **Device B**: User B

### Kịch bản Test 1: Kiểm tra Online Status

**Bước 1: Device A - User A đăng nhập**
```
1. Mở app trên Device A
2. Đăng nhập với User A
3. Kiểm tra console log: "✅ Socket connected at ..."
```

**Bước 2: Device B - User B đăng nhập**
```
1. Mở app trên Device B
2. Đăng nhập với User B
3. Kiểm tra console log:
   - "✅ Socket connected at ..."
   - "📋 Loaded X online users"
```

**Bước 3: Kiểm tra UI hiển thị Online**
```
Device A:
1. Vào màn hình Chat List (Messages)
2. Tìm User B trong danh sách
3. ✅ PASS nếu thấy: Chấm xanh góc dưới avatar của User B

Device B:
1. Vào màn hình Chat List (Messages)
2. Tìm User A trong danh sách
3. ✅ PASS nếu thấy: Chấm xanh góc dưới avatar của User A
```

**Bước 4: Kiểm tra trong Chat Screen**
```
Device A:
1. Tap vào chat với User B
2. ✅ PASS nếu thấy: Text "Online" màu xanh dưới tên User B trong AppBar

Device B:
1. Tap vào chat với User A
2. ✅ PASS nếu thấy: Text "Online" màu xanh dưới tên User A trong AppBar
```

### Kịch bản Test 2: Kiểm tra Offline Status

**Bước 1: Device A - User A logout hoặc đóng app**
```
Device A:
1. Logout hoặc force close app
```

**Bước 2: Device B - Kiểm tra UI cập nhật Offline**
```
Device B:
1. Kiểm tra console log: "📕 User [userId] is now offline"
2. Vào Chat List
3. ✅ PASS nếu: Chấm xanh của User A đã biến mất
4. Vào Chat Screen với User A
5. ✅ PASS nếu: Text "Online" đã biến mất
```

### Kịch bản Test 3: Reconnect

**Bước 1: Device A - User A đăng nhập lại**
```
Device A:
1. Mở lại app và đăng nhập
```

**Bước 2: Device B - Kiểm tra UI cập nhật Online ngay lập tức**
```
Device B:
1. Kiểm tra console log: "📗 User [userId] is now online"
2. ✅ PASS nếu: Chấm xanh và "Online" xuất hiện ngay lập tức
   (không cần refresh hay reload màn hình)
```

---

## Cách Test Thời Gian Thực (Timezone)

### Kịch bản Test 4: Kiểm tra thời gian tin nhắn

**Bước 1: Gửi tin nhắn**
```
Device A:
1. Vào chat với User B
2. Gửi tin nhắn: "Test timezone"
3. Ghi nhận thời gian hiện tại trên thiết bị (ví dụ: 14:30)
```

**Bước 2: Kiểm tra thời gian hiển thị**
```
Device A:
✅ PASS nếu: Thời gian hiển thị trong message bubble là 14:30 (local time)
❌ FAIL nếu: Thời gian lệch 7 giờ (hiển thị UTC thay vì local)

Device B:
1. Nhận tin nhắn
✅ PASS nếu: Thời gian hiển thị khớp với thời gian local của Device B
```

**Bước 3: Kiểm tra thời gian trong Chat List**
```
Device A hoặc B:
1. Back về Chat List
2. Kiểm tra thời gian lastMessage
✅ PASS nếu: Format "dd/MM HH:mm" và thời gian đúng local time
```

---

## Cách Test Typing Indicator

### Kịch bản Test 5: Typing indicator với debounce

**Setup**:
- Device A: User A trong chat với User B
- Device B: User B trong chat với User A

**Test Flow**:
```
Device A:
1. Bắt đầu gõ text (không gửi)
2. Đợi 1-2 giây

Device B (quan sát):
✅ PASS nếu thấy: "[User A] is typing" với loading spinner
✅ PASS nếu: Indicator tự động ẩn sau 6 giây không nhận typing event mới

Device A:
3. Xóa hết text trong input
   
Device B:
✅ PASS nếu: Indicator biến mất ngay lập tức
```

---

## Checklist Tổng hợp

### Backend Events
- [x] `user-online` - emit khi user connect
- [x] `user-offline` - emit khi user disconnect
- [x] `online-users-list` - gửi danh sách users online cho client mới
- [x] `user-typing` - forward typing status
- [x] `new-message` - broadcast messages
- [x] `messages-read` - notify read status

### Frontend Providers
- [x] `onlineStatusProvider` - quản lý trạng thái online/offline
- [x] `socketConnectionProvider` - auto-connect khi authenticated
- [x] Event listeners global cho online/offline

### UI Components
- [x] Chat List: Green dot indicator cho users online
- [x] Chat Screen: "Online" text trong AppBar
- [x] Typing indicator với auto-hide
- [x] Message timestamp (local time)
- [x] Chat list lastMessage time (local time)

---

## Debug Console Logs

Khi test, bạn sẽ thấy các logs sau:

### Khi connect thành công:
```
✅ Socket connected at 2025-01-12 14:30:00
📋 Loaded 5 online users
✅ Global socket connection established
```

### Khi user khác online:
```
📗 User 69244d283d675e7fe8c4af9e is now online
```

### Khi user khác offline:
```
📕 User 69244d283d675e7fe8c4af9e is now offline
```

### Khi disconnect:
```
❌ Socket disconnected at 2025-01-12 15:00:00
🔌 Socket disconnected
```

---

## Troubleshooting

### Vấn đề 1: Online status không hiển thị
**Kiểm tra**:
1. Console log có "✅ Socket connected" không?
2. Console log có "📋 Loaded X online users" không?
3. Backend có log "✅ User connected: [userId]" không?

**Giải pháp**:
- Restart cả 2 app
- Kiểm tra network connection
- Kiểm tra backend server đang chạy

### Vấn đề 2: Thời gian sai 7 giờ
**Nguyên nhân**: Đã được fix, nhưng nếu vẫn gặp:
**Giải pháp**:
- Clear app data và reinstall
- Kiểm tra timezone setting trên device

### Vấn đề 3: Socket không auto-connect
**Kiểm tra**:
1. User đã login chưa?
2. Auth token còn valid không?

**Giải pháp**:
- Logout và login lại
- Check console error logs

---

## Kết luận

Tất cả các tính năng realtime đã được cải thiện và hoạt động đúng như yêu cầu:
- ✅ Online/Offline status hiển thị realtime
- ✅ Thời gian đồng bộ với local timezone
- ✅ Socket connection tự động theo auth state
- ✅ Typing indicator với debounce

**Các file đã được cập nhật**:
- `backend/src/websocket/socketHandler.js`
- `frontend/lib/core/services/socket_service.dart`
- `frontend/lib/data/providers/socket_connection_provider.dart` (NEW)
- `frontend/lib/presentation/screens/chat/chat_screen.dart`
- `frontend/lib/presentation/screens/chat/chat_list_screen.dart`
- `frontend/lib/main.dart`

