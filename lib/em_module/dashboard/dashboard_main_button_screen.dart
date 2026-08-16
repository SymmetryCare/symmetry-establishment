///dashboard use
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:prohealth/app/resources/screen_route_name.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/em_dashboard_const.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/contract_doc_auditing_screen.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/general_setting_screen.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/office_clinician_screen.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/office_location_screen.dart';
import '../../../../app/resources/value_manager.dart';

class DashboardMainButtonScreen extends StatefulWidget {
  static const String routeName = RouteStrings.emMainDashboard;
  const DashboardMainButtonScreen({super.key});

  @override
  State<DashboardMainButtonScreen> createState() => _DashboardMainButtonScreenState();
}

class _DashboardMainButtonScreenState extends State<DashboardMainButtonScreen> {

  final PageController _tabPageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
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
                      _selectButton(index);
                    },
                    index: 0,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.generalSetting),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _selectButton(index);
                    },
                    index: 1,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.OfficeLocation),
                SizedBox(width: AppSize.s10,),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _selectButton(index);
                    },
                    index: 2,
                    grpIndex: _selectedIndex,
                    heading: EmDashboardStringManager.OfficeClinician),
                EMDashboardMenuButtons(
                    onTap: (int index) {
                      _selectButton(index);
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

