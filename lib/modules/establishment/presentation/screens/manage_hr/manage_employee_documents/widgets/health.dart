import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/delete_popup_provider.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/employee_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/employee_doc/employee_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/heading_constant_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/emp_doc_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';

class HealthEmpDocProvider extends ChangeNotifier {
  final int metaDocID;
  HealthEmpDocProvider({required this.metaDocID});

  final StreamController<List<EmployeeDocumentModal>> _controller = StreamController<List<EmployeeDocumentModal>>();
  final int itemsPerPage = 10;
  bool _isLoading = false;
  int currentPage = 1;
  int flexVal = 2;

  Stream<List<EmployeeDocumentModal>> get employeeDocumentsStream => _controller.stream;

  /// Explicit init method to pass BuildContext
  void init(BuildContext context) {
    _fetchEmployeeDocs(context);
  }

  /// Fetch data with BuildContext
  void _fetchEmployeeDocs(BuildContext context) async {
    try {
      final data = await getEmployeeDoc(context, metaDocID, 1, 9999
      );
      _controller.add(data);
    } catch (error) {
      _controller.addError(error);
    }
  }

  List<EmployeeDocumentModal> getPaginatedData(List<EmployeeDocumentModal> docs) {
    return docs.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();
  }

  String getSerialNumber(int index) {
    return (index + 1 + (currentPage - 1) * itemsPerPage).toString().padLeft(2, '0');
  }

  void onPreviousPagePressed() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void onPageNumberPressed(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void onNextPagePressed() {
    currentPage++;
    notifyListeners();
  }
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  void handleEdit(BuildContext context, EmployeeDocumentModal doc) async {
    // Set the loading state to true
    setLoading(true);

    try {
      final snapshotPrefill = await getPrefillEmployeeDocTab(context, doc.employeeDocTypesetupId);
      TextEditingController idOfDocController = TextEditingController(text: snapshotPrefill.idOfDocument.toString());
      TextEditingController nameDocController = TextEditingController(text: snapshotPrefill.docName.toString());
      TextEditingController daysController = TextEditingController(text: snapshotPrefill.reminderThreshold.toString());
      String? expiryType = snapshotPrefill.expiryType;
      int empSetupId = snapshotPrefill.employeeDocTypesetupId ?? 0;
      String docName = snapshotPrefill.docName ?? '';

      // Show the edit dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ChangeNotifierProvider(
            create: (_) => EmpDocEditPopupProvider(),
            child: EmpDocEditPopup(
              title: EditPopupString.editDocument,
              expiryType: expiryType,
              idOfDocController: idOfDocController,
              enable: true,
              nameDocController: nameDocController,
              daysController: daysController,
              empsetupId: empSetupId,
              docname: docName,
              empdoctype: doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.healthDocId
              // empdoctype: doc.employeeDocTypeMetaId == AppConfig.healthDocId
                  ? AppStringEM.health
                  : doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.certificationDocId
                  // : doc.employeeDocTypeMetaId == AppConfig.certificationDocId
                  ? AppStringEM.certifications
                  : doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.employmentDocId
                  // : doc.employeeDocTypeMetaId == AppConfig.employmentDocId
                  ? AppStringEM.employment
                  : doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.clinicalVerificationDocId
                  // : doc.employeeDocTypeMetaId == AppConfig.clinicalVerificationDocId
                  ? AppStringEM.clinicalVerify
                  : doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.acknowledgementDocId
                  // : doc.employeeDocTypeMetaId == AppConfig.acknowledgementDocId
                  ? AppStringEM.acknowledgement
                  : doc.employeeDocTypeMetaId == FrontendConfigStore.data!.config.compensationDocId
                  // : doc.employeeDocTypeMetaId == AppConfig.compensationDocId
                  ? AppStringEM.compensation
                  : AppStringEM.performance,
              employeeDocTypeMetaDataId: doc.employeeDocTypeMetaId,
              onEditSuccess: () {
                _fetchEmployeeDocs(context);
              },
            ),
          );
        },
      );
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void handleDelete(BuildContext context, EmployeeDocumentModal doc) async {
    // Show the confirmation dialog for deleting the document
    showDialog(
      context: context,
      builder: (context) {
              return DeletePopupProvider(
                title: DeletePopupString.deleteDocument,
                loadingDuration: _isLoading,
                onCancel: () {
                  Navigator.pop(context);
                },
                onDelete: () async {
                  setLoading(true);
                  try {
                    // Perform the delete operation
                    await employeedoctypeSetupIdDelete(context, doc.employeeDocTypesetupId);
                    _fetchEmployeeDocs(context);
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => DeleteSuccessPopup(),
                    );
                  } finally{
                    _fetchEmployeeDocs(context);
                    setLoading(false);
                  }
                },
              );}
    );
  }
}

class HealthEmpDoc extends StatefulWidget {
  final int metaDocID;
  const HealthEmpDoc({super.key, required this.metaDocID});

  @override
  State<HealthEmpDoc> createState() => _HealthEmpDocState();
}

class _HealthEmpDocState extends State<HealthEmpDoc> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HealthEmpDocProvider>(
      create: (context) {
        final provider = HealthEmpDocProvider(metaDocID: widget.metaDocID);
        provider.init(context);
        return provider;
      },
      child: Consumer<HealthEmpDocProvider>(
        builder: (context, provider, _) {
          return Container(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<EmployeeDocumentModal>>(
                    stream: provider.employeeDocumentsStream,
                    builder: (context, snapshot) {
                      provider._fetchEmployeeDocs(context);
                      print('Connection state: ${snapshot.connectionState}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorManager.blueprime,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: AllNoDataAvailable.customTextStyle(context),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        print('No data found');
                        return Center(
                          child: Text(
                            ErrorMessageString.noEmpDocc,
                            style: AllNoDataAvailable.customTextStyle(context),
                          ),
                        );
                      }

                      int totalItems = snapshot.data!.length;
                      int totalPages = (totalItems / provider.itemsPerPage).ceil();
                      List<EmployeeDocumentModal> paginatedData = snapshot.data!
                          .skip((provider.currentPage - 1) * provider.itemsPerPage)
                          .take(provider.itemsPerPage)
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
                                                final serialNumber = provider.getSerialNumber(index);
                                                final employeeDoc = paginatedData[index];

                                                return Column(
                                                  children: [
                                                    SizedBox(height: AppSize.s5),
                                                    Container(
                                                      padding: const EdgeInsets.only(bottom: AppPadding.p5),
                                                      margin: const EdgeInsets.symmetric(horizontal: AppMargin.m50),
                                                      decoration: BoxDecoration(
                                                        color: ColorManager.white,
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: ColorManager.grey.withOpacity(0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      height: AppSize.s56,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Expanded(
                                                            flex: provider.flexVal,
                                                            child: Center(
                                                              child: Text(
                                                                serialNumber,
                                                                style: DocumentTypeDataStyle.customTextStyle(context),
                                                                textAlign: TextAlign.start,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: provider.flexVal,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 114.0),
                                                              child: Text(
                                                                employeeDoc.idOfDocument ?? 'N/A',
                                                                style: DocumentTypeDataStyle.customTextStyle(context),
                                                                textAlign: TextAlign.start,
                                                              ),
                                                            ),
                                                          ),
                                                          const Expanded(flex: 1, child: SizedBox()),
                                                          Expanded(
                                                            flex: provider.flexVal,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: AppPadding.p20),
                                                              child: Text(
                                                                employeeDoc.docName ?? 'N/A',
                                                                textAlign: TextAlign.start,
                                                                style: DocumentTypeDataStyle.customTextStyle(context),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: provider.flexVal,
                                                            child: Center(
                                                              child: Text(
                                                                employeeDoc.reminderThreshold ?? 'N/A',
                                                                style: DocumentTypeDataStyle.customTextStyle(context),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      provider.handleEdit(context, employeeDoc);
                                                                    },
                                                                    icon: Icon(
                                                                      Icons.edit_outlined,
                                                                      size: IconSize.I18,
                                                                      color: IconColorManager.bluebottom,
                                                                    ),
                                                                    splashColor: Colors.transparent,
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  IconButton(
                                                                    splashColor: Colors.transparent,
                                                                    highlightColor: Colors.transparent,
                                                                    hoverColor: Colors.transparent,
                                                                    onPressed: () {
                                                                      provider.handleDelete(context, employeeDoc);
                                                                    },
                                                                    icon: Icon(
                                                                      size: IconSize.I18,
                                                                      Icons.delete_outline_outlined,
                                                                      color: IconColorManager.red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
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
                            currentPage: provider.currentPage,
                            items: snapshot.data!,
                            itemsPerPage: provider.itemsPerPage,
                            onPreviousPagePressed: () {
                              if (provider.currentPage > 1) {
                                provider.currentPage--;
                              }
                            },
                            onPageNumberPressed: (pageNumber) {
                              provider.currentPage = pageNumber;
                            },
                            onNextPagePressed: () {
                              if (provider.currentPage < totalPages) {
                                provider.currentPage++;
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

