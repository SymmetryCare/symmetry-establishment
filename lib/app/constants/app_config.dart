import 'package:flutter_dotenv/flutter_dotenv.dart';

///demo instance
// class AppConfig {
//   // static const String dev =  "https://demoapp.symmetry.care";
//   // // static const String dev = "https://resource.symmetry.care";
//   // static const String demo = "https://demoapp.symmetry.care"; /// old
//   // static const String demo = "https://demo.symmetry.care/api";
//   // static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   // static const String deployment = "https://staging.symmetry.care";
//   // static const String version = "Version 1.0.1 (1) demo";
//   ///
//   // static const String dev =  "https://demoapp.symmetry.care";
//   // static const String dev = "https://resource.symmetry.care";
//   // static const String demo = "https://demoapp.symmetry.care";/// old instance 2024
//   static const String demo = "https://demo.symmetry.care"; /// demo new instance 2025
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String deployment = "https://staging.symmetry.care";
//   static const String version = "Version 1.1.1 (7) demo";
//   ///
//   static const String local = "";
//   static const String prod = "";
//   static const String endpoint = demo;
//   static const String dash = '-';
//   static const int templateId = 2;
//   /// Document type
//   static const int corporateAndCompliance = 1;
//   static const int vendorContracts = 2;
//   static const int policiesAndProcedure = 3;
//   ///CCD
//   static const int subDocId1Licenses = 1;
//   static const int subDocId2Adr = 2;
//   static const int subDocId3CICCMedicalCR = 3;
//   static const int subDocId4CapReport = 4;
//   static const int subDocId5BalReport = 5;
//   ///VC
//   static const int subDocId6Leases = 6;
//   static const int subDocId7SNF = 7;
//   static const int subDocId8DME = 8;
//   static const int subDocId9MD = 9;
//   static const int subDocId10MISC = 10;
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 5;
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 4;
//   static const int acknowledgementDocId = 5;
//   static const int compensationDocId = 6;
//   static const int performanceDocId = 7;
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
//   static const String other = "Other";
// ///SM
//  static const int clinicianAttachment = 1;
//  static const int billingAttachment = 2;
//  static const int consent = 3;
//  static const int defaultAttachment = 0;
// }
///
///
///
///dev instance

class AppConfig {
  static String get googleApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ??
      "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
  static const String dash = '-';

  static const String _rawEndpoint = String.fromEnvironment(
    'API_ENDPOINT',
    defaultValue: 'https://demo.symmetry.care',
  );

  static const String version =
      String.fromEnvironment('APP_VERSION', defaultValue: '');

  /// Returns the full endpoint URL.
  /// If API_ENDPOINT is a relative path (e.g. /api), it prepends the browser origin.
  /// If it's an absolute URL (e.g. https://example.com/api), it's used as-is.
  static String get endpoint {
    if (_rawEndpoint.startsWith('/')) {
      // Web: use the browser's current origin
      final origin = Uri.base.origin; // e.g. "https://myapp.com"
      return '$origin$_rawEndpoint'; // e.g. "https://myapp.com/api"
    }
    return _rawEndpoint;
  }

  static String get versionLabel => 'Version $version';

  static void validate() {
    assert(_rawEndpoint.isNotEmpty,
        '❌ API_ENDPOINT must not be empty. Use --dart-define=API_ENDPOINT=/api');
    assert(version.isNotEmpty,
        '❌ APP_VERSION is required. Use --dart-define=APP_VERSION=1.1.4');
  }
}

///
// class AppConfig {
//   // static const String demo = "https://demoapp.symmetry.care"; ///old instance
//   // static const String dev = "http://35.165.254.214:3033";
//   // static const String dev = "http://50.112.139.35:3000/"; // new dev
//   // static const String dev = "https://dev.symmetry.care"; ///new dev
//   // static const String dev = "https://auric-whirly-shannan.ngrok-free.dev";
//   static const String dev = "https://dev.symmetry.care";
//
//   // static const String local = "http://localhost:3000";
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   // static const String deployment = "https://prohealth.symmetry.care";
//   static const String deployment = "https://staging.symmetry.care";
//  static const String version = "Version 1.1.4 (1) dev";
//  static const String local = "";
//   static const String prod = "";
//   static const String endpoint = dev;
//   static const String dash = '-';
//
//
//  // static const int templateId = 1;
//
//   /// Document types
//  // static const int corporateAndCompliance = 8;
//   //static const int vendorContracts = 9;
//   //static const int policiesAndProcedure = 10;
//
//   ///CCD
//  // static const int subDocId1Licenses = 11;
//   //static const int subDocId2Adr = 12;
//  // static const int subDocId3CICCMedicalCR = 13;
//   //static const int subDocId4CapReport = 14;
//   //static const int subDocId5BalReport = 15;
//
//   ///VC
//   //static const int subDocId6Leases = 16;
//   //static const int subDocId7SNF = 17;
//   //static const int subDocId8DME = 18;
//   //static const int subDocId9MD = 19;
//   //static const int subDocId10MISC = 20;
//
//   /// Policies & procedures
//   //static const int subDocId0 = 0;
//
//   ///health record form
//   //static const int empdocumentTypeMetaDataId = 1;
//  // static const int employeeDocumentTypeMetaDataId = 5;//10;
//
//   ///Employee Document types
//  // static const int healthDocId = 1;
//  // static const int certificationDocId = 2;
//   //static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//  // static const int clinicalVerificationDocId = 9;
//  //  static const int acknowledgementDocId = 5;//10;
//  //  static const int compensationDocId = 11;
//  //  static const int performanceDocId = 12;
//
//   /// All From HR EM
//   //static const int clinicalId = 1;
//   //static const int salesId = 2;
//   //static const int AdministrationId = 3;
//
//   /// org string
//   //static const String notApplicable = "Not Applicable";
//   // static const String scheduled = "Scheduled";
//   // static const String issuer = "Issuer Expiry";
//   // static const String year = "Year";
//   // static const String month = "Month";
//   // static const String misc = "MISC";
//
//   ///SM
//   // static const int defaultAttachment = 0;
//   // static const int clinicianAttachment = 1;
//   // static const int billingAttachment = 2;
//   // static const int consent = 3;
// }

///
///
///
///worker instance
// class AppConfig {
//   // static const String dev =  "https://demoapp.symmetry.care";
//   // static const String dev = "https://resource.symmetry.care";
//   // static const String demo = "https://demoapp.symmetry.care";
//   static const String prod = "https://worker.symmetry.care";
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String version = "Version 1.0.1 (7) prod";
//   ///
//   static const String local = "";
//   static const String endpoint = prod;
//   static const String dash = '-';
//   static const int templateId = 2;
//
//   /// Document type
//   static const int corporateAndCompliance = 1;
//   static const int vendorContracts = 2;
//   static const int policiesAndProcedure = 3;
//
//   ///CCD
//   static const int subDocId1Licenses = 1;
//   static const int subDocId2Adr = 2;
//   static const int subDocId3CICCMedicalCR = 3;
//   static const int subDocId4CapReport = 4;
//   static const int subDocId5BalReport = 5;
//
//   ///VC
//   static const int subDocId6Leases = 6;
//   static const int subDocId7SNF = 7;
//   static const int subDocId8DME = 8;
//   static const int subDocId9MD = 9;
//   static const int subDocId10MISC = 10;
//
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 5;
//
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 4;
//   static const int acknowledgementDocId = 5;
//   static const int compensationDocId = 6;
//   static const int performanceDocId = 7;
//
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
//   static const String other = "Other";
//
// /// SM
//   static const int defaultAttachment = 0;
//   static const int clinicianAttachment = 1;
//   static const int billingAttachment = 2;
//   static const int consent = 3;
// }

///local host
// class AppConfig {
//   static const String local = "http://localhost:3000";
//   static const String demo = "https://demoapp.symmetry.care";
//   static const String dev = "https://resource.symmetry.care";
//
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String deployment = "https://prohealth.symmetry.care";
//   static const String version = "Version 1.0.1 (1) local";
//   // static const String local = "";
//   static const String prod = "";
//   static const String endpoint = local;
//   static const String dash = '-';
//   static const int templateId = 1;
//
//   /// Document types
//   static const int corporateAndCompliance = 8;
//   static const int vendorContracts = 9;
//   static const int policiesAndProcedure = 10;
//
//   ///CCD
//   static const int subDocId1Licenses = 11;
//   static const int subDocId2Adr = 12;
//   static const int subDocId3CICCMedicalCR = 13;
//   static const int subDocId4CapReport = 14;
//   static const int subDocId5BalReport = 15;
//
//   ///VC
//   static const int subDocId6Leases = 16;
//   static const int subDocId7SNF = 17;
//   static const int subDocId8DME = 18;
//   static const int subDocId9MD = 19;
//   static const int subDocId10MISC = 20;
//
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 10;
//
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 9;
//   static const int acknowledgementDocId = 10;
//   static const int compensationDocId = 11;
//   static const int performanceDocId = 12;
//
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
// ///SM
// static const int clinicianAttachment = 1;
// static const int billingAttachment = 2;
// static const int consent = 3;
// }

///demo instance
// class AppConfig {
//   // static const String dev =  "https://demoapp.symmetry.care";
//   static const String dev = "https://resource.symmetry.care";
//   static const String demo = "https://demoapp.symmetry.care";
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String deployment = "https://staging.symmetry.care";
//   static const String version = "Version 1.0.1 (2) demo";
//   ///
//   static const String local = "";
//   static const String prod = "";
//   static const String endpoint = demo;
//   static const String dash = '-';
//   static const int templateId = 2;
//   /// Document type
//   static const int corporateAndCompliance = 1;
//   static const int vendorContracts = 2;
//   static const int policiesAndProcedure = 3;
//   ///CCD
//   static const int subDocId1Licenses = 1;
//   static const int subDocId2Adr = 2;
//   static const int subDocId3CICCMedicalCR = 3;
//   static const int subDocId4CapReport = 4;
//   static const int subDocId5BalReport = 5;
//   ///VC
//   static const int subDocId6Leases = 6;
//   static const int subDocId7SNF = 7;
//   static const int subDocId8DME = 8;
//   static const int subDocId9MD = 9;
//   static const int subDocId10MISC = 10;
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 5;
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 4;
//   static const int acknowledgementDocId = 5;
//   static const int compensationDocId = 6;
//   static const int performanceDocId = 7;
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
//   static const String other = "Other";
// }

///dev instance
// class AppConfig {
//   static const String demo = "https://demoapp.symmetry.care";
//   static const String dev = "https://resource.symmetry.care";
//   // static const String local = "http://localhost:3000";
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   // static const String deployment = "https://prohealth.symmetry.care";
//   static const String deployment = "https://staging.symmetry.care";
//   static const String version = "Version 1.0.1 (8) dev";
//   static const String local = "";
//   static const String prod = "";
//   static const String endpoint = dev;
//   static const String dash = '-';
//   static const int templateId = 1;
//
//   /// Document types
//   static const int corporateAndCompliance = 8;
//   static const int vendorContracts = 9;
//   static const int policiesAndProcedure = 10;
//
//   ///CCD
//   static const int subDocId1Licenses = 11;
//   static const int subDocId2Adr = 12;
//   static const int subDocId3CICCMedicalCR = 13;
//   static const int subDocId4CapReport = 14;
//   static const int subDocId5BalReport = 15;
//
//   ///VC
//   static const int subDocId6Leases = 16;
//   static const int subDocId7SNF = 17;
//   static const int subDocId8DME = 18;
//   static const int subDocId9MD = 19;
//   static const int subDocId10MISC = 20;
//
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 5;//10;
//
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 9;
//   static const int acknowledgementDocId = 5;//10;
//   static const int compensationDocId = 11;
//   static const int performanceDocId = 12;
//
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
// }

///worker instance
// class AppConfig {
//   // static const String dev =  "https://demoapp.symmetry.care";
//   // static const String dev = "https://resource.symmetry.care";
//   // static const String demo = "https://demoapp.symmetry.care";
//   static const String prod = "https://worker.symmetry.care";
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String version = "Version 1.0.1 (5) prod";
//
//   ///
//   static const String local = "";
//
//   static const String endpoint = prod;
//   static const String dash = '-';
//   static const int templateId = 2;
//
//   /// Document type
//   static const int corporateAndCompliance = 1;
//   static const int vendorContracts = 2;
//   static const int policiesAndProcedure = 3;
//
//   ///CCD
//   static const int subDocId1Licenses = 1;
//   static const int subDocId2Adr = 2;
//   static const int subDocId3CICCMedicalCR = 3;
//   static const int subDocId4CapReport = 4;
//   static const int subDocId5BalReport = 5;
//
//   ///VC
//   static const int subDocId6Leases = 6;
//   static const int subDocId7SNF = 7;
//   static const int subDocId8DME = 8;
//   static const int subDocId9MD = 9;
//   static const int subDocId10MISC = 10;
//
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 5;
//
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 4;
//   static const int acknowledgementDocId = 5;
//   static const int compensationDocId = 6;
//   static const int performanceDocId = 7;
//
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
//   static const String other = "Other";
// }

///local host
// class AppConfig {
//   static const String local = "http://localhost:3000";
//   static const String demo = "https://demoapp.symmetry.care";
//   static const String dev = "https://resource.symmetry.care";
//
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//   static const String deployment = "https://prohealth.symmetry.care";
//   static const String version = "Version 1.0.1 (1) local";
//   // static const String local = "";
//   static const String prod = "";
//   static const String endpoint = local;
//   static const String dash = '-';
//   static const int templateId = 1;
//
//   /// Document types
//   static const int corporateAndCompliance = 8;
//   static const int vendorContracts = 9;
//   static const int policiesAndProcedure = 10;
//
//   ///CCD
//   static const int subDocId1Licenses = 11;
//   static const int subDocId2Adr = 12;
//   static const int subDocId3CICCMedicalCR = 13;
//   static const int subDocId4CapReport = 14;
//   static const int subDocId5BalReport = 15;
//
//   ///VC
//   static const int subDocId6Leases = 16;
//   static const int subDocId7SNF = 17;
//   static const int subDocId8DME = 18;
//   static const int subDocId9MD = 19;
//   static const int subDocId10MISC = 20;
//
//   /// Policies & procedures
//   static const int subDocId0 = 0;
//
//   ///health record form
//   static const int empdocumentTypeMetaDataId = 1;
//   static const int employeeDocumentTypeMetaDataId = 10;
//
//   ///Employee Document types
//   static const int healthDocId = 1;
//   static const int certificationDocId = 2;
//   static const int employmentDocId = 3;
//   // IDs 4, 5, 6, 7 are deleted
//   static const int clinicalVerificationDocId = 9;
//   static const int acknowledgementDocId = 10;
//   static const int compensationDocId = 11;
//   static const int performanceDocId = 12;
//
//   /// All From HR EM
//   static const int clinicalId = 1;
//   static const int salesId = 2;
//   static const int AdministrationId = 3;
//
//   /// org string
//   static const String notApplicable = "Not Applicable";
//   static const String scheduled = "Scheduled";
//   static const String issuer = "Issuer Expiry";
//   static const String year = "Year";
//   static const String month = "Month";
//   static const String misc = "MISC";
// }
