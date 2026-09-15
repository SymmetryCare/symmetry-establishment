import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/education_data.dart';

Future<List<EducationData>> getEmployeeEducation(
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

  List<EducationData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: ManageReposotory.getEmployeeDucation(employeeId: employeeId, approveOnly: 'no'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        //String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        //String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(EducationData(
            educationId: item['educationId'],
            employeeID: item['employeeId'],
            graduate: item['graduate'],
            degree: item['degree'],
            major: item['major'],
            city: item['city'],
            college: item['college'],
            phone: item['phone'],
            state: item['state'],
            approved: item['approved'],
            sucess: true,
            message: response.statusMessage!,
            country: item['country']??"--",
            startDate: item['startDate']??"--"));
        itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));
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

/// Add Education
Future<ApiData> addEmployeeEducation(
    BuildContext context,
    int employeeId,
    String graduate,
    String degree,
    String major,
    String city,
    String college,
    String phone,
    String state,
    String country,
    String startDate) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.addEmployeeDucation(),
      data: {
        "employeeId": employeeId,
        "graduate": graduate,
        "degree": degree,
        "major": major,
        "city": city,
        "college": college,
        "phone": phone,
        "state": state,
        "country": country,
        "startDate": "${startDate}T00:00:00Z"
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Education added");
      // orgDocumentGet(context);
      var educationResponse = response.data;
      int educationId = educationResponse['educationId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          educationId:educationId);
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

/// Prefill get education
Future<EducationPrefillData> getPrefillEmployeeEducation(
    BuildContext context, int educationId) async {
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
        path: ManageReposotory.patchEmployeeDucation(educationId: educationId));
    if (response.statusCode == 200 || response.statusCode == 201) {
        //String startDateFormattedDate = response.data['startDate'] == null ? "--" : convertIsoToDayMonthYear(response.data['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(response.data['startDate']);
        itemsData = EducationPrefillData(
            educationId: response.data['educationId'],
            employeeID: response.data['employeeId'],
            graduate: response.data['graduate'],
            degree: response.data['degree'],
            major: response.data['major'],
            city: response.data['city'],
            college: response.data['college'],
            phone: response.data['phone'],
            state: response.data['state'],
            approved: response.data['approved'] ?? false,
            sucess: true,
            message: response.statusMessage!,
            country: response.data['country']??"--",
            startDate: issueFormattedDate);

    } else {
      print("Employee Education prefill");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Patch education
Future<ApiData> updateEmployeeEducation(
    BuildContext context,
    int educationId,
    int employeeId,
    String graduate,
    String degree,
    String major,
    String city,
    String college,
    String phone,
    String state,
    String country,
    String startDate) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.patchEmployeeDucation(educationId: educationId),
      data: {
        "employeeId": employeeId,
        "graduate": graduate,
        "degree": degree,
        "major": major,
        "city": city,
        "college": college,
        "phone": phone,
        "state": state,
        "country": country,
        "startDate": "${startDate}T00:00:00Z"
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Education updates");
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
