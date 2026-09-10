import 'package:flutter/widgets.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
///all login flow head
class LoginFlowHeading {
  static TextStyle customTextStyle(BuildContext context, {double fontSize = FontSize.s30}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///instructional line shown under the screen title (e.g. "Enter your email to continue")
class LoginFlowSubtitle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}

/// all login flow base text
class LoginFlowBase {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.blueprime,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}

///bottom bar powered by
class LoginFlowBottomBar {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.black,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
  }
}

///login flow textFormField
class LoginFlowTextField {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.blackForLoginTexts,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}

/// all login flow base text
/// offer later screen
class LoginFlowText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.blueprime,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.none,
    );
  }
}

///error msg
class LoginFlowErrorMsg {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.red,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.none,
    );
  }
}

///email theme
class EmailTextStyle {
  static TextStyle enterEmail(BuildContext context) {
    return TextStyle(
      color: const Color(0xff000000).withOpacity(0.3),

      fontWeight: FontWeight.w300,
    );
  }
}
///
class LoginFlowTheme {
  static TextStyle enterEmail(BuildContext context) {
    return TextStyle(
      color: ColorManager.darkgrey,
      fontWeight: FontWeight.w400,
    );
  }
}

/// having letter spacing
class LoginFlowLetterSpacing {
  static TextStyle enterEmail(BuildContext context, {bool applyLetterSpacing = true}) {
    return TextStyle(
      letterSpacing: applyLetterSpacing ? 0.5 : 0.0,
      color: ColorManager.mediumgrey,
      fontSize: FontSize.s10,
      fontWeight: FontWeight.w600,
    );
  }
}


///didnt receive code
class CodeVerficationText {
  static TextStyle VerifyCode(BuildContext context) {
    return TextStyle(
      color: ColorManager.darkgrey,
      fontWeight: FontWeight.w600,
    );
  }
}