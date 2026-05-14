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
    final dateStr = DateFormat('MM.dd HH:mm').format(poll.deadline);
    final remaining = poll.deadline.difference(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.accentSoft,
          highlightColor: AppColors.accentSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (poll.imageUrl != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg)),
                      child: CachedNetworkImage(
                        imageUrl: poll.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 180,
                          color: AppColors.surfaceElev,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 180,
                          color: AppColors.surfaceElev,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    // Image gradient overlay for legibility of badges
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.lg)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.4],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          _StatusBadge(isPast: isPast, remaining: remaining),
                          const SizedBox(width: 6),
                          _TypeBadge(type: poll.answerType),
                        ],
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (poll.imageUrl == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            _StatusBadge(isPast: isPast, remaining: remaining),
                            const SizedBox(width: 6),
                            _TypeBadge(type: poll.answerType),
                          ],
                        ),
                      ),
                    Text(
                      poll.question,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 17,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatCount(poll.totalVotes)}명',
                          style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          isPast ? Icons.lock_outline : Icons.schedule,
                          size: 13,
                          color: isPast
                              ? AppColors.error
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPast ? '$dateStr 마감' : dateStr,
                          style: AppTextStyles.bodySm.copyWith(
                            color: isPast
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Arrow
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElev,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: AppColors.textSecondary,
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
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
    return '$count';
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPast;
  final Duration remaining;
  const _StatusBadge({required this.isPast, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final urgent = !isPast && remaining.inHours < 24;
    final color = isPast
        ? AppColors.textTertiary
        : urgent
            ? AppColors.highlight
            : AppColors.success;
    final label = isPast
        ? '마감'
        : urgent
            ? 'D-${remaining.inHours}h'
            : 'LIVE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isPast)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                ],
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final PollAnswerType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isMulti = type == PollAnswerType.checkbox;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        isMulti ? '복수' : '단일',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
