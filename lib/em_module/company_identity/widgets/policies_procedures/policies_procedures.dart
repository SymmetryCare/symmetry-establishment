import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prohealth/app/constants/app_config.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/company_identity/ci_org_document.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/manage_history_version.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';
import 'package:prohealth/presentation/widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../app/services/api/managers/establishment_manager/newpopup_manager.dart';
import '../../../../../../data/api_data/establishment_data/ci_manage_button/newpopup_data.dart';
import '../../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../../widgets/error_popups/delete_success_popup.dart';
import '../../../../../widgets/widgets/custom_icon_button_constant.dart';
import '../../../../hr_module/onboarding/download_doc_const.dart';
import '../../../manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import '../error_pop_up.dart';
import '../upload_add_popup.dart';
import '../upload_edit_popup.dart';

class CiPoliciesAndProcedures extends StatefulWidget {
  final int docID;
  final int subDocID;
  final int companyID;
  final String officeId;
  const CiPoliciesAndProcedures(
      {super.key,
      required this.docID,
      required this.subDocID,
      required this.companyID,
      required this.officeId});

  @override
  State<CiPoliciesAndProcedures> createState() =>
      _CiPoliciesAndProceduresState();
}
class _CiPoliciesAndProceduresState extends State<CiPoliciesAndProcedures> {
  TextEditingController nameOfDocController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  final StreamController<List<MCorporateComplianceModal>> _controller =
      StreamController<List<MCorporateComplianceModal>>();
  TextEditingController calenderController = TextEditingController();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();
  int docTypeMetaIdPP = FrontendConfigStore.data!.config.policiesAndProcedure;
  // int docTypeMetaIdPP = AppConfig.policiesAndProcedure;
  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId0;
  // int selectedSubDocId = AppConfig.subDocId0;
  int docTypeMetaId = FrontendConfigStore.data!.config.policiesAndProcedure;
  int docSubTypeMetaId = FrontendConfigStore.data!.config.subDocId0;
  // int docSubTypeMetaId = AppConfig.subDocId0;
  String? expiryType;
  bool _isLoading = false;
  TextEditingController expiryDateController = TextEditingController();
  bool showExpiryDateField = false;

  int currentPage = 1;
  int docTypeId = 0;
  String? documentID;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p60),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppPadding.p10,right: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomIconButtonConst(
                      icon: Icons.add,
                      text: AppStringEM.addDocument,
                      onPressed: () async {
                        int? selectedDocTypeId;
                        String? selectedExpiryType = expiryType;
                        calenderController.clear();
                        docIdController.clear();
                        docNamecontroller.clear();
                        selectedExpiryType = "";

                        showDialog(
                            context: context,
                            builder: (context) {
                              return FutureBuilder<List<TypeofDocpopup>>(
                                  future: getTypeofDoc(context, docTypeMetaIdPP, selectedSubDocId),
                                  builder: (contex, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasData) {
                                      return UploadDocumentAddPopup(
                                        loadingDuration: _isLoading,
                                        title: 'Upload Document',
                                        officeId: widget.officeId,
                                        docTypeMetaIdCC: docTypeMetaIdPP,
                                        selectedSubDocId: selectedSubDocId,
                                        dataList: snapshot.data!,
                                        docTypeText: AppStringEM.policiesAndProcedures,
                                        subDocTypeText: '',
                                      );
                                    } else {
                                      return ErrorPopUp(
                                          title: "Received Error",
                                          text: snapshot.error.toString());
                                    }
                                  });
                            });
                      }),
                ],
              ),
            ),
            SizedBox(height: AppSize.s10),
            Expanded(
              child: StreamBuilder<List<MCorporateComplianceModal>>(
                  stream: _controller.stream,
                  builder: (context, snapshot) {
                    getListMCorporateCompliancefetch(
                            context,
                             FrontendConfigStore.data!.config.policiesAndProcedure, widget.officeId,
                            // AppConfig.policiesAndProcedure, widget.officeId,
                              FrontendConfigStore.data!.config.subDocId0,
                            // AppConfig.subDocId0,
                            1,
                            9999)
                        .then((data) {
                      _controller.add(data);
                    }).catchError((error) {
                      // Handle error
                    });

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
                          ErrorMessageString.noPolicyProcedure,
                          style: AllNoDataAvailable.customTextStyle(context),
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
                                  int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                  String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                  MCorporateComplianceModal policiesdata = paginatedData[index];
                                  var fileUrl = policiesdata.docurl;
                                  final fileExtension = fileUrl.split('/').last;

                                  Widget fileWidget;
                                  if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                                    fileWidget = Image.network(
                                      fileUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: IconSize.I45,
                                          color: ColorManager.faintGrey,
                                        );
                                      },
                                    );
                                  }
                                  else if (['pdf', 'doc', 'docx'].contains(fileExtension)) {
                                    fileWidget = Icon(
                                      Icons.description,
                                      size: IconSize.I45,
                                      color: ColorManager.faintGrey,
                                    );
                                  }
                                  else {
                                    fileWidget = Icon(
                                      Icons.insert_drive_file,
                                      size: IconSize.I45,
                                      color: ColorManager.faintGrey,
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: AppPadding.p8, horizontal: AppPadding.p10),
                                        child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: AppSize.s5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xff000000).withOpacity(0.25),
                                                  spreadRadius: 0,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
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
                                                      GestureDetector(
                                                        onTap: (){
                                                          print("FileExtension:${fileExtension}");
                                                          downloadFile(fileUrl);
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
                                                      SizedBox(width: AppSize.s10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "ID : ${policiesdata.idOfDocument}",
                                                            style:  DocDefineTableDataID.customTextStyle(context),
                                                          ),
                                                          SizedBox(height: AppSize.s8,),
                                                          Text(
                                                            policiesdata.fileName.toString(),
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
                                                              docHistory: policiesdata.docHistory,
                                                            ),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.history,
                                                          size:IconSize.I22,color: IconColorManager.bluebottom,
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
                                                          downloadFile(fileUrl);
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .print_outlined,
                                                          size:IconSize.I22,color: IconColorManager.bluebottom,
                                                        ),
                                                        splashColor:
                                                        Colors.transparent,
                                                        highlightColor:
                                                        Colors.transparent,
                                                        hoverColor:
                                                        Colors.transparent,
                                                      ),
                                                      SizedBox(width: AppSize.s10,),
                                                      ///download saloni
                                                      PdfDownloadButton(apiUrl: policiesdata.docurl,
                                                          iconsize: IconSize.I22,
                                                          documentName: policiesdata.docName!),
                                                      SizedBox(width: AppSize.s10,),
                                                      ///edit
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
                                                                    context,
                                                                    policiesdata
                                                                        .orgOfficeDocumentId),
                                                                builder: (context,
                                                                    snapshotPrefill) {
                                                                  if (snapshotPrefill
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        color: ColorManager
                                                                            .blueprime,
                                                                      ),
                                                                    );
                                                                  }

                                                                  var calender =
                                                                      snapshotPrefill
                                                                          .data!
                                                                          .expiry_date;
                                                                  calenderController =
                                                                      TextEditingController(
                                                                    text: snapshotPrefill
                                                                        .data!
                                                                        .expiry_date,
                                                                  );
                                                                  return StatefulBuilder(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        void Function(void Function())
                                                                            setState) {
                                                                      return VCScreenPopupEditConst(
                                                                        fileName: snapshotPrefill
                                                                            .data!
                                                                            .fileName,
                                                                        url: snapshotPrefill.data!.url,
                                                                        expiryDate: snapshotPrefill.data!.expiry_date,
                                                                        title: EditPopupString.editPolicy,
                                                                        loadingDuration: _isLoading,
                                                                        officeId: widget.officeId,
                                                                        docTypeMetaIdCC: widget.docID,
                                                                        selectedSubDocId: widget.subDocID,
                                                                        //orgDocId: manageCCADR.orgOfficeDocumentId,
                                                                        orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                        orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                        docName: snapshotPrefill.data!.docName,
                                                                        selectedExpiryType: snapshotPrefill.data!.expType,
                                                                        documentType: AppStringEM.policiesAndProcedures,
                                                                        documentSubType: '',
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
                                                        icon: Icon(
                                                          Icons.edit_outlined,
                                                          size:IconSize.I22,color: IconColorManager.bluebottom,
                                                        ),
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                      ),
                                                      SizedBox(width: AppSize.s10,),
                                                      ///delete
                                                      IconButton(
                                                          splashColor: Colors.transparent,
                                                          highlightColor: Colors.transparent,
                                                          hoverColor: Colors.transparent,
                                                          onPressed: () {
                                                            showDialog(context: context,
                                                                builder: (context) => StatefulBuilder(
                                                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                                                    return  DeletePopup(
                                                                        title: 'Delete Policies & Procedure',
                                                                        loadingDuration: _isLoading,
                                                                        onCancel: (){
                                                                          Navigator.pop(context);
                                                                        },
                                                                        onDelete: () async{
                                                                      setState(() {
                                                                        _isLoading = true;
                                                                      });
                                                                      try {
                                                                        await deleteOrgDoc(
                                                                            context: context,
                                                                            orgDocId: policiesdata.orgOfficeDocumentId);
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
                                                            Icons
                                                                .delete_outline,
                                                            size:IconSize.I24,color: IconColorManager.red,
                                                          )),
                                                    ],
                                                  )
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
                    return const Offstage();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

