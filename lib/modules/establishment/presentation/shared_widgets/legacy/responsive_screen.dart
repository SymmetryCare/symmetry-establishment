import 'package:flutter/material.dart';

/// Picks the mobile / tablet / desktop screen for the available width.
///
/// Same fix as [ResponsiveAppBar]: the width used to be pushed into a GetX
/// controller from inside the `LayoutBuilder` callback, which notifies
/// listeners during layout and trips
/// `!_debugDoingThisLayout is not true`. The branch is computed from
/// `constraints` now, with no side effect. Breakpoints are unchanged.
class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({
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
        // Desktop, and the fallback for the old empty-Scaffold branch.
        return Padding(
          padding: MediaQuery.of(context).size.width > 1920
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 8)
              : EdgeInsets.zero,
          child: web,
        );
      },
    );
  }
}
