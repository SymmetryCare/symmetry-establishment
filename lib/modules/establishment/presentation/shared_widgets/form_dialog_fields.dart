import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Opt-in styling shared by Register and Manage form dialogs.
class FormDialogFields extends InheritedWidget {
  const FormDialogFields({super.key, required super.child});

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormDialogFields>() != null;

  static final TextStyle labelStyle = GoogleFonts.firaSans(
    fontSize: 10,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF505050),
    decoration: TextDecoration.none,
  );
  static final TextStyle sectionTitleStyle = labelStyle.copyWith(
      fontWeight: FontWeight.w600, color: const Color(0xFF333333));
  static final TextStyle valueStyle =
      labelStyle.copyWith(color: const Color(0xFF050505));
  static final TextStyle hintStyle =
      labelStyle.copyWith(color: const Color(0xFF555555));
  static const borderColor = Color(0x1A000000);
  static const radius = 8.0;
  static const contentPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 6);
  static const dropdownPadding = EdgeInsets.symmetric(horizontal: 9);
  static const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    borderSide: BorderSide(color: borderColor),
  );

  /// Keep field behavior, hints, icons and validation while sharing its chrome.
  static InputDecoration decoration(
      BuildContext context, InputDecoration original) {
    if (!isActive(context)) return original;
    final fieldBorder =
        original.border == InputBorder.none ? InputBorder.none : border;
    return original.copyWith(
      isDense: true,
      visualDensity: VisualDensity.standard,
      constraints: const BoxConstraints(minHeight: 28),
      contentPadding: contentPadding,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder,
      disabledBorder: fieldBorder,
      errorBorder:
          border.copyWith(borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder:
          border.copyWith(borderSide: const BorderSide(color: Colors.red)),
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      prefixStyle: valueStyle,
      suffixStyle: valueStyle,
    );
  }

  @override
  bool updateShouldNotify(FormDialogFields oldWidget) => false;
}
