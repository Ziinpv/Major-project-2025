import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../core/services/socket_service.dart';
import 'online_status_provider.dart';

/// Provider that automatically manages socket connection based on auth state
class SocketConnectionNotifier extends StateNotifier<bool> {
  final Ref ref;
  final SocketService _socketService = SocketService();
  bool _isInitialized = false;

  SocketConnectionNotifier(this.ref) : super(false) {
    _initSocketConnection();
  }

  Future<void> _initSocketConnection() async {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) async {
      if (next.isAuthenticated && !_isInitialized) {
        await _connectSocket();
      } else if (!next.isAuthenticated && _isInitialized) {
        _disconnectSocket();
      }
    });

    // Check initial auth state
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && !_isInitialized) {
      await _connectSocket();
    }
  }

  Future<void> _connectSocket() async {
    if (_isInitialized) return;

    try {
      await _socketService.connect();
      
      // Setup global listeners for online/offline status
      _socketService.on('user-online', (data) {
        if (data is Map<String, dynamic>) {
          final userId = data['userId'] as String?;
          if (userId != null) {
            ref.read(onlineStatusProvider.notifier).setUserOnline(userId);
            print('📗 User $userId is now online');
          }
        }
      });

      _socketService.on('user-offline', (data) {
        if (data is Map<String, dynamic>) {
          final userId = data['userId'] as String?;
          if (userId != null) {
            ref.read(onlineStatusProvider.notifier).setUserOffline(userId);
            print('📕 User $userId is now offline');
          }
        }
      });

      _socketService.on('online-users-list', (data) {
        if (data is Map<String, dynamic>) {
          final userIds = data['userIds'] as List?;
          if (userIds != null) {
            for (var userId in userIds) {
              if (userId is String) {
                ref.read(onlineStatusProvider.notifier).setUserOnline(userId);
              }
            }
            print('📋 Loaded ${userIds.length} online users');
          }
        }
      });

      _isInitialized = true;
      state = true;
      print('✅ Global socket connection established');
    } catch (e) {
      print('❌ Failed to connect socket: $e');
      state = false;
    }
  }

  void _disconnectSocket() {
    _socketService.off('user-online');
    _socketService.off('user-offline');
    _socketService.off('online-users-list');
    _socketService.disconnect();
    _isInitialized = false;
    state = false;
    
    // Clear online status when disconnecting
    ref.read(onlineStatusProvider.notifier).clear();
    print('🔌 Socket disconnected');
  }

  @override
  void dispose() {
    _disconnectSocket();
    super.dispose();
  }
}

final socketConnectionProvider =
    StateNotifierProvider<SocketConnectionNotifier, bool>((ref) {
  return SocketConnectionNotifier(ref);
});

