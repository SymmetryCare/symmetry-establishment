import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared chrome for every form dialog, lifted from the Register screen's
/// Enroll / Offer Letter dialogs so the Manage screen's popups read as the
/// same product.
///
/// Use them as a pair:
///
/// ```dart
/// Dialog(
///   backgroundColor: Colors.transparent,
///   child: FormDialogSurface(
///     width: 860,
///     child: Column(children: [
///       FormDialogHeader(title: 'Add Employment', onClose: ...),
///       ...
///     ]),
///   ),
/// )
/// ```

/// The Enroll dialog's blue header bar.
const Color kFormDialogHeaderBlue = Color(0xFF0B8CBF);

/// Corner radius of the dialog surface and its header.
const double kFormDialogRadius = 18;

/// Every piece of text inside a dialog renders in Fira Sans, matching the app
/// theme. Applying it once at the dialog root means descendants that don't
/// name a family — including the shared `*Style.customTextStyle()` helpers —
/// inherit it instead of falling back to the platform font.
final String? kFormDialogFontFamily = GoogleFonts.firaSans().fontFamily;

/// 14 / 700 — the dialog heading in the blue bar.
final TextStyle kFormDialogTitleStyle = TextStyle(
  fontFamily: kFormDialogFontFamily,
  fontSize: 14,
  height: 18 / 14,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  decoration: TextDecoration.none,
);

/// 9 / 400 — "Kindly fill these following fields."
final TextStyle kFormDialogSubtitleStyle = TextStyle(
  fontFamily: kFormDialogFontFamily,
  fontSize: 9,
  height: 12 / 9,
  fontWeight: FontWeight.w400,
  color: Colors.white.withValues(alpha: 0.59),
  decoration: TextDecoration.none,
);

/// White rounded dialog body. Drop-in replacement for the hand-rolled
/// `Container(decoration: BoxDecoration(color: white, borderRadius: 8))` each
/// popup used to declare.
class FormDialogSurface extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;

  const FormDialogSurface({
    super.key,
    this.width,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(fontFamily: kFormDialogFontFamily),
      child: Container(
        width: width,
        height: height,
        // Never taller than the viewport, however tall the caller asked for.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kFormDialogRadius),
        ),
        child: FormDialogFields(
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: FormDialogFields.valueStyle,
                    bodyMedium: FormDialogFields.valueStyle,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The blue title bar: heading, optional one-line subtitle, and a circular
/// close button tinted out of the header colour.
class FormDialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  /// Overrides the bar colour for dialogs that signal something other than a
  /// routine form (e.g. a destructive action).
  final Color? backgroundColor;

  const FormDialogHeader({
    super.key,
    required this.title,
    this.subtitle = 'Kindly fill these following fields.',
    required this.onClose,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? kFormDialogHeaderBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kFormDialogRadius),
          topRight: Radius.circular(kFormDialogRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: kFormDialogTitleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: kFormDialogSubtitleStyle),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // Translucent white so the circle reads as a lighter tint of
                // the blue header behind it.
                color: Color(0x14FFFFFF),
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
