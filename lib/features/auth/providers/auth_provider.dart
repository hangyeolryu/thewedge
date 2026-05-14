import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'kakao_service.dart'
    if (dart.library.io) '../services/kakao_service_mobile.dart';

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
    if (kIsWeb) throw UnsupportedError('Apple sign-in not available on web');

    // Dynamically invoke sign_in_with_apple — import guarded at call site
    throw UnimplementedError(
      'Call signInWithAppleMobile() from a mobile-only widget.',
    );
  }

  Future<void> signInWithKakao() async {
    if (kIsWeb) throw UnsupportedError('Kakao sign-in not available on web');
    try {
      if (await isKakaoTalkInstalled()) {
        await loginWithKakaoTalk();
      } else {
        await loginWithKakaoAccount();
      }
    } catch (_) {
      await loginWithKakaoAccount();
    }
    throw UnimplementedError(
      'Kakao → Firebase custom token exchange requires a backend Cloud Function. '
      'See docs/KAKAO_AUTH.md for setup instructions.',
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    if (!kIsWeb) await kakaoLogout();
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
      await ref.update({
        'displayName': displayNameOverride ??
            firebaseUser.displayName ??
            (doc.data()!['displayName']),
        'photoUrl': firebaseUser.photoURL ?? doc.data()!['photoUrl'],
      });
    }
  }
}
