import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/Register/register.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/register_data.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/profile_editor/profile_editor.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/speciality_modeldata.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/profile_repo.dart';

///register enroll get
Future<List<RegisterEnrollData>> RegisterGetData(
  BuildContext context,
) async {
  List<RegisterEnrollData> itemsList = [];
  try {
    final response =
        await Api(context).get(path: AllRegisterRepository.getEmployeeEnroll());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RegisterEnrollData(
          employeeEnrollId: item["employeeEnrollId"] ?? 0,
          companyId: item["companyId"] ?? 0,
          employeeId: item["employeeId"] ?? 0,
          code: item["code"] ?? '--',
          userId: item["userId"] ?? 0,
          firstName: item["firstName"] ?? '--',
          lastName: item["lastName"] ?? '--',
          phoneNbr: item["phoneNbr"] ?? '--',
          email: item["email"] ?? '--',
          link: item["link"] ?? '--',
          status: item["status"] ?? 'Notopen',
          departmentId: item["departmentId"] ?? 0,
          position: item["position"] ?? '--',
          speciality: item["speciality"] ?? '--',
          clinicianTypeId: item["clinicianTypeId"] ?? 0,
          reportingOfficeId: item["reportingOfficeId"] ?? '--',
          cityId: item["cityId"] ?? 0,
          countryId: item["countryId"] ?? 0,
          countyId: item["countyId"] ?? 0,
          zoneId: item["zoneId"] ?? 0,
          employment: item["employment"] ?? '--',
          service: item["service"] ?? '--',
        ));
      }
    } else {
      print('Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
Future<ApiData> addEmpEnroll(
    {required BuildContext context,
      required int employeeId,
      required String code,
      required int userId,
      required String firstName,
      required String lastName,
      required String phoneNbr,
      required String email,
      required String link,
      required String status,
      required int departmentId,
      required String position,
      required int speciality,
      required int clinicianTypeId,
      required String reportingOfficeId,
      required int cityId,
      required int countryId,
      required int countyId,
      required int zoneId,
      required String employment,
      required String service}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrollAdd(),
      data: {
        "companyId": companyId,
        "employeeId": employeeId,
        "code": code,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNbr": phoneNbr,
        "email": email,
        "link": link,
        "status": status,
        "departmentId": departmentId,
        "position": position,
        "speciality": speciality,
        "clinicianTypeId": clinicianTypeId,
        "reportingOfficeId": reportingOfficeId,
        "cityId": cityId,
        "countryId": countryId,
        "countyId": countyId,
        "zoneId": zoneId,
        "employment": employment,
        "service": service
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.data;
      var employeeIdVar = data['employeeId'];
      var employeeEnrollId = data['employeeEnrollId'];

      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          employeeId: employeeIdVar,
          employeeEnrollId: employeeEnrollId);
    } else {
      final data = response.data;
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: _parseErrorMessage(data),
          fieldErrors: _parseFieldErrors(data));
    }
  } on DioException catch (e) {
    print("DioException: ${e.response?.data}");

    final data = e.response?.data;

    return ApiData(
        statusCode: e.response?.statusCode ?? 404,
        success: false,
        message: _parseErrorMessage(data),
        fieldErrors: _parseFieldErrors(data));
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong);
  }
}

/// Parses field-level validation errors from a response like:
/// { "message": [ { "key": "primaryPhoneNbr", "message": "must be unique" } ] }
List<ErrorDetail>? _parseFieldErrors(dynamic data) {
  if (data is Map && data['message'] is List) {
    final List<ErrorDetail> errors = [];
    for (var item in data['message']) {
      if (item is Map) {
        errors.add(
          ErrorDetail(
          item['key'] ?? '', item['message'] ?? '',
          ),
        );
      }
    }
    return errors.isNotEmpty ? errors : null;
  }
  return null;
}

/// Builds a readable message whether `message` is a String or a List of field errors.
String _parseErrorMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    } else if (message is List && message.isNotEmpty) {
      return message
          .whereType<Map>()
          .map((e) => e['message']?.toString() ?? '')
          .where((m) => m.isNotEmpty)
          .join(', ');
    }
  } else if (data is String && data.isNotEmpty) {
    return data;
  }
  return AppString.somethingWentWrong;
}

/// Patch employee enroll
Future<ApiData> patchEmpEnroll(
    {required BuildContext context,
      required int employeeEnrollId,
      required int employeeId,
      required String code,
      required int userId,
      required String firstName,
      required String lastName,
      required String phoneNbr,
      required String email,
      required String link,
      required String status,
      required int departmentId,
      required String position,
      required int speciality,
      required int clinicianTypeId,
      required String reportingOfficeId,
      required int cityId,
      required int countryId,
      required int countyId,
      required int zoneId,
      required String employment,
      required String service}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
      path: AllRegisterRepository.patchEmpEnrollUpdate(empEnrollId: employeeEnrollId),
      data: {
        // "companyId": companyId,
        // "employeeId": employeeId,
        // "code": code,
        // "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNbr": phoneNbr,
        "email": email,
        "link": link,
        "status": status,
        "departmentId": departmentId,
        "position": position,
        "speciality": speciality,
        "clinicianTypeId": clinicianTypeId,
        "reportingOfficeId": reportingOfficeId,
        "cityId": cityId,
        "countryId": countryId,
        "countyId": countyId,
        "zoneId": zoneId,
        "employment": employment,
        "service": service
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Enroll patched");
      // orgDocumentGet(context);
      var data = response.data;
      var employeeIdVar = data['employeeId'];
      var employeeEnrollId = data['employeeEnrollId'];

      print("EmployeeEmrollId ::: ${employeeIdVar}");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          employeeId:employeeIdVar,
          employeeEnrollId:employeeEnrollId);
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

/// Get prefill register enroll ///employee-enroll/{employeeEnrollId}
Future<RegisterDataPrefill> getRegisterEnrollPrefill(
    BuildContext context, int empEnrollId) async {
  var itemsList;
  try {
    final response = await Api(context).get(
        path: AllRegisterRepository.getEmpEnrollByEnrollId(
            empEnrollId: empEnrollId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      itemsList = RegisterDataPrefill(
        empEnrollId: response.data['employeeEnrollId'] ?? 0,
        compId: response.data['companyId'] ?? 5,
        empId: response.data['employeeId'] ?? 2,
        userId: response.data['userId'] ?? 0,
        code: response.data['code'] ?? '--',
        firstName: response.data['firstName'] ?? "--",
        lastName: response.data['lastName'] ?? "--",
        phoneNbr: response.data['phoneNbr'] ?? "--",
        email: response.data['email'] ?? '--',
        link: response.data['link'] ?? "--",
        status: response.data['status'] ?? "--",
        departmentId: response.data['departmentId'] ?? 0,
        position: response.data['position'] ?? "--",
        speciality: response.data['speciality'] ?? "--",
        clinicianTypeId: response.data['clinicianTypeId'] ?? 0,
        reportingOfficeId: response.data['reportingOfficeId'] ?? "--",
        cityId: response.data['cityId'] ?? 0,
        countryId: response.data['countryId'] ?? 0,
        countyId: response.data['countyId'] ?? 0,
        zoneId: response.data['zoneId'] ?? 0,
        employment: response.data['employment'] ?? "--",
        service: response.data['service'] ?? "--",
      );

    } else {
      return itemsList;
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///post /employee-enroll/addOffers
Future<ApiData> addEmpEnrollOffers(
  BuildContext context,
  int employeeEnrollId,
  int employeeId,
  int nbrOfPatient,
  String issueDate,
  String lastDate,
  String startDate,
  String verbalDate,
) async {
  try {
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrollOffers(),
      data: {
        "employeeEnrollId": employeeEnrollId,
        "employeeId": employeeId,
        "nbrOfpatient": nbrOfPatient,
        "issueDate": "${issueDate}T00:00:00Z",  //issueDate,
        "lastDate": "${lastDate}T00:00:00Z",//lastDate,
        "startDate": "${startDate}T00:00:00Z",//startDate,
        "verbalDate": "${verbalDate}T00:00:00Z",//verbalDate,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Offers added");
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

///post /employee-enroll/addZipCodes
Future<ApiData> addEmpEnrollZipCode(
  BuildContext context,
  int employeeEnrollId,
  int employeeEnrollCoverageId,
  int employeeId,
  List<String> zipcodeSetupId,
) async {
  try {
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrollZipCodes(),
      data: {
        "employeeEnrollId": employeeEnrollId,
        "employeeEnrollCoverageId": employeeEnrollCoverageId,
        "employeeId": employeeId,
        "zipcodeSetupId": zipcodeSetupId,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Offers added");
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

///employee-enroll/addCompensations
Future<ApiData> addEmpEnrollAddCompensation(
  BuildContext context,
  int employeeEnrollId,
  int employeeId,
  String payrollType,
  int amount,
) async {
  try {
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrollCompensation(),
      data: {
        "employeeEnrollId": employeeEnrollId,
        "employeeId": employeeId,
        "payrollType": payrollType,
        "amount": amount,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Compensation added");
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

///employee-enroll/addCities
Future<ApiData> addEmpEnrollCities(
  BuildContext context,
  int employeeEnrollId,
  int employeeEnrollCoverageId,
  int employeeId,
  List<String> Cities,
) async {
  try {
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrollCities(),
      data: {
        "employeeEnrollId": employeeEnrollId,
        "employeeEnrollCoverageId": employeeEnrollCoverageId,
        "employeeId": employeeId,
        "Cities": Cities,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Offers added");
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

///employee-enroll/addCoverage
Future<ApiData> addEmpEnrollAddCoverage(
  BuildContext context,
  int employeeEnrollId,
  int employeeId,
  List<ApiAddCovrageData> addCovrage,
  // String city,
  // int countyId,
  // int zoneId,
) async {
  try {
    var data = {
      "employeeEnrollId": employeeEnrollId,
      "employeeId": employeeId,
      "coverageDetails": addCovrage.map((item) => item.toJson()).toList()
      // "city": city,
      // "countyId": countyId,
      // "zoneId": zoneId,
    };
    print("Covrage Data ${data}");
    var response = await Api(context).post(
      path: AllRegisterRepository.addEmpEnrolladdCoverage(),
      data: {
        "employeeEnrollId": employeeEnrollId,
        "employeeId": employeeId,
        "coverageDetails": addCovrage.map((item) => item.toJson()).toList()
        // "city": city,
        // "countyId": countyId,
        // "zoneId": zoneId,
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Coverage added");
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

/// Patch employee-enroll
///employee-enroll/addCoverage
///
///
///
Future<ApiData> patchEmpEnrollAddCoverage(BuildContext context,
    int employeeEnrollId,
    int employeeId,
    List<ApiPatchCovrageData> coverageDetails,) async {

  try {
    var data = {
      "employeeEnrollId": employeeEnrollId,
      "employeeId": employeeId,
      "coverageDetails": coverageDetails.map((item) => item.toJson()).toList(),
    };

    print(">>>>Coverage Data: $data");

    var response = await Api(context).patch(
      path: AllRegisterRepository.PatchEmpEnrolladdCoverage(empEnrollId: employeeEnrollId),
      data: data,
    );

    print(response);
    print(">>>>>>>>Full Response: ${response.data}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Coverage updated successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print(">>>>>>>Error: Coverage update failed<<<<<<");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    print("Error: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}


///delete
Future<ApiData> deleteCoverageEditor(
    BuildContext context, int employeeEnrollCoverageId) async {
  try {
    var response = await Api(context).delete(
        path: ProfileRepository.deleteCoverage(employeeEnrollCoverageId: employeeEnrollCoverageId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Deleted coverage :::${employeeEnrollCoverageId}");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


/// Onboard User Patch...
Future<ApiData> onboardingUserPatch(BuildContext context, int employeeId) async {
  try {
    var response = await Api(context).patch(
      path: AllRegisterRepository.patchOnboardingEmployee(employeeId: employeeId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee Onboarded");
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

/// Change status to complete  User Patch
Future<ApiData> changeStatusUserPatch(BuildContext context, int employeeId) async {
  try {
    var response = await Api(context).patch(
      path: AllRegisterRepository.patchChangeStatusEmployee(employeeId: employeeId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee status changed");
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


/////////////////////////


Future<EmployeeModel> getCoverageList({required BuildContext context,
  required int employeeId ,required int employeeEnrollId }) async {
  // Initialize EmployeeModel with default values
  EmployeeModel employeeModel = EmployeeModel(
    employeeEnrollId: employeeEnrollId, // Default value; can be modified as needed
    employeeId: employeeId,
    coverageDetails: [],
  );

  try {
    final response = await Api(context).get(path: ProfileRepository.getlistcoverage(employeeId: employeeId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Process coverage details from the response
      for (var item in response.data['coverageDetails']) {
        employeeModel.coverageDetails.add(CoverageDetail(
          employeeEnrollCoverageId: item['employeeEnrollCoverageId'],
          city: item['city'] ?? '',
          countyId: item['countyId'],
          countyName: item['countyName'],
          zoneId: item['zoneId'],
          zoneName: item['zoneName'],
          zipCodes: List<int>.from(item['zipCodes']),
        ));
      }
      print("Coverage details fetched successfully.");
    } else {
      print('MAnage profile Error: ${response.statusMessage}');
    }

  } catch (e) {
    print("Error: $e");
  }

  return employeeModel;
}

/// coverage prefill
Future<CoveragePrefillData?> getCoveragePreFill({required BuildContext context,
  required int employeeId ,required int employeeEnrollCoverageId }) async {
  // Initialize EmployeeModel with default values
  try {
    final response = await Api(context).get(path: ProfileRepository.getPreFillcoverage(employeeCoverageId: employeeEnrollCoverageId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Process coverage details from the response
      print("Coverage prefill details fetched successfully.");
      //final data = json.decode(response.body);
      return CoveragePrefillData.fromJson(response.data);

    } else {
      print('Manage coverage prefill error: ${response.statusMessage}');
    }

  } catch (e) {
    print("Error: $e");
    return null;
  }


}




////
/// Update User Status Patch...
Future<ApiData> updateUserActivePatch(
    BuildContext context,
    int userId,
    bool isActive,
    ) async {
  try {

    final String statusValue = isActive ? "Active" : "Inactive";

    var response = await Api(context).patch(
      path: AllRegisterRepository.patchUserStatus(userId: userId),
      data: {
        "status": statusValue,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User status updated successfully → $statusValue");

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
      );
    } else {
      print("Error updating user status");

      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Failed to update status",
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







/// Delete User...
Future<ApiData> deleteUserApi(
    BuildContext context,
    int userId,
    ) async {
  try {
    final response = await Api(context).delete(
      path: AllRegisterRepository.deleteUser(userId: userId),
    );

    final code = response.statusCode ?? 0;

    if (code == 200 || code == 201 || code == 204) {
      print("✅ User deleted successfully: userId=$userId");
      return ApiData(
        statusCode: code,
        success: true,
        message: response.statusMessage ?? "User deleted",
      );
    }

    // ❌ simple fallback message
    return ApiData(
      statusCode: code,
      success: false,
      message: "Failed to delete user",
    );
  } on DioException catch (e) {
    final code = e.response?.statusCode ?? 0;

    print("❌ Delete DioException: code=$code error=${e.error}");

    return ApiData(
      statusCode: code,
      success: false,
      message: "Delete request failed",
    );
  } catch (e) {
    print("❌ Error $e");
    return ApiData(
      statusCode: 500,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

/// Speciality get by department
Future<List<SpecialityModeldata>> getSpecialityListByDeptId({
  required BuildContext context,
  }) async {
  // Initialize EmployeeModel with default values
  List<SpecialityModeldata> itemData = [];

  try {
    final response = await Api(context).get(
        path: ProfileRepository.employeeSpeciality,
    // queryParameters: {
    //       "departmentId":departmentId
    // }
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemData.add(SpecialityModeldata(
            specialityId: item['specialityId'] ?? 0,
            speciality: item['speciality'] ?? '',
            description: item['description'] ?? '',
            // departmentId: item['departmentId'] ?? 0,
            // employeeTypeId: item['employeeTypeId'] ?? 0,
            // department: item['department'] ?? '',
            // employeeType: item['employeeType'] ?? ''
        ),
        );
      }
    } else {
      print('Speciality Error: ${response.statusMessage}');
    }
    return itemData;

  } catch (e) {
    print("Error: $e");
    return itemData;
  }
}

Future<CheckOfferLatterData> getEmployeeOfferLatterCheck({
  required BuildContext context,
  required int employeeTypeId,
  required int deptId,
  required String employeeStatus,
}) async {
  var itemsList;
  try {
    final response = await Api(context).getWithQueryParam(
        path: AllRegisterRepository.getOfferLetterCheck(),
        queryParameters: {
          'employeeTypeId': employeeTypeId,
          'departmentId': deptId,
          'employment': employeeStatus
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      itemsList = CheckOfferLatterData(
        available: response.data['available'] ?? false,
      );
    } else {
      itemsList = CheckOfferLatterData(
        available: false,
        message: response.data['message'] ??
            response.data['msg'] ??
            'Something went wrong',
      );
      return itemsList;
    }
    return itemsList;
  } on DioException catch (e) {
    // Covers 400/401/403/404/500 etc. — Dio throws instead of returning
    // a response for non-2xx status codes, so the real backend message
    // lives in e.response?.data here, not in a normal `response`.
    print("Error ${e.response?.statusCode}: ${e.response?.data}");
    final data = e.response?.data;
    String? backendMessage;
    if (data is Map) {
      backendMessage = data['message'] ?? data['msg'] ?? data['error'];
    }
    itemsList = CheckOfferLatterData(
      available: false,
      message: backendMessage ?? e.message ?? 'Something went wrong. Please try again.',
    );
    return itemsList;
  } catch (e) {
    print("Error $e");
    itemsList = CheckOfferLatterData(
      available: false,
      message: 'Something went wrong. Please try again.',
    );
    return itemsList;
  }
}