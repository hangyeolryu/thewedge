import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(currentUserProvider).valueOrNull;

    int currentIndex = 0;
    if (location.startsWith('/archive')) currentIndex = 1;
    if (location.startsWith('/profile')) currentIndex = 2;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Text('W',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('TheWedge'),
          ],
        ),
        actions: [
          if (user?.isAdmin == true)
            IconButton(
              onPressed: () => context.push('/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: '관리자',
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/polls');
            case 1:
              context.go('/archive');
            case 2:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.how_to_vote_outlined),
            selectedIcon: Icon(Icons.how_to_vote),
            label: '투표',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: '아카이브',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
