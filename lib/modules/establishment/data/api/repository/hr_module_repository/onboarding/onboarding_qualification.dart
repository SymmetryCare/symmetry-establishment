class OnboardingQualificationRepo {
  static String emp_employment = "/employee-employment-histories";
  static String education = "/employee-educations";
  static String byEmployeeId = "/ByemployeeId";
  static String references = "/reference";
  static String employee_licenses = "/employee-licenses";
  static String employee_banking = "/employee-bankings";
  static String employee_doc = "/employee-documents";
  static String approve = "/approve";
  static String reject = "/reject";
  static String batchreject = "/BatchReject";
  static String batchApprove = "/BatchApprove";
  static String formStatus = "/form-html-templates-status/status";

  /// /employee-employment-histories
  static String getEmpEmploymentHistories({required int employeeid, required String approveOnly}) {
    return "$emp_employment/ByemployeeId/$employeeid/$approveOnly";
  }

  static String rejectEmpEmployment({required int employmentId}) {
    return "$emp_employment/reject/$employmentId";
  }

  static String approveEmpEmployment({required int employmentId}){
    return "$emp_employment/approve/$employmentId";
  }

  /// /employee-educations
  static String getEmpEducation({required int employeeid, required String approveOnly}) {
    return "$education/$byEmployeeId/$employeeid/$approveOnly";
  }

  static String rejectEmpEducation({required int educationId}) {
    return "$education/reject/$educationId";
  }

  static String approveEmpEducation({required int educationId}){
    return "$education/approve/$educationId";
  }

  /// /reference
  static String getEmpReference({required int employeeid, required String approveOnly}) {
    return "$references/ByemployeeId/$employeeid/$approveOnly";
  }

  static String rejectEmpReference({required int referenceId}) {
    return "$references/reject/$referenceId";
  }

  static String approveEmpReference({required int referenceId}){
    return "$references/approve/$referenceId";
  }

  /// /employee-licenses
  static String getEmpLicense({required int employeeid, required String approveOnly}) {
    return "$employee_licenses/ByemployeeId/$employeeid/$approveOnly";
  }

  static String rejectEmpLicenses({required int licensedId}) {
    return "$employee_licenses/reject/$licensedId";
  }

  static String approveEmpLicenses({required int licensedId}){
    return "$employee_licenses/approve/$licensedId";
  }

  ///onboarding Banking
  static String getOnboardBanking({required int employeeid, required String approveOnly}) {
    return "$employee_banking/ByemployeeId/$employeeid/$approveOnly";
  }

  static String rejectOnboardBank({required int empBankingId}) {
    return "$employee_banking/reject/$empBankingId";
  }
  ///employee-bankings/{empBankingId}
  static String  getBankBYBankId({required int empBankingId}){
    return "$employee_banking/$empBankingId";
  }


  ///onboarding Acknowledment & health record
  //employee-documents/ByemployeeId/{EmployeeDocumentTypeMetaDataId}/{EmployeeDocumentTypeSetupId}/{employeeId}/approve-only
  static String getAckHealthRecord({required int EmpDocTypeMetaDataId, required int employeeId, required String approveOnly}) {
    return "$employee_doc$byEmployeeId/$EmpDocTypeMetaDataId/$employeeId/$approveOnly";
  }
  //employee-documents/approve/{employeeDocumentId}
  // static String approveAckHealthRecord({required int employeeDocumentId}) {
  //   return "$employee_doc$approve/$employeeDocumentId";
  // }
  //employee-documents/reject/{employeeDocumentId}
  // static String rejectAckHealthRecord({required int employeeDocumentId}) {
  //   return "$employee_doc$reject/$employeeDocumentId";
  // }
  ///employee-documents/BatchApprove
  static String batchApproveAckHealthRecord() {
    return "$employee_doc$batchApprove";
  }

  static String singlebatchApproveAckHealthRecord({required int empDocumentId}) {
    return "/employee-documents/approve/$empDocumentId";
  }

  ///employee-documents/BatchReject
  static String batchRejectAckHealthRecord() {
    return "$employee_doc$batchreject";
  }

  /// employee form status
  static String employeeFormStatusGet({required int employeeId}) {
    return "$formStatus/$employeeId";
  }
}
