import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/others_data.dart';

/// add other doc
Future<ApiData> addOthersDocumentData({required BuildContext context, required String fileName, required String url,
  required int employeeId, required String expDate, required String ifOfDocument, required String createdAt}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    var response = await Api(context).post(path: ManageReposotory.addOthersDoc(), data: {
      "fileName": fileName,
      "employeeId": employeeId,
      "doc_created_at": DateTime.now().toIso8601String()+"Z",
      "url": url,
      "expiry_date": "${expDate}T00:00:00Z",
      "idOfDocument":ifOfDocument,
      "companyId": companyId
    },);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Others doc Added");
      // orgDocumentGet(context);
      var otherDocId = response.data['otherDocument_id'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          otherDocId: otherDocId!);
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

/// Upload other doc
Future<ApiData> uploadOtherDoc({
  required BuildContext context,
  required int otherDocId,
  required dynamic documentFile,
  required String documentName
}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path:ManageReposotory.uploadOthersDoc(otherDocumentid: otherDocId,),
      data: {
        'base64String':documents,
        'file_name':documentName,
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Other doc Uploaded");
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

/// Upload other doc Patch
Future<ApiData> patchUploadOtherDoc({
  required BuildContext context,
  required int otherDocId,
  required dynamic documentFile,
  required String documentName
}) async {
  try {
    String documents = await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).patch(
      path:ManageReposotory.uploadOthersDoc(otherDocumentid: otherDocId,),
      data: {
        'base64String':documents,
        'file_name':documentName,
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Other doc Uploaded");
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

/// get other doc
Future<List<OthersDocModel>> getOthersData(
{required BuildContext context, required int employeeId}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<OthersDocModel> itemsData = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: ManageReposotory.getOthersDocument(employeeId: employeeId, companyId: companyId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // String joiningFormattedDate =
        // convertIsoToDayMonthYear(item['dateOfJoining']);
        // String endFormattedDate = convertIsoToDayMonthYear(item['endDate']);
        itemsData.add(OthersDocModel(
            otherDocId: item['otherDocument_id'],
            fileName: item['fileName']??"",
            employeeId: item['employeeId']??0,
            createdAt: item['doc_created_at']??"",
            url: item['url']??"",
            expDate: item['expiry_date']??"",
            idOfDocument: item['idOfDocument']??"",
            companyId: item['companyId']??1
            ));
      }
    } else {
      print("Employee Employeement");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// get prefill data
Future<OthersDocPreFillModel> getOthersPrefillData(
    {required BuildContext context, required int otherDocId}) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  var itemsData ;
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context)
        .get(path: ManageReposotory.patchOthersDoc(otherDocId: otherDocId));
    if (response.statusCode == 200 || response.statusCode == 201) {
        // String joiningFormattedDate =
        // convertIsoToDayMonthYear(item['dateOfJoining']);

        itemsData = OthersDocPreFillModel(
            otherDocId: response.data['otherDocument_id'],
            fileName: response.data['fileName']??"",
            employeeId: response.data['employeeId']??0,
            createdAt: response.data['doc_created_at']??"",
            url: response.data['url']??"",
            expDate: response.data['expiry_date'] == null ? "" : convertIsoToDayMonthYear(response.data['expiry_date']),
            idOfDocument: response.data['idOfDocument']??"",
            companyId: response.data['companyId']??1
        );

    } else {
      print("Employee Employeement");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// pathch other doc
Future<ApiData> patchOthersDocumentData({required BuildContext context, required int otherDocumentId,required String fileName, required String url,
  required int employeeId, required String expDate, required String ifOfDocument, required String createdAt}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(path: ManageReposotory.patchOthersDoc(otherDocId: otherDocumentId), data: {
      "fileName": fileName,
      "employeeId": employeeId,
      "doc_created_at": DateTime.now().toIso8601String()+"Z",
      "url": url,
      "expiry_date": "${expDate}T00:00:00Z",
      "idOfDocument":ifOfDocument,
      "companyId": companyId
    },);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Others doc Patched");
      // orgDocumentGet(context);
     // var otherDocId = response.data['otherDocument_id'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          );
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

/// Delete other doc
Future<ApiData> deleteOthersDocumentData({required BuildContext context, required int otherDocumentId,}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    var response = await Api(context).delete(path: ManageReposotory.patchOthersDoc(otherDocId: otherDocumentId),);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Others doc deleted");
      // orgDocumentGet(context);
      // var otherDocId = response.data['otherDocument_id'];
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
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