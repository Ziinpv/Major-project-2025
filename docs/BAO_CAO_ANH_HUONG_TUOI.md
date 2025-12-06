# BÁO CÁO: ẢNH HƯỞNG CỦA TUỔI ĐẾN CÔNG THỨC TÍNH ĐIỂM
## Tuổi có ảnh hưởng như thế nào đến Matching Score?

**Ngày:** 2025  
**Files liên quan:**
- `backend/src/services/recommendation.service.js` (hàm `#calcAgeScore()`)
- `backend/src/repositories/user.repository.js` (filter theo tuổi)
- `backend/src/utils/constants.js` (trọng số AGE = 10)

---

## 📋 TÓM TẮT

**Tuổi có ảnh hưởng đến matching score theo 2 cách:**

1. **Hard Filter (Lọc cứng)**: Loại bỏ candidates ngoài khoảng tuổi trước khi tính điểm
2. **Soft Score (Điểm mềm)**: Tính điểm từ 0-10 dựa trên tuổi của candidate

---

## 🔍 1. HARD FILTER - LỌC THEO TUỔI

### **Vị trí:** `backend/src/repositories/user.repository.js` (dòng 132-141)

### **Mục đích:** 
Loại bỏ các candidates có tuổi ngoài khoảng `[ageMin, ageMax]` **TRƯỚC KHI** tính matching score.

### **Code:**
```javascript
const ageMin = filters.ageMin || currentUser.preferences?.ageRange?.min || DEFAULT_PREFERENCES.MIN_AGE;
const ageMax = filters.ageMax || currentUser.preferences?.ageRange?.max || DEFAULT_PREFERENCES.MAX_AGE;

if (ageMin || ageMax) {
  const today = new Date();
  // minBirthDate: oldest person (ageMax years old)
  const minBirthDate = new Date(today.getFullYear() - ageMax, today.getMonth(), today.getDate());
  // maxBirthDate: youngest person (ageMin years old)
  const maxBirthDate = new Date(today.getFullYear() - ageMin, today.getMonth(), today.getDate(), 23, 59, 59, 999);
  query.dateOfBirth = { $gte: minBirthDate, $lte: maxBirthDate };
}
```

### **Cách hoạt động:**

1. **Lấy khoảng tuổi:**
   - Ưu tiên: `filters.ageMin/ageMax` (từ request)
   - Nếu không có: Dùng `currentUser.preferences.ageRange`
   - Mặc định: `MIN_AGE = 18`, `MAX_AGE = 100`

2. **Tính ngày sinh:**
   - **minBirthDate**: Ngày sinh của người già nhất (ageMax tuổi)
   - **maxBirthDate**: Ngày sinh của người trẻ nhất (ageMin tuổi)

3. **Query MongoDB:**
   ```javascript
   query.dateOfBirth = { 
     $gte: minBirthDate,  // Greater than or equal
     $lte: maxBirthDate   // Less than or equal
   }
   ```

### **Ví dụ:**

**User A có preferences:**
```javascript
ageRange: { min: 25, max: 35 }
```

**MongoDB Query:**
```javascript
// Giả sử hôm nay là 2025-01-15
minBirthDate = 2025 - 35 = 1990-01-15  // Người 35 tuổi
maxBirthDate = 2025 - 25 = 2000-01-15 23:59:59  // Người 25 tuổi

query.dateOfBirth = {
  $gte: new Date('1990-01-15'),
  $lte: new Date('2000-01-15T23:59:59.999Z')
}
```

**Kết quả:**
- ✅ User 25-35 tuổi: **Được trả về** → Tiếp tục tính điểm
- ❌ User < 25 tuổi: **Bị loại** → Không xuất hiện trong discovery
- ❌ User > 35 tuổi: **Bị loại** → Không xuất hiện trong discovery

---

## 🎯 2. SOFT SCORE - TÍNH ĐIỂM THEO TUỔI

### **Vị trí:** `backend/src/services/recommendation.service.js` (dòng 84-96)

### **Mục đích:**
Tính điểm từ **0-10** dựa trên tuổi của candidate so với preferences của user.

### **Code:**
```javascript
#calcAgeScore(user, candidate) {
  const agePref = user.preferences?.ageRange;
  if (!agePref) return 0;
  
  const candidateAge = this.#calculateAge(candidate.dateOfBirth);
  if (!candidateAge) return 0;
  
  // Trường hợp 1: Tuổi trong khoảng [min, max]
  if (candidateAge >= agePref.min && candidateAge <= agePref.max) {
    return DISCOVERY_SCORE_WEIGHTS.AGE;  // 10 điểm
  }
  
  // Trường hợp 2: Tuổi ngoài khoảng
  const diff = candidateAge < agePref.min
    ? agePref.min - candidateAge      // Quá trẻ
    : candidateAge - agePref.max;      // Quá già
  
  // Điểm giảm dần: AGE - (diff × 2)
  return Math.max(0, DISCOVERY_SCORE_WEIGHTS.AGE - diff * 2);
}
```

### **Công thức:**

#### **Trường hợp 1: Tuổi trong khoảng [min, max]**
```
Age Score = 10 điểm (tối đa)
```

#### **Trường hợp 2: Tuổi ngoài khoảng**
```
diff = |candidateAge - ageRange|
Age Score = max(0, 10 - diff × 2)
```

**Lưu ý:** Điểm không bao giờ < 0 (Math.max đảm bảo)

---

## 📊 VÍ DỤ TÍNH TOÁN CHI TIẾT

### **Setup:**
```javascript
User A preferences:
  ageRange: { min: 25, max: 35 }

DISCOVERY_SCORE_WEIGHTS.AGE = 10
```

---

### **Ví dụ 1: Tuổi trong khoảng (Lý tưởng)**

**Candidate:** 28 tuổi

**Tính toán:**
```javascript
candidateAge = 28
agePref.min = 25
agePref.max = 35

// 28 >= 25 && 28 <= 35 → TRUE
// → Return 10 điểm
```

**Kết quả:** `Age Score = 10 điểm` ✅

---

### **Ví dụ 2: Tuổi bằng min**

**Candidate:** 25 tuổi

**Tính toán:**
```javascript
candidateAge = 25
// 25 >= 25 && 25 <= 35 → TRUE
// → Return 10 điểm
```

**Kết quả:** `Age Score = 10 điểm` ✅

---

### **Ví dụ 3: Tuổi bằng max**

**Candidate:** 35 tuổi

**Tính toán:**
```javascript
candidateAge = 35
// 35 >= 25 && 35 <= 35 → TRUE
// → Return 10 điểm
```

**Kết quả:** `Age Score = 10 điểm` ✅

---

### **Ví dụ 4: Tuổi quá trẻ (ngoài khoảng)**

**Candidate:** 23 tuổi (thiếu 2 tuổi)

**Tính toán:**
```javascript
candidateAge = 23
agePref.min = 25

// 23 < 25 → Quá trẻ
diff = 25 - 23 = 2
Age Score = max(0, 10 - 2 × 2) = max(0, 6) = 6 điểm
```

**Kết quả:** `Age Score = 6 điểm` ⚠️

---

### **Ví dụ 5: Tuổi quá già (ngoài khoảng)**

**Candidate:** 38 tuổi (thừa 3 tuổi)

**Tính toán:**
```javascript
candidateAge = 38
agePref.max = 35

// 38 > 35 → Quá già
diff = 38 - 35 = 3
Age Score = max(0, 10 - 3 × 2) = max(0, 4) = 4 điểm
```

**Kết quả:** `Age Score = 4 điểm` ⚠️

---

### **Ví dụ 6: Tuổi quá xa khoảng**

**Candidate:** 20 tuổi (thiếu 5 tuổi)

**Tính toán:**
```javascript
candidateAge = 20
agePref.min = 25

diff = 25 - 20 = 5
Age Score = max(0, 10 - 5 × 2) = max(0, 0) = 0 điểm
```

**Kết quả:** `Age Score = 0 điểm` ❌

---

### **Ví dụ 7: Tuổi rất xa khoảng**

**Candidate:** 45 tuổi (thừa 10 tuổi)

**Tính toán:**
```javascript
candidateAge = 45
agePref.max = 35

diff = 45 - 35 = 10
Age Score = max(0, 10 - 10 × 2) = max(0, -10) = 0 điểm
```

**Kết quả:** `Age Score = 0 điểm` ❌

---

## 🔄 LUỒNG XỬ LÝ TUỔI

```
User Request Discovery
    ↓
user.repository.js → findCandidatesForDiscovery()
    ↓
    ├─→ HARD FILTER: Lọc theo dateOfBirth
    │   ├─→ ageMin = 25
    │   ├─→ ageMax = 35
    │   └─→ Query: dateOfBirth trong [1990-01-15, 2000-01-15]
    │
    └─→ Chỉ trả về candidates 25-35 tuổi
        ↓
recommendation.service.js → computeScore()
    ↓
    └─→ #calcAgeScore()
        ├─→ Tính tuổi candidate từ dateOfBirth
        ├─→ So sánh với ageRange [25, 35]
        └─→ Trả về điểm: 0-10
```

---

## ⚠️ LƯU Ý QUAN TRỌNG

### **1. Hard Filter vs Soft Score**

**Câu hỏi:** Nếu đã filter ở repository, tại sao còn tính điểm ở service?

**Trả lời:**
- **Hard Filter** có thể không được áp dụng nếu:
  - User không có `preferences.ageRange`
  - Request không có `filters.ageMin/ageMax`
  - Filter bị bypass (edge cases)

- **Soft Score** đảm bảo:
  - Ngay cả khi candidate vượt qua filter, điểm vẫn phản ánh đúng độ phù hợp
  - Có thể có candidates ngoài khoảng tuổi nhưng vẫn được tính điểm (điểm thấp)

### **2. Tính tuổi chính xác**

**File:** `recommendation.service.js` (dòng 147-158)

```javascript
#calculateAge(date) {
  if (!date) return null;
  const dob = new Date(date);
  if (Number.isNaN(dob.getTime())) return null;
  const today = new Date();
  let age = today.getFullYear() - dob.getFullYear();
  const m = today.getMonth() - dob.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
    age--;  // Chưa đến sinh nhật năm nay
  }
  return age;
}
```

**Ví dụ:**
- Sinh nhật: `2000-06-15`
- Hôm nay: `2025-01-15`
- Tuổi: `2025 - 2000 = 25` nhưng chưa đến sinh nhật → `25 - 1 = 24 tuổi` ✅

---

## 📈 BẢNG ĐIỂM TUỔI

**Giả sử:** `ageRange: { min: 25, max: 35 }`

| Tuổi Candidate | So với khoảng | diff | Công thức | Age Score |
|----------------|---------------|------|-----------|-----------|
| 20 | Quá trẻ | 5 | max(0, 10 - 5×2) | **0** |
| 22 | Quá trẻ | 3 | max(0, 10 - 3×2) | **4** |
| 23 | Quá trẻ | 2 | max(0, 10 - 2×2) | **6** |
| 24 | Quá trẻ | 1 | max(0, 10 - 1×2) | **8** |
| **25** | **Trong khoảng** | 0 | 10 | **10** ✅ |
| **26** | **Trong khoảng** | 0 | 10 | **10** ✅ |
| **30** | **Trong khoảng** | 0 | 10 | **10** ✅ |
| **35** | **Trong khoảng** | 0 | 10 | **10** ✅ |
| 36 | Quá già | 1 | max(0, 10 - 1×2) | **8** |
| 37 | Quá già | 2 | max(0, 10 - 2×2) | **6** |
| 38 | Quá già | 3 | max(0, 10 - 3×2) | **4** |
| 40 | Quá già | 5 | max(0, 10 - 5×2) | **0** |

---

## 🎯 TÁC ĐỘNG ĐẾN TỔNG ĐIỂM

### **Trọng số:**
```javascript
DISCOVERY_SCORE_WEIGHTS = {
  INTERESTS: 40,    // 40%
  LIFESTYLE: 20,    // 20%
  DISTANCE: 20,     // 20%
  ACTIVITY: 10,     // 10%
  AGE: 10,          // 10% ← Tuổi chỉ chiếm 10%
}
```

### **Ví dụ tính tổng điểm:**

**Scenario 1: Tuổi lý tưởng (10 điểm)**
```
Interests: 30 điểm
Lifestyle: 15 điểm
Distance: 18 điểm
Activity: 8 điểm
Age: 10 điểm ← Tối đa
─────────────────────
Tổng: 81 điểm
Normalized: (81 / 100) × 100 = 81%
```

**Scenario 2: Tuổi ngoài khoảng (4 điểm)**
```
Interests: 30 điểm
Lifestyle: 15 điểm
Distance: 18 điểm
Activity: 8 điểm
Age: 4 điểm ← Giảm 6 điểm
─────────────────────
Tổng: 75 điểm
Normalized: (75 / 100) × 100 = 75%
```

**Chênh lệch:** `81% - 75% = 6%` (giảm 6% do tuổi)

---

## ✅ KẾT LUẬN

### **Tuổi có ảnh hưởng đến công thức tính điểm:**

1. ✅ **Hard Filter (Repository):**
   - Loại bỏ candidates ngoài khoảng tuổi trước khi tính điểm
   - File: `user.repository.js` (dòng 132-141)
   - Query MongoDB: `dateOfBirth: { $gte: minBirthDate, $lte: maxBirthDate }`

2. ✅ **Soft Score (Service):**
   - Tính điểm từ 0-10 dựa trên tuổi
   - File: `recommendation.service.js` (dòng 84-96)
   - Công thức:
     - Trong khoảng: `10 điểm`
     - Ngoài khoảng: `max(0, 10 - diff × 2)`

3. ✅ **Trọng số:**
   - Tuổi chiếm **10%** tổng điểm (10/100)
   - Ảnh hưởng vừa phải, không quyết định hoàn toàn

4. ✅ **Tính tuổi chính xác:**
   - Xét cả tháng và ngày sinh
   - File: `recommendation.service.js` (dòng 147-158)

---

**Báo cáo được tạo bởi:** Code Analysis  
**Version:** 1.0  
**Ngày:** 2025

