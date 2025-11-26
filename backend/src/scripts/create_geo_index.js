// src/scripts/create_geo_index.js
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../models/User');

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ Connected to MongoDB");

    // 1. Drop index cũ nếu có (để tránh lỗi duplicate)
    try {
      await User.collection.dropIndex("location.coordinates_2dsphere");
      console.log("🗑 Đã xóa index cũ (nếu có).");
    } catch (e) {
      console.log("ℹ️ Không tìm thấy index cũ để xóa (OK).");
    }

    // 2. Tạo lại Index mới
    console.log("🛠 Đang tạo Index 2dsphere...");
    await User.collection.createIndex({ "location.coordinates": "2dsphere" });
    
    console.log("✅ Đã tạo thành công Index 2dsphere cho location.coordinates!");

  } catch (e) {
    console.error("❌ Lỗi:", e);
  } finally {
    await mongoose.disconnect();
    console.log("🏁 Hoàn tất.");
    process.exit(0);
  }
})();