import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/employee_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/health.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/emp_doc_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

class ManageEmployDocumentProvider with ChangeNotifier {
  final PageController _managePageController = PageController();
  int _selectedIndex = 1;

  PageController get managePageController => _managePageController;

  int get selectedIndex => _selectedIndex;

  void selectButton(int index) {
    _selectedIndex = index;
    _managePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _managePageController.dispose();
    super.dispose();
  }
}

class ManageEmployDocument extends StatelessWidget {
  const ManageEmployDocument({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ManageEmployDocumentProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => ManageEmpDocProvider(),
      child: ManageEmpDocWidget(
        managePageController: provider.managePageController,
       // selectedIndex: provider.selectedIndex,
        selectButton: provider.selectButton,
      ),
    );
  }
}

///tabbar
class ManageEmpDocProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String? _expiryType;
  String? get expiryType => _expiryType;

  int _metaDocID = 0;
  int get metaDocID => _metaDocID;

  void selectButton(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setExpiryType(String? type) {
    _expiryType = type;
    notifyListeners();
  }

  void setMetaDocID(int id) {
    _metaDocID = id;
    notifyListeners();
  }

  void _fetchEmployeeDocs(BuildContext context, int metaDocID) async {
    try {
      final data = await getEmployeeDoc(context, metaDocID, 1, 20);
      // Add the new data to your stream or state management solution here
    } catch (error) {
      // Handle errors appropriately
      print('Error fetching documents: $error');
    }
  }

}

class ManageEmpDocWidget extends StatelessWidget {
  final PageController managePageController;
  final Function(int) selectButton;

  ManageEmpDocWidget({
    Key? key,
    required this.managePageController,
    required this.selectButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ManageEmpDocProvider>(
      builder: (context, provider, child) {
        return Material(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppPadding.p65, vertical: AppPadding.p20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomIconButtonConst(
                     width: AppSize.s137,
                      height: AppSize.s30,
                      text: AppStringEM.adddoctype,
                      onPressed: () async {
                        provider.setExpiryType(null);
                        provider.setMetaDocID(0);
                        int subDocId = _getSubDocId(provider.selectedIndex);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  void Function(void Function()) setState) {
                                return ChangeNotifierProvider(
                                  create: (_) => EmpDocADDPopupProvider(),
                                  child: EmpDocADDPopup(
                                    title: AddPopupString.addDocument,
                                    Subdocid: subDocId,
                                    onSave: () {
                                      provider._fetchEmployeeDocs(context, subDocId);
                                      getEmployeeDoc(context, subDocId, 1, 20);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),

              /// Tab bar
              Padding(
                padding: const EdgeInsets.only(left: AppPadding.p15),
                child: Container(
                  height: AppSize.s30,
                  width: MediaQuery.of(context).size.width / 1.2025,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                    color: ColorManager.blueprime,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (index) {
                      return InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          provider.selectButton(index);
                          // Jump directly to the selected page without animation
                          managePageController.jumpToPage(index);
                        },
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 8.422,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: provider.selectedIndex == index
                                ? ColorManager.white
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              _getTabLabel(index),
                              textAlign: TextAlign.center,
                              style: BlueBgTabbar.customTextStyle(index, provider.selectedIndex),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),


              const SizedBox(height: AppSize.s30),
              Expanded(
                flex: 10,
                child: Container(
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
                  Padding(
                    padding: EdgeInsets.only(
                        left: AppPadding.p20,
                        right: AppPadding.p20,
                        top: AppPadding.p20),
                    child: PageView(
                      controller: managePageController,
                      onPageChanged: (index) {
                        provider.selectButton(index);
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(7, (index) {
                        return ChangeNotifierProvider(
                            create: (_) => HealthEmpDocProvider(metaDocID: _getDocIdForTab(index)),
                            child: HealthEmpDoc(metaDocID: _getDocIdForTab(index)));
                      }),
                    ),
                  ),
                ],
                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0:
        return AppStringEM.health;
      case 1:
        return AppStringEM.certifications;
      case 2:
        return AppStringEM.employment;
      case 3:
        return AppStringEM.clinicalVerify;
      case 4:
        return AppStringEM.acknowledgement;
      case 5:
        return AppStringEM.compensation;
      case 6:
        return AppStringEM.performance;
      default:
        return '';
    }
  }

  int _getSubDocId(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return FrontendConfigStore.data!.config.healthDocId;
        // return AppConfig.healthDocId;
      case 1:
        return FrontendConfigStore.data!.config.certificationDocId;
        // return AppConfig.certificationDocId;
      case 2:
        return FrontendConfigStore.data!.config.employmentDocId;
        // return AppConfig.employmentDocId;
      case 3:
        return FrontendConfigStore.data!.config.clinicalVerificationDocId;
        // return AppConfig.clinicalVerificationDocId;
      case 4:
        return FrontendConfigStore.data!.config.acknowledgementDocId;
        // return AppConfig.acknowledgementDocId;
      case 5:
        return FrontendConfigStore.data!.config.compensationDocId;
        // return AppConfig.compensationDocId;
      case 6:
        return FrontendConfigStore.data!.config.performanceDocId;
        // return AppConfig.performanceDocId;
      default:
        return FrontendConfigStore.data!.config.healthDocId;
        // return AppConfig.healthDocId;
    }
  }

  int _getDocIdForTab(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return FrontendConfigStore.data!.config.healthDocId;
        // return AppConfig.healthDocId;
      case 1:
        return FrontendConfigStore.data!.config.certificationDocId;
        // return AppConfig.certificationDocId;
      case 2:
        return FrontendConfigStore.data!.config.employmentDocId;
        // return AppConfig.employmentDocId;
      case 3:
        return FrontendConfigStore.data!.config.clinicalVerificationDocId;
        // return AppConfig.clinicalVerificationDocId;
      case 4:
        return FrontendConfigStore.data!.config.acknowledgementDocId;
        // return AppConfig.acknowledgementDocId;
      case 5:
        return FrontendConfigStore.data!.config.compensationDocId;
        // return AppConfig.compensationDocId;
      case 6:
        return FrontendConfigStore.data!.config.performanceDocId;
        // return AppConfig.performanceDocId;
      default:
        return FrontendConfigStore.data!.config.healthDocId;
        // return AppConfig.healthDocId;
    }
  }
}
