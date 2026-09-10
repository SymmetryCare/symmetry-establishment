import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_licenses_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';

String _extractServerMessage(dynamic data) {
  try {
    if (data == null) return AppString.somethingWentWrong;

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      final details = _extractFieldErrors(data);
      if (details.isEmpty) return AppString.somethingWentWrong;
      return details.map((d) => d.message).join('\n');
    }

    if (rawMessage is String) {
      return rawMessage;
    }

    return AppString.somethingWentWrong;
  } catch (e) {
    print("Error parsing server message: $e");
    return AppString.somethingWentWrong;
  }
}

List<ErrorDetail> _extractFieldErrors(dynamic data) {
  try {
    if (data == null) return [];

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      return rawMessage
          .map((e) => ErrorDetail(
        (e['key'] ?? '').toString(),
        (e['message'] ?? '').toString(),
      ))
          .toList();
    }

    return [];
  } catch (e) {
    print("Error parsing field errors: $e");
    return [];
  }
}

// ---------------------------------------------------------------------------
// Manager function
// ---------------------------------------------------------------------------

Future<ApiDataRegister> postlicensesscreenData(
    BuildContext context,
    String country,
    int employeeId,
    String expDate,
    String issueDate,
    String licenseUrl,
    String licensure,
    String licenseNumber,
    String org,
    String documentType) async {
  try {
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.postlicensesscreen(),
      data: {
        "country": country,
        "employeeId": employeeId,
        "expDate": "${expDate}T00:00:00Z",
        "issueDate": "${issueDate}T00:00:00Z",
        "licenseUrl": licenseUrl,
        "licensure": licensure,
        "licenseNumber": licenseNumber,
        "org": org,
        "documentType": documentType
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("licenses Added");
      var data = response.data;
      var liscenseIdget = data['licenseId'];
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          licenses: liscenseIdget,
          message: response.statusMessage!);
    } else {
      final msg = _extractServerMessage(response.data);
      final fieldErrors = _extractFieldErrors(response.data);
      print("Error 1: $msg");
      return ApiDataRegister(
        statusCode: response.statusCode!,
        success: false,
        message: msg,
        fieldErrors: fieldErrors, // NEW
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}





////get prifill api

Future<List<LicensesDataForm>> getLicensesForm(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

//var itemList ;
  List<LicensesDataForm> itemsData = [];
  try {
    final response = await ApiOffer(context).get(
        path: ProgressBarRepository
            .getLicensesByEmpID(employeeID: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        //String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        String expFormattedDate = convertIsoToDayMonthYear(item['expDate']);
        itemsData.add(LicensesDataForm(
          licenseId: item['licenseId']??0,
          country: item['country']??"--",
          employeeId: item['employeeId']??2,
          expDate: expFormattedDate,
          issueDate: issueFormattedDate,
          licenseUrl: item['licenseUrl']??"--",
          licensure: item['licensure']??"--",
          licenseNumber: item['licenseNumber']??"--",
          org: item['org']??"--",
          documentType: item['documentType']??"--",
          documentName: item['documentName']??"--",

        ));
        // itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));
      }
    } else {
      print("Employee licenses");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
