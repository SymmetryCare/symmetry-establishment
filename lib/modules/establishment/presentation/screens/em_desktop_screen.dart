import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/em_main_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/company_identity.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/manage_emp_doc.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/manage_work_schedule.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/see_all_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/see_all_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/dashboard_main_button_screen.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/const_appbar/controller.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/ci_role_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/ci_visit.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/hr_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_pay_rates/finance_screen.dart';

// ✅ UPDATED: Changed from StatelessWidget to StatefulWidget
class EMDesktopScreen extends StatefulWidget {
  final String? dropdownValue;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onItem2Selected;

  const EMDesktopScreen({
    this.dropdownValue,
    this.onChanged,
    this.onItem2Selected,
  });

  @override
  State<EMDesktopScreen> createState() => _EMDesktopScreenState();
}

class _EMDesktopScreenState extends State<EMDesktopScreen> {
  // ✅ UPDATED: moved all fields into State
  final PageController _pageController = PageController();
  final EMController smController = Get.put(EMController());
  final HRController hrController = Get.put(HRController());
  final ButtonSelectionController myController = Get.put(ButtonSelectionController());
  bool showSelectOption = true;
  int pgeControllerId = 0;

  @override
  void initState() {
    super.initState();
    // ✅ NEW: Reset dropdown and page to Dashboard every time this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerEmState = Provider.of<EmMainProvider>(context, listen: false);
      providerEmState.selectModuleScreen(0);
      providerEmState.selectModuleNameScreen(EmDashboardStringManager.selectModule);
      myController.selectButton(0);
      _pageController.jumpToPage(0);
      pgeControllerId = 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // ✅ NEW: properly dispose controller
    super.dispose();
  }

  void navigateToPage(BuildContext context, String routeName) {
    Provider.of<RouteProvider>(context, listen: false).setRoute(routeName);
    switch (routeName) {
      case RouteStrings.emCompanyIdentity:
        _pageController.animateToPage(1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
        break;
      default:
        break;
    }
  }

  Future<bool> _onWillPop() async {
    final providerEmState = Provider.of<EmMainProvider>(context, listen: false);
    if (pgeControllerId == 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else if (pgeControllerId == 1) {
      myController.selectButton(0);
      _pageController.animateToPage(0,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      providerEmState.selectModuleNameScreen(EmDashboardStringManager.selectModule);
      return false;
    } else if (pgeControllerId == 6) {
      myController.selectButton(1);
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      providerEmState.selectModuleNameScreen(EmDashboardStringManager.selectModule);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmMainProvider>(
      builder: (context, providerEmState, child) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              Column(
                children: [
                  ApplicationEmrAppBar(
                    isHrModule: true,
                    headingText: EmDashboardStringManager.em,
                    body: [
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: AppPadding.p30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                    () => CustomTitleButton(
                                  height: AppSize.s30,
                                  width: AppSize.s100,
                                  onPressed: () {
                                    myController.selectButton(0);
                                    _pageController.animateToPage(0,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                    providerEmState.selectModuleScreen(0);
                                    providerEmState.selectModuleNameScreen(
                                        EmDashboardStringManager.selectModule);
                                    pgeControllerId = 0;
                                  },
                                  text: EmDashboardStringManager.dashboard,
                                  isSelected: myController.selectedIndex.value == 0,
                                ),
                              ),
                              Obx(
                                    () => CustomTitleButton(
                                  height: AppSize.s30,
                                  width: AppSize.s140,
                                  onPressed: () {
                                    companyByIdApi(context);
                                    myController.selectButton(1);
                                    _pageController.animateToPage(1,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                    providerEmState.selectModuleScreen(1);
                                    providerEmState.selectModuleNameScreen(
                                        EmDashboardStringManager.selectModule);
                                    pgeControllerId = 1;
                                  },
                                  text: EmDashboardStringManager.companyIdentity,
                                  isSelected: myController.selectedIndex.value == 1,
                                ),
                              ),
                              Material(
                                elevation: 4,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                child: CustomDropdownButton(
                                  height: AppSize.s30,
                                  width: AppSize.s170,
                                  initialItem: providerEmState.pageNmaeValue,
                                  items: [
                                    DropdownItem(title: "User Management", isHeading: true),
                                    DropdownItem(title: "Users", index: 2),
                                    DropdownItem(title: "Clinical", isHeading: true),
                                    DropdownItem(title: "Visits", index: 3),
                                    DropdownItem(title: "HR", isHeading: true),
                                    DropdownItem(title: "Designation Settings", index: 4),
                                    DropdownItem(title: "Work Schedule", index: 5),
                                    DropdownItem(title: "Employee Documents", index: 6),
                                    DropdownItem(title: "Finance", isHeading: true),
                                    DropdownItem(title: "Pay Rate", index: 7),
                                    DropdownItem(title: "Org Document", isHeading: true),
                                    DropdownItem(title: "Document Definition", index: 8),
                                  ],
                                  onItemSelected: (selectedValue, pageIndex) {
                                    myController.selectButton(pageIndex);
                                    _pageController.animateToPage(
                                      pageIndex,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                    providerEmState.selectModuleScreen(pageIndex);
                                    providerEmState.selectModuleNameScreen(selectedValue);
                                    print('Page index $pageIndex');
                                    print('Page Value $selectedValue');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      AppBarIcon(
                          icon: Icons.call_outlined,
                          onPressed: () => debugPrint('Call tapped')),
                      const SizedBox(width: 8),
                      AppBarIcon(
                          icon: Icons.notifications_none_outlined,
                          onPressed: () => debugPrint('Notification tapped')),
                      const SizedBox(width: 16),
                    ],
                  ),
                  Expanded(
                    flex: 8,
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        DashboardMainButtonScreen(),
                        CompanyIdentity(),
                        ChangeNotifierProvider(
                          create: (_) => SeeAllProvider(),
                          child: SeeAllScreen(),
                        ),
                        CiVisitScreen(),
                        ChangeNotifierProvider(
                            create: (_) => HrScreenProvider(),
                            child: HrScreen()),
                        ChangeNotifierProvider(
                            create: (_) => WorkScheduleProvider(),
                            child: WorkSchedule()),
                        ChangeNotifierProvider(
                            create: (_) => ManageEmployDocumentProvider(),
                            child: ManageEmployDocument()),
                        ChangeNotifierProvider(
                            create: (_) => FinanceProvider(),
                            child: FinanceScreen()),
                        CiOrgDocument(),
                      ],
                    ),
                  ),
                  BottomBarRow()
                ],
              ),
            ]),
          ),
        );
      },
    );
  }
}

class EMController extends GetxController {
  var selectedItem = 'Admin'.obs;
  void changeSelectedItem(String newItem) {
    selectedItem.value = newItem;
  }
}

class ButtonSelectionController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void selectButton(int index) {
    selectedIndex.value = index;
  }
}

class CustomDropdownButton extends StatefulWidget {
  final double height;
  final double width;
  final List<DropdownItem> items;
  final void Function(String, int)? onItemSelected;
  String initialItem;

  CustomDropdownButton({
    required this.height,
    required this.width,
    required this.items,
    required this.initialItem,
    this.onItemSelected,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  late String _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
  }

  // ✅ UPDATED: sync internal state when parent resets initialItem
  @override
  void didUpdateWidget(covariant CustomDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItem != oldWidget.initialItem) {
      setState(() {
        _selectedItem = widget.initialItem;
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double buttonHeight = renderBox.size.height;
    final double buttonWidth = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _removeDropdown,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            width: buttonWidth,
            left: offset.dx,
            top: offset.dy + buttonHeight,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, buttonHeight),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.items.map((item) {
                        return InkWell(
                          onTap: () {
                            if (!item.isHeading) {
                              setState(() {
                                _selectedItem = item.title;
                              });
                              int itemIndex = widget.items
                                  .where((element) => !element.isHeading)
                                  .toList()
                                  .indexOf(item) +
                                  2;
                              widget.onItemSelected?.call(item.title, itemIndex);
                              _removeDropdown();
                            }
                          },
                          child: Container(
                            padding: item.isHeading
                                ? EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                                : EdgeInsets.only(top: 8, bottom: 8, left: 30),
                            width: double.infinity,
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: FontSize.s14,
                                fontWeight: item.isHeading
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: item.isHeading
                                    ? ColorManager.black
                                    : ColorManager.textPrimaryColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: widget.height + 5,
          decoration: widget.initialItem != EmDashboardStringManager.selectModule
              ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff51B5E6),
                  Color(0xff008ABD),
                ],
              ))
              : const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialItem,
                style: TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                    color: widget.initialItem == EmDashboardStringManager.selectModule
                        ? ColorManager.textPrimaryColor
                        : Colors.white),
              ),
              Icon(Icons.arrow_drop_down,
                  color: widget.initialItem == EmDashboardStringManager.selectModule
                      ? ColorManager.textPrimaryColor
                      : Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownItem {
  final String title;
  final bool isHeading;
  final int? index;

  DropdownItem({required this.title, this.isHeading = false, this.index});
}
/// A round, low-emphasis icon button in the Establishment header (call,
/// notifications).
///
/// Reconstructed from its two call sites above — the original lived in the
/// `prohealth` monolith's shared app bar and did not come across with the
/// extracted screens. Sized and coloured to sit quietly beside the module
/// title rather than compete with the primary actions.
class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIcon({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: IconSize.I22, color: IconColorManager.bluebottom),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }
}
