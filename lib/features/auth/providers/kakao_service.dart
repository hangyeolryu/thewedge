// Default stub — overridden by conditional import in auth_provider.dart and main.dart
void initKakaoSdk(String nativeAppKey) {}

Future<bool> isKakaoTalkInstalled() async => false;
Future<void> loginWithKakaoTalk() async =>
    throw UnsupportedError('Kakao not supported');
Future<void> loginWithKakaoAccount() async =>
    throw UnsupportedError('Kakao not supported');
Future<void> kakaoLogout() async {}
