import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Monochrome status indicator dot with animations
/// Represents different states through visual styling and animations
/// - Active/Success: Solid circle with pulse animation
/// - Warning: Outlined circle with breathing animation
/// - Error/Inactive: Empty outline, no animation
enum MonoStatusType {
  /// Active/Online/Success - Solid dot with pulse
  active,

  /// Warning/Attention - Outlined dot with breathing
  warning,

  /// Error/Offline/Inactive - Empty outline, static
  inactive,
}

class MonoStatusDot extends StatefulWidget {
  final MonoStatusType type;
  final double size;

  const MonoStatusDot({
    super.key,
    required this.type,
    this.size = 8.0,
  });

  @override
  State<MonoStatusDot> createState() => _MonoStatusDotState();
}

class _MonoStatusDotState extends State<MonoStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Setup animation based on type
    if (widget.type == MonoStatusType.active) {
      // Pulse animation for active state (800ms cycle)
      _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else if (widget.type == MonoStatusType.warning) {
      // Breathing animation for warning state (2s cycle)
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 1.0, end: 0.6).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else {
      // No animation for inactive state
      _controller = AnimationController(
        duration: const Duration(milliseconds: 0),
        vsync: this,
      );
      _animation = const AlwaysStoppedAnimation(1.0);
    }
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

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.type == MonoStatusType.active
              ? _animation.value
              : 1.0,
          child: Opacity(
            opacity: widget.type == MonoStatusType.warning
                ? _animation.value
                : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Active: solid fill
                color: widget.type == MonoStatusType.active
                    ? (isDark ? AppColors.mono100Dark : AppColors.mono0)
                    : Colors.transparent,
                // Warning & Inactive: outlined
                border: widget.type != MonoStatusType.active
                    ? Border.all(
                        color: widget.type == MonoStatusType.warning
                            ? (isDark ? AppColors.mono60Dark : AppColors.mono40)
                            : (isDark ? AppColors.mono30Dark : AppColors.mono70),
                        width: widget.type == MonoStatusType.warning ? 1.5 : 1.0,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
