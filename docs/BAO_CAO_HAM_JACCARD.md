# BÁO CÁO: HÀM TÍNH JACCARD SIMILARITY
## Tính độ trùng lặp sở thích và lối sống

**Ngày:** 2025  
**File:** `backend/src/services/recommendation.service.js`

---

## 📋 TỔNG QUAN

Dự án sử dụng **Jaccard Similarity (Modified)** để tính độ trùng lặp giữa:
- **Interests** (Sở thích) của 2 users
- **Lifestyle** (Lối sống) của 2 users

---

## 🔍 HÀM TÍNH JACCARD

### **`#calcOverlapScore()`** - Hàm chính

**File:** `backend/src/services/recommendation.service.js`  
**Dòng:** 74-82  
**Access modifier:** `#` (Private method - chỉ dùng trong class)

#### **Signature:**
```javascript
#calcOverlapScore(listA = [], listB = [], weight = 20)
```

#### **Tham số:**
- `listA`: Danh sách thứ nhất (VD: `currentUser.interests`)
- `listB`: Danh sách thứ hai (VD: `candidate.interests`)
- `weight`: Trọng số tối đa (VD: 40 cho Interests, 20 cho Lifestyle)

#### **Code đầy đủ:**
```javascript
#calcOverlapScore(listA = [], listB = [], weight = 20) {
  // 1. Kiểm tra input hợp lệ
  if (!Array.isArray(listA) || !Array.isArray(listB) || 
      listA.length === 0 || listB.length === 0) {
    return { points: 0 };
  }
  
  // 2. Tạo Set từ listB để lookup nhanh (O(1))
  const setB = new Set(listB);
  
  // 3. Tìm phần tử chung (intersection)
  const overlap = listA.filter(item => setB.has(item));
  
  // 4. Tính denominator: max(|A|, |B|)
  const denominator = Math.max(listA.length, listB.length);
  
  // 5. Tính điểm: (overlap / denominator) * weight
  return { points: Math.min(weight, (overlap.length / denominator) * weight) };
}
```

---

## 📐 CÔNG THỨC JACCARD (MODIFIED)

### Công thức chuẩn Jaccard:
```
J(A, B) = |A ∩ B| / |A ∪ B|
```

### Công thức trong dự án (Modified):
```
S = (|A ∩ B| / max(|A|, |B|)) × weight
```

**Khác biệt:**
- **Chuẩn Jaccard:** Mẫu số là `|A ∪ B|` (hợp của 2 tập)
- **Modified:** Mẫu số là `max(|A|, |B|)` (tập lớn hơn)
- **Lý do:** Đơn giản hóa, vẫn phản ánh độ tương đồng tốt

---

## 🎯 CÁCH SỬ DỤNG

### 1. Tính Interests Score

**File:** `recommendation.service.js` (dòng 12-18)

```javascript
const interestScore = this.#calcOverlapScore(
  currentUser.interests,      // listA
  candidate.interests,         // listB
  DISCOVERY_SCORE_WEIGHTS.INTERESTS  // weight = 40
);
score += interestScore.points;
breakdown.interests = interestScore.points;
```

**Ví dụ:**
- User A: `['travel', 'music', 'coffee', 'photography', 'cooking']` (5 items)
- User B: `['music', 'coffee', 'gaming']` (3 items)
- Chung: `['music', 'coffee']` (2 items)
- Denominator: `max(5, 3) = 5`
- Score: `(2 / 5) × 40 = 16` điểm

---

### 2. Tính Lifestyle Score

**File:** `recommendation.service.js` (dòng 20-26)

```javascript
const lifestyleScore = this.#calcOverlapScore(
  currentUser.lifestyle,      // listA
  candidate.lifestyle,         // listB
  DISCOVERY_SCORE_WEIGHTS.LIFESTYLE  // weight = 20
);
score += lifestyleScore.points;
breakdown.lifestyle = lifestyleScore.points;
```

**Ví dụ:**
- User A: `['fitness', 'early-bird', 'pet-lover']` (3 items)
- User B: `['fitness', 'night-owl']` (2 items)
- Chung: `['fitness']` (1 item)
- Denominator: `max(3, 2) = 3`
- Score: `(1 / 3) × 20 ≈ 6.67` điểm

---

## 🔢 VÍ DỤ TÍNH TOÁN CHI TIẾT

### Ví dụ 1: Interests Overlap

**Input:**
```javascript
listA = ['travel', 'music', 'coffee', 'photography', 'cooking']  // 5 items
listB = ['music', 'coffee', 'gaming']                            // 3 items
weight = 40
```

**Bước 1: Tạo Set từ listB**
```javascript
setB = new Set(['music', 'coffee', 'gaming'])
```

**Bước 2: Tìm phần tử chung**
```javascript
overlap = listA.filter(item => setB.has(item))
// overlap = ['music', 'coffee']  // 2 items
```

**Bước 3: Tính denominator**
```javascript
denominator = Math.max(5, 3) = 5
```

**Bước 4: Tính điểm**
```javascript
points = (2 / 5) × 40 = 16
```

**Kết quả:** `{ points: 16 }`

---

### Ví dụ 2: Lifestyle Overlap

**Input:**
```javascript
listA = ['fitness', 'early-bird', 'pet-lover']  // 3 items
listB = ['fitness', 'night-owl']                // 2 items
weight = 20
```

**Bước 1: Tạo Set**
```javascript
setB = new Set(['fitness', 'night-owl'])
```

**Bước 2: Tìm phần tử chung**
```javascript
overlap = ['fitness']  // 1 item
```

**Bước 3: Tính denominator**
```javascript
denominator = Math.max(3, 2) = 3
```

**Bước 4: Tính điểm**
```javascript
points = (1 / 3) × 20 ≈ 6.67
```

**Kết quả:** `{ points: 6.67 }`

---

### Ví dụ 3: Trùng lặp 100%

**Input:**
```javascript
listA = ['travel', 'music', 'coffee']  // 3 items
listB = ['travel', 'music', 'coffee']   // 3 items
weight = 40
```

**Tính toán:**
- `overlap = ['travel', 'music', 'coffee']` (3 items)
- `denominator = max(3, 3) = 3`
- `points = (3 / 3) × 40 = 40`

**Kết quả:** `{ points: 40 }` (điểm tối đa)

---

### Ví dụ 4: Không có phần tử chung

**Input:**
```javascript
listA = ['travel', 'music']     // 2 items
listB = ['gaming', 'reading']   // 2 items
weight = 40
```

**Tính toán:**
- `overlap = []` (0 items)
- `denominator = max(2, 2) = 2`
- `points = (0 / 2) × 40 = 0`

**Kết quả:** `{ points: 0 }`

---

### Ví dụ 5: Một trong hai list rỗng

**Input:**
```javascript
listA = ['travel', 'music']  // 2 items
listB = []                    // 0 items
weight = 40
```

**Tính toán:**
- Kiểm tra: `listB.length === 0` → **Return ngay**
- **Kết quả:** `{ points: 0 }`

---

## ⚙️ TỐI ƯU HÓA PERFORMANCE

### 1. Sử dụng Set thay vì Array

**Code:**
```javascript
const setB = new Set(listB);
const overlap = listA.filter(item => setB.has(item));
```

**Lý do:**
- **Set.has()**: O(1) - Lookup nhanh
- **Array.includes()**: O(n) - Phải duyệt toàn bộ
- **Khi listB có nhiều phần tử:** Set nhanh hơn đáng kể

**Ví dụ:**
- listB có 100 items
- Set: O(1) × 100 = O(100)
- Array.includes: O(100) × 100 = O(10,000)

---

### 2. Early Return

**Code:**
```javascript
if (!Array.isArray(listA) || !Array.isArray(listB) || 
    listA.length === 0 || listB.length === 0) {
  return { points: 0 };
}
```

**Lý do:**
- Tránh xử lý không cần thiết
- Trả về ngay nếu input không hợp lệ

---

## 📊 SO SÁNH: JACCARD CHUẨN vs MODIFIED

### Jaccard Chuẩn:
```
J(A, B) = |A ∩ B| / |A ∪ B|
```

**Ví dụ:**
- A = `['a', 'b', 'c']` (3 items)
- B = `['b', 'c', 'd']` (3 items)
- A ∩ B = `['b', 'c']` (2 items)
- A ∪ B = `['a', 'b', 'c', 'd']` (4 items)
- J = `2 / 4 = 0.5`

### Modified (Dự án):
```
S = |A ∩ B| / max(|A|, |B|)
```

**Ví dụ:**
- A = `['a', 'b', 'c']` (3 items)
- B = `['b', 'c', 'd']` (3 items)
- A ∩ B = `['b', 'c']` (2 items)
- max(|A|, |B|) = `max(3, 3) = 3`
- S = `2 / 3 ≈ 0.67`

**Kết luận:** Modified version cho điểm cao hơn một chút, nhưng vẫn phản ánh đúng độ tương đồng.

---

## 🎯 TRỌNG SỐ (WEIGHTS)

**File:** `backend/src/utils/constants.js` (dòng 82-88)

```javascript
DISCOVERY_SCORE_WEIGHTS: {
  INTERESTS: 40,    // 40 điểm (40%)
  LIFESTYLE: 20,    // 20 điểm (20%)
  DISTANCE: 20,     // 20 điểm (20%)
  ACTIVITY: 10,     // 10 điểm (10%)
  AGE: 10,          // 10 điểm (10%)
}
```

**Sử dụng:**
- **Interests:** `weight = 40` → Tối đa 40 điểm
- **Lifestyle:** `weight = 20` → Tối đa 20 điểm

---

## 🔄 LUỒNG GỌI HÀM

```
recommendation.service.js → computeScore()
    ↓
    ├─→ #calcOverlapScore(currentUser.interests, candidate.interests, 40)
    │       ↓
    │   Tính Interests Score (Jaccard)
    │
    └─→ #calcOverlapScore(currentUser.lifestyle, candidate.lifestyle, 20)
            ↓
        Tính Lifestyle Score (Jaccard)
```

---

## 📝 EDGE CASES

### 1. List rỗng
```javascript
listA = []
listB = ['music', 'coffee']
// → Return { points: 0 }
```

### 2. Không phải Array
```javascript
listA = null
listB = ['music']
// → Return { points: 0 }
```

### 3. Trùng lặp trong cùng list
```javascript
listA = ['music', 'music', 'coffee']  // Có duplicate
// → Set sẽ tự động loại bỏ duplicate
setB = new Set(['music', 'music', 'coffee'])
// → setB = Set(['music', 'coffee'])
```

**Lưu ý:** Model User có validation để đảm bảo không có duplicate (xem `User.js` dòng 256-258).

---

## ✅ KẾT LUẬN

**Hàm tính Jaccard:**
- ✅ **`#calcOverlapScore()`** - Hàm duy nhất tính Jaccard similarity
- **File:** `backend/src/services/recommendation.service.js` (dòng 74-82)
- **Sử dụng cho:** Interests (40 điểm) và Lifestyle (20 điểm)
- **Công thức:** Modified Jaccard = `|A ∩ B| / max(|A|, |B|) × weight`
- **Tối ưu:** Sử dụng Set để lookup O(1)

**Đặc điểm:**
- ✅ Đơn giản, dễ hiểu
- ✅ Performance tốt (Set lookup)
- ✅ Xử lý edge cases đầy đủ
- ✅ Phản ánh đúng độ tương đồng

---

**Báo cáo được tạo bởi:** Code Analysis  
**Version:** 1.0  
**Ngày:** 2025

