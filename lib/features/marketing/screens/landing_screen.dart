import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/marketing_footer.dart';
import '../widgets/marketing_nav.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            MarketingNav(),
            _Hero(),
            _HowItWorks(),
            _Features(),
            _Stats(),
            _AdminCta(),
            MarketingFooter(),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────── HERO ──────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 120 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0x337C5CFF), Color(0xFF0A0A0F)],
          center: Alignment(-0.4, -0.6),
          radius: 1.4,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Text(
                        '🇰🇷 대국민투표 플랫폼',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.gradientHero.createShader(bounds),
                      child: Text(
                        '더 왜지?',
                        style: AppTextStyles.display.copyWith(
                          fontSize: isWide ? 96 : 64,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '모두가 묻고, 모두가 답하는\n진짜 대한민국의 생각.',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: isWide ? 32 : 24,
                        color: AppColors.textPrimary,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 520,
                      child: Text(
                        '정치 성향이 아닌, 가치관과 라이프스타일의 차이를 들여다보는 새로운 투표 공간. '
                        '실시간 결과 + 마감 결과 + 의견 변화까지 한 번에.',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _CtaButton(
                          label: '앱 다운로드',
                          icon: Icons.download_rounded,
                          primary: true,
                          onTap: () {},
                        ),
                        _CtaButton(
                          label: '어떻게 작동해요?',
                          icon: Icons.play_arrow_rounded,
                          primary: false,
                          onTap: () {
                            Scrollable.ensureVisible(
                              context,
                              duration: const Duration(milliseconds: 600),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isWide)
                Expanded(
                  flex: 5,
                  child: _PhoneMockup(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.55,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.border, width: 8),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 80,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.highlight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.fiber_manual_record,
                          size: 8, color: AppColors.highlight),
                      SizedBox(width: 4),
                      Text('LIVE',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.highlight,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '결혼은 꼭 해야 한다고\n생각하세요?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                _MockBar(label: '꼭 해야 한다', pct: 32),
                const SizedBox(height: 12),
                _MockBar(label: '하면 좋지만 필수는 아니다', pct: 58, highlight: true),
                const SizedBox(height: 12),
                _MockBar(label: '꼭 할 필요 없다', pct: 10),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElev,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.people_outline,
                          size: 16, color: AppColors.accentLight),
                      SizedBox(width: 6),
                      Text('24,581명 참여 중',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MockBar extends StatelessWidget {
  final String label;
  final int pct;
  final bool highlight;
  const _MockBar({required this.label, required this.pct, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
            ),
            Text('$pct%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlight
                        ? AppColors.highlight
                        : AppColors.accentLight)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.surfaceElev),
              FractionallySizedBox(
                widthFactor: pct / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: highlight
                        ? AppColors.gradientHero
                        : const LinearGradient(colors: [
                            AppColors.accent,
                            AppColors.accentLight,
                          ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: primary ? AppColors.gradientHero : null,
            color: primary ? null : AppColors.surfaceElev,
            borderRadius: BorderRadius.circular(99),
            border: primary
                ? null
                : Border.all(color: AppColors.border, width: 1),
            boxShadow: primary
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────── HOW IT WORKS ──────────────────────────
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final steps = [
      ('01', '투표 참여', '카카오·구글·애플로 1초 로그인. 보고 싶은 질문 골라서 답해요.', Icons.how_to_vote_outlined),
      ('02', '실시간 결과 확인', '내가 답하는 순간 전국의 답이 실시간으로 그래프에 반영돼요.', Icons.show_chart_rounded),
      ('03', '마감 결과 vs 실시간', '마감 시점 결과가 따로 보존돼요. 시간이 지난 후의 생각 변화까지 비교 가능.', Icons.compare_arrows_rounded),
      ('04', '의견 변경 + 코멘트', '마감 후에도 마음이 바뀌면 사유와 함께 답을 바꿀 수 있어요.', Icons.swap_horiz_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 120 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionEyebrow('어떻게 작동하나요'),
              const SizedBox(height: 16),
              Text(
                '4단계로 시작하는\n진짜 국민투표',
                style: AppTextStyles.h1.copyWith(
                  fontSize: isWide ? 48 : 32,
                ),
              ),
              const SizedBox(height: 56),
              isWide
                  ? Row(
                      children: steps
                          .map((s) => Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: _StepCard(
                                    number: s.$1,
                                    title: s.$2,
                                    description: s.$3,
                                    icon: s.$4,
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  : Column(
                      children: steps
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _StepCard(
                                  number: s.$1,
                                  title: s.$2,
                                  description: s.$3,
                                  icon: s.$4,
                                ),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: glassSurface(elevated: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accentLight, size: 22),
              ),
              const Spacer(),
              Text(
                number,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textTertiary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(description, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

// ───────────────────────────── FEATURES ─────────────────────────────
class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 120 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionEyebrow('주요 기능'),
              const SizedBox(height: 16),
              Text(
                '오직 더 왜지에만 있는 것',
                style: AppTextStyles.h1.copyWith(
                  fontSize: isWide ? 48 : 32,
                ),
              ),
              const SizedBox(height: 56),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: const [
                  _FeatureCard(
                    emoji: '⚡️',
                    title: '실시간 + 마감 이중 결과',
                    desc: '마감 시점 결과는 박제, 실시간은 계속 흘러요. 두 그래프 한눈에 비교.',
                  ),
                  _FeatureCard(
                    emoji: '🔄',
                    title: '마감 후에도 의견 변경',
                    desc: '시간이 지나도 마음이 바뀌면 사유와 함께 답을 바꿀 수 있어요.',
                  ),
                  _FeatureCard(
                    emoji: '🧠',
                    title: '나의 가치관 페르소나',
                    desc: '7가지 성향 중 당신은? 투표 패턴이 만드는 진짜 나의 성향 리포트.',
                  ),
                  _FeatureCard(
                    emoji: '🛡',
                    title: 'AI 자동 댓글 필터',
                    desc: 'Perspective API + 신고 3건 자동 숨김. 건강한 대화만 남겨요.',
                  ),
                  _FeatureCard(
                    emoji: '📈',
                    title: '의견 변화 타임라인',
                    desc: '마감 후 시간대별 답변 분포 변화를 그래프로 시각화.',
                  ),
                  _FeatureCard(
                    emoji: '🎥',
                    title: '유튜브 라이브 연동',
                    desc: '라이브 방송 중 딥링크 한 번이면 시청자가 바로 투표에 참여.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: isWide ? 350 : double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: glassSurface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(desc, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

// ─────────────────────────────── STATS ───────────────────────────────
class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 80 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 40,
            runSpacing: 32,
            children: const [
              _StatBlock(number: '120K+', label: '누적 투표 참여'),
              _StatBlock(number: '7', label: '가치관 성향 페르소나'),
              _StatBlock(number: '95%', label: '댓글 정상 노출률'),
              _StatBlock(number: '실시간', label: '결과 업데이트'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String number;
  final String label;
  const _StatBlock({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.gradientHero.createShader(b),
          child: Text(number,
              style: AppTextStyles.display.copyWith(color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}

// ─────────────────────────── ADMIN CTA ───────────────────────────
class _AdminCta extends StatelessWidget {
  const _AdminCta();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 100 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(isWide ? 56 : 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1525), Color(0xFF15151E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.accentGlow, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SectionEyebrow('관리자 콘솔'),
                      const SizedBox(height: 16),
                      Text(
                        '관리자라면\n바로 투표를 만들어 보세요',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: isWide ? 36 : 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '구글 계정으로 로그인하면 등록된 관리자만 접근할 수 있어요.\n'
                        '투표 생성·수정·삭제, 댓글 검토, 통계 모두 웹에서.',
                        style: AppTextStyles.bodySm.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 28),
                      _CtaButton(
                        label: '관리자 로그인',
                        icon: Icons.lock_open_rounded,
                        primary: true,
                        onTap: () => context.push('/admin/signin'),
                      ),
                    ],
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(width: 40),
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 140,
                    color: AppColors.accentLight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;
  const _SectionEyebrow(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
            color: AppColors.accentLight, fontSize: 11),
      ),
    );
  }
}
