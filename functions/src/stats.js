const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

/**
 * Persona badge calculator.
 * Returns one of: open_minded, conviction, passionate, calm, observer, consistent
 */
function calculatePersona(stats) {
  const totalVotes = stats.totalVotes ?? 0;
  const voteChanges = stats.voteChanges ?? 0;
  const totalComments = stats.totalComments ?? 0;
  const recent = stats.recentToxicityScores ?? [];
  const avgToxicity =
    recent.length > 0
      ? recent.reduce((a, b) => a + b, 0) / recent.length
      : 0;

  const voteChangeRate = totalVotes > 0 ? voteChanges / totalVotes : 0;
  const commentRate = totalVotes > 0 ? totalComments / totalVotes : 0;

  // Need at least 5 votes to assign a persona
  if (totalVotes < 5) return 'newcomer';

  if (voteChangeRate >= 0.4) return 'open_minded';
  if (voteChangeRate < 0.1 && totalVotes >= 10) return 'conviction';
  if (avgToxicity > 0.4 && totalComments >= 5) return 'passionate';
  if (avgToxicity < 0.1 && commentRate > 0.5) return 'calm';
  if (commentRate < 0.2 && totalVotes >= 10) return 'observer';
  return 'balanced';
}

/**
 * Firestore trigger: when a vote is created or updated,
 * recalculate user stats incrementally.
 */
exports.onVoteWritten = functions.firestore
  .document('votes/{voteId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) return;
    const after = change.after.data();
    const before = change.before.exists ? change.before.data() : null;
    const userId = after.userId;
    if (!userId) return;

    const statsRef = db.doc(`user_stats/${userId}`);

    // Detect: new vote vs update vs deadline-after change
    const isNew = !before;
    const isOpinionChange =
      before &&
      JSON.stringify(before.answerIds) !== JSON.stringify(after.answerIds);

    const updates = {
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (isNew) {
      updates.totalVotes = admin.firestore.FieldValue.increment(1);
      updates.lastVotedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    if (isOpinionChange) {
      updates.voteChanges = admin.firestore.FieldValue.increment(1);
      if (after.isAfterDeadline) {
        updates.postDeadlineChanges =
          admin.firestore.FieldValue.increment(1);
      }
    }

    await statsRef.set(updates, { merge: true });

    // Recalc persona (separate read to get current totals)
    const statsDoc = await statsRef.get();
    const persona = calculatePersona(statsDoc.data() ?? {});
    await statsRef.set({ persona }, { merge: true });
  });

/**
 * Callable: recalculate persona for current user (e.g. on profile screen open).
 * Useful for backfill or after manual edits.
 */
exports.recalculatePersona = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      '로그인이 필요합니다.',
    );
  }
  const uid = context.auth.uid;
  const statsRef = db.doc(`user_stats/${uid}`);
  const doc = await statsRef.get();
  if (!doc.exists) return { persona: 'newcomer' };

  const persona = calculatePersona(doc.data());
  await statsRef.set({ persona }, { merge: true });
  return { persona };
});
