import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'match_model.g.dart';

@JsonSerializable()
class MatchModel {
  final String id;
  final List<UserModel> users;
  final DateTime matchedAt;
  final bool isActive;
  final DateTime? unmatchedAt;
  final String? unmatchedBy;
  final DateTime? lastMessageAt;
  final String? lastMessage;

  MatchModel({
    required this.id,
    required this.users,
    required this.matchedAt,
    this.isActive = true,
    this.unmatchedAt,
    this.unmatchedBy,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) => _$MatchModelFromJson(json);
  Map<String, dynamic> toJson() => _$MatchModelToJson(this);

  UserModel? getOtherUser(String currentUserId) {
    return users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => users.first,
    );
  }
}

