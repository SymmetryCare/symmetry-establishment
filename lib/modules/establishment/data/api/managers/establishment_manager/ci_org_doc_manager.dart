import 'package:flutter/cupertino.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_org_document.dart';

import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';

/// add corporate document POST
Future<ApiData> addCorporateDocumentPost({
  required BuildContext context,
  required String name,
  required int docTypeID,
  required int docSubTypeID,
  required String docCreated,
  required String url,
  required String expiryType,
  required String expiryDate,
  required String expiryReminder,
  required String officeId,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "doc_name": name,
      "document_type_id": docTypeID,
      "document_subtype_id": docSubTypeID,
      "doc_created_at": docCreated,
      "url": url,
      "expiry_type": expiryType,
      "expiry_date": expiryDate,
      "expiry_reminder": expiryReminder,
      "company_id": companyId,
      "office_id": officeId
    };
    print('Post ORG Doc$data');
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.addCorporateDocumentPost(),
        data: data);
    print('ORG Doc Post::::$response ');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Document addded ");
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

/// GET prefill corporate document
Future<CorporatePrefillDocumentData> getPrefillCorporateDocument(
    BuildContext context, int docID) async {
  var itemsList;
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getPrefillCorporateDocument(
            documentId: docID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Document type Response:::::${itemsList}");
      itemsList = CorporatePrefillDocumentData(
          message: response.statusMessage!,
          sucess: true,
          documentId: response.data['document_id'],
          documentTypeId: response.data['document_type_id'],
          documentSubTypeId: response.data['document_subtype_id'],
          docName: response.data['doc_name'],
          docCreated: response.data['doc_created_at'] ?? "",
          url: response.data['url'] ?? "",
          expiryType: response.data['expiry_type'],
          expiryDate: response.data['expiry_date'],
          expiryReminder: response.data['expiry_reminder'],
          companyId: response.data['company_id'],
          officeId: response.data['office_id'] ?? "",
      idOfDoc: response.data['idOfDocument'] ?? "");
    } else {
      print('Api Error');
      //return itemsList;
    }
    print("GetDcoType Prefill Response:::::${itemsList}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Update corporate document
Future<ApiData> updateCorporateDocumentPost({
  required BuildContext context,
  required int docId,
  required String name,
  required int docTypeID,
  required int docSubTypeID,
  required String docCreated,
  required String url,
  required String expiryType,
  required String expiryDate,
  required String expiryReminder,
  required String officeId,
  required String idOfDoc,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.updateCorporateDocumentPost(
            docID: docId),
        data: {
          "doc_name": name,
          "document_type_id": docTypeID,
          "document_subtype_id": docSubTypeID,
          "doc_created_at": docCreated,
          "url": url,
          "expiry_type": expiryType,
          "expiry_date": expiryDate,
          "expiry_reminder": expiryReminder,
          "company_id": companyId,
          "office_id": officeId,
          "idOfDocument": idOfDoc,
        });
    print('::::$response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Document addded ");
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

/// get
Future<List<IdentityData>> getOrgDocfetch(BuildContext context, int companyId,
    int docTypeID, int docSubTypeID, int pageNo, int rowsNO) async {
  List<IdentityData> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getCiOrgDLicense(
            companyId: companyId,
            docTypeID: docSubTypeID,
            docSubTypeID: docSubTypeID,
            pageNo: pageNo,
            rowsNo: rowsNO));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Org Document Tab bar response:::::${itemsList}");
      print("111");
      for (var item in response.data) {
        itemsList.add(
          IdentityData(
            docId: item["document_type_id"],
            companyId: item["company_id"],
            docSubId: item["document_sub_type_id"],
            pageNo: item["pageNbr"],
            rowsNo: item["NbrofRows"],
            sucess: true,
            message: response.statusMessage!,
          ),
        );
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('Org Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// document type GET
Future<List<DocumentTypeData>> documentTypeGet(
  BuildContext context,
) async {
  List<DocumentTypeData> itemsList = [];
  try {
    final response = await Api(context)
        .get(path: EstablishmentManagerRepository.documentTypeGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Document type Response:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(DocumentTypeData(
            docID: item["document_type_id"],
            docType: item["document_type"],
            sucess: true,
            message: response.statusMessage!));
      }
    } else {
      print('Api Error');
      //return itemsList;
    }
    print("Document type Response:::::${itemsList}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Identity document & sub doc type GET
Future<List<IdentityDocumentIdData>> identityDocumentTypeGet(
    BuildContext context, int docID) async {
  List<IdentityDocumentIdData> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.identityDocumentTypeGet(
            docId: docID));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Document type Response:::::${itemsList}");
      for (var item in response.data) {
        itemsList.add(IdentityDocumentIdData(
            docID: item["document_type_id"],
            docType: item["document_type"],
            subDocID: item["document_sub_type_id"],
            subDocType: item["document_sub_type"],
            message: response.statusMessage!,
            sucess: true));
      }
    } else {
      print('Api Error');
      //return itemsList;
    }
    print("GetDcoType Response:::::${itemsList}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
///post
Future<ApiData> addOrgCorporateDocumentPost({
  required BuildContext context,
  required String name,
  required int docTypeID,
  required int docSubTypeID,
  required String expiryType,
  required String expiryDate,
  required String expiryReminder,
  required String idOfDoc,

}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var data = {
      ///
      "doc_name": name,
      "document_type_id": docTypeID,
      "document_subtype_id": docSubTypeID,
      "expiry_type": expiryType,
      "expiry_date": expiryDate,
      "expiry_reminder": expiryReminder,
      "company_id": companyId,
      "idOfDocument": idOfDoc,
    };
    print('Org Corporate Doc $data');
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.addCorporateDocumentPost(),
        data: data);
    print('ORG Doc Post::::$response ');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Org Corporate Doc addded ");
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
