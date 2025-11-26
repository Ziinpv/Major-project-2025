import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/discovery_filters.dart';
import '../models/filter_option.dart';

final discoveryFiltersProvider =
    StateNotifierProvider<DiscoveryFiltersNotifier, DiscoveryFilters>((ref) {
  return DiscoveryFiltersNotifier();
});

class DiscoveryFiltersNotifier extends StateNotifier<DiscoveryFilters> {
  DiscoveryFiltersNotifier() : super(const DiscoveryFilters()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(DiscoveryFilters.storageKey());
    state = DiscoveryFilters.fromStorageString(raw);
  }

  Future<void> updateFilters(DiscoveryFilters filters) async {
    state = filters;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      DiscoveryFilters.storageKey(),
      filters.toStorageString(),
    );
  }

  Future<void> setSort(String sort) => updateFilters(state.copyWith(sort: sort));
}

Future<List<FilterOption>> _loadOptions(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final List<dynamic> parsed = jsonDecode(jsonString) as List<dynamic>;
  return parsed
      .map((item) => FilterOption.fromJson(item as Map<String, dynamic>))
      .toList();
}

final interestOptionsProvider = FutureProvider<List<FilterOption>>((ref) async {
  return _loadOptions('assets/data/interests.json');
});

final lifestyleOptionsProvider = FutureProvider<List<FilterOption>>((ref) async {
  return _loadOptions('assets/data/lifestyles.json');
});

