import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/em_dashboard_theme.dart';
import 'package:prohealth/app/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/theme_manager.dart';
import '../../em_dashboard_const.dart';
///row1 col 1
class GeneralSettingConst extends StatelessWidget {
  const GeneralSettingConst({super.key});

  @override
  Widget build(BuildContext context) {
    return  EMDashboardContainerConst(
        height: AppSize.s150,
        child: Padding(
          padding: const EdgeInsets.only(left: AppPadding.p30),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EmDashboardStringManager.hello,
                      style: EmDashHelloText.customTextStyle(context)),
                    Text(EmDashboardStringManager.empowerprivacy,
                      style: EmDashHelloSubText.customTextStyle(context),),
                  ],),
                SizedBox(width: AppSize.s20,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Image.asset("images/em_dashboard/em_general_pic.png",fit: BoxFit.contain,)),
                  ],
                )
              ]),
        ));
  }
}

///row 1 col 2
class UserRoleDistribution extends StatefulWidget {
   UserRoleDistribution({super.key});

  @override
  State<UserRoleDistribution> createState() => _UserRoleDistributionState();
}

class _UserRoleDistributionState extends State<UserRoleDistribution> {
  int _selectedIndex = 0;

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }
  @override
  Widget build(BuildContext context) {
    return EMDashboardAllBlueSideContainer(
        height: AppSize.s150,
        child: Padding(
          padding: const EdgeInsets.only(left: AppPadding.p25,top: AppPadding.p10,right: AppPadding.p8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                            width: AppSize.s50,
                            height: AppSize.s50,
                            color: ColorManager.bluebottom,
                            child: Icon(Icons.personal_injury_outlined, color: ColorManager.white, size: IconSize.I24,)
                          // Image.asset(
                          //   imageTile, // Replace with your image path
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      ),
                      SizedBox(width: AppSize.s30,),
                      Text(EmDashboardStringManager.userRole,
                        style: EmDashText.customTextStyle(context),),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: AppPadding.p25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                ColorManager.mediumgrey,
                                ColorManager.bluebottom
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          // Ensures the gradient applies only to the text
                          child: Text(
                            "08",
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],),
              Padding(
                padding: const EdgeInsets.only(left: AppPadding.p70,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BlueBgTabButton(
                      index: 0,
                      selectedIndex: _selectedIndex,
                      text: EmDashboardStringManager.admin,
                      onTap: (int index) {
                        _selectButton(index);
                      },
                    ),
                    BlueBgTabButton(
                      index: 1,
                      selectedIndex: _selectedIndex,
                      text: AppStringEM.sales,
                      onTap: (int index) {
                        _selectButton(index);
                      },
                    ),
                    BlueBgTabButton(
                      index: 2,
                      selectedIndex: _selectedIndex,
                      text: EmDashboardStringManager.clinician,
                      onTap: (int index) {
                        _selectButton(index);
                      },
                    ),
                    BlueBgTabButton(
                      index: 3,
                      selectedIndex: _selectedIndex,
                      text: EmDashboardStringManager.patients,
                      onTap: (int index) {
                        _selectButton(index);
                      },
                    ),
                    BlueBgTabButton(
                      index: 4,
                      selectedIndex: _selectedIndex,
                      text: EmDashboardStringManager.physician,
                      onTap: (int index) {
                        _selectButton(index);
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ));
  }
}

typedef OnTabTapCallback = void Function(int index);

class BlueBgTabButton extends StatelessWidget {
  const BlueBgTabButton({
    Key? key,
    required this.index,
    required this.selectedIndex,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final int selectedIndex;
  final String text;
  final OnTabTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8), // Optional spacing
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p6, horizontal: AppPadding.p12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selectedIndex == index
                ? ColorManager.blueKeyGraph
                : Colors.transparent,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: selectedIndex == index
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selectedIndex == index
                  ? ColorManager.white
                  : ColorManager.mediumgrey,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
