class ClinicalLicensesRepo {
  static String drivingLicense = "/driving-license";
  static String practitionerLicense = "/practitioner-license";
  // static String practitionerLicense = "/practitioner-license";
  static String practitionerLicenseBase64 = "/practitioner-license/attach-documentbase64";
  static String practitionerLicenseUpdateBase64 = "/practitioner-license/update-documentbase64";
  static String drivingLicenseBase64 = "/driving-license/attach-documentbase64";
  static String drivingLicenseUpdateBase64 = "/driving-license/update-documentbase64";



  static String postDrivingLicense() {
    return "$drivingLicense";
  }

  static String postpractitionerLicense() {
    return "$practitionerLicense";
  }

  static String postpractitionerLicensebase64({required int practitionerLicenceId }) {
    return "$practitionerLicenseBase64/$practitionerLicenceId";
  }

  static String postpractitionerUpdateLicensebase64({required int practitionerLicenceId }) {
    return "$practitionerLicenseUpdateBase64/$practitionerLicenceId";
  }

  static String postdrivingLicensebase64({required int drivingLicenceId }) {
    return "$drivingLicenseBase64/$drivingLicenceId";
  }

  static String postdrivingLicenseUpdatebase64({required int drivingLicenceId }) {
    return "$drivingLicenseUpdateBase64/$drivingLicenceId";
  }
  static String getDrivingLicenseByEmpId({required int employeeId, required String approve}) {
    return "$drivingLicense/ByemployeeId/$employeeId/$approve";
  }
  static String patchDrivingLicenseApprove({required int licenseId,}) {
    return "$drivingLicense/approve/$licenseId";
  }
  static String patchDrivingLicenseReject({required int licenseId,}) {
    return "$drivingLicense/reject/$licenseId";
  }
  static String deleteDrivingLicense({required String docId,}) {
    return "$drivingLicense/$docId";
  }
  static String DrivingLicensePrefillAndPatch({required String docId,}) {
    return "$drivingLicense/$docId";
  }

  /// PractitionerLicense
  static String getPractitionerLicenseByEmpId({required int employeeId, required String approve}) {
    return "$practitionerLicense/ByemployeeId/$employeeId/$approve";
  }
  static String patchPractitionerLicenseApprove({required int licenseId,}) {
    return "$practitionerLicense/approve/$licenseId";
  }
  static String patchPractitionerLicenseReject({required int licenseId,}) {
    return "$practitionerLicense/reject/$licenseId";
  }
  static String deletePractitionerLicense({required String docId,}) {
    return "$practitionerLicense/$docId";
  }
  static String practitionerLicensePrefillAndPatch({required String docId,}) {
    return "$practitionerLicense/$docId";
  }
}