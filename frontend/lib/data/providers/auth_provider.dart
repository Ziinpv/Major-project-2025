import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/api_service.dart';

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
  final _streamController = StreamController<AuthState>.broadcast();

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _loadAuthState();
  }

  Stream<AuthState> get stream => _streamController.stream;

  @override
  set state(AuthState newState) {
    super.state = newState;
    _streamController.add(newState);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
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

  Future<bool> changePassword(String oldPass, String newPass) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final providerId = user.providerData.first.providerId;

      if (providerId == "password") {
        // Email/Password user → dùng password xác thực
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPass,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPass);
        return true;

      } else if (providerId == "google.com") {
        // Google user → không cho đổi password
        // Vì password thuộc Google, không thuộc Firebase App
        return false;
      }

      return false;
    } catch (e) {
      debugPrint("CHANGE PASSWORD ERROR: $e");
      return false;
    }
  }

  Future<bool> deleteAccount(String passwordInput) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final firebaseUid = FirebaseAuth.instance.currentUser!.uid;
      final providerId = user.providerData.first.providerId;

      // 1 — Reauthenticate
      if (providerId == "password") {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: passwordInput,
        );
        await user.reauthenticateWithCredential(cred);

      } else if (providerId == "google.com") {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return false;

        final googleAuth = await googleUser.authentication;
        final cred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await user.reauthenticateWithCredential(cred);
      }

      // 2 — Delete Firebase account
      await user.delete();

      // 3 — Delete on MongoDB
      final res = await ApiService().delete("/users/delete/$firebaseUid");

      if (res.statusCode != 200) {
        debugPrint("DELETE MONGO FAILED");
        return false;
      }

      // 4 — Clear local token
      final prefs = await SharedPreferences.getInstance();
      prefs.remove("auth_token");

      // 5 — Logout Google if needed
      await GoogleSignIn().signOut();

      // 6 — Reset state
      state = AuthState();

      return true;

    } catch (e) {
      debugPrint("DELETE ACCOUNT ERROR: $e");
      return false;
    }
  }


}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

