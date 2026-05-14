const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

/**
 * Pulls the admin_emails JSON from Remote Config and syncs
 * the /admin_allowlist/{email} collection so Firestore rules can
 * check membership via exists().
 *
 * Remote Config key: admin_emails
 * Value type: JSON
 * Example value: ["you@effeffcorp.com", "ops@effeffcorp.com"]
 */
async function syncAdminAllowlist() {
  const template = await admin.remoteConfig().getTemplate();
  const param = template.parameters?.admin_emails;
  const raw = param?.defaultValue?.value || '[]';

  let emails = [];
  try {
    emails = JSON.parse(raw);
  } catch (e) {
    functions.logger.error('admin_emails not valid JSON:', raw);
    return { count: 0 };
  }

  const normalized = emails
    .filter((e) => typeof e === 'string' && e.includes('@'))
    .map((e) => e.trim().toLowerCase());

  const snap = await db.collection('admin_allowlist').get();
  const existing = new Set(snap.docs.map((d) => d.id));
  const desired = new Set(normalized);

  const batch = db.batch();
  for (const email of desired) {
    if (!existing.has(email)) {
      batch.set(db.collection('admin_allowlist').doc(email), {
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
  for (const email of existing) {
    if (!desired.has(email)) {
      batch.delete(db.collection('admin_allowlist').doc(email));
    }
  }
  await batch.commit();
  functions.logger.info(`admin_allowlist synced: ${desired.size} entries`);
  return { count: desired.size };
}

/** Scheduled: every 10 minutes. */
exports.syncAdminAllowlistScheduled = functions
  .region('asia-northeast3')
  .pubsub.schedule('every 10 minutes')
  .onRun(() => syncAdminAllowlist());

/** Callable: manual trigger for admins. */
exports.syncAdminAllowlistNow = functions
  .region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        '로그인이 필요합니다.',
      );
    }
    return await syncAdminAllowlist();
  });

/**
 * Callable: verifies the caller's email is in the Remote Config admin_emails
 * list and promotes their users/{uid} document to role:'admin' via Admin SDK
 * (bypasses Firestore client rules). Safe to call from the admin sign-in flow.
 */
exports.promoteAdminRole = functions
  .region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        '로그인이 필요합니다.',
      );
    }

    const email = context.auth.token.email;
    if (!email) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        '이메일 정보가 없습니다.',
      );
    }

    const template = await admin.remoteConfig().getTemplate();
    const param = template.parameters?.admin_emails;
    const raw = param?.defaultValue?.value || '[]';

    let emails = [];
    try {
      emails = JSON.parse(raw);
    } catch (e) {
      throw new functions.https.HttpsError('internal', 'admin_emails 설정 오류');
    }

    const normalized = emails
      .filter((e) => typeof e === 'string' && e.includes('@'))
      .map((e) => e.trim().toLowerCase());

    if (!normalized.includes(email.toLowerCase())) {
      throw new functions.https.HttpsError(
        'permission-denied',
        '관리자 권한이 없습니다.',
      );
    }

    await db.collection('users').doc(context.auth.uid).update({ role: 'admin' });
    functions.logger.info(`Promoted ${email} to admin`);
    return { success: true };
  });
