# 🚀 QUICK START - ĐA NGÔN NGỮ (5 PHÚT)

## ✅ ĐÃ HOÀN THÀNH

Hệ thống đa ngôn ngữ (Việt - Anh) đã được cài đặt đầy đủ và sẵn sàng sử dụng!

---

## 🏃 CHẠY NGAY

### Bước 1: Generate localization files

```bash
cd frontend
flutter pub get
flutter gen-l10n
```

### Bước 2: Chạy app

```bash
flutter run
```

### Bước 3: Test đổi ngôn ngữ

1. Mở app → Tab **Profile** → Nhấn ⚙️ **Settings**
2. Section "Ngôn ngữ & giao diện" → Dropdown **Ngôn ngữ**
3. Chọn "English" → **Tất cả text tự động đổi!** ✨

---

## 📝 SỬ DỤNG TRONG CODE (Copy & Paste)

### Template cơ bản:

```dart
import 'package:flutter/material.dart';
import '../../../core/extensions/localization_extension.dart';

class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;  // ← Thêm dòng này
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),  // ← Thay 'Cài đặt' → l10n.key
      ),
      body: Column(
        children: [
          Text(l10n.common_ok),           // "OK"
          Text(l10n.auth_login_title),    // "Đăng nhập" / "Login"
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.common_save), // "Lưu" / "Save"
          ),
        ],
      ),
    );
  }
}
```

---

## 🔑 KEYS PHỔ BIẾN (Copy-Paste Ready)

### Buttons
```dart
l10n.common_ok          // OK
l10n.common_cancel      // Hủy / Cancel
l10n.common_save        // Lưu / Save
l10n.common_delete      // Xóa / Delete
l10n.common_next        // Tiếp theo / Next
l10n.common_back        // Quay lại / Back
l10n.common_done        // Hoàn tất / Done
```

### Auth
```dart
l10n.auth_login_title           // Đăng nhập / Login
l10n.auth_login_button          // Đăng nhập / Login
l10n.auth_register_title        // Tạo tài khoản / Create Account
l10n.auth_error_email_required  // Vui lòng nhập email / Please enter email
```

### Settings
```dart
l10n.settings_title     // Cài đặt / Settings
l10n.settings_language  // Ngôn ngữ / Language
l10n.settings_logout    // Đăng xuất / Logout
```

**Xem đầy đủ 100+ keys:** Mở file `frontend/lib/l10n/app_vi.arb`

---

## 🔄 REFACTOR MÀN HÌNH CŨ (3 bước)

### Bước 1: Import extension

```dart
import '../../../core/extensions/localization_extension.dart';
```

### Bước 2: Thêm biến l10n

```dart
@override
Widget build(BuildContext context) {
  final l10n = context.l10n;  // ← Thêm dòng này
  
  return Scaffold(...);
}
```

### Bước 3: Thay text

**TRƯỚC:**
```dart
const Text('Đăng nhập')
```

**SAU:**
```dart
Text(l10n.auth_login_title)
```

---

## 📚 TÀI LIỆU CHI TIẾT

- **Hướng dẫn đầy đủ:** `docs/LOCALIZATION_GUIDE.md`
- **Tóm tắt triển khai:** `docs/LOCALIZATION_IMPLEMENTATION_SUMMARY.md`

---

## ⚡ VÍ DỤ HOÀN CHỈNH

### Refactor LoginScreen:

```dart
import 'package:flutter/material.dart';
import '../../../core/extensions/localization_extension.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.auth_login_title,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(l10n.auth_login_subtitle),
            SizedBox(height: 32),
            
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.auth_login_email_hint,
                prefixIcon: Icon(Icons.email),
              ),
            ),
            
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.auth_login_password_hint,
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            
            SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _login,
              child: Text(l10n.auth_login_button),
            ),
            
            TextButton(
              onPressed: () => context.go('/auth/register'),
              child: Text('${l10n.auth_login_no_account}${l10n.auth_login_register}'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 TODO: CÁC MÀN HÌNH CẦN REFACTOR

Có keys sẵn, chỉ cần áp dụng 3 bước trên:

- [ ] `auth/login_screen.dart`
- [ ] `auth/register_screen.dart`
- [ ] `profile/profile_screen.dart`
- [ ] `profile/edit_profile_screen.dart`
- [ ] `profile/profile_setup_screen.dart`
- [ ] `discovery/discovery_screen.dart`
- [ ] `matches/matches_screen.dart`
- [ ] `chat/chat_list_screen.dart`

---

## 🐛 TROUBLESHOOTING

### "Getter 'l10n' isn't defined"
→ Thiếu import: `import '../../../core/extensions/localization_extension.dart';`

### "AppLocalizations not found"
→ Chạy: `flutter pub get && flutter gen-l10n`

### Text không đổi sau khi switch language
→ Widget cần rebuild. Đổi từ StatelessWidget → ConsumerWidget (Riverpod)

---

**DONE! Bắt đầu refactor thôi! 🚀**

