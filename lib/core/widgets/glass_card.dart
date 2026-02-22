import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enterprise glassmorphic card with blur + translucent fill.
/// Used heavily for KPI cards, modals, overlays.
class GlassmorphicCard extends StatelessWidget {
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 12,
    this.padding = const EdgeInsets.all(20),
    this.border,
    this.gradient,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsets padding;
  final Border? border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>();
    final glassColor = ext?.glassColor ?? Colors.white.withAlpha(20);
    final glassBorder = ext?.glassBorder ?? Colors.white.withAlpha(40);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [glassColor, glassColor.withAlpha(10)],
                ),
            border: border ??
                Border.all(
                  color: glassBorder,
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Gradient card — solid gradient background, elevated drop shadow.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.shadowColor,
  });

  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? gradientColors.first).withAlpha(77),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Status badge with color-coded dot indicator.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
