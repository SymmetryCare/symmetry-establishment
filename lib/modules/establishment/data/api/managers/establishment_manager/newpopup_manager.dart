import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/establishment_manager/establishment_repository.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';

/// Company Identity document popups — list, prefill and delete.
///
/// Paths, keys and the upload follow the original prohealth code, which
/// survives in symmetry-emr's copy of this manager (the backend's
/// org-document-setup / org-office-document use snake_case:
/// orgDocumentSetupid, doc_name, idOfDocument, expiry_date, office_id, …).
/// An earlier reconstruction had guessed PascalCase keys and other routes,
/// so the type dropdown stayed empty and uploads never saved.
///
/// Originally reconstructed from the call sites in
/// `modules/establishment/presentation/screens/company_identity`; the original
/// lived in the `prohealth` monolith and did not come across with the extracted
/// screens. The endpoints come from
/// [EstablishmentManagerRepository], which the extraction did carry over, and
/// the error handling follows the sibling managers in this directory: log and
/// return an empty result rather than throw, because the call sites feed these
/// straight into a `StreamBuilder` / `FutureBuilder`.

String _s(dynamic v) => v == null ? '' : '$v';
int _i(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

/// An expiry date, or null for a document that does not expire (the API
/// refuses an empty string as a date).
String? _dateOrNull(String? date) =>
    date == null || date.trim().isEmpty ? null : date;

/// What the server said went wrong (its `message`), not Dio's long text.
ApiData _failed(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    final message = data is Map ? data['message'] : null;
    return ApiData(
      success: false,
      message: message is List
          ? message.join(', ')
          : (message?.toString() ?? 'Something went wrong. Please try again.'),
      statusCode: e.response?.statusCode ?? 0,
    );
  }
  return ApiData(success: false, message: 'Something went wrong. Please try again.', statusCode: 0);
}

/// GET org-office-document/ByDocumentTypeAndSubTypePageWise/{type}/{sub}/{office}/…
/// — the rows behind a document tab (corporate & compliance, vendor
/// contracts, policies & procedures). identity/GetDocumentListByCompanyAndOffice,
/// used before, reads another table, so uploaded documents never showed.
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
    // The screens page locally, so fetch them all.
    final response = await Api(context).get(
      path: EstablishmentManagerRepository.getListMCorporateCompliance(
        DocumentTypeId: docTypeId,
        DocumentSubTypeId: subDocTypeId,
        officeID: officeId,
        pageNbr: 1,
        NbrofRows: 99999,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(
          MCorporateComplianceModal(
            idOfDocument: _s(item['idOfDocument']),
            orgOfficeDocumentId: _i(item['orgOfficeDocumentId']),
            docName: _s(item['doc_name']),
            fileName: _s(item['file_name']),
            docurl: _s(item['url']),
            doccreatedAt: _s(item['doc_created_at']),
            docHistory: (item['docHistory'] ?? []) as List<dynamic>,
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
        idOfDocument: _s(item['idOfDocument']),
        orgOfficeDocumentId: item['orgOfficeDocumentId'] ?? orgOfficeDocumentId,
        documentSetupId: _i(item['orgDocumentSetupid']),
        docName: _s(item['doc_name']),
        fileName: _s(item['file_name']),
        url: _s(item['url']),
        expType: _s(item['expiry_type']),
        expiry_date: _s(item['expiry_date']).replaceAll('Z', ''),
        threshould: _i(item['threshold']),
        isOthersDocs: item['isOthersDocs'] == true,
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
    return _failed(e);
  }
}

/// GET /org-document-setup/ByDocumentTypeAndSubType/{typeId}/{subTypeId}
///
/// Fills the document-type dropdown in the "add document" popup with the
/// company's document definitions (Establishment → Org Document →
/// Document Definition) of this type and sub-type.
Future<List<TypeofDocpopup>> getTypeofDoc(
  BuildContext context,
  int docTypeId,
  int docSubTypeId,
) async {
  List<TypeofDocpopup> itemsList = [];
  try {
    final response = await Api(context).get(
        path: EstablishmentManagerRepository.getdocPayratesdropdown(
            DocumentTypeId: docTypeId, DocumentSubTypeId: docSubTypeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      final List items = data is List ? data : (data['data'] ?? []) as List;
      for (var item in items) {
        itemsList.add(TypeofDocpopup(
          orgDocumentSetupid: _i(item['orgDocumentSetupid']),
          docname: _s(item['doc_name']),
          idOfDocument: _s(item['idOfDocument']),
          expirytype: _s(item['expiry_type']),
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
        "company_id": companyId,
        "office_id": officeId,
        "orgDocumentSetupid": orgDocumentSetupid,
        "idOfDocument": idOfDocument,
        "expiry_date": _dateOrNull(expiryDate),
        "doc_created_at": docCreated,
        "url": url,
        "file_name": fileName ?? '',
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: response.data is Map
          ? (response.data['orgOfficeDocumentId'] as int?)
          : null,
    );
  } catch (e) {
    print("addOrgDocPPPost error $e");
    return _failed(e);
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
        "company_id": companyId,
        "office_id": officeId,
        "document_type_id": docTypeid,
        "document_subtype_id": docSubTypeid,
        "doc_name": documentName,
        "expiry_type": expiryType,
        "threshold": threshold,
        "expiry_date": _dateOrNull(expiryDate),
        "expiry_reminder": expiryReminder,
        "idOfDocument": idOfDoc,
        "doc_created_at": docCreated,
        "file_name": fileName ?? '',
        "url": url,
      },
    );
    return ApiData(
      success: response.statusCode == 200 || response.statusCode == 201,
      message: response.statusMessage ?? '',
      statusCode: response.statusCode ?? 0,
      data: response.data,
      orgOfficeDocumentId: response.data is Map
          ? (response.data['orgOfficeDocumentId'] as int?)
          : null,
    );
  } catch (e) {
    print("addOtherOfficeDocPost error $e");
    return _failed(e);
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
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.patchDocOrg(orgDocID: orgDocId),
      data: {
        "company_id": companyId,
        "office_id": officeid,
        "orgDocumentSetupid": orgDocumentSetupid,
        "idOfDocument": idOfDocument,
        "expiry_date": _dateOrNull(expiryDate),
        "doc_created_at": docCreatedat,
        "url": url,
        "file_name": fileName ?? '',
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
    return _failed(e);
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
    final int companyId = await TokenManager.getCompanyId();
    final response = await Api(context).patch(
      path: EstablishmentManagerRepository.patchOtherOrg(
          orgOfficeDocumentId: orgOfficeDocumentId),
      data: {
        "company_id": companyId,
        "office_id": officeid,
        "orgDocumentSetupid": orgDocumentSetupid,
        "document_type_id": docTypeID,
        "document_subtype_id": docSubTypeID,
        "doc_name": docName,
        "expiry_type": expiryType,
        "threshold": threshold,
        "expiry_date": _dateOrNull(expiryDate),
        "expiry_reminder": expiryReminder,
        "idOfDocument": idOfDocument,
        "doc_created_at": docCreatedat,
        "url": url,
        "file_name": fileName ?? '',
        "isOthersDocs": true,
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
    return _failed(e);
  }
}

/// POST /org-office-document/attach-documentbase64/{orgOfficeDocumentId} —
/// the file itself as base64, once the row above exists and returned its id.
Future<ApiData> uploadDocumentsoffice({
  required BuildContext context,
  required dynamic documentFile,
  required int orgOfficeDocumentId,
  required String? fileName,
}) async {
  try {
    final String base64 =
        await AppFilePickerBase64.getEncodeBase64(bytes: documentFile);
    final response = await Api(context).post(
      path: EstablishmentManagerRepository.uploadedocOffice(
          orgOfficeDocumentId: orgOfficeDocumentId),
      data: {'base64String': base64, 'file_name': fileName ?? 'document'},
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
    return _failed(e);
  }
}
