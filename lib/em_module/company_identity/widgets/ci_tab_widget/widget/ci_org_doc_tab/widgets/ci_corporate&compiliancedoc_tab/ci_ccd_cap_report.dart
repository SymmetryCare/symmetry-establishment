import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/company_identity/new_org_doc.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../../../app/constants/app_config.dart';
import '../../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../../../app/resources/provider/delete_popup_provider.dart';
import '../../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../../app/services/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import '../../../../../../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../../../../../../widgets/error_popups/delete_success_popup.dart';
import '../../../../../../../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../../../files_constant-widget.dart';
import '../heading_constant_widget.dart';
import 'package:prohealth/presentation/widgets/widgets/custom_scrollbar.dart';
import '../org_add_popup_const.dart';

class CiCcdCapReportsProvider extends ChangeNotifier {
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  final StreamController<List<NewOrgDocument>> documentStream =
      StreamController<List<NewOrgDocument>>.broadcast();

  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  // int docTypeMetaIdCC = AppConfig.corporateAndCompliance;
  int docTypeMetaIdCCCap =FrontendConfigStore.data!.config.subDocId4CapReport;
  // int docTypeMetaIdCCCap = AppConfig.subDocId4CapReport;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int currentPage = 1;
  String? expiryType;
  String? selectedYear = FrontendConfigStore.data!.config.year;

  void setLoadingState(bool loadingState) {
    _isLoading = loadingState;
    notifyListeners();
  }

  void onPageNumberPressed(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  Future<void> fetchDocuments(BuildContext context) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,
        FrontendConfigStore.data!.config.corporateAndCompliance,
        // AppConfig.corporateAndCompliance,
        FrontendConfigStore.data!.config.subDocId4CapReport,
        // AppConfig.subDocId4CapReport,
        1,
        50,
      );
      documentStream.add(documents);
    } catch (e) {
      documentStream.addError(e);
    }
  }

  Future<void> handleEdit(BuildContext context, NewOrgDocument doc) async {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<NewOrgDocument>(
          future: getPrefillNewOrgDocument(context, doc.orgDocumentSetupid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: ColorManager.blueprime),
              );
            }

            var data = snapshot.data!;
            docNameController.text = data.docName;
            expiryType = data.expiryType;

            return OrgDocNewEditPopup(
              title: EditPopupString.editCap,
              orgDocumentSetupid: data.orgDocumentSetupid,
              docTypeId: data.documentTypeId,
              subDocTypeId: data.documentSubTypeId,
              idOfDoc: data.idOfDocument,
              docName: data.docName,
              expiryType: data.expiryType,
              threshhold: data.threshold,
              expiryDate: data.expiryDate,
              expiryReminder: data.expiryReminder,
              docTypeText: AppStringEM.corporateAndComplianceDocuments,
              subDocTypeText: AppStringEM.capReport,
            );
          },
        );
      },
    );
  }

  Future<void> handleDelete(BuildContext context, NewOrgDocument doc) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteCap,
          loadingDuration: _isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoadingState(true);
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => DeleteSuccessPopup());
            } finally {
              setLoadingState(false);
            }
          },
        );
      },
    );
  }
}

class CiCcdCapReports extends StatefulWidget {
  final int docID;
  final int subDocId;

  const CiCcdCapReports({super.key, required this.docID, required this.subDocId});

  @override
  State<CiCcdCapReports> createState() => _CiCcdCapReportsState();
}

class _CiCcdCapReportsState extends State<CiCcdCapReports> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CiCcdCapReportsProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<NewOrgDocument>>(
          stream: provider.documentStream.stream,
          builder: (context, snapshot) {
            provider.fetchDocuments(context);

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: ColorManager.blueprime));
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Text(ErrorMessageString.noCR, style: AllNoDataAvailable.customTextStyle(context)));
            }

            if (snapshot.hasData) {
              const int itemsPerPage = 10;
              int currentPage = 1;
              int totalPages = (snapshot.data!.length / itemsPerPage).ceil();
              List<NewOrgDocument> paginatedData = snapshot.data!
                  .skip((currentPage - 1) * itemsPerPage)
                  .take(itemsPerPage)
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      const double minContentWidth = 1200;
                      final double contentWidth = constraints.maxWidth > minContentWidth
                          ? constraints.maxWidth
                          : minContentWidth;
                      return CustomScrollbar(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppPadding.p10),
                            child: SizedBox(
                              width: contentWidth,
                              height: constraints.maxHeight,
                              child: Column(
                                children: [
                                  TableHeadingConst(),
                                  SizedBox(height: AppSize.s10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: paginatedData.length,
                                      itemBuilder: (context, index) {
                                        int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                        String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                        NewOrgDocument policiesdata = paginatedData[index];
                                        return Column(
                                          children: [
                                            SizedBox(height: AppSize.s5),
                                            Container(
                                              padding: EdgeInsets.only(bottom: AppPadding.p5),
                                              margin: EdgeInsets.symmetric(horizontal: AppMargin.m50),
                                              decoration: BoxDecoration(
                                                color: ColorManager.white,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorManager.grey.withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              height: AppSize.s56,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Expanded(flex: 2, child: Center(child: Text(formattedSerialNumber, style: DocumentTypeDataStyle.customTextStyle(context), textAlign: TextAlign.start))),
                                                  Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(left: 115.0), child: Text(policiesdata.idOfDocument, style: DocumentTypeDataStyle.customTextStyle(context), textAlign: TextAlign.start))),
                                                  Expanded(flex: 1, child: SizedBox()),
                                                  Expanded(flex: 2, child: Padding(padding: EdgeInsets.only(left: AppPadding.p20), child: Text(policiesdata.docName, textAlign: TextAlign.start, style: DocumentTypeDataStyle.customTextStyle(context)))),
                                                  Expanded(flex: 2, child: Center(child: Text(policiesdata.expiryReminder, style: DocumentTypeDataStyle.customTextStyle(context)))),
                                                  Expanded(flex: 3, child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      IconButton(hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent, onPressed: () => provider.handleEdit(context, policiesdata), icon: Icon(Icons.edit_outlined, size: IconSize.I18, color: IconColorManager.bluebottom)),
                                                      IconButton(hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent, onPressed: () => provider.handleDelete(context, policiesdata), icon: Icon(Icons.delete_outline, size: IconSize.I18, color: IconColorManager.red)),
                                                    ],
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  PaginationControlsWidget(
                    currentPage: currentPage,
                    items: snapshot.data!,
                    itemsPerPage: itemsPerPage,
                    onPreviousPagePressed: () {
                      if (currentPage > 1) currentPage--;
                    },
                    onPageNumberPressed: (pageNumber) {
                      currentPage = pageNumber;
                    },
                    onNextPagePressed: () {
                      if (currentPage < totalPages) currentPage++;
                    },
                  ),
                ],
              );
            }

            return Offstage();
          },
        );
      },
    );
  }
}