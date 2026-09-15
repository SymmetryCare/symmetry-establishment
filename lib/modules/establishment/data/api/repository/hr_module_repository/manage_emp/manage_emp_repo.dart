class ManageReposotory{
  static String employee_licenses = "/employee-licenses";
  static String references = "/reference";
  static String add = "/add";
  static String education = "/employee-educations";
  static String byemployeeId = "ByemployeeId";
  static String employement = "/employee-employment-histories";
  static String selectDocuments = "/corporate-document";
  static String banking = "/employee-bankings";
  static String bankingAdd = "/employee-bankings/add";
  static String equipementGet = "/employee-inventories/ByemployeeId";
  static String inventoryEmp = "/inventory/bycompanyId";
  static String equipement1 = "/employee-inventories";

  static String payrates = "/employee-payrates/ByEmployeeId";

  static String gettermination = "/employees/allTerminatedEmployee";
  static String getterminationPrefillEmp = "/employees/GetTerminateEmployeeDetails";
  static String terminateEmployeePatch = "/employees/terminate";


  static String employeeTimeOff = "/employee-time-off";


  static String licenseStatus = "/employee-licenses/LicenseDetailByemployeeId";
  static String resumeupload = "/employee-employment-histories/attach-documentbase64";
  static String photoupload = "/employees/attach-photobase64";
  static String licensesupload = "/employee-licenses/attach-licensebase64";
  static String Bankcheckupload = "/employee-bankings/attach-checkbase64";
  static String licenseFilterGet = "/employee-licenses/Dropdown/ByLicenseName";

  static String othersDocumentAdd = "/others-docs";

  static String resignationLetterUpload = "/employees/upload-resignation-letter";

  /// Time off
  static String timeOff = "/time-off";


  /// Licenses status wise

  static String getLicenseStatus({required int employeeId,required String approvedOnly}){
    return "$licenseStatus/$employeeId/$approvedOnly";
  }




  /// Employeement
  static String getEmployeement({required int employeeId,required String approveOnly}){
    return "$employement/$byemployeeId/$employeeId/$approveOnly";
  }
  static String addEmployeement(){
    return "$employement$add";
  }
  static String updateEmployeement({required int employeementId}){
    return "$employement/$employeementId";
  }

  static String updateEmployeementresume({required int employeementId, required String documentName}){
    return "$resumeupload/$employeementId/$documentName";
  }






  /// Education
  static String getEmployeeDucation({required int employeeId,required String approveOnly}){
    return "$education/$byemployeeId/$employeeId/$approveOnly";
  }
  static String addEmployeeDucation(){
    return "$education$add";
  }
  static String patchEmployeeDucation({required int educationId}){
    return "$education/$educationId";
  }

  static String uploadphoto({required int employeeid}){
    return "$photoupload/$employeeid";
  }

  /// Others document
  static String addOthersDoc(){
    return "$othersDocumentAdd";
  }

  static String uploadOthersDoc({required int otherDocumentid}){
    return "$othersDocumentAdd/attach-documentbase64/$otherDocumentid";
  }

  static String getOthersDocument({required int employeeId, required int companyId}){
    return "$othersDocumentAdd/by/$employeeId/$companyId";
  }

  static String patchOthersDoc({required int otherDocId}){
    return "$othersDocumentAdd/$otherDocId";
  }


  /// Employee licences
  static String getEmployeeLicenses({required int employeeid,required String approveOnly}){
    return "$employee_licenses/ByemployeeId/$employeeid/$approveOnly";
  }
  static String getEmployeeLicensesFiltered({required int employeeid,required String approveOnly,required String licenseName}){
    return "$licenseFilterGet/$employeeid/$approveOnly/$licenseName";
  }

  static String getEmployeePreFillLicenses({required int licensesId,}){
    return "$employee_licenses/$licensesId";
  }
  static String getselectDocuments(){
    return "$selectDocuments";
  }
  static String addEmployeeLicenses(){
    return "$employee_licenses$add";
  }
  static String attachLicenseDocument({required int licenseId}){
    return "$employee_licenses/attach-licensebase64/$licenseId";
  }
  static String rejectEmployeeLicenses({required int licensedId}){
    return "$employee_licenses/reject/$licensedId";
  }
  static String approveEmployeeLicenses({required int licensedId}){
    return "$employee_licenses/approve/$licensedId";
  }
  static String updateEmployeeLicenses({required int licensedId}){
    return "$employee_licenses/$licensedId";
  }
  static String dropdownAttaceLicences({required int licensedId}){
    return "$employee_licenses/attach-license/$licensedId";

  }
///
  static String uploadlinceses({required int licensedId}){
    return "$licensesupload/$licensedId";

  }


  /// References
  static String referenceByemployeeIdGet({required int employeeId,required String approveOnly}){
    return "$references/ByemployeeId/$employeeId/$approveOnly";
  }
  static String addReferences(){
    return "$references$add";
  }
  static String updateReferences({required int referenceId}){
    return "$references/$referenceId";
  }
  static String rejectReferences({required int referenceId}){
    return "$references/reject/$referenceId";
  }
  static String approveReferences({required int referenceId}){
    return "$references/approve/$referenceId";
  }

  /// Employee Banking
  static String getBankingEmployee({required int employeeId,required String approveOnly}){
    return "$banking/$byemployeeId/$employeeId/$approveOnly";
  }

  static String getPrefillBankingEmployee({required int empBankingId}){
    return "$banking/$empBankingId";
  }

  static String addBankingEmployee(){
    return "$banking$add";
  }

  static String updateBankingEmployee({required int empBankingId}){
    return "$banking/$empBankingId";
  }
  static String addNewBankingEmployee(){
    return "$bankingAdd";
  }

  static String uploadBanckingDocuments({required int empBankingId}){
    return "$banking/attach-checkbase64/$empBankingId";
  }

  static String approveBankingEmployee({required int empBankingId}){
    return "/employee-bankings/approve/$empBankingId";
  }

  static String rejectBankingEmployee({required int empBankingId}){
    return "/employee-bankings/reject/$empBankingId";
  }
////////

  static String uploadcheck({required int empBankingId}){
    return "$Bankcheckupload/$empBankingId";
  }



  /// Equipment

  static String addEquipement(){
    return "$equipement1$add";
  }
  static String gerDropdownInventory({required int companyId}){
    return "$inventoryEmp/$companyId";
  }
  static String getEquipement({required int employeeId}){
    return "$equipementGet/$employeeId";
  }
  // static String getPrefillEquipement({required int empInventoryId}){
  //   return "$equipementGet/$empInventoryId";
  // }
  static String patchEquipement({required int empInventoryId}){
    return "$equipement1/$empInventoryId";
  }

  /// Payrates

  static String getEmployeePayrates({required int employeeID, required int pagNo, required int noOfRows}){
    return "$payrates/$employeeID/$pagNo/$noOfRows";
  }

  static String deleteEmployeePayrates({required int employeePayratesId}){
    return "$payrates/$employeePayratesId";
  }

  /// Termination
  static String getTermination({required int companyId}){
    return "$gettermination/$companyId";
  }
  static String getTerminationPreFillEmp({required int employeeId}){
    return "$getterminationPrefillEmp/$employeeId";
  }
  static String patchTerminateEmployee({required int employeeId}){
    return "$terminateEmployeePatch/$employeeId";
  }

  static String uploadResignationLetter({required int employeeId}) {
    return "$resignationLetterUpload/$employeeId";
  }




  /// Time offf
  static String getEmployeeTimeOff(){
    return "$timeOff";
  }
  static String getEmployeePrefillTimeOff({required int employeeTimeOffId}){
    return "$timeOff/$employeeTimeOffId";
  }
  static String patchEmployeeTimeOff({required int timeOffId}){
    return "$timeOff/$timeOffId";
  }
  static String approveTimeOffPatch({required int employeeTimeOffId}){
    return"$timeOff/approve/$employeeTimeOffId";
  }
  static String rejectTimeOffPatch({required int employeeTimeOffId}){
    return"$timeOff/reject/$employeeTimeOffId";
  }
}