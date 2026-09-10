/// Models for the Company Identity document popups (corporate & compliance,
/// vendor contracts, policies & procedures).
///
/// Reconstructed from the call sites in
/// `modules/establishment/presentation/screens/company_identity` — the original
/// lived in the `prohealth` monolith and did not come across with the extracted
/// screens. Field names match what those screens read; the JSON keys in
/// `newpopup_manager.dart` follow the same casing the sibling establishment
/// managers use for the `/org-office-document` family.

/// One row in a document list (the table the popups page through).
class MCorporateComplianceModal {
  final int idOfDocument;
  final int orgOfficeDocumentId;
  final String docName;
  final String fileName;
  final String docurl;
  final String doccreatedAt;

  /// Prior versions of this document. Shape is whatever the API returns per
  /// entry; `ManageHistoryPopup` takes it as `List<dynamic>` and reads it
  /// dynamically, so it is not narrowed here.
  final List<dynamic> docHistory;

  final bool success;
  final String message;

  MCorporateComplianceModal({
    required this.idOfDocument,
    required this.orgOfficeDocumentId,
    required this.docName,
    required this.fileName,
    required this.docurl,
    required this.doccreatedAt,
    required this.docHistory,
    required this.success,
    required this.message,
  });
}

/// The single document behind the edit popup, fetched by
/// `getPrefillNewOrgOfficeDocument` so the form opens already filled in.
class MCorporateCompliancePreFillModal {
  final String idOfDocument;
  final int orgOfficeDocumentId;
  final int documentSetupId;
  final String docName;
  final String fileName;
  final String url;
  final String expType;
  final String expiry_date;
  final int? threshould;
  final bool isOthersDocs;

  final bool success;
  final String message;

  MCorporateCompliancePreFillModal({
    required this.idOfDocument,
    required this.orgOfficeDocumentId,
    required this.documentSetupId,
    required this.docName,
    required this.fileName,
    required this.url,
    required this.expType,
    required this.expiry_date,
    required this.threshould,
    required this.isOthersDocs,
    required this.success,
    required this.message,
  });
}

/// A row of `/org-document-setup/ByDocumentTypeAndSubType/...` — the document
/// types selectable in the "add document" popup's dropdown.
class TypeofDocpopup {
  final int orgDocumentSetupid;
  final String docname;

  /// Free-text id shown beside the name; the popup copies it into the form.
  final String idOfDocument;

  /// "Issuer Expiry" / "Year" / "Month" / ... — drives whether the popup shows
  /// the expiry-date field.
  final String expirytype;

  final bool success;
  final String message;

  TypeofDocpopup({
    required this.orgDocumentSetupid,
    required this.docname,
    required this.idOfDocument,
    required this.expirytype,
    required this.success,
    required this.message,
  });
}
