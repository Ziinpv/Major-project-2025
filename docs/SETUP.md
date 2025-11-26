## Thiết lập môi trường dự án Matcha (Backend + Frontend)

Tài liệu này mô tả **ngắn gọn**, bằng tiếng Việt, cách chạy dự án Matcha trên máy local.

---

### 1. Yêu cầu hệ thống

- **Node.js**: >= 18
- **npm**: >= 9
- **MongoDB**:
  - Khuyến nghị: MongoDB Atlas (cloud)
  - Có thể dùng MongoDB local cho mục đích dev
- **Flutter SDK**: >= 3.22
- **Android Studio** / **Xcode** (nếu build mobile)
- Tài khoản **Firebase** cho:
  - Firebase Auth (Google/Firebase login)
  - Firebase Cloud Messaging
  - Firebase Storage

---

### 2. Clone source

```bash
git clone <repo-url> matcha
cd matcha
```

> Trong tài liệu này, giả sử thư mục gốc là `E:\Matcha`.

---

### 3. Thiết lập Backend

#### 3.1 Cài dependency

```bash
cd backend
npm install
```

#### 3.2 Tạo file `.env`

Tạo file `backend/.env` (tham khảo cấu trúc từ hướng dẫn kết nối backend) với các biến tối thiểu:

```env
NODE_ENV=development
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

MONGODB_URI=mongodb+srv://<user>:<password>@<cluster>/<db>?retryWrites=true&w=majority

FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com

CORS_ORIGIN=*
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=jpg,jpeg,png,webp
```

#### 3.3 Chạy backend

```bash
cd backend
npm run dev
```

Backend sẽ chạy tại `http://localhost:3000`.

Có thể kiểm tra nhanh:

- `GET http://localhost:3000/api/health`
- `GET http://localhost:3000/api/auth/me` với header `Authorization: Bearer <token>`

---

### 4. Thiết lập Frontend (Flutter)

#### 4.1 Cài dependency

```bash
cd frontend
flutter pub get
```

#### 4.2 Cấu hình API endpoint

Trong `frontend/lib/core/config/app_config.dart` (hoặc file cấu hình tương đương), đặt `baseUrl` trỏ về backend:

```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.1.228:3000/api'; // IP máy backend trong LAN
  static const Duration apiTimeout = Duration(seconds: 20);
}
```

Lưu ý:

- Dùng **IP LAN** thay vì `localhost` khi chạy trên thiết bị thật/giả lập Android.
- Đảm bảo firewall cho phép truy cập port 3000.

#### 4.3 Cấu hình Firebase

- Tạo project Firebase.
- Thêm app Android:
  - Bundle id: `com.example.matcha` (hoặc id đang dùng trong `android/app/build.gradle`).
  - Tải `google-services.json` bỏ vào `frontend/android/app/`.
- Bật:
  - Firebase Auth (Email/Password, Google, v.v. tuỳ nhu cầu)
  - Cloud Messaging
  - Storage

Chạy:

```bash
cd frontend
flutter run
```

---

### 5. Seed dữ liệu test (tùy chọn)

Để có sẵn user seed + dữ liệu swipe/match:

```bash
cd backend
node src/scripts/seed.js          # tạo users seed
node src/scripts/seed_swipes.js <userId>  # tạo swipes + matches quanh userId
```

> Nhớ đặt `MONGODB_URI` đúng trong `.env` trước khi chạy.

---

### 6. Trạng thái hiện tại của dự án

- ✅ Backend:
  - Auth JWT + Firebase token
  - Quản lý user/profile (ảnh, bio, job, school, interests, lifestyle)
  - API Discover với scoring (interests, lifestyle, khoảng cách, độ tuổi, hoạt động)
  - Chat realtime (Socket.IO), danh sách room, messages, unreadCount
  - Upload ảnh (Firebase Storage)
- ✅ Frontend:
  - Onboarding + đăng nhập bằng Firebase
  - Discover + bộ lọc (tuổi, giới tính, distance, lifestyle, interests, online-only, sort)
  - Matches + ChatList + ChatScreen (text)
  - Edit Profile (ảnh kéo thả, bio, job, school, interests, lifestyle) + preview
  - Settings: theme, language, text scale, thông tin app cơ bản
- ⏳ Đang phát triển:
  - Chat media nâng cao (ảnh/GIF/sticker, tab “Media” trong chat)
  - Tối ưu hoá push notification cho media / match / message


