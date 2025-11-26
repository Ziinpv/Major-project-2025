import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      try {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          token: token,
        );
      } catch (e) {
        // Token invalid, clear it
        await prefs.remove('auth_token');
      }
    }
  }

  Future<void> loginWithFirebase(String firebaseToken) async {
    debugPrint('=== AuthProvider: loginWithFirebase called ===');
    debugPrint('=== Token length: ${firebaseToken.length} ===');
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('=== Calling authRepository.loginWithFirebase ===');
      final result = await _authRepository.loginWithFirebase(firebaseToken);
      debugPrint('=== Login result received ===');
      debugPrint('=== User ID: ${result['user']?.id} ===');
      debugPrint('=== Token: ${result['token']?.substring(0, 20)}... ===');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token']);
      debugPrint('=== Token saved to SharedPreferences ===');
      
      state = state.copyWith(
        isAuthenticated: true,
        user: result['user'],
        token: result['token'],
        isLoading: false,
      );
      debugPrint('=== Auth state updated successfully ===');
    } catch (e, stackTrace) {
      debugPrint('=== AuthProvider ERROR: $e ===');
      debugPrint('=== Stack trace: $stackTrace ===');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> registerWithFirebase(String firebaseToken, Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.registerWithFirebase(firebaseToken, userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token']);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: result['user'],
        token: result['token'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // If refresh fails, user might be logged out
      print('Failed to refresh user: $e');
    }
  }

  void updateUserLocally(UserModel user) {
    state = state.copyWith(user: user, isAuthenticated: true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

