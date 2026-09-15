

class LicensesDataForm {
  final int licenseId;
  final String country;
  final int employeeId;
  final String? expDate;
  final String issueDate;
  final String licenseUrl;
  final String licensure;
  final String licenseNumber;
  final String org;
  final String documentType;
  final String documentName;
  bool? approved;

  LicensesDataForm({
    required this.licenseId,
    required this.country,
    required this.employeeId,
    required this.expDate,
    required this.issueDate,
    required this.licenseUrl,
    required this.licensure,
    required this.licenseNumber,
    required this.org,
    required this.documentType,
    required this.documentName,
    this.approved,
  });
}
