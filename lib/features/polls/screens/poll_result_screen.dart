import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../models/poll_model.dart';
import '../providers/polls_provider.dart';
import '../widgets/result_bar.dart';

class PollResultScreen extends ConsumerStatefulWidget {
  final String pollId;
  const PollResultScreen({super.key, required this.pollId});

  @override
  ConsumerState<PollResultScreen> createState() => _PollResultScreenState();
}

class _PollResultScreenState extends ConsumerState<PollResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    timeago.setLocaleMessages('ko', timeago.KoMessages());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pollAsync = ref.watch(pollByIdProvider(widget.pollId));
    final myVoteAsync = ref.watch(myVoteProvider(widget.pollId));
    final changelogAsync = ref.watch(voteChangelogProvider(widget.pollId));

    return pollAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('오류: $e')),
      ),
      data: (poll) {
        if (poll == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('투표를 찾을 수 없습니다.')),
          );
        }
        final myVote = myVoteAsync.valueOrNull;
        final changelog = changelogAsync.valueOrNull ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('투표 결과'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '결과'),
                Tab(text: '변경 기록'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _ResultTab(poll: poll, myVote: myVote),
              _ChangelogTab(changelog: changelog),
            ],
          ),
        );
      },
    );
  }
}

class _ResultTab extends StatelessWidget {
  final Poll poll;
  final dynamic myVote;

  const _ResultTab({required this.poll, required this.myVote});

  @override
  Widget build(BuildContext context) {
    final realtimeTotal = poll.totalVotes;
    final deadlineTotal = poll.deadlineTotalVotes;
    final myAnswerIds = (myVote?.answerIds as List<String>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll question
          Text(
            poll.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.people_outline,
                label: '실시간 참여',
                value: '$realtimeTotal명',
                color: AppColors.resultRealtime,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.lock_clock,
                label: '마감 시 참여',
                value: poll.deadlineSnapshotTaken
                    ? '$deadlineTotal명'
                    : '집계 전',
                color: AppColors.resultDeadline,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _LegendDot(color: AppColors.resultRealtime, label: '실시간 결과'),
              const SizedBox(width: 16),
              _LegendDot(
                color: AppColors.resultDeadline,
                label: poll.deadlineSnapshotTaken
                    ? '마감 시 결과'
                    : '마감 시 결과 (집계 전)',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          // Results per answer
          ...poll.answers.map((answer) {
            final rtPct = realtimeTotal > 0
                ? (answer.voteCount / realtimeTotal * 100).clamp(0.0, 100.0)
                : 0.0;
            final dlPct = deadlineTotal > 0
                ? (answer.deadlineVoteCount / deadlineTotal * 100)
                    .clamp(0.0, 100.0)
                : 0.0;
            final isSelected = myAnswerIds.contains(answer.id);

            return ResultBar(
              label: answer.text,
              realtimePct: rtPct,
              deadlinePct: poll.deadlineSnapshotTaken ? dlPct : rtPct,
              isSelected: isSelected,
            );
          }),
          if (!poll.deadlineSnapshotTaken) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '마감 전이므로 마감 시 결과는 집계되지 않았습니다.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Deadline info
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '마감: ${DateFormat('yyyy년 MM월 dd일 HH:mm').format(poll.deadline)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangelogTab extends ConsumerWidget {
  final List<dynamic> changelog;
  const _ChangelogTab({required this.changelog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (changelog.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              '마감 후 의견 변경 기록이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: changelog.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final vote = changelog[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          leading: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElev,
            child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
          ),
          title: Text(
            vote.changeComment ?? '(사유 없음)',
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            timeago.format(vote.updatedAt ?? vote.votedAt, locale: 'ko'),
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
