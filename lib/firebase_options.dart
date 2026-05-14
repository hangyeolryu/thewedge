// Firebase configuration for the thewedge-woo project.
// Update by running: flutterfire configure --project=thewedge-woo

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkn1PpUNCUaOawvBXao_UyfJteEe5WSQ4',
    appId: '1:223685413206:web:e3c2642bb3ef2ba240eef7',
    messagingSenderId: '223685413206',
    projectId: 'thewedge-woo',
    authDomain: 'thewedge-woo.firebaseapp.com',
    storageBucket: 'thewedge-woo.firebasestorage.app',
    measurementId: 'G-LHHBVFJ57E',
  );

  // TODO: Replace these with android/ios specific configs by running
  // `flutterfire configure --project=thewedge-woo` in the project root.
  // The web config above will work for web builds immediately.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkn1PpUNCUaOawvBXao_UyfJteEe5WSQ4',
    appId: '1:223685413206:android:PLACEHOLDER',
    messagingSenderId: '223685413206',
    projectId: 'thewedge-woo',
    storageBucket: 'thewedge-woo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCngJDgOylOGTqm_BQ4o0zxE7pxhIznEUo',
    appId: '1:223685413206:ios:bfcdd739990f220940eef7',
    messagingSenderId: '223685413206',
    projectId: 'thewedge-woo',
    storageBucket: 'thewedge-woo.firebasestorage.app',
    iosBundleId: 'com.effeffcorp.thewedge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCngJDgOylOGTqm_BQ4o0zxE7pxhIznEUo',
    appId: '1:223685413206:ios:bfcdd739990f220940eef7',
    messagingSenderId: '223685413206',
    projectId: 'thewedge-woo',
    storageBucket: 'thewedge-woo.firebasestorage.app',
    iosBundleId: 'com.effeffcorp.thewedge',
  );
}
