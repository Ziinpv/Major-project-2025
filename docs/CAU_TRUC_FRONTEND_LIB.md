# CẤU TRÚC FRONTEND/LIB - MATCHA DATING APP
## Giải thích chi tiết toàn bộ file và nhiệm vụ

**Ngày:** 2025  
**Kiến trúc:** Clean Architecture (Flutter + Riverpod)

---

## 📋 TỔNG QUAN

Dự án Flutter được tổ chức theo **Clean Architecture** với 3 tầng chính:
- **`core/`**: Tầng cơ sở (infrastructure, config, utilities)
- **`data/`**: Tầng dữ liệu (models, repositories, providers)
- **`presentation/`**: Tầng giao diện (screens, widgets)

---

## 🗂️ CẤU TRÚC CHI TIẾT

### 📁 **`main.dart`** - Điểm khởi đầu (Entry Point)

**Nhiệm vụ:**
- Khởi tạo ứng dụng Flutter
- Setup Firebase, Notification Service
- Cấu hình Riverpod ProviderScope (quản lý state toàn app)
- Khởi tạo Router (điều hướng màn hình)
- Setup Theme, Language, Text Scale

**Code chính:**
```dart
void main() async {
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(ProviderScope(child: MatchaApp()));
}
```

---

## 🔧 **`core/`** - Tầng Cơ Sở (Infrastructure Layer)

Chứa các thành phần cơ bản, dùng chung cho toàn bộ app.

### 📂 **`core/config/`** - Cấu hình

#### **`app_config.dart`**
- **Nhiệm vụ:** Chứa các hằng số cấu hình toàn app
- **Nội dung:**
  - `baseUrl`: Địa chỉ Backend API (VD: `http://localhost:3000/api`)
  - `wsUrl`: Địa chỉ WebSocket (VD: `ws://localhost:3000`)
  - `apiTimeout`: Thời gian chờ API (30 giây)
- **Ví dụ:**
```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'ws://localhost:3000';
  static const Duration apiTimeout = Duration(seconds: 30);
}
```

#### **`router.dart`**
- **Nhiệm vụ:** Định nghĩa tất cả các route (đường dẫn) trong app
- **Sử dụng:** GoRouter (package điều hướng)
- **Routes chính:**
  - `/auth/login` → LoginScreen
  - `/auth/register` → RegisterScreen
  - `/home` → HomeScreen (tab navigation)
  - `/discovery` → DiscoveryScreen
  - `/matches` → MatchesScreen
  - `/chat/:chatRoomId` → ChatScreen
  - `/profile` → ProfileScreen
- **Route Guards:** Kiểm tra đăng nhập, profile đã hoàn thiện chưa

---

### 📂 **`core/services/`** - Dịch vụ cơ sở

#### **`api_service.dart`**
- **Nhiệm vụ:** Lớp wrapper cho HTTP requests (dùng package Dio)
- **Chức năng:**
  - Tự động thêm JWT token vào header mọi request
  - Xử lý lỗi 401 (Unauthorized) → Xóa token, redirect login
  - Retry logic khi mất mạng
  - Logging requests/responses
- **Methods:**
  - `get(url, queryParams)` - GET request
  - `post(url, data)` - POST request
  - `put(url, data)` - PUT request
  - `delete(url)` - DELETE request
- **Ví dụ sử dụng:**
```dart
final api = ApiService();
final response = await api.get('/users/profile');
```

#### **`socket_service.dart`**
- **Nhiệm vụ:** Quản lý kết nối Socket.IO (real-time chat)
- **Chức năng:**
  - Kết nối/disconnect Socket.IO
  - Join/leave chat rooms
  - Gửi/nhận tin nhắn real-time
  - Typing indicators
  - Online/offline status
- **Methods:**
  - `connect()` - Kết nối với token
  - `disconnect()` - Ngắt kết nối
  - `sendMessage(roomId, content)` - Gửi tin nhắn
  - `on(event, handler)` - Lắng nghe sự kiện

#### **`notification_service.dart`**
- **Nhiệm vụ:** Xử lý Push Notifications (Firebase Cloud Messaging)
- **Chức năng:**
  - Request permission
  - Lấy FCM token
  - Xử lý notification khi app đang mở (foreground)
  - Xử lý notification khi app đóng (background)
  - Navigate đến màn hình phù hợp khi tap notification

---

### 📂 **`core/providers/`** - State Management (Toàn app)

#### **`app_theme_provider.dart`**
- **Nhiệm vụ:** Quản lý theme (Light/Dark mode)
- **State:** `ThemeMode` (light, dark, system)
- **Lưu trữ:** SharedPreferences (persist khi restart app)

#### **`language_provider.dart`**
- **Nhiệm vụ:** Quản lý ngôn ngữ (Tiếng Việt / English)
- **State:** `String` (vi, en)
- **Lưu trữ:** SharedPreferences

#### **`text_scale_provider.dart`**
- **Nhiệm vụ:** Quản lý kích thước chữ (accessibility)
- **State:** `double` (0.9x - 1.3x)

---

### 📂 **`core/extensions/`** - Mở rộng (Extensions)

#### **`localization_extension.dart`**
- **Nhiệm vụ:** Extension để dễ dàng truy cập translations
- **Ví dụ:**
```dart
// Thay vì: AppLocalizations.of(context)!.hello
// Dùng: context.l10n.hello
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

---

## 💾 **`data/`** - Tầng Dữ Liệu (Data Layer)

Chứa logic xử lý dữ liệu, giao tiếp với Backend.

### 📂 **`data/models/`** - Khuôn mẫu dữ liệu (Data Models)

**Nhiệm vụ:** Định nghĩa cấu trúc dữ liệu mà Backend trả về, chuyển đổi JSON ↔ Dart Object.

#### **`user_model.dart`** + **`user_model.g.dart`**
- **Mô tả:** Model đại diện cho User
- **Fields:**
  - `id`, `email`, `firstName`, `lastName`
  - `dateOfBirth`, `gender`, `bio`
  - `photos` (List<PhotoModel>)
  - `location` (LocationModel)
  - `interests`, `lifestyle` (List<String>)
  - `matchScore`, `distanceKm` (cho Discovery)
- **Methods:**
  - `fromJson(Map<String, dynamic>)` - Chuyển JSON → UserModel
  - `toJson()` - Chuyển UserModel → JSON
- **File `.g.dart`:** Code tự động generate bởi `json_serializable`

#### **`match_model.dart`** + **`match_model.g.dart`**
- **Mô tả:** Model đại diện cho Match (cặp đôi đã tương hợp)
- **Fields:**
  - `id`, `users` (List<UserModel>)
  - `matchedAt`, `lastMessage`, `lastMessageAt`
  - `isActive`

#### **`message_model.dart`** + **`message_model.g.dart`**
- **Mô tả:** Model đại diện cho tin nhắn chat
- **Fields:**
  - `id`, `content`, `type` (text/image)
  - `sender` (UserModel)
  - `createdAt`, `readAt`
  - `chatRoom` (ChatRoomModel)

#### **`chat_room_model.dart`** + **`chat_room_model.g.dart`**
- **Mô tả:** Model đại diện cho phòng chat
- **Fields:**
  - `id`, `participants` (List<UserModel>)
  - `lastMessage`, `lastMessageAt`
  - `unreadCount` (Map<userId, count>)

#### **`discovery_filters.dart`**
- **Mô tả:** Model chứa các bộ lọc Discovery
- **Fields:**
  - `ageMin`, `ageMax`
  - `maxDistance`
  - `showMe` (List<String> - giới tính)
  - `interests`, `lifestyle` (List<String>)
  - `onlyOnline`, `sort` (best/newest)

#### **`filter_option.dart`**
- **Mô tả:** Model cho một option trong filter (VD: Interest option, Lifestyle option)

---

### 📂 **`data/repositories/`** - Kho dữ liệu (Data Repositories)

**Nhiệm vụ:** Lớp trung gian giao tiếp với Backend API. Repository pattern giúp tách biệt logic gọi API khỏi UI.

#### **`auth_repository.dart`**
- **Nhiệm vụ:** Xử lý các API liên quan đến Authentication
- **Methods:**
  - `loginWithFirebase(firebaseToken)` → `POST /api/auth/firebase`
  - `getCurrentUser()` → `GET /api/auth/me`
  - `logout()` → Xóa token local

#### **`user_repository.dart`**
- **Nhiệm vụ:** Xử lý các API liên quan đến User
- **Methods:**
  - `getProfile()` → `GET /api/users/profile`
  - `updateProfile(data)` → `PATCH /api/users/profile`
  - `updateLocation(province, city)` → `PUT /api/users/location`
  - `getDiscovery(filters)` → `GET /api/discover`

#### **`swipe_repository.dart`**
- **Nhiệm vụ:** Xử lý các API liên quan đến Swipe
- **Methods:**
  - `swipe(userId, action)` → `POST /api/swipes`
  - `getSwipeHistory()` → `GET /api/swipes/history`

#### **`match_repository.dart`**
- **Nhiệm vụ:** Xử lý các API liên quan đến Match
- **Methods:**
  - `getMatches()` → `GET /api/matches`

#### **`chat_repository.dart`**
- **Nhiệm vụ:** Xử lý các API liên quan đến Chat
- **Methods:**
  - `getChatRooms()` → `GET /api/chat/rooms`
  - `getMessages(roomId)` → `GET /api/chat/rooms/:roomId/messages`
  - `markAsRead(roomId)` → `PUT /api/chat/rooms/:roomId/read`

---

### 📂 **`data/providers/`** - State Management (Business Logic)

**Nhiệm vụ:** Riverpod Providers quản lý state và business logic. Đây là "bộ não" của app, kết nối Repository với UI.

#### **`auth_provider.dart`**
- **Nhiệm vụ:** Quản lý trạng thái đăng nhập
- **State:** `AuthState` (isAuthenticated, user, token, isLoading, error)
- **Notifier:** `AuthNotifier`
- **Methods:**
  - `login(firebaseToken)` - Đăng nhập
  - `logout()` - Đăng xuất
  - `loadAuthState()` - Load token từ SharedPreferences khi khởi động app
- **Sử dụng:**
```dart
final authState = ref.watch(authProvider);
if (authState.isAuthenticated) {
  // User đã đăng nhập
}
```

#### **`user_provider.dart`**
- **Nhiệm vụ:** Quản lý thông tin user hiện tại
- **State:** `AsyncValue<UserModel?>` (có thể loading, error, data)
- **Methods:**
  - Tự động load profile khi cần
  - Refresh profile

#### **`match_provider.dart`**
- **Nhiệm vụ:** Quản lý danh sách matches
- **State:** `AsyncValue<List<MatchModel>>`
- **Methods:**
  - Load matches từ API
  - Refresh matches

#### **`chat_provider.dart`**
- **Nhiệm vụ:** Quản lý state chat (danh sách tin nhắn trong một room)
- **State:** `List<MessageModel>`
- **Methods:**
  - `setMessages(messages)` - Set danh sách tin nhắn
  - `appendMessage(message)` - Thêm tin nhắn mới
  - `clear()` - Xóa danh sách

#### **`discovery_filters_provider.dart`**
- **Nhiệm vụ:** Quản lý bộ lọc Discovery
- **State:** `DiscoveryFilters`
- **Lưu trữ:** SharedPreferences (persist khi restart app)
- **Methods:**
  - Update filters
  - Reset filters về mặc định

#### **`socket_connection_provider.dart`**
- **Nhiệm vụ:** Quản lý kết nối Socket.IO
- **Logic:** Tự động connect/disconnect dựa trên auth state
- **Khi user đăng nhập:** Tự động connect Socket
- **Khi user đăng xuất:** Tự động disconnect

#### **`online_status_provider.dart`**
- **Nhiệm vụ:** Quản lý danh sách user online
- **State:** `Set<String>` (Set of userIds)
- **Cập nhật:** Từ Socket.IO events (`user-online`, `user-offline`)

---

## 🎨 **`presentation/`** - Tầng Giao Diện (Presentation Layer)

Chứa UI, màn hình, widgets.

### 📂 **`presentation/screens/`** - Các màn hình

#### **`auth/`** - Màn hình xác thực

##### **`login_screen.dart`**
- **Nhiệm vụ:** Màn hình đăng nhập
- **Chức năng:**
  - Đăng nhập bằng Firebase (Google Sign-In)
  - Hiển thị loading, error
  - Navigate đến Home sau khi đăng nhập thành công

##### **`register_screen.dart`**
- **Nhiệm vụ:** Màn hình đăng ký
- **Chức năng:**
  - Tạo tài khoản mới
  - Validate form
  - Navigate đến Onboarding sau khi đăng ký

---

#### **`onboarding/`** - Màn hình hướng dẫn ban đầu

##### **`onboarding_screen.dart`**
- **Nhiệm vụ:** Màn hình hướng dẫn user mới
- **Chức năng:**
  - Giới thiệu app
  - Hướng dẫn cách sử dụng
  - Navigate đến Profile Setup

---

#### **`home/`** - Màn hình chính

##### **`home_screen.dart`**
- **Nhiệm vụ:** Màn hình chính với Bottom Navigation
- **Tabs:**
  1. **Discover** - Khám phá người dùng
  2. **Matches** - Danh sách match
  3. **Messages** - Danh sách chat
  4. **Profile** - Hồ sơ cá nhân
- **State Management:** Quản lý tab hiện tại

---

#### **`discovery/`** - Màn hình khám phá

##### **`discovery_screen.dart`**
- **Nhiệm vụ:** Màn hình chính để swipe người dùng
- **Chức năng:**
  - Load danh sách users từ API
  - Hiển thị SwipeCard (card có thể vuốt)
  - Xử lý swipe left (pass), right (like), up (superlike)
  - Hiển thị Match Dialog khi có match
  - Filter button (mở bottom sheet)

##### **`discovery_filter_sheet.dart`**
- **Nhiệm vụ:** Bottom sheet chứa các bộ lọc
- **Filters:**
  - Age range slider
  - Distance slider
  - Gender selection (multiple)
  - Interests selection
  - Lifestyle selection
  - Only online toggle
  - Sort options (best/newest)

##### **`discovery_filters.dart`**
- **Nhiệm vụ:** Widget hiển thị filters (có thể là helper widget)

---

#### **`matches/`** - Màn hình matches

##### **`matches_screen.dart`**
- **Nhiệm vụ:** Hiển thị danh sách những người đã match
- **Chức năng:**
  - Load matches từ API
  - Grid layout (2 cột)
  - Tap vào match → Navigate đến Chat
  - Empty state khi chưa có match

---

#### **`chat/`** - Màn hình chat

##### **`chat_list_screen.dart`**
- **Nhiệm vụ:** Danh sách các phòng chat
- **Chức năng:**
  - Load chat rooms từ API
  - Hiển thị: Avatar, tên, tin nhắn cuối, timestamp, unread badge
  - Tap vào room → Navigate đến ChatScreen
  - Pull to refresh

##### **`chat_screen.dart`**
- **Nhiệm vụ:** Màn hình chat chi tiết
- **Chức năng:**
  - Load messages từ API (pagination)
  - Hiển thị message bubbles (sent/received)
  - Input field để gửi tin nhắn
  - Real-time updates qua Socket.IO
  - Typing indicator
  - Read receipts (checkmarks)
  - Auto-scroll to bottom
  - Online status

---

#### **`profile/`** - Màn hình hồ sơ

##### **`profile_screen.dart`**
- **Nhiệm vụ:** Xem hồ sơ cá nhân
- **Chức năng:**
  - Hiển thị thông tin user (ảnh, tên, bio, interests, location...)
  - Edit button → Navigate đến EditProfileScreen
  - Settings button → Navigate đến SettingsScreen

##### **`profile_setup_screen.dart`**
- **Nhiệm vụ:** Màn hình setup hồ sơ lần đầu (onboarding)
- **Chức năng:**
  - Multi-step form (PageView)
  - Step 1: Gender, Date of Birth
  - Step 2: Photos (upload)
  - Step 3: Bio, Interests, Lifestyle
  - Step 4: Location (Province, City)
  - Submit → Tạo profile hoàn chỉnh

##### **`edit_profile_screen.dart`**
- **Nhiệm vụ:** Chỉnh sửa hồ sơ
- **Chức năng:**
  - Edit photos (reorder, delete, upload)
  - Edit bio, job, school
  - Edit interests, lifestyle
  - Edit location
  - Preview button (xem thử card profile)
  - Save button

##### **`edit_profile_controller.dart`**
- **Nhiệm vụ:** Controller (StateNotifier) quản lý state của EditProfileScreen
- **State:** `EditProfileState` (photos, bio, interests, isLoading, errors...)
- **Methods:**
  - `load()` - Load profile hiện tại
  - `updatePhoto()` - Upload/delete photo
  - `save()` - Lưu thay đổi

---

#### **`settings/`** - Màn hình cài đặt

##### **`settings_screen.dart`**
- **Nhiệm vụ:** Màn hình cài đặt app
- **Chức năng:**
  - Theme selection (Light/Dark/System)
  - Language selection (Vi/En)
  - Text scale adjustment
  - Change password dialog
  - Logout button
  - App info (version, links)

##### **`change_password_dialog.dart`**
- **Nhiệm vụ:** Dialog đổi mật khẩu
- **Chức năng:**
  - Form: Old password, New password, Confirm
  - Validate
  - Call API đổi mật khẩu

##### **`change_firebase_password_dialog.dart`**
- **Nhiệm vụ:** Dialog đổi mật khẩu Firebase (nếu dùng Firebase Auth)

---

### 📂 **`presentation/widgets/`** - Widgets tái sử dụng

#### **`swipe_card.dart`**
- **Nhiệm vụ:** Card có thể vuốt (swipeable card) hiển thị user
- **Chức năng:**
  - Hiển thị: Ảnh, tên, tuổi, location, interests, match score
  - Swipe gestures: Left (pass), Right (like), Up (superlike)
  - Animation khi swipe
  - Tap để xem chi tiết profile

#### **`chat_bubble.dart`**
- **Nhiệm vụ:** Widget hiển thị một tin nhắn (message bubble)
- **Chức năng:**
  - Phân biệt sent/received (màu sắc, alignment)
  - Hiển thị: Content, timestamp, read receipts
  - Styling khác nhau cho text/image

#### **`user_profile_detail_modal.dart`**
- **Nhiệm vụ:** Modal/Bottom sheet hiển thị chi tiết profile user
- **Chức năng:**
  - Hiển thị đầy đủ thông tin user
  - Ảnh gallery
  - Bio, interests, lifestyle
  - Location
  - Close button

---

## 🌐 **`l10n/`** - Đa ngôn ngữ (Localization)

**Nhiệm vụ:** Chứa các file dịch thuật (Tiếng Việt, English)

#### **`app_vi.arb`** + **`app_en.arb`**
- **Nhiệm vụ:** File định nghĩa translations (ARB format)
- **Nội dung:** Tất cả các chuỗi text trong app (buttons, labels, messages...)

#### **`app_localizations.dart`**
- **Nhiệm vụ:** Class chính để truy cập translations
- **Sử dụng:** `AppLocalizations.of(context)!.hello`

#### **`app_localizations_vi.dart`** + **`app_localizations_en.dart`**
- **Nhiệm vụ:** Code tự động generate từ `.arb` files
- **Chứa:** Các method trả về text theo ngôn ngữ

---

## 🔄 LUỒNG DỮ LIỆU TỔNG QUAN

```
User tương tác với UI (Screen)
    ↓
Screen gọi Provider (Riverpod)
    ↓
Provider gọi Repository
    ↓
Repository gọi ApiService
    ↓
ApiService gửi HTTP Request đến Backend
    ↓
Backend trả về JSON Response
    ↓
Repository parse JSON → Model (UserModel, MatchModel...)
    ↓
Provider cập nhật State
    ↓
UI tự động rebuild (reactive) → Hiển thị dữ liệu mới
```

---

## 📊 SƠ ĐỒ KIẾN TRÚC

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  ┌──────────┐  ┌──────────┐            │
│  │ Screens  │  │ Widgets  │            │
│  └────┬─────┘  └────┬─────┘            │
│       │             │                   │
│       └──────┬──────┘                   │
│              │                           │
│       ┌──────▼──────┐                   │
│       │  Providers  │ (Riverpod)        │
│       └──────┬──────┘                   │
└──────────────┼──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          DATA LAYER                     │
│  ┌──────────────┐  ┌──────────────┐    │
│  │ Repositories │  │   Models     │    │
│  └──────┬───────┘  └──────┬───────┘    │
│         │                  │            │
│         └────────┬─────────┘            │
│                  │                      │
│         ┌────────▼────────┐             │
│         │   ApiService    │             │
│         └────────┬────────┘             │
└──────────────────┼──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         CORE LAYER                      │
│  ┌──────────┐  ┌──────────┐            │
│  │ Config   │  │ Services │            │
│  │ Router   │  │ Socket   │            │
│  └──────────┘  └──────────┘            │
└─────────────────────────────────────────┘
```

---

## ✅ TÓM TẮT NHIỆM VỤ TỪNG THÀNH PHẦN

| Thành phần | Nhiệm vụ chính | Ví dụ |
|------------|----------------|-------|
| **`main.dart`** | Khởi tạo app | Setup Firebase, Router |
| **`core/config/`** | Cấu hình | API URL, Routes |
| **`core/services/`** | Dịch vụ cơ sở | HTTP Client, Socket.IO |
| **`core/providers/`** | State toàn app | Theme, Language |
| **`data/models/`** | Khuôn mẫu dữ liệu | UserModel, MatchModel |
| **`data/repositories/`** | Giao tiếp API | userRepository.getProfile() |
| **`data/providers/`** | State business logic | authProvider, matchProvider |
| **`presentation/screens/`** | Màn hình UI | LoginScreen, ChatScreen |
| **`presentation/widgets/`** | Widget tái sử dụng | SwipeCard, ChatBubble |
| **`l10n/`** | Đa ngôn ngữ | app_vi.arb, app_en.arb |

---

**Tài liệu được tạo bởi:** Code Analysis  
**Version:** 1.0  
**Ngày:** 2025

