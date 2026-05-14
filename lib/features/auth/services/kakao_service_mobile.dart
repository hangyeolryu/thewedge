import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as k;

void initKakaoSdk(String nativeAppKey) => k.KakaoSdk.init(nativeAppKey: nativeAppKey);

Future<bool> isKakaoTalkInstalled() => k.isKakaoTalkInstalled();
Future<void> loginWithKakaoTalk() => k.UserApi.instance.loginWithKakaoTalk();
Future<void> loginWithKakaoAccount() =>
    k.UserApi.instance.loginWithKakaoAccount();
Future<void> kakaoLogout() async {
  try {
    await k.UserApi.instance.logout();
  } catch (_) {}
}
