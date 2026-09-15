class ManageVendorData{
  final int insuranceVendorId;
  final String vendorName;
  final String? address;
  final String? phone;
  final int companyId;
  final String officeId;
  final bool? sucess;
  final String? message;
  ManageVendorData({

    required this.companyId,
    required this.insuranceVendorId,
    required this.officeId,
      this.address, this.phone,
     this.sucess, this.message,required this.vendorName});
}

///prefill
class ManageVendorPrefill{
  final int? vendorId;
  final String? officeId;
  final String? vendorName;
  final String? address;
  final String? city;
  final String? email;
  final String? phone;
  final String? workEmail;
  final String? workPhone;
  final String? zone;
  ManageVendorPrefill({this.vendorId, this.officeId,
    this.address, this.city,
    this.email, this.phone,
    this.workEmail, this.workPhone,
    this.zone, this.vendorName});
}

///refferals_manager-vendor-contract
class ManageInsuranceContractData{
  final int insuranceVendorContracId;
  final int insuranceVendorId;
  final String contractName;
  final String contractId;
  final String expiryType;
  final int companyId;
  final String officeId;
  final String expiryDate;
  final String expiryReminder;
  final int threshold;
  final bool? sucess;
  final String? message;
  ManageInsuranceContractData( {
    required this.insuranceVendorContracId,
    required this.insuranceVendorId,
    required this.contractName,
    required this.contractId,
    required this.expiryType,
    required this.companyId,
    required this.officeId,
    required this.expiryDate,
    required this.expiryReminder,
    required this.threshold,
    this.sucess, this.message,});
}

///prefill contract
class ManageContractPrefill{
  final int insuranceVendorContracId;
  final int insuranceVendorId;
  final int companyId;
  final String officeId;
  final String? contractName;
  final String? contractId;
  final String? expiryType;
  final String? expiryDate;
  final String? expiryReminder;
  final int? threshold;
  ManageContractPrefill({
    required this.insuranceVendorContracId,
    required this.insuranceVendorId,
    required this.companyId,
    required this.officeId,
    this.contractName, this.contractId,
    this.expiryType, this.expiryDate,
    this.threshold,
    this.expiryReminder,});
}