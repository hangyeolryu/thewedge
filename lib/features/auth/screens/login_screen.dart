import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn(Future<void> Function() action) async {
    setState(() { _loading = true; _error = null; });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.highlight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TheWedge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '대국민투표 플랫폼',
                style: TextStyle(
                  color: Color(0xFFB0BEC5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 3),
              // Social sign-in buttons
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _SocialButton(
                label: '카카오로 계속하기',
                backgroundColor: AppColors.kakaoYellow,
                foregroundColor: AppColors.kakaoText,
                icon: _KakaoIcon(),
                loading: _loading,
                onTap: () => _handleSignIn(auth.signInWithKakao),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                label: 'Google로 계속하기',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3C4043),
                icon: _GoogleIcon(),
                loading: _loading,
                onTap: () => _handleSignIn(auth.signInWithGoogle),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                label: 'Apple로 계속하기',
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.apple, color: Colors.white, size: 20),
                loading: _loading,
                onTap: () => _handleSignIn(auth.signInWithApple),
              ),
              const SizedBox(height: 32),
              const Text(
                '로그인 시 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final bool loading;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _KakaoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: const Text(
        'K',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          color: Color(0xFF3A1D1D),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Text(
        'G',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}
