import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_adr.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_cap_report.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_license.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_medical_cost_report.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_quarterly_balance_report.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

class CICorporateComplianceState with ChangeNotifier {
  int _selectedIndex = 0;
  String _selectedSubDocType = "";

  String get selectedSubDocType => _selectedSubDocType;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    _selectedSubDocType = getSubDocTypeForIndex(index);
    notifyListeners();
  }

  String getSubDocTypeForIndex(int index) {
    switch (index) {
      case 0:
        return AppStringEM.licenses;
      case 1:
        return AppStringEM.ard;
      case 2:
        return AppStringEM.mcr;
      case 3:
        return AppStringEM.capReport;
      case 4:
        return AppStringEM.qbr;
      default:
        return "";
    }
  }

  int getSubDocIdForIndex(int index) {
    switch (index) {
      case 0:
        return  FrontendConfigStore.data!.config.subDocId1Licenses;
        // return AppConfig.subDocId1Licenses;
      case 1:
        return FrontendConfigStore.data!.config.subDocId2Adr;
        // return AppConfig.subDocId2Adr;
      case 2:
        return FrontendConfigStore.data!.config.subDocId3CICCMedicalCR;
       // return AppConfig.subDocId3CICCMedicalCR;
      case 3:
        return FrontendConfigStore.data!.config.subDocId4CapReport;
        // return AppConfig.subDocId4CapReport;
      case 4:
        return FrontendConfigStore.data!.config.subDocId5BalReport;
      default:
        return 0;
    }
  }
}

class CICorporateCompilianceDocument extends StatelessWidget {
  final int docID;
  final Function(int) onSubDocIdSelected;
  final String selectedSubDocType;

  const CICorporateCompilianceDocument({
    Key? key,
    required this.docID,
    required this.onSubDocIdSelected,
    required this.selectedSubDocType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return ChangeNotifierProvider(
      create: (_) => CICorporateComplianceState(),
      child: Consumer<CICorporateComplianceState>(
        builder: (context, corporateState, child) {
          // Sync PageController with selectedIndex
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients &&
                pageController.page?.round() != corporateState.selectedIndex) {
              pageController.jumpToPage(corporateState.selectedIndex);
            }
          });

          return Column(
            children: [
              SizedBox(height: AppSize.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.8,
                    height: AppSize.s50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Repeatable Tab Item
                        for (int index = 0; index < 5; index++)
                          InkWell(
                            highlightColor: const Color(0xFFF2F9FC),
                            hoverColor: const Color(0xFFF2F9FC),
                            child: Container(
                              height: AppSize.s50,
                              width: index == 4
                                  ? MediaQuery.of(context).size.width / 9
                                  : MediaQuery.of(context).size.width / 10,
                              child: Column(
                                children: [
                                  Text(
                                    corporateState.getSubDocTypeForIndex(index),
                                    style: TransparentBgTabbar.customTextStyle(
                                      index,
                                      corporateState.selectedIndex,
                                    ),
                                  ),
                                  corporateState.selectedIndex == index
                                      ? Divider(
                                    color: ColorManager.blueprime,
                                    thickness: 2,
                                  )
                                      : const Offstage(),
                                ],
                              ),
                            ),
                            onTap: () {
                              corporateState.setSelectedIndex(index);
                              onSubDocIdSelected(
                                  corporateState.getSubDocIdForIndex(index));
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p10),
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      corporateState.setSelectedIndex(index);
                      onSubDocIdSelected(
                          corporateState.getSubDocIdForIndex(index));
                    },
                    children: [
                      ChangeNotifierProvider(
                      create: (_) => CICcdLicenseProvider(),
                      child: CICcdLicense(subDocID: docID, docID:  FrontendConfigStore.data!.config.subDocId1Licenses,),
                      // child: CICcdLicense(subDocID: docID, docID: AppConfig.subDocId1Licenses),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CICcdADRProvider(),
                        child: CICcdADR(
                          docID: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId2Adr,
                          // subDocID: AppConfig.subDocId2Adr,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CiCcdMedicalCostReportProvider(),
                        child: CiCcdMedicalCostReport(
                          docID: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId3CICCMedicalCR,
                          // subDocID: AppConfig.subDocId3CICCMedicalCR,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CiCcdCapReportsProvider(),
                        child: CiCcdCapReports(
                          docID: docID,
                          subDocId: FrontendConfigStore.data!.config.subDocId4CapReport,
                          // subDocId: AppConfig.subDocId4CapReport,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CICcdQuarteryBalanceReportProvider(),
                        child: CICcdQuarteryBalanceReport(
                          docId: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId5BalReport,
                          // subDocID: AppConfig.subDocId5BalReport,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
