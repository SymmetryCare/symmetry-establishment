class ClinicalLicenseDataModel{
  final int drivingLicenseId;
  final String idOFDocument;
  final String createdAt;
  final String expDate;
  final String url;
  final int companyId;
  final String officeId;
  final String fileName;
  bool? approve;
  final int employeeId;
  ClinicalLicenseDataModel({required this.drivingLicenseId, required this.idOFDocument, required this.createdAt,
    required this.expDate, required this.url, required this.companyId, required this.officeId, required this.fileName,
     this.approve, required this.employeeId});
}
class ClinicalLicensePrefillDataModel{
  final int drivingLicenseId;
  final String idOFDocument;
  final String createdAt;
  final String expDate;
  final String url;
  final int companyId;
  final String officeId;
  final String fileName;
  bool? approve;
  final int employeeId;
  ClinicalLicensePrefillDataModel({required this.drivingLicenseId, required this.idOFDocument, required this.createdAt,
    required this.expDate, required this.url, required this.companyId, required this.officeId, required this.fileName,
    this.approve, required this.employeeId});
}


class PractitionerLicenseDataModel{
  final int practitionerLicenceId;
  final String idOFDocument;
  final String createdAt;
  final String expDate;
  final String url;
  final int companyId;
  final String officeId;
  final String fileName;
  bool? approve;
  final int employeeId;
  PractitionerLicenseDataModel({required this.practitionerLicenceId, required this.idOFDocument, required this.createdAt,
    required this.expDate, required this.url, required this.companyId, required this.officeId, required this.fileName,
    this.approve, required this.employeeId});
}
class PractitionerLicensePreFillDataModel{
  final int practitionerLicenceId;
  final String idOFDocument;
  final String createdAt;
  final String expDate;
  final String url;
  final int companyId;
  final String officeId;
  final String fileName;
  bool? approve;
  final int employeeId;
  PractitionerLicensePreFillDataModel({required this.practitionerLicenceId, required this.idOFDocument, required this.createdAt,
    required this.expDate, required this.url, required this.companyId, required this.officeId, required this.fileName,
    this.approve, required this.employeeId});
}