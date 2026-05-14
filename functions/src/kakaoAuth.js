const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

/**
 * Exchange Kakao access token → Firebase custom token.
 * Client calls this after Kakao SDK login, then signs into Firebase
 * with the returned customToken.
 */
exports.kakaoCustomToken = functions.https.onCall(async (data, context) => {
  const { kakaoAccessToken } = data;
  if (!kakaoAccessToken) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'kakaoAccessToken이 필요합니다.',
    );
  }

  let kakaoUser;
  try {
    const response = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: { Authorization: `Bearer ${kakaoAccessToken}` },
      timeout: 5000,
    });
    kakaoUser = response.data;
  } catch (err) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Kakao 토큰 검증에 실패했습니다.',
    );
  }

  const uid = `kakao:${kakaoUser.id}`;
  const profile = kakaoUser.kakao_account?.profile ?? {};
  const customToken = await admin.auth().createCustomToken(uid, {
    provider: 'kakao',
  });

  // Upsert user doc
  const userRef = admin.firestore().doc(`users/${uid}`);
  const doc = await userRef.get();
  if (!doc.exists) {
    await userRef.set({
      displayName: profile.nickname ?? null,
      email: kakaoUser.kakao_account?.email ?? null,
      photoUrl: profile.profile_image_url ?? null,
      provider: 'kakao',
      role: 'user',
      isNiceVerified: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return { customToken };
});
