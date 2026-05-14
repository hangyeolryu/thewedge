import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MarketingFooter extends StatelessWidget {
  const MarketingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 40,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF08080C),
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    AppColors.gradientHero.createShader(b),
                child: Text('더 왜지?',
                    style: AppTextStyles.h2
                        .copyWith(color: Colors.white, fontSize: 20)),
              ),
              const SizedBox(height: 8),
              Text(
                '모두가 묻고, 모두가 답하는 대한민국의 생각.',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  Text('© 2025 effeff corp.',
                      style: AppTextStyles.caption),
                  Text('contact@effeffcorp.com',
                      style: AppTextStyles.caption),
                  Text('이용약관 · 개인정보처리방침',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
