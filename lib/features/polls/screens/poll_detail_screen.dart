import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../models/poll_model.dart';
import '../models/vote_model.dart';
import '../providers/comments_provider.dart';
import '../providers/polls_provider.dart';
import '../widgets/comment_composer.dart';
import '../widgets/comment_tile.dart';
import '../widgets/result_bar.dart';

class PollDetailScreen extends ConsumerStatefulWidget {
  final String pollId;
  const PollDetailScreen({super.key, required this.pollId});

  @override
  ConsumerState<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends ConsumerState<PollDetailScreen> {
  final Set<String> _selectedIds = {};
  bool _hasEdited = false;
  bool _submitting = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _initSelections(Vote? myVote) {
    if (!_hasEdited && myVote != null) {
      _selectedIds
        ..clear()
        ..addAll(myVote.answerIds);
    }
  }

  void _toggleAnswer(String id, PollAnswerType type) {
    setState(() {
      _hasEdited = true;
      if (type == PollAnswerType.radio) {
        _selectedIds
          ..clear()
          ..add(id);
      } else {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      }
    });
  }

  Future<void> _submit(Poll poll, Vote? myVote) async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 선택해주세요.')),
      );
      return;
    }

    final isPastDeadline = poll.isPastDeadline;
    if (isPastDeadline && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감 후 의견 변경 시 변경 사유를 입력해주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final service = ref.read(pollServiceProvider);
      await service.submitVote(
        poll: poll,
        answerIds: _selectedIds.toList(),
        changeComment: isPastDeadline ? _commentController.text.trim() : null,
      );
      if (mounted) {
        setState(() { _hasEdited = false; _submitting = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(myVote == null ? '투표 완료!' : '의견이 변경되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pollAsync = ref.watch(pollByIdProvider(widget.pollId));
    final myVoteAsync = ref.watch(myVoteProvider(widget.pollId));

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
        _initSelections(myVote);

        final isPast = poll.isPastDeadline;
        final hasVoted = myVote != null;

        final commentsAsync = ref.watch(commentsForPollProvider(poll.id));

        return Scaffold(
          appBar: AppBar(
            title: const Text('투표'),
            actions: [
              if (hasVoted)
                TextButton.icon(
                  onPressed: () => context.push('/polls/${poll.id}/result'),
                  icon: const Icon(Icons.bar_chart, size: 18),
                  label: const Text('결과 보기'),
                ),
            ],
          ),
          bottomNavigationBar: hasVoted
              ? CommentComposer(
                  pollId: poll.id,
                  hintText: isPast
                      ? '의견 변경 후 생각을 남겨주세요...'
                      : '이 투표에 대한 생각을 나눠주세요...',
                )
              : null,
          body: CustomScrollView(
            slivers: [
              if (poll.imageUrl != null)
                SliverToBoxAdapter(
                  child: CachedNetworkImage(
                    imageUrl: poll.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deadline banner
                      _DeadlineBanner(poll: poll),
                      const SizedBox(height: 20),
                      // Question
                      Text(
                        poll.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        poll.answerType == PollAnswerType.checkbox
                            ? '복수 선택 가능'
                            : '하나만 선택',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Answers
                      ...poll.answers.map((answer) {
                        final selected = _selectedIds.contains(answer.id);
                        return _AnswerTile(
                          answer: answer,
                          selected: selected,
                          type: poll.answerType,
                          totalVotes: poll.totalVotes,
                          showResult: hasVoted,
                          onTap: () => _toggleAnswer(answer.id, poll.answerType),
                        );
                      }),
                      // After-deadline comment
                      if (isPast && hasVoted) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          '의견 변경 사유',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration: const InputDecoration(
                            hintText: '마감 이후 의견을 변경하는 이유를 적어주세요.',
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting || !_hasEdited && hasVoted
                              ? null
                              : () => _submit(poll, myVote),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  !hasVoted
                                      ? '투표하기'
                                      : isPast
                                          ? '마감 후 의견 변경'
                                          : '의견 수정하기',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      if (hasVoted) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                context.push('/polls/${poll.id}/result'),
                            child: const Text('전체 결과 보기 →'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Comments section
                      if (hasVoted) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 16, color: AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Text(
                              '의견 (${commentsAsync.valueOrNull?.length ?? 0})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        commentsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('댓글을 불러올 수 없습니다.',
                                style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12)),
                          ),
                          data: (comments) {
                            if (comments.isEmpty) {
                              return const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    '첫 의견을 남겨보세요',
                                    style: TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: comments
                                  .map((c) => CommentTile(comment: c))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeadlineBanner extends StatelessWidget {
  final Poll poll;
  const _DeadlineBanner({required this.poll});

  @override
  Widget build(BuildContext context) {
    final isPast = poll.isPastDeadline;
    final dateStr = DateFormat('yyyy년 MM월 dd일 HH:mm').format(poll.deadline);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPast
            ? AppColors.error.withOpacity(0.08)
            : AppColors.highlight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPast
              ? AppColors.error.withOpacity(0.25)
              : AppColors.highlight.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPast ? Icons.lock_clock : Icons.schedule,
            size: 16,
            color: isPast ? AppColors.error : AppColors.highlight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPast ? '마감: $dateStr' : '마감 예정: $dateStr',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPast ? AppColors.error : AppColors.highlight,
              ),
            ),
          ),
          Text(
            '${_formatCount(poll.totalVotes)}명 참여',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
    return count.toString();
  }
}

class _AnswerTile extends StatelessWidget {
  final PollAnswer answer;
  final bool selected;
  final PollAnswerType type;
  final int totalVotes;
  final bool showResult;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.answer,
    required this.selected,
    required this.type,
    required this.totalVotes,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalVotes > 0
        ? (answer.voteCount / totalVotes * 100).clamp(0.0, 100.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Result bar background
            if (showResult)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct / 100,
                    child: Container(
                      color: selected
                          ? AppColors.accent.withOpacity(0.12)
                          : AppColors.resultBarBackground.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  _SelectionIndicator(selected: selected, type: type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      answer.text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (showResult) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;
  final PollAnswerType type;
  const _SelectionIndicator({required this.selected, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == PollAnswerType.radio) {
      return Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.accent : AppColors.textTertiary,
        size: 22,
      );
    }
    return Icon(
      selected ? Icons.check_box : Icons.check_box_outline_blank,
      color: selected ? AppColors.accent : AppColors.textTertiary,
      size: 22,
    );
  }
}
