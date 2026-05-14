import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao_sdk;

import '../models/app_user.dart';

// Raw Firebase auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Full AppUser document from Firestore
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _auth.signInWithCredential(credential);
    await _upsertUser(userCred.user!, AuthProvider.google);
  }

  Future<void> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCred = await _auth.signInWithCredential(oauthCredential);
    // Apple only sends name on first login — persist it
    final displayName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    await _upsertUser(
      userCred.user!,
      AuthProvider.apple,
      displayNameOverride: displayName.isNotEmpty ? displayName : null,
    );
  }

  Future<void> signInWithKakao() async {
    // Try Kakao Talk first, fall back to web browser
    try {
      if (await kakao_sdk.isKakaoTalkInstalled()) {
        await kakao_sdk.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
      }
    } catch (e) {
      await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
    }

    final kakaoUser = await kakao_sdk.UserApi.instance.me();

    // Exchange Kakao token for a Firebase custom token via your backend.
    // For now we create a pseudo-UID and use the custom sign-in flow.
    // TODO: call your Cloud Function / backend to exchange and get a Firebase custom token.
    throw UnimplementedError(
      'Kakao → Firebase custom token exchange requires a backend Cloud Function. '
      'See docs/KAKAO_AUTH.md for setup instructions.',
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    try {
      await kakao_sdk.UserApi.instance.logout();
    } catch (_) {}
  }

  Future<void> _upsertUser(
    User firebaseUser,
    AuthProvider provider, {
    String? displayNameOverride,
  }) async {
    final ref = _db.collection('users').doc(firebaseUser.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: displayNameOverride ?? firebaseUser.displayName,
        email: firebaseUser.email,
        photoUrl: firebaseUser.photoURL,
        provider: provider,
        createdAt: DateTime.now(),
      );
      await ref.set(appUser.toFirestore());
    } else {
      // Update mutable fields only
      await ref.update({
        'displayName': displayNameOverride ??
            firebaseUser.displayName ??
            (doc.data()!['displayName']),
        'photoUrl': firebaseUser.photoURL ?? doc.data()!['photoUrl'],
      });
    }
  }
}
