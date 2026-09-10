

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/offer_letter_description_screen.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/offer_letter_html_data/offer_letter_html.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/offer_leter_repo.dart';

///GET:-template---GET/employee-offers/GetEmployeeOffer/{EmployeeId}/{templateId

Future<OfferLetterData> GetOfferLetter(BuildContext context,
    int employeeId,
    int templateId
    ) async {
  // List<OfferLetterData> itemsList = [];
  var itemsList;
  try {
    final response = await ApiOffer(context)
        .get(path: OfferLetterHtmlRepo.getOfferLetterHtml(
        employeeId: employeeId, templateId: templateId));
    print('Response:::::${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Template data ${response.data['template']}');
        itemsList =
            OfferLetterData(
              offerId: response.data['offerId'],
                docUploadStatus: response.data['DocumentUploadStatus'],
                templateName: response.data['templateName'],
                template: response.data['template'],
                statusCode: response.statusCode, message: response.statusMessage!,
            );
    }else if(response.statusCode == 409){
      itemsList = OfferLetterData(
          docUploadStatus: "",
          templateName: "",
          template: "",
          statusCode: response.statusCode, offerId: 0,
          message: response.statusMessage!
      );
    }
    else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


/// Get employeeId
Future<EmployeeIdByEmail> GetEmployeeIdByEmail(BuildContext context,
    int companyId,
    String emailId
    ) async {
  // List<OfferLetterData> itemsList = [];
  var itemsList;
  try {
    final response = await Api(context)
        .get(path: OfferLetterHtmlRepo.getOfferEmployeeIdbyEmail(companyId: companyId, email: emailId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      itemsList = EmployeeIdByEmail(employeeID: int.parse(response.data));
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///accept offer accept offer----PATCH/employee-offers/acceptOffer/{offerId}
Future<ApiData> updateOfferLetter(
     BuildContext context,
    int offerId,
    int employeeEnrollId,
    int employeeId,
    // String issueDate,
    // String lastDate,
    // String startDate,
    // String verbalDate,
    bool offerAccepted,
   String acceptedDate
    ) async {
  try {
    var response = await Api(context).patch(
      path: OfferLetterHtmlRepo.patchAcceptOffer(offerId: offerId),
      data: {
        "offerId": offerId,
        "employeeEnrollId": employeeEnrollId,
        "employeeId": employeeId,
        // "issueDate": issueDate,
        // "lastDate": lastDate,
        // "startDate": startDate,
        // "verbalDate": verbalDate,
        "offerAccepted": offerAccepted,
        "acceptedDate": acceptedDate,
        // "employeeId": employeeId,
        // "graduate": graduate,
        // "degree": degree,
        // "major": major,
        // "city": city,
        // "college": college,
        // "phone": phone,
        // "state": state
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Accept Offer Letter");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


/// Upload signiture
Future<ApiDataRegister> uploadSignature(
    BuildContext context,
    int employeeId,
    dynamic documentFile
    ) async {
  try {
    String document = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await ApiOffer(context).post(
      path: OfferLetterHtmlRepo.uploadSignatureDocument(employeeId: employeeId),
      data: {
        "base64":document
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Signature uploaded");
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