import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/online_status_provider.dart';
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
    _socketService.on('user-online', _handleUserOnline);
    _socketService.on('user-offline', _handleUserOffline);
    _socketService.on('online-users-list', _handleOnlineUsersList);
    await _loadChatRooms();
  }

  @override
  void dispose() {
    _socketService.off('new-message');
    _socketService.off('match:created');
    _socketService.off('user-online');
    _socketService.off('user-offline');
    _socketService.off('online-users-list');
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

  void _handleUserOnline(dynamic data) {
    if (!mounted) return;
    if (data is! Map<String, dynamic>) return;
    
    final userId = data['userId'] as String?;
    if (userId == null) return;
    
    ref.read(onlineStatusProvider.notifier).setUserOnline(userId);
  }

  void _handleUserOffline(dynamic data) {
    if (!mounted) return;
    if (data is! Map<String, dynamic>) return;
    
    final userId = data['userId'] as String?;
    if (userId == null) return;
    
    ref.read(onlineStatusProvider.notifier).setUserOffline(userId);
  }

  void _handleOnlineUsersList(dynamic data) {
    if (!mounted) return;
    if (data is! Map<String, dynamic>) return;
    
    final userIds = data['userIds'] as List?;
    if (userIds == null) return;
    
    // Mark all users in the list as online
    for (var userId in userIds) {
      if (userId is String) {
        ref.read(onlineStatusProvider.notifier).setUserOnline(userId);
      }
    }
    
    print('📋 Received online users list: ${userIds.length} users online');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chat_title),
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
    final l10n = context.l10n;
    
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
            Text('${l10n.chat_list_load_error}.\n$_error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadChatRooms,
              child: Text(l10n.common_retry),
            ),
          ],
        ),
      );
    }
    if (_chatRooms.isEmpty) {
      return Center(child: Text(l10n.chat_list_empty));
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
    final l10n = context.l10n;
    final otherUser = currentUserId != null
        ? chatRoom.getOtherUser(currentUserId)
        : chatRoom.participants.isNotEmpty
            ? chatRoom.participants.first
            : null;
    final unreadCount = currentUserId != null ? chatRoom.getUnreadCount(currentUserId) : 0;
    final lastMessageTime = chatRoom.lastMessageAt != null
        ? DateFormat('dd/MM HH:mm').format(chatRoom.lastMessageAt!.toLocal())
        : '';
    final isOnline = otherUser?.id != null 
        ? ref.watch(onlineStatusProvider)[otherUser!.id] ?? false
        : false;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: otherUser?.primaryPhoto != null
                ? CachedNetworkImageProvider(otherUser!.primaryPhoto!)
                : null,
            child: otherUser?.primaryPhoto == null
                ? Text(otherUser?.firstName.substring(0, 1) ?? '?')
                : null,
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        otherUser?.fullName ?? l10n.chat_room_other_user_unknown,
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chatRoom.lastMessage?.content ?? l10n.chat_no_messages,
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
