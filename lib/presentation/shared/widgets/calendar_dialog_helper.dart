import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class CalendarPickerHelper {
  CalendarPickerHelper._(); // prevent instantiation

  /// Shows a floating calendar popup anchored below [anchorKey].
  ///
  /// Returns the picked [DateTime], or `null` if dismissed.
  ///
  /// Usage:
  /// ```dart
  /// final picked = await CalendarPickerHelper.show(
  ///   context: context,
  ///   anchorKey: _datePillKey,
  ///   selectedDate: _selectedDate,
  ///   horizontalOffset: -100, // shift left/right as needed
  /// );
  /// if (picked != null) setState(() => _selectedDate = picked);
  /// ```
  static Future<DateTime?> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required DateTime selectedDate,
    double horizontalOffset = 0, // ← new parameter
  }) async {
    // ── Guard ──────────────────────────────────────────────────────────────
    if (anchorKey.currentContext == null) return null;

    final renderBox =
    anchorKey.currentContext!.findRenderObject() as RenderBox;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const popupWidth = AppSize.s280;
    const popupHeight = AppSize.s300;

    // ── Clamp left so popup never overflows right edge ─────────────────────
    final left = (renderBox.localToGlobal(Offset.zero).dx + horizontalOffset + popupWidth > screenWidth)
        ? screenWidth - popupWidth - 8
        : renderBox.localToGlobal(Offset.zero).dx + horizontalOffset; // ← offset applied

    // ── Flip above if not enough space below ───────────────────────────────
    final spaceBelow = screenHeight -
        (renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height);
    final top = (spaceBelow < popupHeight + 12)
        ? renderBox.localToGlobal(Offset.zero).dy - popupHeight - 6   // open above
        : renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height + 6; // open below

    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return Stack(
          children: [
            // tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: popupWidth,
                  height: AppSize.s300,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: ColorManager.blueprime,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateChanged: (d) => Navigator.pop(ctx, d),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Formats a [DateTime] as MM/DD/YYYY
  static String fmt(DateTime d) =>
      '${d.year}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.day.toString().padLeft(2, '0')}';
}




class CalendarDialogHelper {
  CalendarDialogHelper._(); // prevent instantiation

  /// Shows a calendar popup centered on the screen.
  ///
  /// Returns the picked [DateTime], or null if dismissed.
  ///
  /// Usage:
  /// ```dart
  /// final picked = await CalendarDialogHelper.show(
  ///   context: context,
  ///   selectedDate: _selectedDate,
  /// );
  /// if (picked != null) setState(() => _selectedDate = picked);
  /// ```
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime selectedDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) {
        return Center(
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: AppSize.s280,
              height: AppSize.s300,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: ColorManager.blueprime,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (d) => Navigator.pop(ctx, d),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Formats a [DateTime] as MM/DD/YYYY
  static String fmt(DateTime d) =>
      '${d.year}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.day.toString().padLeft(2, '0')}';
}






///profile section


/// Same popup as [CalendarDialogHelper], but supports a [firstDate] so
/// past/invalid dates are hidden (disabled) directly in the calendar UI
/// instead of being rejected after the user taps them.
class CalendarDialogHelperFeturedate  {
  CalendarDialogHelperFeturedate._(); // prevent instantiation

  /// Shows a calendar popup centered on the screen.
  ///
  /// [firstDate] hides/disables any date before it in the picker.
  /// Defaults to today if not provided.
  ///
  /// Returns the picked [DateTime], or null if dismissed.
  ///
  /// Usage:
  /// ```dart
  /// final picked = await CalendarDialogHelperV2.show(
  ///   context: context,
  ///   selectedDate: _selectedDate,
  ///   firstDate: DateTime.now(),
  /// );
  /// if (picked != null) setState(() => _selectedDate = picked);
  /// ```
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime selectedDate,
    DateTime? firstDate,
  }) {
    final DateTime now = DateTime.now();
    final DateTime effectiveFirstDate = firstDate ??
        DateTime(now.year, now.month, now.day);

    // ── Clamp the initial selection so it never falls before ──
    // ── firstDate, otherwise CalendarDatePicker will assert. ──
    final DateTime effectiveSelectedDate =
    selectedDate.isBefore(effectiveFirstDate)
        ? effectiveFirstDate
        : selectedDate;

    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) {
        return Center(
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: AppSize.s280,
              height: AppSize.s300,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: ColorManager.blueprime,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: effectiveSelectedDate,
                  firstDate: effectiveFirstDate,
                  lastDate: DateTime(2100),
                  onDateChanged: (d) => Navigator.pop(ctx, d),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Formats a [DateTime] as MM/DD/YYYY
  static String fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
          '${d.day.toString().padLeft(2, '0')}/'
          '${d.year}';
}
