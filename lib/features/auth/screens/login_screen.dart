import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

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
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Animated background orbs (glow)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbController,
              builder: (_, __) => CustomPaint(
                painter: _OrbsPainter(progress: _orbController.value),
              ),
            ),
          ),
          // Subtle grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  // Logo mark
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.gradientHero.createShader(bounds),
                    child: Text(
                      '더 왜지?',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'TheWedge',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '같은 질문, 다른 생각.\n당신의 의견은 어떻게 변하나요?',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Error
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: AppSpacing.sm),
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
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Social buttons
                  _SocialButton(
                    label: '카카오로 시작하기',
                    backgroundColor: AppColors.kakaoYellow,
                    foregroundColor: AppColors.kakaoText,
                    icon: const _Mark(text: 'K', color: Color(0xFF391B1B)),
                    loading: _loading,
                    onTap: () => _handleSignIn(auth.signInWithKakao),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SocialButton(
                    label: 'Google로 시작하기',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F1F2B),
                    icon: const _Mark(text: 'G', color: Color(0xFF4285F4)),
                    loading: _loading,
                    onTap: () => _handleSignIn(auth.signInWithGoogle),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SocialButton(
                    label: 'Apple로 시작하기',
                    backgroundColor: AppColors.surfaceElev,
                    foregroundColor: AppColors.textPrimary,
                    icon: const Icon(Icons.apple,
                        color: AppColors.textPrimary, size: 20),
                    bordered: true,
                    loading: _loading,
                    onTap: () => _handleSignIn(auth.signInWithApple),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      '계속 진행 시 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
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
  final bool bordered;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.loading,
    this.bordered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: bordered
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: foregroundColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  final String text;
  final Color color;
  const _Mark({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          color: color,
        ),
      ),
    );
  }
}

class _OrbsPainter extends CustomPainter {
  final double progress;
  _OrbsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Violet orb — top right
    final violetCenter = Offset(
      size.width * 0.85 + math.cos(t) * 30,
      size.height * 0.15 + math.sin(t) * 20,
    );
    canvas.drawCircle(
      violetCenter,
      size.width * 0.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accent.withOpacity(0.45),
            AppColors.accent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
            center: violetCenter, radius: size.width * 0.6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );

    // Coral orb — bottom left
    final coralCenter = Offset(
      size.width * 0.15 + math.cos(t + math.pi) * 25,
      size.height * 0.85 + math.sin(t + math.pi) * 20,
    );
    canvas.drawCircle(
      coralCenter,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.highlight.withOpacity(0.35),
            AppColors.highlight.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
            center: coralCenter, radius: size.width * 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.025)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
