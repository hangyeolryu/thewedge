import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/kakao_service.dart'
    if (dart.library.io) 'features/auth/services/kakao_service_mobile.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    initKakaoSdk(AppConstants.kakaoNativeAppKey);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayDark);
  }

  await NotificationService().initialize();

  runApp(const ProviderScope(child: TheWedgeApp()));
}
