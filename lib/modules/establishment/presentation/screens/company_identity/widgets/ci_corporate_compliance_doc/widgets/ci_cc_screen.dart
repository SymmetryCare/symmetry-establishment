import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/ci_org_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/company_identity_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/upload_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_adr.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_cap_reports.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_licence.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_medical_cost_report.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_quaterly_bal_report.dart';

class CiCorporateComplianceScreen extends StatefulWidget {
  final int docId;
  final String officeId;
  final int companyID;

  const CiCorporateComplianceScreen({
    super.key,
    required this.docId,
    required this.officeId,
    required this.companyID,
  });

  @override
  State<CiCorporateComplianceScreen> createState() =>
      _CiCorporateComplianceScreenState();
}

class _CiCorporateComplianceScreenState
    extends State<CiCorporateComplianceScreen> {
  final PageController _tabPageController = PageController();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();

  int _selectedIndex = 0;
  //int docTypeMetaId = 8;
  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  // int docTypeMetaIdCC = AppConfig.corporateAndCompliance;
  // int docTypeDropMetaId = 0;
  int docSubTypeMetaId = 0;
  String? expiryType;
  bool _isLoading = false;
  int docTypeId = 0;
  DateTime? datePicked;
  String? selectedDocTypeValue;
  String? selectedSubDocTypeValue;
  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId1Licenses; // Default value
  // int selectedSubDocId = AppConfig.subDocId1Licenses; // Default value
  String selectedSubDocType = "";
  dynamic filePath;
  late Future<List<DocumentTypeData>> docTypeFuture;
  bool showExpiryDateField = false;
  TextEditingController expiryDateController = TextEditingController();
  String fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        print('File path ${filePath}');
        print('File name ${fileName}');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDocTypeValue = "Select Document Type";
    selectedSubDocTypeValue = "Select Sub Document";
    docTypeFuture = documentTypeGet(context);
    _updateSelectedSubDocId(selectedSubDocId);
    print("office id ::::::::${widget.officeId}");
  }

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;

      _updateSelectedSubDocId(index == 0
          ? FrontendConfigStore.data!.config.subDocId1Licenses
          // ? AppConfig.subDocId1Licenses
          : index == 1
              ?FrontendConfigStore.data!.config.subDocId2Adr
              // ? AppConfig.subDocId2Adr
              : index == 2
                  ? FrontendConfigStore.data!.config.subDocId3CICCMedicalCR
                  // ? AppConfig.subDocId3CICCMedicalCR
                  : index == 3
                      ? FrontendConfigStore.data!.config.subDocId4CapReport
                      // ? AppConfig.subDocId4CapReport
                      :  FrontendConfigStore.data!.config.subDocId5BalReport);
                      // : AppConfig.subDocId5BalReport);
    });
    _tabPageController.jumpToPage(
      index,);
  }

  void _updateSelectedSubDocId(int subDocId) {
    setState(() {
      selectedSubDocId = subDocId;
      selectedSubDocType = getSubDocTypeText(subDocId);
    });
  }


  String getSubDocTypeText(int subDocId) {
    final cfg = FrontendConfigStore.data!.config;

    switch (subDocId) {
      case _ when subDocId == cfg.subDocId1Licenses:
        return "Licenses";

      case _ when subDocId == cfg.subDocId2Adr:
        return "ADR";

      case _ when subDocId == cfg.subDocId3CICCMedicalCR:
        return "Medical Cost Reports";

      case _ when subDocId == cfg.subDocId4CapReport:
        return "CAP Reports";

      case _ when subDocId == cfg.subDocId5BalReport:
        return "Quarterly Balance Reports";

      default:
        return "Unknown Document Type";
    }
  }

  // String getSubDocTypeText(int subDocId) {
  //   switch (subDocId) {
  //     case AppConfig.subDocId1Licenses:
  //     // case AppConfig.subDocId1Licenses:
  //       return "Licenses";
  //     case AppConfig.subDocId2Adr:
  //       return "ADR";
  //     case AppConfig.subDocId3CICCMedicalCR:
  //       return "Medical Cost Reports";
  //     case AppConfig.subDocId4CapReport:
  //       return "CAP Reports";
  //     case AppConfig.subDocId5BalReport:
  //       return "Quarterly Balance Reports";
  //     default:
  //       return "Unknown Document Type";
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                flex: 1,
                child: Container()),
            ///tabbar
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(top: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EMTabbar(onTap: (int index){
                      _selectButton(0);
                    }, index: 0, grpIndex: _selectedIndex, heading: AppStringEM.licenses),
                    EMTabbar(onTap: (int index){
                      _selectButton(1);
                    }, index: 1, grpIndex: _selectedIndex, heading: AppStringEM.ard),
                    EMTabbar(onTap: (int index){
                      _selectButton(2);
                    }, index: 2, grpIndex: _selectedIndex, heading: AppStringEM.mcr),
                    EMTabbar(onTap: (int index){
                      _selectButton(3);
                    }, index: 3, grpIndex: _selectedIndex, heading: AppStringEM.capReport),
                    EMTabbar(onTap: (int index){
                      _selectButton(4);
                    }, index: 4, grpIndex: _selectedIndex, heading: AppStringEM.qbr),
                  ],
                )
              ),
            ),

           ///button
            Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p5, right: AppPadding.p65,top: AppPadding.p5),
              child: CustomIconButtonConst(
                  icon: Icons.add,
                  text: AppStringEM.addDocument,
                  onPressed: () async {
                    String? selectedExpiryType = expiryType;
                    calenderController.clear();
                    docIdController.clear();
                    docNamecontroller.clear();
                    selectedExpiryType = "";
                    datePicked = null;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return FutureBuilder<List<TypeofDocpopup>>(
                              future: getTypeofDoc(
                                  context, docTypeMetaIdCC, selectedSubDocId),
                              builder: (contex, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasData) {
                                  print("docTypeMetaIdCC @@@@@@@@@@@ ${docTypeMetaIdCC}");
                                  print("selectedSubDocId @@@@@@@@@@@ ${selectedSubDocId}");
                                  print("CC @@@@@@@@@@@ ${AppStringEM.corporateAndComplianceDocuments}");
                                  print("docTypeMetaIdCC @@@@@@@@@@@ ${getSubDocTypeText(selectedSubDocId)}");
                                  // print("docTypeMetaIdCC @@@@@@@@@@@ ${}");
                                  // print("docTypeMetaIdCC @@@@@@@@@@@ ${}");
                                  return UploadDocumentAddPopup(
                                    loadingDuration: _isLoading,
                                    title: 'Upload Document',
                                    officeId: widget.officeId,
                                    docTypeMetaIdCC: docTypeMetaIdCC,
                                    selectedSubDocId: selectedSubDocId,
                                    dataList: snapshot.data!,
                                    docTypeText: AppStringEM.corporateAndComplianceDocuments,
                                    subDocTypeText: getSubDocTypeText(selectedSubDocId),
                                  );
                                } else {
                                  return ErrorPopUp(
                                      title: "Received Error",
                                      text: snapshot.error.toString());
                                }
                              });
                        });
                  }),
            ),
          ],
        ),
        SizedBox(
          height: AppSize.s20,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p60),
            child: NonScrollablePageView(
              controller: _tabPageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                // Page 1
                CICCLicense(
                  docId: widget.docId,
                  subDocId:  FrontendConfigStore.data!.config.subDocId1Licenses,
                  // subDocId: AppConfig.subDocId1Licenses,
                  officeId: widget.officeId,
                ),
                CICCADR(
                  docId: widget.docId,
                  subDocId:  FrontendConfigStore.data!.config.subDocId2Adr,
                  // subDocId: AppConfig.subDocId2Adr,
                  officeId: widget.officeId,
                ),
                CICCMedicalCR(
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId3CICCMedicalCR,
                  // subDocId: AppConfig.subDocId3CICCMedicalCR,
                  officeId: widget.officeId,
                ),
                CICCCAPReports(
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId4CapReport,
                  // subDocId: AppConfig.subDocId4CapReport,
                  officeId: widget.officeId,
                ),
                CICCQuarterlyBalReport(
                  docId: widget.docId,
                  subDocId:FrontendConfigStore.data!.config.subDocId5BalReport,
                  // subDocId: AppConfig.subDocId5BalReport,
                  officeId: widget.officeId,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}