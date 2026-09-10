class NewOrgDocument {
  final int orgDocumentSetupid;
  final int documentTypeId;
  final int documentSubTypeId;
  final String docName;
  final String expiryType;
  final int threshold;
  final String expiryDate;
  final String expiryReminder;
  final int companyId;
  final String idOfDocument;

  NewOrgDocument(
      {required this.orgDocumentSetupid,
        required this.documentTypeId,
        required this.documentSubTypeId,
        required this.docName,
        required this.expiryType,
        required this.threshold,
        required this.expiryDate,
        required this.expiryReminder,
        required this.companyId,
        required this.idOfDocument,
        });
}
