
import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/search_byfilter_repo.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';

/// Add search by employee
Future<List<ApiDataFilter>?> postSearchByFilter(
    BuildContext context,
    bool patientProfileSearch,
    String profileName,
    bool officeLocationSearch,
    String officeId,
    bool zoneSearch,
    int zoneId,
    bool licenseSearch,
    String licenseStatus,
    bool availabilitySearch,
    String availability,
    bool isDZone,
    int loggedUserId,

    ) async {
  try {
    // ✅ Or print each field individually
    print("patientProfileSearch: $patientProfileSearch");
    print("profileName: $profileName");
    print("officeLocationSearch: $officeLocationSearch");
    print("officeId: $officeId");
    print("zoneSearch: $zoneSearch");
    print("zoneId: $zoneId");
    print("licenseSearch: $licenseSearch");
    print("licenseStatus: $licenseStatus");
    print("availabilitySearch: $availabilitySearch");
    print("availability: $availability");
    print("isDZone: $isDZone");
    print("loggedInUserId: $loggedUserId");
    List<ApiDataFilter> responseList = [];
    var response = await Api(context).post(
      path: SearchByfilterRepo.employeeSearchByFilter(),
      data: {
         "patientProfileSearch":  patientProfileSearch,
         "profileName":profileName,
         "officeLocationSearch": officeLocationSearch,
         "officeId": officeId,
         "zoneSearch": zoneSearch,
         "zoneId": zoneId,
         "licenseSearch": licenseSearch,
         "licenseStatus": licenseStatus,
         "availabilitySearch":availabilitySearch,
         "availability": availability,
         "isDZone":isDZone,
         "loggedInUserId":loggedUserId

      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Search By Filter Done");
      // orgDocumentGet(context);

      for(var item in response.data){
         responseList.add(ApiDataFilter(
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
             rating:item["rating"]??'--'
            ));
      }

    } else {
      print("Error 1");
    }
    return responseList;
  } catch (e) {
    print("Error $e");
  }
}