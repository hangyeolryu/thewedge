const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

/**
 * Scheduled job: every 5 minutes, find polls past deadline that haven't
 * had a snapshot taken yet, and freeze the deadline result.
 */
exports.takeDeadlineSnapshot = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    const snap = await db
      .collection('polls')
      .where('deadlineSnapshotTaken', '==', false)
      .where('deadline', '<=', now)
      .get();

    if (snap.empty) return null;

    const batch = db.batch();
    for (const doc of snap.docs) {
      const poll = doc.data();
      const updatedAnswers = (poll.answers ?? []).map((a) => ({
        ...a,
        deadlineVoteCount: a.voteCount ?? 0,
      }));
      batch.update(doc.ref, {
        deadlineSnapshotTaken: true,
        deadlineTotalVotes: poll.totalVotes ?? 0,
        answers: updatedAnswers,
        snapshotTakenAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    console.log(`Snapshot taken for ${snap.size} polls`);
    return null;
  });
