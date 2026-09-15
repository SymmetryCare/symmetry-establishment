class QulificationLicensesData {
  final int licenseId;
  final String country;
  final int employeeId;
  final String expData;
  final String issueDate;
  final String licenseUrl;
  final String licenure;
  final String licenseNumber;
  final String org;
  final String documentType;
   bool? approved;
  final bool sucess;
  final String message;
  QulificationLicensesData(
      {required this.licenseId,
      required this.country,
      required this.employeeId,
      required this.expData,
      required this.issueDate,
      required this.licenseUrl,
      required this.licenure,
      required this.licenseNumber,
      required this.org,
      required this.documentType,
      required this.approved,
      required this.sucess,
      required this.message});
}

class QulificationLicensesPreFillData {
  final int licenseId;
  final String country;
  final int employeeId;
  final String expData;
  final String issueDate;
  final String licenseUrl;
  final String licenure;
  final String licenseNumber;
  final String org;
  final String documentType;
  bool? approved;
  final bool sucess;
  final String message;
  final String documentName;
  QulificationLicensesPreFillData(
      {
        required this.documentName,
        required this.licenseId,
        required this.country,
        required this.employeeId,
        required this.expData,
        required this.issueDate,
        required this.licenseUrl,
        required this.licenure,
        required this.licenseNumber,
        required this.org,
        required this.documentType,
        required this.approved,
        required this.sucess,
        required this.message});
}

class SelectDocuments {
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
  final String idOfDocument;
  SelectDocuments({
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
    required this.idOfDocument
  });
}

class QulificationLicensesFilteredData {
  final int licenseId;
  final String country;
  final int employeeId;
  final String expData;
  final String issueDate;
  final String licenseUrl;
  final String licenure;
  final String licenseNumber;
  final String org;
  final String documentType;
  final String status;
  bool? approved;
  final bool sucess;
  final String message;
  QulificationLicensesFilteredData(
      {
        required this.licenseId,
        required this.status,
        required this.country,
        required this.employeeId,
        required this.expData,
        required this.issueDate,
        required this.licenseUrl,
        required this.licenure,
        required this.licenseNumber,
        required this.org,
        required this.documentType,
        required this.approved,
        required this.sucess,
        required this.message});
}
