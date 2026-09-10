import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/onboarding/onboarding_qualification.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/form_status_data.dart';

import 'package:symmetry_establishment/app/services/token/token_manager.dart';

// Future<FormModel?> getFormStatus({
//   required BuildContext context,
//   required int employeeId,
// }) async {
//   List<SignedForm> signedForms = [];
//   List<UnsignedForm> unsignedForms = [];
//   var listData =[];
//   try {
//     final response = await Api(context).get(
//       path: OnboardingQualificationRepo.employeeFormStatusGet(employeeId: employeeId),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("API Response received");
//
//       // Mapping the signed forms
//       if (response.data['signedForms'] != null) {
//         for (var signedForm in response.data['signedForms']) {
//           signedForms.add(SignedForm(
//             formHtmlTemplatesId: signedForm['formHtmlTemplatesId'] ?? 0,
//             htmlname: signedForm['htmlname'] ?? '--',
//             companyId: signedForm['company_Id'] ?? 0,
//             signed: signedForm['signed'] ?? false,
//           ));
//         }
//       }
//
//       // Mapping the unsigned forms
//       if (response.data['unsignedForms'] != null) {
//         for (var unsignedForm in response.data['unsignedForms']) {
//           unsignedForms.add(UnsignedForm(
//             formHtmlTemplatesId: unsignedForm['formHtmlTemplatesId'] ?? 0,
//             htmlname: unsignedForm['htmlname'] ?? '--',
//             companyId: unsignedForm['company_Id'] ?? 0,
//             signed: unsignedForm['signed'] ?? false,
//           ));
//         }
//       }
//
//       // Creating the FormsData object with the populated lists
//       FormModel formModel = FormModel(
//         signedForms: signedForms,
//         unsignedForms: unsignedForms,
//       );
//
//       print("Signed Forms: $signedForms, Unsigned Forms: $unsignedForms");
//       return formModel;
//     } else {
//       print("Error: Failed to fetch data");
//       return null;
//     }
//   } catch (e) {
//     print("Error occurred: $e");
//     return null;
//   }
// }

Future<List<FormModel>> getFormStatus(
 BuildContext context,
 int employeeId,) async {
  List<FormModel> itemsData = [];
  // String convertIsoToDayMonthYear(String isoDate) {
  //   DateTime dateTime = DateTime.parse(isoDate);
  //   DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  //   String formattedDate = dateFormat.format(dateTime);
  //   return formattedDate;
  // }

  try{
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(path: OnboardingQualificationRepo.employeeFormStatusGet(employeeId: employeeId),);
    if(response.statusCode == 200 || response.statusCode == 201){
      for(var item in response.data){
       // String DOB = convertIsoToDayMonthYear(item['dateOfBirth']);
        itemsData.add(
            FormModel(
            formHtmlTemplatesId: item['formHtmlTemplatesId'] ?? 0,
                htmlname: item['htmlname'] ?? "",
                companyId: companyId,
                signed: item['signed'] ?? false,
                url: item['url'] ?? ""));
      }
    }else {
      print("Employment List");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
