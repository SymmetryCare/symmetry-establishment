import 'package:flutter/material.dart';

/// Circular reload control used across the onboarding screens.
///
/// Every onboarding section pulls its dropdowns and its prefilled form data
/// once, when its widget first mounts, so anything changed server-side after
/// that (a newly added degree, for instance) only appeared after a full
/// browser reload — and reloading drops the session, forcing a fresh login.
/// This button gives those screens an in-app way to re-run just the fetches
/// the section on screen owns.
///
/// [onPressed] fires immediately. The icon spins for [_spinDuration]
/// afterwards purely as feedback: the refetch happens inside the widgets the
/// caller remounts (or inside a provider), so there is nothing here to await.
class RefreshIconButton extends StatefulWidget {
  const RefreshIconButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Refresh',
    this.size = 36,
    this.color = const Color(0xFF008ABD),
  });

  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final Color color;

  @override
  State<RefreshIconButton> createState() => _RefreshIconButtonState();
}

class _RefreshIconButtonState extends State<RefreshIconButton>
    with SingleTickerProviderStateMixin {
  static const Duration _spinDuration = Duration(milliseconds: 700);

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: _spinDuration,
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _handleTap() {
    // A second press while the first is still spinning is swallowed, so a
    // double-click can't stack two refetches of the same section.
    if (_spin.isAnimating) return;
    _spin.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: RotationTransition(
              turns: _spin,
              child: Icon(
                Icons.refresh_rounded,
                size: widget.size * 0.58,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
