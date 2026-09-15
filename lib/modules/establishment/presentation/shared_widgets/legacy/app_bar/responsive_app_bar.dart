import 'package:flutter/material.dart';

/// Picks the mobile / tablet / desktop app bar for the available width.
///
/// This used to push the width into a GetX `ScreenSizeController` from inside
/// the `LayoutBuilder` callback and then read the resulting `RxBool`s back out.
/// Assigning an `Rx` value notifies its listeners, and the callback runs
/// *during layout* — so the notification marked widgets dirty in the middle of
/// the layout pass. Flutter caught that as
/// `!_debugDoingThisLayout is not true` on this LayoutBuilder, and every box
/// under it then failed with `RenderBox was not laid out`, which paints as a
/// blank screen.
///
/// The width is all the decision needs, and nothing outside these builders ever
/// read those flags, so the branch is now computed from `constraints` with no
/// side effect. Breakpoints are unchanged.
class ResponsiveAppBar extends StatelessWidget {
  const ResponsiveAppBar({
    super.key,
    required this.mobile,
    required this.web,
    required this.tablet,
  });

  final Widget mobile, web, tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        if (width <= 414) return mobile;
        if (width < 800) return tablet;
        // Desktop, and also the fallback: the old code returned an empty
        // Scaffold for anything that matched no branch (a width of exactly
        // 800), which rendered a blank bar.
        return web;
      },
    );
  }
}
