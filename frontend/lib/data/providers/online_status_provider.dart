import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track online status of users
class OnlineStatusNotifier extends StateNotifier<Map<String, bool>> {
  OnlineStatusNotifier() : super({});

  void setUserOnline(String userId) {
    state = {...state, userId: true};
  }

  void setUserOffline(String userId) {
    state = {...state, userId: false};
  }

  bool isUserOnline(String userId) {
    return state[userId] ?? false;
  }

  void clear() {
    state = {};
  }
}

final onlineStatusProvider =
    StateNotifierProvider<OnlineStatusNotifier, Map<String, bool>>((ref) {
  return OnlineStatusNotifier();
});

