import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/qualification_licenses.dart';

Future<List<QulificationLicensesData>> getEmployeeLicenses(
    BuildContext context, int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('dd MMM yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<QulificationLicensesData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: ManageReposotory.getEmployeeLicenses(employeeid: employeeId, approveOnly: 'no'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String expFormattedDate = convertIsoToDayMonthYear(item['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(QulificationLicensesData(
          licenseId: item['licenseId'],
          country: item['country'],
          employeeId: item['employeeId'],
          expData: expFormattedDate,
          issueDate: issueFormattedDate,
          licenseUrl: item['licenseUrl'],
          licenure: item['licensure'],
          licenseNumber: item['licenseNumber'],
          org: item['org'],
          documentType: item['documentType'],
          approved: item['approved'],
          sucess: true,
          message: response.statusMessage!,
        ));
        itemsData.sort((a, b) => a.licenseId.compareTo(b.licenseId));
      }
    } else {
      print("Employee Licenses");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// employee licenses filter
Future<List<QulificationLicensesFilteredData>> getEmployeeLicensesFilteredData(
    BuildContext context, int employeeId, String licenseName) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<QulificationLicensesFilteredData> itemsData = [];
  try {
    final response = await Api(context).get(
        path: ManageReposotory.getEmployeeLicensesFiltered(employeeid: employeeId, approveOnly: 'no', licenseName: licenseName));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String expFormattedDate = convertIsoToDayMonthYear(item['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(QulificationLicensesFilteredData(
          licenseId: item['licenseId'],
          status:item['status'],
          country: item['country'],
          employeeId: item['employeeId'],
          expData: expFormattedDate,
          issueDate: issueFormattedDate,
          licenseUrl: item['licenseUrl'],
          licenure: item['licensure'],
          licenseNumber: item['licenseNumber'],
          org: item['org'],
          documentType: item['documentType'],
          approved: item['approved'],
          sucess: true,
          message: response.statusMessage!,
        ));
        itemsData.sort((a, b) => a.licenseId.compareTo(b.licenseId));
      }
    } else {
      print("Employee Licenses");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Add License

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

/// Extracts a flat, human-readable message from the server's error
/// payload. Handles both the validation-array shape (message: [{key,
/// message}, ...]) and a plain string message.
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

Future<ApiData> addLicensePost(
    BuildContext context,
    String country,
    int employeeId,
    String expDate,
    String issueDate,
    String licenseUrl,
    String licensure,
    String licenseNumber,
    String org,
    String documentType) async {
  try {
    var response = await Api(context).post(
      path: ManageReposotory.addEmployeeLicenses(),
      data: {
        "country": country,
        "employeeId": employeeId,
        "expDate": "${expDate}T00:00:00Z",
        "issueDate": "${issueDate}T00:00:00Z",
        "licenseUrl": licenseUrl,
        "licensure": licensure,
        "licenseNumber": licenseNumber,
        "org": org,
        "documentType": documentType
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("License Added");
      var licenseRes = response.data;
      int licenseId = licenseRes['licenseId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          licenseId: licenseId);
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

/// Attach license document
Future<ApiData> attachLicenseDocument(
    BuildContext context,
    int licenseId,
    dynamic documentFile,
    String documentFileName) async {
  try {
    String document = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    var response = await Api(context).post(
      path: ManageReposotory.attachLicenseDocument(licenseId: licenseId),
      data: {
        "base64":document,
        'documentName': documentFileName
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("License Added");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("License uploaded");
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
/// select document
Future<List<SelectDocuments>> selectDocument(
  BuildContext context,
) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('dd MMM yyyy');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<SelectDocuments> itemsData = [];
  try {
    final response =
        await Api(context).get(path: ManageReposotory.getselectDocuments());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // String expFormattedDate = convertIsoToDayMonthYear(item['expDate']);
        // String issueFormattedDate = convertIsoToDayMonthYear(item['issueDate']);
        itemsData.add(SelectDocuments(
            documentId: item['document_id'],
            documentTypeId: item['document_type_id'],
            documentSubTypeId: item['document_subtype_id'],
            docName: item['doc_name'],
            docCreated: item['doc_created_at']??"",
            url: item['url']??"",
            expiryType: item['expiry_type'],
            expiryDate: item['expiry_date'],
            expiryReminder: item['expiry_reminder'],
            companyId: item['company_id'],
            officeId: item['office_id'],
            idOfDocument: item['idOfDocument']??""));
      }
    } else {
      print("Select Documents");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Update license
Future<ApiData> updateLicensePatch(
    BuildContext context,
    int licenseId,
    String country,
    int employeeId,
    String expDate,
    String issueDate,
    String licenseUrl,
    String licensure,
    String licenseNumber,
    String org,
    String documentType) async {
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg is List) {
        // NEW: when this is the structured [{key, message}, ...] shape,
        // join just the human messages rather than the raw map dump.
        final details = _extractFieldErrors(data);
        if (details.isNotEmpty) {
          return details.map((d) => d.message).join('\n');
        }
        return msg.join('\n'); // e.g. ["issueDate must be a valid date"]
      }
      return msg?.toString();
    }
    return null;
  }
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.updateEmployeeLicenses(licensedId: licenseId),
      data: {
        "country": country,
        "employeeId": employeeId,
        "expDate": "${expDate}T00:00:00Z",
        "issueDate": "${issueDate}T00:00:00Z",
        "licenseUrl": licenseUrl,
        "licensure": licensure,
        "licenseNumber": licenseNumber,
        "org": org,
        "documentType": documentType
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("License Updated");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: _extractMessage(response.data) ?? "License updated successfully",
      );
    } else {
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: _extractMessage(response.data) ??
            response.statusMessage ??
            AppString.somethingWentWrong,
        fieldErrors: _extractFieldErrors(response.data), // NEW
      );
    }
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode ?? 500;
    String message;

    switch (statusCode) {
      case 400:
      // Validation error — backend says exactly what's wrong
        message = _extractMessage(e.response?.data) ??
            "Invalid input. Please check the details and try again.";
        break;
      case 404:
        message = _extractMessage(e.response?.data) ??
            "License not found.";
        break;
      case 401:
        message = _extractMessage(e.response?.data) ??
            "Session expired. Please log in again.";
        break;
      case 403:
        message = _extractMessage(e.response?.data) ??
            "You don't have permission to update this license.";
        break;
      default:
        message = _extractMessage(e.response?.data) ??
            AppString.somethingWentWrong;
    }

    print("Error $statusCode: $message");
    return ApiData(
      statusCode: statusCode,
      success: false,
      message: message,
      fieldErrors: _extractFieldErrors(e.response?.data), // NEW
    );
  } catch (e) {
    print("Error $e");
    // Network failure / timeout — no HTTP status exists
    return ApiData(
      statusCode: 500,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

/// PreFill Licences data
Future<QulificationLicensesPreFillData> getEmployeeLicensesPreFill(
    BuildContext context, int licensesId,) async {
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
        path: ManageReposotory.getEmployeePreFillLicenses(licensesId: licensesId));
    if (response.statusCode == 200 || response.statusCode == 201) {

        String expFormattedDate = convertIsoToDayMonthYear(response.data['expDate']);
        String issueFormattedDate = convertIsoToDayMonthYear(response.data['issueDate']);
        itemsData = QulificationLicensesPreFillData(
          licenseId: response.data['licenseId']??"--",
          country: response.data['country']??"--",
          employeeId: response.data['employeeId']??0,
          expData: expFormattedDate,
          issueDate: issueFormattedDate,
          licenseUrl: response.data['licenseUrl']??"--",
          licenure: response.data['licensure']??"--",
          licenseNumber: response.data['licenseNumber']??"--",
          org: response.data['org']??"--",
          documentType: response.data['documentType']??"--",
          approved: response.data['approved'],
          documentName: response.data['documentName'] ?? '--',
          sucess: true,
          message: response.statusMessage!,
        );
    } else {
      print("Employee Licenses prefill");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Reject license
Future<ApiData> rejectLicensePatch(BuildContext context, int licenseId) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.rejectEmployeeLicenses(licensedId: licenseId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("License rejected");
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

/// Approve license
Future<ApiData> approveLicensePatch(BuildContext context, int licenseId) async {
  try {
    var response = await Api(context).patch(
      path: ManageReposotory.approveEmployeeLicenses(licensedId: licenseId),
      data: {},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("License Approved");
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
