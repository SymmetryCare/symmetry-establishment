import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onlink_general/onlink_general_data.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/onlinj_general_repo/onlink_general_repo.dart';

Future<OnlinkGeneralData> getGeneralIdPrefill(
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
  var itemsList;
  try {
    final companyId = TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: OnlinkGeneralRepo.getGeneralByIdPrefill(employeeId: employeeId
        ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("onlink general response:::::${itemsList}");
      // String formatedDOBDate = convertIsoToDayMonthYear(response.data['dateOfBirth']);
      itemsList = OnlinkGeneralData(
        employeeId: response.data['employeeId'] ?? 0,
        userId: response.data['userId'] ?? 0,
        code: response.data['code'] ?? '',
        firstName: response.data['firstName'] ?? "",
        lastName: response.data['lastName'] ?? "",
        departmentId: response.data['departmentId'] ?? 0,
        employeeTypeId: response.data['departmentId'] ?? 0,
        expertise: response.data['expertise'] ??"",
        cityId: response.data['cityId'] ?? 0,
        countryId: response.data['countryId'] ?? 0,
        zoneId: response.data['zoneId'] ?? 0,
        SSNNbr: response.data['SSNNbr'] ?? "",
        primaryPhoneNbr: response.data['primaryPhoneNbr'] ?? "",
        secondryPhoneNbr: response.data['secondryPhoneNbr'] ?? "",
        workPhoneNbr: response.data['workPhoneNbr'] ?? "",
        regOfficId: response.data['regOfficId'] ?? "",
        personalEmail: response.data['personalEmail'] ?? '',
        workEmail: response.data['workEmail'] ?? '',
        dateOfBirth: response.data['dateOfBirth'] != null ? convertIsoToDayMonthYear(response.data['dateOfBirth']) : "",
        emergencyContact: response.data['emergencyContact'] ?? "",
        covreage: response.data['covreage'] ?? "",
        employment: response.data['employment'] ?? "",
        gender: response.data['gender'] ?? "",
        status: response.data['status'] ?? "",
        service: response.data['service'] ?? "",
        imgurl: response.data['imgurl'] ?? "",
        resumeurl: response.data['resumeurl'] ?? "",
        onboardingStatus: response.data['onboardingStatus'] ?? "",
        driverLicenceNbr: response.data['driverLicenceNbr'] ?? "",
        dateofTermination: response.data['dateofTermination'] ?? "",
        dateofResignation: response.data['dateofResignation'] ?? "",
        dateofHire: response.data['dateofHire'] ?? "",
        rehirable: response.data['rehirable'] ?? "",
        position: response.data['position'] ?? "",
        finalAddress: response.data['finalAddress'] ?? "",
        address: response.data['address'] ?? "",
        type: response.data['type'] ?? "",
        reason: response.data['reason'] ?? "",
        finalPayCheck: response.data['finalPayCheck'] ?? 0,
        checkDate: response.data['checkDate'] ?? "",
        grossPay: response.data['grossPay'] ?? 0,
        netPay: response.data['netPay'] ?? 0,
        methods: response.data['methods'] ?? "",
        materials: response.data['materials'] ?? "",
        race: response.data['race'] ?? "",
        signatureURL: response.data['signatureURL'] ?? "",
        companyId: response.data['companyId'] ?? 0,
        city: response.data['city'] ?? "--",
        employeeType: response.data['employeeType'] ?? "",
        department: response.data['department'] ?? "",
        country: response.data['country'] ?? "",
        county: response.data['county'] ?? "",
        zone: response.data['zone'] ?? "",
        profileScorePercentage: response.data['profileScorePercentage'] ?? 0.0,
        createdAt: response.data['createdAt'] ?? "",
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

Future<ApiDataRegister> updateOnlinkGeneralPatch(
    BuildContext context,
    int employeeId,
    int userId,
    String firstName,
    String lastName,
    int departmentId,
    String expertise,
    String SSNNbr,
    String primaryPhoneNbr,
    String personalEmail,
    String address,
    String dateOfBirth,
    String gender,
    String imgurl,
    String driverLicenceNbr,
    String dateofTermination,
    String dateofResignation,
    String finalAddress,
    String type,
    String checkDate,
    String race,
    String signatureURL,
    ) async {
  try {
    var response = await ApiOffer(context).patch(
      path: OnlinkGeneralRepo.patchGeneralById(employeeId: employeeId),
      data: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'departmentId': departmentId,
        'expertise': expertise,
        'SSNNbr': SSNNbr,
        'primaryPhoneNbr': primaryPhoneNbr,
        'personalEmail': personalEmail,
        'address': address,
        'dateOfBirth': "${dateOfBirth}T00:00:00Z",
        'gender': gender,
        'imgurl': imgurl,
        'driverLicenceNbr': driverLicenceNbr,
        'dateofTermination': "2024-01-01T00:00:00Z",
        'dateofResignation': "2024-01-01T00:00:00Z",
        'finalAddress': finalAddress,
        'type': type,
        'checkDate': "2024-01-01T00:00:00Z",
        'race': race,
        'signatureURL': signatureURL,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User updated");
      return ApiDataRegister(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      final msg = _extractServerMessage(response.data);
      final fieldErrors = _extractFieldErrors(response.data);
      print("Error: $msg");
      return ApiDataRegister(
        statusCode: response.statusCode!,
        success: false,
        message: msg,
        fieldErrors: fieldErrors,
      );
    }
  } on DioException catch (e) {
    // e.response != null proves the server responded (even on 4xx/5xx) —
    // this is where the real validation message lives
    final msg = _extractServerMessage(e.response?.data);
    final fieldErrors = _extractFieldErrors(e.response?.data);
    print("DioException: ${e.response?.statusCode} -> $msg");
    return ApiDataRegister(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: msg,
      fieldErrors: fieldErrors,
    );
  } catch (e) {
    print("Error: $e");
    return ApiDataRegister(
      statusCode: 404,
      success: false,
      message: "Something went wrong",
    );
  }
}





String _extractServerMessage(dynamic data) {
  try {
    if (data == null) return "Something went wrong";

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      final details = _extractFieldErrors(data);
      if (details.isEmpty) return "Something went wrong";
      return details.map((d) => d.message).join('\n');
    }

    if (rawMessage is String) {
      return rawMessage;
    }

    return "Something went wrong";
  } catch (e) {
    print("Error parsing server message: $e");
    return "Something went wrong";
  }
}

/// Pulls the structured {key, message} list out of the server's error
/// payload so the UI can map each error back to its specific form field.
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