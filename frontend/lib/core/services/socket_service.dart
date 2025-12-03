import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SocketService {
  IO.Socket? _socket;
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;
  SocketService._internal();

  Future<void> connect() async {
    if (_socket?.connected ?? false) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _socket = IO.io(
      AppConfig.wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected at ${DateTime.now().toLocal()}');
      _socket!.emit('join-chat-rooms');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected at ${DateTime.now().toLocal()}');
    });

    _socket!.onError((error) {
      print('⚠️ Socket error: $error');
    });

    _socket!.onConnectError((error) {
      print('⚠️ Socket connect error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinChatRoom(String chatRoomId) {
    _socket?.emit('join-chat-room', chatRoomId);
  }

  void leaveChatRoom(String chatRoomId) {
    _socket?.emit('leave-chat-room', chatRoomId);
  }

  void sendMessage(String chatRoomId, String content, {String? type, String? mediaUrl}) {
    _socket?.emit('send-message', {
      'chatRoomId': chatRoomId,
      'content': content,
      'type': type ?? 'text',
      'mediaUrl': mediaUrl,
    });
  }

  void onTyping(String chatRoomId, bool isTyping) {
    _socket?.emit('typing', {
      'chatRoomId': chatRoomId,
      'isTyping': isTyping,
    });
  }

  void markAsRead(String chatRoomId) {
    _socket?.emit('mark-read', {'chatRoomId': chatRoomId});
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  bool get isConnected => _socket?.connected ?? false;
}

