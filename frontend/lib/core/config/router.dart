import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile/profile_setup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/discovery/discovery_screen.dart';
import '../../presentation/screens/matches/matches_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../data/models/chat_room_model.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../data/providers/auth_provider.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isProfileComplete = authState.user?.isProfileComplete ?? false;
      final isOnAuthRoute = state.matchedLocation.startsWith('/auth');

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isOnAuthRoute) {
        return '/auth/login';
      }

      // If authenticated but profile not complete, redirect to profile setup
      if (isAuthenticated && !isProfileComplete && !state.matchedLocation.startsWith('/profile/setup')) {
        return '/profile/setup';
      }

      // If authenticated and profile complete, allow access
      if (isAuthenticated && isProfileComplete && isOnAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile/setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/discovery',
        builder: (context, state) => const DiscoveryScreen(),
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MatchesScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatRoomId',
        builder: (context, state) {
          final chatRoomId = state.pathParameters['chatRoomId']!;
          final chatRoom = state.extra is ChatRoomModel ? state.extra as ChatRoomModel : null;
          return ChatScreen(chatRoomId: chatRoomId, initialChatRoom: chatRoom);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

