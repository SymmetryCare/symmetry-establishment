import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
///AppBar custom buttons
class AppbarCustomDropdownStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

///AppBar custom buttons
class AppbarCustomDropdownSubItem {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w400,
      color: ColorManager.textPrimaryColor,
      decoration: TextDecoration.none,
    );
  }
}

///common const text form field
class ConstTextFieldStyles {
  static TextStyle customTextStyle({required Color textColor}) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: textColor,
      decoration: TextDecoration.none,
    );
  }
}

class ConstTextFieldRegister {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///all PopupBlue BarText
class PopupBlueBarText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s15,
      fontWeight: FontWeight.w700,
      color: ColorManager.white,
      decoration: TextDecoration.none,
    );
  }
}

///all Popupgray BarText
class DropdownItemStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      color: ColorManager.greylight,
      decoration: TextDecoration.none,
    );
  }
}

///all button Text
class BlueButtonTextConst {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.white,
      decoration: TextDecoration.none,
    );
  }
}

///all transparentButton  and pick location text
class TransparentButtonTextConst {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.blueprime,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customRegisterTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.granitegray,
      decoration: TextDecoration.none,
    );
  }
}


///all popu heading
class AllPopupHeadings {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.labelStyle;
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///sm textfield heading
class SMTextfieldHeadings {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.labelStyle;
    return TextStyle(
      fontSize: FontSize.s13,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}
class SMTextfieldResponsiveHeadings {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s10,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///all menu container heading
class MenuContainerTextStylling {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///all no data msg
class AllNoDataAvailable {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s13,
      fontWeight: FontWeight.w600,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///error msg
class CommonErrorMsg {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.red,
      fontSize: FontSize.s10,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customBackendErrorTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.red,
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}
///popup text const
class PopupTextConst {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.mediumgrey,
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}

class SearchDropdownConst{
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
        color: ColorManager.mediumgrey,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.s12);
  }
}

class NumberTExtFieldLegalDoc {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

class APIErrorTextConst{
  static TextStyle customTextStyle(BuildContext context) {
    return const TextStyle(
      fontSize: FontSize.s16,
      color: Colors.black,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }
}
/// SM Intake Italic text
class SMItalicTextConst{
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color:ColorManager.greylight,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w300,
      fontSize: FontSize.s12,
      decoration: TextDecoration.none,
    );
  }
}