import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';

class CardDetails extends StatefulWidget {
  final Widget childWidget;
  const CardDetails({super.key, required this.childWidget});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  @override
  Widget build(BuildContext context) {
    // Inside a ManageCardGrid the column width wins, so the card fills its
    // grid cell; outside one (the onboarding screens) it keeps the 700px
    // surface it was designed at.
    final double width = ManageCardWidth.maybeOf(context) ?? 700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: width,
        // No minimum height: the card hugs its content so nothing is left
        // over as an empty band under the field columns. (Cards sitting
        // side by side still line up, because each tab pins its field rows
        // and its trailing button row to fixed heights.)
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.13)),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: widget.childWidget,
      ),
    );
  }
}

class DetailsFormate extends StatefulWidget {
  final List<Widget> row1Child1;
  final List<Widget> row1Child2;
  final List<Widget> row2Child1;
  final List<Widget> row2Child2;
  final String? title;
  final Widget button;
  final Widget? titleRow;
  // Optional widget shown on the right side of the title row (e.g. a View
  // button), while the title text stays on the left. Ignored if titleRow is
  // supplied, since titleRow fully overrides the default title layout.
  final Widget? titleTrailing;
  DetailsFormate(
      {super.key,
      this.titleRow,
      this.title,
      this.titleTrailing,
      required this.row1Child1,
      required this.row1Child2,
      required this.row2Child1,
      required this.row2Child2,
      required this.button});

  @override
  State<DetailsFormate> createState() => _DetailsFormateState();
}

class _DetailsFormateState extends State<DetailsFormate> {
  /// Horizontal gap between a label column and its value column.
  static const double _labelValueGap = 24;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Was spaceBetween, which silently re-inflated every gap whenever the
      // content came in shorter than CardDetails' 303px minimum height — so
      // tightening the title gap below had no visible effect. Packing from
      // the top keeps the spacing exactly as specified and lets any slack
      // fall at the bottom of the card instead.
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Everything that used to sit under the field columns — the Edit
        // buttons and the approval pill — rides in the title row now, in the
        // free space to the right of the title. With nothing below the last
        // field row, every card in a section comes out the same height.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: widget.titleRow ??
                  Text(widget.title!,
                      style: ManageCardTitleStyle.customTextStyle(context)),
            ),
            if (widget.titleTrailing != null) ...[
              widget.titleTrailing!,
              const SizedBox(width: 10),
            ],
            // The tabs hand their action row in as a full-width Row(end),
            // which cannot sit directly inside another Row; an intrinsic
            // width bounds it without pinning a size here.
            IntrinsicWidth(child: widget.button),
          ],
        ),
        // Gap between the title / status row and the two field columns.
        const SizedBox(
          height: 34,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // start, not spaceBetween: spaceBetween shoved the value
              // column against the far edge of its half, opening a gap far
              // wider than the design's between a label and its value.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.row1Child1),
                  const SizedBox(
                    width: _labelValueGap,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.row1Child2),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: widget.row2Child1),
                  const SizedBox(
                    width: _labelValueGap,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.row2Child2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Status pill shown at the right of a card's title row.
///
/// The default is the grey "Not Approved" / "Rejected" chip — Figma: 111x35,
/// #D9D9D9 at 65%, 6px radius. [CardStatusChip.approved] is the green
/// variant from the Banking design: a #1AB595 wash with a white-ticked green
/// disc and green label, sized to sit level with the buttons beside it.
/// Shared so every tab renders these identically.
class CardStatusChip extends StatelessWidget {
  final String label;

  /// Renders the green approved treatment instead of the grey chip.
  final bool approved;

  static const Color green = Color(0xFF1AB595);

  const CardStatusChip({super.key, required this.label})
      : approved = false;

  const CardStatusChip.approved({super.key, this.label = 'Approved'})
      : approved = true;

  @override
  Widget build(BuildContext context) {
    if (!approved) {
      return Container(
        width: 111,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: ManageCardChipStyle.customTextStyle(context),
        ),
      );
    }

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 17,
            height: 17,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: green,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'images/timeoff_check.svg',
              width: 9,
              height: 9,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: ManageCardChipStyle.customTextStyle(context)
                .copyWith(color: green, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
