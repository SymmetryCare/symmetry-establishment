import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/add_employee/clinical.dart';
import 'package:dio/dio.dart' as dio; // Alias Dio package
import 'package:get/get_connect/http/src/multipart/form_data.dart' as get_form_data;

// Other imports

///get Employee API
Future<List<HRAddEmployeeGet>> HrAddEmployeeget(
    BuildContext context,
    ) async {
  List<HRAddEmployeeGet> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: HRModuleAEClinicalRepository.getEmployees());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          HRAddEmployeeGet(
            employeeid : item['employeeId'],
            code: item['code'],
            userId: item['userId'],
            firstName: item['firstName'],
            lastName: item['lastName'],
            dptID: item['departmentId'],
            emplyID: item['employeeTypeId'],
            expritise: item['expertise'],
            cityID: item['cityId'],
            countryID: item['countryId'],
            zoneID: item['zoneId'],
            ssnnBr: item['SSNNbr'],
            primeNo: item['primaryPhoneNbr'],
            secNo: item['secondryPhoneNbr'],
            workNo: item['workPhoneNbr'],
            regOfficeId: item['regOfficId'],
            personalEmail: item['personalEmail'],
            workEmail: item['"workEmail'],
            address: item['address'],
            dob: item['dateOfBirth'],
            emgContact: item['emergencyContact'],
            coverage: item['covreage'],
            employment: item['employment'],
            gender: item['gender'],
            status: item['status'],
            service: item['service'],
            imgUrl: item['imgurl'],
            resumeUrl: item['resumeurl'],
            onboardingStatus: item['onboardingStatus'],
            companyID: item['companyId'],
            terminationFlag: item['terminationFlag'],
            driverLicenceNbr: item['driverLicenceNbr'],
            approved: item['approved'],
            dateofTermination: item['dateofTermination'],
            dateofResignation: item['dateofResignation'],
            dateofHire: item['dateofHire'],
            rehirable: item['rehirable'],
            position:item['position'],
            finalAddress: item['finalAddress'],
            type: item['type'],
            reason: item['reason'],
            finalPayCheck: item['finalPayCheck'],
            checkDate: item['checkDate'],
              grossPay: item['grossPay'],
              netPay : item["netPay"],
              methods : item['methods'],
              materials: item['materials'],
              race: item['race'],
          ),
        );
      }
      print("Response:::::${response}");
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

///ADD Employee Post API
Future<ApiData> addEmployeeClinical(
    BuildContext context,
    int emplyId,
    String code,
    int userId,
    String firstName,
    String lastName,
    int dptID,
    int emplyTypeId,
    String expritise,
    int cityID,
    int countryID,
    int countyId,
    int zoneID,
    String ssnnBr,
    String primeNo,
    String secNo,
    String workNo,
    String regOfficeId,
    String personalEmail,
    String workEmail,
    String address,
    String dob,
    String emgContact,
    String coverage,
    String employment,
    String gender,
    String status,
    String service,
    String imgUrl,
    String resumeUrl,
    int companyID,
    bool terminationFlag,
    bool approved,
    String onboardingStatus,
    String driverLicenceNbr,
    String dateofTermination,
    String dateofResignation,
    String dateofHire,
    String rehirable,
    String position,
    String finaladdress,
    String checkDate,
    int grossPay,
    String type,
    String reason,
    int finalPayCheck,
    int netpay,
    String method,
    String material,
    String race,
    String rating,
    String signatureURL,

    ) async {
  try {
    var response = await Api(context).post(
      path: HRModuleAEClinicalRepository.postAddEmployeeClinical(),
      data: {
        "code": code,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "departmentId": dptID,
        "employeeTypeId": emplyTypeId,
        "expertise": expritise,
        "cityId": cityID,
        "countryId": countryID,
        "countyId": countyId,
        "zoneId": zoneID,
        "SSNNbr": ssnnBr,
        "primaryPhoneNbr": primeNo,
        "secondryPhoneNbr": secNo,
        "workPhoneNbr": workNo,
        "regOfficId": regOfficeId,
        "personalEmail": personalEmail,
        "workEmail": workEmail,
        "address": address,
        "dateOfBirth": "${dob}T00:00:00Z",
        "emergencyContact": emgContact,
        "covreage": coverage,
        "employment": employment,
        "gender": gender,
        "status": status,
        "service": service,
        "imgurl": imgUrl,
        "resumeurl": resumeUrl,
        "companyId": companyID,
        "onboardingStatus": onboardingStatus,
        "driverLicenceNbr": driverLicenceNbr,
        "dateofTermination": "${dateofTermination}T00:00:00Z",
        "dateofResignation": "${dateofResignation}T00:00:00Z",
        "dateofHire": "${dateofHire}T00:00:00Z",
        "rehirable": rehirable,
        "position": position,
        "finalAddress": finaladdress,
        "type": type,
        "reason": reason,
        "finalPayCheck": finalPayCheck,
        "checkDate": "${checkDate}T00:00:00Z",
        "grossPay": grossPay,
        "netPay": netpay,
        "methods": method,
        "materials": material,
        "race": race,
        "rating": rating,
        "signatureURL":signatureURL

      },

    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Add Employee added");
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
///post api for upload photo
Future<ApiData> addPhotoUpload(
    BuildContext context,
    int emplyId,
    String code,
    int userId,
    String firstName,
    String lastName,
    int dptID,
    int emplyTypeId,
    String expritise,
    int cityID,
    int countryID,
    int zoneID,
    String ssnnBr,
    String primeNo,
    String secNo,
    String workNo,
    String regOfficeId,
    String personalEmail,
    String workEmail,
    String address,
    String dob,
    String emgContact,
    String coverage,
    String employment,
    String gender,
    String status,
    String service,
    String imgUrl,
    String resumeUrl,
    int companyID,
    bool terminationFlag,
    bool approved,
    String onboardingStatus,
    String createdAt,
    String driverLicenceNbr,
    String dateofTermination,
    String dateofResignation,
    String dateofHire,
    String rehirable,
    String position,
    String finaladdress,
    String checkDate,
    int grossPay,
    String type,
    String reason,
    int finalPayCheck,
    int netpay,
    String method,
    String material,
    String race,

    ) async {
  try {
    var response = await Api(context).post(
      path: HRModuleAEClinicalRepository.addphoto(employeeID: emplyId),
      data: {
        "employeeId": emplyId,
        "code": code,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "departmentId": dptID,
        "employeeTypeId": emplyTypeId,
        "expertise": expritise,
        "cityId": cityID,
        "countryId": countryID,
        "zoneId": zoneID,
        "SSNNbr": ssnnBr,
        "primaryPhoneNbr": primeNo,
        "secondryPhoneNbr": secNo,
        "workPhoneNbr": workNo,
        "regOfficId": regOfficeId,
        "personalEmail": personalEmail,
        "workEmail": workEmail,
        "address": address,
        "dateOfBirth": "${dob}T00:00:00Z",
        "emergencyContact": emgContact,
        "covreage": coverage,
        "employment": employment,
        "gender": gender,
        "status": status,
        "service": service,
        "imgurl": imgUrl,
        "resumeurl": resumeUrl,
        "companyId": companyID,
        "onboardingStatus": onboardingStatus,
        "createdAt": "${createdAt}T00:00:00Z",
        "terminationFlag": terminationFlag,
        "approved": approved,
        "dateofTermination": "${dateofTermination}T00:00:00Z",
        "dateofResignation": "${dateofResignation}T00:00:00Z",
        "dateofHire": "${dateofHire}T00:00:00Z",
        "rehirable": rehirable,
        "position": position,
        "driverLicenceNbr": driverLicenceNbr,
        "finalAddress": finaladdress,
        "type": type,
        "reason": reason,
        "finalPayCheck": finalPayCheck,
        "checkDate": "${checkDate}T00:00:00Z",
        "grossPay": grossPay,
        "netPay": netpay,
        "methods": method,
        "materials": material,
        "race": race,

      },

    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Photo Uploaded");
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





///Discipline dropdown get Api
Future<List<AEClinicalDiscipline>> HrAddEmplyClinicalDisciplinApi(
    BuildContext context, int deptID) async {
  List<AEClinicalDiscipline> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: HRModuleAEClinicalRepository.getEmployeeTypeDept(deptID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          AEClinicalDiscipline(
            employeeTypesId: item['employeeTypeId'],
            empType: item['employeeType'],
            deptID: item['DepartmentId'],
            abbrivation: item['abbreviation'],
            color: item['color'],
          ),
        );
      }
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

///city dropdown get Api
Future<List<AEClinicalCity>> HrAddEmplyClinicalCityApi(
  BuildContext context,
  // int deptID
) async {
  List<AEClinicalCity> itemsList = [];
  try {
    final response = await Api(context).get(
        path: HRModuleAEClinicalRepository.getAddEmployeeTypeCity(
            // deptID
            ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(AEClinicalCity(
          cityName: item['cityName'],
          cityID: item['city_id'],
          state: item['state'],
          country: item['Country'],
        ));
      }
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

///Reporting Office DropDown get api
Future<List<AEClinicalReportingOffice>> HrAddEmplyClinicalReportingOfficeApi(
    BuildContext context, int companyID) async {
  List<AEClinicalReportingOffice> itemsList = [];
  try {
    final response = await Api(context).get(
        path:
            HRModuleAEClinicalRepository.getAddEmplyReportingOffice(companyID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          AEClinicalReportingOffice(
              companyOfficeID: item['company_Office_id'],
              companyID: item['company_id'],
              officeID: item['office_id'],
              primNo: item['primary_phone'],
              secNo: item['secondary_phone'],
              primeFax: item['primary_fax'],
              secFax: item['secondary_fax'],
              alterNo: item['alternative_phone'],
              email: item['email'],
              name: item['name'],
              address: item['address']),
        );
      }
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

///zone drop down
Future<List<AEClinicalZone>> HrAddEmplyClinicalZoneApi(
  BuildContext context,
) async {
  List<AEClinicalZone> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: HRModuleAEClinicalRepository.getAddEmplyZone(companyId: companyId
            //   companyID: companyID, officeID:officeID, countyID: countyID,
            // pageNo: pageNo,
            // rowsNo: rowsNo,
            ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          AEClinicalZone(
            county: item['countyName'],
            countyID: item['county_id'],
            zoneID: item['zone_id'],
            zoneName: item['zoneName'],
            companyId: item['companyId'],
            officeId: item['officeId'],
          ),
        );
      }
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

// int companyID,
// int officeID,
// int countyID,
// int pageNo,
// int rowsNo,
/// service radio button Get Api
Future<List<AEClinicalService>> HrAddEmplyClinicalServiceRadioButtonApi(
    BuildContext context,
    ) async {
  List<AEClinicalService> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path:
            HRModuleAEClinicalRepository.getEmplyServiceRadiobutton(companyID: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          AEClinicalService(
              officeServiceID: item['Office_service_id'],
              companyID: companyId,
              officeID: item['office_id'],
              serviceName: item['service_name'],
              npiNo: item['npi_number'],
              medicareProviderID: item['medicare_provider_id'],
              hecoNoID: item['hco_num_id']),
        );
      }
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




///prajwal
/// service radio button Get Api meta data
Future<List<EnrollServices>> EmpServiceRadioButtonApi(
    BuildContext context,
    ) async {
  List<EnrollServices> itemsList = [];
  try {
    // final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path:
        HRModuleAEClinicalRepository.getEmpServiceRadiobutton());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
            EnrollServices(
            serviceMetadataId: item['serviceMetadataId'],
            servicename: item['service_name'],
            serviceid: item['service_id'],
          )
        );
      }
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
