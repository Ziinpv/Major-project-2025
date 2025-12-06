# BÁO CÁO: API TỈNH THÀNH TRONG DỰ ÁN MATCHA

**Ngày kiểm tra:** 2025  
**Trạng thái:** ✅ Đã xác minh

---

## 📋 TÓM TẮT

**Kết luận:** Dự án **KHÔNG sử dụng API bên ngoài** để lấy danh sách tỉnh thành. Thay vào đó, dự án sử dụng **dữ liệu local** được lưu trữ trong các file JSON và JavaScript.

---

## 🔍 CHI TIẾT KIỂM TRA

### 1. Frontend - Danh sách Tỉnh/Thành phố

#### **File:** `frontend/assets/data/vn_locations.json`

**Mô tả:**
- File JSON chứa danh sách 63 tỉnh/thành phố Việt Nam
- Mỗi tỉnh/thành có danh sách các quận/huyện/thành phố trực thuộc
- Được đóng gói trong app (bundle assets), không cần internet để load

**Cấu trúc dữ liệu:**
```json
[
  {
    "province": "Hà Nội",
    "cities": [
      "Quận Ba Đình",
      "Quận Hoàn Kiếm",
      "Quận Đống Đa",
      ...
    ]
  },
  {
    "province": "TP. Hồ Chí Minh",
    "cities": [
      "Quận 1",
      "Quận 3",
      "Quận 5",
      ...
    ]
  },
  ...
]
```

**Số lượng:**
- 63 tỉnh/thành phố
- Mỗi tỉnh có 8-15 quận/huyện/thành phố

---

#### **File sử dụng:** `frontend/lib/presentation/screens/profile/profile_setup_screen.dart`

**Hàm load dữ liệu:**
```dart
Future<void> _loadProvinceCityData() async {
  try {
    // Load từ assets local, KHÔNG phải API
    final jsonString = await rootBundle.loadString('assets/data/vn_locations.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final parsed = jsonList.map((item) {
      return {
        'province': item['province'] as String,
        'cities': List<String>.from(item['cities'] as List),
      };
    }).toList();
    
    setState(() {
      _provinceCityData.clear();
      _provinceCityData.addAll(parsed);
      _isLocationDataLoading = false;
    });
  } catch (e) {
    // Error handling
  }
}
```

**Dòng code:** 66-99

**Cách sử dụng:**
- Được gọi trong `initState()` (dòng 56)
- Load dữ liệu từ assets bundle (offline)
- Parse JSON và lưu vào state `_provinceCityData`
- Hiển thị trong dropdown: Tỉnh/Thành phố và Thành phố/Quận/Thị xã

---

### 2. Backend - Tra cứu Tọa độ Tỉnh/Thành

#### **File:** `backend/src/utils/vietnam_coordinates.js`

**Mô tả:**
- File JavaScript chứa hardcoded tọa độ (longitude, latitude) của 63 tỉnh/thành phố
- Hàm `getCoordinates(provinceName)` để tra cứu tọa độ từ tên tỉnh
- Có logic normalize tên tỉnh (bỏ dấu, lowercase, loại bỏ tiền tố)

**Cấu trúc dữ liệu:**
```javascript
const VIETNAM_PROVINCE_COORDINATES = {
  'Hà Nội': [105.83416, 21.02776],
  'TP. Hồ Chí Minh': [106.66017, 10.76262],
  'Hải Phòng': [106.68809, 20.84491],
  'Đà Nẵng': [108.22083, 16.06778],
  // ... 63 tỉnh/thành
};
```

**Hàm tra cứu:**
```javascript
function getCoordinates(provinceName) {
  // 1. Normalize tên tỉnh (bỏ dấu, lowercase)
  const query = normalizeName(provinceName);
  
  // 2. Tìm khớp chính xác
  let found = NORMALIZED_INDEX.find((item) => item.norm === query);
  if (found) return found.coords;
  
  // 3. Tìm khớp tương đối (fuzzy match)
  found = NORMALIZED_INDEX.find(
    (item) => item.norm.includes(query) || query.includes(item.norm)
  );
  return found ? found.coords : null;
}
```

**Dòng code:** 99-115

---

#### **File sử dụng:** `backend/src/services/user.service.js`

**Hàm sử dụng:**
```javascript
const { getCoordinates } = require('../utils/vietnam_coordinates');

async updateLocation(userId, locationData) {
  // ...
  
  // Nếu client không gửi toạ độ, tra cứu theo tên tỉnh/thành
  if (!coordinates && locationData.province) {
    const lookedUp = getCoordinates(locationData.province);
    if (Array.isArray(lookedUp) && lookedUp.length === 2) {
      coordinates = [Number(lookedUp[0]), Number(lookedUp[1])];
    }
  }
  
  // ...
}
```

**Dòng code:** 344-350

**Mục đích:**
- Khi user chọn tỉnh/thành nhưng không có GPS coordinates
- Backend tự động tra cứu tọa độ trung tâm của tỉnh/thành
- Lưu vào MongoDB với format GeoJSON: `{ type: 'Point', coordinates: [lng, lat] }`

---

## 📊 SO SÁNH: API BÊN NGOÀI vs DỮ LIỆU LOCAL

| Tiêu chí | API Bên ngoài | Dữ liệu Local (Hiện tại) |
|----------|---------------|--------------------------|
| **Nguồn dữ liệu** | API server (Vietnam API, etc.) | File JSON/JS trong project |
| **Cần Internet** | ✅ Có | ❌ Không |
| **Tốc độ load** | Phụ thuộc network | ⚡ Nhanh (local) |
| **Cập nhật dữ liệu** | Tự động từ server | Phải update code |
| **Chi phí** | Có thể có phí | Miễn phí |
| **Offline support** | ❌ Không | ✅ Có |
| **Độ tin cậy** | Phụ thuộc server | ✅ Ổn định |

---

## ✅ KẾT LUẬN

### Dự án KHÔNG sử dụng API bên ngoài

**Lý do:**
1. ✅ **Offline support:** App hoạt động ngay cả khi không có internet
2. ✅ **Performance:** Load nhanh từ local assets
3. ✅ **Độ tin cậy:** Không phụ thuộc vào server bên ngoài
4. ✅ **Chi phí:** Không cần trả phí cho API service
5. ✅ **Đơn giản:** Không cần xử lý authentication, rate limiting

**Nhược điểm:**
- ⚠️ Phải cập nhật code khi có thay đổi địa giới hành chính
- ⚠️ Dữ liệu có thể không cập nhật real-time

---

## 📁 DANH SÁCH FILE LIÊN QUAN

### Frontend:
1. **`frontend/assets/data/vn_locations.json`**
   - Chứa danh sách 63 tỉnh/thành và quận/huyện
   - Được bundle vào app

2. **`frontend/lib/presentation/screens/profile/profile_setup_screen.dart`**
   - Load và hiển thị danh sách tỉnh/thành
   - Hàm: `_loadProvinceCityData()` (dòng 66-99)

3. **`frontend/lib/presentation/screens/profile/edit_profile_screen.dart`**
   - Có thể sử dụng cùng dữ liệu (cần kiểm tra)

### Backend:
1. **`backend/src/utils/vietnam_coordinates.js`**
   - Chứa tọa độ 63 tỉnh/thành
   - Hàm: `getCoordinates()` (dòng 99-115)

2. **`backend/src/services/user.service.js`**
   - Sử dụng `getCoordinates()` để tra cứu tọa độ
   - Hàm: `updateLocation()` (dòng 322-377)

---

## 🔧 CÁCH CẬP NHẬT DỮ LIỆU

### Nếu cần thêm/sửa tỉnh/thành:

**1. Frontend (`vn_locations.json`):**
```json
{
  "province": "Tên Tỉnh Mới",
  "cities": [
    "Quận/Huyện 1",
    "Quận/Huyện 2"
  ]
}
```

**2. Backend (`vietnam_coordinates.js`):**
```javascript
const VIETNAM_PROVINCE_COORDINATES = {
  // ...
  'Tên Tỉnh Mới': [longitude, latitude],
};
```

**3. Rebuild app:**
- Frontend: `flutter build apk/ios`
- Backend: Không cần restart (code đã có)

---

## 📝 GHI CHÚ

- Dữ liệu tỉnh/thành được hardcode, không phải từ API
- Có thể migrate sang API trong tương lai nếu cần:
  - Vietnam Administrative Units API
  - OpenStreetMap Nominatim API
  - Google Places API (có phí)

---

**Báo cáo được tạo bởi:** Code Analysis  
**Ngày:** 2025  
**Version:** 1.0

