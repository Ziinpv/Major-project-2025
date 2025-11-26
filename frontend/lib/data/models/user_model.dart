import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String? firebaseUid;
  final String? email;
  final String? phone;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;
  final String gender;
  final List<String> interestedIn;
  final String? bio;
  final List<PhotoModel> photos;
  final LocationModel? location;
  final List<String> interests;
  final List<String> lifestyle;
  final String? job;
  final String? school;
  final bool isVerified;
  final bool isActive;
  final bool isProfileComplete;
  final DateTime? lastActive;
  final PreferencesModel? preferences;
  @JsonKey(name: 'score')
  final double? matchScore;
  @JsonKey(name: 'distanceKm')
  final double? distanceKm;
  @JsonKey(name: 'scoreBreakdown')
  final ScoreBreakdownModel? scoreBreakdown;

  UserModel({
    required this.id,
    this.firebaseUid,
    this.email,
    this.phone,
    required this.firstName,
    this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.interestedIn,
    this.bio,
    required this.photos,
    this.location,
    required this.interests,
    this.lifestyle = const [],
    this.job,
    this.school,
    this.isVerified = false,
    this.isActive = true,
    this.isProfileComplete = false,
    this.lastActive,
    this.preferences,
    this.matchScore,
    this.distanceKm,
    this.scoreBreakdown,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get fullName => '$firstName ${lastName ?? ''}'.trim();
  String? get primaryPhoto {
    final primary = photos.firstWhere(
      (p) => p.isPrimary,
      orElse: () => photos.isNotEmpty ? photos.first : PhotoModel(url: '', isPrimary: false, order: 0),
    );
    return primary.url;
  }
}

@JsonSerializable()
class PhotoModel {
  final String? id;
  final String url;
  final bool isPrimary;
  final int order;

  PhotoModel({
    this.id,
    required this.url,
    this.isPrimary = false,
    this.order = 0,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => _$PhotoModelFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoModelToJson(this);
}

@JsonSerializable()
class LocationModel {
  final String? province;
  final String? city;
  final String? district;
  final String? address;
  final String? country;
  final List<double>? coordinates;
  final DateTime? lastUpdatedAt;

  LocationModel({
    this.province,
    this.city,
    this.district,
    this.address,
    this.country,
    this.coordinates,
    this.lastUpdatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonSerializable()
class PreferencesModel {
  final AgeRangeModel ageRange;
  final int maxDistance;
  final List<String> showMe;
  final List<String> lifestyle;
  final bool onlyShowOnline;

  PreferencesModel({
    required this.ageRange,
    required this.maxDistance,
    required this.showMe,
    this.lifestyle = const [],
    this.onlyShowOnline = false,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) => _$PreferencesModelFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesModelToJson(this);
}

@JsonSerializable()
class AgeRangeModel {
  final int min;
  final int max;

  AgeRangeModel({
    required this.min,
    required this.max,
  });

  factory AgeRangeModel.fromJson(Map<String, dynamic> json) => _$AgeRangeModelFromJson(json);
  Map<String, dynamic> toJson() => _$AgeRangeModelToJson(this);
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

@JsonSerializable()
class ScoreBreakdownModel {
  final double? interests;
  final double? lifestyle;
  final double? age;
  final double? activity;
  final double? distance;

  ScoreBreakdownModel({
    this.interests,
    this.lifestyle,
    this.age,
    this.activity,
    this.distance,
  });

  factory ScoreBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreBreakdownModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreBreakdownModelToJson(this);
}

