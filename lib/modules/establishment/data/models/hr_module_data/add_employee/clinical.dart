///add employee get

class HRAddEmployeeGet {
  final bool? success;
  final String? message;
  final int? employeeid;
  final String? code;
  final int? userId;
  final String? firstName;
  final String? lastName;
  final int? dptID;
  final int? emplyID;
  final String? expritise;
  final int? cityID;
  final int? countryID;
  final int? zoneID;
  final String? ssnnBr;
  final String? primeNo;
  final String? secNo;
  final String? workNo;
  final String? regOfficeId;
  final String? personalEmail;
  final String? workEmail;
  final String? address;
  final String? dob;
  final String? emgContact;
  final String? coverage;
  final String? employment;
  final String? gender;
  final String? status;
  final String? service;
  final String? imgUrl;
  final String? resumeUrl;
  final int? companyID;
  final String? onboardingStatus;
  final String? dateofTermination;
  final String? dateofResignation;
  final String? rehirable;
  final String? finalAddress;
  final String? type;
  final String? reason;
  final String? checkDate;
  final int? grossPay;
  final int? netPay;
  final String? methods;
  final String? materials;
  final String? driverLicenceNbr;
  final bool? terminationFlag;
  final bool? approved;
  final String? dateofHire;
  final String? position;
  final int? finalPayCheck;
  final String? race;

  HRAddEmployeeGet({
    this.employeeid,
    this.success,
    this.message,
    this.code,
    this.userId,
    this.firstName,
    this.lastName,
    this.dptID,
    this.emplyID,
    this.expritise,
    this.cityID,
    this.countryID,
    this.zoneID,
    this.ssnnBr,
    this.primeNo,
    this.secNo,
    this.workNo,
    this.regOfficeId,
    this.personalEmail,
    this.workEmail,
    this.address,
    this.dob,
    this.emgContact,
    this.coverage,
    this.employment,
    this.gender,
    this.status,
    this.service,
    this.imgUrl,
    this.resumeUrl,
    this.companyID,
    this.onboardingStatus,
    this.driverLicenceNbr,
    this.dateofTermination,
    this.dateofResignation,
    this.rehirable,
    this.finalAddress,
    this.type,
    this.reason,
    this.checkDate,
    this.grossPay,
    this.netPay,
    this.methods,
    this.materials,
    this.terminationFlag,
    this.approved,
    this.dateofHire,
    this.position,
    this.finalPayCheck,
    this.race,
  });
}

/// discipline dropdown
class AEClinicalDiscipline {
  final bool? success;
  final String? message;
  final String? empType;
  final String? abbrivation;
  final int? deptID;
  final String? color;
  final int employeeTypesId;
  // int? deptId;

  AEClinicalDiscipline(
      {required this.employeeTypesId,
      this.success,
      this.message,
      this.empType,
      this.deptID,
      this.abbrivation,
      this.color});
}

///city dropdown
class AEClinicalCity {
  final bool? success;
  final String? message;
  final String? cityName;
  final int? cityID;
  final String? state;
  final String? country;

  AEClinicalCity(
      {this.cityName,
      this.cityID,
      this.state,
      this.country,
      this.success,
      this.message});
}

/// Reporting Office dropdown
class AEClinicalReportingOffice {
  final bool? success;
  final String? message;
  final int? companyOfficeID;
  final int? companyID;
  final String? officeID;
  final String? primNo;
  final String? secNo;
  final String? primeFax;
  final String? secFax;
  final String? alterNo;
  final String? email;
  final String? name;
  final String? address;

  AEClinicalReportingOffice(
      {this.success,
      this.message,
      this.companyOfficeID,
      this.companyID,
      this.officeID,
      this.primNo,
      this.secNo,
      this.primeFax,
      this.secFax,
      this.alterNo,
      this.email,
      this.name,
      this.address});
}

///zone dropdown
class AEClinicalZone {
  final bool? success;
  final String? message;
  final String? county;
  final int? countyID;
  final int? zoneID;
  final String? zoneName;
  final int? companyId;
  final String? officeId;

  AEClinicalZone(
      {this.success,
      this.message,
      this.county,
      this.countyID,
      this.zoneID,
      this.zoneName,
      this.companyId,
      this.officeId});
}

class AEClinicalService {
  final int? officeServiceID;
  final int? companyID;
  final String? officeID;
  final String? serviceName;
  final String? npiNo;
  final String? medicareProviderID;
  final String? hecoNoID;

  AEClinicalService(
      {this.officeServiceID,
      this.companyID,
      this.officeID,
      this.serviceName,
      this.npiNo,
      this.medicareProviderID,
      this.hecoNoID});
  // "Office_service_id": 1,
  // "company_id": 1,
  // "office_id": "Office NY",
  // "service_name": "Home Health",
  // "service_id": "Ser1",
  // "npi_number": "45555E",
  // "medicare_provider_id": "455EE",
  // "hco_num_id": "dkkkd444"
}

/// upload photo
class UploadPicture {}

////services
class EnrollServices {
  final int? serviceMetadataId;
  final String servicename;
  final String serviceid;

  EnrollServices(
      {required this.serviceMetadataId,
      required this.servicename,
      required this.serviceid});
}
