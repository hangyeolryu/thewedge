const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Scheduled every 5 minutes: send deadline-approaching alerts for polls
 * closing within the next hour that haven't sent an alert yet.
 */
exports.sendDeadlineReminders = functions
  .region('asia-northeast3')
  .pubsub.schedule('every 5 minutes')
  .onRun(async () => {
    const now = new Date();
    const oneHourLater = new Date(now.getTime() + 60 * 60 * 1000);

    const snap = await db
      .collection('polls')
      .where('status', '==', 'active')
      .where('deadline', '>', now)
      .where('deadline', '<=', oneHourLater)
      .where('reminderSent', '==', false)
      .get();

    if (snap.empty) return null;

    const batch = db.batch();
    const promises = snap.docs.map(async (doc) => {
      const poll = doc.data();
      const minutesLeft = Math.round(
        (poll.deadline.toDate() - now) / 60000,
      );

      try {
        await messaging.send({
          topic: `poll_${doc.id}`,
          notification: {
            title: '⏰ 마감 임박!',
            body: `"${poll.question.substring(0, 40)}..." 투표가 ${minutesLeft}분 후 마감됩니다.`,
          },
          data: {
            type: 'deadline_reminder',
            pollId: doc.id,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            notification: {
              channelId: 'deadline_reminders',
              priority: 'high',
            },
          },
          apns: {
            payload: {
              aps: { sound: 'default', badge: 1 },
            },
          },
        });
        batch.update(doc.ref, { reminderSent: true });
      } catch (err) {
        functions.logger.error('Deadline reminder send failed:', err);
      }
    });

    await Promise.all(promises);
    await batch.commit();
    return null;
  });

/**
 * Scheduled daily at 09:00 KST (00:00 UTC): send "지금도?" re-engagement
 * notifications to users who voted exactly 7 days ago and haven't changed
 * their answer since.
 */
exports.sendReengagementNotifications = functions
  .region('asia-northeast3')
  .pubsub.schedule('0 0 * * *') // 00:00 UTC = 09:00 KST
  .timeZone('UTC')
  .onRun(async () => {
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const windowStart = new Date(sevenDaysAgo.getTime() - 60 * 60 * 1000);
    const windowEnd = new Date(sevenDaysAgo.getTime() + 60 * 60 * 1000);

    // Votes cast around 7 days ago that haven't been updated since
    const votesSnap = await db
      .collection('votes')
      .where('votedAt', '>=', windowStart)
      .where('votedAt', '<=', windowEnd)
      .get();

    const promises = votesSnap.docs.map(async (voteDoc) => {
      const vote = voteDoc.data();
      // Skip if they already changed their answer after the deadline
      if (vote.isAfterDeadline) return;

      // Get the poll
      const pollDoc = await db.collection('polls').doc(vote.pollId).get();
      if (!pollDoc.exists) return;
      const poll = pollDoc.data();
      if (!poll.deadlineSnapshotTaken) return; // not yet past deadline

      // Get the user's FCM token
      const userDoc = await db.collection('users').doc(vote.userId).get();
      if (!userDoc.exists) return;
      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) return;

      try {
        await messaging.send({
          token: fcmToken,
          notification: {
            title: '🤔 지금도 같은 생각인가요?',
            body: `"${poll.question.substring(0, 40)}..." 일주일이 지났습니다. 아직도 같은 의견인가요?`,
          },
          data: {
            type: 'reengagement',
            pollId: vote.pollId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            notification: { channelId: 'reengagement' },
          },
          apns: {
            payload: {
              aps: { sound: 'default' },
            },
          },
        });
      } catch (err) {
        // Token may be stale — clean up
        if (err.code === 'messaging/registration-token-not-registered') {
          await db
            .collection('users')
            .doc(vote.userId)
            .update({ fcmToken: admin.firestore.FieldValue.delete() });
        }
      }
    });

    await Promise.all(promises);
    return null;
  });

/**
 * Callable: save a user's FCM token to their user doc.
 * Called from the Flutter app after NotificationService.getToken().
 */
exports.saveFcmToken = functions
  .region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }
    const { token } = data;
    if (!token || typeof token !== 'string') {
      throw new functions.https.HttpsError('invalid-argument', 'FCM 토큰이 없습니다.');
    }

    await db.collection('users').doc(context.auth.uid).update({
      fcmToken: token,
      fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
  });
