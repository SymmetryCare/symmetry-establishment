class SearchEmployeeProfileData{
  final int employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int employeeTypeId;
  final String expertise;
  final int cityId;
  final int countryId;
  final int zoneId;
  final String SSNNbr;
  final String primaryPhoneNbr;
  final String secondryPhoneNbr;
  final String workPhoneNbr;
  final String regOfficId;
  final String personalEmail;
  final String workEmail;
  final String address;
  final String dateOfBirth;
  final String emergencyContact;
  final String employment;
  final String covreage;
  final String gender;
  final String status;
  final String service;
  final String imgurl;
  final String resumeurl;
  final String onboardingStatus;
  final String createdAt;
  final int companyId;
  final bool terminationFlag;
  final bool approved;
  final String dateofTermination;
  final String dateofResignation;
  final String rehirable;
  final String finalAddress;
  final String type;
  final String reason;
  final double finalPayCheck;
  final String checkDate;
  final double grossPay;
  final double netPay;
  final String methods;
  final String materials;
  final String dateofHire;
  final String position;
  final String driverLicenceNbr;
  final String race;
  final String rating;
  final bool active;

  SearchEmployeeProfileData({
    required this.rating,
    required this.employeeId,
    required this.code,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.employeeTypeId,
    required this.expertise,
    required this.cityId,
    required this.countryId,
    required this.zoneId,
    required this.SSNNbr,
    required this.primaryPhoneNbr,
    required this.secondryPhoneNbr,
    required this.workPhoneNbr,
    required this.regOfficId,
    required this.personalEmail,
    required this.workEmail,
    required this.address,
    required this.dateOfBirth,
    required this.emergencyContact,
    required this.employment,
    required this.covreage,
    required this.gender,
    required this.status,
    required this.service,
    required this.imgurl,
    required this.resumeurl,
    required this.onboardingStatus,
    required this.createdAt,
    required this.companyId,
    required this.terminationFlag,
    required this.approved,
    required this.dateofTermination,
    required this.dateofResignation,
    required this.rehirable,
    required this.finalAddress,
    required this.type,
    required this.reason,
    required this.finalPayCheck,
    required this.checkDate,
    required this.grossPay,
    required this.netPay,
    required this.methods,
    required this.materials,
    required this.dateofHire,
    required this.position,
    required this.driverLicenceNbr,
    required this.race,
    required this.active,
  });
}

class SearchByEmployeeIdProfileData{
  final int? employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int employeeTypeId;
  final int cityId;
  final int countryId;
  final int zoneId;
  final String SSNNbr;
  final String primaryPhoneNbr;
  final String secondryPhoneNbr;
  final String workPhoneNbr;
  final String regOfficId;
  final String personalEmail;
  final String workEmail;
  final String dateOfBirth;
  final String emergencyContact;
  final String covreage;
  final String employment;
  final String gender;
  final String status;
  final String service;
  final String summary;
  final String imgurl;
  final String resumeurl;
  final String onboardingStatus;
  final String driverLicenceNbr;
  final String createdAt;
  final String dateofTermination;
  final String dateofResignation;
  final String dateofHire;
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
  final String city;
  final String employeeType;
  final String department;
  final String country;
  final String zone;
  final String race;
  final String expertise;
  final double anualSkill;
  final String officeId;
  final double profileScorePercentage;
  final bool active;
  final String color;
  final String employeeStatus;

  SearchByEmployeeIdProfileData({
    required this.employeeStatus,
    required this.officeId,
    required this.active,
    required this.anualSkill,
    this.employeeId,
    required this.color,
    required this.code,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.employeeTypeId,
    required this.cityId,
    required this.countryId,
    required this.zoneId,
    required this.SSNNbr,
    required this.primaryPhoneNbr,
    required this.secondryPhoneNbr,
    required this.workPhoneNbr,
    required this.regOfficId,
    required this.personalEmail,
    required this.workEmail,
    required this.dateOfBirth,
    required this.emergencyContact,
    required this.covreage,
    required this.employment,
    required this.gender,
    required this.status,
    required this.service,
    required this.summary,
    required this.imgurl,
    required this.resumeurl,
    required this.onboardingStatus,
    required this.driverLicenceNbr,
    required this.createdAt,
    required this.dateofTermination,
    required this.dateofResignation,
    required this.dateofHire,
    required this.rehirable,
    required this.position,
    required this.finalAddress ,
    required this.type ,
    required this.reason ,
    required this.finalPayCheck ,
    required this.checkDate ,
    required this.grossPay,
    required this.netPay ,
    required this.methods,
    required this.materials ,
    required this.city,
    required this.employeeType,
    required this.department ,
    required this.country,
    required this.zone,
    required this.race,
    required this.expertise,
    required this.profileScorePercentage,
  });
}

class ProfilePercentage{
  final String percentage;
  ProfilePercentage({required this.percentage});
}








// ////data come in list
// class SearchByEmployeeIdProfileDataList {
//   final int employeeId;
//   final String code;
//   final int userId;
//   final String firstName;
//   final String lastName;
//   final int departmentId;
//   final int employeeTypeId;
//   final String expertise;
//   final int cityId;
//   final int countryId;
//   final int countyId;
//   final int zoneId;
//   final String SSNNbr;
//   final String primaryPhoneNbr;
//   final String secondryPhoneNbr;
//   final String workPhoneNbr;
//   final String regOfficId;
//   final String personalEmail;
//   final String workEmail;
//   final String dateOfBirth;
//   final String emergencyContact;
//   final String covreage;
//   final String employment;
//   final String gender;
//   final String status;
//   final String service;
//   final String imgurl;
//   final String resumeurl;
//   final String onboardingStatus;
//   final String driverLicenceNbr;
//   final String createdAt;
//   final String dateofTermination;
//   final String dateofResignation;
//   final String dateofHire;
//   final String rehirable;
//   final String position;
//   final String finalAddress;
//   final String type;
//   final String reason;
//   final double finalPayCheck;
//   final String checkDate;
//   final double grossPay;
//   final double netPay;
//   final String methods;
//   final String materials;
//   final String race;
//   final String signatureURL;
//   final int companyId;
//   final int employeeEnrollId;
//   final bool? active;
//   final String summary;
//   final String reportingOffice;
//   final String speciality;
//   final String address;
//   final String city;
//   final String employeeType;
//   final String department;
//   final String country;
//   final List<String> county;
//   final List<String> zone;
//   final double AnnualSkills;
//   final String color;
//   final double profileScorePercentage;
//
//   SearchByEmployeeIdProfileDataList({
//     required this.employeeId,
//     required this.code,
//     required this.userId,
//     required this.firstName,
//     required this.lastName,
//     required this.departmentId,
//     required this.employeeTypeId,
//     required this.expertise,
//     required this.cityId,
//     required this.countryId,
//     required this.countyId,
//     required this.zoneId,
//     required this.SSNNbr,
//     required this.primaryPhoneNbr,
//     required this.secondryPhoneNbr,
//     required this.workPhoneNbr,
//     required this.regOfficId,
//     required this.personalEmail,
//     required this.workEmail,
//     required this.dateOfBirth,
//     required this.emergencyContact,
//     required this.covreage,
//     required this.employment,
//     required this.gender,
//     required this.status,
//     required this.service,
//     required this.imgurl,
//     required this.resumeurl,
//     required this.onboardingStatus,
//     required this.driverLicenceNbr,
//     required this.createdAt,
//     required this.dateofTermination,
//     required this.dateofResignation,
//     required this.dateofHire,
//     required this.rehirable,
//     required this.position,
//     required this.finalAddress,
//     required this.type,
//     required this.reason,
//     required this.finalPayCheck,
//     required this.checkDate,
//     required this.grossPay,
//     required this.netPay,
//     required this.methods,
//     required this.materials,
//     required this.race,
//     required this.signatureURL,
//     required this.companyId,
//     required this.employeeEnrollId,
//     required this.active,
//     required this.summary,
//     required this.reportingOffice,
//     required this.speciality,
//     required this.address,
//     required this.city,
//     required this.employeeType,
//     required this.department,
//     required this.country,
//     required this.county,
//     required this.zone,
//     required this.AnnualSkills,
//     required this.color,
//     required this.profileScorePercentage,
//   });
//   }