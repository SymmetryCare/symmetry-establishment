import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
// import 'package:flutter/material.dart';
// import 'package:prohealth/app/resources/color.dart';
// import 'package:prohealth/app/resources/font_manager.dart';
//
// ///Tabbar with Blue BG
// class BlueBgTabbar {
//   static TextStyle customTextStyle(int selectedIndex, int currentIndex) {
//     return TextStyle(
//       fontSize: FontSize.s12,
//       fontWeight: selectedIndex == currentIndex
//           ? FontWeight.w700
//           : FontWeight.w500,
//       color: selectedIndex == currentIndex
//           ? ColorManager.mediumgrey
//           : ColorManager.white,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
// ///Tabbar with transparent BG
// class TransparentBgTabbar {
//   static TextStyle customTextStyle(int selectedIndex, int currentIndex) {
//     return TextStyle(
//       fontSize: FontSize.s12,
//       fontWeight: selectedIndex == currentIndex
//           ? FontWeight.w700
//           : FontWeight.w500,
//       color: selectedIndex == currentIndex
//           ? ColorManager.blueprime
//           : ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
// ///listview table listview heading
// class UserHeading {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s14,
//       fontWeight: FontWeight.w600,
//       color: ColorManager.white,
//       decoration: TextDecoration.none,
//     );
//   }
// }
// ///old
// class AllHRTableHeading {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s12,
//       fontWeight: FontWeight.w600,
//       color: ColorManager.white,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
//
//
//
//
// ///apply most of the places for each listview data
// class DocumentTypeDataStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: FontSize.s10,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
// class UserTableStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: FontSize.s10,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
// class PopupCompStyle{
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s12,
//       fontWeight: FontWeight.w700,
//       color: ColorManager.mediumgrey,
//     );
//   }
// }
// ///details screen office name
// class CompanyIdentityManageHeadings {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s15,
//       color: ColorManager.mediumgrey,
//       fontWeight: FontWeight.w700,
//     );
//   }
// }
//
//
//
// ///listview table data used for HR
// class AllHRTableData {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s10,
//       fontWeight: FontWeight.w500,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
// class ZoneDataStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s10,
//       fontWeight: FontWeight.w500,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
// ///document defination
// class DefineWorkWeekStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s12,
//       fontWeight: FontWeight.w700,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
//
// //hr register screen link
// class RegisterLinkDataStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontWeight: FontWeight.w500,
//       fontSize: FontSize.s11,
//       color: ColorManager.blueprime,
//       decoration: TextDecoration.none,
//     );
//   }
// }
//
//
//
// // class RadioButtonHeadStyle {
// //   static TextStyle customTextStyle(BuildContext context) {
// //     return GoogleFonts.firaSans(
// //       fontSize: FontSize.s12,
// //       fontWeight: FontWeight.w700,
// //       color: ColorManager.mediumgrey,
// //       decoration: TextDecoration.none,
// //     );
// //   }
// // }
//
//
// ///document definition
// // class DocDefineTableData {
// //   static TextStyle customTextStyle(BuildContext context) {
// //     return GoogleFonts.firaSans(
// //       fontWeight: FontWeight.w400,
// //       fontSize: FontSize.s11,
// //       color: ColorManager.mediumgrey,
// //       decoration: TextDecoration.none,
// //     );
// //   }
// // }
//
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

///Tabbar with Blue BG
class BlueBgTabbar {
  static TextStyle customTextStyle(int selectedIndex, int currentIndex) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: selectedIndex == currentIndex
          ? FontWeight.w700
          : FontWeight.w600,
      color: selectedIndex == currentIndex
          ? ColorManager.mediumgrey
          : ColorManager.white,
      letterSpacing: 0.2,
      decoration: TextDecoration.none,
    );
  }
}

///Tabbar with transparent BG
class TransparentBgTabbar {
  static TextStyle customTextStyle(int selectedIndex, int currentIndex) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: selectedIndex == currentIndex
          ? FontWeight.w700
          : FontWeight.w500,
      color: selectedIndex == currentIndex
          ? ColorManager.blueprime
          : ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///listview table listview heading
// class TableHeading {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontSize: FontSize.s14,
//       fontWeight: FontWeight.w600,
//       color: ColorManager.white,
//       decoration: TextDecoration.none,
//     );
//   }
// }
///old
class TableHeading {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,
      color: ColorManager.white,
      decoration: TextDecoration.none,
    );
  }
}
class CIHeading {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,
      color: ColorManager.white,
      decoration: TextDecoration.none,
    );
  }
}





///apply most of the places for each listview data
class
DocumentTypeDataStyle {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s13,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customText12Style(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customLinkTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s14,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}
// class CITableStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: FontSize.s14,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }
class TableSubHeading {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customTextStyleWithColor(BuildContext context,Color color) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle.copyWith(color: color);
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s12,
      color: color,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customTextStyleDate(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: FontSize.s12,
      color: ColorManager.green,
      decoration: TextDecoration.none,
    );
  }
}


class PopupCompStyle{
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
    );
  }
}
///details screen office name
class CompanyIdentityManageHeadings {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s20,
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w700,
    );
  }
}



///listview table data used for HR
class AllHRTableData {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}
class ZoneDataStyle {
  static TextStyle customTextStyle(BuildContext context) {
    if (FormDialogFields.isActive(context)) return FormDialogFields.valueStyle;
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

///document defination
class DefineWorkWeekStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}


class RegisterLinkDataStyle {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: FontSize.s14,
      color: ColorManager.blueprime,
      decoration: TextDecoration.underline,
    );
  }
}

class LegalDocumentPopupMessage{
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
  static TextStyle customOfferTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: FontSize.s13,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}



// class RadioButtonHeadStyle {
//   static TextStyle customTextStyle(BuildContext context) {
//     return GoogleFonts.firaSans(
//       fontSize: FontSize.s12,
//       fontWeight: FontWeight.w700,
//       color: ColorManager.mediumgrey,
//       decoration: TextDecoration.none,
//     );
//   }
// }


///document manage id
class DocDefineTableData {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

class DocDefineTableDataID {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: FontSize.s12,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

class FaintTextColor {
  static TextStyle customTextStyle(BuildContext context){
    return TextStyle(fontWeight: FontWeight.w400,
    fontSize: FontSize.s12,
    color: ColorManager.fmediumgrey,
    fontStyle: FontStyle.italic);
  }
}


///intake
class Filterhead {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s13,
      fontWeight: FontWeight.w600,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}