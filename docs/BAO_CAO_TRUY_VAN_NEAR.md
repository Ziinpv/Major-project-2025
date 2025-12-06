# BÁO CÁO: HÀM TRUY VẤN $NEAR (GEOSPATIAL QUERY)
## Gợi ý người dùng dựa trên vị trí địa lý

**Ngày:** 2025  
**Database:** MongoDB với 2dsphere Index

---

## 📋 TỔNG QUAN

Dự án sử dụng **MongoDB Geospatial Query** với operator `$near` để tìm kiếm người dùng trong một bán kính nhất định từ vị trí của user hiện tại.

---

## 🔍 HÀM TRUY VẤN $NEAR CHÍNH

### 1. **`findCandidatesForDiscovery()`** - Hàm chính

**File:** `backend/src/repositories/user.repository.js`  
**Dòng:** 118-208  
**Mục đích:** Tìm kiếm candidates (người dùng tiềm năng) cho Discovery feature dựa trên vị trí địa lý.

#### **Signature:**
```javascript
async findCandidatesForDiscovery(currentUser, excludeIds = [], filters = {})
```

#### **Tham số:**
- `currentUser`: User object hiện tại (cần có `location.coordinates`)
- `excludeIds`: Mảng các user IDs cần loại trừ (đã swipe, đã match...)
- `filters`: Object chứa các bộ lọc (ageMin, ageMax, maxDistance, showMe, lifestyle, interests, onlyOnline, sort)

#### **Logic truy vấn $near:**

**Bước 1: Kiểm tra điều kiện áp dụng $near**
```javascript
const coords = currentUser.location?.coordinates;
const hasValidCoordinates = Array.isArray(coords) && 
  coords.length === 2 && 
  coords.every(value => value !== null && value !== undefined && !Number.isNaN(Number(value)));

const maxDistance = filters.maxDistance !== undefined && filters.maxDistance !== null
  ? Number(filters.maxDistance)
  : (currentUser.preferences?.maxDistance || DEFAULT_PREFERENCES.MAX_DISTANCE);

const shouldApplyDistanceFilter = hasValidCoordinates && 
  maxDistance && 
  maxDistance > 0 && 
  maxDistance < 1000; // Nếu >= 1000km, coi như không giới hạn khoảng cách
```

**Bước 2: Áp dụng $near query (nếu điều kiện thỏa mãn)**
```javascript
if (shouldApplyDistanceFilter) {
  const [lng, lat] = coords.map((v) => Number(v));
  dbQuery = dbQuery.where({
    'location.coordinates': {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [lng, lat]  // [longitude, latitude]
        },
        $maxDistance: maxDistance * 1000  // Chuyển km → m (MongoDB dùng mét)
      }
    }
  });
}
```

#### **MongoDB Query đầy đủ:**
```javascript
User.find({
  _id: { $ne: currentUser._id, $nin: excludeIds },
  isActive: true,
  isProfileComplete: true,
  gender: { $in: showMe },
  dateOfBirth: { $gte: minBirthDate, $lte: maxBirthDate },
  'location.coordinates': {
    $near: {
      $geometry: {
        type: 'Point',
        coordinates: [lng, lat]
      },
      $maxDistance: maxDistance * 1000
    }
  }
})
.sort({ lastActive: -1 })
.limit(50)
```

#### **Điều kiện áp dụng $near:**
1. ✅ User hiện tại có `location.coordinates` hợp lệ (array [lng, lat])
2. ✅ `maxDistance` được set và > 0
3. ✅ `maxDistance` < 1000 km (nếu >= 1000km, coi như không giới hạn)

#### **Kết quả:**
- Trả về danh sách users trong bán kính `maxDistance` km từ vị trí `currentUser`
- Đã được sắp xếp theo khoảng cách (gần nhất trước)
- Kết hợp với các filters khác (age, gender, lifestyle, interests...)

---

## 📊 CÁC HÀM KHÁC (KHÔNG DÙNG $NEAR)

### 2. **`findNearbyUsers()`** - Tìm user gần đây (KHÔNG dùng $near)

**File:** `backend/src/repositories/user.repository.js`  
**Dòng:** 32-63  
**Mục đích:** Tìm user gần đây nhưng **KHÔNG sử dụng $near**, chỉ filter theo `province` và `city`.

**Query:**
```javascript
User.find({
  _id: { $ne: userId },
  isActive: true,
  isProfileComplete: true,
  'location.province': location.province,  // Filter theo tỉnh
  'location.city': location.city           // Filter theo thành phố
})
```

**Khác biệt:**
- ❌ Không dùng `$near` (không tính khoảng cách chính xác)
- ✅ Chỉ filter theo text (province, city)
- ⚠️ Có thể không chính xác (VD: cùng tỉnh nhưng cách xa 100km)

**Trạng thái:** Có thể là hàm cũ, ít được sử dụng.

---

### 3. **`findPotentialMatches()`** - Tìm match tiềm năng (KHÔNG dùng $near)

**File:** `backend/src/repositories/user.repository.js`  
**Dòng:** 65-116  
**Mục đích:** Tìm potential matches nhưng **KHÔNG sử dụng $near**, chỉ filter theo `province` và `city`.

**Query:**
```javascript
User.find({
  _id: { $ne: userId, $nin: excludeIds },
  isActive: true,
  isProfileComplete: true,
  gender: { $in: showMe },
  dateOfBirth: { $gte: minBirthDate, $lte: maxBirthDate },
  'location.province': user.location.province,
  'location.city': user.location.city
})
```

**Khác biệt:**
- ❌ Không dùng `$near`
- ✅ Có fallback: Nếu không tìm thấy user cùng location → Bỏ location filter

**Trạng thái:** Có thể là hàm cũ hoặc dùng cho mục đích khác.

---

## 🗄️ CẤU HÌNH DATABASE

### Index 2dsphere

**File:** `backend/src/models/User.js`  
**Dòng:** 87

```javascript
coordinates: {
  type: [Number],
  index: '2dsphere',  // Geospatial index
  validate: {
    validator: function(value) {
      if (!value || value.length === 0) return true;
      return Array.isArray(value) && value.length === 2 && 
        value.every(num => typeof num === 'number');
    },
    message: 'Coordinates must be an array [lng, lat]'
  }
}
```

**Mục đích:**
- Tăng tốc độ truy vấn `$near`
- Bắt buộc phải có index này mới dùng được `$near`

### Scripts tạo Index

#### **`create_geo_index.js`**
- **File:** `backend/src/scripts/create_geo_index.js`
- **Mục đích:** Script để tạo index 2dsphere thủ công
- **Command:**
```bash
node backend/src/scripts/create_geo_index.js
```

#### **`force_fix_discovery.js`**
- **File:** `backend/src/scripts/force_fix_discovery.js`
- **Mục đích:** Script để fix và tạo lại index 2dsphere

---

## 🔄 LUỒNG SỬ DỤNG

### Luồng gọi hàm:

```
User Request Discovery
    ↓
user.controller.js → getDiscovery()
    ↓
user.service.js → getDiscovery()
    ├─→ swipeRepository.getSwipedUserIds()  // Loại trừ đã swipe
    ├─→ parseDiscoveryFilters()              // Parse filters
    └─→ userRepository.findCandidatesForDiscovery()  // ⭐ HÀM CHÍNH
            ↓
        MongoDB Query với $near
            ↓
        Trả về candidates (đã sort theo khoảng cách)
            ↓
    recommendation.service.js → computeScore()  // Tính matching score
            ↓
    Sort theo score (nếu sort = 'best')
            ↓
    Return results
```

---

## 📝 VÍ DỤ CODE

### Hàm chính `findCandidatesForDiscovery()`:

```javascript
async findCandidatesForDiscovery(currentUser, excludeIds = [], filters = {}) {
  // 1. Build base query
  const query = {
    _id: { $ne: currentUser._id, $nin: excludeIds },
    isActive: true,
    isProfileComplete: true
  };

  // 2. Apply filters (gender, age, lifestyle, interests...)
  // ... filter logic ...

  let dbQuery = User.find(query);

  // 3. Determine maxDistance
  const maxDistance = filters.maxDistance ?? 
    currentUser.preferences?.maxDistance ?? 
    DEFAULT_PREFERENCES.MAX_DISTANCE;

  // 4. Check if should apply $near
  const coords = currentUser.location?.coordinates;
  const hasValidCoordinates = Array.isArray(coords) && 
    coords.length === 2 && 
    coords.every(v => !Number.isNaN(Number(v)));

  const shouldApplyDistanceFilter = hasValidCoordinates && 
    maxDistance && 
    maxDistance > 0 && 
    maxDistance < 1000;

  // 5. Apply $near query
  if (shouldApplyDistanceFilter) {
    const [lng, lat] = coords.map(v => Number(v));
    dbQuery = dbQuery.where({
      'location.coordinates': {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat]
          },
          $maxDistance: maxDistance * 1000  // km → m
        }
      }
    });
  }

  // 6. Sort và limit
  dbQuery = dbQuery.sort({ lastActive: -1 });
  return await dbQuery.limit(Math.min(filters.limit || 50, 100));
}
```

---

## ⚙️ CẤU HÌNH VÀ THAM SỐ

### Tham số $near:

| Tham số | Kiểu | Mô tả | Ví dụ |
|---------|------|-------|-------|
| **`$geometry`** | Object | Điểm địa lý (GeoJSON Point) | `{ type: 'Point', coordinates: [106.6297, 10.8231] }` |
| **`coordinates`** | Array[Number] | `[longitude, latitude]` | `[106.6297, 10.8231]` (Sài Gòn) |
| **`$maxDistance`** | Number | Khoảng cách tối đa (mét) | `50000` (50km) |

### Default values:

**File:** `backend/src/utils/constants.js`
```javascript
DEFAULT_PREFERENCES: {
  MAX_DISTANCE: 50,  // 50 km
}
```

### Format coordinates:

- **MongoDB GeoJSON:** `[longitude, latitude]` (lng trước, lat sau)
- **Ví dụ:** Sài Gòn = `[106.6297, 10.8231]`
- **Lưu ý:** Không phải `[lat, lng]`!

---

## 🎯 ĐIỀU KIỆN VÀ EDGE CASES

### Khi nào KHÔNG áp dụng $near:

1. **User không có coordinates:**
   - `currentUser.location.coordinates` = `null` hoặc `undefined`
   - → Bỏ qua distance filter, chỉ filter theo province/city (nếu có)

2. **maxDistance >= 1000 km:**
   - Coi như "không giới hạn khoảng cách"
   - → Bỏ qua $near query

3. **maxDistance = 0 hoặc null:**
   - → Không áp dụng $near

### Kết quả khi không có $near:

- Vẫn trả về users nhưng **không sort theo khoảng cách**
- Sort theo `lastActive` (mặc định) hoặc `createdAt` (nếu sort = 'newest')
- Khoảng cách sẽ được tính sau đó trong `recommendation.service.js` (Haversine formula)

---

## 📊 SO SÁNH: $NEAR vs HAVERSINE

| Tiêu chí | MongoDB $near | Haversine (JavaScript) |
|----------|---------------|------------------------|
| **Nơi tính toán** | Database (MongoDB) | Application (Node.js) |
| **Performance** | ⚡ Rất nhanh (có index) | ⚠️ Chậm hơn (tính cho từng user) |
| **Filter tại DB** | ✅ Có (chỉ trả về users trong bán kính) | ❌ Không (phải load tất cả rồi filter) |
| **Sort theo khoảng cách** | ✅ Tự động (gần nhất trước) | ❌ Phải sort thủ công |
| **Độ chính xác** | ⭐⭐⭐⭐⭐ Rất chính xác | ⭐⭐⭐⭐⭐ Rất chính xác |
| **Khi nào dùng** | Filter users trong bán kính | Tính khoảng cách cho matching score |

**Kết luận:** Dự án dùng **cả hai**:
- **$near:** Filter users trong bán kính (tại DB)
- **Haversine:** Tính khoảng cách chính xác cho matching score (tại Service)

---

## 🔧 DEBUG VÀ SCRIPT

### Scripts liên quan:

1. **`create_geo_index.js`**
   - Tạo index 2dsphere thủ công
   - Dùng khi index bị mất hoặc cần tạo lại

2. **`force_fix_discovery.js`**
   - Fix discovery issues
   - Tạo lại index 2dsphere

3. **`debug_missing_users.js`**
   - Debug tại sao user không xuất hiện trong discovery
   - Kiểm tra coordinates

4. **`debug_distance_filter.js`**
   - Debug distance filter
   - Test với các maxDistance khác nhau

5. **`normalize_coordinates.js`**
   - Chuẩn hóa coordinates (đảm bảo format đúng)

---

## 📋 BẢNG TÓM TẮT

| Hàm | File | Dòng | Sử dụng $near? | Mục đích |
|-----|------|------|----------------|----------|
| **`findCandidatesForDiscovery()`** | `user.repository.js` | 118-208 | ✅ **CÓ** | Tìm candidates cho Discovery (hàm chính) |
| **`findNearbyUsers()`** | `user.repository.js` | 32-63 | ❌ Không | Tìm user gần đây (filter theo province/city) |
| **`findPotentialMatches()`** | `user.repository.js` | 65-116 | ❌ Không | Tìm potential matches (filter theo province/city) |

---

## ✅ KẾT LUẬN

**Hàm chính sử dụng $near:**
- ✅ **`findCandidatesForDiscovery()`** - Hàm duy nhất sử dụng `$near` operator
- Được gọi từ `user.service.js` → `getDiscovery()`
- Được sử dụng trong API `GET /api/discover`

**Các hàm khác:**
- ❌ `findNearbyUsers()` - Không dùng $near
- ❌ `findPotentialMatches()` - Không dùng $near

**Cấu hình:**
- ✅ Index 2dsphere trên `location.coordinates`
- ✅ Format: `[longitude, latitude]`
- ✅ Default maxDistance: 50 km

---

**Báo cáo được tạo bởi:** Code Analysis  
**Version:** 1.0  
**Ngày:** 2025

