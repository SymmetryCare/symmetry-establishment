import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/upload_edit_popup.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';

class CICCLicense extends StatefulWidget {
  final int docId;
  final int subDocId;
  final String officeId;
  const CICCLicense(
      {super.key,
      required this.docId,
      required this.subDocId,
      required this.officeId});

  @override
  State<CICCLicense> createState() => _CICCLicenseState();
}

class _CICCLicenseState extends State<CICCLicense> {
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  int docTypeMetaIdCC =FrontendConfigStore.data!.config.corporateAndCompliance;
  // int docTypeMetaIdCC = AppConfig.corporateAndCompliance;
  int docTypeMetaIdCCL =  FrontendConfigStore.data!.config.subDocId1Licenses;
  // int docTypeMetaIdCCL = AppConfig.subDocId1Licenses;
  final StreamController<List<MCorporateComplianceModal>> lisenceController =
      StreamController<List<MCorporateComplianceModal>>();

  String? selectedValue;
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

  @override
  void initState() {
    getListMCorporateCompliancefetch(context, FrontendConfigStore.data!.config.corporateAndCompliance, widget.officeId,
    // getListMCorporateCompliancefetch(context, AppConfig.corporateAndCompliance, widget.officeId,
        FrontendConfigStore.data!.config.subDocId1Licenses, 1, 9999)
            // AppConfig.subDocId1Licenses, 1, 9999)
        .then((data) {
      lisenceController.add(data);
    }).catchError((error) {
      // Handle error
    });
    print("prachi:::::: ${widget.officeId}");
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
                stream: lisenceController.stream,
                builder: (context, snapshot) {
                  getListMCorporateCompliancefetch(context, FrontendConfigStore.data!.config.corporateAndCompliance, widget.officeId, FrontendConfigStore.data!.config.subDocId1Licenses,
                  // getListMCorporateCompliancefetch(context, AppConfig.corporateAndCompliance, widget.officeId, AppConfig.subDocId1Licenses,
                      1, 9999)
                      .then((data) {
                    lisenceController.add(data);
                  }).catchError((error) {});
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
                        ErrorMessageString.noLicenses,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    int totalItems = snapshot.data!.length;
                    int totalPages = (totalItems / itemsPerPage).ceil();
                    List<MCorporateComplianceModal> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: paginatedData.length,
                              itemBuilder: (context, index) {
                                var cclicenses = snapshot.data![index];
                                var fileUrl = cclicenses.docurl;
                                final fileExtension = fileUrl.split('/').last;
                                int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                MCorporateComplianceModal manageCCLicence = paginatedData[index];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8,),
                                      child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: AppSize.s5),
                                          decoration: BoxDecoration(
                                            color: ColorManager.white,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ColorManager.black.withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          height: AppSize.s65,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    // InkWell(
                                                    //   onTap: () {},
                                                    //   child: Image.asset(
                                                    //     'images/eye.png',
                                                    //     height: AppSize.s15,
                                                    //     width: AppSize.s22,
                                                    //   ),
                                                    // ),
                                                    //IconButton(onPressed: (){},
                                                    // icon: Icon(Icons.remove_red_eye_outlined,
                                                    // size:20,color: ColorManager.blueprime,)),
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
                                                      mainAxisAlignment: MainAxisAlignment  .center,
                                                      children: [
                                                        Text(
                                                          "ID : ${manageCCLicence.idOfDocument}",
                                                          textAlign: TextAlign.center,
                                                          style:  DocDefineTableDataID.customTextStyle(context),
                                                        ),
                                                        SizedBox(height: AppSize.s8,),
                                                        Text(
                                                          manageCCLicence.fileName.toString(),
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
                                                            docHistory: manageCCLicence.docHistory,
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.history,
                                                        size: IconSize.I22,
                                                        color: IconColorManager.bluebottom,
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
                                                    PdfDownloadButton(apiUrl: manageCCLicence.docurl, iconsize: IconSize.I22, apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName(), documentName: manageCCLicence.docName!),
                                                    SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return FutureBuilder<
                                                                MCorporateCompliancePreFillModal>(
                                                              future: getPrefillNewOrgOfficeDocument(context, manageCCLicence.orgOfficeDocumentId),
                                                              builder: (context,
                                                                  snapshotPrefill) {
                                                                if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                  return Center(
                                                                    child: CircularProgressIndicator(
                                                                      color: ColorManager.blueprime,
                                                                    ),
                                                                  );
                                                                }

                                                                return StatefulBuilder(
                                                                  builder: (BuildContext context,
                                                                      void Function(void Function())setState) {
                                                                    return VCScreenPopupEditConst(
                                                                      fileName: snapshotPrefill.data!.fileName,
                                                                      title: EditPopupString.editLicenses,
                                                                      loadingDuration: _isLoading,
                                                                      officeId: widget.officeId,
                                                                      docTypeMetaIdCC: widget.docId,
                                                                      selectedSubDocId: widget.subDocId,
                                                                      //orgDocId: manageCCADR.orgOfficeDocumentId,
                                                                      orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                      orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                      docName: snapshotPrefill.data!.docName,
                                                                      selectedExpiryType: snapshotPrefill.data!.expType,
                                                                      expiryDate: snapshotPrefill.data!.expiry_date,
                                                                      url: snapshotPrefill.data!.url,
                                                                      documentType: AppStringEM.corporateAndComplianceDocuments,
                                                                      documentSubType: AppStringEM.licenses,
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
                                                      icon:  Icon(Icons.edit_outlined,
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
                                                                          DeletePopupString.deleteLicenses,
                                                                          loadingDuration: _isLoading,
                                                                          onCancel: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          onDelete: () async {
                                                                            setState(() {
                                                                              _isLoading = true;
                                                                            });
                                                                            try {
                                                                              await deleteOrgDoc(
                                                                                context: context,
                                                                                orgDocId: manageCCLicence.orgOfficeDocumentId,
                                                                              );
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
                                                          color: IconColorManager.red,
                                                        ),
                                                    ),
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