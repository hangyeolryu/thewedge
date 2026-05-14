const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

const PERSPECTIVE_API_URL =
  'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

const THRESHOLDS = {
  block: 0.85,    // hard block
  blur: 0.60,     // blur with warning
};

const ATTRIBUTES = [
  'TOXICITY',
  'SEVERE_TOXICITY',
  'IDENTITY_ATTACK',
  'INSULT',
  'THREAT',
  'INFLAMMATORY',
];

/**
 * Score a comment via Perspective API.
 * Returns { scores: {ATTR: number}, maxScore: number, status }.
 */
async function scoreText(text) {
  const apiKey = functions.config().perspective?.key;
  if (!apiKey) {
    console.warn('Perspective API key missing — skipping moderation');
    return { scores: {}, maxScore: 0, status: 'visible' };
  }

  const requestedAttributes = {};
  for (const attr of ATTRIBUTES) {
    requestedAttributes[attr] = {};
  }

  try {
    const response = await axios.post(
      `${PERSPECTIVE_API_URL}?key=${apiKey}`,
      {
        comment: { text },
        languages: ['ko', 'en'],
        requestedAttributes,
        doNotStore: true,
      },
      { timeout: 8000 },
    );

    const scores = {};
    let maxScore = 0;
    for (const attr of ATTRIBUTES) {
      const score =
        response.data.attributeScores?.[attr]?.summaryScore?.value ?? 0;
      scores[attr] = score;
      if (score > maxScore) maxScore = score;
    }

    let status = 'visible';
    if (maxScore >= THRESHOLDS.block) status = 'blocked';
    else if (maxScore >= THRESHOLDS.blur) status = 'blurred';

    return { scores, maxScore, status };
  } catch (err) {
    console.error('Perspective API error:', err.message);
    return { scores: {}, maxScore: 0, status: 'visible' };
  }
}

/**
 * Callable function: moderate a comment in real time before it's posted.
 * Returns moderation result so the client can show a warning before submit.
 */
exports.moderateComment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      '로그인이 필요합니다.',
    );
  }
  const { text } = data;
  if (!text || text.length > 1000) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '댓글 길이가 올바르지 않습니다.',
    );
  }
  return await scoreText(text);
});

/**
 * Firestore trigger: when a comment is created/updated, run moderation
 * and update the doc with toxicity scores + status.
 * Also enforces auto-blur at 3+ flags (belt-and-suspenders on top of client logic).
 */
exports.onCommentWritten = functions.firestore
  .document('comments/{commentId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) return; // deleted
    const after = change.after.data();
    const before = change.before.exists ? change.before.data() : null;

    // Auto-blur enforcement: if flaggedBy array grew and is now >= 3
    const prevFlags = (before?.flaggedBy ?? []).length;
    const nowFlags = (after.flaggedBy ?? []).length;
    if (nowFlags >= 3 && nowFlags !== prevFlags && after.status === 'visible') {
      await change.after.ref.update({ status: 'blurred' });
    }

    // Only re-score if text changed or never scored
    if (before && before.text === after.text && after.toxicityScore != null) {
      return;
    }

    const result = await scoreText(after.text);

    // Don't downgrade manually-blurred/blocked comments from flagging
    const currentStatus = after.status;
    const newStatus =
      currentStatus === 'blocked' ? 'blocked' : result.status;

    await change.after.ref.update({
      toxicityScore: result.maxScore,
      toxicityScores: result.scores,
      status: newStatus,
      moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update user stats: blocked count + average toxicity
    const userId = after.userId;
    if (userId) {
      const statsRef = admin.firestore().doc(`user_stats/${userId}`);
      await statsRef.set(
        {
          totalComments: admin.firestore.FieldValue.increment(1),
          blockedComments:
            newStatus === 'blocked'
              ? admin.firestore.FieldValue.increment(1)
              : admin.firestore.FieldValue.increment(0),
          recentToxicityScores: admin.firestore.FieldValue.arrayUnion(
            result.maxScore,
          ),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
  });
