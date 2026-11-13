import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Thin bar with a segment sliding back and forth, for work without a known
/// progress. Always animates (the stock indicator showed a solid bar on device).
class IndeterminateBar extends StatefulWidget {
  const IndeterminateBar({super.key});

  @override
  State<IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<IndeterminateBar>
    with SingleTickerProviderStateMixin {
  static const _height = 6.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          height: _height,
          child: ColoredBox(
            color: colors.selectedBg,
            child: AnimatedBuilder(
              animation: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_controller.value);
                return Align(
                  alignment: Alignment(-1 + 2 * t, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.35,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
