class ProfileEditorModal {
  final int employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int employeeTypeId;

  final int cityId;
  final int countryId;
  final int countyId;

  final int zoneId;
  final String SSNNbr;
  final String primaryPhoneNbr;
  final String secondryPhoneNbr;
  final String workPhoneNbr;
  final String regOfficId;
  final String speciality;
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
  final int employeeEnrollId;
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
  final int finalPayCheck;
  final String checkDate;
  final int grossPay;
  final int netPay;
  final String methods;
  final String materials;
  final String race;
  final String signatureURL;
  final int companyId;
  final String rating;
  final String city;
  final String employeType;
  final String department;
  final String country;
  final String county;
  final String zone;
  final String color;
  final String officeId;
  final double profileScorePercentage;
  final String success;
  final String message;

  ProfileEditorModal({required this.employeeEnrollId,
    required this.officeId,
      required this.employeeId,
      required this.code,
      required this.userId,
      required this.firstName,
      required this.lastName,
      required this.departmentId,
      required this.employeeTypeId,
      required this.cityId,
      required this.countryId,
      required this.countyId,
      required this.zoneId,
      required this.SSNNbr,
      required this.summary,
      required this.primaryPhoneNbr,
      required this.secondryPhoneNbr,
      required this.workPhoneNbr,
      required this.regOfficId,
      required this.speciality,
      required this.personalEmail,
      required this.workEmail,
      required this.dateOfBirth,
      required this.emergencyContact,
      required this.covreage,
      required this.employment,
      required this.gender,
      required this.status,
      required this.service,
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
      required this.finalAddress,
      required this.type,
      required this.reason,
      required this.finalPayCheck,
      required this.checkDate,
      required this.grossPay,
      required this.netPay,
      required this.methods,
      required this.materials,
      required this.race,
      required this.signatureURL,
      required this.companyId,
      required this.rating,
      required this.city,
      required this.employeType,
      required this.department,
      required this.country,
      required this.county,
      required this.zone,
    required this.color,
      required this.profileScorePercentage,
      required this.success,
      required this.message});
}

class EmployeeTypeModal {
  final int employeeTypeId;
  final int DepartmentId;
  final String employeeType;
  final String color;
  final String abbreviation;

  EmployeeTypeModal(
      {required this.employeeTypeId,
      required this.DepartmentId,
      required this.employeeType,
      required this.color,
      required this.abbreviation});
}

class CountyWiseZoneModal {


  final int zone_id;
  final int county_id;
  final String zoneName;
  final int companyId;
  final String officeId;



  CountyWiseZoneModal({
    required this.zone_id, required this.county_id, required this.zoneName, required this.companyId, required this.officeId
});
}



/// Coverage section

class EmployeeModel {
  int employeeEnrollId;
  int employeeId;
  List<CoverageDetail> coverageDetails;

  EmployeeModel({
    required this.employeeEnrollId,
    required this.employeeId,
    required this.coverageDetails,
  });
}

class CoverageDetail {
  int employeeEnrollCoverageId;
  String city;
  int countyId;
  String countyName;
  int zoneId;
  String zoneName;
  List<int> zipCodes;

  CoverageDetail({
    required this.employeeEnrollCoverageId,
    required this.city,
    required this.countyId,
    required this.countyName,
    required this.zoneId,
    required this.zoneName,
    required this.zipCodes,
  });
}

class CoveragePrefillData {
  final int employeeEnrollId;
  final int employeeId;
  final CoverageDetails coverageDetails;

  CoveragePrefillData({
    required this.employeeEnrollId,
    required this.employeeId,
    required this.coverageDetails,
  });

  factory CoveragePrefillData.fromJson(Map<String, dynamic> json) {
    return CoveragePrefillData(
      employeeEnrollId: json['employeeEnrollId'],
      employeeId: json['employeeId'],
      coverageDetails: CoverageDetails.fromJson(json['coverageDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeEnrollId': employeeEnrollId,
      'employeeId': employeeId,
      'coverageDetails': coverageDetails.toJson(),
    };
  }
}

class CoverageDetails {
  final int employeeEnrollCoverageId;
  final String city;
  final int countyId;
  final String countyName;
  final int zoneId;
  final String zoneName;
  final List<int> zipCodes;

  CoverageDetails({
    required this.employeeEnrollCoverageId,
    required this.city,
    required this.countyId,
    required this.countyName,
    required this.zoneId,
    required this.zoneName,
    required this.zipCodes,
  });

  factory CoverageDetails.fromJson(Map<String, dynamic> json) {
    return CoverageDetails(
      employeeEnrollCoverageId: json['employeeEnrollCoverageId'],
      city: json['city'] ?? "--",
      countyId: json['countyId'],
      countyName: json['countyName'] ?? "--",
      zoneId: json['zoneId'],
      zoneName: json['zoneName']??"--",
      zipCodes: List<int>.from(json['zipCodes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeEnrollCoverageId': employeeEnrollCoverageId,
      'city': city,
      'countyId': countyId,
      'countyName': countyName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'zipCodes': zipCodes,
    };
  }
}

class DownloadEmployeeOfferLatterData{
  final int employeeId;
  final String templateName;
  final int offerID;
  final String pdfUrl;
  DownloadEmployeeOfferLatterData(
      {required this.employeeId,
        required this.templateName,
        required this.offerID,
        required this.pdfUrl}
      );
}


