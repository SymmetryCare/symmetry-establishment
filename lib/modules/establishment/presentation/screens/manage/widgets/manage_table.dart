import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

/// Shared table primitives for the Manage tabs.
///
/// Equipment and Pay Rates draw the same table in the design — a grey header
/// strip over white rows with circular row actions — so the geometry, colors
/// and text styles live here once instead of being re-typed per tab. Text
/// uses the same [ManageCardLabelStyle] / [ManageCardValueStyle] pair as the
/// Qualifications cards, and the action buttons the same recipe as
/// DocumentRowCard's.

/// One column's label and its share of the row width — either a [flex]
/// weight, or a hard [width] via [ManageColumn.fixed].
class ManageColumn {
  final String label;

  /// Share of the leftover width. Null for a fixed-width column.
  final int? flex;

  /// Exact width in logical pixels. Null for a flex column.
  ///
  /// Action columns need this: a flex weight only resolves to the width the
  /// buttons need at one particular panel width, and anywhere else the
  /// button group either overflows its cell or floats away from its header.
  final double? width;

  /// Applies to the header cell and to values built with
  /// [ManageTableRow.text]. Action columns are usually centred.
  final Alignment alignment;

  const ManageColumn(
    this.label,
    this.flex, {
    this.alignment = Alignment.centerLeft,
  }) : width = null;

  const ManageColumn.fixed(
    this.label,
    this.width, {
    this.alignment = Alignment.center,
  }) : flex = null;

  /// Lays [child] out in this column's slot.
  Widget cell(Widget child) => width != null
      ? SizedBox(width: width, child: child)
      : Expanded(flex: flex!, child: child);
}

/// Width a row of [count] action buttons occupies — the exact value to hand
/// [ManageColumn.fixed] for an action column.
double manageActionsWidth(int count) =>
    count * ManageRowActionButton.size +
    (count - 1) * ManageRowActions.gap;

class ManageTable {
  static const double headerHeight = 36;
  static const double rowHeight = 50;

  /// Rows carrying something taller than plain text — an avatar, a status
  /// pill — get a little more room.
  static const double rowHeightTall = 56;
  static const double cellPadding = 16;
  static const double rowGap = 8;
  // The left rail is a fully-rounded pill flush against the row's left edge,
  // inset only vertically so its rounded ends clear the row's corners.
  static const double accentWidth = 5;
  static const double accentInset = 0;
  static const double accentVerticalInset = 6;

  /// How far a rail pushes the row's content in, so an accented header can
  /// match its rows' inset.
  static const double accentGutter = accentInset + accentWidth;
  static const double radius = 8;

  static const Color headerBg = Color(0xFFF0F0F0);
  static const Color rowBorder = Color(0xFFEDEDED);

  /// The left rail on accented rows (Pay Rates, Time Off).
  static const Color accentBlue = Color(0xFF008ABD);
}

/// The grey column-label strip that sits above the rows.
class ManageTableHeader extends StatelessWidget {
  final List<ManageColumn> columns;

  /// Rows that carry a left accent bar are inset by it; the header matches
  /// that inset so labels stay aligned with their values.
  final bool accented;

  const ManageTableHeader({
    super.key,
    required this.columns,
    this.accented = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ManageTable.headerHeight,
      padding: EdgeInsets.only(
        left: ManageTable.cellPadding +
            (accented ? ManageTable.accentGutter : 0),
        right: ManageTable.cellPadding,
      ),
      decoration: BoxDecoration(
        color: ManageTable.headerBg,
        borderRadius: BorderRadius.circular(ManageTable.radius),
      ),
      child: Row(
        children: [
          for (final column in columns)
            column.cell(
              Align(
                alignment: column.alignment,
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ManageCardLabelStyle.customTextStyle(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One white row. [cells] must line up 1:1 with the table's [columns] —
/// build plain values with [ManageTableRow.text] and pass widgets (such as
/// [ManageRowActions]) for anything else.
class ManageTableRow extends StatelessWidget {
  final List<ManageColumn> columns;
  final List<Widget> cells;

  /// Draws a full-height bar down the row's left edge, e.g. the blue rail on
  /// the Pay Rates rows. Omit for an unaccented row.
  final Color? accentColor;

  final double height;

  const ManageTableRow({
    super.key,
    required this.columns,
    required this.cells,
    this.accentColor,
    this.height = ManageTable.rowHeight,
  }) : assert(columns.length == cells.length,
            'Every column needs exactly one cell');

  /// A value cell in the column's own alignment and the shared value style.
  static Widget text(BuildContext context, String value,
      {Alignment alignment = Alignment.centerLeft}) {
    return Align(
      alignment: alignment,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ManageCardValueStyle.customTextStyle(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: ManageTable.rowGap),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ManageTable.rowBorder),
        borderRadius: BorderRadius.circular(ManageTable.radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (accentColor != null)
            Padding(
              padding: const EdgeInsets.only(
                left: ManageTable.accentInset,
                top: ManageTable.accentVerticalInset,
                bottom: ManageTable.accentVerticalInset,
              ),
              child: Container(
                width: ManageTable.accentWidth,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius:
                      BorderRadius.circular(ManageTable.accentWidth / 2),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ManageTable.cellPadding,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < cells.length; i++)
                    columns[i].cell(cells[i]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The circular row actions from the design, flush to the right edge of
/// their cell.
class ManageRowActions extends StatelessWidget {
  final List<Widget> children;
  static const double gap = 10;

  const ManageRowActions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: gap),
          children[i],
        ],
      ],
    );
  }
}

/// One circular action button — 5%-black fill, or 12% red for [danger].
/// Icons come from the shared `images/doc_*.svg` set the Documents rows use,
/// so color and stroke weight match across tabs.
class ManageRowActionButton extends StatelessWidget {
  final String asset;
  final VoidCallback? onPressed;
  final bool danger;

  static const double size = 34;
  static const double iconSize = 14;
  static const Color _red = Color(0xFFE05D5F);

  const ManageRowActionButton({
    super.key,
    required this.asset,
    this.onPressed,
    this.danger = false,
  });

  /// Named shorthands so callers don't repeat asset paths.
  factory ManageRowActionButton.edit({VoidCallback? onPressed}) =>
      ManageRowActionButton(
        asset: 'images/doc_edit_pencil.svg',
        onPressed: onPressed,
      );

  factory ManageRowActionButton.download({VoidCallback? onPressed}) =>
      ManageRowActionButton(
        asset: 'images/doc_download.svg',
        onPressed: onPressed,
      );

  factory ManageRowActionButton.delete({VoidCallback? onPressed}) =>
      ManageRowActionButton(
        asset: 'images/doc_delete.svg',
        onPressed: onPressed,
        danger: true,
      );

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: danger
            ? _red.withValues(alpha: 0.12)
            : const Color(0xFF000000).withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(asset, width: iconSize, height: iconSize),
    );
    if (onPressed == null) return circle;
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: circle,
    );
  }
}

/// A status pill — the Approve / Reject control from the Time Off design.
///
/// Two looks off one recipe: [filled] paints the pill in [color] with white
/// text and a white icon disc, which is how a decided row reads; unfilled
/// gives it a 10%-[color] wash with black text and a [color] icon disc,
/// which is how a row still awaiting a decision reads.
class ManageStatusPill extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Color color;
  final bool filled;
  final VoidCallback? onPressed;

  /// Approve green and Reject red from the design.
  static const Color green = Color(0xFF1AB595);
  static const Color red = Color(0xFFE05D5F);

  static const double height = 26;
  static const double _discSize = 13;
  static const double _iconSize = 7;

  const ManageStatusPill({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.color,
    this.filled = false,
    this.onPressed,
  });

  factory ManageStatusPill.approve({
    bool filled = false,
    VoidCallback? onPressed,
  }) =>
      ManageStatusPill(
        label: 'Approve',
        iconAsset: 'images/timeoff_check.svg',
        color: green,
        filled: filled,
        onPressed: onPressed,
      );

  factory ManageStatusPill.reject({
    bool filled = false,
    VoidCallback? onPressed,
  }) =>
      ManageStatusPill(
        label: 'Reject',
        iconAsset: 'images/timeoff_cross.svg',
        color: red,
        filled: filled,
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) {
    // Filled flips the two surfaces: the pill takes the color and the disc
    // goes white, so the glyph is tinted instead of the disc.
    final Color pillBg = filled ? color : color.withValues(alpha: 0.10);
    final Color discBg = filled ? Colors.white : color;
    final Color glyph = filled ? color : Colors.white;
    final Color labelColor = filled ? Colors.white : Colors.black;

    final pill = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _discSize,
            height: _discSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: discBg, shape: BoxShape.circle),
            child: SvgPicture.asset(
              iconAsset,
              width: _iconSize,
              height: _iconSize,
              colorFilter: ColorFilter.mode(glyph, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 7),
          // Flexible, not bare Text: the pill is given a fixed width by its
          // column, so a label that renders wider than the box has to be
          // allowed to shrink instead of overflowing the Row.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: ManageCardValueStyle.customTextStyle(context)
                  .copyWith(color: labelColor),
            ),
          ),
        ],
      ),
    );

    if (onPressed == null) return pill;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: pill,
    );
  }
}

/// The rounded date field from the Time Off design — white, hairline border,
/// label on the left and a calendar glyph on the right.
class ManageDateField extends StatelessWidget {
  final String placeholder;
  final String value;
  final VoidCallback onPressed;

  static const double width = 180;
  static const double height = 40;

  const ManageDateField({
    super.key,
    required this.placeholder,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFB5B5B5).withValues(alpha: 0.43),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? placeholder : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ManageCardValueStyle.customTextStyle(context)
                    .copyWith(color: const Color(0xFF5F5F5F)),
              ),
            ),
            SvgPicture.asset(
              'images/timeoff_calendar.svg',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
