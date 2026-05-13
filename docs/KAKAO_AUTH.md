# Kakao Authentication Setup

Kakao does not issue Firebase-compatible tokens directly. You need a backend
step to exchange the Kakao access token for a Firebase Custom Token.

## Architecture

```
Flutter app
  └─ Kakao SDK login → Kakao access token
       └─ POST /api/kakao-auth (your Cloud Function / server)
            └─ Verify token with Kakao API
                 └─ firebase-admin.createCustomToken(kakaoUid)
                      └─ Return custom token → Flutter signInWithCustomToken()
```

## Setup steps

### 1. Firebase Cloud Function (Node.js)

```javascript
// functions/src/kakaoAuth.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

exports.kakaoCustomToken = functions.https.onCall(async (data, context) => {
  const { kakaoAccessToken } = data;

  // Verify token with Kakao and get user info
  const { data: kakaoUser } = await axios.get('https://kapi.kakao.com/v2/user/me', {
    headers: { Authorization: `Bearer ${kakaoAccessToken}` },
  });

  const uid = `kakao:${kakaoUser.id}`;
  const customToken = await admin.auth().createCustomToken(uid, {
    provider: 'kakao',
    name: kakaoUser.kakao_account?.profile?.nickname,
    photoUrl: kakaoUser.kakao_account?.profile?.profile_image_url,
  });

  return { customToken };
});
```

### 2. Flutter — update signInWithKakao() in auth_provider.dart

```dart
Future<void> signInWithKakao() async {
  if (await kakao_sdk.isKakaoTalkInstalled()) {
    await kakao_sdk.UserApi.instance.loginWithKakaoTalk();
  } else {
    await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
  }

  final token = await kakao_sdk.TokenManagerProvider.instance.manager.getToken();
  final functions = FirebaseFunctions.instance;
  final result = await functions.httpsCallable('kakaoCustomToken').call({
    'kakaoAccessToken': token!.accessToken,
  });

  final customToken = result.data['customToken'] as String;
  final userCred = await _auth.signInWithCustomToken(customToken);
  await _upsertUser(userCred.user!, AuthProvider.kakao);
}
```

### 3. Kakao Developer Console

- Register your app at https://developers.kakao.com
- Add platform: Android (com.thewedge.app) and iOS (com.thewedge.app)
- Enable Kakao Login in "kakao login" settings
- Add `kakao{YOUR_NATIVE_APP_KEY}://oauth` as redirect URI

### 4. Android — AndroidManifest.xml

Replace `${YOUR_KAKAO_NATIVE_APP_KEY}` with your actual key (no `${}`).

### 5. iOS — Info.plist

Add:
```xml
<key>KAKAO_APP_KEY</key>
<string>YOUR_KAKAO_NATIVE_APP_KEY</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>kakaoYOUR_KAKAO_NATIVE_APP_KEY</string>
    </array>
  </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>kakaokompassauth</string>
  <string>storykompassauth</string>
  <string>kakaolink</string>
</array>
```
