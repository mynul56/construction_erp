import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A card that rotates in 3D based on pointer/drag position.
/// Uses Matrix4 perspective transforms for depth effect.
class TiltCard3D extends StatefulWidget {
  const TiltCard3D({
    super.key,
    required this.child,
    this.maxTiltDegrees = 8.0,
    this.perspective = 0.001,
    this.enableGlow = true,
    this.glowColor,
  });

  final Widget child;
  final double maxTiltDegrees;
  final double perspective;
  final bool enableGlow;
  final Color? glowColor;

  @override
  State<TiltCard3D> createState() => _TiltCard3DState();
}

class _TiltCard3DState extends State<TiltCard3D>
    with SingleTickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;
  double _glowOpacity = 0;

  late AnimationController _returnController;
  late Animation<double> _returnAnimX;
  late Animation<double> _returnAnimY;
  double _savedX = 0;
  double _savedY = 0;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final cx = constraints.maxWidth / 2;
    final cy = constraints.maxHeight / 2;
    final dx = details.localPosition.dx - cx;
    final dy = details.localPosition.dy - cy;

    final maxRad = widget.maxTiltDegrees * math.pi / 180;
    setState(() {
      _rotateY = (dx / cx) * maxRad;
      _rotateX = -(dy / cy) * maxRad;
      _glowOpacity = (((dx.abs() + dy.abs()) / (cx + cy))).clamp(0.0, 1.0);
      _savedX = _rotateX;
      _savedY = _rotateY;
    });
  }

  void _onPanEnd(DragEndDetails _) {
    _returnController.reset();
    _returnAnimX = Tween<double>(begin: _savedX, end: 0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.elasticOut),
    );
    _returnAnimY = Tween<double>(begin: _savedY, end: 0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.elasticOut),
    );
    _returnController.forward();
    _returnController.addListener(() {
      setState(() {
        _rotateX = _returnAnimX.value;
        _rotateY = _returnAnimY.value;
        _glowOpacity = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: Stack(
            children: [
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, widget.perspective)
                  ..rotateX(_rotateX)
                  ..rotateY(_rotateY),
                alignment: Alignment.center,
                child: widget.child,
              ),
              if (widget.enableGlow)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _glowOpacity * 0.3,
                    duration: const Duration(milliseconds: 100),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          colors: [
                            (widget.glowColor ?? const Color(0xFF00D4FF))
                                .withAlpha(77),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
