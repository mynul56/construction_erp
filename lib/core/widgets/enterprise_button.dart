import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Enterprise-grade animated button with press-scale effect and gradient fill.
class EnterpriseButton extends StatefulWidget {
  const EnterpriseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradientColors = AppColors.cyanGradient,
    this.width = double.infinity,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color> gradientColors;
  final double width;
  final double height;

  @override
  State<EnterpriseButton> createState() => _EnterpriseButtonState();
}

class _EnterpriseButtonState extends State<EnterpriseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: widget.onPressed == null
                  ? [Colors.grey.shade600, Colors.grey.shade700]
                  : widget.gradientColors,
            ),
            boxShadow: widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: widget.gradientColors.first.withAlpha(77),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.navyDeep),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: AppColors.navyDeep, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.navyDeep,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
