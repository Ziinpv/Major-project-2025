// src/scripts/debug_missing_mono.js
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('../models/User');
const Swipe = require('../models/Swipe');

// Email của các nhân vật chính
const EMAIL_VIEWER = 'duoclora@gmail.com'; // Ánh (Người đi tìm)
// const EMAIL_VIEWER = 'lonbg5417@gmail.com'; // Hoặc đổi thành Long để test Long
const EMAIL_MONO = 'mono@gmail.com';       // Mono (Người bị ẩn)

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ Connected to DB");

    const viewer = await User.findOne({ email: EMAIL_VIEWER });
    const mono = await User.findOne({ email: EMAIL_MONO });

    if (!viewer || !mono) {
      console.error("❌ Không tìm thấy User! Kiểm tra lại email.");
      process.exit(1);
    }

    console.log(`\n🕵️‍♂️ ĐANG ĐIỀU TRA: Tại sao [${viewer.firstName}] không thấy [${mono.firstName}]?`);
    console.log("----------------------------------------------------------------");

    // 1. KIỂM TRA MONO (NẠN NHÂN)
    console.log(`\n1. KIỂM TRA HỒ SƠ CỦA MONO:`);
    console.log(`   - ID: ${mono._id}`);
    console.log(`   - isActive: ${mono.isActive} ${mono.isActive ? "✅" : "❌ (Phải là true)"}`);
    console.log(`   - isProfileComplete: ${mono.isProfileComplete} ${mono.isProfileComplete ? "✅" : "❌ (Phải là true - Xem lại ảnh/location)"}`);
    console.log(`   - Gender: '${mono.gender}'`);
    console.log(`   - Age: ${getAge(mono.dateOfBirth)} tuổi (DOB: ${mono.dateOfBirth?.toISOString().split('T')[0]})`);
    console.log(`   - Location: ${mono.location?.type === 'Point' ? `✅ Có tọa độ [${mono.location.coordinates}]` : "❌ Mất tọa độ!"}`);

    if (!mono.isActive || !mono.isProfileComplete || !mono.location?.coordinates) {
        console.log("\n👉 KẾT LUẬN: Mono bị loại ngay từ vòng gửi xe do hồ sơ lỗi/thiếu.");
        process.exit(0);
    }

    // 2. KIỂM TRA LỊCH SỬ SWIPE
    console.log(`\n2. KIỂM TRA LỊCH SỬ SWIPE:`);
    const swipe = await Swipe.findOne({ swiper: viewer._id, swiped: mono._id });
    if (swipe) {
        console.log(`   ❌ [${viewer.firstName}] ĐÃ từng swipe Mono rồi! (Kiểu: ${swipe.action})`);
        console.log("\n👉 KẾT LUẬN: Đã swipe rồi thì không hiện lại nữa.");
        process.exit(0);
    } else {
        console.log(`   ✅ Chưa từng swipe nhau.`);
    }

    // 3. KIỂM TRA BỘ LỌC CỦA VIEWER (ÁNH)
    console.log(`\n3. KIỂM TRA BỘ LỌC CỦA [${viewer.firstName}]:`);
    const prefs = viewer.preferences;
    
    // Check Gender
    // Lưu ý: Nếu showMe rỗng [] nghĩa là tìm tất cả (trong logic code cũ), hoặc chỉ tìm Nam/Nữ tùy logic mới
    const showMe = prefs.showMe || []; 
    console.log(`   - Show Me (Giới tính muốn tìm): ${JSON.stringify(showMe)}`);
    let genderMatch = showMe.length === 0 || showMe.includes(mono.gender);
    console.log(`   => So khớp giới tính Mono ('${mono.gender}'): ${genderMatch ? "✅ Khớp" : "❌ KHÔNG KHỚP"}`);

    // Check Age
    const age = getAge(mono.dateOfBirth);
    console.log(`   - Age Range: ${prefs.ageRange.min} - ${prefs.ageRange.max}`);
    let ageMatch = age >= prefs.ageRange.min && age <= prefs.ageRange.max;
    console.log(`   => So khớp tuổi Mono (${age}): ${ageMatch ? "✅ Khớp" : "❌ KHÔNG KHỚP (Quá già/Quá trẻ)"}`);

    // Check Distance
    const dist = getDistance(viewer.location.coordinates, mono.location.coordinates);
    console.log(`   - Max Distance: ${prefs.maxDistance} km`);
    console.log(`   - Khoảng cách thực tế: ${dist ? dist.toFixed(2) + " km" : "Không tính được"}`);
    let distMatch = dist !== null && dist <= prefs.maxDistance;
    console.log(`   => So khớp khoảng cách: ${distMatch ? "✅ Khớp" : "❌ KHÔNG KHỚP (Quá xa)"}`);

    console.log("\n----------------------------------------------------------------");
    if (genderMatch && ageMatch && distMatch) {
        console.log("🎉 KẾT LUẬN CUỐI CÙNG: Mọi điều kiện đều thỏa mãn! Mono PHẢI hiện ra.");
        console.log("👉 Nếu vẫn không thấy -> Có thể do Phân trang (Limit) hoặc Cache Frontend.");
    } else {
        console.log("💀 KẾT LUẬN CUỐI CÙNG: Mono bị ẩn do BỘ LỌC không khớp (xem mục X bên trên).");
    }

  } catch (e) {
    console.error(e);
  } finally {
    await mongoose.disconnect();
  }
})();

// Hàm tính tuổi
function getAge(dob) {
    if(!dob) return 0;
    const diff = Date.now() - new Date(dob).getTime();
    return Math.abs(new Date(diff).getUTCFullYear() - 1970);
}

// Hàm tính khoảng cách
function getDistance(coords1, coords2) {
    if (!coords1 || !coords2) return null;
    const [lon1, lat1] = coords1;
    const [lon2, lat2] = coords2;
    const R = 6371; // Radius of the earth in km
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

function deg2rad(deg) {
    return deg * (Math.PI / 180);
}