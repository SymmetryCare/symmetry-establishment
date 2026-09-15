import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_employment_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';

Future<ApiDataRegister> postemploymentscreenData(
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
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.postemploymentscreen(),
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
      print("employment Added");
      var responseEmp = response.data;
      var employeeMentid = responseEmp['employmentId'];
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          employeeMentId: employeeMentid);
    } else {
      final msg = _extractServerMessage(response.data);
      print("Error: $msg");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: msg);
    }
  } on DioException catch (e) {
    // e.response != null proves the server responded (even on 4xx/5xx) —
    // this is where the real validation message lives
    final msg = _extractServerMessage(e.response?.data);
    print("DioException: ${e.response?.statusCode} -> $msg");
    return ApiDataRegister(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: msg,
    );
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
///prifill api get
///
Future<List<EmploymentDataForm>> getEmployeeHistoryForm(
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
  List<EmploymentDataForm> itemsData = [];
  try {
    final response = await ApiOffer(context).get(
        path: ProgressBarRepository
            .getEmploymentByEmpID(employeeID: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(item['dateOfJoining']);
        //String endDateFormattedDate = convertIsoToDayMonthYear(item['endDate']);
        itemsData.add(EmploymentDataForm(
            employmentId: item['employmentId']??"--",
            employeeId: item['employeeId']??"--",
            employer: item['employer']??"--",
            city: item['city']??"--",
            reason: item['reason']??"--",
            supervisor: item['supervisor']??"--",
            supMobile: item['supMobile']??"--",
            title: item['title']??"--",
            dateOfJoining: issueFormattedDate??"--",
            endDate: item['endDate']??"--",
            emgMobile: item['emgMobile']??"--",
            country: item['country']??"--",
          documentUrl: item['documentUrl']??"--",
          documentName: item['documentName']??"--",
        ));
        // itemsData.sort((a, b) => a.employmentId.compareTo(b.employmentId));
      }
    } else {
      print("Employee Education");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}



String _extractServerMessage(dynamic data) {
  if (data is Map) {
    final msg = data['message'];
    if (msg is List) return msg.join(', ');
    if (msg is String) return msg;
  }
  return AppString.somethingWentWrong;
}