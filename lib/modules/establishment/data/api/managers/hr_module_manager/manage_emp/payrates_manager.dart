import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/payrates_data.dart';

/// Get equipment
Future<List<PayratesData>> getEmployeePayrates(
    BuildContext context,
    int employeeId,
    int pageNo,
    int noOfRows) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('MM-dd-yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<PayratesData> itemsData = [];
  try {
    final response =
    await Api(context).get(path: ManageReposotory.getEmployeePayrates(employeeID: employeeId, pagNo: pageNo, noOfRows: noOfRows));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // String assignedFormattedDate =

        // convertIsoToDayMonthYear(item['assignedDate']);
        itemsData.add(PayratesData(employeeId: item['employeeId'], employeeName: item['employeeName'],
            payratesSetupId: item['PayratesSetupId'], employeeTypeId: item['employeeTypeId'], department: item['department'], departmentId: item['departmentId'],
            employeeType: item['employeeType']??"--", abbreviation: item['abbreviation']??"--", typeOfVisitId: item['typeOfVisitId'], visitType: item['typeOfVisit'], zoneId: item['zoneId'], zone: item['zone'], payRates: item['payrates'], permiles: item['permiles']));
        itemsData.sort((a, b) => a.zoneId.compareTo(b.zoneId));
      }
    } else {
      print("Payrates");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Delete payrates
Future<ApiData> deleteEmployeePayrates({required BuildContext context,
    required int employeePayratesId,}
    ) async {
  try {
    var response = await Api(context).delete(path: ManageReposotory.deleteEmployeePayrates(employeePayratesId: employeePayratesId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Employee payrates Deleted");
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