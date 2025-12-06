class AppConfig {
  // Backend API
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For physical device, use your computer's IP address
  // Current available IPs on your machine:
  // - 192.168.1.43 (Local WiFi/Ethernet - recommended for same network)
  // - 26.197.138.220 (VPN/Virtual network - for remote connection)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.43:3000/api', // Physical device - Local network
    // Alternative for VPN: 'http://26.197.138.220:3000/api'
  );

  // WebSocket URL
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'http://192.168.1.43:3000', // Physical device - Local network
    // Alternative for VPN: 'http://26.197.138.220:3000'
  );

  // App Version
  static const String appVersion = '1.0.0';

  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 60); // Increased for debugging
}

