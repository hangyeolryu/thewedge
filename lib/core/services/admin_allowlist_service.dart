import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads admin allowlist from Firebase Remote Config.
///
/// Set up in Firebase Console → Remote Config:
///   Key:   admin_emails
///   Type:  JSON
///   Value: ["you@effeffcorp.com", "ops@effeffcorp.com"]
///
/// The list controls which Google-authenticated users can access /admin on web.
class AdminAllowlistService {
  static const _key = 'admin_emails';
  static const _defaultEmails = '[]';

  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // 5 min cache in prod; 0 in debug for fast iteration
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(minutes: 5),
    ));
    await _rc.setDefaults(const {_key: _defaultEmails});
    try {
      await _rc.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
    _initialized = true;
  }

  Future<List<String>> allowedEmails() async {
    await _ensureInitialized();
    final raw = _rc.getString(_key);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => (e as String).trim().toLowerCase()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> isAllowed(String? email) async {
    if (email == null || email.isEmpty) return false;
    final allowed = await allowedEmails();
    return allowed.contains(email.trim().toLowerCase());
  }
}

final adminAllowlistServiceProvider = Provider<AdminAllowlistService>((ref) {
  return AdminAllowlistService();
});

/// FutureProvider that tells whether the currently signed-in user's email
/// is in the Remote Config admin allowlist. Use this on web to gate /admin.
final isAdminAllowedProvider = FutureProvider.family<bool, String?>(
  (ref, email) async {
    final svc = ref.watch(adminAllowlistServiceProvider);
    return svc.isAllowed(email);
  },
);
