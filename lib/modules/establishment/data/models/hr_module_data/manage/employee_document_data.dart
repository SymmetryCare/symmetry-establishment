class EmployeeDocumentPrefillData {
  final String documentName;
  final String expiry;
  final String reminderThresold;
  final String idOfDocument;
  final String documentType;
  final int empDocMetaDataId;
  final int empDocSetupId;
  final String documentUrl;
  final int employeeDocumentId;
  final int employeeId;
  EmployeeDocumentPrefillData(
      {required this.documentName,
      required this.expiry,
      required this.reminderThresold,
      required this.idOfDocument,
      required this.documentType,
      required this.empDocMetaDataId,
      required this.empDocSetupId,
      required this.documentUrl,
      required this.employeeDocumentId,
      required this.employeeId});
}
