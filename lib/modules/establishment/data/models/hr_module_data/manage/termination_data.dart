class TerminationData {
  final int employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final int deptId;
  final int employeeTypeId;
  final String expertise;
  final int cityId;
  final int countyId;
  final int zoinId;
  final String SSNNbr;
  final String primaryPhoneNo;
  final String secoundayPhoneNo;
  final String workPhoneNo;
  final String regOfficeId;
  final String personalEmail;
  final String workEmail;
  final String address;
  final String dateOdBirth;
  final String emergencyContact;
  final String covrage;
  final String employment;
  final String gender;
  final String status;
  final String service;
  final String imgUrl;
  final String resumeUrl;
  final String onbordinStatus;
  final String createdAt;
  final int companyId;
  final bool terminationFlag;
  final bool approved;
  final String dateOfTermination;
  final String dateOfResignation;
  final String rehirable;
  final String finalAddress;
  final String type;
  final String reson;
  final int finalPayCheck;
  final String checkDate;
  final int grossPay;
  final int netPay;
  final String methods;
  final String materials;
  TerminationData({
    required this.employeeId,
    required this.code,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.deptId,
    required this.employeeTypeId,
    required this.expertise,
    required this.cityId,
    required this.countyId,
    required this.zoinId,
    required this.SSNNbr,
    required this.primaryPhoneNo,
    required this.secoundayPhoneNo,
    required this.workPhoneNo,
    required this.regOfficeId,
    required this.personalEmail,
    required this.workEmail,
    required this.address,
    required this.dateOdBirth,
    required this.emergencyContact,
    required this.covrage,
    required this.employment,
    required this.gender,
    required this.status,
    required this.service,
    required this.imgUrl,
    required this.resumeUrl,
    required this.onbordinStatus,
    required this.createdAt,
    required this.companyId,
    required this.terminationFlag,
    required this.approved,
    required this.dateOfTermination,
    required this.dateOfResignation,
    required this.rehirable,
    required this.finalAddress,
    required this.type,
    required this.reson,
    required this.finalPayCheck,
    required this.checkDate,
    required this.grossPay,
    required this.netPay,
    required this.methods,
    required this.materials,
  });
  // "companyId": 0,
  // "terminationFlag": true,
  // "approved": true,
  // "dateofTermination": "2024-07-16T08:27:53.798Z",
  // "dateofResignation": "2024-07-16T08:27:53.798Z",
  // "rehirable": "string",
  // "finalAddress": "string",
  // "type": "string",
  // "reason": "string",
  // "finalPayCheck": 0,
  // "checkDate": "2024-07-16T08:27:53.798Z",
  // "grossPay": 0,
  // "netPay": 0,
  // "methods": "string",
  // "materials": "string"
}

/// prefill termination
class TerminateEmployeePrefillData {
  final int employeeId;
  final String firstName;
  final String lastName;
  final String primaryPhoneNbr;
  final bool? terminationFlag;
  final String dateofTermination;
  final String dateofResignation;
  final String dateofHire;
  final String lastWorkingDay;      // ✅ NEW
  final String rehirable;
  final String position;
  final String finalAddress;
  final String type;
  final String reason;
  final double finalPayCheck;
  final String checkDate;
  final double grossPay;
  final double netPay;
  final String methods;
  final String materials;
  final String status;

  TerminateEmployeePrefillData({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.primaryPhoneNbr,
    required this.terminationFlag,
    required this.dateofTermination,
    required this.dateofResignation,
    required this.dateofHire,
    required this.lastWorkingDay,   // ✅ NEW
    required this.rehirable,
    required this.position,
    required this.finalAddress ,
    required this.type,
    required this.reason,
    required this.finalPayCheck,
    required this.checkDate,
    required this.grossPay,
    required this.netPay,
    required this.methods,
    required this.materials,
    required this.status,
  });
}






///card data
class TerminationDetailData {
  final int employeeId;
  final String firstName;
  final String lastName;
  final int roleId;
  final String primaryPhoneNbr;
  final bool terminationFlag;
  final String dateofTermination;
  final String dateofResignation;
  final String dateofHire;
  final String lastWorkingDay;              // ✅ NEW
  final String rehirable;
  final String position;
  final String finalAddress;
  final String type;
  final String reason;
  final double finalPayCheck;
  final String checkDate;
  final double grossPay;
  final double netPay;
  final String methods;
  final String materials;
  final String status;
  final bool active;
  final String registrationDate;           // ✅ NEW
  final String offerLetterAcceptanceDate;  // ✅ NEW

  TerminationDetailData({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.primaryPhoneNbr,
    required this.terminationFlag,
    required this.dateofTermination,
    required this.dateofResignation,
    required this.dateofHire,
    required this.lastWorkingDay,              // ✅ NEW
    required this.rehirable,
    required this.position,
    required this.finalAddress,
    required this.type,
    required this.reason,
    required this.finalPayCheck,
    required this.checkDate,
    required this.grossPay,
    required this.netPay,
    required this.methods,
    required this.materials,
    required this.status,
    required this.active,
    required this.registrationDate,           // ✅ NEW
    required this.offerLetterAcceptanceDate,  // ✅ NEW
  });
}