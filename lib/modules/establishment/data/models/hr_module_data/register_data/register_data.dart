class RegisterEnrollData {
  // final bool success;
  // final String message;
  final int employeeEnrollId;
  final int companyId;
  final int employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final String phoneNbr;
  final String email;
  final String link;
  final String status;
  final int departmentId;
  final String position;
  final String speciality;
  final int clinicianTypeId;
  final String reportingOfficeId;
  final int cityId;
  final int countryId;
  final int countyId;
  final int zoneId;
  final String employment;
  final String service;

  RegisterEnrollData({
    // required this.success,
    // required this.message,
    required this.employeeEnrollId,
    required this.companyId,
    required this.employeeId,
    required this.userId,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.phoneNbr,
    required this.email,
    required this.link,
    required this.status,
    required this.departmentId,
    required this.position,
    required this.speciality,
    required this.clinicianTypeId,
    required this.reportingOfficeId,
    required this.cityId,
    required this.countryId,
    required this.countyId,
    required this.zoneId,
    required this.employment,
    required this.service,
  });
}

///employee-enroll/{employeeEnrollId}
class RegisterDataPrefill {
  final int empEnrollId;
  final int compId;
  final int empId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final String phoneNbr;
  final String email;
  final String link;
  final String status;
  final int departmentId;
  final String position;
  final String speciality;
  final int clinicianTypeId;
  final String reportingOfficeId;
  final int cityId;
  final int countryId;
  final int countyId;
  final int zoneId;
  final String employment;
  final String service;

  RegisterDataPrefill({
    required this.empEnrollId,
    required this.compId,
    required this.empId,
    required this.code,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNbr,
    required this.email,
    required this.link,
    required this.status,
    required this.departmentId,
    required this.position,
    required this.speciality,
    required this.clinicianTypeId,
    required this.reportingOfficeId,
    required this.cityId,
    required this.countryId,
    required this.countyId,
    required this.zoneId,
    required this.employment,
    required this.service,
  });
}

class CheckOfferLatterData{
  final bool available;
  final String? message;
  CheckOfferLatterData({
    required this.available, this.message
});
}
