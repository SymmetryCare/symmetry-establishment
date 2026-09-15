import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_banking_data.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';

String _extractServerMessage(dynamic data) {
  try {
    if (data == null) return AppString.somethingWentWrong;

    final map = data as Map<String, dynamic>;
    final rawMessage = map['message'];

    if (rawMessage is List) {
      final details = _extractFieldErrors(data);
      if (details.isEmpty) return AppString.somethingWentWrong;
      return details.map((d) => d.message).join('\n');
    }

    if (rawMessage is String) {
      return rawMessage;
    }

    return AppString.somethingWentWrong;
  } catch (e) {
    print("Error parsing server message: $e");
    return AppString.somethingWentWrong;
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

// ---------------------------------------------------------------------------
// Manager function
// ---------------------------------------------------------------------------

Future<ApiDataRegister> postbankingscreenData(
    BuildContext context,
    int employeeId,
    String accountNumber,
    String bankName,
    int amountRequested,
    String checkUrl,
    String effectiveDate,
    String routingNumber,
    String type,
    String requestedPercentage
    ) async {
  try {
    var response = await ApiOffer(context).post(
      path: ProgressBarRepository.postbankingscreen(),
      data: {
        "employeeId": employeeId,
        "accountNumber": accountNumber,
        "bankName": bankName,
        "amountRequested": amountRequested,
        "checkUrl": checkUrl,
        "effectiveDate": "${effectiveDate}T00:00:00Z",
        "routingNumber": routingNumber,
        "type": type,
        "requestedPercentage": requestedPercentage
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("banking Added");
      var bankResponse = response.data;
      var banckingId = bankResponse['empBankingId'];
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          banckingId: banckingId,
          message: response.statusMessage!);
    } else {
      final msg = _extractServerMessage(response.data);
      final fieldErrors = _extractFieldErrors(response.data);
      print("Error 1: $msg");
      return ApiDataRegister(
        statusCode: response.statusCode!,
        success: false,
        message: msg,
        fieldErrors: fieldErrors, // NEW
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

Future<ApiData> uploadcheck({
  required BuildContext context,
  required int employeeid,
  required int empBankingId,
  required dynamic documentFile,
  required String documentName
}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path:ManageReposotory.uploadcheck(empBankingId: empBankingId),
      data: {
        'base64':documents,
        'documentName':documentName
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Employee Check uploded");
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






///get prifill api
Future<List<BankingDataForm>> getBankingForm(
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
  List<BankingDataForm> itemsData = [];
  try {
    final response = await ApiOffer(context).get(
        path: ProgressBarRepository
            .getBankingByEmpID(employeeID: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        //String startDateFormattedDate = item['startDate'] == null ? "--" :convertIsoToDayMonthYear(item['expDate']);
        String FormattedDate = convertIsoToDayMonthYear(item['effectiveDate']);
        itemsData.add(BankingDataForm(
          empBankingId: item['empBankingId']??00,
          employeeId: item['employeeId']??00,
          accountNumber: item['accountNumber']??"--",
          bankName: item['bankName']??"--",
          amountRequested: item['amountRequested']??00,
          checkUrl: item['checkUrl']??"--",
          effectiveDate: FormattedDate,
          routingNumber: item['routingNumber']??"--",
          type: item['type']??"--",
          requestedPercentage: item['requestedPercentage']??"--",

        ));
        // itemsData.sort((a, b) => a.educationId.compareTo(b.educationId));
      }
    } else {
      print("Employee Banking");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}
