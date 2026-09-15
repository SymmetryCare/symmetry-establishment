import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';

/// Company Identity document popups — list, prefill and delete.
///
/// Reconstructed from the call sites in
/// `modules/establishment/presentation/screens/company_identity`; the original
/// lived in the `prohealth` monolith and did not come across with the extracted
/// screens. The endpoints come from
/// [EstablishmentManagerRepository], which the extraction did carry over, and
/// the error handling follows the sibling managers in this directory: log and
/// return an empty result rather than throw, because the call sites feed these
/// straight into a `StreamBuilder` / `FutureBuilder`.

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

/// GET identity/GetDocumentListByCompanyAndOffice — the rows behind a document
/// tab (corporate & compliance, vendor contracts, policies & procedures).
Future<List<MCorporateComplianceModal>> getListMCorporateCompliancefetch(
  BuildContext context,
  int docTypeId,
  String officeId,
  int subDocTypeId,
  int pageNo,
  int rowNo,
) async {
  List<MCorporateComplianceModal> itemsList = [];
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).get(
      path: EstablishmentManagerRepository.corporateGetListbyCompany(
        companyId: companyId,
        officeId: officeId,
        docTypeID: docTypeId,
        docSubTypeID: subDocTypeId,
        pageNo: pageNo,
        rowsNo: rowNo,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(
          MCorporateComplianceModal(
            idOfDocument: item['DocumentId'] ?? item['documentId'] ?? 0,
            orgOfficeDocumentId: item['OrgOfficeDocumentId'] ??
                item['orgOfficeDocumentId'] ??
                0,
            docName: item['DocumentName'] ?? item['docName'] ?? '',
            fileName: item['FileName'] ?? item['fileName'] ?? '',
            docurl: item['DocumentUrl'] ?? item['url'] ?? '',
            doccreatedAt: '${item['CreatedAt'] ?? item['createdAt'] ?? ''}',
            docHistory: (item['DocumentHistory'] ?? item['docHistory'] ?? [])
                as List<dynamic>,
            success: true,
            message: response.statusMessage ?? '',
          ),
        );
      }
    }
    return itemsList;
  } catch (e) {
    print("getListMCorporateCompliancefetch error $e");
    return itemsList;
  }
}

/// GET org-office-document/{orgDocID} — the document behind the edit popup.
Future<MCorporateCompliancePreFillModal> getPrefillNewOrgOfficeDocument(
  BuildContext context,
  int orgOfficeDocumentId,
) async {
  MCorporateCompliancePreFillModal empty = MCorporateCompliancePreFillModal(
    idOfDocument: '',
    orgOfficeDocumentId: orgOfficeDocumentId,
    documentSetupId: 0,
    docName: '',
    fileName: '',
    url: '',
    expType: '',
    expiry_date: '',
    threshould: null,
    isOthersDocs: false,
    success: false,
    message: '',
  );
  try {
    final response = await Api(context).get(
      path: EstablishmentManagerRepository.prefillDocOfficeOrg(
          orgDocID: orgOfficeDocumentId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data is List
          ? (response.data as List).first
          : response.data;
      return MCorporateCompliancePreFillModal(
        idOfDocument: _s(item['DocumentId'] ?? item['documentId']),
        orgOfficeDocumentId:
            item['OrgOfficeDocumentId'] ?? orgOfficeDocumentId,
        documentSetupId:
            item['OrgDocumentSetupId'] ?? item['documentSetupId'] ?? 0,
        docName: item['DocumentName'] ?? item['docName'] ?? '',
        fileName: item['FileName'] ?? item['fileName'] ?? '',
        url: item['DocumentUrl'] ?? item['url'] ?? '',
        expType: item['ExpiryType'] ?? item['expType'] ?? '',
        expiry_date: '${item['ExpiryDate'] ?? item['expiry_date'] ?? ''}',
        threshould: _i(item['Threshold'] ?? item['threshould']),
        isOthersDocs: item['IsOthersDocs'] ?? item['isOthersDocs'] ?? false,
        success: true,
        message: response.statusMessage ?? '',
      );
    }
    return empty;
  } catch (e) {
    print("getPrefillNewOrgOfficeDocument error $e");
    return empty;
  }
}

/// DELETE org-office-document/{orgDocID}.
Future<ApiData> deleteOrgDoc({
  required BuildContext context,
  required int orgDocId,
}) async {
  try {
    final response = await Api(context).delete(
      path: EstablishmentManagerRepository.deleteDocOrg(orgDocID: orgDocId),
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );
  } catch (e) {
    print("deleteOrgDoc error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// GET /org-document-setup/ByDocumentTypeAndSubType/{typeId}/{subTypeId}/{page}/{rows}
///
/// Fills the document-type dropdown in the "add document" popup.
Future<List<TypeofDocpopup>> getTypeofDoc(
  BuildContext context,
  int docTypeId,
  int docSubTypeId,
) async {
  List<TypeofDocpopup> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.newOrgDocGetTypeWise(
            DocumentTypeId: docTypeId,
            DocumentSubTypeId: docSubTypeId,
            pageNbr: 1,
            NbrofRows: 9999));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(TypeofDocpopup(
          orgDocumentSetupid: _i(item['OrgDocumentSetupId']),
          docname: _s(item['DocumentName'] ?? item['DocName']),
          idOfDocument: _s(item['DocumentId'] ?? item['IdOfDocument']),
          expirytype: _s(item['ExpiryType']),
          success: true,
          message: response.statusMessage ?? '',
        ));
      }
    }
    return itemsList;
  } catch (e) {
    print("getTypeofDoc error $e");
    return itemsList;
  }
}

// ── org office document writes ─────────────────────────────────────────────
//
// Add/update for the Company Identity document popups. Reconstructed from the
// call sites in `upload_add_popup.dart` / `upload_edit_popup.dart`; endpoints
// come from [EstablishmentManagerRepository]. The "others" variants hit the
// `/others` sub-resource, which carries the free-text document name, expiry
// type and threshold that a set-up-backed document takes from its setup row.

/// POST /org-office-document/add — a document backed by an org-document setup.
Future<ApiData> addOrgDocPPPost({
  required BuildContext context,
  required int orgDocumentSetupid,
  required String idOfDocument,
  required String? expiryDate,
  required String docCreated,
  required String url,
  required String officeId,
  required String? fileName,
}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.addDocOrg(),
      data: {
        "CompanyId": companyId,
        "OfficeId": officeId,
        "OrgDocumentSetupId": orgDocumentSetupid,
        "DocumentId": idOfDocument,
        "ExpiryDate": expiryDate ?? '',
        "CreatedAt": docCreated,
        "DocumentUrl": url,
        "FileName": fileName ?? '',
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: response.data is Map
          ? (response.data['OrgOfficeDocumentId'] as int?)
          : null,
    );
  } catch (e) {
    print("addOrgDocPPPost error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// POST /org-office-document/others/add — an ad-hoc ("Other") document.
Future<ApiData> addOtherOfficeDocPost({
  required BuildContext context,
  required int docTypeid,
  required int docSubTypeid,
  required String documentName,
  required String expiryType,
  required int threshold,
  required String? expiryDate,
  required String expiryReminder,
  required String idOfDoc,
  required String docCreated,
  required String? fileName,
  required String url,
  required String officeId,
}) async {
  try {
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.addOtherDoc(),
      data: {
        "CompanyId": companyId,
        "OfficeId": officeId,
        "DocumentTypeId": docTypeid,
        "DocumentSubTypeId": docSubTypeid,
        "DocumentName": documentName,
        "ExpiryType": expiryType,
        "Threshold": threshold,
        "ExpiryDate": expiryDate ?? '',
        "ExpiryReminder": expiryReminder,
        "DocumentId": idOfDoc,
        "CreatedAt": docCreated,
        "FileName": fileName ?? '',
        "DocumentUrl": url,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: response.data is Map
          ? (response.data['OrgOfficeDocumentId'] as int?)
          : null,
    );
  } catch (e) {
    print("addOtherOfficeDocPost error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// PATCH /org-office-document/{orgDocID}
Future<ApiData> updateOrgDoc({
  required BuildContext context,
  required int orgDocId,
  required int orgDocumentSetupid,
  required String idOfDocument,
  required String? expiryDate,
  required String docCreatedat,
  required String url,
  required String? fileName,
  required String officeid,
}) async {
  try {
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.patchDocOrg(orgDocID: orgDocId),
      data: {
        "OfficeId": officeid,
        "OrgDocumentSetupId": orgDocumentSetupid,
        "DocumentId": idOfDocument,
        "ExpiryDate": expiryDate ?? '',
        "CreatedAt": docCreatedat,
        "DocumentUrl": url,
        "FileName": fileName ?? '',
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: orgDocId,
    );
  } catch (e) {
    print("updateOrgDoc error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// PATCH /org-office-document/others/{orgOfficeDocumentId}
Future<ApiData> updateOtherDoc({
  required BuildContext context,
  required int orgOfficeDocumentId,
  required int orgDocumentSetupid,
  required int docTypeID,
  required int docSubTypeID,
  required String docName,
  required String expiryType,
  required int threshold,
  required String? expiryDate,
  required String expiryReminder,
  required String idOfDocument,
  required String docCreatedat,
  required String url,
  required String officeid,
  required String? fileName,
}) async {
  try {
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.patchOtherOrg(
          orgOfficeDocumentId: orgOfficeDocumentId),
      data: {
        "OfficeId": officeid,
        "OrgDocumentSetupId": orgDocumentSetupid,
        "DocumentTypeId": docTypeID,
        "DocumentSubTypeId": docSubTypeID,
        "DocumentName": docName,
        "ExpiryType": expiryType,
        "Threshold": threshold,
        "ExpiryDate": expiryDate ?? '',
        "ExpiryReminder": expiryReminder,
        "DocumentId": idOfDocument,
        "CreatedAt": docCreatedat,
        "DocumentUrl": url,
        "FileName": fileName ?? '',
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: orgOfficeDocumentId,
    );
  } catch (e) {
    print("updateOtherDoc error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}

/// POST (multipart) /office-document/{orgOfficeDocumentId} — upload the file
/// itself, once the metadata row above exists and returned its id.
Future<ApiData> uploadDocumentsoffice({
  required BuildContext context,
  required dynamic documentFile,
  required int orgOfficeDocumentId,
  required String? fileName,
}) async {
  try {
    final formData = FormData.fromMap({
      'file': documentFile is MultipartFile
          ? documentFile
          : MultipartFile.fromBytes(
              documentFile as List<int>,
              filename: fileName ?? 'document',
            ),
    });
    final response = await Api(context).postWithFormData(
      path: EstablishmentManagerRepository.uploadedocOffice(
          orgOfficeDocumentId: orgOfficeDocumentId),
      formData: formData,
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: orgOfficeDocumentId,
    );
  } catch (e) {
    print("uploadDocumentsoffice error $e");
    return ApiData(success: false, message: '$e', statusCode: 0);
  }
}
