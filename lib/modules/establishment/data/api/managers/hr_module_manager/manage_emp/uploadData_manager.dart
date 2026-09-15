import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/upload_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:http/http.dart' as http;
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employee_document_data.dart';

Future<ApiData> uploadDocuments({
  required BuildContext context,
  required int employeeDocumentMetaId,
  required int employeeDocumentTypeSetupId,
  required int employeeId,
  required dynamic documentFile,
  required String documentName,
  String? expiryDate
}) async {
  try {
    String documents = await
    AppFilePickerBase64.getEncodeBase64(
        bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path: UploadDocumentRepository.uploadEmployeeDocumentGet(employeeDocumentTypeMetaDataId: employeeDocumentMetaId, employeeDocumentTypeSetupId: employeeDocumentTypeSetupId, employeeId: employeeId),
      data: {
        'base64':documents,
        "expiry_date": expiryDate,
        "documentName":documentName
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents uploded");
      // orgDocumentGet(context);
      var uploadResponse = response.data;
      int documentId = uploadResponse['employeeDocumentId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,documentId:documentId );
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

/// patch upload emp document
Future<ApiData> patchEmployeeBase64Documents({
  required BuildContext context,
  required int employeeDocumentId,
  required int employeeDocumentMetaId,
  required int employeeDocumentTypeSetupId,
  required int employeeId,
  required dynamic documentFile,
  required String documentName,
  String? expiryDate
}) async {
  try {
    String documents = await
    AppFilePickerBase64.getEncodeBase64(
        bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).patch(
      path: UploadDocumentRepository.PatchUploadEmployeeDocumentGet(
          employeeDocumentId: employeeDocumentId,
          employeeDocumentTypeMetaDataId: employeeDocumentMetaId,
          employeeDocumentTypeSetupId: employeeDocumentTypeSetupId,
          employeeId: employeeId),
      data: {
        // "EmployeeDocumentTypeMetaDataId": employeeDocumentMetaId,
        // "EmployeeDocumentTypeSetupId": employeeDocumentTypeSetupId,
        // "employeeId": employeeId,
        'base64':documents,
        "expiry_date":expiryDate == null ? null : "${expiryDate}T00:00:00Z",// expiryDate,
        "documentName":documentName
      },
    );
    print("Response ${response.toString()}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents updated;;;;;;;;;;;;;");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1;;;;;;;;;;;;;;;;;;");
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


Future<void> uploadHttpDocuments({
  required BuildContext context,
  required int employeeDocumentMetaId,
  required int employeeDocumentTypeSetupId,
  required int employeeId,
  required dynamic documentFile,
  required String documentName
}) async {
  try {
    final String token = await TokenManager.getAccessToken();
    var headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
};
    // File file = documentFile as File;
    // Future<XFile> convertHtmlFileToXFile(String assetPath) async {
    //   // Load the HTML file content from assets
    //   final String htmlContent = await rootBundle.loadString(assetPath);
    //
    //   // Get the temporary directory
    //   final Directory tempDir = await getTemporaryDirectory();
    //
    //   // Create a temporary file
    //   final File tempFile = File('${tempDir.path}/temp.html');
    //
    //   // Write the HTML content to the temporary file
    //   await tempFile.writeAsString(htmlContent);
    //
    //   // Convert the temporary file to an XFile
    //   final XFile xFile = XFile(tempFile.path);
    //
    //   return xFile;
    // }
    // await convertHtmlFileToXFile(file as String);
    // print("::::${file}");
    String base64Documents = base64Encode(documentFile);
    print("File :::${base64Documents}" );
    print("Token :: $token");
var request = http.MultipartRequest('POST',
    Uri.parse('${AppConfig.endpoint}/employee-documents/uploadDocumentbase64/$employeeDocumentMetaId/$employeeDocumentTypeSetupId/$employeeId'));
request.files.add(http.MultipartFile.fromString('base64', base64Documents));
// request.files.add(http.MultipartFile.f('file',documentFile.path) as http.MultipartFile);
request.headers.addAll(headers);

http.StreamedResponse response = await request.send();
    var responseData = await http.Response.fromStream(response);

print("Request ::: ${responseData.body}");
if (response.statusCode == 200 || response.statusCode == 201) {
  print("Uploded");
print(await response.stream.bytesToString());
}
else {
  print("Faild");
  print("${response.statusCode}");
print(response.reasonPhrase);
}
  } catch (e) {
    print("Error $e");
  }
}

/// Patch employee documents
Future<ApiData> patchEmployeeDocuments({
  required BuildContext context,
  required int empDocumentId,
  required int employeeDocumentMetaId,
  required int employeeDocumentTypeSetupId,
  required int employeeId,
  required String documentUrl,
  required String uploadDate,
  String? expiryDate
}) async {
  try {

    // print("File :::${documents}" );
    var response = await Api(context).patch(
      path: UploadDocumentRepository.PatchEmployeeDocumentGet(employeeDocumentId: empDocumentId),
      data: {
        "EmployeeDocumentTypeMetaDataId": employeeDocumentMetaId,
        "EmployeeDocumentTypeSetupId": employeeDocumentTypeSetupId,
        "employeeId": employeeId,
        "DocumentUrl": documentUrl,
        "UploadDate": uploadDate,
        "expiry_date": expiryDate == null ? null : "${expiryDate}T00:00:00Z",
      }
    );
    print("Response ${response.toString()}");
    print("empdocid: $employeeDocumentMetaId");
    print("documentSetupId: $employeeDocumentTypeSetupId");
    print("empdocid: $employeeId");
    print("ackProviderState.fileName: $documentUrl");
    print("ackProviderState.filePath: $uploadDate");
    print("expiryDate: $expiryDate");
    print("expiryDate: $expiryDate");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents Updated");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      print(response);
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

/// Patch employee documents
Future<EmployeeDocumentPrefillData> getPrefillEmployeeDocuments({
  required BuildContext context,
  required int empDocumentId,
}) async {
  var itemData;
  try {
    // String documents = await
    // AppFilePickerBase64.getEncodeBase64(
    //     bytes: documentFile);
    // print("File :::${documents}" );

    var response = await Api(context).get(
      path: UploadDocumentRepository.PatchEmployeeDocumentGet(
          employeeDocumentId: empDocumentId),
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents Get Prefill");
      // orgDocumentGet(context);
      itemData = EmployeeDocumentPrefillData(
          documentName: response.data['DocumentName'] ?? "--",
          expiry: response.data['expiry_date'] ?? "--",
          reminderThresold: response.data['ReminderThreshold'] ?? "--",
          idOfDocument: response.data['idOfDocument'] ?? "--",
          documentType: response.data['DocumentType'] ?? "--",
          empDocMetaDataId: response.data['EmployeeDocumentTypeMetaDataId'] ??
              0,
          empDocSetupId: response.data['EmployeeDocumentTypeSetupId'] ?? 0,
          documentUrl: response.data['DocumentUrl'] ?? "--",
          employeeDocumentId: response.data['employeeDocumentId'] ?? 0,
          employeeId: response.data['employeeId'] ?? 0);
    } else {
      print("Error 1");
      return itemData;
    }
    return itemData;
  } catch (e) {
    print("Error $e");
    return itemData;
  }
}

/// Delete employee documents
Future<ApiData> deleteEmployeeDocuments({
  required BuildContext context,
  required int empDocumentId,
}) async {
  try {
    // String documents = await
    // AppFilePickerBase64.getEncodeBase64(
    //     bytes: documentFile);
    // print("File :::${documents}" );
    var response = await Api(context).delete(
        path: UploadDocumentRepository.PatchEmployeeDocumentGet(employeeDocumentId: empDocumentId),
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Documents deleted");
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

