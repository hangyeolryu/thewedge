import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// Standard chrome for all admin web pages — left rail nav + header.
class AdminScaffold extends ConsumerWidget {
  final String title;
  final String activeRoute;
  final Widget body;
  final List<Widget> actions;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.activeRoute,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: isWide ? null : Drawer(child: _SideNav(activeRoute: activeRoute)),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 240,
              child: _SideNav(activeRoute: activeRoute),
            ),
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    border: Border(
                        bottom: BorderSide(color: AppColors.borderSubtle)),
                  ),
                  child: Row(
                    children: [
                      if (!isWide)
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        ),
                      Text(title, style: AppTextStyles.h3),
                      const Spacer(),
                      ...actions,
                      const SizedBox(width: 12),
                      // User chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElev,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.accent,
                              backgroundImage: user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                  : null,
                              child: user?.photoUrl == null
                                  ? const Icon(Icons.person,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user?.displayName ?? user?.email ?? '관리자',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(authServiceProvider)
                                    .signOut();
                                if (context.mounted) context.go('/');
                              },
                              child: const Icon(Icons.logout,
                                  size: 14, color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final String activeRoute;
  const _SideNav({required this.activeRoute});

  static const _items = [
    ('/admin', '대시보드', Icons.dashboard_rounded),
    ('/admin/create', '투표 생성', Icons.add_circle_outline_rounded),
    ('/admin/moderation', '댓글 검토', Icons.shield_outlined),
    ('/admin/stats', '플랫폼 통계', Icons.analytics_outlined),
    ('/admin/docs', '관리자 가이드', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E16),
        border: Border(right: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('W',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.gradientHero.createShader(b),
                  child: Text('Admin',
                      style: AppTextStyles.h3.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Nav items
          ...(_items.map((item) {
            final isActive = activeRoute == item.$1;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go(item.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accentSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(item.$3,
                            size: 18,
                            color: isActive
                                ? AppColors.accentLight
                                : AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList()),
          const Spacer(),
          // Back to marketing
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back, size: 14),
              label: const Text('마케팅 페이지로',
                  style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
