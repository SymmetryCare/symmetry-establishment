
class EstablishmentManagerRepository {
  ///Company
  static String addCompany = "/Company/Insert";
  static String company = "/Company";
  static String details = "Details";
  static String companyLogo = "/company-logo";
  static String uploadLogo = "uploadLogoBase64";
  static String companyOffice = "/company-office";
  static String add = "/add";
  static String document = "/document";
  static String addDocument = "/document/addDocument";
  static String companyOfficeService = "/company-office-service";
  static String companServiceMetaData = "/service-metadata";
  static String identity = "/identity";
  static String companyList = "/companyList";
  static String officeDetails = "officeDetailWithServiceByCompany";
  static String getDocType = "/GetDocType";
  static String getDocTypeManageCC = "/document-type";
  static String getDocListCompany = "/GetDocumentListByCompany";
  static String getDocListCompanyOffice = "/GetDocumentListByCompanyAndOffice";
  static String visit = "/visits";
  static String visitList = "/visitList";
  static String documentType = "/document-type";
  static String identityDocumentType = "/identity/GetDocType";
  static String getlistByCompany = "/officeListByCompany";
  static String corporateDocument = "/corporate-document";
  static String addOrgDoc = "/addOrgDocument";
  static String addOfficeDoc = "/addOfficeDocument";
  static String workWeekSchedule = "/work-week-schedule";
  static String workWeekShiftSchedule = "/work-week-shift-schedule";
  static String holidays = "/holidays";
  static String holidaysCalender = "/holidays/month";
  static String employeedocSetup = "/employee-document-type-setup";
  static String employeedocSetupByMetaId = "/employee-document-type-setup/ByDocumentTypeMetaDataId";
  static String getEmployeedocTab = "/employee-document-type-meta-data";
  static String payRatesSetup = "/payrates-setup";
  static String payrates = "/payrates";
  static String employeeType = "/employee-types";
  static String user = "/users";
  static String zone = "/zone";
  static String signUp = "/signUp";
  static String companyDept = "/company-department";
  static String department = "/Department";
  static String roleMetaData = "/app-module-meta-data";
  static String addAppRoleModule = "/app-role-module";
  static String companyDetail = "/CompanyDetail";
  static String vendors = "/vendors";
  static String insurancevendors = "/insurance-vendor";//"/refferals_manager-vendor";
  //static String insuranceVendorsContractPatch = "/insurance-vendor-contract";
  static String insurancevendorsContract = "/insurance-vendor-contract";
  static String zonedropdown = "/zoneDropdownByCompany";
  static String zonezipcodedropdown = "/zoneDropdown";
  static String addPayrates = "/payrates/add";
  static String companyOfficeGetList = "/company-office";
  static String companyContactPatch = "/company-contact";

  // static String zonedropdown ="/zone/zoneDropdown";
  //static String addPayrates ="/payrates/add";
  static String newPayrates = "/payrates";
  static String newPayratesdelete = "/payrates";
  static String payratesByServiceId = "/payrates/byServiceAndEmployeeType";
  static String addCompanyPost = "/Company/Insert";
  static String docgetDD = "/org-document-setup/ByDocumentTypeAndSubType";
  static String orgdocadd = "/org-office-document";
  static String orgdocEndPoind = "/org-office-document";
  static String officedocbase = "/org-office-document/attach-documentbase64";

  ///new org
  static String orgDocSetup ="/org-document-setup";
  static String bydoctypeSubtype ="/ByDocumentTypeAndSubTypePageWise";

  // static String getCCList ="/org-document-setup/ByDocumentTypeAndSubTypePageWise/";
  static String getCCList ="/org-office-document/ByDocumentTypeAndSubTypePageWise/";

  static String addofficeservices = "/company-office-service/add";

  ///new office doc
  static String getCCVCPPList ="/org-office-document/ByDocumentTypeAndSubTypePageWise/";
  static String employees ="/employees/";
  static String employeType = "/employee-types/Department/";
  static String downloadEmployeeOffer = "/employee-offers/downloadOfferLetter";


  static String getDownloadOfferLatter({required int employeeId}) {
    return "$downloadEmployeeOffer/$employeeId";
  }
  static String companyAll() {
    return "$company";
  }

  static String companyById({required int companyId}) {
    return "$company/$companyId";
  }

  static String companyDetails({required int companyId}) {
    return "$company/$companyId/$details";
  }

  static String uploadCompanyLogo(
      {required int companyId, required String type}) {
    return "$companyLogo/$type/$companyId/$uploadLogo";
  }
  static String patchCompanyLogo(
      {required int companyId, required String type, required int companyLogoId}) {
    return "$companyLogo/$type/$companyLogoId/$companyId/$uploadLogo";
  }

  static String getCompanyLogo(
      {required int companyId,}) {
    return "$companyLogo/by-company/$companyId";
  }

  static String addCompanyWhitelebling() {
    return "$addCompanyPost";
  }

  ///company-office/{company_Office_id}
  static String companyOfficepatch({required int company_Office_id}) {
    return "$companyOffice/$company_Office_id";
  }

  static String addNewOffice() {
    return "$companyOffice/$add";
  }

  static String addNewOfficeServices() {
    return "$addofficeservices";
  }

  ///identity get all
  static String companyOfficeGet({required int pageNo, required int rowsNo }) {
    return "$identity/$companyList/$pageNo/$rowsNo";
  }

  static String orgDocumentGet() {
    return "$document";
  }

  static String addOrgDocumentPost() {
    return "$addDocument";
  }

  static String updatePrefillPatchCCVCPP({required int docId}) {
    return "$corporateDocument/$docId";
  }

  ///company-office-service/{Office_service_id}
  static String companyofficeservicepatch({required int Office_service_id}) {
    return "$companyOfficeService/$Office_service_id";
  }

  static String companyOfficeServiceGet() {
    return "$companyOfficeService";
  }

  static String companyOfficeServiceGetByCompanyId({required int companyId}) {
    return "$companyOfficeService/${companyId}";
  }
  static String companyOfficeServiceGetByCompanyIdPreFill({required int companyId,required int officeServiceId}) {
    return "$companyOfficeService/${officeServiceId}/${companyId}";
  }
  static String companyServiceMetaDataGet() {
    return "$companServiceMetaData";
  }

  ///service-metadata/add
  static String companyServiceMetaDataPost() {
    return "$companServiceMetaData$add";
  }

  ///insurance-vendor/add
  /////refferals_manager-vendor/add
  static String companyOfficeVendorPost() {
    return "$insurancevendors/$add";
  }

  ///manage refferals_manager-vendor /refferals_manager-vendor/{CompanyId}/{officeId}/{pageNbr}/{NbrofRows}
  static String companyOfficeVendorGet(
      {required int companyId, required String officeId, required int pageNo, required int rowNo}) {
    return "$insurancevendors/$companyId/$officeId/$pageNo/$rowNo";
  }

  ///insurance-vendor/{insuranceVendorId}
  static String companyVendorPatchDelete(
      {required int insuranceVendorId}) {
    return "$insurancevendors/$insuranceVendorId";
  }

  //refferals_manager-vendor-contract/add
  ///insurance-vendor-contract/add
  static String companyOfficeContractPost() {
    return "$insurancevendorsContract/$add";
  }

  ///insurance-vendor-contract/{CompanyId}/{officeId}/{insuranceVendorId}/{pageNbr}/{NbrofRows}
  static String companyOfficeContractGet(
      {required int companyId, required String officeId, required int insuranceVendorId, required int pageNo, required int rowNo}) {
    return "$insurancevendorsContract/$companyId/$officeId/$insuranceVendorId/$pageNo/$rowNo";
  }
  ///insurance-vendor-contract/{insuranceVendorContracId}
  static String companyOfficeVendorPatchDelete(
      {required int insuranceVendorContracId}) {
    return "$insurancevendorsContract/$insuranceVendorContracId";
  }
  ///refferals_manager-vendor-contract/{insuranceVendorContracId}
  static String companyOfficeContractPatchDeleteprefill(
      {required int insuranceVendorContracId}) {
    return "$insurancevendorsContract/$insuranceVendorContracId";
  }

  static String postCompanyOffice() {
    return "$companyOffice/$add";
  }
  static String patchCompanyContact({required int companyId}) {
    return "$companyContactPatch/$companyId";
  }
  static String postCompanyContact() {
    return "$companyContactPatch/add";
  }
  ///manage cc 5 screens
  static String getManageCorporateComp() {
    return "$getDocTypeManageCC";
  }

  ///manage details
  static String getManageDetails(
      {required int companyID, required String officeId}) {
    return "$identity/$officeDetails/$companyID/$officeId";
  }

  ///manage details service post
  static String companyOfficeServicePost() {
    return "$companyOfficeService/$add";
  }

  ///manage corporate and compliance flow
  static String corporateGetDocType({required int docTypeId}) {
    return "$identity/$getDocType";
  }

  ///identity/GetDocumentListByCompanyAndOffice/{company_id}/{office_id}/{document_type_id}/{document_sub_type_id}/{pageNbr}/{NbrofRows}
  static String corporateGetListbyCompany({required int companyId,
    required String officeId, required int docTypeID, required int docSubTypeID, required int pageNo, required int rowsNo}) {
    return "$identity/$getDocListCompanyOffice/$companyId/$officeId/$docTypeID/$docSubTypeID/$pageNo/$rowsNo";
  }

  ///corporate-document/addOfficeDocument
  static String addManageCCVCPPPost() {
    return "$corporateDocument/$addOfficeDoc";
  }

  ///org doc
  static String getCiOrgDLicense({required int companyId,
    required int docTypeID,
    required int docSubTypeID,
    required int pageNo,
    required int rowsNo}) {
    return "$identity/$getDocListCompany/$companyId/$docTypeID/$docSubTypeID/$pageNo/$rowsNo";
  }

  static String getOrgDocument() {
    return "/$document";
  }

  static String getCiVisit(
      {required int companyId, required int pageNo, required int noofRows}) {
    return "$visit/$companyId/$pageNo/$noofRows";
  }

  static String getCiVisitList() {
    return "$visit$visitList";
  }

  static String getCiVisitListByServiceId({required String serviceId}) {
    return "$visit/getVisitsByServiceId/${serviceId}";
  }

  static String getCiVisitPrefill({required int visitId}) {
    return "$visit/$visitId";
  }

  static String postCiVisit() {
    return "$visit/$add";
  }

  static String documentTypeGet() {
    return "/$documentType";
  }

  static String deleteCiVisit({required int visitId}) {
    return "$visit/$visitId";
  }

  static String updateCiVisit({required int typeVisit}) {
    return "$visit/$typeVisit";
  }

  static String identityDocumentTypeGet({required int docId}) {
    return "/$identityDocumentType/$docId";
  }

  static String companyOfficeListGet({required int companyId,
    required int pageNo, required int rowsNo }) {
    return "/$identity$getlistByCompany/$companyId/$pageNo/$rowsNo";
  }

  ///corporate-document/addOrgDocument
  static String addCorporateDocumentPost() {
    return "$corporateDocument/$addOrgDoc";
  }

  static String getPrefillCorporateDocument({required int documentId}) {
    return "$corporateDocument/$documentId";
  }

  static String updateCorporateDocumentPost({required int docID}) {
    return "$corporateDocument/$docID";
  }

  /// Work Schedule
  static String workWeekScheduleGet() {
    return "$workWeekSchedule";
  }

  static String workWeekShiftScheduleGet(
      {required int companyId,required String weekDay}) {
    return "$workWeekShiftSchedule/findByWeekDay/$weekDay/$companyId";
  }

  static String addWorkWeekShiftPost() {
    return "$workWeekShiftSchedule$add";
  }

  static String addWorkWeekSchedulePost() {
    return "$workWeekSchedule$add";
  }

  static String deleteWorkWeekScheduleDelete(
      {required int workWeekScheduleId}) {
    return "$workWeekSchedule/$workWeekScheduleId";
  }

  static String getShiftPrefillBatches({required int shiftBatchId}) {
    return "$workWeekShiftSchedule/getbatchBy/$shiftBatchId";
  }

  static String getShiftBatches(
      {required String shiftName, required int companyId, required String weekDay}) {
    print(":::getshiftbatch${shiftName}");
    return "$workWeekShiftSchedule/batch/$weekDay/$shiftName/$companyId";
  }

  static String addShiftBatches() {
    return "$workWeekShiftSchedule/batch/";
  }
  static String modifyShiftBatches({required int shiftBatchScheduleId}) {
    return "$workWeekShiftSchedule/batch/$shiftBatchScheduleId";
  }
  static String deleteWorkWeekShict({required int workWeekShiftId}) {
    return "$workWeekShiftSchedule/$workWeekShiftId";
  }

  // Holidays
  static String holidaysGet() {
    return "$holidays";
  }

  static String holidaysCalenderGet({required int companyId,required int years, required int monthh}) {
    return "$holidaysCalender/$companyId/$years/$monthh";
  }

  static String holidaysPrefillGet({required int holidayId}) {
    return "$holidays/$holidayId";
  }

  static String addHolidaysPost() {
    return "$holidays$add";
  }

  static String deleteHolidaysDelete({required int holidayId}) {
    return "$holidays/$holidayId";
  }

  static String updateHolidaysPatch({required int holidayId}) {
    return "$holidays/$holidayId";
  }



  ///employee doc list
  static String getEmployeeDocSetUpMetaId({
    required int pageNo, required int rowsNo,
    required int employeeDocTypeMetaDataId
  }) {
    /// return "$employeedocSetup/$metaDocId";
    return "$employeedocSetup/$employeeDocTypeMetaDataId/$pageNo/$rowsNo";
  }

  static String getPrefillEmployeDocSetup({required int empDocTypeId}) {
    return "$employeedocSetup/$empDocTypeId";
  }

  static String getEmployeDocSetupDropdown({required int empDocMetaId}) {
    return "$employeedocSetupByMetaId/$empDocMetaId";
  }

  static String addEmployeDocSetup() {
    return "$employeedocSetup$add";
  }

  ///employee doc tab bar
  static String getEmployeeDocSetup() {
    return "$getEmployeedocTab";
  }

  /// Pay Rates get data
  static String payRatesSetupGet({
    required int empTypeId,
    required int companyId,
    required int pageNo,
    required int noOfRows
  }) {
    return "$payRatesSetup/$companyId/$empTypeId/$pageNo/$noOfRows";
  }

  ///payrates/add
  static String payRatesSetupPost() {
    return "$payrates$add";
  }

  static String deletePayRatesSetup({required int payRatesId}) {
    return "$payRatesSetup/$payRatesId";
  }

  static String updatePayRatesSetup({required int payRatesId}) {
    return "$payRatesSetup/$payRatesId";
  }


  /// Employee type add POST
  static String addEmployeeTypePost() {
    return "$employeeType$add";
  }

  static String deleteEmployeeTypes({
    required int employeeTypeId
  }) {
    return "$employeeType/$employeeTypeId";
  }

  static String deleteEmployeedoctypesetup({
    required int employeeDoctypeSetupId
  }) {
    return "$employeedocSetup/$employeeDoctypeSetupId";
  }

  static String postEmployeedocTypesetup(
      {required int employeeDoctypeSetupId }) {
    return "$employeedocSetup/$add";
  }

  static String userGet() {
    return "$user";
  }

  static String userGetbyCompanyId({required int companyId}) {
    return "$user";
  }

  static String userGetByCompanyId({required int companyId}) {
    return "$user/ByCompanyId/$companyId";
  }
  static String userGetAllByCompanyId({required int companyId}) {
    return "$user/all/ByCompanyId/$companyId";
  }

  static String userPrefillGet({required int userId}) {
    return "$user/$userId";
  }

  static String createUserPost() {
    return "$user$signUp";
  }

  static String userUpdatePatch({required userId}) {
    return "$user/$userId";
  }

  static String userDelete({required userId}) {
    return "$user/$userId";
  }

  // static String zoneGet(){
  //   return "$zone";
  // }
  ///Role Manager
  static String companyDepartment() {
    return "$companyDept";
  }

  ///employee-types/Department/{DepartmentId}
  static String companyDepartmentById({required int DepartmentId}) {
    return "$employeeType$department/$DepartmentId";
  }

  static String getRoalMetaData() {
    return "$roleMetaData";
  }

  static String addAppRoleModulePost() {
    return "$addAppRoleModule$add";
  }

  static String getWhitelabellingDetail({required int companyId}) {
    return "$identity$companyDetail/$companyId";
  }

  ///company-office/{company_id}
  static String getCompanyOfficeList({required int companyId}) {
    return "$companyOfficeGetList/$companyId";
  }


  ///zone dropdown
  static String getzonedropdown({required int companyID,}) {
    return "$zone/$zonedropdown/$companyID";
  }

  ///zone dropdown zipcode prefill
  ///zone/zoneDropdown/{companyId}/{officeId}
  static String getzonezipcodedropdown({required int companyID,required String officeId,}) {
    return "$zone/$zonezipcodedropdown/$companyID/$officeId";
  }

  /// service dropdown
  static String getServicedropdown() {
    return "$companyOfficeService";
  }

  static String postPayrates() {
    return "$addPayrates";
  }

  static String getPayrates() {
    return "$newPayrates";
  }
  static String getPayratesByServiceIdAnrEmpId({required String serviceID, required int empId}) {
    return "$payratesByServiceId/${serviceID}/${empId}";
  }

  static String addDocOrg() {
    return "$orgdocadd/$add";
  }
  ///org-office-document/others/add
  static String addOtherDoc() {
    return "$orgdocadd/others/$add";
  }
  static String patchDocOrg({required int orgDocID}) {
    return "$orgdocEndPoind/$orgDocID";
  }
  ///org-office-document/others/{orgOfficeDocumentId}
  static String patchOtherOrg({required int orgOfficeDocumentId}) {
    return "$orgdocEndPoind/others/$orgOfficeDocumentId";
  }
  static String deleteDocOrg({required int orgDocID}) {
    return "$orgdocEndPoind/$orgDocID";
  }

  static String uploadedocOffice({required int orgOfficeDocumentId }){
    return "$officedocbase/$orgOfficeDocumentId";
}


  static String getdocPayratesdropdown({ required int DocumentTypeId, required int DocumentSubTypeId } ) {
    return "$docgetDD/$DocumentTypeId/$DocumentSubTypeId";
  }


  static String deleteeditprefillPayRates({required int payRatesId}) {
    return "$newPayratesdelete/$payRatesId";
  }


  ///new org doc
  static String newOrgDocGet() {
    return "$orgDocSetup";
  }


  ///org-document-setup/ByDocumentTypeAndSubTypePageWise/{DocumentTypeId}/{DocumentSubTypeId}/{pageNbr}/{NbrofRows}
  static String newOrgDocGetTypeWise({required int DocumentTypeId, required int DocumentSubTypeId, required int pageNbr, required int NbrofRows}) {
    return "$orgDocSetup/$bydoctypeSubtype/$DocumentTypeId/$DocumentSubTypeId/$pageNbr/$NbrofRows";
  }
  ///org-document-setup/{orgDocumentSetupid}
  static String updatePrefillPatchNewOrgDoc({required int orgDocumentSetupid}) {
    return "$orgDocSetup/$orgDocumentSetupid";
  }
  ///
  static String addNewDocumentPost() {
    return "$orgDocSetup/$add";
  }
  ///new office doc
  ///org-office-document/ByDocumentTypeAndSubTypePageWise/{DocumentTypeId}/{DocumentSubTypeId}/{pageNbr}/{NbrofRows}
  static String getListMCorporateCompliance({required int DocumentTypeId,    required String officeID, required int DocumentSubTypeId, required int pageNbr, required int NbrofRows}){
    return "$getCCVCPPList$DocumentTypeId/$DocumentSubTypeId/$officeID/$pageNbr/$NbrofRows";
  }

  static String prefillDocOfficeOrg({required int orgDocID}) {
    return "$orgdocEndPoind/$orgDocID";
  }
  static String employeeEditGet({required int employeeId}){
    return "$employees$employeeId";
  }
  static String employeePrefillPatch({required int employeeId}){
    return "$employees$employeeId";
}
 static String getEmployeeType({required int departmentId}){
    return "$employeType$departmentId";
 }
}
