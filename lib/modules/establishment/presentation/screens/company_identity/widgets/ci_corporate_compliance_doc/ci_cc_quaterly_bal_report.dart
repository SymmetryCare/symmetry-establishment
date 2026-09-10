import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/upload_edit_popup.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';

class CICCQuarterlyBalReport extends StatefulWidget {
  final int docId;
  final int subDocId;
  final String officeId;
  const CICCQuarterlyBalReport(
      {super.key,
      required this.docId,
      required this.subDocId,
      required this.officeId});

  @override
  State<CICCQuarterlyBalReport> createState() => _CICCQuarterlyBalReportState();
}

class _CICCQuarterlyBalReportState extends State<CICCQuarterlyBalReport> {
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  // int docTypeMetaIdCC = AppConfig.corporateAndCompliance;
  int docTypeMetaIdCCbal =FrontendConfigStore.data!.config.subDocId5BalReport;
  // int docTypeMetaIdCCbal = AppConfig.subDocId5BalReport;
  final StreamController<List<MCorporateComplianceModal>>
      _ccQuarterlyController =
      StreamController<List<MCorporateComplianceModal>>();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();

  String? selectedValue;
  int docTypeMetaId = 0;
  int docSubTypeMetaId = 0;
  String? expiryType;
  bool _isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  int docTypeId = 0;
  String? documentTypeName;
  dynamic filePath;
  String? selectedDocType;
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: AppSize.s5,
          ),
          Expanded(
            child: StreamBuilder<List<MCorporateComplianceModal>>(
                stream: _ccQuarterlyController.stream,
                builder: (context, snapshot) {
                  getListMCorporateCompliancefetch(
                          context,
                           FrontendConfigStore.data!.config.corporateAndCompliance, widget.officeId,
                          // AppConfig.corporateAndCompliance, widget.officeId,
                          FrontendConfigStore.data!.config.subDocId5BalReport,
                          // AppConfig.subDocId5BalReport,
                          1,
                          9999)
                      .then((data) {
                    _ccQuarterlyController.add(data);
                  }).catchError((error) {
                    // Handle error
                  });
                  print('55555555');
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
                        ErrorMessageString.noQBR,
                        style: AllNoDataAvailable.customTextStyle(context)
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    int totalItems = snapshot.data!.length;
                    int totalPages = (totalItems / itemsPerPage).ceil();
                    List<MCorporateComplianceModal> paginatedData = snapshot
                        .data!
                        .skip((currentPage - 1) * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: paginatedData.length,

                              itemBuilder: (context, index) {
                                var ccMCR = snapshot.data![index];
                                var fileUrl = ccMCR.docurl;
                                final fileExtension = fileUrl.split('/').last;
                                int serialNumber = index +
                                    1 +
                                    (currentPage - 1) * itemsPerPage;
                                String formattedSerialNumber =
                                    serialNumber.toString().padLeft(2, '0');
                                MCorporateComplianceModal balReport =
                                    paginatedData[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8,),
                                      child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: AppSize.s5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xff000000)
                                                    .withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          height: AppSize.s65,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppPadding.p30),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    // InkWell(
                                                    //   onTap: () {
                                                    //   },
                                                    //   child: Image.asset(
                                                    //     'images/eye.png',
                                                    //     height: 15,
                                                    //     width: 22,
                                                    //   ),
                                                    // ),
                                                    //IconButton(onPressed: (){}, icon: Icon(Icons.remove_red_eye_outlined,size:20,color: ColorManager.blueprime,)),
                                                    GestureDetector(
                                                      onTap: (){
                                                        print("FileExtension:${fileExtension}");
                                                        downloadFile(
                                                          context: context,
                                                          fileUrl: fileUrl,
                                                          documentName: fileUrl.split('/').last,
                                                          apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                        //DowloadFile();
                                                        //.downloadPdfFromBase64(fileExtension,"Acknowledgement");
                                                      },
                                                      child: Container(
                                                          width: AppSize.s62,
                                                          height: AppSize.s45,
                                                          padding: EdgeInsets.symmetric(horizontal: AppPadding.p10,vertical: AppPadding.p8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(width: 2, color: ColorManager.faintGrey),
                                                          ),
                                                          child: SvgPicture.asset('images/doc_vector.svg')),
                                                    ),
                                                    SizedBox(width: AppSize.s10),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "ID : ${balReport.idOfDocument}",
                                                          style:  DocDefineTableDataID.customTextStyle(context),
                                                        ),
                                                        SizedBox(height: AppSize.s8,),
                                                        Text(
                                                          balReport.fileName.toString(),
                                                          textAlign: TextAlign.center,
                                                          style:  DocDefineTableData.customTextStyle(context),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              ManageHistoryPopup(
                                                            docHistory:
                                                                balReport
                                                                    .docHistory,
                                                          ),
                                                        );
                                                      },
                                                      icon:Icon(
                                                        Icons.history,
                                                        size: IconSize.I22,
                                                        color: IconColorManager
                                                            .bluebottom,
                                                      ),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,

                                                    ),
                                                    SizedBox(width: AppSize.s10,),
                                                    ///print
                                                    IconButton(
                                                      onPressed: () {
                                                        print("FileExtension:${fileExtension}");
                                                        // DowloadFile()
                                                        //     .downloadPdfFromBase64(
                                                        //     fileExtension,
                                                        //     "DME.pdf");
                                                        downloadFile(
                                                          context: context,
                                                          fileUrl: fileUrl,
                                                          documentName: fileUrl.split('/').last,
                                                          apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      icon: Icon(
                                                        Icons.print_outlined,
                                                        size:IconSize.I22,color: IconColorManager.bluebottom,
                                                      ),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                    ),
                                                    SizedBox(width: AppSize.s10,),
                                                    ///download saloni
                                                    PdfDownloadButton(apiUrl: balReport.docurl,
                                                        iconsize: IconSize.I22,
                                                        apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName(),
                                                        documentName: balReport.docName!),
                                                    SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                      onPressed: () {
                                                        String?
                                                            selectedExpiryType =
                                                            expiryType;
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return FutureBuilder<
                                                                MCorporateCompliancePreFillModal>(
                                                              future: getPrefillNewOrgOfficeDocument(
                                                                  context, balReport.orgOfficeDocumentId),
                                                              builder: (context, snapshotPrefill) {
                                                                if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                  return Center(
                                                                    child: CircularProgressIndicator(
                                                                      color: ColorManager.blueprime,
                                                                    ),
                                                                  );
                                                                }
                                                                return StatefulBuilder(
                                                                  builder: (BuildContextcontext,
                                                                      void Function(void Function())setState) {
                                                                    return VCScreenPopupEditConst(
                                                                      fileName: snapshotPrefill.data!.fileName,
                                                                      url: snapshotPrefill.data!.url,
                                                                      expiryDate: snapshotPrefill.data!.expiry_date ,
                                                                      title: EditPopupString.editQBR ,
                                                                      loadingDuration: _isLoading,
                                                                      officeId: widget.officeId,
                                                                      docTypeMetaIdCC: widget.docId,
                                                                      selectedSubDocId: widget.subDocId,
                                                                      orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                      orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                      docName: snapshotPrefill.data!.docName,
                                                                      selectedExpiryType: snapshotPrefill.data!.expType,
                                                                      documentType: AppStringEM.corporateAndComplianceDocuments,
                                                                      documentSubType: AppStringEM.qbr,
                                                                      isOthersDocs: snapshotPrefill.data!.isOthersDocs,
                                                                      idOfDoc: snapshotPrefill.data!.idOfDocument,
                                                                      expiryType: snapshotPrefill.data!.expType,
                                                                      threshhold: snapshotPrefill.data!.threshould,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(Icons.edit_outlined,
                                                        size:IconSize.I22,color: IconColorManager.bluebottom,),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                    ),
                                                    SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  StatefulBuilder(
                                                                    builder: (BuildContext context,
                                                                        void Function(void Function())setState) {
                                                                      return DeletePopup(
                                                                          title:
                                                                          DeletePopupString.deleteQBR ,
                                                                          loadingDuration: _isLoading,
                                                                          onCancel: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          onDelete: () async {
                                                                            setState(() {
                                                                              _isLoading = true;
                                                                            });
                                                                            try {
                                                                              await deleteOrgDoc(context: context, orgDocId: balReport.orgOfficeDocumentId);
                                                                              Navigator.pop(context);
                                                                              showDialog(context: context, builder: (context) => DeleteSuccessPopup());
                                                                            } finally {
                                                                              setState(() {
                                                                                _isLoading = false;
                                                                              });
                                                                            }
                                                                          });
                                                                    },
                                                                  ));
                                                        },
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          size: IconSize.I22,
                                                          color: ColorManager.red,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        PaginationControlsWidget(
                          currentPage: currentPage,
                          items: snapshot.data!,
                          itemsPerPage: itemsPerPage,
                          onPreviousPagePressed: () {
                            setState(() {
                              currentPage =
                                  currentPage > 1 ? currentPage - 1 : 1;
                            });
                          },
                          onPageNumberPressed: (pageNumber) {
                            setState(() {
                              currentPage = pageNumber;
                            });
                          },
                          onNextPagePressed: () {
                            setState(() {
                              currentPage = currentPage < totalPages
                                  ? currentPage + 1
                                  : totalPages;
                            });
                          },
                        ),
                      ],
                    );
                  }
                  return Offstage();
                }),
          ),
        ],
      ),
    );
  }
}