import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/references_data.dart';

Future<List<ReferenceData>> getReferences(
    BuildContext context, int employeeId) async {
  List<ReferenceData> itemsData = [];
  try {
    final response = await Api(context).get(
        path:
            ManageReposotory.referenceByemployeeIdGet(employeeId: employeeId, approveOnly: 'no'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(ReferenceData(
            referenceId: item['referenceId'],
            association: item['association'],
            comment: item['comment'],
            company: item['company'],
            email: item['email'],
            mobNumber: item['mob'],
            employeeId: item['employeeId'],
            name: item['name'],
            references: item['references'],
            title: item['title'],
            approve: item['approve'], sucess: true, message: response.statusMessage!));
        itemsData.sort((a, b) => a.referenceId.compareTo(b.referenceId));
      }
    } else {
      print("References List");
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
        (e is Map ? (e['key'] ?? '') : '').toString(),
        (e is Map ? (e['message'] ?? e.toString()) : e.toString())
            .toString(),
      ))
          .toList();
    }
    return [];
  } catch (e) {
    print("Error parsing field errors: $e");
    return [];
  }
}

String _extractServerMessage(dynamic data, String fallback) {
  if (data == null) return fallback;
  if (data is String && data.isNotEmpty) return data;
  if (data is Map) {
    final rawMessage = data['message'];
    if (rawMessage is List) {
      final details = _extractFieldErrors(data);
      if (details.isNotEmpty) {
        return details.map((d) => d.message).join('\n');
      }
    }
    return rawMessage?.toString() ?? fallback;
  }
  return fallback;
}

// ---------------------------------------------------------------------------
// Add
// ---------------------------------------------------------------------------
Future<ApiData> addReferencePost(
    BuildContext context,
    String association,
    String comment,
    String company,
    String email,
    int employeeId,
    String mob,
    String name,
    String references,
    String title) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.addReferences(),
      data: {
        "association": association,
        "comment": comment,
        "company": company,
        "email": email,
        "employeeId": employeeId,
        "mob": mob,
        "name": name,
        "references": references,
        "title": title
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("reference Added");
      var referenceRes = response.data;
      int referenceId = referenceRes['referenceId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          referenceId: referenceId);
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: _extractServerMessage(
            response.data, AppString.somethingWentWrong),
        fieldErrors: _extractFieldErrors(response.data), // NEW
      );
    }
  } on DioException catch (e) {
    // This fires when the backend responds with a non-2xx status
    // (Dio throws instead of just returning the response in that case).
    String errorMessage = AppString.somethingWentWrong;

    if (e.response != null && e.response!.data != null) {
      errorMessage =
          _extractServerMessage(e.response!.data, AppString.somethingWentWrong);
    } else if (e.message != null) {
      // e.g. no internet, timeout, etc.
      errorMessage = e.message!;
    }

    print("DioException: $errorMessage");
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: errorMessage,
      fieldErrors: _extractFieldErrors(e.response?.data), // NEW
    );
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong);
  }
}

// ---------------------------------------------------------------------------
// Update
// ---------------------------------------------------------------------------
Future<ApiData> updateReferencePatch(
    BuildContext context,
    int referenceId,
    String association,
    String comment,
    String company,
    String email,
    int employeeId,
    String mob,
    String name,
    String references,
    String title) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.updateReferences(referenceId: referenceId),
      data: {
        "association": association,
        "comment": comment,
        "company": company,
        "email": email,
        "employeeId": employeeId,
        "mob": mob,
        "name": name,
        "references": references,
        "title": title
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("reference updated");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: _extractServerMessage(
            response.data, AppString.somethingWentWrong),
        fieldErrors: _extractFieldErrors(response.data), // NEW
      );
    }
  } on DioException catch (e) {
    String errorMessage = AppString.somethingWentWrong;

    if (e.response != null && e.response!.data != null) {
      errorMessage =
          _extractServerMessage(e.response!.data, AppString.somethingWentWrong);
    } else if (e.message != null) {
      errorMessage = e.message!;
    }

    print("DioException: $errorMessage");
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: errorMessage,
      fieldErrors: _extractFieldErrors(e.response?.data), // NEW
    );
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong);
  }
}
/// Get prefill
Future<ReferencePrefillData> getPrefillReferences(
    BuildContext context, int referenceId) async {
  var itemsData;
  try {
    final response = await Api(context).get(
        path:
        ManageReposotory.updateReferences(referenceId: referenceId));
    if (response.statusCode == 200 || response.statusCode == 201) {
        itemsData = ReferencePrefillData(
            referenceId: response.data['referenceId'],
            association: response.data['association'],
            comment: response.data['comment'],
            company: response.data['company'],
            email: response.data['email'],
            mobNumber: response.data['mob'],
            employeeId: response.data['employeeId'],
            name: response.data['name'],
            references: response.data['references'],
            title: response.data['title'],
            approve: response.data['approve']??false, sucess: true, message: response.statusMessage!);
    } else {
      print("References Prefill data");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
/// Reject reference
Future<ApiData> rejectReferencePatch(BuildContext context, int referenceId) async {
  try {
    var response = await Api(context).patch(path: ManageReposotory.rejectReferences(referenceId: referenceId), data: {},);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Reject reference");
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

/// Approve reference
Future<ApiData> approveReferencePatch(BuildContext context, int referenceId) async {
  try {
    var response = await Api(context).patch(path: ManageReposotory.approveReferences(referenceId: referenceId), data: {},);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Approve reference");
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