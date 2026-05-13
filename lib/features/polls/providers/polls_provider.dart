import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../auth/providers/auth_provider.dart';
import '../models/poll_model.dart';
import '../models/vote_model.dart';

final _db = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

// Stream of all active polls (before deadline)
final activePollsProvider = StreamProvider<List<Poll>>((ref) {
  return _db
      .collection('polls')
      .orderBy('deadline', descending: false)
      .snapshots()
      .map((snap) => snap.docs
          .map(Poll.fromFirestore)
          .where((p) => p.deadline.isAfter(DateTime.now()))
          .toList());
});

// Stream of all polls (for archive)
final allPollsProvider = StreamProvider<List<Poll>>((ref) {
  return _db
      .collection('polls')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Poll.fromFirestore).toList());
});

// Single poll stream (real-time updates)
final pollByIdProvider =
    StreamProvider.family<Poll?, String>((ref, pollId) {
  return _db
      .collection('polls')
      .doc(pollId)
      .snapshots()
      .map((doc) => doc.exists ? Poll.fromFirestore(doc) : null);
});

// Current user's vote for a poll
final myVoteProvider =
    StreamProvider.family<Vote?, String>((ref, pollId) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);

  return _db
      .collection('votes')
      .where('pollId', isEqualTo: pollId)
      .where('userId', isEqualTo: uid)
      .limit(1)
      .snapshots()
      .map((snap) =>
          snap.docs.isNotEmpty ? Vote.fromFirestore(snap.docs.first) : null);
});

// Changelog: all post-deadline answer changes for a poll
final voteChangelogProvider =
    StreamProvider.family<List<Vote>, String>((ref, pollId) {
  return _db
      .collection('votes')
      .where('pollId', isEqualTo: pollId)
      .where('isAfterDeadline', isEqualTo: true)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Vote.fromFirestore).toList());
});

final pollServiceProvider = Provider<PollService>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid ?? '';
  return PollService(uid: uid);
});

class PollService {
  final String uid;
  PollService({required this.uid});

  // Submit or update a vote
  Future<void> submitVote({
    required Poll poll,
    required List<String> answerIds,
    String? changeComment,
  }) async {
    if (uid.isEmpty) throw Exception('로그인이 필요합니다.');

    final isPastDeadline = poll.isPastDeadline;
    if (isPastDeadline && (changeComment == null || changeComment.isEmpty)) {
      throw Exception('마감 후 의견 변경 시 사유를 입력해야 합니다.');
    }

    final existingSnap = await _db
        .collection('votes')
        .where('pollId', isEqualTo: poll.id)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    final batch = _db.batch();
    final now = DateTime.now();

    if (existingSnap.docs.isEmpty) {
      // First vote
      final voteRef = _db.collection('votes').doc();
      final vote = Vote(
        id: voteRef.id,
        pollId: poll.id,
        userId: uid,
        answerIds: answerIds,
        isAfterDeadline: isPastDeadline,
        changeComment: changeComment,
        votedAt: now,
        updatedAt: now,
      );
      batch.set(voteRef, vote.toFirestore());
      _updatePollCounts(batch, poll, [], answerIds, isPastDeadline);
    } else {
      // Update vote
      final existing = Vote.fromFirestore(existingSnap.docs.first);
      final oldAnswerIds = existing.answerIds;
      batch.update(existingSnap.docs.first.reference, {
        'answerIds': answerIds,
        'isAfterDeadline': isPastDeadline,
        'changeComment': changeComment,
        'previousAnswerIds': oldAnswerIds,
        'updatedAt': Timestamp.fromDate(now),
      });
      _updatePollCounts(batch, poll, oldAnswerIds, answerIds, isPastDeadline);
    }

    await batch.commit();
  }

  void _updatePollCounts(
    WriteBatch batch,
    Poll poll,
    List<String> oldIds,
    List<String> newIds,
    bool isPastDeadline,
  ) {
    final pollRef = _db.collection('polls').doc(poll.id);
    final Map<String, dynamic> updates = {};

    // Decrement old answers
    for (final id in oldIds) {
      if (!newIds.contains(id)) {
        updates['answers'] = FieldValue.arrayRemove([]);
      }
    }

    // Build updated answers array incrementally
    final updatedAnswers = poll.answers.map((a) {
      int delta = 0;
      if (newIds.contains(a.id) && !oldIds.contains(a.id)) delta = 1;
      if (!newIds.contains(a.id) && oldIds.contains(a.id)) delta = -1;
      return a.copyWith(voteCount: (a.voteCount + delta).clamp(0, 999999));
    }).toList();

    final totalDelta = newIds.length - oldIds.length;

    updates['answers'] = updatedAnswers.map((a) => a.toMap()).toList();
    updates['totalVotes'] =
        FieldValue.increment(oldIds.isEmpty ? 1 : 0);

    // If deadline snapshot not yet taken and this is before deadline, sync deadline counts
    if (!isPastDeadline && !poll.deadlineSnapshotTaken) {
      final updatedAnswersWithDeadline = updatedAnswers.map((a) {
        int delta = 0;
        if (newIds.contains(a.id) && !oldIds.contains(a.id)) delta = 1;
        if (!newIds.contains(a.id) && oldIds.contains(a.id)) delta = -1;
        return a.copyWith(
          deadlineVoteCount:
              (a.deadlineVoteCount + delta).clamp(0, 999999),
        );
      }).toList();
      updates['answers'] =
          updatedAnswersWithDeadline.map((a) => a.toMap()).toList();
    }

    batch.update(pollRef, updates);
  }

  Future<String?> uploadPollImage(File imageFile) async {
    final ref = _storage
        .ref('poll_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(imageFile);
    return await task.ref.getDownloadURL();
  }

  Future<Poll> createPoll({
    required String question,
    required List<String> answerTexts,
    required PollAnswerType answerType,
    required DateTime deadline,
    String? imageUrl,
  }) async {
    final pollRef = _db.collection('polls').doc();
    final answers = answerTexts
        .asMap()
        .entries
        .map((e) => PollAnswer(
              id: 'a${e.key}',
              text: e.value,
            ))
        .toList();

    final poll = Poll(
      id: pollRef.id,
      question: question,
      imageUrl: imageUrl,
      answers: answers,
      answerType: answerType,
      deadline: deadline,
      status: PollStatus.active,
      createdAt: DateTime.now(),
      createdBy: uid,
    );
    await pollRef.set(poll.toFirestore());
    return poll;
  }

  Future<void> updatePoll({
    required String pollId,
    String? question,
    String? imageUrl,
    List<String>? answerTexts,
    PollAnswerType? answerType,
    DateTime? deadline,
  }) async {
    final Map<String, dynamic> updates = {};
    if (question != null) updates['question'] = question;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;
    if (answerType != null) {
      updates['answerType'] =
          answerType == PollAnswerType.checkbox ? 'checkbox' : 'radio';
    }
    if (deadline != null) updates['deadline'] = Timestamp.fromDate(deadline);
    if (answerTexts != null) {
      updates['answers'] = answerTexts
          .asMap()
          .entries
          .map((e) => PollAnswer(id: 'a${e.key}', text: e.value).toMap())
          .toList();
    }
    await _db.collection('polls').doc(pollId).update(updates);
  }

  Future<void> deletePoll(String pollId) async {
    await _db.collection('polls').doc(pollId).delete();
  }

  // Called by a Cloud Function / scheduled job at deadline.
  // Can also be triggered manually by admin.
  Future<void> takeDeadlineSnapshot(Poll poll) async {
    if (poll.deadlineSnapshotTaken) return;
    await _db.collection('polls').doc(poll.id).update({
      'deadlineSnapshotTaken': true,
      'deadlineTotalVotes': poll.totalVotes,
      'answers': poll.answers
          .map((a) => a.copyWith(deadlineVoteCount: a.voteCount).toMap())
          .toList(),
    });
  }
}
