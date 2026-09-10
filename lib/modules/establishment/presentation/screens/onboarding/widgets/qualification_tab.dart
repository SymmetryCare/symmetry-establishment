import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/widgets/banking_tab_constant.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/upper_menu_buttons.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/controller/controller.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/onboarding_qualification.dart';

/// to do saloni
class OnboardingQualification extends StatefulWidget {
  late QualificationTabBarController controller;
  final int employeeId;
  final int departmentId;
  OnboardingQualification({required this.employeeId, required this.departmentId});
  @override
  State<OnboardingQualification> createState() =>
      _OnboardingQualificationState();
}

class _OnboardingQualificationState extends State<OnboardingQualification> {
  final PageController _tabPageController = PageController();

  int _selectedIndex = 0;
  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabPageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.white,
        body: Column(children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UpperMenuButtons(
                        onTap: (int index) {
                          _selectButton(index);
                        },
                        index: 0,
                        grpIndex: _selectedIndex,
                        heading: "Employment"),
                    UpperMenuButtons(
                        onTap: (int index) {
                          _selectButton(index);
                        },
                        index: 1,
                        grpIndex: _selectedIndex,
                        heading: "Education"),
                    UpperMenuButtons(
                        onTap: (int index) {
                          _selectButton(index);
                        },
                        index: 2,
                        grpIndex: _selectedIndex,
                        heading: "Reference"),
                    UpperMenuButtons(
                        onTap: (int index) {
                          _selectButton(index);
                        },
                        index: 3,
                        grpIndex: _selectedIndex,
                        heading: "License"),

                   widget.departmentId == 1 ? UpperMenuButtons(
                        onTap: (int index) {
                          _selectButton(index);
                        },
                        index: 4,
                        grpIndex: _selectedIndex,
                        heading: "Clinical Licenses"):const Offstage(),
                  ],
                ),
                          ],
                        ),
                      ),
          Expanded(
            flex: 1,
            child: PageView(
              controller: _tabPageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children:  [
                OnBoardingQualificationEmployment(employeeId: widget.employeeId,),
                              OnBoardingQualificationEducation(employeeId: widget.employeeId,),
                              OnBoardingQualificationReference(employeeId: widget.employeeId,),
                              OnBoardingQualificationLicense(employeeId: widget.employeeId,),
               widget.departmentId == 1? OnBoardingQualificationGeneralLicenses(employeeId:widget.employeeId):const Offstage()
              ],
            ),
          ),

        ]));
  }
}
