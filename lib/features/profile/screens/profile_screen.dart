import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_stats_model.dart';
import '../providers/user_stats_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(myStatsProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('로그인이 필요합니다.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceElev,
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? const Icon(Icons.person,
                        size: 44, color: AppColors.textTertiary)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName ?? '이름 없음',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (user.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.email!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Provider badge
              _ProviderBadge(provider: user.provider),
              const SizedBox(height: 8),
              // NICE badge
              if (user.isNiceVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user,
                          size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text('본인인증 완료',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber,
                          size: 14, color: AppColors.warning),
                      SizedBox(width: 6),
                      Text('본인인증 미완료 (출시 예정)',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Persona card preview
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) {
                  if (stats == null) return const SizedBox.shrink();
                  return _PersonaPreview(
                    persona: stats.persona,
                    totalVotes: stats.totalVotes,
                    onTap: () => context.push('/profile/persona'),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Menu items
              _MenuSection(
                title: '계정',
                items: [
                  if (user.isAdmin)
                    _MenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: '관리자 패널',
                      onTap: () => context.push('/admin'),
                    ),
                  _MenuItem(
                    icon: Icons.insights_outlined,
                    label: '내 성향 리포트',
                    onTap: () => context.push('/profile/persona'),
                  ),
                  _MenuItem(
                    icon: Icons.history,
                    label: '내 투표 기록',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    label: '본인인증 (NICE) — 출시 예정',
                    onTap: () {},
                    disabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MenuSection(
                title: '앱',
                items: [
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: '이용약관',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보처리방침',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MenuSection(
                title: '',
                items: [
                  _MenuItem(
                    icon: Icons.logout,
                    label: '로그아웃',
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                    },
                    textColor: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  final AuthProvider provider;
  const _ProviderBadge({required this.provider});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (provider) {
      AuthProvider.kakao => ('카카오 로그인', AppColors.kakaoYellow),
      AuthProvider.apple => ('Apple 로그인', Colors.black87),
      AuthProvider.google => ('Google 로그인', const Color(0xFF4285F4)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color == AppColors.kakaoYellow
              ? AppColors.kakaoText
              : color,
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((entry) => Column(
                      children: [
                        entry.value,
                        if (entry.key < items.length - 1)
                          const Divider(height: 0, indent: 52),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PersonaPreview extends StatelessWidget {
  final Persona persona;
  final int totalVotes;
  final VoidCallback onTap;
  const _PersonaPreview({
    required this.persona,
    required this.totalVotes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              persona.color.withOpacity(0.12),
              persona.color.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: persona.color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(persona.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        persona.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: persona.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: persona.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$totalVotes표',
                          style: TextStyle(
                            fontSize: 10,
                            color: persona.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '내 성향 리포트 보기 →',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final bool disabled;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: disabled
            ? AppColors.textTertiary
            : textColor ?? AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: disabled
              ? AppColors.textTertiary
              : textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: AppColors.textTertiary),
      onTap: disabled ? null : onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
