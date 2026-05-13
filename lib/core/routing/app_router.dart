import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_create_poll_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/polls/screens/poll_archive_screen.dart';
import '../../features/polls/screens/poll_detail_screen.dart';
import '../../features/polls/screens/poll_result_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../constants/app_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/polls',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/polls';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/polls',
            builder: (context, state) => const PollArchiveScreen(showActiveOnly: true),
          ),
          GoRoute(
            path: '/archive',
            builder: (context, state) => const PollArchiveScreen(showActiveOnly: false),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/polls/:pollId',
        builder: (context, state) => PollDetailScreen(
          pollId: state.pathParameters['pollId']!,
        ),
      ),
      GoRoute(
        path: '/polls/:pollId/result',
        builder: (context, state) => PollResultScreen(
          pollId: state.pathParameters['pollId']!,
        ),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) async {
          final user = ref.read(currentUserProvider).valueOrNull;
          if (user?.role != AppConstants.adminRole) return '/polls';
          return null;
        },
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/create',
        builder: (context, state) => const AdminCreatePollScreen(),
      ),
      GoRoute(
        path: '/admin/edit/:pollId',
        builder: (context, state) => AdminCreatePollScreen(
          pollId: state.pathParameters['pollId'],
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
    ),
  );
});
