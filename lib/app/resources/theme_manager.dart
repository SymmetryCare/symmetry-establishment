import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:symmetry_establishment/app/resources/color.dart';



///done by saloni and prachi
class ThemeManager {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w400,
    );
  }
}


///prajwal
class ThemeManagerBold {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      //color: Color(0xFF686464),
      color: Colors.black,
      //fontWeight: FontWeight.w400,
      fontWeight: FontWeight.w400,
    );
  }
}



class ThemeManagerDark {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      color: ColorManager.black,
      fontWeight: FontWeight.w600,
    );
  }
}

class ThemeManagerAddressPB {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      height: 1.5,
      fontSize: FontSize.s12,
      color: ColorManager.bluelight,
      fontWeight: FontWeight.w700,
    );
  }
}
class ThemeManagerDarkFont {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(

      fontSize: fontSize,
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w400,
    );
  }
}

class ThemeManagerLightblue {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      color: const Color(0xff2B647F),
      fontWeight: FontWeight.w600,
    );
  }
}

class ThemeManagerWhite {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s10;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
  }
}


class ThemeManagerBlack {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
        // MediaQuery.of(context).size.width / 130;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
  }
  static TextStyle customTerminatedTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    // MediaQuery.of(context).size.width / 130;
    return TextStyle(
      fontSize: fontSize,
      color: ColorManager.redDark,
      fontWeight: FontWeight.w600,
    );
  }
}

class ThemeManagerAccentblue {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s10;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.blueAccent,
      fontWeight: FontWeight.w200,
    );
  }
}

class ThemeManagerblue {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      color: const Color(0xff2B647F),
      fontWeight: FontWeight.w600,
    );
  }
}

class ThemeManageWhitebold {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width / 99;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
  }
}

class RegisterTableHead {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s12;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
  }
}

/// HR Documents style
class AknowledgementStyleConst {
  static TextStyle customTextStyle(BuildContext context) {
    return const TextStyle(
      fontSize: FontSize.s14,
      color: Color(0xFF000000),
      fontWeight: FontWeight.w400,
    );
  }
}
class AknowledgementStyleNormal {
  static TextStyle customTextStyle(BuildContext context) {
    return const TextStyle(
      fontSize: FontSize.s12,
      color: Color(0xFF000000),
      fontWeight: FontWeight.w600,
    );
  }
}

///profile bar
class ProfileBarConst {
  static TextStyle profileTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      color: ColorManager.bluelight,
    fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: ColorManager.blueprime,
    );
  }
}

class ProfileBarConstText {
  static TextStyle profileTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w600,
    );
  }
}

class ProfileBarLastColText {
  static TextStyle profileTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      color: ColorManager.bluelight,
      fontWeight: FontWeight.w700,
    );
  }
}

class ProfileBarClipText {
  static TextStyle profileTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      color: ColorManager.white,
      fontWeight: FontWeight.w600,
    );
  }
}

///common theme
class CustomTextStylesCommon {
  static TextStyle commonStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontSize: fontSize ?? FontSize.s15,
      color: color ?? const Color(0xff4B89BA),
      fontWeight: fontWeight ?? FontWeight.w600,
      decoration: TextDecoration.none,
      fontStyle: fontStyle
    );
  }
}

///menu screen
class MenuScreenHeadStyle {
  static TextStyle menuHead(BuildContext context) {
    return TextStyle(
        color: ColorManager.darkgrey,
        fontSize: FontSize.s14,
        fontWeight: FontWeight.w600);
  }
}



///Human Resource screen textField email only
class MobileMenuText {
  static TextStyle MenuTextConst(BuildContext context) {
    return TextStyle(
      color: ColorManager.mediumgrey,
      fontSize: FontSize.s12,
      fontWeight:FontWeight.w500,
    );
  }
}


class BoxHeadingStyle {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s15;
    // MediaQuery.of(context).size.width / 130;
    return TextStyle(
      fontSize: fontSize,
      color: ColorManager.blackfaint,
      fontWeight: FontWeight.w700,
    );
  }
}

class PopupHeadingStyle {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = FontSize.s16;
    // MediaQuery.of(context).size.width / 130;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w600,
    );
  }
}
///Equipment
class EquipmentStyleHeading{
  static TextStyle customTextStyle(BuildContext context) {
    return  const TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      decoration: TextDecoration.none,
    );
  }
}
class EquipmentStyleRegular{
  static TextStyle customTextStyle(BuildContext context) {
    return  const TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w600,
      color: Color(0xff686464),
      decoration: TextDecoration.none,
    );
  }
}
///
class EquipTableRegStyle {
  static TextStyle  customTextStyle(BuildContext) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w700,
      color:  ColorManager.granitegray,
      decoration: TextDecoration.none,
    );
  }
}
///Time Off
class TimeOffRegular{
  static TextStyle customTextStyle(BuildContext context) {
    return  TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w600,
      color: ColorManager.granitegray,
      decoration:
      TextDecoration.none,
    );
  }
}


/// profile bar in HR
class ProfileBarZoneStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w500,
      color: Color(0xff686464),
      decoration: TextDecoration.none,
    );
  }
}
class ProfileBarNameLicenseStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      decoration: TextDecoration.none,
    );
  }
}
class AboutExpiredLStyle{
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w400,
      color: Color(0xff686464),
      decoration: TextDecoration.none,
    );
  }
}
class ProfileBarTextBoldStyle{
  static TextStyle customEditTextStyle() {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w600,
      color: ColorManager.textPrimaryColor,

      // decoration: TextDecoration.none,
    );
  }
}

/// ── Manage screen — Figma text styles ────────────────────────────────
/// Typography lifted 1:1 from the Figma "01 - Dashboard / Manage" frame.
/// The app-wide font is Fira Sans (see main.dart), so styles that use it
/// only need size / weight / colour. The two exceptions in the design are
/// Plus Jakarta Sans (profile card) and Inter (status chip), which are
/// requested explicitly through google_fonts.

/// Plus Jakarta Sans — used across the left profile card in the design.
TextStyle manageJakarta({
  double fontSize = FontSize.s12,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF64748B),
  double? height,
  TextDecoration? decoration,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );

/// Card title, e.g. "Employment #1" — Fira Sans 700, 18/22, #1A1A1A.
/// w700 rather than the Figma's w500: the title has to read as the heading
/// of its card now that the field labels and values sit at w500. Every
/// Manage card draws from this, so the weight is set here once.
class ManageCardTitleStyle {
  static TextStyle customTextStyle(BuildContext context) => const TextStyle(
        fontSize: FontSize.s18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        height: 22 / 18,
      );
}

/// Card field label, e.g. "Final Position Title" — Fira Sans 500, 14/17.
/// w500 rather than the Figma's w400: at 14px the labels read too light
/// against the card surface, and every Manage card and table draws from
/// this pair, so the weight is set here once.
class ManageCardLabelStyle {
  static TextStyle customTextStyle(BuildContext context) => const TextStyle(
        fontSize: FontSize.s14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111111),
        height: 17 / 14,
      );
}

/// Card field value, e.g. "Hanna Calzoni" — Fira Sans 500, 14/17, #555555.
class ManageCardValueStyle {
  static TextStyle customTextStyle(BuildContext context) => const TextStyle(
        fontSize: FontSize.s14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF555555),
        height: 17 / 14,
      );
}

/// "Not Approved" chip — Inter 500, 12/15, #666666.
class ManageCardChipStyle {
  static TextStyle customTextStyle(BuildContext context) => GoogleFonts.inter(
        fontSize: FontSize.s12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
        height: 15 / 12,
      );
}
