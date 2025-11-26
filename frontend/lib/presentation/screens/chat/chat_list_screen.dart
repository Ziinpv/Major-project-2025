import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../core/services/socket_service.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final SocketService _socketService = SocketService();
  List<ChatRoomModel> _chatRooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _socketService.connect();
    _socketService.on('new-message', _handleRealtimeUpdate);
    _socketService.on('match:created', (_) => _loadChatRooms(silent: true));
    await _loadChatRooms();
  }

  @override
  void dispose() {
    _socketService.off('new-message');
    _socketService.off('match:created');
    super.dispose();
  }

  Future<void> _loadChatRooms({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final repository = ref.read(chatRepositoryProvider);
      final rooms = await repository.getChatRooms();
      if (!mounted) return;
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _handleRealtimeUpdate(dynamic data) {
    if (data is Map<String, dynamic>) {
      final chatRoomId = data['chatRoomId'] as String?;
      if (chatRoomId == null) return;
      _loadChatRooms(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadChatRooms(),
          )
        ],
      ),
      body: _buildBody(currentUserId),
    );
  }

  Widget _buildBody(String? currentUserId) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadChatRooms,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_chatRooms.isEmpty) {
      return const Center(child: Text('Chưa có cuộc trò chuyện nào'));
    }
    return RefreshIndicator(
      onRefresh: () => _loadChatRooms(),
      child: ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          return _buildChatRoomTile(chatRoom, currentUserId);
        },
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoomModel chatRoom, String? currentUserId) {
    final otherUser = currentUserId != null
        ? chatRoom.getOtherUser(currentUserId)
        : chatRoom.participants.isNotEmpty
            ? chatRoom.participants.first
            : null;
    final unreadCount = currentUserId != null ? chatRoom.getUnreadCount(currentUserId) : 0;
    final lastMessageTime = chatRoom.lastMessageAt != null
        ? DateFormat('dd/MM HH:mm').format(chatRoom.lastMessageAt!)
        : '';

    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: otherUser?.primaryPhoto != null
            ? CachedNetworkImageProvider(otherUser!.primaryPhoto!)
            : null,
        child: otherUser?.primaryPhoto == null
            ? Text(otherUser?.firstName.substring(0, 1) ?? '?')
            : null,
      ),
      title: Text(
        otherUser?.fullName ?? 'Ẩn danh',
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chatRoom.lastMessage?.content ?? 'Chưa có tin nhắn',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.push('/chat/${chatRoom.id}', extra: chatRoom),
    );
  }
}

