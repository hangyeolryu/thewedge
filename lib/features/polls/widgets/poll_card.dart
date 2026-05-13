import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../models/poll_model.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback onTap;

  const PollCard({super.key, required this.poll, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPast = poll.isPastDeadline;
    final deadlineStr = DateFormat('yyyy.MM.dd HH:mm').format(poll.deadline);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poll.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: poll.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: AppColors.surfaceVariant,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusChip(isPast: isPast),
                      const SizedBox(width: 8),
                      _TypeChip(type: poll.answerType),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    poll.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatCount(poll.totalVotes)}명 참여',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isPast ? Icons.lock_clock : Icons.schedule,
                        size: 15,
                        color: isPast
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPast ? '마감 $deadlineStr' : '~$deadlineStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPast
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
    return count.toString();
  }
}

class _StatusChip extends StatelessWidget {
  final bool isPast;
  const _StatusChip({required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPast
            ? AppColors.textTertiary.withOpacity(0.15)
            : AppColors.highlight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPast ? '마감' : '진행중',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPast ? AppColors.textTertiary : AppColors.highlight,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final PollAnswerType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final isMulti = type == PollAnswerType.checkbox;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isMulti ? '다중선택' : '단일선택',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
