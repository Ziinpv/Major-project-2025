# Hệ thống Tính Điểm Phù Hợp (Matching Score System)
## Ứng dụng Hẹn hò - Matcha

---

## 📋 Tổng quan

Tài liệu này mô tả chi tiết **Logic và Công thức tính toán Matching Score** giữa User A (Người tìm kiếm) và User B (Ứng viên tiềm năng) trong hệ thống khuyến nghị của ứng dụng hẹn hò Matcha.

**Mục tiêu chính:**
- Đảm bảo độ chính xác cao trong việc khuyến nghị người dùng phù hợp
- Cân bằng giữa các yếu tố cá nhân (sở thích, lối sống) và yếu tố địa lý
- Tối ưu hóa trải nghiệm người dùng bằng cách ưu tiên người dùng hoạt động gần đây
- Xử lý hiệu quả trường hợp người dùng mới (Cold Start)

---

## 🔒 1. Hard Filters (Bộ lọc cứng)

Hard Filters là các điều kiện **BẮT BUỘC** phải thỏa mãn. Nếu User B không đáp ứng bất kỳ điều kiện nào, họ sẽ bị **loại ngay lập tức** khỏi danh sách khuyến nghị cho User A.

### 1.1. Bảng Hard Filters

| STT | Điều kiện | Mô tả | Giá trị mặc định | Ví dụ |
|-----|-----------|-------|------------------|-------|
| 1 | **Giới tính (Gender)** | User B phải thuộc danh sách giới tính mà User A quan tâm | `[]` (tất cả) | User A tìm `['female', 'non-binary']` → User B phải có `gender ∈ ['female', 'non-binary']` |
| 2 | **Khoảng cách địa lý** | Khoảng cách giữa User A và User B phải ≤ maxDistance | 50 km | User A đặt maxDistance = 30km → User B phải ở trong bán kính 30km |
| 3 | **Trạng thái tài khoản** | User B phải có `isActive = true` và `isProfileComplete = true` | - | Loại bỏ tài khoản bị khóa hoặc chưa hoàn thiện |
| 4 | **Chưa từng tương tác** | User A chưa swipe (like/pass) User B trước đó | - | Không hiển thị lại người đã swipe |
| 5 | **Không bị chặn/báo cáo** | User B không nằm trong danh sách chặn hoặc báo cáo của User A | - | Đảm bảo an toàn và trải nghiệm tích cực |

### 1.2. Logic Implementation

```javascript
function applyHardFilters(currentUser, candidates) {
  return candidates.filter(candidate => {
    // Filter 1: Gender preference
    const showMeList = currentUser.preferences?.showMe || [];
    if (showMeList.length > 0 && !showMeList.includes(candidate.gender)) {
      return false;
    }
    
    // Filter 2: Geographic distance
    const maxDistance = currentUser.preferences?.maxDistance || 50;
    const distance = calculateHaversineDistance(
      currentUser.location.coordinates,
      candidate.location.coordinates
    );
    if (distance > maxDistance) {
      return false;
    }
    
    // Filter 3: Account status
    if (!candidate.isActive || !candidate.isProfileComplete) {
      return false;
    }
    
    // Filter 4: Not swiped before
    if (hasSwipedBefore(currentUser._id, candidate._id)) {
      return false;
    }
    
    // Filter 5: Not blocked/reported
    if (isBlockedOrReported(currentUser._id, candidate._id)) {
      return false;
    }
    
    return true;
  });
}
```

### 1.3. Công thức Haversine (Tính khoảng cách địa lý)

Công thức Haversine được sử dụng để tính khoảng cách giữa hai điểm trên bề mặt Trái Đất:

$$
a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos(\phi_1) \cdot \cos(\phi_2) \cdot \sin^2\left(\frac{\Delta\lambda}{2}\right)
$$

$$
c = 2 \cdot \arctan2\left(\sqrt{a}, \sqrt{1-a}\right)
$$

$$
d = R \cdot c
$$

**Trong đó:**
- \( \phi_1, \phi_2 \): Vĩ độ (latitude) của User A và User B (rad)
- \( \lambda_1, \lambda_2 \): Kinh độ (longitude) của User A và User B (rad)
- \( \Delta\phi = \phi_2 - \phi_1 \)
- \( \Delta\lambda = \lambda_2 - \lambda_1 \)
- \( R = 6371 \) km (bán kính Trái Đất)
- \( d \): Khoảng cách (km)

---

## 🎯 2. Soft Preferences (Tính điểm tương đồng)

Sau khi vượt qua Hard Filters, mỗi User B sẽ được tính **Matching Score** dựa trên các yếu tố Soft Preferences. Điểm số này phản ánh mức độ phù hợp giữa hai người dùng.

### 2.1. Các yếu tố tính điểm

| STT | Yếu tố | Trọng số (w) | Mô tả | Công thức |
|-----|--------|--------------|-------|-----------|
| 1 | **Interests Overlap** | 40 | Độ trùng lặp sở thích | Jaccard Similarity |
| 2 | **Lifestyle Overlap** | 20 | Độ trùng lặp lối sống | Jaccard Similarity |
| 3 | **Distance Score** | 20 | Điểm khoảng cách (càng gần càng cao) | Linear decay |
| 4 | **Activity Score** | 10 | Mức độ hoạt động gần đây | Time-based decay |
| 5 | **Age Compatibility** | 10 | Độ phù hợp về tuổi tác | Range-based scoring |

**Tổng trọng số:** \( W_{total} = 40 + 20 + 20 + 10 + 10 = 100 \)

---

### 2.2. Chi tiết Logic tính từng yếu tố

#### **2.2.1. Interests Overlap Score** (\(S_{interests}\))

**Mục đích:** Đo lường mức độ trùng lặp giữa danh sách sở thích của User A và User B.

**Công thức Jaccard Similarity (Modified):**

$$
S_{interests} = w_{interests} \times \frac{|I_A \cap I_B|}{\max(|I_A|, |I_B|)}
$$

**Trong đó:**
- \( I_A \): Tập sở thích của User A
- \( I_B \): Tập sở thích của User B
- \( |I_A \cap I_B| \): Số lượng sở thích chung
- \( \max(|I_A|, |I_B|) \): Số lượng sở thích của người có nhiều sở thích hơn
- \( w_{interests} = 40 \)

**Ví dụ:**
- User A: `['travel', 'music', 'coffee', 'photography', 'cooking']` (5 items)
- User B: `['music', 'coffee', 'gaming']` (3 items)
- Chung: `['music', 'coffee']` (2 items)
- \( S_{interests} = 40 \times \frac{2}{5} = 16 \) điểm

**Lưu ý:** 
- Nếu một trong hai người không có sở thích nào → \( S_{interests} = 0 \)
- Tối đa: 40 điểm (khi trùng lặp 100%)

---

#### **2.2.2. Lifestyle Overlap Score** (\(S_{lifestyle}\))

**Mục đích:** Đo lường mức độ tương đồng về lối sống (lifestyle).

**Công thức:**

$$
S_{lifestyle} = w_{lifestyle} \times \frac{|L_A \cap L_B|}{\max(|L_A|, |L_B|)}
$$

**Trong đó:**
- \( L_A \): Tập lối sống của User A
- \( L_B \): Tập lối sống của User B
- \( w_{lifestyle} = 20 \)

**Ví dụ:**
- User A: `['fitness', 'early-bird', 'pet-lover']`
- User B: `['fitness', 'night-owl']`
- Chung: `['fitness']` (1 item)
- \( S_{lifestyle} = 20 \times \frac{1}{3} \approx 6.67 \) điểm

**Lifestyle Options:**
- `hiking`, `nightlife`, `vegan`, `pet-lover`, `early-bird`, `night-owl`, `minimalist`, `spiritual`, `fitness`, `traveling`, `family-oriented`, `career-focused`

---

#### **2.2.3. Distance Score** (\(S_{distance}\))

**Mục đích:** Ưu tiên người dùng ở gần hơn. Khoảng cách càng nhỏ, điểm càng cao.

**Công thức Linear Decay:**

$$
S_{distance} = \max\left(0, w_{distance} \times \left(1 - \frac{d}{d_{max}}\right)\right)
$$

**Trong đó:**
- \( d \): Khoảng cách thực tế giữa User A và User B (km)
- \( d_{max} \): Khoảng cách tối đa cho phép (từ preferences của User A)
- \( w_{distance} = 20 \)

**Ví dụ:**
- User A đặt \( d_{max} = 50 \) km
- User B cách User A \( d = 10 \) km
- \( S_{distance} = 20 \times \left(1 - \frac{10}{50}\right) = 20 \times 0.8 = 16 \) điểm

**Biểu đồ quan hệ:**
```
Distance (km)    Score
    0            20
   10            16
   25            10
   40             4
   50             0
```

**Đặc điểm:**
- Khoảng cách 0 km (cùng vị trí) → 20 điểm
- Khoảng cách = \( d_{max} \) → 0 điểm
- Giảm tuyến tính

---

#### **2.2.4. Activity Score** (\(S_{activity}\))

**Mục đích:** Ưu tiên người dùng đang hoạt động hoặc hoạt động gần đây (tăng khả năng match thành công).

**Công thức Time-based Decay:**

$$
S_{activity} = \begin{cases}
w_{activity} & \text{nếu } \Delta t \leq 1 \text{ ngày} \\
w_{activity} - 2 & \text{nếu } 1 < \Delta t \leq 7 \text{ ngày} \\
w_{activity} - 5 & \text{nếu } 7 < \Delta t \leq 14 \text{ ngày} \\
2 & \text{nếu } 14 < \Delta t \leq 30 \text{ ngày} \\
0 & \text{nếu } \Delta t > 30 \text{ ngày}
\end{cases}
$$

**Trong đó:**
- \( \Delta t \): Số ngày kể từ lần hoạt động cuối cùng của User B
- \( w_{activity} = 10 \)

**Bảng điểm:**

| Thời gian không hoạt động | Điểm |
|---------------------------|------|
| ≤ 1 ngày (Online gần đây) | 10 |
| 1-7 ngày (Tuần vừa rồi) | 8 |
| 7-14 ngày (2 tuần trước) | 5 |
| 14-30 ngày (Tháng trước) | 2 |
| > 30 ngày (Không hoạt động) | 0 |

**Lợi ích:**
- Tăng cơ hội match với người dùng đang online
- Giảm số lượng profile "ma" (inactive users)

---

#### **2.2.5. Age Compatibility Score** (\(S_{age}\))

**Mục đích:** Đánh giá mức độ phù hợp về độ tuổi dựa trên preferences của User A.

**Công thức Range-based Scoring:**

$$
S_{age} = \begin{cases}
w_{age} & \text{nếu } age_B \in [age_{min}, age_{max}] \\
\max(0, w_{age} - 2 \times |age_B - age_{nearest}|) & \text{nếu } age_B \notin [age_{min}, age_{max}]
\end{cases}
$$

**Trong đó:**
- \( age_B \): Tuổi của User B
- \( [age_{min}, age_{max}] \): Khoảng tuổi ưa thích của User A
- \( age_{nearest} \): Điểm gần nhất trong khoảng (nếu \( age_B < age_{min} \) thì \( age_{nearest} = age_{min} \), ngược lại \( age_{nearest} = age_{max} \))
- \( w_{age} = 10 \)

**Ví dụ 1:** User A preferences: 25-35 tuổi
- User B: 28 tuổi → \( S_{age} = 10 \) (trong khoảng)

**Ví dụ 2:** User A preferences: 25-35 tuổi
- User B: 40 tuổi → Chênh lệch: \( 40 - 35 = 5 \)
- \( S_{age} = \max(0, 10 - 2 \times 5) = 0 \)

**Ví dụ 3:** User A preferences: 25-35 tuổi
- User B: 23 tuổi → Chênh lệch: \( 25 - 23 = 2 \)
- \( S_{age} = \max(0, 10 - 2 \times 2) = 6 \)

**Đặc điểm:**
- Trong khoảng tuổi ưa thích → Điểm tối đa (10)
- Ngoài khoảng → Giảm 2 điểm cho mỗi năm chênh lệch
- Chênh lệch > 5 năm → 0 điểm

---

## ⚖️ 3. Weighting System (Hệ thống trọng số)

### 3.1. Bảng trọng số hiện tại

Bảng trọng số được thiết kế dựa trên nghiên cứu hành vi người dùng và A/B testing:

| Yếu tố | Trọng số (\(w\)) | Tỷ lệ (%) | Lý do |
|--------|------------------|-----------|-------|
| **Interests** | 40 | 40% | **Quan trọng nhất** - Sở thích chung tạo nền tảng cho cuộc trò chuyện và kết nối |
| **Lifestyle** | 20 | 20% | Lối sống tương đồng đảm bảo tương thích lâu dài |
| **Distance** | 20 | 20% | Khoảng cách địa lý quyết định khả năng gặp mặt thực tế |
| **Activity** | 10 | 10% | Người dùng hoạt động gần đây có khả năng phản hồi cao hơn |
| **Age** | 10 | 10% | Tuổi tác ít quan trọng hơn trong hẹn hò hiện đại |

**Tổng:** 100 điểm

### 3.2. Biểu đồ phân bổ trọng số

```
Interests    ████████████████████████████████████████ 40%
Lifestyle    ████████████████████ 20%
Distance     ████████████████████ 20%
Activity     ██████████ 10%
Age          ██████████ 10%
```

### 3.3. Điều chỉnh trọng số (Advanced)

Trong tương lai, hệ thống có thể **cá nhân hóa trọng số** dựa trên hành vi người dùng:

**Ví dụ:** Nếu User A thường like các profile gần nhà:
- Tăng \( w_{distance} \) từ 20 → 30
- Giảm \( w_{interests} \) từ 40 → 35
- Giảm \( w_{lifestyle} \) từ 20 → 15

**Machine Learning approach:**
$$
w_i^{(user)} = w_i^{(default)} + \alpha \cdot \frac{\partial L}{\partial w_i}
$$

Trong đó \( L \) là loss function dựa trên lịch sử swipe của người dùng.

---

## 🧮 4. Công thức Tổng quát (Final Match Score)

### 4.1. Công thức Raw Score

**Raw Matching Score** là tổng điểm từ tất cả các yếu tố:

$$
S_{raw} = S_{interests} + S_{lifestyle} + S_{distance} + S_{activity} + S_{age}
$$

**Hoặc viết dưới dạng chi tiết:**

$$
S_{raw} = w_{int} \cdot f_{overlap}(I_A, I_B) + w_{life} \cdot f_{overlap}(L_A, L_B) + w_{dist} \cdot f_{distance}(d, d_{max}) + w_{act} \cdot f_{activity}(\Delta t) + w_{age} \cdot f_{age}(age_B, [age_{min}, age_{max}])
$$

**Trong đó:**
- \( w_{int}, w_{life}, w_{dist}, w_{act}, w_{age} \): Trọng số các yếu tố
- \( f_{overlap} \): Hàm tính độ trùng lặp (Jaccard-like)
- \( f_{distance} \): Hàm tính điểm khoảng cách
- \( f_{activity} \): Hàm tính điểm hoạt động
- \( f_{age} \): Hàm tính điểm tuổi tác

---

### 4.2. Normalized Score (0-100)

Để dễ hiểu và so sánh, điểm số được chuẩn hóa về thang 0-100:

$$
S_{final} = \min\left(100, \left\lfloor \frac{S_{raw}}{W_{total}} \times 100 \right\rfloor \right)
$$

**Trong đó:**
- \( W_{total} = 100 \) (tổng trọng số)
- \( \lfloor \cdot \rfloor \): Hàm làm tròn xuống

---

### 4.3. Ví dụ Tính toán Hoàn chỉnh

**Giả sử:**
- **User A:**
  - Interests: `['travel', 'music', 'coffee', 'photography', 'cooking']`
  - Lifestyle: `['fitness', 'early-bird', 'pet-lover']`
  - Location: `[106.6297, 10.8231]` (Sài Gòn)
  - Preferences: Age 25-35, maxDistance 50km
  - Gender preference: `['female']`

- **User B:**
  - Interests: `['music', 'coffee', 'reading', 'gaming']`
  - Lifestyle: `['fitness', 'pet-lover']`
  - Location: `[106.7000, 10.8500]` (Cách ~10km)
  - Age: 28
  - Gender: `female`
  - Last active: 2 ngày trước

**Tính toán:**

1. **Interests Score:**
   - Chung: `['music', 'coffee']` (2/5)
   - \( S_{interests} = 40 \times \frac{2}{5} = 16 \)

2. **Lifestyle Score:**
   - Chung: `['fitness', 'pet-lover']` (2/3)
   - \( S_{lifestyle} = 20 \times \frac{2}{3} \approx 13.33 \)

3. **Distance Score:**
   - \( d = 10 \) km, \( d_{max} = 50 \) km
   - \( S_{distance} = 20 \times \left(1 - \frac{10}{50}\right) = 16 \)

4. **Activity Score:**
   - \( \Delta t = 2 \) ngày (1 < 2 < 7)
   - \( S_{activity} = 10 - 2 = 8 \)

5. **Age Score:**
   - Age B = 28, trong khoảng [25, 35]
   - \( S_{age} = 10 \)

**Tổng hợp:**
$$
S_{raw} = 16 + 13.33 + 16 + 8 + 10 = 63.33
$$

$$
S_{final} = \left\lfloor \frac{63.33}{100} \times 100 \right\rfloor = 63
$$

**Kết quả:** User B có **Matching Score = 63%** với User A.

---

### 4.4. Score Breakdown (Chi tiết điểm)

Hệ thống trả về breakdown để debug và optimize:

```json
{
  "userId": "user_b_id",
  "score": 63,
  "breakdown": {
    "interests": 16,
    "lifestyle": 13,
    "distance": 16,
    "activity": 8,
    "age": 10
  },
  "distanceKm": 10.2
}
```

---

## 🆕 5. Edge Cases & Cold Start Problem

### 5.1. Cold Start Problem (Người dùng mới)

**Vấn đề:** Người dùng mới chưa có đủ dữ liệu (ít sở thích, chưa cập nhật lối sống, chưa có hành vi swipe).

#### **5.1.1. Giải pháp cho New User làm Viewer (User A)**

**Strategy 1: Sử dụng giá trị mặc định rộng**
- Nếu User A không đặt preferences → Sử dụng default:
  - Age range: 18-100
  - Max distance: 50km
  - Show me: Tất cả giới tính (trừ giới tính của chính họ nếu họ là straight)

**Strategy 2: Hiển thị Popular Profiles**
- Ưu tiên người dùng có:
  - Tỷ lệ match cao (nhiều người like)
  - Hoàn thiện profile đầy đủ
  - Activity score cao

**Strategy 3: Onboarding Survey**
- Yêu cầu người dùng mới chọn ít nhất 3-5 sở thích
- Hỏi về lối sống cơ bản (early-bird/night-owl, fitness level, etc.)

---

#### **5.1.2. Giải pháp cho New User làm Candidate (User B)

**Strategy 1: Boosting New Users**
- Tạm thời tăng Activity Score:
  - Người dùng mới (< 7 ngày) luôn có \( S_{activity} = 10 \) 
  - Mục đích: Tăng visibility, giúp tạo connections nhanh

**Strategy 2: Giảm yêu cầu Interests/Lifestyle**
- Nếu User B chưa có đủ dữ liệu:
  - Nếu `interests.length < 3`: \( S_{interests} = 0.3 \times w_{interests} = 12 \) (điểm cơ bản)
  - Nếu `lifestyle.length < 2`: \( S_{lifestyle} = 0.2 \times w_{lifestyle} = 4 \)

**Implementation:**

```javascript
function calculateInterestsScore(userA, userB) {
  // New user handling
  if (userB.interests.length < 3) {
    return 0.3 * WEIGHTS.INTERESTS; // 12 điểm cơ bản
  }
  
  // Normal calculation
  return normalJaccardScore(userA.interests, userB.interests, WEIGHTS.INTERESTS);
}
```

---

### 5.2. Edge Case: Người dùng không có Location

**Vấn đề:** User không cho phép truy cập vị trí.

**Giải pháp:**
1. **Yêu cầu nhập thủ công:**
   - Cho phép nhập tỉnh/thành phố
   - Sử dụng tọa độ trung tâm của tỉnh/thành phố

2. **Giảm Distance Score:**
   - \( S_{distance} = 0 \) (không tính)
   - Tăng trọng số cho các yếu tố khác:
     - \( w_{interests} = 50 \) (+10)
     - \( w_{lifestyle} = 30 \) (+10)

3. **Chỉ hiển thị trong cùng tỉnh/thành phố:**
   - Filter cứng dựa trên `location.province` hoặc `location.city`

---

### 5.3. Edge Case: Người dùng có quá ít Profile Data

**Trường hợp:**
- Không có sở thích: `interests = []`
- Không có lối sống: `lifestyle = []`
- Không có ảnh hoặc chỉ có 1 ảnh

**Giải pháp:**
1. **Warning/Prompt:**
   - Khuyến khích hoàn thiện profile
   - "Hoàn thiện profile để tăng 50% cơ hội match!"

2. **Penalty Score:**
   - Profile không đầy đủ → Giảm tổng điểm 20%
   - Formula:
     $$
     S_{final} = S_{raw} \times \text{Completeness Factor}
     $$
   - Completeness Factor:
     - 0 interests: 0.8
     - < 3 photos: 0.9
     - No bio: 0.95

3. **Không hiển thị trong "Best" mode:**
   - Chỉ hiển thị trong "Newest" sort option

---

### 5.4. Edge Case: Matching Score = 0

**Nguyên nhân:**
- User quá xa (Distance = 0)
- Không có điểm chung nào về sở thích, lối sống
- Tuổi không phù hợp
- User lâu không hoạt động

**Giải pháp:**
1. **Minimum Score Guarantee:**
   - Đảm bảo tối thiểu 5-10 điểm cho bất kỳ profile nào vượt qua Hard Filters
   - Công thức:
     $$
     S_{final} = \max(5, S_{raw})
     $$

2. **Random Exploration:**
   - 10-15% kết quả là random (không theo matching score)
   - Giúp discover những profile "ngoài radar"
   - Tăng diversity

---

## 📊 6. Optimization & Advanced Features

### 6.1. Machine Learning Enhancement

**Collaborative Filtering:**
- Học từ hành vi swipe của người dùng tương tự
- "Người dùng giống bạn cũng thích những profile này"

**Công thức:**
$$
S_{ML} = S_{rule-based} + \alpha \cdot P_{collaborative}
$$

Trong đó:
- \( S_{rule-based} \): Điểm từ hệ thống hiện tại
- \( P_{collaborative} \): Xác suất từ collaborative filtering
- \( \alpha \): Hệ số kết hợp (0.1 - 0.3)

---

### 6.2. Dynamic Weight Adjustment

**Personalized Weights dựa trên hành vi:**

```python
# Pseudo-code
def adjust_weights_for_user(user_id, swipe_history):
    weights = DEFAULT_WEIGHTS.copy()
    
    # Phân tích hành vi
    liked_profiles = get_liked_profiles(swipe_history)
    
    # Nếu user thích những người gần
    avg_distance = mean([p.distance for p in liked_profiles])
    if avg_distance < 10:
        weights['distance'] += 10
        weights['interests'] -= 5
        weights['lifestyle'] -= 5
    
    # Nếu user thích những người có sở thích giống
    avg_interest_overlap = mean([p.interest_overlap for p in liked_profiles])
    if avg_interest_overlap > 0.6:
        weights['interests'] += 10
        weights['age'] -= 5
        weights['activity'] -= 5
    
    return normalize_weights(weights)
```

---

### 6.3. A/B Testing Framework

**Thử nghiệm các phiên bản khác nhau:**

| Variant | Interests | Lifestyle | Distance | Activity | Age |
|---------|-----------|-----------|----------|----------|-----|
| A (Current) | 40 | 20 | 20 | 10 | 10 |
| B (Distance Focus) | 30 | 15 | 35 | 10 | 10 |
| C (Interests Focus) | 50 | 15 | 15 | 10 | 10 |
| D (Balanced) | 30 | 25 | 25 | 10 | 10 |

**Metrics đo lường:**
- Match rate (%)
- Conversion to conversation (%)
- Average conversation length
- User satisfaction score

---

## 🔍 7. Monitoring & Analytics

### 7.1. Key Metrics

**Score Distribution:**
```
Score Range   Count    Percentage
0-20          50       5%
21-40         150      15%
41-60         400      40%
61-80         300      30%
81-100        100      10%
```

**Component Contribution:**
- Interests là yếu tố quan trọng nhất (40% trọng số)
- Monitor xem trong thực tế có đúng như vậy không

### 7.2. Logging & Debugging

**DiscoveryLog Schema:**
```javascript
{
  viewer: ObjectId,
  candidate: ObjectId,
  score: 63,
  breakdown: {
    interests: 16,
    lifestyle: 13,
    distance: 16,
    activity: 8,
    age: 10
  },
  distanceKm: 10.2,
  filters: { maxDistance: 50, ageRange: [25, 35] },
  timestamp: ISODate("2025-11-30T10:30:00Z")
}
```

**Analytics Queries:**
1. Điểm trung bình theo từng component
2. Component nào có tương quan cao nhất với swipe right
3. Phân bố điểm theo demographics (tuổi, giới tính, địa lý)

---

## 📚 8. Tài liệu tham khảo & Best Practices

### 8.1. Best Practices trong Dating Apps

**Tinder:**
- Sử dụng Elo Rating System (tương tự cờ vua)
- Người dùng có nhiều right swipes → Score cao hơn

**Bumble:**
- Ưu tiên người dùng hoạt động gần đây
- Boosting profiles mới trong 24h đầu

**Hinge:**
- Focus vào compatibility dựa trên câu trả lời cho prompts
- "Most Compatible" dựa trên Gale-Shapley algorithm

### 8.2. Academic References

1. **Jaccard Similarity:** 
   - Jaccard, P. (1912). "The distribution of the flora in the alpine zone"

2. **Haversine Formula:**
   - Sinnott, R. W. (1984). "Virtues of the Haversine"

3. **Recommendation Systems:**
   - Ricci, F., et al. (2015). "Recommender Systems Handbook"

4. **Cold Start Problem:**
   - Schein, A. I., et al. (2002). "Methods and metrics for cold-start recommendations"

---

## 🎬 9. Tổng kết

### 9.1. Workflow Tổng quan

```
┌─────────────────┐
│  User A Request │
│  Discovery      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Apply Hard Filters     │
│  - Gender              │
│  - Distance            │
│  - Active Status       │
│  - Not Swiped Before   │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Calculate Soft Scores  │
│  - Interests (40)      │
│  - Lifestyle (20)      │
│  - Distance (20)       │
│  - Activity (10)       │
│  - Age (10)            │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Aggregate & Normalize  │
│  Score = Σ / 100       │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Sort & Return Top N    │
│  (Default: 25-50)      │
└─────────────────────────┘
```

### 9.2. Key Takeaways

✅ **Hard Filters đảm bảo chất lượng cơ bản** (giới tính, khoảng cách, status)

✅ **Soft Scores cung cấp ranking chi tiết** (40% Interests, 20% Lifestyle, 20% Distance, 10% Activity, 10% Age)

✅ **Normalized Score (0-100)** dễ hiểu và so sánh

✅ **Cold Start được xử lý** bằng default values, boosting, và onboarding

✅ **Scalable & Extensible** - Dễ thêm yếu tố mới hoặc điều chỉnh trọng số

✅ **Data-driven** - Log đầy đủ để optimize dựa trên hành vi thực tế

---

## 📞 Liên hệ & Đóng góp

Nếu có câu hỏi hoặc đề xuất cải tiến cho hệ thống Matching Score:
- Tạo issue trên GitHub repository
- Liên hệ Data Science Team
- Tham gia A/B Testing program

---

**Version:** 1.0  
**Last Updated:** November 30, 2025  
**Author:** Matcha Engineering Team  
**Status:** Production Ready ✅

