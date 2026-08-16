
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/const_string.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/role_manager_administration.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/role_manager_clinician.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/role_manager_sales.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/rolemanager_role_rules.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/theme_manager.dart';
import '../../../../company_identity_screen.dart';

class RoleManagerRoles extends StatefulWidget {
  const RoleManagerRoles({super.key});

  @override
  State<RoleManagerRoles> createState() => _RoleManagerRolesState();
}

class _RoleManagerRolesState extends State<RoleManagerRoles> {
  final PageController _tabPageController = PageController();

  int _selectedIndex = 0;
  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 410,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () => _selectButton(0),
                    child: Column(
                      children: [
                        Text(
                          AppString.clinician,
                          style:  CustomTextStylesCommon.commonStyle(
                            fontSize: 12,
                            fontWeight: _selectedIndex == 0?
                            FontWeight.w700
                                :FontWeight.w600,
                            color: _selectedIndex == 0
                                ? ColorManager.blueprime
                                : ColorManager.mediumgrey,
                          ),
                        ),
                        SizedBox(height: 2,),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 14,
                          color: _selectedIndex == 0 ?  ColorManager.blueprime : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectButton(1),
                    child: Column(
                      children: [
                        Text(
                         AppString.sales,
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: 12,
                            fontWeight: _selectedIndex == 1?
                            FontWeight.w700
                                :FontWeight.w600,
                            color: _selectedIndex == 1
                                ? ColorManager.blueprime
                                : ColorManager.mediumgrey,
                          ),
                        ),
                        SizedBox(height: 2,),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 13,
                          color: _selectedIndex == 1 ?  ColorManager.blueprime : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectButton(2),
                    child: Column(
                      children: [
                        Text(
                          AppString.administration,
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: 12,
                            fontWeight: _selectedIndex == 2?
                            FontWeight.w700
                                :FontWeight.w600,
                            color: _selectedIndex == 2
                                ? ColorManager.blueprime
                                : ColorManager.mediumgrey,
                          ),
                        ),
                        SizedBox(height: 2,),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 13,
                          color: _selectedIndex == 2 ? ColorManager.blueprime: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Expanded(
          flex: 12,
          child: NonScrollablePageView(
            controller: _tabPageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              RoleManagerClinician(),
              RoleManagerSales(),
              RoleManagerAdministration(),
            ],
          ),
        ),

      ],
    );
  }
}
