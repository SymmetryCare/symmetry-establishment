import 'package:flutter/material.dart';
import 'package:prohealth/app/constants/app_config.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_snf.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_leases.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_dme.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_misc.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vd_md.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../../data/appconfige_data/app_confige_data.dart';

class VendorContractState with ChangeNotifier {
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
        return AppStringEM.leases;
      case 1:
        return AppStringEM.snf;
      case 2:
        return AppStringEM.dme;
      case 3:
        return AppStringEM.md;
      case 4:
        return AppStringEM.misc;
      default:
        return "";
    }
  }

  int getSubDocIdForIndex(int index) {
    switch (index) {
      case 0:
        return   FrontendConfigStore.data!.config.subDocId6Leases;
        // return AppConfig.subDocId6Leases;
      case 1:
        return FrontendConfigStore.data!.config.subDocId7SNF;
        // return AppConfig.subDocId7SNF;
      case 2:
        return FrontendConfigStore.data!.config.subDocId8DME;
        // return AppConfig.subDocId8DME;
      case 3:
        return FrontendConfigStore.data!.config.subDocId9MD;
        // return AppConfig.subDocId9MD;
      case 4:
        return FrontendConfigStore.data!.config.subDocId10MISC;
        // return AppConfig.subDocId10MISC;
      default:
        return 0;
    }
  }
}

class CIVendorContract extends StatelessWidget {
  final int docId;
  final Function(int) onSubDocIdSelected;
  final String selectedSubDocType;

  CIVendorContract({
    Key? key,
    required this.docId,
    required this.onSubDocIdSelected,
    required this.selectedSubDocType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return ChangeNotifierProvider(
      create: (_) => VendorContractState(),
      child: Consumer<VendorContractState>(
        builder: (context, vendorContractState, child) {
          // Sync PageController with selectedIndex
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients &&
                pageController.page?.round() != vendorContractState.selectedIndex) {
              pageController.jumpToPage(vendorContractState.selectedIndex);
            }
          });

          return Column(
            children: [
              SizedBox(height: AppSize.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
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
                              width: MediaQuery.of(context).size.width / 10,
                              child: Column(
                                children: [
                                  Text(
                                    vendorContractState.getSubDocTypeForIndex(index),
                                    style: TransparentBgTabbar.customTextStyle(
                                      index,
                                      vendorContractState.selectedIndex,
                                    ),
                                  ),
                                  vendorContractState.selectedIndex == index
                                      ?  Divider(
                                    color: ColorManager.blueprime,
                                    thickness: 2,
                                  )
                                      : const Offstage(),
                                ],
                              ),
                            ),
                            onTap: () {
                              vendorContractState.setSelectedIndex(index);
                              onSubDocIdSelected(
                                  vendorContractState.getSubDocIdForIndex(index));
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
                      vendorContractState.setSelectedIndex(index);
                      onSubDocIdSelected(
                          vendorContractState.getSubDocIdForIndex(index));
                    },
                    children: [
                      VendorContractLeases(
                        docId: docId,
                        subDocID:  FrontendConfigStore.data!.config.subDocId6Leases,
                        // subDocID: AppConfig.subDocId6Leases,
                      ),
                        ChangeNotifierProvider(
                          create: (_) => VendorContractSNFProvider(),
                          child: VendorContractSNF(docId: docId, subDocId:FrontendConfigStore.data!.config.subDocId7SNF),
                          // child: VendorContractSNF(docId: docId, subDocId: AppConfig.subDocId7SNF),
                          ),
                      ChangeNotifierProvider(
                        create: (_) => VendorContractDMEProvider(),
                        child: VendorContractDME(
                          docId: docId,
                          subDocId: FrontendConfigStore.data!.config.subDocId8DME,
                          // subDocId: AppConfig.subDocId8DME,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => VendorContractMDProvider(),
                        child: VendorContractMD(
                          docId: docId,
                          subDocId: FrontendConfigStore.data!.config.subDocId9MD,
                          // subDocId: AppConfig.subDocId9MD,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => VendorContractMISCProvider(),
                        child: VendorContractMISC(
                          docId: docId,
                          subDocId: FrontendConfigStore.data!.config.subDocId10MISC,
                          // subDocId: AppConfig.subDocId10MISC,
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
