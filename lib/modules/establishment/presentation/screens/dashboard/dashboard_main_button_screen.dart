///dashboard use
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/em_dashboard_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/contract_doc_auditing_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/general_setting_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/office_clinician_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/office_location_screen.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class DashboardMainButtonScreen extends StatefulWidget {
  static const String routeName = RouteStrings.emMainDashboard;
  const DashboardMainButtonScreen({
    super.key,
    this.initialTab = 0,
    this.onTabChanged,
  });

  /// The tab the URL names (General Setting, Office Location, ...).
  final int initialTab;

  /// A tab was tapped; puts it in the URL.
  final ValueChanged<int>? onTabChanged;

  @override
  State<DashboardMainButtonScreen> createState() => _DashboardMainButtonScreenState();
}

class _DashboardMainButtonScreenState extends State<DashboardMainButtonScreen> {

  late final PageController _tabPageController =
      PageController(initialPage: widget.initialTab);
  late int _selectedIndex = widget.initialTab;

  /// The tab last asked for. [_selectedIndex] passes through the pages in
  /// between while the PageView animates, so it cannot tell whether a new
  /// URL tab is one we are already on our way to.
  late int _targetIndex = widget.initialTab;

  void _selectButton(int index) {
    _targetIndex = index;
    setState(() {
      _selectedIndex = index;
    });
    _tabPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _onTabTapped(int index) {
    _selectButton(index);
    widget.onTabChanged?.call(index);
  }

  /// The URL moved to another tab while this page stayed on screen (Back,
  /// Forward, or the Dashboard button from another tab's URL).
  @override
  void didUpdateWidget(covariant DashboardMainButtonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int tab = widget.initialTab;
    if (tab == _targetIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && tab != _targetIndex) _selectButton(tab);
    });
  }

  @override
  void dispose() {
    _tabPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          /// tab bar
          Container(
           // color: Colors.green,
            margin: const EdgeInsets.symmetric(vertical: AppPadding.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _onTabTapped(index);
                    },
                    index: 0,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.generalSetting),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _onTabTapped(index);
                    },
                    index: 1,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.OfficeLocation),
                SizedBox(width: AppSize.s10,),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _onTabTapped(index);
                    },
                    index: 2,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.OfficeClinician),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _onTabTapped(index);
                    },
                    index: 3,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.ContractDoc),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: NonScrollablePageView(
              controller: _tabPageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                  // documentTypeGet(context);
                });
              },
              children: [
                GeneralSettingScreen(),
                OfficeLocationScreen(),
                OfficeClinicianScreen(),
                ContractDocAuditingScreen(),

              ],
            ),
          ),
        ]));
  }
}


class NonScrollablePageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final List<Widget> children;
  const NonScrollablePageView({
    Key? key,
    required this.controller,
    required this.onPageChanged,
    required this.children,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) => true,
      child: PageView(
        controller: controller,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disables scrolling
        children: children,
      ),
    );
  }
}

