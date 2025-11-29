# BÁO CÁO KỸ THUẬT TỔNG QUAN DỰ ÁN PHẦN MỀM: ỨNG DỤNG HẸN HÒ VÀ KẾT NỐI XÃ HỘI "MATCHA"

**Người thực hiện:** [Tên của bạn]  
**Vai trò:** Nhóm phát triển phần mềm  
**Ngày báo cáo:** [Ngày tháng năm]

---

## 1. Tổng quan Dự án (Project Overview)

### 1.1. Tính cấp thiết của đề tài
Trong kỷ nguyên số hóa, nhu cầu kết nối và tìm kiếm các mối quan hệ xã hội thông qua nền tảng di động đang gia tăng theo cấp số nhân. Tuy nhiên, các giải pháp hiện có thường gặp vấn đề về:
*   **Độ trễ trong tương tác thực (Real-time latency):** Việc nhắn tin và thông báo tương thích (match) thường không tức thời.
*   **Thuật toán gợi ý kém hiệu quả:** Thiếu sự cá nhân hóa dựa trên vị trí địa lý và sở thích sâu.
*   **Trải nghiệm người dùng (UX):** Quy trình thiết lập hồ sơ phức tạp, thiếu tính trực quan.

Dự án **Matcha** được xây dựng nhằm giải quyết các vấn đề trên bằng việc áp dụng các công nghệ hiện đại nhất trong phát triển ứng dụng đa nền tảng và xử lý dữ liệu thời gian thực.

### 1.2. Phạm vi và Mục tiêu
*   **Mục tiêu kỹ thuật:** Xây dựng hệ thống có khả năng chịu tải tốt, đảm bảo tính toàn vẹn dữ liệu và bảo mật thông tin người dùng.
*   **Mục tiêu nghiệp vụ:** Cung cấp một nền tảng hoàn chỉnh cho phép người dùng Đăng ký, Thiết lập hồ sơ chi tiết, Khám phá (Discovery) người dùng khác qua cơ chế Swipe, và Trò chuyện (Chat) thời gian thực khi có tương thích (Match).

---

## 2. Kiến trúc Hệ thống (System Architecture)

### 2.1. Mô hình kiến trúc
Hệ thống được thiết kế dựa trên mô hình **Client-Server** kết hợp với **Layered Architecture** (Kiến trúc phân tầng) tại phía Backend. Đây là mô hình tiêu chuẩn trong kỹ thuật phần mềm giúp đảm bảo nguyên lý **Separation of Concerns** (Phân tách mối quan tâm).

*   **Client Side (Mobile App):** Sử dụng Flutter Framework, áp dụng mô hình quản lý trạng thái tập trung (State Management).
*   **Server Side (Backend):** Xây dựng theo mô hình 3-Layer (Controller - Service - Repository) trên nền tảng Node.js.

### 2.2. Sơ đồ khối các thành phần (Block Diagram Description)

```mermaid
graph TD
    Client[Mobile App (Flutter)] -->|REST API / HTTPS| LB[API Gateway / Web Server]
    Client -->|WebSocket / WSS| Socket[Socket.IO Service]
    
    subgraph "Backend System (Node.js)"
        LB --> Controller[Controllers Layer]
        Controller --> Service[Services Layer]
        Service --> Repo[Repositories Layer]
        Socket --> Service
    end
    
    Repo -->|Query/Aggregation| DB[(MongoDB Cluster)]
    Service -->|Auth| Firebase[Firebase Auth Service]
    Service -->|Media| Storage[Cloud Storage]
```

### 2.3. Công nghệ triển khai và Vai trò

*   **Frontend (Mobile):** 
    *   **Flutter & Dart:** Đảm bảo hiệu năng native trên cả Android và iOS.
    *   **Riverpod:** Quản lý trạng thái (State Management), giúp tách biệt logic nghiệp vụ khỏi giao diện (UI), tăng khả năng test và bảo trì.
    *   **GoRouter:** Quản lý điều hướng (Navigation) phức tạp và Deep linking.
*   **Backend (API Server):**
    *   **Node.js & Express:** Xử lý các request bất đồng bộ (Non-blocking I/O), phù hợp với ứng dụng cần I/O cao như mạng xã hội.
    *   **Socket.io:** Thiết lập kênh giao tiếp hai chiều (Bi-directional) cho tính năng Chat thời gian thực.
*   **Database (Cơ sở dữ liệu):**
    *   **MongoDB:** NoSQL Database, phù hợp để lưu trữ dữ liệu hồ sơ người dùng với schema linh hoạt và hỗ trợ tốt các truy vấn địa lý (`2dsphere index` cho tính năng tìm quanh đây).

---

## 3. Cơ chế Hoạt động & Liên kết Chức năng (Operational Flow & Functional Coupling)

Hệ thống được phân rã thành các module độc lập nhưng có sự liên kết chặt chẽ về mặt dữ liệu.

### 3.1. Phân rã chức năng (Functional Decomposition)
1.  **Module Authentication:** Quản lý định danh, phân quyền, tích hợp Firebase Auth và JWT session.
2.  **Module User Profile:** Quản lý thông tin cá nhân, sở thích, ảnh, và vị trí địa lý.
3.  **Module Discovery (Core):** Thuật toán tìm kiếm ứng viên dựa trên bộ lọc (Filter) và vị trí.
4.  **Module Interaction:** Xử lý hành động Like, Pass, Super Like và logic Matching.
5.  **Module Communication:** Xử lý tin nhắn, phòng chat (Chat Room) và trạng thái online/offline.

### 3.2. Luồng dữ liệu điển hình (Data Flow Example)
**Kịch bản:** Người dùng thực hiện hành động "Cập nhật vị trí và Tìm kiếm ứng viên quanh đây".

1.  **Presentation Layer (Frontend):** 
    *   User cấp quyền vị trí hoặc chọn tỉnh/thành.
    *   `ProfileSetupScreen` gọi `UserRepository.updateLocation()`.
2.  **Controller Layer (Backend):** 
    *   `UserController` nhận request, validate dữ liệu đầu vào (input validation).
3.  **Service Layer (Backend):**
    *   `UserService` chuẩn hóa dữ liệu tọa độ (GeoJSON format).
    *   Gọi `UserRepository` để cập nhật DB.
    *   Sau khi cập nhật thành công, hệ thống tự động kiểm tra tính hoàn thiện hồ sơ (`checkProfileComplete`) và set cờ `isProfileComplete = true`.
4.  **Repository Layer (Backend):**
    *   Thực hiện lệnh `findOneAndUpdate` xuống MongoDB.
5.  **Discovery Flow (Tiếp nối):**
    *   Frontend gọi API `GET /discovery`.
    *   Backend sử dụng toán tử `$near` và `$geoWithin` của MongoDB để tìm user trong bán kính `maxDistance`.
    *   Kết quả trả về được lọc (Filter) theo tuổi, giới tính và loại bỏ những người đã tương tác (Swiped).

### 3.3. Sự tương tác giữa các module
Các module giao tiếp thông qua **Dependency Injection** tại Service Layer.
*   *Ví dụ:* Khi module `Interaction` ghi nhận một "Match", nó sẽ gọi sang module `Communication` để khởi tạo một `ChatRoom` mới cho hai người dùng. Điều này đảm bảo tính nhất quán: Có Match mới được Chat.

---

## 4. Điểm nhấn Kỹ thuật & Học thuật (Technical Highlights)

### 4.1. Tối ưu hóa Truy vấn Địa lý (Geospatial Query Optimization)
*   Hệ thống sử dụng **Spatial Indexing** (Chỉ mục không gian) của MongoDB.
*   Thay vì tính toán khoảng cách bằng công thức Haversine thủ công tại tầng ứng dụng (gây chậm), hệ thống đẩy việc tính toán xuống tầng Database Engine, giảm độ phức tạp thuật toán từ O(N) xuống O(logN).

### 4.2. Kiến trúc 3 Lớp (3-Layer Architecture)
Việc áp dụng triệt để mô hình **Controller - Service - Repository** giúp mã nguồn đạt được:
*   **Maintainability (Tính bảo trì):** Thay đổi Database không ảnh hưởng đến Business Logic.
*   **Testability (Tính kiểm thử):** Dễ dàng viết Unit Test cho Service bằng cách Mock Repository.

### 4.3. Xử lý Bất đồng bộ và Race Conditions
*   Sử dụng `async/await` trong toàn bộ luồng xử lý I/O.
*   Xử lý vấn đề **Race Condition** trong luồng tạo hồ sơ: Sử dụng `StreamController` ở Frontend để lắng nghe thay đổi trạng thái từ Backend ngay lập tức, ngăn chặn việc điều hướng (Routing) sai khi dữ liệu chưa đồng bộ.

---

## 5. Kết quả Thực hiện & Trạng thái Hệ thống (Implementation Status & Results)

### 5.1. Bảng tổng hợp chức năng (Completed Modules)

| Module | Chức năng | Trạng thái | Input/Output chính |
| :--- | :--- | :--- | :--- |
| **Auth** | Đăng ký/Đăng nhập (Email, Google) | ✅ Hoàn tất | Email, Token / JWT, User Session |
| **Profile** | Thiết lập hồ sơ, Upload ảnh, Geolocation | ✅ Hoàn tất | Images, Coordinates / User Object |
| **Discovery** | Gợi ý user, Filter (Tuổi, Vị trí) | ✅ Hoàn tất | Filters / List<User> (Sorted) |
| **Matches** | Xử lý Like/Pass, Logic Match | ✅ Hoàn tất | TargetUserId / Match Status |
| **Chat** | Nhắn tin thời gian thực | ✅ Hoàn tất | Message Content / Socket Event |

### 5.2. Mức độ đáp ứng yêu cầu
Hệ thống đã hoàn thành **100% các chức năng cốt lõi (MVP)**. Ứng dụng hoạt động ổn định trên môi trường giả lập và thiết bị thực. Các luồng nghiệp vụ phức tạp như "Đăng ký -> Setup Profile -> Discovery -> Match -> Chat" đã được kiểm chứng thông suốt.

### 5.3. Kịch bản kiểm thử Demo (Demo Scenario)
Để chứng minh tính hoạt động của hệ thống trước hội đồng, kịch bản sau sẽ được thực hiện:
1.  **User A (Máy 1):** Đăng ký tài khoản mới, điền thông tin, upload ảnh và chọn vị trí Hà Nội. -> Hệ thống chuyển hướng vào trang chủ (Discovery).
2.  **User B (Máy 2):** Đang ở Hà Nội, mở App, thiết lập bộ lọc tìm kiếm. -> Hệ thống hiển thị User A trong danh sách gợi ý.
3.  **Tương tác:** Cả User A và User B cùng thực hiện thao tác "Like" nhau.
4.  **Kết quả:** Màn hình hiển thị thông báo "It's a Match!". Hệ thống tự động tạo phòng chat. User A nhắn "Xin chào", User B nhận tin nhắn ngay lập tức (Real-time).

---
*Hết báo cáo.*

