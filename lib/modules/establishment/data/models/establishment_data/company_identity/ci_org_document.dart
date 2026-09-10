class CiOrgDocumentCC {
  final int docId;
  final int documentTypeId;
  final int documentSubTypeId;
  final String name;
  final String createdAt;
  final String url;
  final String? expiryType;
  final String? expirtDate;
  final String expirtReminder;
  final int companyId;
  final String officeId;
  final String idOfDocument;
  final bool sucess;
  final String message;


  CiOrgDocumentCC(
      {required this.documentTypeId,
      required this.documentSubTypeId,
      required this.url,
      required this.expirtReminder,
      required this.companyId,
      required this.officeId,
      required this.sucess,
      required this.message,
      required this.createdAt,
      required this.docId,
      required this.name,
        required this.idOfDocument,
      this.expiryType,
      this.expirtDate});
}

class OrgDocModal {
  final int? docId;
  final String? name;
  final String? expiry;
  final String? reminderThreshold;
  final String? createdAt;
  final bool sucess;
  final String message;

  OrgDocModal(
      {required this.sucess,
      required this.message,
      this.createdAt,
      this.docId,
      this.name,
      this.expiry,
      this.reminderThreshold});
}

class IdentityData {
  final int companyId;
  final int docId;
  final int docSubId;
  final int pageNo;
  final int rowsNo;
  final bool sucess;
  final String message;

  IdentityData({
    required this.sucess,
    required this.message,
    required this.companyId,
    required this.docId,
    required this.docSubId,
    required this.pageNo,
    required this.rowsNo,
  });
}

/// document type
class DocumentTypeData {
  final int docID;
  final String docType;
  final bool sucess;
  final String message;
  DocumentTypeData({
    required this.docID,
    required this.docType,
    required this.sucess,
    required this.message,
  });
}

/// Get prefill corporate document
class CorporatePrefillDocumentData {
  final int documentId;
  final int documentTypeId;
  final int documentSubTypeId;
  final String docName;
  final String docCreated;
  final String url;
  final String expiryType;
  final String expiryDate;
  final String expiryReminder;
  final int companyId;
  final String officeId;
  final String idOfDoc;
  final bool sucess;
  final String message;
  CorporatePrefillDocumentData({
    required this.documentId,
    required this.documentTypeId,
    required this.documentSubTypeId,
    required this.docName,
    required this.docCreated,
    required this.url,
    required this.expiryType,
    required this.expiryDate,
    required this.expiryReminder,
    required this.companyId,
    required this.officeId,
    required this.idOfDoc,
    required this.sucess,
    required this.message,
  });
}

/// identity document type
class IdentityDocumentIdData {
  final int docID;
  final String docType;
  final int subDocID;
  final String subDocType;
  final bool sucess;
  final String message;
  IdentityDocumentIdData({
    required this.docID,
    required this.docType,
    required this.subDocID,
    required this.subDocType,
    required this.sucess,
    required this.message,
  });
}
