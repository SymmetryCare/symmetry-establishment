import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_legal_doc_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';

Future<ApiDataRegister> addEmployeeI9Form({
  required BuildContext context,
  required int employeeId,
  required String firstName,
  required String middleName,
  required String lastName,
  required String lastNameOther,
  required String phonrNumber,
  required String city,
  required String state,
  required String address,
  required String zipCode,
  required String SSNNbr,
  required String email,
  required String DOB,
  required bool isUSACitizen,
  required bool isNonUSACitizen,
  required bool isLawfullResident,
  required String alienRegNbr,
  required bool isAuthorizedToWork,
  required String unthorizedToWorkDate,
  required String I94AdmissionNbr,
  required String foreignPassportNbr,
  required String countryOfIssue,
  required String officeId,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.addEmployeeI9Form(),
      data: {
        "employeeId": employeeId,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "lastNameOther": lastNameOther,
        "phoneNumber": phonrNumber,
        "city": city,
        "state": state,
        "address": address,
        "zipcode": zipCode,
        "SSNNbr": SSNNbr,
        "email": email,
        "DOB": "${DOB}T00:00:00Z",
        "isUSACitizen": isUSACitizen,
        "isNonUSACitizen": isNonUSACitizen,
        "isLawfullResident": isLawfullResident,
        "alienRegNbr": alienRegNbr,
        "isAuthorizedToWork": isAuthorizedToWork,
        "uthorizedToWorkDate": "${unthorizedToWorkDate}T00:00:00Z",
        "I94AdmissionNbr": I94AdmissionNbr,
        "foreignPassportNbr": foreignPassportNbr,
        "countryOfIssue": countryOfIssue,
        "companyId": companyId,
        "officeId": officeId
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("i9 form completed");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AddSuccessPopup(
            message: 'I9 form saved',
          );
        },
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("I9 form saved"),backgroundColor: Colors.green,),
      // );
      // orgDocumentGet(context);
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


Future<ApiDataRegister> legalDocumentAdd({
  required BuildContext context,
  required int employeeId,
  required String documentName,
  required String docUrl,
  required String officeId
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.addLegalDocumentForm(),
      data: {
      "employeeId": employeeId,
      "docName": documentName,
      "docUrl": docUrl,
      "companyId": companyId,
      "officeId": officeId
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("legal data add");
      var data = response.data;
      var legalDocId = data['EmployeeLegalDocumentId'];
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Legal data saved"),backgroundColor: Colors.green,),
      // );
      // orgDocumentGet(context);
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
      legalDocumentId: legalDocId);
    } else {
      print("Error 1");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

Future<ApiDataRegister> uploadLegalDocumentBase64({
  required BuildContext context,
  required int employeeLegalDocumentId,
  required dynamic documentFile,
}
    ) async {
  try {
    var document = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.uploadLegalDocumentBase64(legalDocumentId: employeeLegalDocumentId),
      data: {
        "base64": document,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Legal Document Uploaded");
      // orgDocumentGet(context);
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong);
  }
}


Future<List<EmployeeLegalDocument>>  legalDocumentPrifill(
    BuildContext context, int employeeId) async {
//var itemList ;
  List<EmployeeLegalDocument> itemsData = [];
  try {
    final response = await ApiOffer(context).get(
        path: ProgressBarRepository.priLegalDocumentForm(employeeID: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {

      for (var item in response.data) {

        itemsData.add(EmployeeLegalDocument(
          EmployeeLegalDocumentId:  item['EmployeeLegalDocumentId'],
          employeeId: item['employeeId'],
          docName: item['docName'],
          docUrl:  item['docUrl'],
          companyId: item['companyId'],
          officeId:  item['officeId'],
          approved: item['approved'],

        ));
        // itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));
      }
    } else {
      print("Employee legal docoment prifill");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
