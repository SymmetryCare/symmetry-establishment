import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employee_banking_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';

Future<List<EmployeeBankingData>> getEmployeeBanking(
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

  List<EmployeeBankingData> itemsData = [];
  try {
    final response = await Api(context)
        .get(path: ManageReposotory.getBankingEmployee(employeeId: employeeId, approveOnly: 'no'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data!) {
        String effectiveFormattedDate = convertIsoToDayMonthYear(item['effectiveDate']);
        // String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(EmployeeBankingData(
            empBankingId: item['empBankingId'],
            employeeId: item['employeeId'],
            accountNumber: item['accountNumber'],
            bankName: item['bankName'],
            amountRequested: item['amountRequested'],
            checkUrl: item['checkUrl'],
          percentage: item['requestedPercentage'] ?? "0",
            effectiveDate: effectiveFormattedDate,
            routinNumber: item['routingNumber'],
            type: item['type'],
            approve: item['approved'] ?? false, requestedPercentage: item['requestedPercentage']??"0",

            ));
        itemsData.sort((a, b) => a.empBankingId.compareTo(b.empBankingId));
      }
    } else {
      print("Employee Bancking");
    }
    return itemsData;
  } catch (e) {
    print("error ${e}");
    return itemsData;
  }
}

/// Banking employee prefill Get
Future<EmployeeBankingPrefillData> getPrefillEmployeeBancking(
    BuildContext context, int empBankingId) async {
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
        .get(path: ManageReposotory.getPrefillBankingEmployee(empBankingId: empBankingId));
    if (response.statusCode == 200 || response.statusCode == 201) {

        String effectiveFormattedDate = convertIsoToDayMonthYear(response.data['effectiveDate']);
        // String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        print(":::;${response.data}");
        itemsData = EmployeeBankingPrefillData(
          percentage: response.data['requestedPercentage']??"0",
            empBankingId: response.data['empBankingId'],
            employeeId: response.data['employeeId'],
            accountNumber: response.data['accountNumber'],
            bankName: response.data['bankName']??"--",
            amountRequested: response.data['amountRequested'],
            checkUrl: response.data['checkUrl'],
            effectiveDate: effectiveFormattedDate,
            routinNumber: response.data['routingNumber'],
            type: response.data['type'],
            documentName: response.data['documentName'] ?? "--",
            action: response.data['action']??"--",
            approve: response.data['approved'] ?? true
            );
        print("ItemData${itemsData.toString()}");

    } else {
      print("Employee Prefill Bancking");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Banking patch api

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

Future<ApiData> PatchEmployeeBanking(
    BuildContext context,
    int bankingId,
    int employeeId,
    String accountNumber,
    String bankName,
    int amountRequested,
    String checkUrl,
    String effectiveDate,
    String routingNumber,
    String percentage,
    String type) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.updateBankingEmployee(empBankingId: bankingId),
      data: {
        "employeeId": employeeId,
        "accountNumber": accountNumber,
        "bankName": bankName,
        "amountRequested": amountRequested,
        "checkUrl": checkUrl,
        "effectiveDate": "${effectiveDate}T00:00:00Z",
        "routingNumber": routingNumber,
        "type": type,
        "requestedPercentage": percentage,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Banking updated");
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

/// Add bancking

Future<ApiData> addNewEmployeeBanking(
    {required BuildContext context,
      required int employeeId,
      required String accountNumber,
      required String bankName,
      required int amountRequested,
      required String checkUrl,
      required String effectiveDate,
      required String routingNumber,
      required String percentage,
      required String type}) async {
  try {
    var response = await Api(context).post(
        path: ManageReposotory.addNewBankingEmployee(),
        data: {
          "employeeId": employeeId,
          "accountNumber": accountNumber,
          "bankName": bankName,
          "amountRequested": amountRequested,
          "checkUrl": checkUrl,
          "effectiveDate": "${effectiveDate}T00:00:00Z",
          "routingNumber": routingNumber,
          "type": type,
          "requestedPercentage": percentage,
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Banking Added");
      var bankRes = response.data;
      int bankId = bankRes['empBankingId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          banckingId: bankId);
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



/// Attach bncking document
Future<ApiData> uploadBanckingDocument(
    BuildContext context,
    int banckingId,
    dynamic documentFile,
    String documentFileName) async {
  try {
    String document = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await Api(context).post(
      path: ManageReposotory.uploadBanckingDocuments(empBankingId:banckingId),
      data: {
      "base64": document,
        "documentName": documentFileName
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Bank Document uploaded");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);

    } else {
      print("Upload Error 1");
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

/// Reject bank
Future<ApiData> rejectBankPatch(BuildContext context, int empBankingId) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.rejectBankingEmployee(empBankingId: empBankingId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Bank rejected");
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

/// Approve bank
Future<ApiData> approveBankPatch(BuildContext context, int empBankingId) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.approveBankingEmployee(empBankingId: empBankingId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Bank Approved");
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