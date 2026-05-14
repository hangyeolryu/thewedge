import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../polls/models/comment_model.dart';
import '../widgets/admin_scaffold.dart';

/// Stream of all comments that need admin attention:
/// status='blurred' OR flaggedBy.length > 0
final flaggedCommentsProvider = StreamProvider<List<Comment>>((ref) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('status', whereIn: ['blurred', 'blocked'])
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map(Comment.fromFirestore).toList());
});

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(flaggedCommentsProvider);

    return AdminScaffold(
      title: '댓글 검토 큐',
      activeRoute: '/admin/moderation',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('댓글 검토 큐', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  '자동 필터(AI 점수 ≥ 0.6) 또는 신고 3건 이상으로 가려진 댓글입니다. '
                  '검토 후 복원하거나 삭제하세요.',
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 32),
                commentsAsync.when(
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator())),
                  error: (e, _) => Text('오류: $e'),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(48),
                        decoration: glassSurface(),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 48, color: AppColors.success),
                              const SizedBox(height: 12),
                              Text('검토할 댓글이 없습니다',
                                  style: AppTextStyles.h3),
                              const SizedBox(height: 4),
                              Text('전부 깨끗해요 🎉', style: AppTextStyles.bodySm),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: comments
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ModerationCard(comment: c),
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

class _ModerationCard extends ConsumerWidget {
  final Comment comment;
  const _ModerationCard({required this.comment});

  Future<void> _approve(WidgetRef ref) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.id)
        .update({
      'status': 'visible',
      'flaggedBy': [], // clear flags
    });
  }

  Future<void> _delete(WidgetRef ref) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.id)
        .delete();
  }

  Future<void> _block(WidgetRef ref) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(comment.id)
        .update({'status': 'blocked'});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagCount = comment.flaggedBy.length;
    final score = comment.toxicityScore;
    final isBlocked = comment.status == CommentStatus.blocked;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassSurface(
        tint: isBlocked ? AppColors.error : AppColors.warning,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Tag(
                      label: isBlocked ? 'BLOCKED' : 'BLURRED',
                      color: isBlocked
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    if (score > 0)
                      _Tag(
                        label: 'AI ${(score * 100).toStringAsFixed(0)}',
                        color: AppColors.accent,
                      ),
                    const SizedBox(width: 8),
                    if (flagCount > 0)
                      _Tag(
                        label: '🚩 신고 $flagCount',
                        color: AppColors.highlight,
                      ),
                    const Spacer(),
                    Text(
                      DateFormat('yyyy.MM.dd HH:mm').format(comment.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  comment.text,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      comment.userDisplayName ?? comment.userId.substring(0, 8),
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 14),
                    Icon(Icons.poll_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'poll: ${comment.pollId.substring(0, 8)}...',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              _ActionBtn(
                label: '복원',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                onTap: () => _approve(ref),
              ),
              const SizedBox(height: 8),
              if (!isBlocked)
                _ActionBtn(
                  label: '차단',
                  icon: Icons.block,
                  color: AppColors.warning,
                  onTap: () => _block(ref),
                ),
              if (!isBlocked) const SizedBox(height: 8),
              _ActionBtn(
                label: '삭제',
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: () => _delete(ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
