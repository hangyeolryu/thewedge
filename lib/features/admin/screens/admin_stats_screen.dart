import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';

class _Counts {
  final int polls;
  final int activePolls;
  final int votes;
  final int comments;
  final int blockedComments;
  final int blurredComments;
  final int users;
  const _Counts({
    required this.polls,
    required this.activePolls,
    required this.votes,
    required this.comments,
    required this.blockedComments,
    required this.blurredComments,
    required this.users,
  });
}

final _statsProvider = FutureProvider<_Counts>((ref) async {
  final db = FirebaseFirestore.instance;
  final results = await Future.wait([
    db.collection('polls').count().get(),
    db
        .collection('polls')
        .where('deadline', isGreaterThan: Timestamp.now())
        .count()
        .get(),
    db.collection('votes').count().get(),
    db.collection('comments').count().get(),
    db
        .collection('comments')
        .where('status', isEqualTo: 'blocked')
        .count()
        .get(),
    db
        .collection('comments')
        .where('status', isEqualTo: 'blurred')
        .count()
        .get(),
    db.collection('users').count().get(),
  ]);

  return _Counts(
    polls: results[0].count ?? 0,
    activePolls: results[1].count ?? 0,
    votes: results[2].count ?? 0,
    comments: results[3].count ?? 0,
    blockedComments: results[4].count ?? 0,
    blurredComments: results[5].count ?? 0,
    users: results[6].count ?? 0,
  );
});

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_statsProvider);

    return AdminScaffold(
      title: '플랫폼 통계',
      activeRoute: '/admin/stats',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(_statsProvider),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('플랫폼 통계', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  '플랫폼 전반의 참여 현황을 한눈에. 실시간으로 새로고침해서 확인하세요.',
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 32),
                statsAsync.when(
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator())),
                  error: (e, _) => Text('오류: $e'),
                  data: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _StatTile(
                              label: '전체 가입자',
                              value: c.users,
                              icon: Icons.people_outline,
                              color: AppColors.accent),
                          _StatTile(
                              label: '전체 투표',
                              value: c.polls,
                              icon: Icons.poll_outlined,
                              color: AppColors.highlight),
                          _StatTile(
                              label: '진행 중 투표',
                              value: c.activePolls,
                              icon: Icons.live_tv_outlined,
                              color: AppColors.success),
                          _StatTile(
                              label: '누적 투표 수',
                              value: c.votes,
                              icon: Icons.how_to_vote_outlined,
                              color: AppColors.info),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text('댓글 검토 현황', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _StatTile(
                              label: '전체 댓글',
                              value: c.comments,
                              icon: Icons.chat_bubble_outline,
                              color: AppColors.textSecondary),
                          _StatTile(
                              label: '가려진 댓글',
                              value: c.blurredComments,
                              icon: Icons.visibility_off_outlined,
                              color: AppColors.warning),
                          _StatTile(
                              label: '차단된 댓글',
                              value: c.blockedComments,
                              icon: Icons.block,
                              color: AppColors.error),
                          _StatTile(
                              label: '정상 비율',
                              value: c.comments == 0
                                  ? 100
                                  : (((c.comments -
                                                  c.blockedComments -
                                                  c.blurredComments) /
                                              c.comments) *
                                          100)
                                      .round(),
                              suffix: '%',
                              icon: Icons.verified_outlined,
                              color: AppColors.success),
                        ],
                      ),
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

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: glassSurface(tint: color, elevated: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${_format(value)}$suffix',
            style: AppTextStyles.display.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
