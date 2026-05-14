import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/user_stats_model.dart';
import '../providers/user_stats_provider.dart';

class PersonaReportScreen extends ConsumerWidget {
  const PersonaReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myStatsProvider);
    final averages = ref.watch(platformAveragesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내 성향 리포트')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('데이터가 없습니다.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PersonaCard(persona: stats.persona, totalVotes: stats.totalVotes),
                const SizedBox(height: 24),
                _SectionTitle('이번 달 활동'),
                const SizedBox(height: 8),
                _StatGrid(stats: stats),
                const SizedBox(height: 24),
                _SectionTitle('전체 평균과 비교'),
                const SizedBox(height: 8),
                _ComparisonCard(stats: stats, avg: averages),
                const SizedBox(height: 24),
                _SectionTitle('감정 온도'),
                const SizedBox(height: 8),
                _EmotionCard(stats: stats),
                const SizedBox(height: 32),
                _PrivacyNote(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final Persona persona;
  final int totalVotes;
  const _PersonaCard({required this.persona, required this.totalVotes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            persona.color.withOpacity(0.15),
            persona.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: persona.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(persona.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona.label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: persona.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  persona.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final UserStats stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _StatBox(
          icon: Icons.how_to_vote,
          label: '참여 투표',
          value: '${stats.totalVotes}개',
          color: AppColors.accent,
        ),
        _StatBox(
          icon: Icons.swap_horiz,
          label: '의견 변경',
          value: '${stats.voteChanges}회',
          color: const Color(0xFF6C8EBF),
        ),
        _StatBox(
          icon: Icons.chat_bubble_outline,
          label: '작성 댓글',
          value: '${stats.totalComments}개',
          color: AppColors.success,
        ),
        _StatBox(
          icon: Icons.history,
          label: '마감 후 변경',
          value: '${stats.postDeadlineChanges}회',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final UserStats stats;
  final PlatformAverages avg;
  const _ComparisonCard({required this.stats, required this.avg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ComparisonRow(
            label: '의견 변화율',
            mine: stats.voteChangeRate * 100,
            average: avg.avgVoteChangeRate * 100,
            unit: '%',
          ),
          const SizedBox(height: 14),
          _ComparisonRow(
            label: '댓글 참여율',
            mine: stats.commentRate * 100,
            average: avg.avgCommentRate * 100,
            unit: '%',
          ),
          const SizedBox(height: 14),
          _ComparisonRow(
            label: '댓글 평균 톤',
            mine: stats.avgToxicityScore * 100,
            average: avg.avgToxicityScore * 100,
            unit: '',
            invert: true, // lower is better
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double mine;
  final double average;
  final String unit;
  final bool invert;
  const _ComparisonRow({
    required this.label,
    required this.mine,
    required this.average,
    required this.unit,
    this.invert = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = (mine > average ? mine : average).clamp(1.0, 100.0);
    final mineRatio = mine / maxVal;
    final avgRatio = average / maxVal;
    final isHigher = mine > average;
    final isGood = invert ? !isHigher : isHigher;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isGood
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isHigher ? '↑ 평균보다 높음' : '↓ 평균보다 낮음',
                style: TextStyle(
                  fontSize: 10,
                  color: isGood ? AppColors.success : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _MiniBar(label: '나', value: mine, ratio: mineRatio,
            color: AppColors.accent, unit: unit),
        const SizedBox(height: 4),
        _MiniBar(label: '평균', value: average, ratio: avgRatio,
            color: AppColors.textTertiary, unit: unit),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final double ratio;
  final Color color;
  final String unit;
  const _MiniBar({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toStringAsFixed(1)}$unit',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final UserStats stats;
  const _EmotionCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            stats.emotionalTemperature.split(' ').first,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.emotionalTemperature.split(' ').last,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '최근 댓글 톤 평균: ${(stats.avgToxicityScore * 100).toStringAsFixed(1)}점',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                if (stats.blockedComments > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⚠️ 차단된 댓글 ${stats.blockedComments}건',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline,
              size: 14, color: AppColors.textTertiary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '이 데이터는 본인만 볼 수 있으며, 다른 사용자에게 공개되지 않습니다. '
              '언제든 설정에서 데이터 삭제를 요청할 수 있습니다.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
