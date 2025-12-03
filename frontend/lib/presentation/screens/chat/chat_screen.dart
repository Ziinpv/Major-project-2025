import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/online_status_provider.dart';
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
  
  // Debounce timer for typing event
  Timer? _typingDebounceTimer;
  DateTime? _lastTypingEventSent;
  
  // Other user typing indicator
  bool _otherUserIsTyping = false;
  Timer? _typingIndicatorTimer;

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
      _socketService.on('user-typing', _handleUserTyping);
      _socketService.on('user-online', _handleUserOnline);
      _socketService.on('user-offline', _handleUserOffline);
      _socketService.on('online-users-list', _handleOnlineUsersList);
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
    _socketService.off('user-typing');
    _socketService.off('user-online');
    _socketService.off('user-offline');
    _socketService.off('online-users-list');
    _socketService.leaveChatRoom(widget.chatRoomId);
    ref.read(chatMessagesProvider.notifier).clear();
    _messageController.dispose();
    _scrollController.dispose();
    _typingDebounceTimer?.cancel();
    _typingIndicatorTimer?.cancel();
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

  void _handleUserTyping(dynamic data) {
    if (!mounted) return;
    if (data is! Map<String, dynamic>) return;
    
    final userId = data['userId'] as String?;
    final isTyping = data['isTyping'] as bool? ?? false;
    final currentUserId = ref.read(authProvider).user?.id;
    
    // Ignore own typing events
    if (userId == null || userId == currentUserId) return;
    
    setState(() {
      _otherUserIsTyping = isTyping;
    });
    
    // Auto-hide indicator after 6 seconds if no new typing event
    if (isTyping) {
      _typingIndicatorTimer?.cancel();
      _typingIndicatorTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _otherUserIsTyping = false;
          });
        }
      });
    } else {
      _typingIndicatorTimer?.cancel();
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
  }

  void _handleTypingChange(String value) {
    final now = DateTime.now();
    final shouldSendTypingEvent = _lastTypingEventSent == null || 
        now.difference(_lastTypingEventSent!).inSeconds >= 2;
    
    // Cancel previous debounce timer
    _typingDebounceTimer?.cancel();
    
    if (value.isNotEmpty) {
      // User is typing
      if (!_isTyping && shouldSendTypingEvent) {
        _isTyping = true;
        _lastTypingEventSent = now;
        _socketService.onTyping(widget.chatRoomId, true);
      }
      
      // Set debounce timer to send stop typing after 2 seconds of inactivity
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          _socketService.onTyping(widget.chatRoomId, false);
        }
      });
    } else {
      // Text field is empty, stop typing immediately
      if (_isTyping) {
        _isTyping = false;
        _lastTypingEventSent = now;
        _socketService.onTyping(widget.chatRoomId, false);
      }
    }
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
    final isOtherUserOnline = otherUser?.id != null 
        ? ref.watch(onlineStatusProvider)[otherUser!.id] ?? false
        : false;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherUser?.fullName ?? 'Chat'),
            if (isOtherUserOnline)
              const Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
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
          if (_otherUserIsTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final otherBubbleColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final otherTextColor = isDarkMode ? Colors.white : Colors.black;
    final otherTimeColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE91E63) : otherBubbleColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : otherTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${message.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.white70 : otherTimeColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final otherUser = _chatRoom?.getOtherUser(ref.read(authProvider).user?.id ?? '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${otherUser?.fullName ?? "User"} is typing',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textFieldFillColor = isDarkMode ? Colors.grey[850] : Colors.grey[100];
    
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: textFieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: Color(0xFFE91E63),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (value) {
                  _handleTypingChange(value);
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

