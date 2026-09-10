import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/timeoff_data.dart';

Future<List<TimeOfffData>> getEmployeeTimeOff(
{
    required BuildContext context,
   required int employeeId,
   required String startDate,
   required String endDate}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return DateFormat('d MMMM yyyy hh:mm a').format(dateTime);
  }

  List<TimeOfffData> itemsData = [];
  try {
    final response = await Api(context)
        .getWithQueryParam(
        path: ManageReposotory.getEmployeeTimeOff(),
     queryParameters: {
          "employeeId":employeeId,
           "startDate":startDate,
           "endDate":endDate
     });
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(TimeOfffData(
            employeeTimeOffId: item['id'] ?? 0,
            employeeId: item['employeeId'] ?? 0,
            userId: item['userId'] ?? 0,
            timeOffTypeId: item['timeOffTypeId'] ?? 0,
            leaveTypeId: item['leaveTypeId'] ?? 0,
            startDate: item['startDate'] != null ? convertIsoToDayMonthYear(item['startDate']) : '--',
            endDate: item['endDate'] != null ? convertIsoToDayMonthYear(item['endDate']) : '--',
            reason: (item['reason']?.toString().trim().isNotEmpty ?? false)
                ? item['reason'].toString().trim()
                : '--',            createdAt: item['createdAt'] != null ? convertIsoToDayMonthYear(item['createdAt']) : '',
            updatedAt: item['updatedAt'] != null ? convertIsoToDayMonthYear(item['updatedAt']) : '',
            firstHalf: item['firstHalf'] ?? false,
            timeOffStatus: item['timeOffStatus'] ?? '',
            imageUrl: item['imageUrl'] ?? '',
          employeeName: item['employeeName'] ?? '--'
           ));
      }
    } else {
      print("TimeOff Error");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
/// TimeOfff edit
Future<ApiData> updateEmployeeTimeOffPatch({required BuildContext context,
  required int timeOffId,
  required int timeOffTypeId,
  required int employeeID,
  required int leaveTypeId,
  required String reson,
  required String startTime,
  required String endTime,
  required bool firstHalf,
}) async {
  try {
    var response = await Api(context).patch(path: ManageReposotory.patchEmployeeTimeOff(timeOffId: timeOffId), data: {
      "employeeId": employeeID,
      "reason": reson,
      "startDate": "${startTime}T00:00:00Z",
      "endDate":"${endTime}T00:00:00Z",
      "firstHalf": firstHalf,
      "timeOffTypeId": timeOffTypeId,
      "leaveTypeId": leaveTypeId,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Timeoff updated");
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

/// Get time off prefill
Future<TimeOfPrefillData> getEmployeePrefillTimeOff(
    BuildContext context, int employeeTimeOffId) async {
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
    final response = await Api(context)
        .get(path: ManageReposotory.getEmployeePrefillTimeOff(employeeTimeOffId: employeeTimeOffId));
    if (response.statusCode == 200 || response.statusCode == 201) {
        // String startFormattedDate = convertIsoToDayMonthYear(response.data['startTime']);
        // String endFormattedDate = convertIsoToDayMonthYear(response.data['endTime']);
        itemsData = TimeOfPrefillData(
            timeOffId: response.data['id'] ?? 0,
            employeeId: response.data['employeeId'] ?? 0,
            userId: response.data['userId'] ?? 0,
            timeOffTypeId: response.data['timeOffTypeId'] ?? 0,
            leaveTypeId: response.data['leaveTypeId'] ?? 0,
            startDate: response.data['startDate'] ?? '',
            endDate: response.data['endDate'] ?? '',
            timeOffStatus: response.data['timeOffStatus'] ?? '',
            firstHalf: response.data['firstHalf'] ?? false,
            reason: response.data['reason'] ?? ''
            );
    } else {
      print("TimeOff prefill");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Reject TimeOff
Future<ApiData> rejectTimeOffPatch(BuildContext context, int timeOffId) async {
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data;

    if (data is Map) {
      for (final key in ['message', 'detail', 'error', 'msg']) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) return v;
        if (v is List && v.isNotEmpty) return v.join(', ');
      }
      // DRF-style field errors: {"start_date": ["This field is required."]}
      for (final v in data.values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.trim().isNotEmpty) return v;
      }
    }

    if (data is List && data.isNotEmpty) return data.first.toString();
    return null;
  }
  try {
    final response = await Api(context).patch(
      path: ManageReposotory.rejectTimeOffPatch(employeeTimeOffId: timeOffId),
      data: {},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: _extractMessage(response.data) ?? "TimeOff rejected",
      );
    }

    return ApiData(
      statusCode: response.statusCode ?? 400,
      success: false,
      message: _extractMessage(response.data) ?? AppString.somethingWentWrong,
    );
  } on DioException catch (e) {
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: _extractMessage(e.response?.data) ??
          e.message ??
          AppString.somethingWentWrong,
    );
  } catch (e) {
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}



/// Approve TimeOff
Future<ApiData> approveTimeOffPatch(
    BuildContext context, int employeeTimeOffId) async {
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data;

    if (data is Map) {
      for (final key in ['message', 'detail', 'error', 'msg']) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) return v;
        if (v is List && v.isNotEmpty) return v.join(', ');
      }
      // DRF-style field errors: {"start_date": ["This field is required."]}
      for (final v in data.values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.trim().isNotEmpty) return v;
      }
    }

    if (data is List && data.isNotEmpty) return data.first.toString();
    return null;
  }
  try {
    final response = await Api(context).patch(
      path: ManageReposotory.approveTimeOffPatch(
          employeeTimeOffId: employeeTimeOffId),
      data: {},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: _extractMessage(response.data) ?? "TimeOff Approved",
      );
    }

    return ApiData(
      statusCode: response.statusCode ?? 400,
      success: false,
      message: _extractMessage(response.data) ?? AppString.somethingWentWrong,
    );
  } on DioException catch (e) {
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: _extractMessage(e.response?.data) ??
          e.message ??
          AppString.somethingWentWrong,
    );
  } catch (e) {
    return ApiData(
      statusCode: 505,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}
