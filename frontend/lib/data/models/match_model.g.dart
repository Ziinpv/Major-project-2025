// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) => MatchModel(
      id: json['id'] as String,
      users: (json['users'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      unmatchedAt: json['unmatchedAt'] == null
          ? null
          : DateTime.parse(json['unmatchedAt'] as String),
      unmatchedBy: json['unmatchedBy'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      lastMessage: json['lastMessage'] as String?,
    );

Map<String, dynamic> _$MatchModelToJson(MatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'users': instance.users,
      'matchedAt': instance.matchedAt.toIso8601String(),
      'isActive': instance.isActive,
      'unmatchedAt': instance.unmatchedAt?.toIso8601String(),
      'unmatchedBy': instance.unmatchedBy,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'lastMessage': instance.lastMessage,
    };
