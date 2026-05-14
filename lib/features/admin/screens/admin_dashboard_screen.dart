import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../polls/models/poll_model.dart';
import '../../polls/providers/polls_provider.dart';
import '../widgets/admin_scaffold.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(allPollsProvider);

    return AdminScaffold(
      title: '대시보드',
      activeRoute: '/admin',
      actions: [
        ElevatedButton.icon(
          onPressed: () => context.push('/admin/create'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('새 투표'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
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
                Text('투표 관리', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  '진행 중·마감된 모든 투표를 한곳에서 관리하세요.',
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 32),
                pollsAsync.when(
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator())),
                  error: (e, _) => Text('오류: $e'),
                  data: (polls) {
                    if (polls.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(48),
                        decoration: glassSurface(),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.how_to_vote_outlined,
                                  size: 64, color: AppColors.textTertiary),
                              const SizedBox(height: 16),
                              Text('투표가 없습니다',
                                  style: AppTextStyles.h3),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/admin/create'),
                                icon: const Icon(Icons.add),
                                label: const Text('첫 번째 투표 만들기'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: polls
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _AdminPollTile(poll: p),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPollTile extends ConsumerWidget {
  final Poll poll;
  const _AdminPollTile({required this.poll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPast = poll.isPastDeadline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassSurface(elevated: true),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPast
                  ? AppColors.textTertiary.withOpacity(0.12)
                  : AppColors.highlight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPast ? Icons.lock_clock : Icons.how_to_vote_outlined,
              size: 20,
              color: isPast ? AppColors.textTertiary : AppColors.highlight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poll.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Pill(
                        label: '${poll.category.emoji} ${poll.category.label}',
                        color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      '${poll.totalVotes}명 참여 · 마감 ${DateFormat('MM/dd HH:mm').format(poll.deadline)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (!poll.deadlineSnapshotTaken && isPast) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.warning_amber,
                          size: 13, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        '마감 스냅샷 미집계',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.warning),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final service = ref.read(pollServiceProvider);
              switch (value) {
                case 'view':
                  context.push('/polls/${poll.id}/result');
                case 'edit':
                  context.push('/admin/edit/${poll.id}');
                case 'snapshot':
                  await service.takeDeadlineSnapshot(poll);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('마감 스냅샷이 저장되었습니다.')),
                    );
                  }
                case 'delete':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('투표 삭제'),
                      content:
                          const Text('이 투표를 삭제하면 복구할 수 없습니다. 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('삭제',
                                style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await service.deletePoll(poll.id);
                  }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'view', child: Text('결과 보기')),
              const PopupMenuItem(value: 'edit', child: Text('수정')),
              if (poll.isPastDeadline && !poll.deadlineSnapshotTaken)
                const PopupMenuItem(
                    value: 'snapshot', child: Text('마감 스냅샷 저장')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('삭제', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
