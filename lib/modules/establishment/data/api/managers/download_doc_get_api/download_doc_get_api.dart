import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:symmetry_establishment/app/services/api/api.dart';

Future<DownloadFileData?> getEmployeeDocumentByFileName(
    {required BuildContext context,
      required String fileName,
      required apiPath
    }
    ) async {
  try {
    final response = await Api(context).getBytes(
      path:"$apiPath",
      // path: EmployeeDocumentsRepository.getDocumentByFileName(fileName: fileName),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return DownloadFileData(
        fileName: fileName,
         bytes: response.data,
      );
    } else {
      print('Api Error');
      return null;
    }
  } on DioException catch (e) {
    print("Error ${e.response?.data['message'] ?? e.message}");
    return null;
  } catch (e) {
    print("Error $e");
    return null;
  }
}















class DownloadDocumentRepository {

  static String _employeeDocuments = '/employee-documents/documents';

  static String getDocumentByFileName() {
    return '$_employeeDocuments';
  }

  static String _appModuleMetaData = '/app-module-meta-data/documents';

  static String getAppModuleMetaDataDocumentByFileName() {
    return '$_appModuleMetaData';
  }

  static String _companyLogo = '/company-logo/documents';

  static String getCompanyLogoDocumentByFileName() {
    return '$_companyLogo';
  }

  static String _corporateDocument = '/corporate-document/documents';

  static String getCorporateDocumentByFileName() {
    return '$_corporateDocument';
  }

  static String _document = '/document/documents';

  static String getGenericDocumentByFileName() {
    return '$_document';
  }

  static String _drivingLicense = '/driving-license/documents';

  static String getDrivingLicenseDocumentByFileName() {
    return '$_drivingLicense';
  }

  static String _employeeBankings = '/employee-bankings/documents';

  static String getEmployeeBankingsDocumentByFileName() {
    return '$_employeeBankings';
  }

  static String _employeeEducations = '/employee-educations/documents';

  static String getEmployeeEducationsDocumentByFileName() {
    return '$_employeeEducations';
  }

  static String _employeeEmploymentHistories = '/employee-employment-histories/documents';

  static String getEmployeeEmploymentHistoriesDocumentByFileName() {
    return '$_employeeEmploymentHistories';
  }

  static String _employeeLegalDocument = '/employee-legal-document/documents';

  static String getEmployeeLegalDocumentByFileName() {
    return '$_employeeLegalDocument';
  }

  static String _employeeLicenses = '/employee-licenses/documents';

  static String getEmployeeLicensesDocumentByFileName() {
    return '$_employeeLicenses';
  }

  static String _employees = '/employees/documents';

  static String getEmployeesDocumentByFileName() {
    return '$_employees';
  }

  static String _feedback = '/feedback/documents';

  static String getFeedbackDocumentByFileName() {
    return '$_feedback';
  }

  static String _formHtmlTemplatesStatus = '/form-html-templates-status/documents';

  static String getFormHtmlTemplatesStatusDocumentByFileName() {
    return '$_formHtmlTemplatesStatus';
  }

  static String _hrTempleteSignatures = '/hr-templete-signatures/documents';

  static String getHrTempleteSignaturesDocumentByFileName() {
    return '$_hrTempleteSignatures';
  }

  static String _intakeLabReport = '/intake-lab-report/documents';

  static String getIntakeLabReportDocumentByFileName() {
    return '$_intakeLabReport';
  }

  static String _intakeMiscNote = '/intake-misc-note/documents';

  static String getIntakeMiscNoteDocumentByFileName() {
    return '$_intakeMiscNote';
  }

  static String _intakePatientCompliance = '/intake-patient-compliance/documents';

  static String getIntakePatientComplianceDocumentByFileName() {
    return '$_intakePatientCompliance';
  }

  static String _orgOfficeDocument = '/org-office-document/documents';

  static String getOrgOfficeDocumentByFileName() {
    return '$_orgOfficeDocument';
  }

  static String _othersDocs = '/others-docs/documents';

  static String getOthersDocsDocumentByFileName() {
    return '$_othersDocs';
  }

  static String _patientProtocol = '/patient-protocol/documents';

  static String getPatientProtocolDocumentByFileName() {
    return '$_patientProtocol';
  }

  static String _f2f = '/f2f/documents';

  static String getF2fDocumentByFileName() {
    return '$_f2f';
  }

  static String _patientDocument = '/patient-document/documents';

  static String getPatientDocumentByFileName() {
    return '$_patientDocument';
  }

  static String _patientReferral = '/patient-referral/documents';

  static String getPatientReferralDocumentByFileName() {
    return '$_patientReferral';
  }

  static String _signatureFormDocuments = '/signature-form-documents/documents';

  static String getSignatureFormDocumentByFileName() {
    return '$_signatureFormDocuments';
  }

  static String _patientInsuranceDocuments = '/patient-insurance-documents/documents';

  static String getPatientInsuranceDocumentByFileName() {
    return '$_patientInsuranceDocuments';
  }

  static String _physicianMaster = '/physician-master/documents';

  static String getPhysicianMasterDocumentByFileName() {
    return '$_physicianMaster';
  }

  static String _practitionerLicense = '/practitioner-license/documents';

  static String getPractitionerLicenseDocumentByFileName() {
    return '$_practitionerLicense';
  }

  static String _referralSources = '/referral-sources/documents';

  static String getReferralSourcesDocumentByFileName() {
    return '$_referralSources';
  }

  static String _users = '/users/documents';

  static String getUsersDocumentByFileName() {
    return '$_users';
  }

  static String _cliniciansChatImages = '/clinicians_chat/images';

  static String getCliniciansChatImageByFileName() {
    return '$_cliniciansChatImages';
  }

  static String _employeesChatImages = '/employees-chat/images';

  static String getEmployeesChatImageByFileName() {
    return '$_employeesChatImages';
  }

  static String _patientVisitsImages = '/patient-visits/images';

  static String getPatientVisitsImageByFileName() {
    return '$_patientVisitsImages';
  }

  static String _patientGroupImages = '/patient-group/images';

  static String getPatientGroupImageByFileName() {
    return '$_patientGroupImages';
  }

  static String _patientUserImages = '/patient-user/images';

  static String getPatientUserImageByFileName() {
    return '$_patientUserImages';
  }

  static String _patientGroupChatImages = '/patient-group-chat/images';

  static String getPatientGroupChatImageByFileName() {
    return '$_patientGroupChatImages';
  }

  static String _patientFormUploadImages = '/patient-form-upload/images';

  static String getPatientFormUploadImageByFileName() {
    return '$_patientFormUploadImages';
  }

  static String _supplyOrdersImages = '/supply-orders/images';

  static String getSupplyOrdersImageByFileName() {
    return '$_supplyOrdersImages';
  }
}










class DownloadFileData {
  final String fileName;
  final List<int> bytes;

  DownloadFileData({
    required this.fileName,
    required this.bytes,
  });
}