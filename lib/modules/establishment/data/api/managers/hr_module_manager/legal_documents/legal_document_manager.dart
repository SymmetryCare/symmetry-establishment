import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/services/api/api_offer.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/Register/legal_document_repo.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/form_repository/form_general_repo.dart';
import 'package:symmetry_establishment/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';

/// Signature Form
Future<ApiDataRegister> htmlFormTemplateSignature({
  required BuildContext context,
  required int formHtmlTempId,
  required String htmlName,
  required String documentFile,
  required int employeeId,
  required bool signed,
}) async {
  try {
    // String documents = await
    // AppFilePickerBase64.getEncodeHTML(
    //     html: documentFile);
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "formHtmlTemplatesId": formHtmlTempId,
      "htmlname": htmlName,
      "base64": documentFile,
      "employeeId": employeeId,
      "createdAt": DateTime.now().toIso8601String()+"Z",
      "company_Id": companyId,
      "signed": signed
    };
    print('All sign data ${data}');

    var response = await ApiOffer(context).post(
      path: LegalDocumentsRepo.postHemlTemplateFormSignature(),
      data: {
        "formHtmlTemplatesId": formHtmlTempId,
        "htmlname": htmlName,
        "base64": documentFile,
        "employeeId": employeeId,
        "createdAt": DateTime.now().toIso8601String()+"Z",
        "company_Id": companyId,
        "signed": signed
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Html form Signature Added");
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      print('Error response ${response.data['message']}');
      return ApiDataRegister(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiDataRegister(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// OnCall Document
Future<OnCallDocument> getLegalOnCallDocument(
    {required BuildContext context,
    required int callHtmlId,
    required int employeeId}) async {
//var itemList ;
  var itemsData;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getOnCallDocument(
            callHtmlId: callHtmlId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('OnCall Document Fetched');
      itemsData = OnCallDocument(
          onCallId: response.data['id'],
          html: response.data['html'],
          name: response.data['name']
      );
    } else {
      print("OnCall Document ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// CovidTestPolicy Document
Future<CovidTestPolicyDocument> getLegalCovidTestPolicyDocument(
    {required BuildContext context,
    required int covidTestId,
    required int employeeId}) async {
//var itemList ;
  var itemsData;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getCovidTestPolicyDocument(
            covidTestId: covidTestId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('covidTest Document Fetched');
      itemsData = CovidTestPolicyDocument(
          covidTestPolicyId: response.data['id'],
          name: response.data['name'],
          html: response.data['html']);
    } else {
      print("covidTest Document ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// ConfidentialStatement Document
Future<ConfidentialStatementDocument> getLegalConfidentialStatementDocument(
    {required BuildContext context,
    required int ConfidentialStatementId,
    required int employeeId}) async {
//var itemList ;
  var itemsData;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getConfidentialStatementDocument(
            confidentialId: ConfidentialStatementId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('confidentialDocument Fetched');
      itemsData = ConfidentialStatementDocument(
          confidentialStatementId: response.data['id'],
          name: response.data['name'],
          html: response.data['html']);
    } else {
      print("confidentialDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// reportingAbuseDocument
Future<ReportingAbuseDocument> getLegalReportingAbuseDocumentDocument(
    {required BuildContext context,
    required int reportingAbuseId,
    required int employeeId}) async {
//var itemList ;
  var itemsData;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getreportingAbuseDocument(
            reportingAbuseId: reportingAbuseId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('reportingAbuseDocument Fetched');
      itemsData = ReportingAbuseDocument(
          reportingAbuseId: response.data['id'],
          name: response.data['name'],
          html: response.data['html']);
    } else {
      print("reportingAbuseDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// policyConcerningDocument
Future<PolicyConcerningDocument> getLegalpolicyConcerningDocument(
    {required BuildContext context,
    required int policyConcerningId,
    required int employeeId}) async {
//var itemList ;
  var itemsData;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getpolicyConcerningDocument(
            policyConcerningId: policyConcerningId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('policyConcerning document Fetched');
      itemsData = PolicyConcerningDocument(
          policyConcerningId: response.data['id'],
          name: response.data['name'],
          html: response.data['html']);
    } else {
      print("policyConcerningDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Candidates reales form
Future<CandidateRealeaseDocument> getCandidateRealeaseDocument({
  required BuildContext context, required int candidateReleaseFormhtmlId,
  required int employeeId, required String middleName, required String maindenSurnameAlisa,
  required String currentAddress, required String stateIssuingLicense, required String fullName}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getCandidateReleaseDocument(employeeId: employeeId, candidateReleaseFormhtmlId: candidateReleaseFormhtmlId,
            middleName: middleName, maindenSurnameAlisa: maindenSurnameAlisa, currentAddress: currentAddress, stateIssuingLicense: stateIssuingLicense, fullname: fullName));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Candidate Release Document Fetched');
      itemsData = CandidateRealeaseDocument(candidateRealeaseId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("CandidateReleaseDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Standard of conduct form
Future<StandardConductDocument> getStandardConductDocument({
  required BuildContext context, required int standardConductId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getStandardConductDocument(standardConductId: standardConductId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('StandardConduct document Fetched');
      itemsData = StandardConductDocument(standardConductId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("StandardConductDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Sexual Haressment document
Future<SexualHaressmentDocument> getSexualHaressmentDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getSexualHaressmentDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('SexualHaressment document Fetched');
      itemsData = SexualHaressmentDocument(sexualHaressmentId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("SexualHaressmentDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Sexual And Unlawful Document
Future<SexualAndUnlawfulDocument> getSexualAndUnlawfulDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getSexualAndUnlawfulDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('SexualAndUnlawful document Fetched');
      itemsData = SexualAndUnlawfulDocument(sexualUnlawfulId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("SexualAndUnlawfulDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Pre auth patient visits
Future<PreAuthPatientVisitsDocument> getPreAuthPatientVisitsDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getPreAuthPatientVisitsDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Pre Auth Patient Visits document Fetched');
      itemsData = PreAuthPatientVisitsDocument(preAuthPatientId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("PreAuthPatientVisitsDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Pro 65 document
Future<ProDocument> getPro65Document({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getPro65Document(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Pro 65 Document Fetched');
      itemsData = ProDocument(proDocumentId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("ProDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// return of company property
Future<ReturnOfCompanyProperty> getReturnOfCompanyPropertyDocument({
  required BuildContext context, required int templateId,required int employeeId,
  required String companyProperty,
  required String specifications,
  // required String supervisorName
}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getReturnOfCompanyDocument(templateId: templateId, employeeId: employeeId, companyProperty: companyProperty, specifications: specifications,
            // supervisorName: supervisorName
        ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Return Of Company Property Fetched');
      itemsData = ReturnOfCompanyProperty(returnOfCompanyPropertyId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("ReturnOfCompanyPropertyDocument ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Hep B document
Future<HepBDocuemnt> getHepBDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getHepBDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Hep B DocuemntFetched');
      itemsData = HepBDocuemnt(hepBDocuemntId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("HepBDocuemnt ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// T Dap document
Future<TDapDocuemnt> getTDapDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getTDapDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' T Dap Docuemnt Fetched');
      itemsData = TDapDocuemnt(tDapDocuemnttId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("TDapDocuemnt ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Covid Vaccine document
Future<CovidVaccineDocuemnt> getCovidVaccineDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getCovidVaccineDocument(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Covid Vaccine Docuemnt Fetched');
      itemsData = CovidVaccineDocuemnt(covidVaccineDocuemntId: response.data['id'], name: response.data['name'], html: response.data['html']);
    } else {
      print("CovidVaccineDocuemnt ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Direct Deposit Docuemnt
Future<DirectDepositDocuemnt> getDirectDepositDocument({
  required BuildContext context, required int templateId,required int employeeId,
   }) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getDirectDepositDocument(templateId: templateId, employeeId: employeeId ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Direct Deposit Docuemnt Fetched');
      itemsData = DirectDepositDocuemnt(directDepositDocuemntId: response.data['id'],
          name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("DirectDepositDocuemnt ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

/// Pro health cell document
Future<ProHealthCellPhoneStatement> getProHealthCellPhoneStatementDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getProHealthCellPhoneStatement(templateId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Covid Vaccine Docuemnt Fetched');
      itemsData = ProHealthCellPhoneStatement(proHealthCellPhoneStatementId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("CovidVaccineDocuemnt ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


/// Pro health employee handBook
Future<ProHealthEmployeeHandbook> getProHealthEmployeeHandbookDocument({
  required BuildContext context, required int templateId,required int employeeId}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getProHealthEmployeeHandbook(handBookId: templateId, employeeId: employeeId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Pro Health Employee Handbook Docuemnt Fetched');
      itemsData = ProHealthEmployeeHandbook(proHealthEmployeeHandbookId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("ProHealthEmployeeHandbook ");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


/// Flu Vaccine Document
Future<FluVaccineDocument> getFluVaccineDocument({
  required BuildContext context, required int templateId,required int employeeId,
  required String dateOfVaccine,required String siteOfAdministration, required String vaccineType,
  required String dose,required String reactions, required String manufacturer, required String dateofVaccination,
  required String nameOfAdministering, required String title, required String providerAddress, required String acknowledgeFacts,
  required String Allergis, required String other}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getFluVaccineDocument(templateId: templateId, employeeId: employeeId,
            siteOfAdministration: siteOfAdministration, vaccineType: vaccineType, dose: dose, reactions: reactions,
            manufacturer: manufacturer, dateofVaccination: dateofVaccination, nameOfAdministering: nameOfAdministering,
            title: title, providerAddress: providerAddress, acknowledgeFacts: acknowledgeFacts, Allergis: Allergis, other: other));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(' Flu Vaccine Docuemnt Fetched');
      itemsData = FluVaccineDocument(fluVaccineDocumentId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("FluVaccineDocument");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}


/// W 4 document
Future<WFourDocument> getW4Document({
  required BuildContext context, required int templateId,required int employeeId, required String middleName,
  required String marriedStatus, required int step3a,required int step3b,required int step3c,required int step4a,
  required int step4b,required int step4c, required int multipleJW1,required int multipleJW12a,required int multipleJW12b,
  required int multipleJW12c,required int multipleJW13,required int multipleJW14,required int deductionsWorksheet1,required int deductionsWorksheet2,
  required int deductionsWorksheet3,required int deductionsWorksheet4,required int deductionsWorksheet5,}) async {
//var itemList ;
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo
            .getW4Documents(templateId: templateId, employeeId: employeeId, middleName: middleName, marriedstatus: marriedStatus, step3a: step3a, step3b: step3b,
            step3c: step3c, step4a: step4a, step4b: step4b, step4c: step4c, multipleJW1: multipleJW1, multipleJW12a: multipleJW12a, multipleJW12b: multipleJW12b,
          multipleJW12c: multipleJW12c, multipleJW13: multipleJW13, multipleJW14: multipleJW14, deductionsWorksheet1: deductionsWorksheet1, deductionsWorksheet2: deductionsWorksheet2,
          deductionsWorksheet3: deductionsWorksheet3, deductionsWorksheet4: deductionsWorksheet4, deductionsWorksheet5: deductionsWorksheet5,
        ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('w4 Docuemnt Fetched');
      itemsData = WFourDocument(wFourDocumentId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("WFourDocument");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

///Employment Application
Future<EmploymentAppDocument> getEmployeeApplicationDocument({ required BuildContext context, required int employmentAppFormhtmlId, required int employeeId,
  required String middleName, required String faxNo, required String ifHired,required String positionApplying,required String positionDesired,
  required String dateAvailable, required String specifyWorkingHrs, required String salary,required String sourceReferral,required String value,
}) async {
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getEmplAppDocument(employmentAppFormhtmlId: employmentAppFormhtmlId, employeeId: employeeId,
            middleName: middleName, faxNo: faxNo, ifHired: ifHired, positionApplying: positionApplying, positionDesired: positionDesired,
            dateAvailable: dateAvailable, specifyWorkingHrs: specifyWorkingHrs, salary: salary, sourceReferral: sourceReferral, value: value));
         if (response.statusCode == 200 || response.statusCode == 201) {
      print('Employment Application Docuemnt Fetched');
      itemsData = EmploymentAppDocument(EmpAppDocumentId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("Employment ApplicationDocument");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}

///i9
Future<INineDocument> getI9Document({ required BuildContext context, required int i9FormhtmlId, required int employeeId,
  required String middleName, required String otherLastName, required String aptNumber,required String alienInfo,required String citizenship,
  required String alienDate,
}) async {
  var itemsData ;
  try {
    final response = await ApiOffer(context).get(
        path: LegalDocumentsRepo.getINineDocument(i9FormhtmlId: i9FormhtmlId, employeeId: employeeId, middleName: middleName,
            otherLastName: otherLastName, aptNumber: aptNumber, alienInfo: alienInfo, citizenship: citizenship, alienDate: alienDate));
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('I9 Docuemnt Fetched');
      itemsData = INineDocument(iNineDocumentId: response.data['id'], name: response.data['name'], html: response.data['html'], statusCode: response.statusCode!);
    } else {
      print("I9");
    }
    return itemsData;
  } catch (e) {
    print("error${e}");
    return itemsData;
  }
}