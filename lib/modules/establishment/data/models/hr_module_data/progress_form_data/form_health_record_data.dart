class HREmployeeDocumentModal {
  final String docName;
  final String expiry;
  final String reminderThreshold;
  final int employeeDocTypesetupId;
  final int employeeDocTypeMetaId;
  final bool sucess;
  final String message;

  HREmployeeDocumentModal({
    required this.employeeDocTypeMetaId,
    required this.employeeDocTypesetupId,
    required this.docName,
    required this.expiry,
    required this.reminderThreshold,
    required this.sucess,
    required this.message,
  });
}