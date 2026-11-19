import 'package:material_ui/material_ui.dart';

/// Shrinks its child to [scale] while a pointer is down, as tap feedback.
/// A quick tap still plays the full press before springing back, so the
/// feedback stays visible even when the tap immediately opens another page.
/// Does not take part in gestures, so the child's own tap handling is unchanged.
/// Skipped when [enabled] is false or the system "remove animations" is on.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 0.96,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  bool _pressed = false;

  void _down() {
    _pressed = true;
    _controller.forward();
  }

  void _up() {
    _pressed = false;
    _controller.forward().whenCompleteOrCancel(() {
      if (mounted && !_pressed) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _down(),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1,
          end: widget.scale,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: widget.child,
      ),
    );
  }
}
