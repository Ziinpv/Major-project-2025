import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatRoomsProvider = FutureProvider<List<ChatRoomModel>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getChatRooms();
});

final chatRoomProvider = FutureProvider.family<ChatRoomModel, String>((ref, matchId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getChatRoomByMatch(matchId);
});

final messagesProvider = FutureProvider.family<List<MessageModel>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getMessages(
    chatRoomId: params['chatRoomId'] as String,
    limit: params['limit'] as int? ?? 50,
    before: params['before'] as DateTime?,
  );
});

class ChatMessagesNotifier extends StateNotifier<List<MessageModel>> {
  ChatMessagesNotifier() : super([]);

  final Set<String> _messageIds = {};
  final Set<String> _pendingLocalIds = {};

  void clear() {
    state = [];
    _messageIds.clear();
    _pendingLocalIds.clear();
  }

  void setMessages(List<MessageModel> messages) {
    state = List<MessageModel>.from(messages);
    _messageIds
      ..clear()
      ..addAll(messages.map((m) => m.id));
    _pendingLocalIds.clear();
  }

  /// Returns true if the message was newly appended.
  bool append(MessageModel message) {
    if (_messageIds.contains(message.id)) {
      state = [
        for (final existing in state) existing.id == message.id ? message : existing,
      ];
      return false;
    }
    state = [...state, message];
    _messageIds.add(message.id);
    return true;
  }

  /// Append message created locally (via REST) and track it to ignore socket echo.
  bool appendLocal(MessageModel message) {
    final appended = append(message);
    if (appended) {
      _pendingLocalIds.add(message.id);
    }
    return appended;
  }

  /// Append message coming from socket. Returns true if UI should scroll.
  bool appendFromSocket(MessageModel message, {String? currentUserId}) {
    final isOwnMessage =
      currentUserId != null && message.sender.id == currentUserId;

    if (isOwnMessage && _pendingLocalIds.contains(message.id)) {
      _pendingLocalIds.remove(message.id);
      return false;
    }

    return append(message);
  }

  void appendMany(Iterable<MessageModel> messages) {
    if (messages.isEmpty) return;
    final updated = List<MessageModel>.from(state);
    var changed = false;
    for (final message in messages) {
      if (_messageIds.contains(message.id)) continue;
      updated.add(message);
      _messageIds.add(message.id);
      changed = true;
    }
    if (changed) {
      state = updated;
    }
  }

  void markAllAsRead() {
    state = state
        .map((message) => message.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
  }
}

final chatMessagesProvider =
    StateNotifierProvider.autoDispose<ChatMessagesNotifier, List<MessageModel>>(
  (ref) => ChatMessagesNotifier(),
);

