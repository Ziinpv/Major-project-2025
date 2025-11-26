import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, ThemeMode>((ref) {
  return AppThemeNotifier();
});

class AppThemeNotifier extends StateNotifier<ThemeMode> {
  AppThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('theme_mode');
    if (stored != null) {
      state = ThemeMode.values
          .firstWhere((element) => element.name == stored, orElse: () => ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }
}

