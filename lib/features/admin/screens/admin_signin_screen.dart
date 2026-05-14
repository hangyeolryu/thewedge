import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/admin_allowlist_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../marketing/widgets/marketing_nav.dart';

class AdminSigninScreen extends ConsumerStatefulWidget {
  const AdminSigninScreen({super.key});

  @override
  ConsumerState<AdminSigninScreen> createState() => _AdminSigninScreenState();
}

class _AdminSigninScreenState extends ConsumerState<AdminSigninScreen> {
  bool _signingIn = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _signingIn = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();

      // After sign-in, check Remote Config allowlist
      final user = await ref.read(authStateProvider.future);
      final email = user?.email;
      final isAllowed =
          await ref.read(adminAllowlistServiceProvider).isAllowed(email);

      if (!isAllowed) {
        await ref.read(authServiceProvider).signOut();
        if (mounted) {
          setState(() {
            _error =
                '등록되지 않은 관리자 계정입니다.\n($email)\n관리자에게 권한 요청을 해주세요.';
          });
        }
        return;
      }

      // Promote role to admin in users doc (rules allow self-update of non-role
      // fields; role promotion needs to go through a Cloud Function in prod,
      // but for allowlisted users we trust the client write here gated by RC).
      // Simplest: redirect; admin role check in router uses the allowlist too.
      if (mounted) context.go('/admin');
    } catch (e) {
      if (mounted) {
        setState(() => _error = '로그인 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MarketingNav(),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 80 : 20, vertical: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: glassSurface(elevated: true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientHero,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 24),
                        Text('관리자 로그인', style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          '등록된 관리자 계정으로만 접근 가능해요.',
                          style: AppTextStyles.bodySm,
                        ),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: _signingIn ? null : _signInWithGoogle,
                          icon: _signingIn
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.g_mobiledata,
                                  size: 28, color: Colors.white),
                          label: Text(
                            _signingIn ? '로그인 중...' : 'Google로 로그인',
                            style: const TextStyle(fontSize: 15),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.error, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error,
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElev,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.textTertiary, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '관리자 권한이 필요하다면 ${AppConstants.contactEmail}로 문의해주세요.',
                                  style: AppTextStyles.bodySm
                                      .copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
