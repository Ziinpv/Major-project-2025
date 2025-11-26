import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/services/socket_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  final ChatRoomModel? initialChatRoom;

  const ChatScreen({super.key, required this.chatRoomId, this.initialChatRoom});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final SocketService _socketService = SocketService();

  ChatRoomModel? _chatRoom;
  bool _isTyping = false;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      final room = widget.initialChatRoom ?? await repository.getChatRoomById(widget.chatRoomId);
      final messages = await repository.getMessages(chatRoomId: widget.chatRoomId);

      setState(() {
        _chatRoom = room;
        _isLoading = false;
      });
      ref.read(chatMessagesProvider.notifier).setMessages(messages);
      _scrollToBottom();

      await repository.markAsRead(widget.chatRoomId);
      await _socketService.connect();
      _socketService.joinChatRoom(widget.chatRoomId);
      _socketService.markAsRead(widget.chatRoomId);

      _socketService.on('new-message', _handleIncomingMessage);
      _socketService.on('messages-read', _handleMessagesRead);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _socketService.off('new-message');
    _socketService.off('messages-read');
    _socketService.leaveChatRoom(widget.chatRoomId);
    ref.read(chatMessagesProvider.notifier).clear();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleIncomingMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    final chatRoomId = data['chatRoomId'] as String?;
    final messageJson = data['message'] as Map<String, dynamic>?;
    if (chatRoomId != widget.chatRoomId || messageJson == null) return;

    final message = MessageModel.fromJson(messageJson);
    final currentUserId = ref.read(authProvider).user?.id;
    final appended = ref
        .read(chatMessagesProvider.notifier)
        .appendFromSocket(message, currentUserId: currentUserId);
    if (appended) {
      _scrollToBottom();
    }

    if (currentUserId != null && message.sender.id != currentUserId) {
      final repository = ref.read(chatRepositoryProvider);
      repository.markAsRead(widget.chatRoomId);
      _socketService.markAsRead(widget.chatRoomId);
    }
  }

  void _handleMessagesRead(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    if (data['chatRoomId'] != widget.chatRoomId) return;
    final userId = data['userId'] as String?;
    final currentUserId = ref.read(authProvider).user?.id;
    if (userId == null || userId == currentUserId) return;

    ref.read(chatMessagesProvider.notifier).markAllAsRead();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _chatRoom == null || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final repository = ref.read(chatRepositoryProvider);
      final message = await repository.sendMessage(
        matchId: _chatRoom!.match,
        content: content,
      );
      _messageController.clear();
      final appended = ref.read(chatMessagesProvider.notifier).appendLocal(message);
      if (appended) {
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi tin nhắn: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).user?.id;
    final otherUser = currentUserId != null ? _chatRoom?.getOtherUser(currentUserId) : null;
    final messages = ref.watch(chatMessagesProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _initialize,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(otherUser?.fullName ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = currentUserId != null && message.sender.id == currentUserId;
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE91E63) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && !_isTyping) {
                    _isTyping = true;
                    _socketService.onTyping(widget.chatRoomId, true);
                  } else if (value.isEmpty && _isTyping) {
                    _isTyping = false;
                    _socketService.onTyping(widget.chatRoomId, false);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: const Color(0xFFE91E63),
            ),
          ],
        ),
      ),
    );
  }
}

