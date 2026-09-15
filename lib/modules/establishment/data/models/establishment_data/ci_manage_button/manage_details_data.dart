class ManageDetails {
  final String officeID;
  final String officeName;
  final String priNumber;
  final String secNumber;
  final String alternateNumber;
  final String address;
  final String email;
  final String primaryFax;
  final String secondaryFax;
  final List<DetailsServiceData>? serviceDetails;
  final bool success; // Corrected spelling from 'sucess' to 'success'
  final String message;
  final String lat;
  final String long;
  final String city;
  final String stateName;
  final String countryName;
  final bool isHeadOffice;

  ManageDetails({
    required this.lat,
    required this.long,
    required this.city,
    required this.stateName,
    required this.countryName,
    required this.isHeadOffice,
    required this.officeID,
    required this.success, // Corrected spelling
    required this.message,
    required this.officeName,
    required this.priNumber,
    required this.secNumber,
    required this.alternateNumber,
    required this.address,
    required this.primaryFax,
    required this.secondaryFax,
    required this.email,
    this.serviceDetails,
  });

  factory ManageDetails.fromJson(Map<String, dynamic> json) {
    return ManageDetails(
      officeID: json['officeDetail']['company_Office_id'].toString(),
      success: true,
      message: '',
      officeName: json['officeDetail']['name'],
      priNumber: json['officeDetail']['primary_phone'],
      secNumber: json['officeDetail']['secondary_phone'],
      alternateNumber: json['officeDetail']['alternative_phone'],
      address: json['officeDetail']['address'],
      primaryFax: json['officeDetail']['primary_fax'],
      secondaryFax: json['officeDetail']['secondary_fax'],
      email: json['officeDetail']['email'],
      lat: json['officeDetail']['lat'] ?? "",
      long: json['officeDetail']['lng'] ?? "",
      city: json['officeDetail']['city'] ?? "",
      stateName: json['officeDetail']['state'] ?? "",
      countryName: json['officeDetail']['country'] ?? "",
      isHeadOffice: json['officeDetail']['isHeadOffice'] ?? false,
      serviceDetails: (json['serviceList'] as List<dynamic>?)
          ?.map((item) => DetailsServiceData.fromJson(item))
          .toList(),
    );
  }
}

class DetailsServiceData {
  final int officeServiceId;
  final int companyId;
  final String officeId;
  final String serviceName;
  final String serviceId;
  final String npiNum;
  final String medicareNum;
  final String hcoNum;
  final String lat;
  final String long;
  final String city;
  final String stateName;
  final String countryName;
  final bool isHeadOffice;

  DetailsServiceData({
    required this.lat,
    required this.long,
    required this.city,
    required this.stateName,
    required this.countryName,
    required this.isHeadOffice,
    required this.officeServiceId,
    required this.companyId,
    required this.officeId,
    required this.serviceName,
    required this.serviceId,
    required this.npiNum,
    required this.medicareNum,
    required this.hcoNum,
  });

  // Add factory constructor to convert JSON to the model
  factory DetailsServiceData.fromJson(Map<String, dynamic> json) {
    return DetailsServiceData(
      officeServiceId: json['OfficeServiceId'],
      companyId: json['CompanyId'],
      officeId: json['officeId'],
      serviceName: json['serviceName'],
      serviceId: json['serviceId'],
      npiNum: json['npiNum'],
      medicareNum: json['medicareNum'],
      hcoNum: json['hcoNum'],
      lat: json['lat'],
      long: json['lng'],
      city: json['city'],
      stateName: json['state'],
      countryName: json['country'],
      isHeadOffice: json['isHeadOffice'],
    );
  }
}

///get doc type : /document-type
class GetManageDetailsHeadData {
  final int? id;
  final String? docName;
  final bool sucess;
  final String message;

  GetManageDetailsHeadData({
    this.id,
    this.docName,
    required this.sucess,
    required this.message,
  });
}

///get document subtype: /identity/GetDocType/{document_type_id}
class GetManageDetailsSubHeadData {
  final int docTypeId;
  final String docType;
  final int subDocTypeId;
  final String subDocType;
  final bool sucess;
  final String message;
  GetManageDetailsSubHeadData({
    required this.docTypeId,
    required this.docType,
    required this.subDocTypeId,
    required this.subDocType,
    required this.sucess,
    required this.message,
  });
}

/// get services data
class ServicesData {
  final int officeServiceId;
  final int companyId;
  final String officeId;
  final String serviceName;
  final String serviceId;
  final String npiNumber;
  final String medicareId;
  final String hcoNumber;
  ServicesData(
      {required this.officeServiceId,
      required this.companyId,
      required this.officeId,
      required this.serviceName,
      required this.serviceId,
      required this.npiNumber,
      required this.medicareId,
      required this.hcoNumber});
}

/// Get services meta data
class ServicesMetaData {
  final int serviceMetaDataId;
  final String serviceName;
  final String serviceId;

  ServicesMetaData(
      {
        required this.serviceName,
        required this.serviceId,
        required this.serviceMetaDataId,
        });
}

/// Get prefill service data
class ServicePreFillData{
  final int officeServiceId;
  final int companyId;
  final String officeId;
  final String serviceName;
  final String serviceId;
  final String npiNumber;
  final String medicareId;
  final String hcoNumber;
  final int serviceCompanySetupId;
  ServicePreFillData({required this.officeServiceId, required this.companyId, required this.officeId, required this.serviceName,
  required this.serviceId, required this.npiNumber, required this.medicareId, required this.hcoNumber, required this.serviceCompanySetupId});
}
