import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../polls/models/poll_model.dart';
import '../../polls/providers/polls_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(allPollsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
        actions: [
          IconButton(
            onPressed: () => context.push('/admin/create'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '새 투표 만들기',
          ),
        ],
      ),
      body: pollsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (polls) {
          if (polls.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.how_to_vote_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text('투표가 없습니다.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/admin/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('첫 번째 투표 만들기'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: polls.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final poll = polls[index];
              return _AdminPollTile(poll: poll);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/create'),
        icon: const Icon(Icons.add),
        label: const Text('투표 만들기'),
        backgroundColor: AppColors.highlight,
        foregroundColor: Colors.white,
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          poll.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${poll.totalVotes}명 참여 · '
              '마감 ${DateFormat('MM/dd HH:mm').format(poll.deadline)}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            if (!poll.deadlineSnapshotTaken && isPast) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.warning_amber,
                      size: 13, color: AppColors.warning),
                  const SizedBox(width: 4),
                  const Text(
                    '마감 스냅샷 미집계',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.warning),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final service = ref.read(pollServiceProvider);
            switch (value) {
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
                    content: const Text('이 투표를 삭제하면 복구할 수 없습니다. 삭제하시겠습니까?'),
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
        onTap: () => context.push('/polls/${poll.id}/result'),
      ),
    );
  }
}
