# HƯỚNG DẪN SỬ DỤNG ĐA NGÔN NGỮ (LOCALIZATION) - MATCHA APP

## 📋 MỤC LỤC
1. [Tổng quan](#tổng-quan)
2. [Cài đặt hoàn tất](#cài-đặt-hoàn-tất)
3. [Cách sử dụng](#cách-sử-dụng)
4. [Refactor màn hình hiện có](#refactor-màn-hình-hiện-có)
5. [Thêm ngôn ngữ mới](#thêm-ngôn-ngữ-mới)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 TỔNG QUAN

Hệ thống đa ngôn ngữ đã được cài đặt hoàn chỉnh với:
- ✅ **2 ngôn ngữ:** Tiếng Việt (vi) và English (en)
- ✅ **Hơn 100+ keys** dịch sẵn cho các màn hình chính
- ✅ **Tự động reload** khi đổi ngôn ngữ
- ✅ **Lưu cấu hình** người dùng vào SharedPreferences

---

## 🔧 CÀI ĐẶT HOÀN TẤT

### 1. Files đã được tạo/cập nhật:

```
frontend/
├── l10n.yaml                              # Cấu hình localization
├── pubspec.yaml                            # Đã thêm flutter_localizations
├── lib/
│   ├── l10n/
│   │   ├── app_vi.arb                     # File ngôn ngữ Tiếng Việt (template)
│   │   └── app_en.arb                     # File ngôn ngữ English
│   ├── core/
│   │   └── extensions/
│   │       └── localization_extension.dart # Extension helper
│   ├── main.dart                           # Đã cấu hình localization
│   └── presentation/screens/
│       ├── home/home_screen.dart           # ✅ Đã refactor
│       └── settings/settings_screen.dart   # ✅ Đã refactor
```

### 2. Chạy code generation:

```bash
cd frontend
flutter pub get
flutter gen-l10n
```

Lệnh `flutter gen-l10n` sẽ tự động tạo file:
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations_vi.dart`
- `lib/.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`

> **Lưu ý:** Mỗi khi bạn sửa file `.arb`, cần chạy lại `flutter gen-l10n` hoặc `flutter run` (tự động generate).

---

## 💡 CÁCH SỬ DỤNG

### Cách 1: Sử dụng Extension (Khuyến nghị)

```dart
import 'package:flutter/material.dart';
import '../../../core/extensions/localization_extension.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;  // ✅ Ngắn gọn, dễ đọc
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),  // "Cài đặt" hoặc "Settings"
      ),
      body: Text(l10n.common_ok),           // "OK"
    );
  }
}
```

### Cách 2: Sử dụng trực tiếp AppLocalizations

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.auth_login_title);  // "Đăng nhập" hoặc "Login"
  }
}
```

### Sử dụng với Placeholders (tham số động)

Trong file `.arb`:
```json
{
  "match_dialog_message": "Bạn và {name} đã thích nhau!",
  "@match_dialog_message": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}
```

Trong code:
```dart
Text(l10n.match_dialog_message('Alice'))
// Output: "Bạn và Alice đã thích nhau!" (vi)
// Output: "You and Alice liked each other!" (en)
```

---

## 🔄 REFACTOR MÀN HÌNH HIỆN CÓ

### Bước 1: Thêm import

```dart
import '../../../core/extensions/localization_extension.dart';
```

### Bước 2: Đổi hardcoded text sang localization

**TRƯỚC (Hardcoded):**
```dart
AppBar(
  title: const Text('Đăng nhập'),
)
```

**SAU (Localized):**
```dart
@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.auth_login_title),
    ),
  );
}
```

### Bước 3: Refactor toàn bộ màn hình

**VÍ DỤ: LoginScreen**

```dart
import 'package:flutter/material.dart';
import '../../../core/extensions/localization_extension.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      body: Column(
        children: [
          Text(l10n.auth_login_title),        // "Đăng nhập" / "Login"
          Text(l10n.auth_login_subtitle),     // "Chào mừng bạn trở lại!" / "Welcome back!"
          
          TextFormField(
            decoration: InputDecoration(
              labelText: l10n.auth_login_email_hint,  // "Email"
            ),
          ),
          
          TextFormField(
            decoration: InputDecoration(
              labelText: l10n.auth_login_password_hint,  // "Mật khẩu" / "Password"
            ),
          ),
          
          ElevatedButton(
            onPressed: _login,
            child: Text(l10n.auth_login_button),  // "Đăng nhập" / "Login"
          ),
        ],
      ),
    );
  }
}
```

---

## 📝 DANH SÁCH KEYS ĐÃ CÓ SẴN

### Common (Chung)
- `common_ok`, `common_cancel`, `common_save`, `common_delete`, `common_edit`
- `common_close`, `common_next`, `common_back`, `common_done`
- `common_loading`, `common_error`, `common_retry`

### Authentication
- `auth_login_title`, `auth_login_subtitle`, `auth_login_button`
- `auth_register_title`, `auth_register_subtitle`, `auth_register_button`
- `auth_error_*` (tất cả các lỗi validation)

### Profile
- `profile_title`, `profile_about`, `profile_job`, `profile_school`
- `profile_setup_*` (tất cả các bước setup)
- `profile_edit_*` (tất cả các trường edit)

### Discovery
- `discovery_title`, `discovery_filter_*`
- `discovery_complete_profile_*`

### Settings
- `settings_*` (tất cả các mục trong settings)

### Chat & Matches
- `chat_*`, `matches_*`

> **Xem đầy đủ:** Mở file `lib/l10n/app_vi.arb` hoặc `app_en.arb`

---

## ➕ THÊM NGÔN NGỮ MỚI

### Bước 1: Tạo file `.arb` mới

Ví dụ thêm tiếng Nhật:
```bash
cp lib/l10n/app_vi.arb lib/l10n/app_ja.arb
```

### Bước 2: Dịch nội dung

Trong `app_ja.arb`:
```json
{
  "@@locale": "ja",
  "appTitle": "Matcha",
  "common_ok": "OK",
  "auth_login_title": "ログイン",
  ...
}
```

### Bước 3: Cập nhật `main.dart`

```dart
supportedLocales: const [
  Locale('vi', ''),
  Locale('en', ''),
  Locale('ja', ''),  // ➕ Thêm dòng này
],
```

### Bước 4: Cập nhật `SettingsScreen`

Thêm option trong DropdownButton:
```dart
DropdownMenuItem(value: 'ja', child: Text('日本語')),
```

---

## 🚨 TROUBLESHOOTING

### Lỗi: "The getter 'l10n' isn't defined for the type 'BuildContext'"

**Nguyên nhân:** Chưa import extension.

**Giải pháp:**
```dart
import '../../../core/extensions/localization_extension.dart';
```

### Lỗi: "AppLocalizations.delegate isn't defined"

**Nguyên nhân:** Chưa chạy code generation.

**Giải pháp:**
```bash
flutter pub get
flutter gen-l10n
```

### Lỗi: Hot Reload không cập nhật text sau khi đổi ngôn ngữ

**Nguyên nhân:** StatelessWidget không rebuild.

**Giải pháp:** Sử dụng `ConsumerWidget` (Riverpod) hoặc `StatefulWidget`.

### Text vẫn hiển thị hardcode dù đã đổi ngôn ngữ

**Kiểm tra:**
1. Đã refactor text sang `l10n.key` chưa?
2. Widget có rebuild khi `languageProvider` thay đổi không?

---

## 📚 QUY TRÌNH REFACTOR TOÀN BỘ APP

### Thứ tự ưu tiên refactor:

1. **Auth Screens** (Login, Register) ← ✅ Có keys sẵn
2. **Profile Screens** (Profile, Edit, Setup) ← ✅ Có keys sẵn
3. **Discovery Screen** ← ✅ Có keys sẵn
4. **Chat & Matches** ← ✅ Có keys sẵn
5. **Các màn hình còn lại** ← Thêm keys mới nếu cần

### Mẫu commit message:

```
refactor: add localization to LoginScreen

- Replace hardcoded strings with l10n keys
- Add localization extension import
- Test both vi and en languages
```

---

## ✅ CHECKLIST KHI REFACTOR MỘT MÀN HÌNH

- [ ] Import `localization_extension.dart`
- [ ] Khai báo `final l10n = context.l10n;` trong build method
- [ ] Thay thế TẤT CẢ `const Text('...')` → `Text(l10n.key)`
- [ ] Thay thế TẤT CẢ `'...'` trong InputDecoration, AlertDialog, SnackBar
- [ ] Kiểm tra các validation error messages
- [ ] Test chuyển đổi ngôn ngữ trong Settings
- [ ] Verify cả 2 ngôn ngữ hiển thị đúng

---

## 🎓 BÀI TẬP THỰC HÀNH

Hãy thử refactor **LoginScreen** theo hướng dẫn trên. Các bước:

1. Mở `lib/presentation/screens/auth/login_screen.dart`
2. Thêm import extension
3. Đổi các text hardcode sang keys có sẵn:
   - `auth_login_title`
   - `auth_login_subtitle`
   - `auth_login_button`
   - `auth_login_with_google`
   - ...
4. Chạy app và test đổi ngôn ngữ trong Settings

---

**Liên hệ:** Nếu cần hỗ trợ, hãy tạo issue hoặc liên hệ team.

