
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_org_document.dart';

///old

Future<List<CiOrgDocumentCC>> getORGDoc(BuildContext context,
    int docTypeID, int docSubTypeID, int pageNo, int rowsNO) async {
  List<CiOrgDocumentCC> itemsList = [];
  try {
    final companyId =await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getCiOrgDLicense(
          companyId: companyId,
          docTypeID: docTypeID,
          docSubTypeID: docSubTypeID,
          pageNo: pageNo,
          rowsNo: rowsNO, ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("ORG Doc response:::::${itemsList}");
      print("111");
      for (var item in response.data["DocumentList"]) {
        itemsList.add(
          CiOrgDocumentCC(
            docId: item["document_id"],
            documentTypeId: item["document_type_id"],
            documentSubTypeId: item["document_subtype_id"],
            name: item["doc_name"] ?? "",
            createdAt: item["doc_created_at"] ?? "--",
            url: item["url"] ?? "--",
            expiryType: item["expiry_type"],
            expirtDate: item["expiry_date"],
            expirtReminder: item["expiry_reminder"] ?? "--",
            companyId: companyId,
            officeId: item["office_id"] ?? "--",
            idOfDocument: item["idOfDocument"] ?? "--",
            sucess: true,
            message: response.statusMessage!,
          ),
        );
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('Manage CC Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///post api
Future<ApiData> addOrgDocumentPost(
    BuildContext context,
    String expiryDate,
    String docName,
    String expiryType,
    String expiryReminder
    ) async {
  try {
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.
        addOrgDocumentPost(), data: {
          'doc_name':docName,
          'expiry_type':expiryType,
          'expiry_date':expiryDate,
          'expiry_reminder':expiryReminder
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Added request");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///patch
Future<ApiData> updateOrgDocument(
    BuildContext context,
    int docId,
    String docName,
    String docDate,
    String expiryType,
    String expiryReminder) async{
  try {
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.
        updatePrefillPatchCCVCPP(docId: docId),
        data: {
      'document_id':docId,
      "doc_name": docName,
      "expiry_type": expiryType,
      "expiry_date": docDate,
      "expiry_reminder": expiryReminder
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Updated request");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


///delete
Future<ApiData> deleteDocument(
    BuildContext context, int docId) async {
  try {
    var response = await Api(context).delete(
        path: EstablishmentManagerRepository.updatePrefillPatchCCVCPP(docId: docId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Deleted Document :::${docId}");
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
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}