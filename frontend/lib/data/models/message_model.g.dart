// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      chatRoom: json['chatRoom'] as String,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatRoom': instance.chatRoom,
      'sender': instance.sender,
      'content': instance.content,
      'type': instance.type,
      'mediaUrl': instance.mediaUrl,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
