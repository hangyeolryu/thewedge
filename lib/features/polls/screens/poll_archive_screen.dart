import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/polls_provider.dart';
import '../widgets/poll_card.dart';

class PollArchiveScreen extends ConsumerWidget {
  final bool showActiveOnly;
  const PollArchiveScreen({super.key, required this.showActiveOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = showActiveOnly
        ? ref.watch(activePollsProvider)
        : ref.watch(allPollsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(
          showActiveOnly ? activePollsProvider : allPollsProvider),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                showActiveOnly ? '현재 진행 중인 투표' : '전체 투표 아카이브',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          pollsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ShimmerCard(),
                childCount: 5,
              ),
            ),
            error: (e, __) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('오류가 발생했습니다\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            data: (polls) {
              if (polls.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showActiveOnly
                              ? Icons.how_to_vote_outlined
                              : Icons.archive_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showActiveOnly
                              ? '현재 진행 중인 투표가 없습니다'
                              : '투표 기록이 없습니다',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poll = polls[index];
                    return PollCard(
                      poll: poll,
                      onTap: () => context.push('/polls/${poll.id}'),
                    );
                  },
                  childCount: polls.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surfaceElev,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
