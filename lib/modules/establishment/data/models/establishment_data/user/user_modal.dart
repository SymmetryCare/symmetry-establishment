///
class UserModal {
  final int userId;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final int departmentId;
  final String email;
  final int companyId;
  final String phoneNbr;
  final String link;
  final int employeeEnrollId;
  final int employeeId;
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
  final String status;
  final int templateId;
  final bool sucess;
  final String message;
  final bool isActive;

  // final String password;
  UserModal({
    required this.department,
    required this.departmentId,
    required this.phoneNbr,
    required this.link,
    required this.employeeEnrollId,
    required this.employeeId,
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
    required this.status,
    required this.templateId,
    required this.sucess,
    required this.message,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.companyId,
    required this.email,
    required this.isActive,

    // required this.password,
  });
}

/// Get prefill user
class UserModalPrefill {
  final int userId;
  final String firstName;
  final String lastName;
  final String department;
  final int companyId;
  final int deptId;
  final String email;
  final String? password;
  // final String status;
  final bool sucess;
  final String message;
  //  "userId": 37,
  //   "firstName": "Pp",
  //   "lastName": "Pachange",
  //   "departmentId": null,
  //   "department": "Clinical",
  //   "email": "pachangeprachi@gmail.com",
  //   "company_id": 1,
  //   "password": "$2b$10$g/LTCbyi0R.GDikiTbooj.UsTiAHYb.vKK2sN43QcIlkbFLqLdp2y",
  //   "status": "Notopen"

  UserModalPrefill( {
    required this.sucess,
    required this.message,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.companyId,
    required this.deptId,
    required this.email,
     this.password,
    // required this.status,
  });
}
