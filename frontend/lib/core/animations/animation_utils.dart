import 'package:flutter/material.dart';

/// AnimatedCounter animates a double value change with a custom easing curve.
/// Perfect for KPI cards — numbers count up on first load.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutExpo,
    this.fractionDigits = 0,
  });

  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        final display = fractionDigits == 0
            ? animatedValue.toInt().toString()
            : animatedValue.toStringAsFixed(fractionDigits);
        return Text('$prefix$display$suffix', style: style);
      },
    );
  }
}

/// ParallaxCard shifts its child based on scroll offset — a true parallax.
class ParallaxCard extends StatelessWidget {
  const ParallaxCard({
    super.key,
    required this.child,
    this.parallaxFactor = 0.3,
  });

  final Widget child;
  final double parallaxFactor;

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: _ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        parallaxFactor: parallaxFactor,
      ),
      children: [child],
    );
  }
}

class _ParallaxFlowDelegate extends FlowDelegate {
  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.parallaxFactor,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final double parallaxFactor;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox?;
    if (listItemBox == null) {
      context.paintChild(0);
      return;
    }
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);
    final verticalAlignment = Alignment(0, scrollFraction * 2 - 1);
    final childSize = context.getChildSize(0) ?? Size.zero;
    final childRect = verticalAlignment.inscribe(
      childSize,
      Offset.zero & context.size,
    );
    final shift = (childSize.height - context.size.height) *
        parallaxFactor *
        scrollFraction;
    context.paintChild(0,
        transform: Transform.translate(
                offset: Offset(childRect.left, childRect.top - shift))
            .transform);
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext;
  }
}

/// StaggeredFadeSlide animates a child with fade + upward slide on mount.
class StaggeredFadeSlide extends StatefulWidget {
  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 24,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final Duration delay;
  final double offsetY;
  final Duration duration;

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
