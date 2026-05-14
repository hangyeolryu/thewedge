import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/comment_model.dart';
import '../providers/comments_provider.dart';

class CommentTile extends ConsumerStatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final me = ref.watch(currentUserProvider).valueOrNull;
    final isMine = me?.uid == c.userId;
    final blurred = c.status == CommentStatus.blurred && !_revealed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: c.userPhotoUrl != null
                ? CachedNetworkImageProvider(c.userPhotoUrl!)
                : null,
            child: c.userPhotoUrl == null
                ? const Icon(Icons.person,
                    size: 18, color: AppColors.textTertiary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      c.userDisplayName ?? '익명',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeago.format(c.createdAt, locale: 'ko'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz,
                          size: 16, color: AppColors.textTertiary),
                      padding: EdgeInsets.zero,
                      onSelected: (v) async {
                        final svc = ref.read(commentServiceProvider);
                        if (v == 'flag') {
                          await svc.flagComment(c.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('신고되었습니다.')),
                            );
                          }
                        } else if (v == 'delete') {
                          await svc.deleteComment(c.id);
                        }
                      },
                      itemBuilder: (_) => [
                        if (!isMine)
                          const PopupMenuItem(
                              value: 'flag', child: Text('신고하기')),
                        if (isMine)
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제',
                                  style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (blurred)
                  GestureDetector(
                    onTap: () => setState(() => _revealed = true),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 14, color: AppColors.warning),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '불쾌할 수 있는 댓글입니다. 탭하여 보기',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    c.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                if (c.answerChangeFromId != null &&
                    c.answerChangeToId != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🔄 의견 변경',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
