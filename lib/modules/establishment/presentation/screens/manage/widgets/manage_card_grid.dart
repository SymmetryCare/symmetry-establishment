import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Responsive multi-column layout for the Manage screen's section cards.
///
/// Every section used to stack its cards in a single column, which left a
/// wide band of dead space on the right once the panel grew past one card's
/// width. These two widgets lay the same cards out in as many columns as the
/// panel can fit without squeezing a card below [kManageCardMinWidth]:
/// one column on a narrow panel, two or three as it widens.
///
/// [ManageCardGrid] is the non-scrolling variant, for sections that build
/// their cards eagerly inside a `Column` (Qualifications, Banking). Cards may
/// differ in height — each row sizes to its tallest card.
///
/// [ManageCardGridView] is the scrolling variant, a drop-in replacement for a
/// `ListView.builder` of fixed-height rows (the Documents tabs).

/// A card is never squeezed narrower than this, so a section drops back to
/// fewer columns rather than truncating its values. Not far off the 700px
/// the cards are designed at — at ~520 Banking's account and routing numbers
/// start to ellipsise, and much above 600 the Qualifications panel, which is
/// inset more than Banking's, never reaches two columns at all.
const double kManageCardMinWidth = 600;

/// Cards designed at a fixed width (the 700px [CardDetails] surface) stop
/// growing here; the leftover width stays as margin.
const double kManageCardMaxWidth = 700;

/// Gap between cards, horizontally and vertically.
const double kManageCardSpacing = 16;

/// How many columns of at least [minCardWidth] fit into [availableWidth].
int manageGridColumns(
  double availableWidth, {
  double minCardWidth = kManageCardMinWidth,
  double spacing = kManageCardSpacing,
}) {
  if (!availableWidth.isFinite || availableWidth <= 0) return 1;
  return math.max(
      1, ((availableWidth + spacing) / (minCardWidth + spacing)).floor());
}

/// Width of one card once [availableWidth] is split into that many columns.
double manageGridCardWidth(
  double availableWidth, {
  double minCardWidth = kManageCardMinWidth,
  double? maxCardWidth,
  double spacing = kManageCardSpacing,
}) {
  final int columns = manageGridColumns(availableWidth,
      minCardWidth: minCardWidth, spacing: spacing);
  final double width =
      (availableWidth - spacing * (columns - 1)) / columns;
  return maxCardWidth == null ? width : math.min(width, maxCardWidth);
}

/// Non-scrolling responsive card grid. Children keep their own heights.
class ManageCardGrid extends StatelessWidget {
  final List<Widget> children;

  /// Cards stop growing at this width (null lets them fill their column).
  final double? maxCardWidth;
  final double minCardWidth;
  final double spacing;

  const ManageCardGrid({
    super.key,
    required this.children,
    this.maxCardWidth = kManageCardMaxWidth,
    this.minCardWidth = kManageCardMinWidth,
    this.spacing = kManageCardSpacing,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = manageGridCardWidth(
          constraints.maxWidth,
          minCardWidth: minCardWidth,
          maxCardWidth: maxCardWidth,
          spacing: spacing,
        );
        return ManageCardWidth(
          width: cardWidth,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final child in children)
                SizedBox(width: cardWidth, child: child),
            ],
          ),
        );
      },
    );
  }
}

/// Scrolling responsive card grid — the `ListView.builder` replacement for
/// sections whose rows all share one [cardHeight].
class ManageCardGridView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Height of one card, including any margin it carries itself.
  final double cardHeight;
  final double minCardWidth;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const ManageCardGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.cardHeight,
    this.minCardWidth = kManageCardMinWidth,
    this.spacing = kManageCardSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = manageGridColumns(constraints.maxWidth,
            minCardWidth: minCardWidth, spacing: spacing);
        return GridView.builder(
          padding: padding ?? EdgeInsets.zero,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            // The cards carry their own vertical margin, so the grid adds
            // none of its own on the main axis.
            mainAxisSpacing: 0,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Publishes the column width a [ManageCardGrid] has settled on, so a card
/// built for a fixed width (see `CardDetails`) can fill its column instead.
/// Absent — as in the onboarding screens, which use the same cards outside a
/// grid — the card keeps its own width.
class ManageCardWidth extends InheritedWidget {
  final double width;

  const ManageCardWidth({
    super.key,
    required this.width,
    required super.child,
  });

  static double? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ManageCardWidth>()
      ?.width;

  @override
  bool updateShouldNotify(ManageCardWidth oldWidget) =>
      oldWidget.width != width;
}
