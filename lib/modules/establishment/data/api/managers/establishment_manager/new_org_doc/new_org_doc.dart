
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';

import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
///post new orf
Future<ApiData> addNewOrgDocumentPost({
  required BuildContext context,
  required String docName,
  required int docTypeID,
  required int docSubTypeID,
  required int threshold,
  required String expiryType,
  required String? expiryDate,
  required String expiryReminder,
  required String idOfDoc,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "document_type_id": docTypeID,
      "document_subtype_id": docSubTypeID,
      "doc_name": docName,
      "expiry_type": expiryType,
      "threshold": threshold,
      "expiry_date": expiryDate,
      "expiry_reminder": expiryReminder,
      "company_id": companyId,
      "idOfDocument": idOfDoc,
    };

    print('New Org Corporate Doc $data');
    var response = await Api(context).post(
        path: EstablishmentManagerRepository.addNewDocumentPost(),
        data: data);

    print('New ORG Doc Post::::$response ');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("New Org Corporate Doc added ");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    }
    else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'][0]);
    }
  } catch (e) {
    print("Error $e");
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// get all
Future<List<NewOrgDocument>> getNewOrgDocument(BuildContext context,) async {
  List<NewOrgDocument> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.newOrgDocGet());
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Org Document Tab bar response:::::${itemsList}");
      print("111");
      for (var item in response.data) {
        itemsList.add(
        NewOrgDocument(
            orgDocumentSetupid: item['orgDocumentSetupid'],
            documentTypeId: item['document_type_id'],
            documentSubTypeId: item['document_subtype_id'],
            docName: item['doc_name'],
            expiryType: item['expiry_type'],
            threshold: item['threshold'],
            expiryDate: item['expiry_date'] ?? "",
            expiryReminder: item['expiry_reminder'],
            companyId: companyId,
            idOfDocument: item['idOfDocument']));
      }
      // print("Org Document response:::::${itemsList}");
    } else {
      print('New Org Api Error');
      return itemsList;
    }
    // print("Org response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///get doc wise
Future<List<NewOrgDocument>> getNewOrgDocfetch(BuildContext context,
    int docTypeID, int docSubTypeID, int pageNo, int rowsNo) async {
  List<NewOrgDocument> itemsList = [];
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.newOrgDocGetTypeWise(
            DocumentTypeId: docTypeID,
            DocumentSubTypeId: docSubTypeID,
            pageNbr: pageNo,
            NbrofRows: rowsNo));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Org Document Tab bar response:::::${itemsList}");
      print("111");
      for (var item in response.data) {
        itemsList.add(
          NewOrgDocument(
              orgDocumentSetupid: item['orgDocumentSetupid'],
              documentTypeId: item['document_type_id'],
              documentSubTypeId: item['document_subtype_id'],
              docName: item['doc_name'],
              expiryType: item['expiry_type'],
              threshold: item['threshold'],
              expiryDate: item['expiry_date'] ?? "",
              expiryReminder: item['expiry_reminder'] ,
              companyId: companyId,
              idOfDocument: item['idOfDocument']),
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

/// GET prefill corporate document
Future<NewOrgDocument> getPrefillNewOrgDocument(
    BuildContext context, int orgDocumentSetupid) async {
  var itemsList;
  try {
    final companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.updatePrefillPatchNewOrgDoc(
            orgDocumentSetupid: orgDocumentSetupid));
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print("Document type Response:::::${itemsList}");
      itemsList = NewOrgDocument(
          orgDocumentSetupid: response.data['orgDocumentSetupid'],
          documentTypeId: response.data['document_type_id'],
          documentSubTypeId: response.data['document_subtype_id'],
          docName: response.data['doc_name'],
          expiryType: response.data['expiry_type'],
          threshold: response.data['threshold'] ?? 0,
          expiryDate: response.data['expiry_date'] ?? "",
          expiryReminder: response.data['expiry_reminder'],
          companyId: companyId,
          idOfDocument: response.data['idOfDocument'] ?? "");
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
Future<ApiData> updateNewOrgDocumentPatch({
  required BuildContext context,
  required int orgDocumentSetupid,
  required int docTypeID,
  required int docSubTypeID,
  required String docName,
  required String expiryType,
  required int threshold,
  required String? expiryDate,
  required String expiryReminder,
  required String idOfDoc,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();
    var response = await Api(context).patch(
        path: EstablishmentManagerRepository.updatePrefillPatchNewOrgDoc(
            orgDocumentSetupid: orgDocumentSetupid),
        data: {
          "document_type_id": docTypeID,
          "document_subtype_id": docSubTypeID,
          "doc_name": docName,
          "expiry_type": expiryType,
          "threshold":threshold,
          "expiry_date": expiryDate,
          "expiry_reminder": expiryReminder,
          "company_id": companyId,
          "idOfDocument": idOfDoc,
        });
    print('::::$response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Document Patch new org");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'][0]);
    }
  } catch (e) {
    print("Error $e");
    print("Error 2");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///delete
Future<ApiData> deleteNewOrgDoc(
    BuildContext context, int orgDocumentSetupid) async {
  try {
    var response = await Api(context).delete(
        path: EstablishmentManagerRepository.updatePrefillPatchNewOrgDoc(orgDocumentSetupid: orgDocumentSetupid));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Deleted Document :::${orgDocumentSetupid}");
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