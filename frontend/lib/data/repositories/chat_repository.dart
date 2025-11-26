import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../../core/services/api_service.dart';

class ChatRepository {
  final _api = ApiService();

  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await _api.get('/chat/rooms');
    if (response.statusCode == 200) {
      final rooms = response.data['data']['chatRooms'] as List;
      return rooms.map((room) => ChatRoomModel.fromJson(room)).toList();
    } else {
      throw Exception('Failed to get chat rooms');
    }
  }

  Future<ChatRoomModel> getChatRoomByMatch(String matchId) async {
    final response = await _api.get('/chat/rooms/$matchId');
    if (response.statusCode == 200) {
      return ChatRoomModel.fromJson(response.data['data']['chatRoom']);
    } else {
      throw Exception('Failed to get chat room');
    }
  }

  Future<ChatRoomModel> getChatRoomById(String chatRoomId) async {
    final response = await _api.get('/chat/room-id/$chatRoomId');
    if (response.statusCode == 200) {
      return ChatRoomModel.fromJson(response.data['data']['chatRoom']);
    } else {
      throw Exception('Failed to get chat room');
    }
  }

  Future<MessageModel> sendMessage({
    required String matchId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) async {
    final response = await _api.post('/chat/messages', data: {
      'matchId': matchId,
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
    });
    if (response.statusCode == 201) {
      return MessageModel.fromJson(response.data['data']['message']);
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<List<MessageModel>> getMessages({
    required String chatRoomId,
    int limit = 50,
    DateTime? before,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (before != null) {
      queryParams['before'] = before.toIso8601String();
    }

    final response = await _api.get(
      '/chat/rooms/$chatRoomId/messages',
      queryParameters: queryParams,
    );
    if (response.statusCode == 200) {
      final messages = response.data['data']['messages'] as List;
      return messages.map((msg) => MessageModel.fromJson(msg)).toList();
    } else {
      throw Exception('Failed to get messages');
    }
  }

  Future<void> markAsRead(String chatRoomId) async {
    final response = await _api.put('/chat/rooms/$chatRoomId/read');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read');
    }
  }
}

