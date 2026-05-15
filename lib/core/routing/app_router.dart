import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_create_poll_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_docs_screen.dart';
import '../../features/admin/screens/admin_moderation_screen.dart';
import '../../features/admin/screens/admin_signin_screen.dart';
import '../../features/admin/screens/admin_stats_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/marketing/screens/landing_screen.dart';
import '../../features/polls/screens/poll_archive_screen.dart';
import '../../features/polls/screens/poll_detail_screen.dart';
import '../../features/polls/screens/poll_result_screen.dart';
import '../../features/profile/screens/persona_report_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../services/admin_allowlist_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: kIsWeb ? '/' : '/polls',
    redirect: (context, state) async {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;

      final isMarketing = location == '/' || location == '/admin/docs';
      final isAdminRoute = location.startsWith('/admin');
      final isAdminSignin = location == '/admin/signin';
      final isLoginRoute = location == '/login';

      // ─── Web flow ───────────────────────────────────────────
      if (kIsWeb) {
        // Marketing pages always public
        if (isMarketing) return null;

        // Admin sign-in always reachable
        if (isAdminSignin) {
          // If already signed in AND allowed, send to dashboard
          if (isLoggedIn) {
            final allowed = await ref
                .read(adminAllowlistServiceProvider)
                .isAllowed(user.email);
            if (allowed) return '/admin';
          }
          return null;
        }

        // Other admin routes require sign-in + allowlist
        if (isAdminRoute) {
          if (!isLoggedIn) return '/admin/signin';
          final allowed = await ref
              .read(adminAllowlistServiceProvider)
              .isAllowed(user.email);
          if (!allowed) return '/admin/signin';
          return null;
        }

        // Voter-facing pages on web also require login (existing behaviour)
        if (!isLoggedIn && !isLoginRoute) return '/login';
        if (isLoggedIn && isLoginRoute) return '/polls';
        return null;
      }

      // ─── Mobile flow ────────────────────────────────────────
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/polls';
      return null;
    },
    routes: [
      // ─── Marketing (web entry) ────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),

      // ─── Auth ────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── Voter app ───────────────────────────────────────
      ShellRoute(
        pageBuilder: (context, state, child) => NoTransitionPage(
          child: MainScaffold(child: child),
        ),
        routes: [
          GoRoute(
            path: '/polls',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PollArchiveScreen(showActiveOnly: true),
            ),
          ),
          GoRoute(
            path: '/archive',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PollArchiveScreen(showActiveOnly: false),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
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
        path: '/profile/persona',
        builder: (context, state) => const PersonaReportScreen(),
      ),

      // ─── Admin ───────────────────────────────────────────
      GoRoute(
        path: '/admin/signin',
        builder: (context, state) => const AdminSigninScreen(),
      ),
      GoRoute(
        path: '/admin',
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
      GoRoute(
        path: '/admin/moderation',
        builder: (context, state) => const AdminModerationScreen(),
      ),
      GoRoute(
        path: '/admin/stats',
        builder: (context, state) => const AdminStatsScreen(),
      ),
      GoRoute(
        path: '/admin/docs',
        builder: (context, state) => const AdminDocsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
    ),
  );
});
