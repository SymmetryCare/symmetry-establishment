import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/screen_route_name.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/company_identity.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/upper_menu_buttons.dart';

class CompanyIdentityScreen extends StatefulWidget {
  static const String routeName = RouteStrings.emCompanyIdentity;
  final VoidCallback? onWhitelabellingPressed;
   final String? officeId;
  final int? companyId;
  const CompanyIdentityScreen({super.key, this.onWhitelabellingPressed,
    this.officeId, this.companyId});
  @override
  State<CompanyIdentityScreen> createState() => _CompanyIdentityScreenState();
}

class _CompanyIdentityScreenState extends State<CompanyIdentityScreen> {
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
          /// visit , org , Document tab bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppPadding.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UpperMenuButtons(
                    onTap: (int index) {
                      _selectButton(index);
                    },
                    index: 0,
                    grpIndex: _selectedIndex,
                    heading: "Company Identity"),
                SizedBox(width: 10,),
                UpperMenuButtons(
                    onTap: (int index) {
                      _selectButton(index);
                    },
                    index: 1,
                    grpIndex: _selectedIndex,
                    heading: "Document Definitions"),
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
                CompanyIdentity(),
                CiOrgDocument()
              ],
            ),
          ),
        ]));
  }
}
///

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
