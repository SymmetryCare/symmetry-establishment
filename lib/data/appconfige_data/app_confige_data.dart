class FrontendConfigData {
  final int id;
  final String name;
  final FrontendConfig config;

  FrontendConfigData({
    required this.id,
    required this.name,
    required this.config,
  });
}



class FrontendConfig {
  final String misc;
  final String year;
  final String month;
  final String other;
  final String issuer;
  final int consent;
  final int salesId;
  final String scheduled;
  final int subDocId0;
  final int clinicalId;
  final int templateId;
  final int healthDocId;
  final int subDocId9MD;
  final int subDocId2Adr;
  final int subDocId7SNF;
  final int subDocId8DME;
  final String notApplicable;
  final int subDocId10MISC;
  final int employmentDocId;
  final int subDocId6Leases;
  final int vendorContracts;
  final int administrationId;
  final int performanceDocId;
  final int billingAttachment;
  final int compensationDocId;
  final int defaultAttachment;
  final int subDocId1Licenses;
  final int certificationDocId;
  final int subDocId4CapReport;
  final int subDocId5BalReport;
  final int clinicianAttachment;
  final int acknowledgementDocId;
  final int policiesAndProcedure;
  final int corporateAndCompliance;
  final int subDocId3CICCMedicalCR;
  final int clinicalVerificationDocId;
  final int empdocumentTypeMetaDataId;
  final int employeeDocumentTypeMetaDataId;

  FrontendConfig({
    required this.misc,
    required this.year,
    required this.month,
    required this.other,
    required this.issuer,
    required this.consent,
    required this.salesId,
    required this.scheduled,
    required this.subDocId0,
    required this.clinicalId,
    required this.templateId,
    required this.healthDocId,
    required this.subDocId9MD,
    required this.subDocId2Adr,
    required this.subDocId7SNF,
    required this.subDocId8DME,
    required this.notApplicable,
    required this.subDocId10MISC,
    required this.employmentDocId,
    required this.subDocId6Leases,
    required this.vendorContracts,
    required this.administrationId,
    required this.performanceDocId,
    required this.billingAttachment,
    required this.compensationDocId,
    required this.defaultAttachment,
    required this.subDocId1Licenses,
    required this.certificationDocId,
    required this.subDocId4CapReport,
    required this.subDocId5BalReport,
    required this.clinicianAttachment,
    required this.acknowledgementDocId,
    required this.policiesAndProcedure,
    required this.corporateAndCompliance,
    required this.subDocId3CICCMedicalCR,
    required this.clinicalVerificationDocId,
    required this.empdocumentTypeMetaDataId,
    required this.employeeDocumentTypeMetaDataId,
  });
}



class FrontendConfigStore {
  static FrontendConfigData? data;
}
