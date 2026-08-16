import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/role_manager_clinician.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_tab_widget/widget/ci_role_manager_tab/rolemanager_role_rules.dart';
import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../company_identity_screen.dart';

class CiRoleManager extends StatefulWidget {
  const CiRoleManager({super.key});
  @override
  State<CiRoleManager> createState() => _CiRoleManagerState();
}

class _CiRoleManagerState extends State<CiRoleManager> {
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
          height: AppSize.s10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSize.s280,
              height: AppSize.s30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: ColorManager.blueprime,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => _selectButton(0),
                    child: Container(
                      height: AppSize.s30,
                      width: AppSize.s150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: _selectedIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          AppStringEM.role,
                          style:  BlueBgTabbar.customTextStyle(0, _selectedIndex),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => _selectButton(1),
                    child: Container(
                      height: AppSize.s30,
                      width: AppSize.s130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: _selectedIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          AppStringEM.roleRules,
                          style:  BlueBgTabbar.customTextStyle(1, _selectedIndex),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
        SizedBox(height: AppSize.s30,),
        Expanded(
          flex: 12,
          child: Opacity(
            opacity: 0.3,
            child: Stack(
              children: [
             _selectedIndex != 0 ?Offstage():
             Container(
               height: MediaQuery.of(context).size.height/3.5,
                  decoration: BoxDecoration(color: Color(0xFFF2F9FC),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                      boxShadow: [ BoxShadow(
                        color: ColorManager.faintGrey,
                        blurRadius: 2,
                        spreadRadius: -2,
                        offset: Offset(0, -4),
                      ),]
                  ),),
                NonScrollablePageView(
                controller: _tabPageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  // Page 1
                  //RoleManagerRoles(),
                  RoleManagerClinician(),
                  RoleManagerRoleRules()
                ],
              ),]
            ),
          ),
        ),
      ],
    );
  }
}
