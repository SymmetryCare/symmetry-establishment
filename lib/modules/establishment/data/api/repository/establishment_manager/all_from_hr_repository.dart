class AllFromHrRepository{
  ///Clinical
  static String empType = "/employee-types";
  static String companyDept = "/company-department";
  static String department = "/Department";
  static String roleMasterData = "/role-master-new";
  static String addTemplate = "/template-data/add";
  static String patchTemplate = "/template-data";

  static String getEmployeeType(){
    return "$empType";
  }
  static String getEmployeeTypeDeptWise({required int deptId}){
    return "$empType$department/$deptId";
  }
  static String getHrType(){
    return "$companyDept";
  }
  static String getRoleMaster(){
    return "$roleMasterData";
  }
  static String patchHRType({required int empId}){
    return "$empType/$empId";
  }
  static String getEmpTypeById({required int empId}){
    return "$empType/$empId";
  }
  static String addOfferTemplate(){
    return "$addTemplate";
  }
  static String patchOfferTemplate({required int templateId}){
    return "$patchTemplate/$templateId";
  }
  static String getOfferTemplate({required int templateId}){
    return "$patchTemplate/$templateId";
  }
}

///zone
class AllZoneRepository{
  static String zone = "/zone";
  static String county = "/county";
  static String countyOfficeIWse = "/county/FindAllByOfficeId";
  static String zoneCounty = "/zone-county";
  static String add = "/add";
  static String zipcodesetup = "/zipcode-setup";
  static String country = "/country";
  static String zoneByCountyId = '/zone/zoneByCounty';
  static String zoneByCompanyId = '/zipcode-setup/all/by-company';
  static String zoneWithCompanyId = "/zone/zoneDropdownByCompany";

  static String zoneGet(){
    return "$zone";
  }
  static String countryGet(){
    return "$country";
  }
  static String deleteZipCodeSetup({required int zipCodeSetupId}){
    return "$zipcodesetup/$zipCodeSetupId";
  }
  /// Add zipcode setup
  static String addZipCodeSetupPost(){
    return "$zipcodesetup/add";
  }
  static String updateZipCodeSetup({required int zipCodeSetupId}){
    return "$zipcodesetup/$zipCodeSetupId";
  }
  /// get
  static String zoneBYcompOfficeGet({required int companyId,required String officeId,required int pageNo,required int noOfRow}){
    return "$zone/$companyId/$officeId/$pageNo/$noOfRow";
  }

  static String getZoneByCountyId({required int countyId}){
    return "$zoneByCountyId/$countyId";
  }
  static String getZoneByCompanyIdWise({required int companyId}){
    return "$zoneWithCompanyId/$companyId";
  }

  ///county get last
  static String countyGet({required int companyId,required String officeId,required int pageNo,required int noOfRow}){
    return "$county/$companyId/$officeId/$pageNo/$noOfRow";
  }
  static String countyCompanyGet({required String officeId,}){
    return "$county/FindAllByOfficeId/$officeId";
  }
  ///county get list zone
  static String countyZoneGet({required int companyId,
    required String officeId,
    required int countyId,
    required int pageNo,
    required int noOfRow}){
    return "$zone/$companyId/$officeId/$countyId/$pageNo/$noOfRow";
  }
  static String countyZoneDelete({required int zoinId}){
    return "$zone/$zoinId";
  }


  static String addCountyZone(){
    return "$zone$add";
  }
  static String updateCountyZone({required int zoinId}){
    return "$zone/$zoinId";
  }
  static String countyListGet(){
    return "$county";
  }
  static String countyListGetOfficeIdWise({required String OfficeId}){
    return "$countyOfficeIWse/$OfficeId";
  }
  static String addCounty(){
    return "$county$add";
  }
  static String updateCounty({required int countyId}){
    return "$county/$countyId";
  }
  static String deleteCounty({required int countyId}){
    return "$county/$countyId";
  }
  static String zoneCountyPost(){
    return "$zoneCounty$add";
  }
  ///zipcode,zone get
  static String zipcodeSetupGet({required int companyId,required String officeId,required int pageNo,required int noOfRow,
    required String countyId, required String zoneId}){
    return "$zipcodesetup/$companyId/$officeId/$pageNo/$noOfRow/$countyId/$zoneId";
  }
  /// Zipcode by countyId
  static String zipcodeByCountyId({required int companyId, required int countyId}){
    return "$zipcodesetup/GetByCounty/$companyId/$countyId";
  }
  static String zipcodeByCompanyId(){
    return "$zoneByCompanyId";
  }
  /// Zipcode by countyId and zoneId
  static String zipcodeByCountyIdAndZoneId({required int zoneId, required int countyId}){
    return "$zipcodesetup/GetByCountyZone/$zoneId/$countyId";
  }

}