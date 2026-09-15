import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_corporate&compiliance_document.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_policies&procedure.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_vendor_contract.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/company_identity_screen.dart';

///provider
class CiOrgDocumentProvider with ChangeNotifier {
  final PageController tabPageController = PageController();
  int selectedIndex = 0;

  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calendarController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId1Licenses; // Default value
  // int selectedSubDocId = AppConfig.subDocId1Licenses; // Default value
  String selectedSubDocType = "";

  CiOrgDocumentProvider() {
    updateSelectedSubDocId(selectedSubDocId);
  }

  void selectButton(int index) {
    if (selectedIndex == index) return;
    selectedIndex = index;
    if (selectedIndex == 0) {
      updateSelectedSubDocId( FrontendConfigStore.data!.config.subDocId1Licenses);
      // updateSelectedSubDocId(AppConfig.subDocId1Licenses);
    } else if (selectedIndex == 1) {
      updateSelectedSubDocId(  FrontendConfigStore.data!.config.subDocId6Leases,);
      // updateSelectedSubDocId(AppConfig.subDocId6Leases);
    } else if (selectedIndex == 2) {
      updateSelectedSubDocId(FrontendConfigStore.data!.config.subDocId0);
      // updateSelectedSubDocId(AppConfig.subDocId0);
    }

    tabPageController.jumpToPage(index);
    // animateToPage(
    //   index,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.ease,
    // );
    notifyListeners();
  }

  void updateSelectedSubDocId(int subDocId) {
    selectedSubDocId = subDocId;
    selectedSubDocType = getSubDocTypeText(subDocId);
    print('Updated SubDocId: $subDocId, SubDocTypeText: $selectedSubDocType'); // Debug print
    notifyListeners();
  }



  String getSubDocTypeText(int subDocId) {
    final cfg = FrontendConfigStore.data!.config;

    switch (subDocId) {
      case _ when subDocId == cfg.subDocId1Licenses:
        return AppStringEM.licenses;

      case _ when subDocId == cfg.subDocId2Adr:
        return AppStringEM.ard;

      case _ when subDocId == cfg.subDocId3CICCMedicalCR:
        return AppStringEM.mcr;

      case _ when subDocId == cfg.subDocId4CapReport:
        return AppStringEM.capReport;

      case  _ when subDocId == cfg.subDocId5BalReport:
        return AppStringEM.qbr;

      case  _ when subDocId == cfg.subDocId6Leases:
        return AppStringEM.leases;

      case  _ when subDocId == cfg.subDocId7SNF:
        return AppStringEM.snf;

      case  _ when subDocId == cfg.subDocId8DME:
        return AppStringEM.dme;

      case  _ when subDocId == cfg.subDocId9MD:
        return AppStringEM.md;

      case _ when subDocId == cfg.subDocId10MISC:
        return AppStringEM.misc;

      default:
        return "Unknown Document Type";
    }
  }


  // String getSubDocTypeText(int subDocId) {
  //   switch (subDocId) {
  //     case AppConfig.subDocId1Licenses:
  //     // case AppConfig.subDocId1Licenses:
  //       return AppStringEM.licenses;
  //     case AppConfig.subDocId2Adr:
  //       return AppStringEM.ard;
  //     case AppConfig.subDocId3CICCMedicalCR:
  //       return AppStringEM.mcr;
  //     case AppConfig.subDocId4CapReport:
  //       return AppStringEM.capReport;
  //     case AppConfig.subDocId5BalReport:
  //       return AppStringEM.qbr;
  //     case AppConfig.subDocId6Leases:
  //       return AppStringEM.leases;
  //     case AppConfig.subDocId7SNF:
  //       return AppStringEM.snf;
  //     case AppConfig.subDocId8DME:
  //       return AppStringEM.dme;
  //     case AppConfig.subDocId9MD:
  //       return AppStringEM.md;
  //     case AppConfig.subDocId10MISC:
  //       return AppStringEM.misc;
  //     default:
  //       return "Unknown Document Type";
  //   }
  // }
}

class CiOrgDocument extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CiOrgDocumentProvider(),
      child: Consumer<CiOrgDocumentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              SizedBox(height: AppSize.s20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.s45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: AppSize.s20, width: AppSize.s150),
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        width: 840,
                        height: AppSize.s30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: ColorManager.blueprime,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            tabButton(
                              context,
                              0,
                              AppStringEM.corporateAndComplianceDocuments,
                            ),
                            tabButton(
                              context,
                              1,
                              AppStringEM.vendorContracts,
                            ),
                            tabButton(
                              context,
                              2,
                              AppStringEM.policiesAndProcedures,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildAddButton(context, provider),
                  ],
                ),
              ),
              SizedBox(height: AppSize.s30),
              Expanded(
                child: Stack(
                  children: [
                    provider.selectedIndex == 2
                        ? Offstage()
                        : Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F9FC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Inner shadow effect at the top
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 8, // Adjust the height of the shadow effect
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2), // Darker at top
                                    Colors.transparent, // Fades out
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PageView Content
                    NonScrollablePageView(
                      controller: provider.tabPageController,
                      onPageChanged: provider.selectButton,
                      children: [
                        CICorporateCompilianceDocument(
                          docID:FrontendConfigStore.data!.config.corporateAndCompliance,
                          // docID: AppConfig.corporateAndCompliance,
                          selectedSubDocType: provider.selectedSubDocType,
                          onSubDocIdSelected: provider.updateSelectedSubDocId,
                        ),
                        CIVendorContract(
                          docId:  FrontendConfigStore.data!.config.vendorContracts,
                          // docId: AppConfig.vendorContracts,
                          onSubDocIdSelected: provider.updateSelectedSubDocId,
                          selectedSubDocType: provider.selectedSubDocType,
                        ),
                        ChangeNotifierProvider(
                          create: (context) => CIPoliciesProcedureProvider(),
                          child: CIPoliciesProcedure(
                            docId: FrontendConfigStore.data!.config.policiesAndProcedure,
                            // docId: AppConfig.policiesAndProcedure,
                            subDocId: FrontendConfigStore.data!.config.subDocId0,
                            // subDocId: AppConfig.subDocId0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )

              //     Expanded(
          //       child: Stack(
          // children: [
          // provider.selectedIndex == 2
          // ? Offstage()
          //     :Container(
          //    height: MediaQuery.of(context).size.height / 3.5,
          //   decoration: BoxDecoration(
          //       color: Color(0xFFF2F9FC),
          //       borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(20),
          //           topRight: Radius.circular(20)),
          //       boxShadow: [
          //         BoxShadow(
          //           color: ColorManager.faintGrey,
          //           blurRadius: 2,
          //           spreadRadius: -2,
          //           offset: Offset(0, -4),
          //         ),
          //       ]),
          // ),
          //       NonScrollablePageView(
          //         controller: provider.tabPageController,
          //         onPageChanged: provider.selectButton,
          //         children: [
          //           // Container(color: ColorManager.red,),
          //           // Container(color: ColorManager.fGrey,),
          //         CICorporateCompilianceDocument(
          //           docID: AppConfig.corporateAndCompliance,
          //           selectedSubDocType: provider.selectedSubDocType,
          //           onSubDocIdSelected: provider.updateSelectedSubDocId, //officeId: widget.officeId,
          //         ),
          //         // ChangeNotifierProvider(
          //         //   create: (context) => CIVendorContract(),
          //         //   child:
          //          CIVendorContract(
          //             docId: AppConfig.vendorContracts,
          //             onSubDocIdSelected: provider.updateSelectedSubDocId,
          //             selectedSubDocType: provider.selectedSubDocType, //officeId: widget.officeId
          //           ),
          //         //),
          //           ChangeNotifierProvider(
          //             create: (context) => CIPoliciesProcedureProvider(),
          //             child: CIPoliciesProcedure(
          //               docId: AppConfig.policiesAndProcedure,
          //               subDocId: AppConfig.subDocId0,
          //             ),
          //           ),
          //         ],
          //       ),
          // ],
          //       ),
          //     ),
            ],
          );
        },
      ),
    );
  }

  Widget tabButton(BuildContext context, int index, String text) {
    final provider = Provider.of<CiOrgDocumentProvider>(context, listen: false);
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () => provider.selectButton(index),
        child: Container(
          height: AppSize.s30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: provider.selectedIndex == index
                ? Colors.white
                : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              style: BlueBgTabbar.customTextStyle(index, provider.selectedIndex),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CiOrgDocumentProvider provider) {
    return Align(
      alignment: Alignment.bottomRight,
      child: CustomIconButtonConst(
        width: AppSize.s137,
        height: AppSize.s30,
        icon: Icons.add,
        text: AddPopupString.addDocType,
        onPressed: ()async{
          showDialog(
            context: context,
            builder: (context) {
              return ChangeNotifierProvider(
                create: (_) => AddNewOrgDocButtonProvider(
                    docTypeId: provider.selectedIndex == 0
                        ? FrontendConfigStore.data!.config.corporateAndCompliance : provider.selectedIndex == 1
                        // ? AppConfig.corporateAndCompliance : provider.selectedIndex == 1
                        ?  FrontendConfigStore.data!.config.vendorContracts : FrontendConfigStore.data!.config.policiesAndProcedure,
                        // ? AppConfig.vendorContracts : AppConfig.policiesAndProcedure,
                  subDocTypeId: provider.selectedIndex == 2
                      ? FrontendConfigStore.data!.config.subDocId0 : provider.selectedSubDocId,),
                      // ? AppConfig.subDocId0 : provider.selectedSubDocId,),
                child: AddNewOrgDocButton(
                  title: provider.selectedIndex == 0 ? AddPopupString.addCorporate : provider.selectedIndex == 1 ? AddPopupString.addVendor : AddPopupString.addPolicy,
                  docTypeText:  provider.selectedIndex == 0
                      ? AppStringEM.corporateAndComplianceDocuments : provider.selectedIndex == 1
                      ? AppStringEM.vendorContracts : AppStringEM.policiesAndProcedures,
                  docTypeId: provider.selectedIndex == 0
                      ? FrontendConfigStore.data!.config.corporateAndCompliance : provider.selectedIndex == 1
                      // ? AppConfig.corporateAndCompliance : provider.selectedIndex == 1
                      ? FrontendConfigStore.data!.config.vendorContracts :FrontendConfigStore.data!.config.policiesAndProcedure,
                      // ? AppConfig.vendorContracts : AppConfig.policiesAndProcedure,

                  selectedSubDocType:provider.selectedSubDocType,
                  subDocTypeId: provider.selectedIndex == 2
                      ? FrontendConfigStore.data!.config.subDocId0 : provider.selectedSubDocId,
                      // ? AppConfig.subDocId0 : provider.selectedSubDocId,
                  subDocTypeText: provider.selectedSubDocType,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

