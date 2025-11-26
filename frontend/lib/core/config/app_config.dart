class AppConfig {
  // Backend API
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For physical device, use your computer's IP address (e.g., 192.168.1.100)
  // You can find your IP with: ipconfig (Windows) or ifconfig (Mac/Linux)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.228:3000/api', // Android emulator
    // For physical device, change to: 'http://YOUR_IP:3000/api'
    // Example: 'http://192.168.1.100:3000/api'
  );

  // WebSocket URL
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'http://192.168.1.228:3000', // Android emulator
    // For physical device, change to: 'http://YOUR_IP:3000'
  );

  // App Version
  static const String appVersion = '1.0.0';

  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);
}

