import 'dart:async';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/constants/app_config.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/const_string.dart';
import 'package:prohealth/app/resources/establishment_resources/establish_theme_manager.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/screen_route_name.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/widgets/add_emp_popup_const.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/widgets/edit_emp_popup_const.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import '../../../../data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import '../../../../data/appconfige_data/app_confige_data.dart';
import '../../../widgets/error_popups/delete_success_popup.dart';
import '../../../widgets/widgets/custom_icon_button_constant.dart';
import '../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../company_identity/widgets/whitelabelling/success_popup.dart';
import 'hr_clinitian_tab.dart';
import 'hr_salesAdmin_tab.dart';
import 'manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';

/// stl conversion
class HrScreenProvider with ChangeNotifier {
  final PageController hrPageController = PageController();
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;
  void selectButton(int index) {
    _selectedIndex = index;
    notifyListeners();
    hrPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
}

class HrScreen extends StatelessWidget {
  static const String routeName = RouteStrings.emHrAdminScreen;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HrScreenProvider(),
      child: Consumer<HrScreenProvider>(
        builder: (context, hrProvider, child) {
          return ChangeNotifierProvider(
            create: (_) => HrWidgetProvider(),
            child: HrWidget(
              hrPageController: hrProvider.hrPageController,
              selectedIndex: hrProvider.selectedIndex,
              selectButton: hrProvider.selectButton,
            ),
          );
        },
      ),
    );
  }
}

///
class HrWidgetProvider with ChangeNotifier {
  final PageController _hrPageController = PageController();
  TextEditingController typeController = TextEditingController();
  TextEditingController shorthandController = TextEditingController();
  final StreamController<List<HRAllData>> _controller = StreamController<List<HRAllData>>();
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  var _deptId = 0;
  get deptId => _deptId;
  String color = "";
  List<Color> containerColors = List.generate(20, (index) => Color(0xffE8A87D));

  HrWidgetProvider() {
    _loadColors();
  }

  void selectButton(int index) {
    _selectedIndex = index;
    notifyListeners();
    _hrPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < containerColors.length; i++) {
      int? colorValue = prefs.getInt('containerColor$i');
      if (colorValue != null) {
        containerColors[i] = Color(colorValue);
      }
    }
    notifyListeners();
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }


  Future<void> saveColor(int index, Color selectedColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('containerColor$index', selectedColor.r.toInt());
    containerColors[index] = selectedColor;
    color = colorToHex(selectedColor);
    notifyListeners();
  }

  void handleColorChange(int index, Color selectedColor) {
    saveColor(index, selectedColor);
  }
}

class HrWidget extends StatelessWidget {
  final PageController hrPageController;
  final int selectedIndex;
  final Function(int) selectButton;
  const HrWidget({super.key, required this.hrPageController, required this.selectedIndex, required this.selectButton});

  @override
  Widget build(BuildContext context) {
    return Consumer<HrWidgetProvider>(
      builder: (context, provider, child) {
        return Material(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width/70
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 180,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppPadding.p24),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: AppSize.s30,
                          width: MediaQuery.of(context).size.width / 2.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ColorManager.blueprime,
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.black.withValues(alpha: 0.25),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    child: Container(
                                      height: AppSize.s30,
                                      width: MediaQuery.of(context).size.width / 8.421,
                                      padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: provider.selectedIndex == 0
                                            ? ColorManager.white
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        AppStringEM.clinical,
                                        textAlign: TextAlign.center,
                                        style: BlueBgTabbar.customTextStyle(0, provider.selectedIndex),
                                      ),
                                    ),
                                    onTap: () {
                                      provider.selectButton(0);
                                      // metaDocID = snapshot.data![index].employeeDocMetaDataId;
                                    }),
                                InkWell(
                                    child: Container(
                                      height: AppSize.s30,
                                      width: MediaQuery.of(context).size.width / 8.421,
                                      padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: provider.selectedIndex == 1
                                            ? ColorManager.white
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        AppStringEM.sales,
                                        textAlign: TextAlign.center,
                                        style: BlueBgTabbar.customTextStyle(1, provider.selectedIndex),
                                      ),
                                    ),
                                    onTap: () {
                                      provider.selectButton(1);
                                      // metaDocID = snapshot.data![index].employeeDocMetaDataId;
                                    }),
                                InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    child: Container(
                                      height: AppSize.s30,
                                      width:
                                      MediaQuery.of(context).size.width / 8.421,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: AppPadding.p6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: provider.selectedIndex == 2
                                            ? ColorManager.white
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        AppStringEM.administration,
                                        textAlign: TextAlign.center,
                                        style: BlueBgTabbar.customTextStyle(2, provider.selectedIndex),
                                      ),
                                    ),
                                    onTap: () {
                                      provider.selectButton(2);
                                      // metaDocID = snapshot.data![index].employeeDocMetaDataId;
                                    }),
                              ]),
                        ),
                      )
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width/24),
                      child: CustomIconButtonConst(
                          width: AppSize.s181,
                          height: AppSize.s30,
                          text: AppString.addemployeetype,
                          icon: Icons.add,
                          onPressed: () {
                            // provider._deptId = provider.selectedIndex == 0
                            //     ? AppConfig.clinicalId
                            //     : provider.selectedIndex == 1
                            //     ? AppConfig.salesId
                            //     : AppConfig.AdministrationId;
                            provider._deptId = provider.selectedIndex == 0
                                ? FrontendConfigStore.data!.config.clinicalId
                                : provider.selectedIndex == 1
                                ? FrontendConfigStore.data!.config.salesId
                                : FrontendConfigStore.data!.config.administrationId;
                            provider.typeController.clear();
                            provider.shorthandController.clear();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomPopupWidget(
                                  isClinitian: provider.selectedIndex == 1 || provider.selectedIndex == 2 ? false : true,
                                  typeController: provider.typeController,
                                  abbreviationController: provider.shorthandController,
                                  containerColor: provider.containerColors[1],
                                  departmentId: provider.deptId,


                                  // onAddPressed: (String selectedColorToSave) async {
                                  //   print('$provider.deptId');
                                  //
                                  //   // ✅ If you added dropdown in popup:
                                  //   // selectedRadio == Yes -> assistant true + selected master type id
                                  //   // selectedRadio == No  -> assistant false + master null
                                  //   // final bool isAssistant = provider.popupSelectedRadio == 'Yes';
                                  //   // final int? assistantMasterId = provider.popupSelectedEmployeeTypeId;
                                  //
                                  //
                                  //
                                  //   var response = await addEmployeeTypePost(
                                  //       context,
                                  //       provider.deptId,
                                  //       provider.typeController.text,
                                  //       selectedColorToSave,//provider.color,
                                  //       provider.shorthandController.text,
                                  //     payload.isAssistant,
                                  //     payload.assistantMasterId,
                                  //   );
                                  //   getAllHrDeptWise(context,provider.deptId).then((data){
                                  //     provider._controller.add(data);
                                  //   }).catchError((error){});
                                  //   if(response.statusCode == 200 || response.statusCode == 201){
                                  //     Navigator.pop(context);
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (BuildContext context) {
                                  //         return AddSuccessPopup(
                                  //           message: 'Added Successfully',
                                  //         );
                                  //       },
                                  //     );
                                  //   }else if(response.statusCode == 400 || response.statusCode == 404){
                                  //     Navigator.pop(context);
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (BuildContext context) => const FourNotFourPopup(),
                                  //     );
                                  //   }
                                  //   else {
                                  //     Navigator.pop(context);
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (BuildContext context) => FailedPopup(text: response.message),
                                  //     );
                                  //   }
                                  //   provider.typeController.clear();
                                  //   provider.shorthandController.clear();
                                  // },


                                  onAddPressed: (String colorHex, int masterTypeId,
                                      int roleId,List<int> childEmpTypeId,int templateIdSalaried,
                                      int templateIdParttime,
                                      int templateIdPerdiem) async {
                                    final response = await addEmployeeTypePost(
                                      context,
                                      provider.deptId,
                                      provider.typeController.text,
                                      colorHex,
                                      provider.shorthandController.text,
                                      masterTypeId,
                                      roleId,
                                        childEmpTypeId,
                                        templateIdSalaried,
                                        templateIdParttime,
                                        templateIdPerdiem
                                    );

                                    getAllHrDeptWise(context, provider.deptId).then((data) {
                                      provider._controller.add(data);
                                    }).catchError((_) {});

                                    if (response.statusCode == 200 || response.statusCode == 201) {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AddSuccessPopup(message: 'Added Successfully'),
                                      );
                                    } else if (response.statusCode == 400 || response.statusCode == 404) {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => const FourNotFourPopup(),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => FailedPopup(text: response.message),
                                      );
                                    }

                                    provider.typeController.clear();
                                    provider.shorthandController.clear();
                                  },

                                  onColorChanged: (Color selectedColor) {
                                    provider.handleColorChange(1, selectedColor);
                                    print('Selected color: $selectedColor');
                                    print('Color to Hex: ${provider.color}');
                                  },
                                  // onColorChanged: (Color seletedColor) {
                                  //  setState(() {
                                  //     print('Selected color :: ${seletedColor}');
                                  //     provider.containerColors[1] = seletedColor;
                                  //     provider.color = provider.colorToHex(seletedColor,);
                                  //     provider.saveColor(1, seletedColor);
                                  //     print('Color to Hex :: ${provider.color}');
                                  //   });
                                  // },
                                  title: AppStringEM.addEmp,
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
                Expanded(
                  flex: 10,
                  child: PageView(
                    controller: provider._hrPageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ChangeNotifierProvider(
                          create: (_) => HRTabScreenProvider(),
                          child: HRTabScreens(deptId: FrontendConfigStore.data!.config.clinicalId)),
                          // child: HRTabScreens(deptId: AppConfig.clinicalId)),
                      ChangeNotifierProvider(
                          create: (_) => HRTabScreenProvider(),
                          child: HRSalesAdminTabScreens(deptId: FrontendConfigStore.data!.config.salesId)),
                          // child: HRTabScreens(deptId: AppConfig.salesId)),
                      ChangeNotifierProvider(
                          create: (_) => HRTabScreenProvider(),
                          child: HRSalesAdminTabScreens(deptId: FrontendConfigStore.data!.config.administrationId)),
                          // child: HRTabScreens(deptId: AppConfig.AdministrationId)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

///hr tab stl
class HRTabScreenProvider with ChangeNotifier {
  TextEditingController typeController = TextEditingController();
  TextEditingController shorthandController = TextEditingController();

  final StreamController<List<HRAllData>> hrAllcontroller = StreamController<List<HRAllData>>();
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  List<Color> hrContainerColors = List.generate(20, (index) => Color(0xffE8A87D));

  ColorProvider() {
    _loadColors();
  }

  Future<void> _loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < hrContainerColors.length; i++) {
      int? colorValue = prefs.getInt('containerColor$i');
      if (colorValue != null) {
        hrContainerColors[i] = Color(colorValue);
      }
    }
    notifyListeners(); // Notify listeners after colors are loaded
  }

  Future<void> _saveColor(int index, Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('containerColor$index', color.value);
    hrContainerColors[index] = color; // Update in the list as well
    notifyListeners(); // Notify listeners after saving the color
  }
  void onColorChanged(int index, Color selectedColor) {
    hrContainerColors[index] = selectedColor;
    _saveColor(index, selectedColor);
    notifyListeners(); // Notify listeners after the color is updated
  }
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;
  String color = " ";
  void onPageNumberPressed(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }
  void updatePageNumber(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }
  int flexVal = 2;
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}



///tabbar api

// FutureBuilder<List<HRHeadBar>>(
//   future: companyHRHeadApi(context, provider.deptId),
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       return Material(
//         elevation: 4,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           height: AppSize.s30,
//           width: MediaQuery.of(context).size.width / 2.8,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: ColorManager.blueprime,
//             boxShadow: [
//               BoxShadow(
//                 color: ColorManager.black.withValues(alpha: 0.25),
//                 spreadRadius: 0,
//                 blurRadius: 4,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 InkWell(
//                     splashColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     hoverColor: Colors.transparent,
//                     child: Container(
//                       height: AppSize.s30,
//                       width: MediaQuery.of(context).size.width / 8.421,
//                       padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: provider.selectedIndex == 0
//                             ? ColorManager.white
//                             : Colors.transparent,
//                       ),
//                       child: Text(
//                         AppStringEM.clinical,
//                         textAlign: TextAlign.center,
//                         style: BlueBgTabbar.customTextStyle(0, provider.selectedIndex),
//                       ),
//                     ),
//                     onTap: () {
//                       provider.selectButton(0);
//                       // metaDocID = snapshot.data![index].employeeDocMetaDataId;
//                     }),
//                 InkWell(
//                     child: Container(
//                       height: AppSize.s30,
//                       width: MediaQuery.of(context).size.width / 8.421,
//                       padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: provider.selectedIndex == 1
//                             ? ColorManager.white
//                             : Colors.transparent,
//                       ),
//                       child: Text(
//                         AppStringEM.sales,
//                         textAlign: TextAlign.center,
//                         style: BlueBgTabbar.customTextStyle(1, provider.selectedIndex),
//                       ),
//                     ),
//                     onTap: () {
//                       provider.selectButton(1);
//                       // metaDocID = snapshot.data![index].employeeDocMetaDataId;
//                     }),
//                 InkWell(
//                     splashColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     hoverColor: Colors.transparent,
//                     child: Container(
//                       height: AppSize.s30,
//                       width:
//                       MediaQuery.of(context).size.width / 8.421,
//                       padding:
//                       const EdgeInsets.symmetric(vertical: AppPadding.p6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: provider.selectedIndex == 2
//                             ? ColorManager.white
//                             : Colors.transparent,
//                       ),
//                       child: Text(
//                         AppStringEM.administration,
//                         textAlign: TextAlign.center,
//                         style: BlueBgTabbar.customTextStyle(2, provider.selectedIndex),
//                       ),
//                     ),
//                     onTap: () {
//                       provider.selectButton(2);
//                       // metaDocID = snapshot.data![index].employeeDocMetaDataId;
//                     }),
//               ]),
//         ),
//       );
//     } else {
//       return SizedBox(height: 1, width: 1,);
//     }
//   },
// ),