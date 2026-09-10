class ManageCCDoc {
  final int docId;
  final int documentTypeId;
  final int documentSubTypeId;
  final String? docname;
  final String doccreatedAt;
  final String url;
  final String? expiryType;
  final String? expiryDate;
  final String expiryReminder;
  final int companyId;
  final String officeId;
  final String idOfDoc;
  final bool sucess;
  final String message;

  ManageCCDoc({required this.idOfDoc,
      required this.documentTypeId,
        required this.documentSubTypeId,
        required this.url,
        required this.expiryReminder,
        required this.companyId,
        required this.officeId,
        required this.sucess,
        required this.message,
        required this.doccreatedAt,
        required this.docId,
        this.docname,
        this.expiryType,
        this.expiryDate,
      });
}


///prefill
class CorporatePrefillCCVVPP {
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
  CorporatePrefillCCVVPP({
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

