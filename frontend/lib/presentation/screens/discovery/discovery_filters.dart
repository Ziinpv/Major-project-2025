import 'dart:convert';

class DiscoveryFilters {
  final int ageMin;
  final int ageMax;
  final int distance;
  final List<String> lifestyle;
  final List<String> interests;
  final List<String> showMe;
  final bool onlyOnline;
  final String sort;

  const DiscoveryFilters({
    required this.ageMin,
    required this.ageMax,
    required this.distance,
    this.lifestyle = const [],
    this.interests = const [],
    this.showMe = const [],
    this.onlyOnline = false,
    this.sort = 'best',
  });

  DiscoveryFilters copyWith({
    int? ageMin,
    int? ageMax,
    int? distance,
    List<String>? lifestyle,
    List<String>? interests,
    List<String>? showMe,
    bool? onlyOnline,
    String? sort,
  }) {
    return DiscoveryFilters(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      distance: distance ?? this.distance,
      lifestyle: lifestyle ?? this.lifestyle,
      interests: interests ?? this.interests,
      showMe: showMe ?? this.showMe,
      onlyOnline: onlyOnline ?? this.onlyOnline,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      'ageMin': ageMin,
      'ageMax': ageMax,
      'distance': distance,
      if (lifestyle.isNotEmpty) 'lifestyle': lifestyle,
      if (interests.isNotEmpty) 'interests': interests,
      if (showMe.isNotEmpty) 'showMe': showMe,
      'onlyOnline': onlyOnline,
      'sort': sort,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'ageMin': ageMin,
      'ageMax': ageMax,
      'distance': distance,
      'lifestyle': lifestyle,
      'interests': interests,
      'showMe': showMe,
      'onlyOnline': onlyOnline,
      'sort': sort,
    };
  }

  String toPrefsString() => jsonEncode(toJson());

  static DiscoveryFilters fromJson(Map<String, dynamic> json) {
    return DiscoveryFilters(
      ageMin: json['ageMin'] as int? ?? 20,
      ageMax: json['ageMax'] as int? ?? 35,
      distance: json['distance'] as int? ?? 50,
      lifestyle: (json['lifestyle'] as List<dynamic>? ?? const []).cast<String>(),
      interests: (json['interests'] as List<dynamic>? ?? const []).cast<String>(),
      showMe: (json['showMe'] as List<dynamic>? ?? const []).cast<String>(),
      onlyOnline: json['onlyOnline'] as bool? ?? false,
      sort: json['sort'] as String? ?? 'best',
    );
  }

  static DiscoveryFilters defaults() {
    return const DiscoveryFilters(
      ageMin: 20,
      ageMax: 35,
      distance: 50,
      showMe: ['male', 'female'],
      lifestyle: [],
      interests: [],
      onlyOnline: false,
      sort: 'best',
    );
  }
}

class FilterOption {
  final String id;
  final String label;

  const FilterOption({required this.id, required this.label});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: json['id'] as String,
      label: json['label'] as String? ?? json['id'] as String,
    );
  }
}

