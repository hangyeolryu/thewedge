// Web stub — Kakao SDK is mobile-only
Future<bool> isKakaoTalkInstalled() async => false;
Future<void> loginWithKakaoTalk() async =>
    throw UnsupportedError('Kakao not supported on web');
Future<void> loginWithKakaoAccount() async =>
    throw UnsupportedError('Kakao not supported on web');
Future<void> kakaoLogout() async {}
