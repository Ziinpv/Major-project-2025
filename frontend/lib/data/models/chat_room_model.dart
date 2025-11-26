import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'message_model.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel {
  final String id;
  final String match;
  final List<UserModel> participants;
  final MessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatRoomModel({
    required this.id,
    required this.match,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => _$ChatRoomModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomModelToJson(this);

  UserModel? getOtherUser(String currentUserId) {
    return participants.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => participants.first,
    );
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

