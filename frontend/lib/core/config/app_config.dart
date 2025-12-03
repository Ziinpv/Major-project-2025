import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
class AppConfig {
  static String get baseUrl {
    // WEB
    if (kIsWeb) {
      return "http://localhost:3000/api"; // hoặc server thật nếu deploy
    }

    // ANDROID PHYSICAL DEVICE via USB (use adb reverse)
    if (Platform.isAndroid) {
      // Nếu dùng adb reverse
      return "http://localhost:3000/api";

      // Nếu dùng emulator -> bạn bè dùng emulator sẽ sửa dòng này:
      // return "http://10.0.2.2:3000/api";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://localhost:3000/api";
    }

    // Default fallback
    return "http://localhost:3000/api";
  }

  static String get wsUrl {
    if (kIsWeb) {
      return "ws://localhost:3000";
    }

    if (Platform.isAndroid) {
      return "ws://localhost:3000";
    }

    if (Platform.isIOS) {
      return "ws://localhost:3000";
    }

    return "ws://localhost:3000";
  }

  static const String appVersion = '1.0.0';
  static const Duration apiTimeout = Duration(seconds: 30);
}