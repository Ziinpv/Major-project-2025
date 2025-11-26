// src/scripts/force_fix_discovery.js
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const Match = require('../models/Match');

const LONG_ID = '69244d283d675e7fe8c4af9e';
const ANH_ID = '6925d58e438e74a43c43f1cb';

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ Connected to MongoDB");

    // 1. TẠO LẠI INDEX ĐỊA LÝ (Quan trọng nhất)
    console.log("🛠 Đang tạo lại Index 2dsphere...");
    await User.collection.createIndex({ "location.coordinates": "2dsphere" });
    console.log("✅ Index 2dsphere đã được đảm bảo.");

    // 2. XÓA SẠCH QUAN HỆ CŨ
    console.log("🧹 Đang dọn dẹp lịch sử Swipe/Match...");
    await Swipe.deleteMany({
      $or: [
        { swiper: LONG_ID, swiped: ANH_ID },
        { swiper: ANH_ID, swiped: LONG_ID }
      ]
    });
    await Match.deleteMany({
      users: { $all: [LONG_ID, ANH_ID] }
    });
    console.log("✅ Đã reset quan hệ Long <-> Ánh về người lạ.");

    // 3. DỜI ÁNH VỀ ĐÀ NẴNG (Sát bên Long)
    console.log("📍 Đang cập nhật vị trí Ánh...");
    await User.updateOne(
      { _id: ANH_ID },
      {
        $set: {
          "location.province": "Đà Nẵng",
          "location.city": "Quận Sơn Trà",
          "location.type": "Point",
          "location.coordinates": [108.2208, 16.0603], // Cầu Rồng
          "isActive": true,
          "isProfileComplete": true
        }
      }
    );
    console.log("✅ Ánh đã chuyển hộ khẩu về Đà Nẵng.");

    // 4. KIỂM TRA BỘ LỌC CỦA LONG
    const long = await User.findById(LONG_ID);
    console.log("\n--- THÔNG TIN CỦA LONG (Check kỹ cái này) ---");
    console.log("Show Me (Giới tính muốn tìm):", long.preferences.showMe);
    console.log("Age Range:", long.preferences.ageRange);
    console.log("Max Distance:", long.preferences.maxDistance);
    
    // Reset bộ lọc của Long để chắc chắn tìm thấy
    await User.updateOne({ _id: LONG_ID }, {
      $set: {
        "preferences.showMe": [], // Tìm tất cả giới tính
        "preferences.ageRange": { min: 18, max: 100 },
        "preferences.maxDistance": 100 // Tăng lên 100km
      }
    });
    console.log("✅ Đã reset bộ lọc của Long về mặc định (Tìm tất cả).");

  } catch (e) {
    console.error("❌ Lỗi:", e);
  } finally {
    await mongoose.disconnect();
    console.log("🏁 Hoàn tất. Hãy restart app!");
  }
})();