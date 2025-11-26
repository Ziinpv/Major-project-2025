import 'dart:convert';

const _defaultAgeMin = 18;
const _defaultAgeMax = 35;
const _defaultDistance = 50;
const _filtersStorageKey = 'discovery_filters';

class DiscoveryFilters {
  final int ageMin;
  final int ageMax;
  final int distance;
  final bool noDistanceLimit;
  final List<String> lifestyle;
  final List<String> interests;
  final List<String> showMe;
  final bool onlyOnline;
  final String sort;

  const DiscoveryFilters({
    this.ageMin = _defaultAgeMin,
    this.ageMax = _defaultAgeMax,
    this.distance = _defaultDistance,
    this.noDistanceLimit = false,
    this.lifestyle = const [],
    this.interests = const [],
    this.showMe = const ['male', 'female'],
    this.onlyOnline = false,
    this.sort = 'best',
  });

  DiscoveryFilters copyWith({
    int? ageMin,
    int? ageMax,
    int? distance,
    bool? noDistanceLimit,
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
      noDistanceLimit: noDistanceLimit ?? this.noDistanceLimit,
      lifestyle: lifestyle ?? this.lifestyle,
      interests: interests ?? this.interests,
      showMe: showMe ?? this.showMe,
      onlyOnline: onlyOnline ?? this.onlyOnline,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'ageMin': ageMin,
      'ageMax': ageMax,
      'distance': noDistanceLimit ? 1000 : distance,
      if (lifestyle.isNotEmpty) 'lifestyle': lifestyle,
      if (interests.isNotEmpty) 'interests': interests,
      if (showMe.isNotEmpty) 'showMe': showMe,
      'onlyOnline': onlyOnline,
      'sort': sort,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'ageMin': ageMin,
      'ageMax': ageMax,
      'distance': distance,
      'noDistanceLimit': noDistanceLimit,
      'lifestyle': lifestyle,
      'interests': interests,
      'showMe': showMe,
      'onlyOnline': onlyOnline,
      'sort': sort,
    };
  }

  static DiscoveryFilters fromMap(Map<String, dynamic> map) {
    return DiscoveryFilters(
      ageMin: map['ageMin'] as int? ?? _defaultAgeMin,
      ageMax: map['ageMax'] as int? ?? _defaultAgeMax,
      distance: map['distance'] as int? ?? _defaultDistance,
      noDistanceLimit: map['noDistanceLimit'] as bool? ?? false,
      lifestyle: List<String>.from(map['lifestyle'] as List? ?? []),
      interests: List<String>.from(map['interests'] as List? ?? []),
      showMe: List<String>.from(map['showMe'] as List? ?? ['male', 'female']),
      onlyOnline: map['onlyOnline'] as bool? ?? false,
      sort: map['sort'] as String? ?? 'best',
    );
  }

  static DiscoveryFilters fromStorageString(String? raw) {
    if (raw == null || raw.isEmpty) return const DiscoveryFilters();
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return fromMap(decoded);
    } catch (_) {
      return const DiscoveryFilters();
    }
  }

  static String storageKey() => _filtersStorageKey;

  String toStorageString() => jsonEncode(toMap());
}

