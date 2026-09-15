import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

import 'package:symmetry_establishment/app/resources/color.dart';

class OnboardFlowContainerHeading {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s13,
      color: ColorManager.blackfaint,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    );
  }
}

class FormHeading{
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      color: ColorManager.blueprime,
      fontSize: FontSize.s18,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.none,
    );
  }

}

///stepper name
class formNameText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ColorManager.grey,
      decoration: TextDecoration.none,
    );
  }
}

///form textfield and blue box
class onlyFormDataStyle {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}



///ip address and
class onlyFormINineDataStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: const Color(0xFF605F5F).withOpacity(0.50),
      decoration: TextDecoration.none,
    );
  }
}


class FileuploadString {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w300,
      color: ColorManager.greylight,
      decoration: TextDecoration.none,
      fontStyle: FontStyle.italic

    );
  }
}


///  Employment #1
class HeadingFormStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s16,
      fontWeight: FontWeight.w700,
      color: ColorManager.black,
      decoration: TextDecoration.none,
    );
  }
}
/// hr dashboard
class TableHeadHRDashboard {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14p,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}
class TableDataHRDashboard {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s15,
      fontWeight: FontWeight.w400,
      color: ColorManager.dashListviewData,
      decoration: TextDecoration.none,
    );
  }
}

///graph heading
class GraphHeadingHRDashboard {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}
