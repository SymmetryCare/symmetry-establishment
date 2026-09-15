
import 'package:flutter/material.dart';

import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/main_register_screen_data.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/Register/main_register_screen.dart';

///users/ByCompanyId/{companyId}
Future<List<RegisterDataCompID>> GetRegisterByCompId({
  required BuildContext context,
  required String searchText,
  required int page,
  required int noRows
}) async {
  List<RegisterDataCompID> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response =
    await Api(context).getWithQueryParam(
        path: AllRegisterRepo.getRegisterDataCompId(companyId: companyId),
       queryParameters: {
          "search":searchText,
          "page":page,
          "limit":noRows
       }
       );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data['data']) {
        print("::::::::<><><>");
        itemsList.add(RegisterDataCompID(
            userId: item['userId'] ?? 0,
            firstName: item['firstName'] ?? "--",
            lastName: item['lastName'] ?? '--',
            role: item['role'] ?? '--',
            email: item['email'] ?? '--',
            company_id: item['company_id'] ?? 0,
            status: item['status'] ?? 'Notopen',
            phoneNbr: item['phoneNbr']??" ",
            link: item['link']??" ",
            employeeEnrollId: item['employeeEnrollId']??0,
            employeeId: item['employeeId']??0,
            deptId: item['departmentId']??0,
            department: item['department'] ?? '--',
            posotion: item['position']??" ",
            speciality: item['speciality']??" ",
            clinicalId: item['clinicianTypeId']??0,
            reportingOfficeId: item['reportingOfficeId']??" ",
            cityId: item['cityId']??0,
            countryId: item['countryId']??0,
            countyId: item['countyId']??0,
            zoneId: item['zoneId']??0,
            employeement: item['employment']??" ",
            service: item['service']??" ",
            templateId: item['templateId']??1,
            isActive: item['isActive'] ?? false
            ),);
        //itemsList.sort((a, b) => a.firstName.compareTo(b.firstName));
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


///users/ByCompanyId/{companyId}/{status}
Future<List<RegisterDataCompIDStatus>> GetRegisterByCompIdStatus(
    BuildContext context,
    String status
    ) async {
  List<RegisterDataCompIDStatus> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response =
    await Api(context).get(path: AllRegisterRepo.getRegisterDataCompIdStatus(companyId: companyId, status: status));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RegisterDataCompIDStatus(
            userId: item['userId'] ?? 0,
            firstName: item['firstName'] ?? "--",
            lastName: item['lastName'] ?? '--',
            role: item['role'] ?? '--',
            email: item['email'] ?? '--',
            company_id: item['company_id'] ?? 0,
            status: item['status'] ?? '--'));
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

///register prefill
Future<RegisterDataUserIDPrefill> getRegisterEnrollPrefillUserId(
    BuildContext context, int userId) async {
  var itemsList;
  try {
    final response = await Api(context).get(
        path: AllRegisterRepo.getRegisterPrefill(
            userId: userId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Org Document response:::::${itemsList}");
      itemsList = RegisterDataUserIDPrefill(
          userId: response.data['userId'] ?? 0,
          firstName: response.data['firstName'] ?? "--",
          lastName: response.data['lastName'] ?? '--',
        departmentId: response.data['departmentId'] ?? 0,
        role: response.data['role'] ?? '--',
          email: response.data['email'] ?? '--',
          company_id: response.data['company_id'] ?? 0,
          status: response.data['status'] ?? '--', );
    } else {
      return itemsList;
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
