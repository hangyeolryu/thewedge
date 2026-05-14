import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/user_stats_model.dart';

final _db = FirebaseFirestore.instance;

/// Stream of the current user's stats document.
final myStatsProvider = StreamProvider<UserStats?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);

  return _db
      .collection('user_stats')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists
          ? UserStats.fromFirestore(doc)
          : UserStats(uid: uid));
});

/// Compare current user vs platform-wide averages (for the report card).
/// In production, these averages would be computed by a scheduled function.
/// For now, return reasonable placeholder values.
final platformAveragesProvider = Provider<PlatformAverages>((ref) {
  return const PlatformAverages(
    avgVoteChangeRate: 0.22,
    avgCommentRate: 0.35,
    avgToxicityScore: 0.18,
  );
});

class PlatformAverages {
  final double avgVoteChangeRate;
  final double avgCommentRate;
  final double avgToxicityScore;
  const PlatformAverages({
    required this.avgVoteChangeRate,
    required this.avgCommentRate,
    required this.avgToxicityScore,
  });
}
