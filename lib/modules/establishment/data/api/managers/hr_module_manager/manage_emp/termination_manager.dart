import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/termination_data.dart';
//
// Future<List<TerminationData>> getTermination(BuildContext context) async {
//
//   String convertIsoToDayMonthYear(String isoDate) {
//     DateTime dateTime = DateTime.parse(isoDate);
//     DateFormat dateFormat = DateFormat('MM-dd-yyyy');
//     return dateFormat.format(dateTime);
//   }
//
//   // ✅ Safely converts any date field — returns '--' if null or invalid
//   String safeConvert(dynamic value) {
//     if (value == null || value.toString().isEmpty) return '--';
//     try {
//       return convertIsoToDayMonthYear(value.toString());
//     } catch (_) {
//       return '--';
//     }
//   }
//
//   List<TerminationData> itemsData = [];
//   try {
//     final companyId = await TokenManager.getCompanyId();
//     final response = await Api(context).get(
//       path: ManageReposotory.getTermination(companyId: companyId),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       for (var item in response.data) {
//         itemsData.add(
//             TerminationData(
//           employeeId:       item['employeeId'],
//           code:             item['code'],
//           userId:           item['userId'],
//           firstName:        item['firstName']        ?? '--',
//           lastName:         item['lastName']         ?? '--',
//           deptId:           item['departmentId']     ?? 0,
//           employeeTypeId:   item['employeeTypeId']   ?? 0,
//           expertise:        item['expertise']        ?? '--',
//           cityId:           item['cityId']           ?? 0,
//           countyId:         item['countryId']        ?? 0,
//           zoinId:           item['zoneId']           ?? 0,
//           SSNNbr:           item['SSNNbr']           ?? '--',
//           primaryPhoneNo:   item['primaryPhoneNbr']  ?? '--',
//           secoundayPhoneNo: item['secondryPhoneNbr'] ?? '--',
//           workPhoneNo:      item['workPhoneNbr']     ?? '--',
//           regOfficeId:      item['regOfficId']       ?? 0,
//           personalEmail:    item['personalEmail']    ?? '--',
//           workEmail:        item['workEmail']        ?? '--',
//           address:          item['address']          ?? '--',
//           dateOdBirth:      safeConvert(item['dateOfBirth']),       // ✅
//           emergencyContact: item['emergencyContact'] ?? '--',
//           covrage:          item['covreage']         ?? '--',
//           employment:       item['employment']       ?? '--',
//           gender:           item['gender']           ?? '--',
//           status:           item['status']           ?? '--',
//           service:          item['service']          ?? '--',
//           imgUrl:           item['imgurl']           ?? '--',
//           resumeUrl:        item['resumeurl']        ?? '--',
//           onbordinStatus:   item['onboardingStatus'] ?? '--',
//           createdAt:        item['createdAt']        ?? '--',
//           companyId:        item['companyId']        ?? 0,
//           terminationFlag:  item['terminationFlag']  ?? false,
//           approved:         item['approved']         ?? true,
//           dateOfTermination: safeConvert(item['dateofTermination']), // ✅
//           dateOfResignation: safeConvert(item['dateofResignation']), // ✅
//           rehirable:        item['rehirable']        ?? '--',
//           finalAddress:     item['finalAddress']     ?? '--',
//           type:             item['type']             ?? '--',
//           reson:            item['reason']           ?? '--',
//           finalPayCheck:    item['finalPayCheck']    ?? 0,
//           checkDate:        safeConvert(item['checkDate']),          // ✅
//           grossPay:         item['grossPay']         ?? 0,
//           netPay:           item['netPay']           ?? 0,
//           methods:          item['methods']          ?? '--',
//           materials:        item['materials']        ?? '--',
//         ));
//       }
//       itemsData.sort((a, b) => a.userId.compareTo(b.userId));
//     } else {
//       print("Termination error");
//     }
//     return itemsData;
//   } catch (e) {
//     print("error$e");
//     return itemsData;
//   }
// }
/// Get termination data employee Id wise prefill
Future<TerminateEmployeePrefillData> getTerminationEmployeePerfill({
  required BuildContext context,
  required int employeeId
}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);
    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  // ✅ NEW — lastWorkingDay comes back null from API, guard before parsing
  String convertNullableIsoToDayMonthYear(dynamic isoDate) {
    if (isoDate == null || isoDate.toString().isEmpty) return "--";
    try {
      return convertIsoToDayMonthYear(isoDate.toString());
    } catch (_) {
      return "--";
    }
  }

  var itemsData;
  try {
    final response =
    await Api(context).get(path: ManageReposotory.getTerminationPreFillEmp(employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      String dateofTermination =
      convertIsoToDayMonthYear(response.data['dateofTermination'] ?? "0000-00-00");
      String dateofResignation =
      convertIsoToDayMonthYear(response.data['dateofResignation'] ?? "0000-00-00");
      String dateofHire =
      convertIsoToDayMonthYear(response.data['dateofHire'] ?? "0000-00-00");
      String lastWorkingDay =
      convertNullableIsoToDayMonthYear(response.data['lastWorkingDay']); // ✅ NEW
      String checkDate =
      convertIsoToDayMonthYear(response.data['checkDate'] ?? "0000-00-00");
      itemsData = TerminateEmployeePrefillData(
        employeeId: response.data['employeeId'],
        firstName: response.data['firstName']??"",
        lastName: response.data['lastName']??"",
        status: response.data['status'] ?? '',
        rehirable: response.data['rehirable'] ?? "",
        finalAddress: response.data['finalAddress'] ?? "",
        type: response.data['type'] ?? "",
        finalPayCheck: response.data['finalPayCheck'] ?? 0,
        checkDate: checkDate ?? "0000-00-00",
        grossPay: response.data['grossPay'] ?? 0,
        netPay: response.data['netPay'] ?? 0,
        methods: response.data['methods'] ?? "",
        materials: response.data['materials'] ?? "",
        primaryPhoneNbr: response.data['primaryPhoneNbr']??"",
        terminationFlag: response.data['terminationFlag']??false,
        dateofTermination: dateofTermination??"--",
        dateofResignation: dateofResignation??"--",
        dateofHire: dateofHire??"--",
        lastWorkingDay: lastWorkingDay,    // ✅ NEW
        position: response.data['position']??"",
        reason: response.data['reason']??"",
      );
    } else {
      print("Termination Prefill error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


/// Terminate employee Patch
Future<ApiData> patchEmployeeTermination({
  required BuildContext context,
  required int employeeId,
  required String dateofTermination,
  required String dateofResignation,
  required String dateofHire,
  required String lastWorkingDay,
  required String rehirable,
  required String position,
  required String finalAddress,
  required String type,
  required String reason,
  required double finalPayCheck,
  required String checkDate,
  required double grossPay,
  required double netPay,
  required String methods,
  required String materials,
  required String status
}) async {
  try {
    var response = await Api(context).patch(path: ManageReposotory.patchTerminateEmployee(employeeId: employeeId),
      data: {
        "dateofTermination": "${dateofTermination}T00:00:00Z",
        "dateofResignation": "${dateofResignation}T00:00:00Z",
        "dateofHire": "${dateofHire}T00:00:00Z",
        "lastWorkingDay": "${lastWorkingDay}T00:00:00Z",
        "rehirable": rehirable,
        "position": position,
        "finalAddress": finalAddress,
        "type": type,
        "reason": reason,
        "finalPayCheck": finalPayCheck,
        "checkDate": "${checkDate}T00:00:00Z",
        "grossPay": grossPay,
        "netPay": netPay,
        "methods": methods,
        "materials": materials,
        "status": status
      },);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Terminated");
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
  } on DioException catch (e) {
    print("Error ${e.response?.data}");
    // e.response != null proves the server actually responded (4xx/5xx) —
    // surface its real message instead of a generic fallback.
    return ApiData(
        statusCode: e.response?.statusCode ?? 404,
        success: false,
        message: e.response?.data['message']?.toString() ??
            AppString.somethingWentWrong);
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}



Future<ApiData> uploadResignationLetterPost(
    BuildContext context,
    int employeeId,
    String base64,
    String documentName,
    ) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.uploadResignationLetter(employeeId: employeeId),
      data: {
        "base64": base64,
        "documentName": documentName,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Resignation Letter Uploaded");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Resignation letter uploaded successfully",
      );
    } else {
      print("Upload Error");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data?['message'] ?? "Upload failed",
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}





Future<TerminationDetailData> getTerminationDetail({
  required BuildContext context,
  required int employeeId,
}) async {

  // ✅ Safely converts ISO date — returns '--' if null or invalid
  String safeConvert(dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == 'null') return '--';
    try {
      DateTime dateTime = DateTime.parse(value.toString());
      return DateFormat('MM-dd-yyyy').format(dateTime);
    } catch (_) {
      return '--';
    }
  }

  TerminationDetailData? itemData;
  try {
    final response = await Api(context).get(
      path: ManageReposotory.getTerminationPreFillEmp(employeeId: employeeId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      itemData = TerminationDetailData(
        employeeId:        data['employeeId']       ?? 0,
        firstName:         data['firstName']        ?? '--',
        lastName:          data['lastName']         ?? '--',
        roleId:            data['roleId']           ?? 0,
        primaryPhoneNbr:   data['primaryPhoneNbr']  ?? '--',
        terminationFlag:   data['terminationFlag']  ?? false,
        dateofTermination: safeConvert(data['dateofTermination']),
        dateofResignation: safeConvert(data['dateofResignation']),
        dateofHire:        safeConvert(data['dateofHire']),
        lastWorkingDay:    safeConvert(data['lastWorkingDay']),  // ✅ NEW
        rehirable:         data['rehirable']        ?? '--',
        position:          data['position']         ?? '--',
        finalAddress:      data['finalAddress']     ?? '--',
        type:              data['type']             ?? '--',
        reason:            data['reason']           ?? '--',
        finalPayCheck:     (data['finalPayCheck']   ?? 0).toDouble(),
        checkDate:         safeConvert(data['checkDate']),
        grossPay:          (data['grossPay']        ?? 0).toDouble(),
        netPay:            (data['netPay']          ?? 0).toDouble(),
        methods:           data['methods']          ?? '--',
        materials:         data['materials']        ?? '--',
        status:            data['status']           ?? '--',
        active:            data['active']           ?? false,
        registrationDate:            safeConvert(data['registrationDate']),           // ✅ NEW
        offerLetterAcceptanceDate:   safeConvert(data['offerLetterAcceptanceDate']),  // ✅ NEW
      );
    } else {
      print("Termination Detail error");
    }
    return itemData!;
  } catch (e) {
    print("error$e");
    return itemData!;
  }
}