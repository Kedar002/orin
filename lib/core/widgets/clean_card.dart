import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// Clean, minimal card component
/// Follows Apple design philosophy with generous spacing
class CleanCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool enablePressAnimation;

  const CleanCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.enablePressAnimation = false,
  });

  @override
  State<CleanCard> createState() => _CleanCardState();
}

class _CleanCardState extends State<CleanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enablePressAnimation) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enablePressAnimation) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enablePressAnimation) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: widget.color,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      Widget tappableCard = InkWell(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );

      if (widget.enablePressAnimation) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: tappableCard,
        );
      }

      return tappableCard;
    }

    return card;
  }
}
