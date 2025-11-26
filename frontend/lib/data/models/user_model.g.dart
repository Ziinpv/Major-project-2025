// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      interestedIn: (json['interestedIn'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String?,
      photos: (json['photos'] as List<dynamic>)
          .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      lifestyle: (json['lifestyle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      job: json['job'] as String?,
      school: json['school'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      lastActive: json['lastActive'] == null
          ? null
          : DateTime.parse(json['lastActive'] as String),
      preferences: json['preferences'] == null
          ? null
          : PreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>),
      matchScore: (json['score'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      scoreBreakdown: json['scoreBreakdown'] == null
          ? null
          : ScoreBreakdownModel.fromJson(
              json['scoreBreakdown'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'firebaseUid': instance.firebaseUid,
      'email': instance.email,
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'interestedIn': instance.interestedIn,
      'bio': instance.bio,
      'photos': instance.photos,
      'location': instance.location,
      'interests': instance.interests,
      'lifestyle': instance.lifestyle,
      'job': instance.job,
      'school': instance.school,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'isProfileComplete': instance.isProfileComplete,
      'lastActive': instance.lastActive?.toIso8601String(),
      'preferences': instance.preferences,
      'score': instance.matchScore,
      'distanceKm': instance.distanceKm,
      'scoreBreakdown': instance.scoreBreakdown,
    };

PhotoModel _$PhotoModelFromJson(Map<String, dynamic> json) => PhotoModel(
      id: json['id'] as String?,
      url: json['url'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PhotoModelToJson(PhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'isPrimary': instance.isPrimary,
      'order': instance.order,
    };

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
      'country': instance.country,
      'coordinates': instance.coordinates,
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
    };

PreferencesModel _$PreferencesModelFromJson(Map<String, dynamic> json) =>
    PreferencesModel(
      ageRange:
          AgeRangeModel.fromJson(json['ageRange'] as Map<String, dynamic>),
      maxDistance: (json['maxDistance'] as num).toInt(),
      showMe:
          (json['showMe'] as List<dynamic>).map((e) => e as String).toList(),
      lifestyle: (json['lifestyle'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      onlyShowOnline: json['onlyShowOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$PreferencesModelToJson(PreferencesModel instance) =>
    <String, dynamic>{
      'ageRange': instance.ageRange,
      'maxDistance': instance.maxDistance,
      'showMe': instance.showMe,
      'lifestyle': instance.lifestyle,
      'onlyShowOnline': instance.onlyShowOnline,
    };

AgeRangeModel _$AgeRangeModelFromJson(Map<String, dynamic> json) =>
    AgeRangeModel(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$AgeRangeModelToJson(AgeRangeModel instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

ScoreBreakdownModel _$ScoreBreakdownModelFromJson(Map<String, dynamic> json) =>
    ScoreBreakdownModel(
      interests: (json['interests'] as num?)?.toDouble(),
      lifestyle: (json['lifestyle'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toDouble(),
      activity: (json['activity'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ScoreBreakdownModelToJson(
        ScoreBreakdownModel instance) =>
    <String, dynamic>{
      'interests': instance.interests,
      'lifestyle': instance.lifestyle,
      'age': instance.age,
      'activity': instance.activity,
      'distance': instance.distance,
    };
