## Hướng dẫn kết nối Backend Matcha (MongoDB + Firebase)

Tài liệu này dành cho việc **thiết lập backend** trên môi trường mới (máy dev khác, server test…).

---

### 1. Kết nối MongoDB

#### 1.1 Tạo cluster (MongoDB Atlas)

1. Vào `https://cloud.mongodb.com`, tạo project + cluster mới.
2. Tạo database user, nhớ ghi lại **username/password**.
3. Mở tab **Network Access**, thêm IP:
   - Dev: có thể dùng `0.0.0.0/0` (chỉ nên dùng trong môi trường test).
   - Hoặc IP tĩnh của máy dev.

#### 1.2 Lấy connection string

Trong Atlas:

1. Nhấn **Connect** → **Connect your application**.
2. Driver: `Node.js`, Version: `5.5 or later`.
3. Sao chép connection string, ví dụ:

```text
mongodb+srv://matcha-admin:<password>@matchacluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

4. Thay `<password>` và thêm tên database, ví dụ:

```text
mongodb+srv://matcha-admin:your-password@matchacluster.xxxxx.mongodb.net/matcha?retryWrites=true&w=majority
```

Đây sẽ là giá trị cho `MONGODB_URI`.

---

### 2. Cấu hình `.env` cho backend

Trong thư mục `backend/`, tạo file `.env`:

```env
NODE_ENV=development
PORT=3000

JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

MONGODB_URI=mongodb+srv://matcha-admin:your-password@matchacluster.xxxxx.mongodb.net/matcha?retryWrites=true&w=majority

FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com

CORS_ORIGIN=*
MAX_FILE_SIZE=5242880
ALLOWED_FILE_TYPES=jpg,jpeg,png,webp
```

Sau khi lưu `.env`, có thể test nhanh kết nối:

```bash
cd backend
node test-connection.js
```

Nếu mọi thứ đúng:

- `✅ MongoDB connected successfully!`
- `✅ Firebase initialized successfully!`

---

### 3. Chạy backend

```bash
cd backend
npm install
npm run dev
```

Mặc định backend chạy tại `http://localhost:3000`.

Kiểm tra:

- `GET http://localhost:3000/api/health`
- Nếu trả về:
  ```json
  { "status": "ok", "timestamp": "..." }
  ```
  là server đã sẵn sàng.

---

### 4. Kết nối từ frontend (Flutter)

Trong Flutter, file cấu hình (`AppConfig`) cần trỏ đúng IP:

```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.1.228:3000/api';
}
```

- Nếu chạy giả lập Android trên cùng máy: sử dụng IP LAN, **không dùng** `localhost`.
- Nếu dùng thiết bị thật:
  - Máy tính và điện thoại phải cùng mạng Wi-Fi.
  - Dùng `ipconfig` / `ifconfig` để lấy IP của máy tính.

---

### 5. Lỗi thường gặp

**1. `MongoDB error: bad auth`**

- Sai `MONGODB_URI` (username/password hoặc tên DB).
- User Atlas không có quyền trên database `matcha`.

**2. `MongoDB error: IP not allowed`**

- Quên add IP của máy dev vào Network Access.

**3. `Firebase error: Missing credentials`**

- Thiếu một trong các biến:
  - `FIREBASE_PROJECT_ID`
  - `FIREBASE_PRIVATE_KEY`
  - `FIREBASE_CLIENT_EMAIL`
- Private key không giữ lại `\n` đúng định dạng.

**4. Frontend không gọi được API / lỗi CORS**

- Kiểm tra `CORS_ORIGIN` trong `.env` (dev có thể dùng `*`).
- Kiểm tra IP + port trong `AppConfig.baseUrl`.

---

### 6. Trạng thái hiện tại

- ✅ Luồng kết nối MongoDB + Firebase đã hoạt động ổn định trong môi trường dev.
- ✅ Đã có script `test-connection.js` để kiểm tra nhanh.
- ✅ Backend đang được dùng thực tế bởi app Flutter (Discover, Matches, Chat…).
- ⏳ Production:
  - Cần thêm config riêng (biến môi trường, logging, giám sát, backup DB…).
  - Cân nhắc đổi `CORS_ORIGIN` thành domain cụ thể thay vì `*`.


