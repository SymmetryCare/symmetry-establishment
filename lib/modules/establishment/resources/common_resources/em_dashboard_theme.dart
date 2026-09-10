import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

/// Text styles for the Establishment dashboard.
///
/// Reconstructed from the call sites in this module — the original lived in the
/// `prohealth` monolith (`app/resources/common_resources/em_dashboard_theme.dart`)
/// and did not come across with the extracted screens. Every class here is used
/// as `<Name>.customTextStyle(context)`, matching the convention in
/// `app/resources/common_resources/common_theme_const.dart`. Sizes and weights
/// are sensible defaults reflecting each style's role, not the original design
/// tokens — tune them to the spec.

/// Big greeting on the dashboard header ("Hello, <name>").
class EmDashHelloText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s20,
      fontWeight: FontWeight.w700,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// Secondary line under the greeting.
class EmDashHelloSubText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w400,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

/// Default body text inside dashboard cards.
class EmDashText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w400,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// Heading inside a dashboard container / metric tile.
class EmDashContainerHeadTextStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// Column header row of the dashboard list views.
class EmDashListviewHeadText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w700,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// Data rows of the dashboard list views (also used for chart axis labels).
class EmDashListviewDataText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w400,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// The "View More" affordance at the foot of a dashboard card.
class EmDashViewMoreText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w600,
      color: ColorManager.blueprime,
      decoration: TextDecoration.none,
    );
  }
}

/// Staff / headcount captions.
class EmDashstaffText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

/// Label text on the General Settings screen.
class GeneralSettingTextStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w400,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

/// The numeric value beside a General Settings label.
class GeneralSettingNumStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.blueprime,
      decoration: TextDecoration.none,
    );
  }
}
