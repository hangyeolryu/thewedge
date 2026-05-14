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
