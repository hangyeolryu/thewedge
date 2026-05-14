import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/comment_model.dart';

final _db = FirebaseFirestore.instance;

/// Stream of visible + blurred comments for a poll (blocked are hidden).
final commentsForPollProvider =
    StreamProvider.family<List<Comment>, String>((ref, pollId) {
  return _db
      .collection('comments')
      .where('pollId', isEqualTo: pollId)
      .where('status', whereIn: ['visible', 'blurred'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Comment.fromFirestore).toList());
});

final commentServiceProvider = Provider<CommentService>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return CommentService(
    uid: user?.uid ?? '',
    displayName: user?.displayName,
    photoUrl: user?.photoUrl,
  );
});

class CommentService {
  final String uid;
  final String? displayName;
  final String? photoUrl;
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  CommentService({required this.uid, this.displayName, this.photoUrl});

  /// Pre-check toxicity before posting. Returns max score 0~1.
  /// Client uses this to warn the user before submission.
  Future<({double maxScore, String status})> preModerate(String text) async {
    try {
      final callable = _functions.httpsCallable('moderateComment');
      final result = await callable.call({'text': text});
      final data = result.data as Map<dynamic, dynamic>;
      return (
        maxScore: (data['maxScore'] as num).toDouble(),
        status: data['status'] as String,
      );
    } catch (_) {
      return (maxScore: 0.0, status: 'visible');
    }
  }

  /// Post a new comment. Cloud Function will re-score and update status.
  Future<void> postComment({
    required String pollId,
    required String text,
    String? answerChangeFromId,
    String? answerChangeToId,
  }) async {
    if (uid.isEmpty) throw Exception('로그인이 필요합니다.');
    if (text.trim().isEmpty) throw Exception('댓글을 입력해주세요.');
    if (text.length > 1000) throw Exception('댓글은 1000자 이내로 작성해주세요.');

    final ref = _db.collection('comments').doc();
    final comment = Comment(
      id: ref.id,
      pollId: pollId,
      userId: uid,
      userDisplayName: displayName,
      userPhotoUrl: photoUrl,
      text: text.trim(),
      answerChangeFromId: answerChangeFromId,
      answerChangeToId: answerChangeToId,
      createdAt: DateTime.now(),
    );
    await ref.set(comment.toFirestore());
  }

  /// Flag a comment. Auto-blurs at 3+ unique flags (Cloud Function also enforces this).
  Future<void> flagComment(String commentId) async {
    if (uid.isEmpty) return;
    final ref = _db.collection('comments').doc(commentId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final flaggedBy = List<String>.from(data['flaggedBy'] as List? ?? []);
    if (flaggedBy.contains(uid)) return; // already flagged by this user

    final newFlaggedBy = [...flaggedBy, uid];
    final Map<String, dynamic> updates = {
      'flaggedBy': FieldValue.arrayUnion([uid]),
    };

    // Auto-blur when 3+ unique users have flagged
    if (newFlaggedBy.length >= 3) {
      final currentStatus = data['status'] as String? ?? 'visible';
      if (currentStatus == 'visible') {
        updates['status'] = 'blurred';
      }
    }

    await ref.update(updates);
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('comments').doc(commentId).delete();
  }
}
