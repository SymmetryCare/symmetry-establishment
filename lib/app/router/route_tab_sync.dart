import 'package:flutter/widgets.dart';

/// Keeps a tabbed page on the tab its URL names while the page stays mounted.
///
/// A page reads its starting tab from the URL once, when it is built. After
/// that the URL can move to another tab of the same page without the page
/// being rebuilt from scratch — Back/Forward between two of its tabs, or a
/// header link back to it. This calls [onTabChanged] with the new tab after
/// such a rebuild, never on the first one.
///
/// A tap on a tab changes the URL too, so [onTabChanged] also runs for the tab
/// the page is already on; implementations do nothing when that is the case.
class RouteTabSync extends StatefulWidget {
  const RouteTabSync({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.child,
  });

  /// The tab the URL names right now.
  final int tab;

  /// Moves the page to [tab]. Runs after the frame, so it may animate a
  /// PageController or notify a provider.
  final ValueChanged<int> onTabChanged;

  final Widget child;

  @override
  State<RouteTabSync> createState() => _RouteTabSyncState();
}

class _RouteTabSyncState extends State<RouteTabSync> {
  @override
  void didUpdateWidget(covariant RouteTabSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab == oldWidget.tab) return;
    final int tab = widget.tab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTabChanged(tab);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
