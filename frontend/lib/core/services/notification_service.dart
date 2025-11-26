import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      // Show local notification if needed
    });

    // Handle background messages (already handled in main.dart)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when app is in background
      print('Notification opened app: ${message.data}');
    });

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    // TODO: Send token to backend
  }


  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

