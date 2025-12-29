import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Monochrome LIVE status badge for camera feeds
/// Light mode: Black background with white text and pulsing white dot
/// Dark mode: White background with black text and pulsing black dot
class MonoLiveBadge extends StatefulWidget {
  const MonoLiveBadge({super.key});

  @override
  State<MonoLiveBadge> createState() => _MonoLiveBadgeState();
}

class _MonoLiveBadgeState extends State<MonoLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation (800ms cycle)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Color scheme based on theme
    final backgroundColor = isDark ? AppColors.mono100Dark : AppColors.mono0;
    final foregroundColor = isDark ? AppColors.mono0Dark : AppColors.mono100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: foregroundColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // "LIVE" text
          Text(
            'LIVE',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
