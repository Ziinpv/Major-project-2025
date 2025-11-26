import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String chatRoom;
  final UserModel sender;
  final String content;
  final String type;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? readAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.chatRoom,
    required this.sender,
    required this.content,
    this.type = 'text',
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id,
      chatRoom: chatRoom,
      sender: sender,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

