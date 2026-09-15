import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_general_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/profile_repo.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/employee_profile/search_profile_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/profile_editor/profile_editor.dart';

import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/all_from_hr_repository.dart';

/// Search by Text
/// get api
Future<List<SearchEmployeeProfileData>> getSearchProfileByText(
    BuildContext context, String searchText) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM-dd-yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<SearchEmployeeProfileData> itemsData = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: ProfileRepository.searchEmployeeProfileByText(
            companyId: companyId, searchText: searchText));

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        print("//");
        print(item);
        // String DateOfBirth = convertIsoToDayMonthYear(item['dateOfBirth']);
        // String CreatedAt = convertIsoToDayMonthYear(item['createdAt']);
        // String TerminationDate = convertIsoToDayMonthYear(
        //     item['dateofTermination'] ?? '--');
        // String ReginationDate = convertIsoToDayMonthYear(
        //     item['dateofResignation'] ?? '--');
        // //String CheckDate = convertIsoToDayMonthYear(item['checkDate']);
        // String HireDate = convertIsoToDayMonthYear(item['dateofHire'] ?? '--');
        itemsData.add(SearchEmployeeProfileData(
            employeeId: item['employeeId'] ?? 0,
            code: item['code'] ?? '--',
            userId: item['userId'] ?? 0,
            firstName: item['firstName'] ?? '--',
            lastName: item['lastName'] ?? '--',
            departmentId: item['departmentId'] ?? 0,
            employeeTypeId: item['employeeTypeId'] ?? 0,
            expertise: item['expertise'] ?? '--',
            cityId: item['cityId'] ?? 0,
            countryId: item['countryId'] ?? 0,
            zoneId: item['zoneId'] ?? 0,
            SSNNbr: item['SSNNbr'] ?? '--',
            primaryPhoneNbr: item['primaryPhoneNbr'] ?? '--',
            secondryPhoneNbr: item['secondryPhoneNbr'] ?? '--',
            workPhoneNbr: item['workPhoneNbr'] ?? '--',
            regOfficId: item['regOfficId'] ?? '--',
            personalEmail: item['personalEmail'] ?? '--',
            workEmail: item['workEmail'] ?? '--',
            address: item['address'] ?? '--',
            dateOfBirth: item['dateOfBirth'] ?? "--",
            emergencyContact: item['emergencyContact'] ?? '--',
            employment: item['employment'] ?? '--',
            covreage: item['covreage'] ?? '--',
            gender: item['gender'] ?? '--',
            status: item['status'] ?? '--',
            service: item['service'] ?? '--',
            imgurl: item['imgurl'] ?? '--',
            resumeurl: item['resumeurl'] ?? '--',
            onboardingStatus: item['onboardingStatus'] ?? '--',
            createdAt: item['createdAt'] ?? "--",
            companyId: item['companyId'] ?? 0,
            terminationFlag: item['terminationFlag'] ?? false,
            approved: item['approved'] ?? false,
            dateofTermination: item['dateofTermination'] ?? "--",
            dateofResignation: item['dateofResignation'] ?? "--",
            rehirable: item['rehirable'] ?? "--",
            finalAddress: item['finalAddress'] ?? '--',
            type: item['type'] ?? '--',
            reason: item['reason'] ?? '--',
            finalPayCheck: item['finalPayCheck'] != null
                ? item['finalPayCheck'].toDouble()
                : 0.0,
            checkDate: item['checkDate'] ?? '--',
            grossPay:
                item['grossPay'] != null ? item['grossPay'].toDouble() : 0.0,
            netPay: item['netPay'] != null ? item['netPay'].toDouble() : 0.0,
            methods: item['methods'] ?? '--',
            materials: item['materials'] ?? '--',
            dateofHire: item['dateofHire'] ?? "--",
            position: item['position'] ?? '--',
            driverLicenceNbr: item['driverLicenceNbr'] ?? '--',
            race: item['race'] ?? '--',
            rating: item["rating"] ?? '--',
            active: item['active']??false));
      }

      print("search data by Text${itemsData}");
    } else {
      print(response);
      print("Search Data by Text Error 1");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Search by ID
///get
Future<List<SearchEmployeeProfileData>> getSearchProfileById(
    BuildContext context, int companyId, int employeeTypeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    /// Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    /// Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM-dd-yyyy');

    /// Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<SearchEmployeeProfileData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: ProfileRepository.searchEmployeeProfileById(
            companyId: companyId, Id: employeeTypeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String DateOfBirth = convertIsoToDayMonthYear(item['dateOfBirth']);
        String CreatedAt = convertIsoToDayMonthYear(item['createdAt']);
        String TerminationDate =
            convertIsoToDayMonthYear(item['dateofTermination']);
        String ReginationDate =
            convertIsoToDayMonthYear(item['dateofResignation']);
        String CheckDate = convertIsoToDayMonthYear(item['checkDate']);
        String HireDate = convertIsoToDayMonthYear(item['dateofHire']);
        itemsData.add(SearchEmployeeProfileData(
          employeeId: item['employeeId'] ?? 0,
          code: item['code'] ?? '--',
          userId: item['userId'] ?? 0,
          firstName: item['firstName'] ?? '--',
          lastName: item['lastName'] ?? '--',
          departmentId: item['departmentId'] ?? 0,
          employeeTypeId: item['employeeTypeId'] ?? 0,
          expertise: item['expertise'] ?? '--',
          cityId: item['cityId'] ?? 0,
          countryId: item['countryId'] ?? 0,
          zoneId: item['zoneId'] ?? 0,
          SSNNbr: item['SSNNbr'] ?? '--',
          primaryPhoneNbr: item['primaryPhoneNbr'] ?? '--',
          secondryPhoneNbr: item['secondryPhoneNbr'] ?? '--',
          workPhoneNbr: item['workPhoneNbr'] ?? '--',
          regOfficId: item['regOfficId'] ?? '--',
          personalEmail: item['personalEmail'] ?? '--',
          workEmail: item['workEmail'] ?? '--',
          address: item['address'] ?? '--',
          dateOfBirth: DateOfBirth,
          emergencyContact: item['emergencyContact'] ?? '--',
          employment: item['employment'] ?? '--',
          covreage: item['covreage'] ?? '--',
          gender: item['gender'] ?? '--',
          status: item['status'] ?? '--',
          service: item['service'] ?? '--',
          imgurl: item['imgurl'] ?? '--',
          resumeurl: item['resumeurl'] ?? '--',
          onboardingStatus: item['onboardingStatus'] ?? '--',
          createdAt: CreatedAt,
          companyId: item['companyId'] ?? 0,
          terminationFlag: item['terminationFlag'] ?? false,
          approved: item['approved'] ?? false,
          dateofTermination: TerminationDate,
          dateofResignation: ReginationDate,
          rehirable: item['rehirable'] ?? false,
          finalAddress: item['finalAddress'] ?? '--',
          type: item['type'] ?? '--',
          reason: item['reason'] ?? '--',
          finalPayCheck: item['finalPayCheck'] != null
              ? item['finalPayCheck'].toDouble()
              : 0.0,
          checkDate: CheckDate,
          grossPay:
              item['grossPay'] != null ? item['grossPay'].toDouble() : 0.0,
          netPay: item['netPay'] != null ? item['netPay'].toDouble() : 0.0,
          methods: item['methods'] ?? '--',
          materials: item['materials'] ?? '--',
          dateofHire: HireDate,
          position: item['position'] ?? '--',
          driverLicenceNbr: item['driverLicenceNbr'] ?? '--',
          race: item['race'] ?? '--',
          rating: item['rating'] ?? '--',
          active: item['active']??false,
        ));
      }
      print("search data by Id");
    } else {
      print("Search Data by Id Error 1");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// employee id wise
Future<SearchByEmployeeIdProfileData> getSearchByEmployeeIdProfileByText(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  var itemsData;
  try {
    final response = await Api(context).get(
        path: ProfileRepository.searchByEmployeeIdProfile(
          employeeId: employeeId,
        ));
    print("Getting response");
    print("Search response ::: ${response}");
    if (response.statusCode == 200 || response.statusCode == 201) {

      String DOB = response.data['dateOfBirth'] != null
          ? convertIsoToDayMonthYear(response.data['dateOfBirth'])
          : '--';

      String hireDate = response.data['dateofHire'] != null
          ? convertIsoToDayMonthYear(response.data['dateofHire'])
          : '--';

      String termDate = response.data['dateofTermination'] != null
          ? convertIsoToDayMonthYear(response.data['dateofTermination'])
          : '--';

      String resignDate = response.data['dateofResignation'] != null
          ? convertIsoToDayMonthYear(response.data['dateofResignation'])
          : '--';

      String createdDate = response.data['createdAt'] != null
          ? convertIsoToDayMonthYear(response.data['createdAt'])
          : '--';

      String checkDateStr = response.data['checkDate'] != null
          ? convertIsoToDayMonthYear(response.data['checkDate'])
          : '--';

      itemsData = SearchByEmployeeIdProfileData(
        employeeStatus: response.data['employeeStatus'] ?? '',
        officeId: response.data['officeId'] ?? '',
        employeeId: response.data['employeeId'] ?? 0,
        code: response.data['code'] ?? '--',
        userId: response.data['userId'] ?? 0,
        firstName: response.data['firstName'] ?? '--',
        lastName: response.data['lastName'] ?? '--',
        departmentId: response.data['departmentId'] ?? 0,
        employeeTypeId: response.data['employeeTypeId'] ?? 0,
        cityId: response.data['cityId'] ?? 0,
        countryId: response.data['countryId'] ?? 0,
        zoneId: response.data['zoneId'] ?? 0,
        SSNNbr: response.data['SSNNbr'] ?? '--',
        primaryPhoneNbr: response.data['primaryPhoneNbr'] ?? '--',
        secondryPhoneNbr: response.data['secondryPhoneNbr'] ?? '--',
        workPhoneNbr: response.data['workPhoneNbr'] ?? '--',
        regOfficId: response.data['regOfficId'] ?? '--',
        personalEmail: response.data['personalEmail'] ?? '--',
        workEmail: response.data['workEmail'] ?? '--',
        dateOfBirth: DOB,
        emergencyContact: response.data['emergencyContact'] ?? '--',
        covreage: response.data['covreage'] ?? '--',
        employment: response.data['employment'] ?? '--',
        gender: response.data['gender'] ?? '--',
        status: response.data['status'] ?? '--',
        service: response.data['service'] ?? '--',
        summary: response.data['summary'] ?? '--',
        imgurl: response.data['imgurl'] ?? '--',
        resumeurl: response.data['resumeurl'] ?? '--',
        onboardingStatus: response.data['onboardingStatus'] ?? '',
        driverLicenceNbr: response.data['driverLicenceNbr'] ?? '',
        createdAt: createdDate,
        dateofTermination: termDate,
        dateofResignation: resignDate,
        dateofHire: hireDate,
        rehirable: response.data['rehirable'] ?? '--',
        position: response.data['position'] ?? '--',
        finalAddress: response.data['finalAddress'] ?? '--',
        type: response.data['type'] ?? '--',
        reason: response.data['reason'] ?? '--',
        finalPayCheck: response.data['finalPayCheck'] != null
            ? response.data['finalPayCheck'].toDouble()
            : 0.0,
        checkDate: checkDateStr,
        grossPay: response.data['grossPay'] != null
            ? response.data['grossPay'].toDouble()
            : 0.0,
        netPay: response.data['netPay'] != null
            ? response.data['netPay'].toDouble()
            : 0.0,
        methods: response.data['methods'] ?? '--',
        materials: response.data['materials'] ?? '--',
        city: response.data['city'] ?? '--',
        employeeType: response.data['employeeType'] ?? '--',
        department: response.data['department'] ?? '--',
        country: response.data['country'] ?? '--',
        zone: response.data['zone'] ?? '--',
        race: response.data['race'] ?? '--',
        expertise: response.data['expertise'] ?? '--',
        profileScorePercentage: response.data['profileScorePercentage'] != null
            ? response.data['profileScorePercentage'].toDouble()
            : 0.0,
        anualSkill: response.data['AnnualSkills'] != null
            ? response.data['AnnualSkills'].toDouble()
            : 0.0,
        active: response.data['active'] ?? false,
        color: response.data['color'] ?? "#FFFFFF",
      );

      print("search data by Text ${itemsData.toString()}");
    } else {
      print("Search Data by Text Error 1");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}



Future<ProfilePercentage> getPercentage(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM-dd-yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  var itemsData;
  try {
    final response = await Api(context).get(
        path: ProfileRepository.getPercentage(
      employeeId: employeeId,
    ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      itemsData = ProfilePercentage(percentage: response.data ?? "0");
    //  print('profile percentage');
    } else {
      print("percentage Error 1");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
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

Future<ApiData> patchEmployeeEdit({
  required BuildContext context,
  required bool filePicked,
  required dynamic pickedFilepath,
  required String pickedFileName,
  required int employeeId,
  required String code,
  required int userId,
  required String firstName,
  required String lastName,
  required int departmentId,
  required int employeeTypeId,
  required String expertise,
  required int cityId,
  required int countryId,
  required int countyId,
  required int zoneId,
  required String SSNNbr,
  required String primaryPhoneNbr,
  required String secondryPhoneNbr,
  required String workPhoneNbr,
  required String regOfficId,
  required String personalEmail,
  required String workEmail,
  required String address,
  required String dateOfBirth,
  required String emergencyContact,
  required String covreage,
  required String employment,
  required String gender,
  required String status,
  required String service,
  required String summary,
  required String imgurl,
  required String resumeurl,
  // required int companyId,
  required String onboardingStatus,
  required String driverLicenceNbr,
  required String dateofTermination,
  required String dateofResignation,
  required String dateofHire,
  required String rehirable,
  required String position,
  required String finalAddress,
  required String type,
  required String reason,
  required int finalPayCheck,
  required String checkDate,
  required int grossPay,
  required int netPay,
  required String methods,
  required String materials,
  required String race,
  required String rating,
  required String signatureURL,
  required String colorCode,
  required String departmentName,
}) async {
  String extractServerMessage(dynamic data, String fallback) {
    if (data == null) return fallback;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      // NEW: handle the validation-array shape (message: [{key, message}, ...])
      final rawMessage = data['message'];
      if (rawMessage is List) {
        final details = _extractFieldErrors(data);
        if (details.isNotEmpty) {
          return details.map((d) => d.message).join('\n');
        }
      }
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString() ??
          data['msg']?.toString() ??
          fallback;
    }
    return fallback;
  }
  try {
    final companyId = await TokenManager.getCompanyId();
    final data = {
      'code': code,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'departmentId': departmentId,
      'department': departmentName,
      'employeeTypeId': employeeTypeId,
      'expertise': expertise,
      'cityId': cityId,
      'countryId': countryId,
      'countyId': countyId,
      'zoneId': zoneId,
      'SSNNbr': SSNNbr,
      'primaryPhoneNbr': primaryPhoneNbr,
      'secondryPhoneNbr': secondryPhoneNbr,
      'workPhoneNbr': workPhoneNbr,
      'regOfficId': regOfficId,
      'personalEmail': personalEmail,
      'workEmail': workEmail,
      'address': address,
      'dateOfBirth': "${dateOfBirth}T00:00:00Z",
      'emergencyContact': emergencyContact,
      'covreage': covreage,
      'employment': employment,
      'gender': gender,
      'status': status,
      'service': service,
      'summary': summary,
      'imgurl': imgurl,
      'resumeurl': resumeurl,
      'companyId': companyId,
      'onboardingStatus': onboardingStatus,
      'driverLicenceNbr': driverLicenceNbr,
      'dateofTermination': dateofTermination,
      'dateofResignation': dateofResignation,
      'dateofHire': dateofHire,
      'rehirable': rehirable,
      'position': position,
      'finalAddress': finalAddress,
      'type': type,
      'reason': reason,
      'finalPayCheck': finalPayCheck,
      'checkDate': checkDate,
      'grossPay': grossPay,
      'netPay': netPay,
      'methods': methods,
      'materials': materials,
      'race': race,
      'rating': rating,
      'signatureURL': signatureURL,
      "color": colorCode,
    };

    print("Data payload being sent to API: $data");

    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.employeeEditGet(employeeId: employeeId),
      data: data,
    );

    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employees updated successfully");

      if (filePicked && pickedFilepath != null) {
        print("Uploading file: $pickedFilepath for employeeId: $employeeId");
        await UploadEmployeePhoto(
          context: context,
          documentFile: pickedFilepath,
          employeeId: employeeId,
        );
        print("File upload completed.");
      }

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: extractServerMessage(
          response.data,
          'Employee updated successfully',
        ),
      );
    } else {
      print("Failed to update Employees: ${response.statusCode}");
      print("Error details: ${response.data}");

      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: extractServerMessage(
          response.data,
          response.statusMessage ?? 'Something went wrong',
        ),
        fieldErrors: _extractFieldErrors(response.data), // NEW
      );
    }
  } on DioException catch (e) {
    // Server responded with an error status (4xx/5xx) — grab its message
    print("DioException: ${e.response?.statusCode} — ${e.response?.data}");
    return ApiData(
      statusCode: e.response?.statusCode ?? 500,
      success: false,
      message: extractServerMessage(e.response?.data, 'Server error'),
      fieldErrors: _extractFieldErrors(e.response?.data), // NEW
    );
  } catch (e) {
    print("Error: $e");
    return ApiData(statusCode: 500, success: false, message: "Server error");
  }
}


/// get prefill API  Employees
Future<ProfileEditorModal> getEmployeePrefill(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.trim().isEmpty) return fallback;
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.trim().isEmpty) return fallback;
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  var itemsList;
  final companyId = await TokenManager.getCompanyId();
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.employeePrefillPatch(
            employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      String dateOfBirth = convertIsoToDayMonthYear(response.data['dateOfBirth']);
      itemsList = ProfileEditorModal(
        officeId: response.data['officeId'] ?? '',
        employeeId: _toInt(response.data['employeeId']),
        code: response.data['code'] ?? '',
        userId: _toInt(response.data['userId']),
        firstName: response.data['firstName'] ?? '',
        lastName: response.data['lastName'] ?? '',
        departmentId: _toInt(response.data['departmentId']),
        employeeTypeId: _toInt(response.data['employeeTypeId']),
        cityId: _toInt(response.data['cityId']),
        countryId: _toInt(response.data['countryId']),
        countyId: _toInt(response.data['countyId'], fallback: 1),
        zoneId: _toInt(response.data['zoneId']),
        SSNNbr: response.data['SSNNbr'] ?? '',
        primaryPhoneNbr: response.data['primaryPhoneNbr'] ?? '',
        secondryPhoneNbr: response.data['secondryPhoneNbr'] ?? '',
        workPhoneNbr: response.data['workPhoneNbr'] ?? '',
        regOfficId: response.data['regOfficId'] ?? '',
        speciality: response.data['speciality'] ?? '',
        personalEmail: response.data['personalEmail'] ?? '',
        workEmail: response.data['workEmail'] ?? '',
        dateOfBirth: dateOfBirth ?? '',
        emergencyContact: response.data['emergencyContact'] ?? '',
        covreage: response.data['covreage'] ?? '',
        employment: response.data['employment'] ?? '',
        gender: response.data['gender'] ?? '',
        status: response.data['status'] ?? '',
        service: response.data['service'] ?? '',
        imgurl: response.data['imgurl'] ?? '',
        resumeurl: response.data['resumeurl'] ?? '',
        onboardingStatus: response.data['onboardingStatus'] ?? '',
        driverLicenceNbr: response.data['driverLicenceNbr'] ?? '',
        createdAt: response.data['createdAt'] ?? '',
        // FIX: were "?? null" — dateofTermination/dateofResignation are
        // non-nullable String fields. Assigning null (not caught at compile
        // time since response.data is dynamic) crashes at runtime with
        // "type 'Null' is not a subtype of type 'String'" whenever the API
        // returns null for either field. Now falls back to ''.
        dateofTermination: response.data['dateofTermination'] ?? '',
        dateofResignation: response.data['dateofResignation'] ?? '',
        dateofHire: response.data['dateofHire'] ?? '',
        rehirable: response.data['rehirable'] ?? '',
        position: response.data['position'] ?? '',
        finalAddress: response.data['finalAddress'] ?? '',
        type: response.data['type'] ?? '',
        reason: response.data['reason'] ?? '',
        // FIX: finalPayCheck is declared `int` in ProfileEditorModal, but
        // this was assigning '' (String) whenever the API returns null —
        // which it does for employee 225 ("finalPayCheck": null). That is
        // the exact source of: TypeError: "": type 'String' is not a
        // subtype of type 'int'.
        finalPayCheck: _toInt(response.data['finalPayCheck']),
        checkDate: response.data['checkDate'] ?? '',
        grossPay: _toInt(response.data['grossPay']),
        netPay: _toInt(response.data['netPay']),
        methods: response.data['methods'] ?? '',
        materials: response.data['materials'] ?? '',
        race: response.data['race'] ?? '',
        signatureURL: response.data['signatureURL'] ?? '',
        companyId: _toInt(response.data['companyId']),
        rating: response.data['rating'] ?? '',
        city: response.data['city'] ?? '',
        employeType: response.data['employeeType'] ?? '',
        department: response.data['department'] ?? '',
        country: response.data['country'] ?? '',
        county: response.data['county'] ?? '',
        zone: response.data['zones'] ?? '',
        color: response.data['color']??"#FFFFFF",
        summary: response.data['summary'] ?? "",
        profileScorePercentage: _toDouble(response.data['profileScorePercentage']),
        message: response.statusMessage!,
        success: '', employeeEnrollId: _toInt(response.data['employeeEnrollId']),
      );
      print('${response.data}');
      print("User Prefilled by Get: $itemsList");
    } else {
      print('User Data Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<EmployeeTypeModal>> EmployeeTypeGet(BuildContext context, int departmentId,  ) async {
  List<EmployeeTypeModal> itemsList = [];
  try {
    final response = await Api(context).get(path:  EstablishmentManagerRepository.getEmployeeType(departmentId: departmentId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // Add the employee type to the list
        itemsList.add(
          EmployeeTypeModal(
            employeeTypeId: item['employeeTypeId'],
            DepartmentId: item['DepartmentId'],
            employeeType: item['employeeType'],
            color: item['color'],
            abbreviation: item['abbreviation'],
          ),
        );
      }
    } else {
      print('API Error: ${response.statusCode}');
    }
    print("Response:::::${response.data}"); // Debug the response to see what you're getting
    return itemsList;
  } catch (e) {
    print("Error: $e");
    return itemsList; // Return empty list on error
  }
}

///county wise zone Get API

Future<List<CountyWiseZoneModal>> fetchCountyWiseZone(BuildContext context,
    int countyId,) async {
  List<CountyWiseZoneModal> itemsList = [];
  try {
    final response = await Api(context).get(path:
    ProfileRepository.getCountyWiseZone(
       countyId: countyId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          CountyWiseZoneModal(
              zone_id: item['zone_id'],
              county_id: item['county_id'],
              zoneName: item['zoneName'],
              companyId: item['companyId'],
              officeId: item['officeId'])
          );
      }
    } else {
      print('County Wise Zone API Error: ${response.statusCode}');
    }
    print("Response:::::${response.data}");
    return itemsList;
  } catch (e) {
    print("Error: $e");
    return itemsList; // Return empty list on error
  }
}

/// TODO After api working implement this
// Returns null when the download fails — the caller decides how to react.
Future<DownloadEmployeeOfferLatterData?> downloadEmployeeOfferLatter({
  required BuildContext context,
  required int employeeId,
}) async {
  try {
    final response = await Api(context).get(
      path: EstablishmentManagerRepository.getDownloadOfferLatter(
        employeeId: employeeId,
      ),
    );

    debugPrint("Offer letter response: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // Guard against an empty or malformed body
      if (data == null || data is! Map) {
        _showError(context, 'Invalid response from server.');
        return null;
      }

      return DownloadEmployeeOfferLatterData(
        employeeId: data['employeeId'] ?? 0,
        templateName: data['templateName'] ?? '',
        offerID: data['offerId'] ?? 0,
        pdfUrl: data['pdfUrl'] ?? '',
      );
    } else {
      _handleHttpError(context, response.statusCode);
      return null;
    }
  } on DioException catch (e) {
    // Network-level failures (timeouts, no connection, bad certificates, etc.)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      _showError(context, 'Request timed out. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      _showError(context, 'No internet connection.');
    } else if (e.response != null) {
      _handleHttpError(context, e.response!.statusCode);
    } else {
      _showError(context, 'Something went wrong. Please try again.');
    }
    debugPrint("DioException: $e");
    return null;
  } catch (e, stackTrace) {
    // Anything unexpected (parsing errors, null issues, etc.)
    debugPrint("Unexpected error: $e\n$stackTrace");
    _showError(context, 'Unexpected error occurred.');
    return null;
  }
}

void _handleHttpError(BuildContext context, int? statusCode) {
  switch (statusCode) {
    case 400:
      _showError(context, 'Bad request. Please check the details.');
      break;
    case 401:
      _showError(context, 'Session expired. Please log in again.');
      // Optionally: navigate to login screen here
      break;
    case 403:
      _showError(context, 'You don\'t have permission to download this offer letter.');
      break;
    case 404:
      _showError(context, 'Offer letter not found for this employee.');
      break;
    case 500:
    case 502:
    case 503:
      _showError(context, 'Server error. Please try again later.');
      break;
    default:
      _showError(context, 'Error ${statusCode ?? 'unknown'}. Please try again.');
  }
}

void _showError(BuildContext context, String message) {
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) => FailedPopup(text: message),
    );
  }
}







// Future<SearchByEmployeeIdProfileDataList> getSearchByEmployeeIdProfileByTextii(
//     BuildContext context,
//     int employeeId) async {
//
//   // Helper function to convert ISO date format to a simpler 'dd-mm-yyyy' format
//   String convertIsoToDayMonthYear(String isoDate) {
//     DateTime dateTime = DateTime.parse(isoDate);
//     DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Desired format
//     String formattedDate = dateFormat.format(dateTime);
//     return formattedDate;
//   }
//
//   SearchByEmployeeIdProfileDataList? itemsData;
//
//   try {
//     // Make the API call using the provided employeeId
//     final response = await Api(context).get(
//       path: ProfileRepository.searchByEmployeeIdProfile(employeeId: employeeId),
//     );
//     print("Getting response");
//     print("Search response ::: ${response}");
//
//     // If the response is successful, parse the data
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       String DOB = convertIsoToDayMonthYear(response.data['dateOfBirth']);
//       String hireDate = convertIsoToDayMonthYear(response.data['dateofHire']);
//       List<String> county = List<String>.from(response.data['county'] ?? []);
//       List<String> zone = List<String>.from(response.data['zone'] ?? []);
//
//       // Map the response data to the model class
//       itemsData = SearchByEmployeeIdProfileDataList(
//         employeeId: response.data['employeeId'] ?? 0,
//         code: response.data['code'] ?? '--',
//         userId: response.data['userId'] ?? 0,
//         firstName: response.data['firstName'] ?? '--',
//         lastName: response.data['lastName'] ?? '--',
//         departmentId: response.data['departmentId'] ?? 0,
//         employeeTypeId: response.data['employeeTypeId'] ?? 0,
//         expertise: response.data['expertise'] ?? '--',
//         cityId: response.data['cityId'] ?? 0,
//         countryId: response.data['countryId'] ?? 0,
//         countyId: response.data['countyId'] ?? 0,
//         zoneId: response.data['zoneId'] ?? 0,
//         SSNNbr: response.data['SSNNbr'] ?? '--',
//         primaryPhoneNbr: response.data['primaryPhoneNbr'] ?? '--',
//         secondryPhoneNbr: response.data['secondryPhoneNbr'] ?? '--',
//         workPhoneNbr: response.data['workPhoneNbr'] ?? '--',
//         regOfficId: response.data['regOfficId'] ?? '--',
//         personalEmail: response.data['personalEmail'] ?? '--',
//         workEmail: response.data['workEmail'] ?? '--',
//         dateOfBirth: DOB ?? "--",
//         emergencyContact: response.data['emergencyContact'] ?? '--',
//         covreage: response.data['covreage'] ?? '--',
//         employment: response.data['employment'] ?? '--',
//         gender: response.data['gender'] ?? '--',
//         status: response.data['status'] ?? '--',
//         service: response.data['service'] ?? '--',
//         imgurl: response.data['imgurl'] ?? '--',
//         resumeurl: response.data['resumeurl'] ?? '--',
//         onboardingStatus: response.data['onboardingStatus'] ?? '',
//         driverLicenceNbr: response.data['driverLicenceNbr'] ?? '',
//         createdAt: response.data['createdAt'] ?? "--",
//         dateofTermination: response.data['dateofTermination'] ?? "--",
//         dateofResignation: response.data['dateofResignation'] ?? "--",
//         dateofHire: hireDate ?? "--",
//         rehirable: response.data['rehirable'] ?? "--",
//         position: response.data['position'] ?? '--',
//         finalAddress: response.data['finalAddress'] ?? '--',
//         type: response.data['type'] ?? '--',
//         reason: response.data['reason'] ?? '--',
//         finalPayCheck: response.data['finalPayCheck'] != null
//             ? response.data['finalPayCheck'].toDouble()
//             : 0.0,
//         checkDate: response.data['checkDate'] ?? "--",
//         grossPay: response.data['grossPay'] != null
//             ? response.data['grossPay'].toDouble()
//             : 0.0,
//         netPay: response.data['netPay'] != null
//             ? response.data['netPay'].toDouble()
//             : 0.0,
//         methods: response.data['methods'] ?? '--',
//         materials: response.data['materials'] ?? '--',
//         race: response.data['race'] ?? '--',
//         signatureURL: response.data['signatureURL'] ?? '--',
//         companyId: response.data['companyId'] ?? 0,
//         employeeEnrollId: response.data['employeeEnrollId'] ?? 0,
//         active: response.data['active'] ?? false,
//         summary: response.data['summary'] ?? '--',
//         reportingOffice: response.data['reportingOffice'] ?? '--',
//         speciality: response.data['speciality'] ?? '--',
//         address: response.data['address'] ?? '--',
//         city: response.data['city'] ?? '--',
//         employeeType: response.data['employeeType'] ?? '--',
//         department: response.data['department'] ?? '--',
//         country: response.data['country'] ?? '--',
//         county: county, // List of counties
//         zone: zone, // List of zones
//         AnnualSkills: response.data['AnnualSkills'] != null
//             ? response.data['AnnualSkills'].toDouble()
//             : 0.0,
//         color: response.data['color'] ?? "#FFFFFF",
//         profileScorePercentage: response.data['profileScorePercentage'] != null
//             ? response.data['profileScorePercentage'].toDouble()
//             : 0.0,
//       );
//
//       print("Search data by Employee ID: ${itemsData.toString()}");
//
//     } else {
//       print("Search Data by Employee ID Error - Response status: ${response.statusCode}");
//     }
//
//     return itemsData!;
//
//   } catch (e) {
//     print("Error occurred: ${e}");
//     return itemsData!;
//   }
// }
