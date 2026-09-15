class LegalDocumentsRepo{
  static String onCallDocument = "/call-html";
  static String covidTestDocument = "/covid-test-policy-html";
  static String ConfidentialStatementDocument = "/confidentiality-statement-html";
  static String reportingAbuseDocument = "/reporting-abuse";
  static String candidateReleaseDocument = "/candidate-release-form";
  static String policyConcerningDocument = "/policy-concerning-third-party";
  static String standardConductDocument = "/standards-of-conduct";
  static String sexualHaressmentDocument = "/california-sexual-harassment";
  static String sexualAndUnlawfulDocument = "/sexual-and-other-unlawful/template";
  static String preAuthPatientVisitsDocument = "/pre-authorized-patient-visits";
  static String pro65Document = "/prop-65";
  static String returnOfCompanyDocument = "/return-of-company-property";
  static String hepBDocument = "/hep-b-declination-form";
  static String tDapDocument = "/tdap-declination-form";
  static String proHealthCellPhoneStatement = "/pro-health-cell-phone-usage-statement";
  static String covidVaccineDocument = "/february-covid-vaccination-policy-mandatory";
  static String htmlFormTemplateSignatureAdd = "/form-html-templates-status/add/employee/form/Signatures";
  static String directDepositDocument = "/direct-deposit/generate-template";
  static String proHealthEmployeeHandbookDocument = "/pro-health-employee-handbook";
  static String fluVaccineDocument = "/flu-vaccine-form";
  static String w4Document = "/w4";
  static String i9Document = "/i-9";
  static String empAppDocument = "/employment-application";



  ///users/ByCompanyId/{companyId}
  static String getOnCallDocument({required int callHtmlId,required int employeeId}){
    return "$onCallDocument/$callHtmlId/$employeeId";

  }
  static String getCandidateReleaseDocument({required int candidateReleaseFormhtmlId,required int employeeId,required String middleName, required String maindenSurnameAlisa,
    required String currentAddress,required String stateIssuingLicense, required String fullname}){
    return "$candidateReleaseDocument/$candidateReleaseFormhtmlId/$employeeId/$middleName/$maindenSurnameAlisa/$currentAddress/$stateIssuingLicense/$fullname";
  }
  static String getCovidTestPolicyDocument({required int covidTestId,required int employeeId}){
    return "$covidTestDocument/$covidTestId/$employeeId";
  }
  static String getConfidentialStatementDocument({required int confidentialId,required int employeeId}){
    return "$ConfidentialStatementDocument/$confidentialId/$employeeId";
  }
  static String getreportingAbuseDocument({required int reportingAbuseId,required int employeeId}){
    return "$reportingAbuseDocument/$reportingAbuseId/$employeeId";
  }
  static String getpolicyConcerningDocument({required int policyConcerningId,required int employeeId}){
    return "$policyConcerningDocument/$policyConcerningId/$employeeId";
  }
  static String getStandardConductDocument({required int standardConductId,required int employeeId}){
    return "$standardConductDocument/$standardConductId/$employeeId";
  }
  static String getSexualHaressmentDocument({required int templateId,required int employeeId}){
    return "$sexualHaressmentDocument/$templateId/$employeeId";
  }
  static String getSexualAndUnlawfulDocument({required int templateId,required int employeeId}){
    return "$sexualAndUnlawfulDocument/$templateId/$employeeId";
  }
  static String getPreAuthPatientVisitsDocument({required int templateId,required int employeeId}){
    return "$preAuthPatientVisitsDocument/$templateId/generate-html/$employeeId";
  }
  static String getPro65Document({required int templateId,required int employeeId}){
    return "$pro65Document/$templateId/generate-html/$employeeId";
  }
  static String getReturnOfCompanyDocument({required int templateId,required int employeeId, required String companyProperty,
    required String specifications,
    // required String supervisorName
  }){
    return "$returnOfCompanyDocument/$templateId/generate-html/$employeeId/$companyProperty/$specifications";
  }
  static String getHepBDocument({required int templateId,required int employeeId}){
    return "$hepBDocument/$templateId/generate-html/$employeeId";
  }
  static String getTDapDocument({required int templateId,required int employeeId}){
    return "$tDapDocument/$templateId/generate-html/$employeeId";
  }
  static String getCovidVaccineDocument({required int templateId,required int employeeId}){
    return "$covidVaccineDocument/$templateId/generate-html/$employeeId";
  }
  static String getDirectDepositDocument({required int templateId,required int employeeId}){
    return "$directDepositDocument/$templateId/$employeeId";
  }
  static String getProHealthCellPhoneStatement({required int templateId,required int employeeId}){
    return "$proHealthCellPhoneStatement/$templateId/generate-html/$employeeId";
  }
  static String postHemlTemplateFormSignature(){
    return "$htmlFormTemplateSignatureAdd";
  }
  static String getProHealthEmployeeHandbook({required int handBookId,required int employeeId}){
    return "$proHealthEmployeeHandbookDocument/$handBookId/$employeeId";
  }

  static String getFluVaccineDocument({required int templateId,required int employeeId,required String dateofVaccination,required String siteOfAdministration, required String vaccineType, required String dose,
   required String reactions, required String manufacturer, required String nameOfAdministering, required String title, required String providerAddress, required String acknowledgeFacts, required String Allergis, required String other}){
    return
      "$fluVaccineDocument/$templateId/generate-html/$employeeId/$vaccineType/$reactions/$dateofVaccination/$siteOfAdministration/$dose/$manufacturer/$nameOfAdministering/$title/$providerAddress/$acknowledgeFacts/$Allergis/$other";
  }

  ////flu-vaccine-form/{templateId}/generate-html/{employeeId}/{vaccineType}/{reactions}/{dateOfvaccination}/{siteOfAdministration}/{dose}/{manufacturer}/{nameOfAdministering}/{title}/{providerAddress}/{acknowledgeFacts}/{Allergis}/{other}



  static String getW4Documents({required int templateId,required int employeeId, required String middleName,
    required String marriedstatus, required int step3a,required int step3b,required int step3c,required int step4a,
    required int step4b,required int step4c, required int multipleJW1,required int multipleJW12a,required int multipleJW12b,
    required int multipleJW12c,required int multipleJW13,required int multipleJW14,required int deductionsWorksheet1,required int deductionsWorksheet2,
    required int deductionsWorksheet3,required int deductionsWorksheet4,required int deductionsWorksheet5,}){
    return "$w4Document/$templateId/$employeeId/$marriedstatus/$step3a/$middleName/$step3b/$step3c/$step4a/$step4b/$step4c/$multipleJW1/$multipleJW12a/$multipleJW12b/$multipleJW12c/$multipleJW13/$multipleJW14/$deductionsWorksheet1/$deductionsWorksheet2/$deductionsWorksheet3/$deductionsWorksheet4/$deductionsWorksheet5";
  }

  ///i-9/{i9FormhtmlId}/{employeeId}/{middleName}/{otherLastName}/{aptNumber}/{alienInfo}/{citizenship}
  static String getINineDocument({required int i9FormhtmlId,required int employeeId, required String middleName,
    required String otherLastName, required String aptNumber,required String alienInfo,required String citizenship, required String alienDate}){
    return "$i9Document/$i9FormhtmlId/$employeeId/$middleName/$otherLastName/$aptNumber/$alienInfo/$citizenship/$alienDate";
}

///employment-application/{employmentAppFormhtmlId}/{employeeId}/{middleName}/{faxNo}/{ifHired}/{positionApplying}/{positionDesired}/
///{dateAvailable}/{specifyWorkingHrs}/{salary}/{sourceReferral}/{value}
 static String getEmplAppDocument({required int employmentAppFormhtmlId,required int employeeId, required String middleName,
   required String faxNo, required String ifHired,required String positionApplying,required String positionDesired,required String dateAvailable,
   required String specifyWorkingHrs, required String salary,required String sourceReferral,required String value}){
    return "$empAppDocument/$employmentAppFormhtmlId/$employeeId/$middleName/$faxNo/$ifHired/$positionApplying/$positionDesired/$dateAvailable/$specifyWorkingHrs/$salary/$sourceReferral/$value";
}
}
