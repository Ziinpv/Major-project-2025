# Matcha - Ứng dụng Hẹn hò & Chat

<div align="center">

![Matcha Logo](https://via.placeholder.com/200x200/E91E63/FFFFFF?text=Matcha)

**Ứng dụng hẹn hò hiện đại với tính năng khám phá thông minh và chat realtime**

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb)](https://www.mongodb.com/cloud/atlas)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)

</div>

---

## 📱 Giới thiệu

**Matcha** là ứng dụng hẹn hò được xây dựng với Flutter và Node.js, mang đến trải nghiệm tìm kiếm bạn đời hiện đại với:

- 🎯 **Khám phá thông minh**: Hệ thống gợi ý dựa trên sở thích, lifestyle, khoảng cách và độ tuổi
- 💬 **Chat realtime**: Nhắn tin tức thời với Socket.IO
- 📍 **Tìm kiếm theo vị trí**: Lọc người dùng theo khoảng cách địa lý
- 🎨 **UI/UX hiện đại**: Giao diện đẹp mắt, dễ sử dụng, thân thiện với người dùng

---

## ✨ Tính năng chính

### 🔐 Xác thực & Hồ sơ

- Đăng ký/Đăng nhập với Firebase Auth
- Đăng nhập bằng Google
- Quản lý hồ sơ: ảnh, bio, sở thích, lifestyle, công việc, học vấn
- Chỉnh sửa ảnh với drag & drop, tối đa 6 ảnh

### 🔍 Khám phá & Gợi ý

- **Smart Discovery**: Hệ thống tính điểm match dựa trên:
  - Sở thích chung (interests)
  - Lifestyle tương đồng
  - Độ tuổi phù hợp
  - Khoảng cách địa lý
  - Hoạt động gần đây
- **Bộ lọc nâng cao**:
  - Độ tuổi (min-max)
  - Khoảng cách (km)
  - Giới tính
  - Lifestyle
  - Sở thích
  - Chỉ hiển thị người đang online
- **Sắp xếp**: Phù hợp nhất / Mới nhất

### 👆 Swipe & Match

- Vuốt trái/phải/lên để pass/like/superlike
- Tự động tạo match khi cả hai cùng like
- Hiển thị match score (%)

### 💬 Chat Realtime

- Nhắn tin tức thời với Socket.IO
- Typing indicator
- Trạng thái tin nhắn: sent, delivered, read
- Xem tất cả media đã gửi
- Push notifications

### ⚙️ Cài đặt

- Chọn ngôn ngữ
- Chế độ dark/light
- Điều chỉnh font size
- Thông tin ứng dụng

---

## 📸 Screenshots

### Màn hình Đăng nhập & Đăng ký

<!-- Thay URL dưới đây bằng link ảnh chụp màn hình thực tế -->

![Login Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Login+Screen)
*Màn hình đăng nhập với Firebase Auth và Google Sign-In*

![Register Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Register+Screen)
*Màn hình đăng ký với form nhập thông tin*

### Màn hình Thiết lập Hồ sơ

![Profile Setup](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Profile+Setup)
*Quy trình thiết lập hồ sơ: upload ảnh, chọn giới tính, sở thích, vị trí*

### Màn hình Khám phá (Discover)

![Discover Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Discover+Screen)
*Màn hình khám phá với SwipeCard hiển thị tên, tuổi, vị trí và match score*

![Swipe Card](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Swipe+Card)
*Thẻ vuốt với ảnh profile, thông tin cơ bản và các nút action*

![Profile Detail Modal](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Profile+Detail)
*Modal chi tiết profile với carousel ảnh và thông tin đầy đủ*

![Discovery Filters](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Filters)
*Bộ lọc khám phá: độ tuổi, khoảng cách, giới tính, lifestyle, sở thích*

### Màn hình Match

![Matches Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Matches)
*Danh sách các match đã có*

### Màn hình Chat

![Chat List](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Chat+List)
*Danh sách các cuộc trò chuyện*

![Chat Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Chat+Screen)
*Màn hình chat với tin nhắn realtime, typing indicator*

### Màn hình Hồ sơ

![Profile Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Profile)
*Màn hình xem hồ sơ của bạn*

![Edit Profile](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Edit+Profile)
*Màn hình chỉnh sửa hồ sơ với drag & drop ảnh*

### Màn hình Cài đặt

![Settings Screen](https://via.placeholder.com/400x800/E91E63/FFFFFF?text=Settings)
*Màn hình cài đặt: ngôn ngữ, theme, font size*

---

## 🛠️ Tech Stack

### Frontend

- **Flutter** 3.22+ - Framework UI
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Socket.IO Client** - Realtime communication
- **Firebase**:
  - Firebase Auth (Google Sign-In)
  - Firebase Storage (upload ảnh)
  - Firebase Cloud Messaging (push notifications)
- **Cached Network Image** - Image loading & caching
- **Image Picker** - Chọn ảnh từ gallery

### Backend

- **Node.js** 18+ - Runtime
- **Express.js** - Web framework
- **MongoDB** + **Mongoose** - Database & ODM
- **Socket.IO** - Realtime server
- **Firebase Admin SDK** - Xác thực Firebase token
- **JWT** - Authentication tokens
- **Winston** - Logging
- **Multer** - File upload handling

### Infrastructure

- **MongoDB Atlas** - Cloud database
- **Firebase** - Authentication, Storage, Messaging

---

## 📋 Yêu cầu hệ thống

- **Node.js**: >= 18
- **npm**: >= 9
- **Flutter SDK**: >= 3.22
- **MongoDB**: MongoDB Atlas (khuyến nghị) hoặc MongoDB local
- **Firebase Account**: Để sử dụng Firebase Auth, Storage, Messaging
- **Android Studio** / **Xcode**: Để build mobile app

---

## 🚀 Cài đặt & Chạy

### 1. Clone repository

```bash
git clone <repository-url> matcha
cd matcha
```

### 2. Backend Setup

```bash
cd backend
npm install
```

Tạo file `.env` trong thư mục `backend/`:



Chạy backend:

```bash
npm run dev  # Development mode với nodemon
# hoặc
npm start    # Production mode
```

Backend sẽ chạy tại `http://localhost:3000`

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
```

Cấu hình Firebase:

- Copy file `google-services.json` vào `frontend/android/app/`
- Cấu hình iOS nếu cần (xem [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup))

Chạy app:

```bash
flutter run
```

### 4. Seed dữ liệu (tùy chọn)

```bash
cd backend
npm run seed
```

---

## 📁 Cấu trúc dự án

```
matcha/
├── backend/                 # Node.js Backend
│   ├── src/
│   │   ├── config/         # Database, Firebase config
│   │   ├── controllers/    # Route controllers
│   │   ├── middleware/     # Auth, error handling, validation
│   │   ├── models/         # Mongoose schemas
│   │   ├── repositories/  # Data access layer
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── utils/          # Utilities, constants
│   │   ├── websocket/      # Socket.IO handlers
│   │   └── scripts/        # Database scripts
│   └── package.json
│
├── frontend/                # Flutter Frontend
│   ├── lib/
│   │   ├── core/           # Services, providers, config
│   │   ├── data/           # Models, repositories, providers
│   │   └── presentation/   # Screens, widgets
│   ├── assets/             # Images, data files
│   └── pubspec.yaml
│
└── docs/                    # Documentation
    ├── SETUP.md
    ├── API.md
    ├── DATABASE.md
    └── PROJECT_COMPLETE.md
```

---

## 📚 API Documentation

Xem chi tiết tại [docs/API.md](docs/API.md)

### Endpoints chính:

- **Auth**: `/api/auth/login/firebase`, `/api/auth/register/firebase`
- **Users**: `/api/users/profile`, `/api/users/profile/photos`, `/api/users/location`
- **Discover**: `/api/discover` (với query params: ageMin, ageMax, distance, lifestyle, interests, showMe, onlyOnline, sort)
- **Swipes**: `/api/swipes` (POST)
- **Matches**: `/api/matches`
- **Chat**: `/api/chat/rooms`, `/api/chat/rooms/:roomId/messages`
- **Upload**: `/api/upload/image`

---

## 🔌 Socket.IO Events

### Client → Server:

- `join-chat-rooms` - Join tất cả chat rooms của user
- `join-chat-room` - Join một chat room cụ thể
- `leave-chat-room` - Rời chat room
- `send-message` - Gửi tin nhắn
- `typing` - Typing indicator
- `mark-read` - Đánh dấu đã đọc

### Server → Client:

- `new-message` - Tin nhắn mới
- `message-delivered` - Tin nhắn đã được gửi
- `message-read` - Tin nhắn đã được đọc
- `user-typing` - User đang gõ
- `user-stopped-typing` - User dừng gõ

---

## 🧪 Testing

### Backend

```bash
cd backend
npm test
```

### Frontend

```bash
cd frontend
flutter test
```

---

## 📝 Scripts hữu ích

### Backend

- `npm run seed` - Seed dữ liệu mẫu
- `node src/scripts/normalize_coordinates.js` - Chuẩn hóa tọa độ cho user cũ
- `node src/scripts/update_coordinates.js <userId> <lng> <lat>` - Cập nhật tọa độ cho user

---

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

- **Your Name** - *Initial work*

---

## 🙏 Acknowledgments

- Flutter team
- Firebase team
- MongoDB Atlas
- Tất cả các contributors của các packages open source được sử dụng

---

## 📞 Liên hệ

- **Email**: your.email@example.com
- **GitHub**: [@yourusername](https://github.com/yourusername)

---

<div align="center">

**Made with ❤️ using Flutter & Node.js**

</div>
