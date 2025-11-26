import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final textScaleProvider =
    StateNotifierProvider<TextScaleNotifier, double>((ref) {
  return TextScaleNotifier();
});

class TextScaleNotifier extends StateNotifier<double> {
  TextScaleNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble('text_scale');
    if (stored != null) {
      state = stored.clamp(0.9, 1.3);
    }
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(0.9, 1.3);
    state = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', clamped);
  }
}

