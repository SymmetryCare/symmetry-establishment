import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/i9_form_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/candidate_release_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/const_form_list.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/direct_deposit_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/employment_application_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/flue_vaccine_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/form_screen_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/company_property_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/i9_form_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/w4_popup.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/form_status_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/form_status_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_legal_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_nine_screen.dart';

class LegalDocumentsScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  const LegalDocumentsScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack,
  });

  final BuildContext context;

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  final StreamController<List<FormModel>> formController =
      StreamController<List<FormModel>>();
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  bool fileAbove20Mb = false;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  @override
  void initState() {
    _initializeFormWithPrefilledData();
    _loadFormStatus();
    super.initState();

  }

  void _loadFormStatus() {
    getFormStatus(
      context,
      widget.employeeID,
    ).then((data) {
      if (mounted) formController.add(data);
    }).catchError((error) {});
  }

  @override
  void dispose() {
    formController.close();
    super.dispose();
  }

  bool isSelected = false;
  List<String> _fileNames = [];
  bool _loading = false;

  bool isLoading = false;

  void _pickFiles() async {
    setState(() {
      _loading = true; // Show loader
      _fileNames.clear(); // Clear previous file names if any
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _fileNames.addAll(result.files.map((file) => file.name!));
        _loading = false; // Hide loader
      });
      print('Files picked: $_fileNames');
    } else {
      setState(() {
        _loading = false; // Hide loader on cancel
      });
      print('User canceled the picker');
    }
  }

  ////////////////////////////////////

  bool _documentUploaded = true;
  var fileName;
  var fileName1;
  dynamic? filePath;
  File? xfileToFile;
  var finalPath;
  String? docName;
  String? docUrl;


  Future<void> _initializeFormWithPrefilledData() async {
    try {

      List<EmployeeLegalDocument> prefilledData = await legalDocumentPrifill(context, widget.employeeID); // Assuming getLegalDocuments is your GET API function

      if (prefilledData.isNotEmpty) {
        var data = prefilledData[0]; // Assuming index matches the data list
        setState(() {
          docUrl = data.docUrl ; // URL for the document
          docName = data.docName ?? '--'; // Default value if no docName is found
        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }



  Future<WebFile> saveFileFromBytes(dynamic bytes, String fileName) async {
    // Get the directory to save the file.
    final blob = html.Blob(bytes);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create the file.
    final file = html.File([blob], fileName);
    // Write the bytes to the file.
    print(file.toString());
    return WebFile(file, url);
  }

  Future<XFile> convertBytesToXFile(Uint8List bytes, String fileName) async {
    // Create a Blob from the bytes
    final blob = html.Blob([bytes]);

    // Create an object URL from the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a File from the Blob
    final file = html.File([blob], fileName);

    print("XFILE ${url}");

    // Return the XFile created from the object URL
    return XFile(url);
  }

  Future<Uint8List> loadFileBytes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/somefile.txt');
    if (await file.exists()) {
      return await file.readAsBytes();
    } else {
      throw Exception('File not found!');
    }
  }


  Future<void> saveDataWithoutFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Save data logic here, as no file needs to be uploaded
      ApiDataRegister result = await legalDocumentAdd(
        context: context,
        employeeId: widget.employeeID,
        documentName: fileName,
        docUrl: '',
        officeId: '',
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddSuccessPopup(
              message: 'Data Saved Successfully Without File.',
            );
          },
        );
        await widget.onSave(); // Save the data to parent
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddFailePopup(
              message: 'Failed to save data without file.',
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const FourNotFourPopup();
        },
      );
    }
  }




  Future<void> saveDataWithFile() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Perform the API call to save data
      ApiDataRegister result = await legalDocumentAdd(
        context: context,
        employeeId: widget.employeeID,
        documentName: fileName,
        docUrl: '',
        officeId: '',
      );

      // Upload the document
      var response = await uploadLegalDocumentBase64(
        context: context,
        employeeLegalDocumentId: result.legalDocumentId!,
        documentFile: finalPath,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddSuccessPopup(
              message: 'Document Uploaded Successfully.',
            );
          },
        );
        await widget.onSave(); // Save the data to parent
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddFailePopup(
              message: 'Failed to upload document.',
            );
          },
        );
        print('Document upload error');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const FourNotFourPopup();
        },
      );
    }
  }



  Future<void> callHtmlData(String htmlName, int id) async{
    setState(() {

    });
    if(htmlName == AppStringLegalDocument.onCall){
      OnCallDocument oncallDoc = await getLegalOnCallDocument(context: context, callHtmlId: id, employeeId: widget.employeeID);

      Navigator.push(context, MaterialPageRoute(builder: (context)=>
          SignatureFormScreen(
          isDisable:false,
        documentName: AppStringLegalDocument.onCall,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: oncallDoc.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: id,)
      ));
    }
    else if(htmlName == AppStringLegalDocument.confidentialityAgreement){
      ConfidentialStatementDocument confidentialStatementDocument = await getLegalConfidentialStatementDocument(context: context, employeeId: widget.employeeID, ConfidentialStatementId: id);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignatureFormScreen(
        isDisable:false,
        documentName: confidentialStatementDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: confidentialStatementDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: confidentialStatementDocument.confidentialStatementId,)));
    }
    else if(htmlName == AppStringLegalDocument.covidTestingPolicy){
      CovidTestPolicyDocument covidTestPolicyDocument = await getLegalCovidTestPolicyDocument(context: context, employeeId: widget.employeeID, covidTestId: id);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignatureFormScreen(
        isDisable:false,
        documentName: covidTestPolicyDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: covidTestPolicyDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: covidTestPolicyDocument.covidTestPolicyId,)));
    }
    else if(htmlName == AppStringLegalDocument.reportOfAbuse){
      ReportingAbuseDocument reportingAbuseDocument = await getLegalReportingAbuseDocumentDocument(context: context, employeeId: widget.employeeID, reportingAbuseId: id);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignatureFormScreen(
        isDisable:false,
        documentName: reportingAbuseDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: reportingAbuseDocument.html,
        employeeId: widget.employeeID,
        htmlFormTemplateId: reportingAbuseDocument.reportingAbuseId,)));
    }
    else if(htmlName == AppStringLegalDocument.policyConcerning){
      PolicyConcerningDocument policyConcerningDocument = await getLegalpolicyConcerningDocument(context: context, employeeId: widget.employeeID, policyConcerningId: id);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignatureFormScreen(
        isDisable:false,
        documentName: policyConcerningDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: policyConcerningDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: policyConcerningDocument.policyConcerningId,)));
    }
    else if(htmlName == AppStringLegalDocument.standardOfCodeOfConduct){
      StandardConductDocument standardConductDocument = await getStandardConductDocument(context: context, employeeId: widget.employeeID, standardConductId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: standardConductDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: standardConductDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: standardConductDocument.standardConductId,)));
    }
    else if(htmlName == AppStringLegalDocument.sexualHarassmentPolicy){
      SexualHaressmentDocument sexualHaressmentDocument = await getSexualHaressmentDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: sexualHaressmentDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: sexualHaressmentDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: sexualHaressmentDocument.sexualHaressmentId,)));
    }
    else if(htmlName == AppStringLegalDocument.sexualHarassmentPolicyACK){
      SexualAndUnlawfulDocument sexualAndUnlawfulDocument = await getSexualAndUnlawfulDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: sexualAndUnlawfulDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: sexualAndUnlawfulDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: sexualAndUnlawfulDocument.sexualUnlawfulId,)));
    }
    else if(htmlName == AppStringLegalDocument.preAuthorization){
      PreAuthPatientVisitsDocument preAuthPatientVisitsDocument = await getPreAuthPatientVisitsDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: preAuthPatientVisitsDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: preAuthPatientVisitsDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: preAuthPatientVisitsDocument.preAuthPatientId,)));
    }
    else if(htmlName == AppStringLegalDocument.prop65){
      ProDocument proDocument = await getPro65Document(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: proDocument.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: proDocument.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: proDocument.proDocumentId,)));
    }
    else if(htmlName == AppStringLegalDocument.proHealthCellPhone){
      ProHealthCellPhoneStatement proHealthCellPhoneStatement = await getProHealthCellPhoneStatementDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: proHealthCellPhoneStatement.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: proHealthCellPhoneStatement.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: proHealthCellPhoneStatement.proHealthCellPhoneStatementId,)));
    }
    else if(htmlName == AppStringLegalDocument.hepB){
      HepBDocuemnt hepBDocuemnt = await getHepBDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: hepBDocuemnt.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: hepBDocuemnt.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: hepBDocuemnt.hepBDocuemntId,)));
    }
    else if(htmlName == AppStringLegalDocument.tDap){
      TDapDocuemnt tDapDocuemnt = await getTDapDocument(context: context, employeeId: widget.employeeID,templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: tDapDocuemnt.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: tDapDocuemnt.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: tDapDocuemnt.tDapDocuemnttId,)));
    }
    else if(htmlName == AppStringLegalDocument.covidVaccine){
      CovidVaccineDocuemnt covidVaccineDocuemnt = await getCovidVaccineDocument(context: context, employeeId: widget.employeeID, templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:false,
        documentName: covidVaccineDocuemnt.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: covidVaccineDocuemnt.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: covidVaccineDocuemnt.covidVaccineDocuemntId,)));
    }
    else if(htmlName == AppStringLegalDocument.employeeHandbook){
      ProHealthEmployeeHandbook proHealthEmployeeHandbook = await getProHealthEmployeeHandbookDocument(context: context, employeeId: widget.employeeID, templateId: id);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
        isDisable:true,
        documentName: proHealthEmployeeHandbook.name,
        onPressed: () { _loadFormStatus(); },
        htmlFormData: proHealthEmployeeHandbook.html,
        employeeId: widget.employeeID,//widget.employeeID,
        htmlFormTemplateId: proHealthEmployeeHandbook.proHealthEmployeeHandbookId,)));
    }
    else if(htmlName == AppStringLegalDocument.flu){
      showDialog(context: context, builder: (BuildContext context){
        return FlueVaccineSignPopup(employeeId: widget.employeeID, htmlFormTemplateId: id, onSigned: _loadFormStatus);
      });
    }
    else if(htmlName == AppStringLegalDocument.employmentApplication){
      showDialog(context: context, builder: (BuildContext context){
        return EmploymentAppSignPopup(employeeId: widget.employeeID, htmlFormTemplateId: id, onSigned: _loadFormStatus);
      });
    }
    else if(htmlName == AppStringLegalDocument.w4){
      showDialog(context: context, builder: (BuildContext context){
        return WFourSignPopup(employeeId: widget.employeeID, htmlFormTemplateId: id, onSigned: _loadFormStatus);
      });
    }
    else if(htmlName == AppStringLegalDocument.i9){
      showDialog(context: context, builder: (BuildContext context){
        return INineSignPopup(employeeId: widget.employeeID, htmlFormTemplateId: id, onSigned: _loadFormStatus);
      });
    }
    else if(htmlName == AppStringLegalDocument.candidatereLeaseForm){
      showDialog(context: context, builder: (BuildContext context){
        return CandidateReleaseSignPopup(
          employeeId: widget.employeeID,
          htmlFormTemplateId:id,
          onSigned: _loadFormStatus,
          );
      });
    }
    else if(htmlName == AppStringLegalDocument.returnOfcompanyProperty){
      showDialog(context: context, builder: (BuildContext context){
        return CompanyPropertySignPopup(
          employeeId: widget.employeeID,
          htmlFormTemplateId: id,
          onSigned: _loadFormStatus,
        );
      });
    }
    else if(htmlName == AppStringLegalDocument.directDeposit){
        DirectDepositDocuemnt directDepositDocuemnt = await getDirectDepositDocument(context: context, employeeId: widget.employeeID, templateId: id,);
          Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
            isDisable:false,
          documentName: directDepositDocuemnt.name,
          onPressed: () { _loadFormStatus(); },
          htmlFormData: directDepositDocuemnt.html,
          employeeId: widget.employeeID,//widget.employeeID,
          htmlFormTemplateId: directDepositDocuemnt.directDepositDocuemntId,)));


    }
    else{

    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false,),
      child: SingleChildScrollView(
          child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.p150),
                  child: Column(
        children: [
          const FormsBlueHeaderConst(
            text: 'Please add information about your legal documents.',
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upload one of your government ids. ( e.g. drivers license )',
                  style: FileuploadString.customTextStyle(context),
                ),
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // FilePicker allows only one file to be selected at a time
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        allowMultiple: false, // Ensure only one file is selected
                      );
                      final fileSize = result?.files.first.size;
                      if (fileSize != null) {
                        final isAbove20MB = fileSize > (20 * 1024 * 1024); // Check if file is larger than 20MB

                        if (isAbove20MB) {
                          // If the file is larger than 20MB, show an error message
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AddErrorPopup(
                                message: 'File is too large!',
                              );
                            },
                          );
                        } else {
                          // If the file is less than 20MB, proceed with the upload process
                          if (result != null) {
                            final file = result.files.first;
                            setState(() {
                              fileName = file.name;
                              finalPath = file.bytes;
                              fileAbove20Mb = false; // This flag indicates that the file is below 20MB
                            });
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff50B5E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: docName == "--" ? const Icon(Icons.upload, color: Colors.white) : null,
                    label: docName == null || docName == "--"
                        ? Text(
                      'Upload File',
                      style: BlueButtonTextConst.customTextStyle(context),
                    )
                        : Text(
                      'Uploaded',
                      style: BlueButtonTextConst.customTextStyle(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  docName != null
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Uploaded File: ', style: onlyFormDataStyle.customTextStyle(context)),
                      InkWell(
                        onTap: () async {
                          if (docUrl != null && docUrl!.isNotEmpty) {
                            // Previously submitted (prefilled) file: download it.
                            await downloadFile(
                              context: context,
                              fileUrl: docUrl!,
                              documentName: docName!,
                              apiPath: DownloadDocumentRepository.getEmployeeLegalDocumentByFileName(),
                            );
                          }
                        },
                        child: AutoSizeText(
                          docName!,
                          style: onlyFormDataStyle.customTextStyle(context).copyWith(
                            decoration: TextDecoration.underline,
                            color: const Color(0xff50B5E5),
                          ),
                        ),
                      ),
                    ],
                  )
                      : fileName != null
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('File picked: ', style: onlyFormDataStyle.customTextStyle(context)),
                      InkWell(
                        onTap: () {
                          if (finalPath != null) {
                            final blob = html.Blob([finalPath], 'application/pdf');
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            html.window.open(url, '_blank');
                          }
                        },
                        child: AutoSizeText(
                          '$fileName',
                          style: onlyFormDataStyle.customTextStyle(context).copyWith(
                            decoration: TextDecoration.underline,
                            color: const Color(0xff50B5E5),
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox(),
                ],
              ), // Display file names if picked
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'List Of Documents',
                style: HeadingFormStyle.customTextStyle(context),
              ),

            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          StreamBuilder<List<FormModel>>(
              stream: formController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      AppStringHRNoData.nolegalDocData,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          FormModel formStatus = snapshot.data![index];
                          return Column(
                            children: [
                              // const SizedBox(height: AppSize.s10),
                              // DefineFormList(formName: AppStringLegalDocument.onCall, onSigned: () async{
                              //   OnCallDocument oncallDoc = await getLegalOnCallDocument(context: context, callHtmlId: 1, employeeId: 169);
                              //   Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
                              //     documentName: AppStringLegalDocument.onCall,
                              //     onPressed: () { _loadFormStatus(); },
                              //     htmlFormData: oncallDoc.html,
                              //     employeeId: 169,//widget.employeeID,
                              //     htmlFormTemplateId: 1,)));
                              // }, onView: () {  },),
                              // const SizedBox(height: AppSize.s10),
                              /// dont delete this code
                              DefineFormList(
                                isReturnCompany: (formStatus.htmlname == AppStringLegalDocument.returnOfcompanyProperty)?true:false,
                                isHandbook: (formStatus.htmlname == AppStringLegalDocument.employeeHandbook)?true:false,
                                handBookView:(formStatus.htmlname == AppStringLegalDocument.employeeHandbook)?() async{
                                  await callHtmlData(formStatus.htmlname,formStatus.formHtmlTemplatesId);
                                  print("${formStatus.htmlname} signed.");
                                }:(){},
                                formName: formStatus.htmlname,
                                onSigned: formStatus.signed
                                    ? null
                                    : () async{
                                  await callHtmlData(formStatus.htmlname,formStatus.formHtmlTemplatesId);
                                  print("${formStatus.htmlname} signed.");
                                },
                                onView: formStatus.signed ?  () {
                                  // Logic for viewing the form
                                  downloadFile(context: context,
                                      fileUrl: formStatus.url,
                                      documentName: formStatus.htmlname,
                                      apiPath: DownloadDocumentRepository.getEmployeeLegalDocumentByFileName());
                                  print("Viewing ${formStatus.htmlname}");
                                } : (){},
                                isSigned: formStatus.signed,
                              ),
                              const SizedBox(height: AppSize.s10),
                              const Divider(
                                height: 1,
                                color: Color(0xFFD1D1D1),
                              ),
                              const SizedBox(height: AppSizeConst.A20),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Offstage();
              }),
        ],
                  ),
                ),
            const SizedBox(height: AppSizeConst.A20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FormOutlineButtonConst(
                  text: 'Previous',
                  onPressed: () {
                    widget.onBack();
                  },
                ),
                const SizedBox(
                  width: 30,
                ),
                FormSaveButtonConst(
                  isLoading: isLoading,
                  onPressed: () async {
                    // Check if a file is selected
                    if (finalPath == null || finalPath.isEmpty) {
                      // If no file is selected, just save the data
                      await saveDataWithoutFile(); // Function to save data without file upload
                    } else {
                      // If file is selected, check if it's under 20 MB
                      if (!fileAbove20Mb) {
                        // Show error message if file is too large

                        await saveDataWithFile();

                      } else {
                        // If file size is acceptable, proceed with saving data and uploading the file
                        // Function to save data and upload the file
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AddErrorPopup(
                              message: 'File is too large!',
                            );
                          },
                        );
                      }
                    }

                    setState(() {
                      isLoading = false; // Stop loading
                    });
                  },
                ),
              ],
            ),

      ])),

    );
  }
}

