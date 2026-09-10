import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
///saloni

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
class ThemeManagerDarkProfile {
  static TextStyle customTextStyle() {
    double fontSize = 12;
    return TextStyle(
      fontSize: fontSize,
      color: ColorManager.black,
      fontWeight: FontWeight.w600,
    );
  }
}
class MyConstants {
  static List<Widget> personalInfoTexts(BuildContext context) {

   // final textStyle = ThemeManager.customTextStyle(context);
    return [
      Text(
        AppString.age,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
      //SizedBox(height: 1,),
      Text(
        AppString.gender,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
     // SizedBox(height: 1,),
      Text(
        AppString.ssn,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
    //  SizedBox(height: 1,),
      Text(
        AppString.phone,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
    //  SizedBox(height: 1,),
      Text(
        AppString.personalno,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
     // SizedBox(height: 1,),
      Text(
        AppString.workno,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),
    ];
  }
}

class MyConstantsColumn {
  static List<Widget> personalInfoTexts(BuildContext context) {
    // final textStyle = ThemeManager.customTextStyle(context);
    return [

      Text(
          AppString.personalEmail,
      style: ThemeManagerDarkProfile.customTextStyle()
    ),

      Text(
        AppString.workemail,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),

      Text(
        AppString.speciality,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),

      Text(
        AppString.service,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),

      Text(
        AppString.reportingOffice,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),

      Text(
        AppString.summary,
          style: ThemeManagerDarkProfile.customTextStyle()
      ),

      // Text(
      //     '',
      //     style: ProfileBarTextBoldStyle.customEditTextStyle()
      // ),

    ];
  }
}
