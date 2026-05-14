import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class MarketingNav extends StatelessWidget {
  const MarketingNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 20,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xCC0A0A0F),
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.gradientHero.createShader(b),
                  child: Text(
                    '더 왜지?',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (isWide) ...[
                _NavLink(label: '어떻게 작동해요', onTap: () {}),
                _NavLink(label: '기능', onTap: () {}),
                _NavLink(label: '관리자 가이드', onTap: () => context.push('/admin/docs')),
                const SizedBox(width: 12),
              ],
              GestureDetector(
                onTap: () => context.push('/admin/signin'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '관리자 로그인',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
