class EmployeeLegalDocument {
  final int EmployeeLegalDocumentId;
  final int employeeId;
  final String docName;
  final String docUrl;
  final int companyId;
  final String officeId;
  final String? approved;

  // Constructor to initialize the fields
  EmployeeLegalDocument({
    required this.EmployeeLegalDocumentId,
    required this.employeeId,
    required this.docName,
    required this.docUrl,
    required this.companyId,
    required this.officeId,
    this.approved,
  });
}