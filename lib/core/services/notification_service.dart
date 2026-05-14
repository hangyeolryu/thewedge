import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Top-level handler for background FCM messages (must be top-level, not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main(); just log here.
  debugPrint('FCM background: ${message.messageId}');
}

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (iOS / web)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Subscribe to topic for broadcast notifications (all users)
    await _messaging.subscribeToTopic('all_users');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          'FCM foreground: ${message.notification?.title} — ${message.notification?.body}');
      // In-app banner can be shown here via a Riverpod StateProvider if needed
    });
  }

  /// Save the user's FCM token to Firestore so we can send targeted notifications.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }

  /// Subscribe to a poll's deadline reminder topic.
  Future<void> subscribeToPoll(String pollId) async {
    await _messaging.subscribeToTopic('poll_$pollId');
  }

  /// Unsubscribe from a poll's topic (e.g., after deadline passes).
  Future<void> unsubscribeFromPoll(String pollId) async {
    await _messaging.unsubscribeFromTopic('poll_$pollId');
  }

  /// Upload current FCM token to Firestore via Cloud Function.
  /// Call this after user signs in.
  Future<void> saveFcmTokenToServer() async {
    try {
      final token = await getToken();
      if (token == null) return;
      final fn = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
      await fn.httpsCallable('saveFcmToken').call({'token': token});
    } catch (e) {
      debugPrint('saveFcmToken error: $e');
    }
  }
}
