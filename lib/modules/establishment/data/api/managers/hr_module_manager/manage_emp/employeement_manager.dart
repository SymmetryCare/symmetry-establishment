import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employeement_data.dart';

import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';

Future<List<EmployeementData>> getEmployeement(
    BuildContext context, int employeeId) async {
  String safeText(dynamic value, {String fallback = '--'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String convertIsoToDayMonthYear(dynamic isoDate) {
    final rawDate = safeText(isoDate);
    if (rawDate == '--') return rawDate;
    // Parse ISO date string to DateTime object
    final dateTime = DateTime.tryParse(rawDate);
    if (dateTime == null) return rawDate;

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<EmployeementData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: ManageReposotory.getEmployeement(
            employeeId: employeeId, approveOnly: 'no'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String joiningFormattedDate =
            convertIsoToDayMonthYear(item['dateOfJoining']);
        // String endFormattedDate = convertIsoToDayMonthYear(item['endDate']);
        itemsData.add(EmployeementData(
            employmentId: item['employmentId'] ?? 0,
            employeeId: item['employeeId'] ?? employeeId,
            employer: safeText(item['employer']),
            city: safeText(item['city']),
            reason: safeText(item['reason']),
            supervisor: safeText(item['supervisor']),
            supMobile: safeText(item['supMobile']),
            title: safeText(item['title']),
            dateOfJoining: joiningFormattedDate,
            endDate: safeText(item['endDate']), //endFormattedDate,
            approved: item['approved'],
            emgMobile: safeText(item['emgMobile']),
            country: safeText(item['country']),
            documentUrl: item['documentUrl'] ?? "--",
            sucess: true,
            message: response.statusMessage!));
        itemsData.sort((a, b) => a.employmentId.compareTo(b.employmentId));
      }
    } else {
      print("Employee Employeement");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Add employeement
Future<ApiData> addEmployeement(
    BuildContext context,
    int employeeId,
    String employer,
    String city,
    String reason,
    String supervisor,
    String supMobile,
    String title,
    String dateOfJoining,
    String? endDate,
    String emgMobile,
    String country) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.addEmployeement(),
      data: {
        "employeeId": employeeId,
        "employer": employer,
        "city": city,
        "reason": reason,
        "supervisor": supervisor,
        "supMobile": supMobile,
        "title": title,
        "dateOfJoining": "${dateOfJoining}T00:00:00Z",
        "endDate": endDate,
        "emgMobile": emgMobile,
        "country": country
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employeement Added");
      // orgDocumentGet(context);
      var employeeResponse = response.data['employmentId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          employeementId: employeeResponse!);
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

/// Patch employeement
Future<ApiData> updateEmployeementPatch(
    BuildContext context,
    int employeeIdupdate,
    int employeeId,
    String employer,
    String city,
    String reason,
    String supervisor,
    String supMobile,
    String title,
    String dateOfJoining,
    String endDate,
    String emgMobile,
    String country) async {
  try {
    var response = await Api(context).patch(
      path:
          ManageReposotory.updateEmployeement(employeementId: employeeIdupdate),
      data: {
        "employeeId": employeeId,
        "employer": employer,
        "city": city,
        "reason": reason,
        "supervisor": supervisor,
        "supMobile": supMobile,
        "title": title,
        "dateOfJoining": "${dateOfJoining}T00:00:00Z",
        // "endDate": endDate == "Currently Working"? endDate :"${endDate}T00:00:00Z",
        "endDate": endDate,
        "emgMobile": emgMobile,
        "country": country
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employeement Added");
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

/// Prefill get employeement
Future<EmployeementPrefillData> getPrefillEmployeement(
    BuildContext context, int employeementId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  var itemsData;
  try {
    final response = await Api(context).get(
        path: ManageReposotory.updateEmployeement(
            employeementId: employeementId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      String joiningFormattedDate =
          convertIsoToDayMonthYear(response.data['dateOfJoining']);
      // String endFormattedDate = convertIsoToDayMonthYear(response.data['endDate']);
      itemsData = EmployeementPrefillData(
          employmentId: response.data['employmentId'],
          employeeId: response.data['employeeId'],
          employer: response.data['employer'],
          city: response.data['city'],
          reason: response.data['reason'],
          supervisor: response.data['supervisor'],
          supMobile: response.data['supMobile'],
          title: response.data['title'],
          dateOfJoining: joiningFormattedDate,
          endDate: response.data['endDate'] ?? '__',
          // endDate: response.data['endDate'] == "Currently Working" ? response.data['endDate']:convertIsoToDayMonthYear(response.data['endDate']),
          approved: response.data['approved'],
          sucess: true,
          message: response.statusMessage!,
          emgMobile: response.data['emgMobile'],
          country: response.data['country']);
    } else {
      print("Employee Employeement");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

///upload resume

Future<ApiData> uploadEmployeeResume(
    {required BuildContext context,
    required int employeementId,
    required dynamic documentFile,
    required String documentName}) async {
  try {
    String documents =
        await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}");
    var response = await Api(context).post(
      path: ManageReposotory.updateEmployeementresume(
          employeementId: employeementId, documentName: documentName),
      data: {'base64': documents},
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Employee Resume Uploaded");
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

///upload photo general form screen
///
Future<ApiData> uploadphoto(
    {required BuildContext context,
    required int employeeid,
    required dynamic documentFile,
    required String documentName}) async {
  try {
    String documents =
        await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}");
    var response = await Api(context).post(
      path: ManageReposotory.uploadphoto(employeeid: employeeid),
      data: {'base64': documents},
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Employee Resume uploded");
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

/// linceses uploaded
///

Future<ApiData> uploadlinceses(
    {required BuildContext context,
    required int employeeid,
    required int licensedId,
    required dynamic documentFile,
    required String documentName}) async {
  try {
    String documents =
        await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}");
    var response = await Api(context).post(
      path: ManageReposotory.uploadlinceses(licensedId: licensedId),
      data: {'base64': documents, 'documentName': documentName},
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("license uploded");
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

///////
////////
//////
///upload check
