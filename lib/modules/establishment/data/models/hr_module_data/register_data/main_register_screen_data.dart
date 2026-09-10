//by comp id
class RegisterDataCompID {
  final int userId;
  final String firstName;
  final String lastName;
  final String role;
  final String email;
  final int company_id;
  final String status;
  final String? phoneNbr;
  final String? link;
  final int? employeeEnrollId;
  final int employeeId;
  final int? deptId;
  final String department;
  final String? posotion;
  final String? speciality;
  final int? clinicalId;
  final String? reportingOfficeId;
  final int? cityId;
  final int? countryId;
  final int? countyId;
  final int? zoneId;
  final String? employeement;
  final String? service;
  final int? templateId;
  final bool isActive;

  RegisterDataCompID({
    this.phoneNbr,
    this.link,
    this.employeeEnrollId,
    required this.employeeId,
    this.deptId,
    required this.department,
    this.posotion,
    this.speciality,
    this.clinicalId,
    this.reportingOfficeId,
    this.cityId,
    this.countryId,
    this.countyId,
    this.zoneId,
    this.employeement,
    this.service,
    this.templateId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.company_id,
    required this.status,
    this.isActive = false,
  });
}

///by comp id by status
class RegisterDataCompIDStatus {
  final int userId;
  final String firstName;
  final String lastName;
  final String role;
  final String email;
  final int company_id;
  final String status;

  RegisterDataCompIDStatus({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.company_id,
    required this.status,
  });
}

///users/{userId} prefill
class RegisterDataUserIDPrefill {
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final String role;
  final String email;
  final int company_id;
  final String status;


  RegisterDataUserIDPrefill( {
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.role,
    required this.email,
    required this.company_id,
    required this.status,
  });
}
