import 'package:flutter/material.dart';
import 'package:login_rive_animation/theme/app_theme.dart';
import 'package:lottie/lottie.dart';

/// Lottie animations (LottieFiles, Lottie Simple License).
abstract final class ReptileAnimations {
  static const loading = 'assets/lottie/lizard_running.lottie';
  static const empty = 'assets/lottie/chameleon.lottie';
  static const error = 'assets/lottie/snake.lottie';
  static const hero = 'assets/lottie/chameleon_colors.lottie';
}

/// Full-area state (loading, empty, error) with an animated reptile.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.animation,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String animation;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(animation, width: 180, height: 180),
            const SizedBox(height: 16),
            Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
