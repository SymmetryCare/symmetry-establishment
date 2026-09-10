import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/common_resources/em_dashboard_theme.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/widgets/general_setting_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/em_dashboard_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

class GeneralSettingScreen extends StatefulWidget {
  const GeneralSettingScreen({super.key});

  @override
  State<GeneralSettingScreen> createState() => _GeneralSettingScreenState();
}

class _GeneralSettingScreenState extends State<GeneralSettingScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const double minContentWidth = 1200;
      final double contentWidth = constraints.maxWidth > minContentWidth
          ? constraints.maxWidth
          : minContentWidth;
      return CustomScrollbar(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p25),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                flex: 4,
                child: Column(children: [
                  ///white first container
                 const GeneralSettingConst(),
                  const SizedBox(height: AppSize.s20,),
                  ///border blue big container row 2
                  EMDashboardAllBlueSideContainer(
                      height: AppSize.s100,
                      child: Row(
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
                                  child: Icon(Icons.lock_clock,color: ColorManager.white,size: IconSize.I24,)
                              ),
                            ),
                            const SizedBox(width: AppSize.s20,),
                            Text( EmDashboardStringManager.userPassExp ,
                              style: EmDashText.customTextStyle(context),),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(EmDashboardStringManager.expDays,
                              style: CustomTextStylesCommon.commonStyle(
                                fontSize: FontSize.s12, color: ColorManager.mediumgrey,fontWeight: FontWeight.w400
                              ),),
                          ],
                        ),
                      ],)),
                  const SizedBox(height: AppPadding.p20,),
                  const Row(children: [
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath :"images/em_dashboard/system_update.png",
                            padding: 0,
                            headText: EmDashboardStringManager.systemUpdate, numberText: '', bottomText: '',)),
                    ),
                    SizedBox(width: AppSize.s30,),
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imageTile: Icons.error_outline,
                            padding: 0,
                            headText: EmDashboardStringManager.systemError, numberText: '12', bottomText: 'Last 24 hours',)),
                    ),
                  ],),
                  const SizedBox(height: AppSize.s10,),
                  const Row(children: [
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath: "images/em_dashboard/data_deletion.png",
                            padding: 0,
                            headText: EmDashboardStringManager.NoDataDelet, numberText: '12', bottomText: '',) ),
                    ),
                    SizedBox(width: AppSize.s30,),
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath: "images/em_dashboard/login_white.png",
                            padding: 0,
                            headText: EmDashboardStringManager.failedLoginAttempt, numberText: '  02', bottomText: 'Last 24 hours',)),
                    ),
                  ],),
                  const SizedBox(height: AppSize.s10,),
                  const Row(children: [
                    Expanded(
                        child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath: "images/em_dashboard/security_protocol.png",
                            padding: 0,
                            headText: EmDashboardStringManager.ActiveUsersSecurity, numberText: '12  ', bottomText: '',),)
                    ),
                    SizedBox(width: AppSize.s30,),
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imageTile: Icons.personal_injury_outlined,
                            padding: 0,
                            headText: EmDashboardStringManager.ActiveUsers, numberText: '26', bottomText: '',),)
                    ),
                  ],),
                  const SizedBox(height: AppSize.s10,),
                  const Row(children: [
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath: "images/em_dashboard/authenticate.png",
                            headText: EmDashboardStringManager.multiAuthenticate,
                            padding: 45,
                            numberText: '12', bottomText: '',)),
                    ),
                    SizedBox(width: AppSize.s30,),
                    Expanded(
                      child: EMDashboardAllBlueSideContainer(
                          height: AppSize.s100,
                          child: BlueBorderContainerConst(imagePath: "images/em_dashboard/system_update.png",
                            padding: 0,
                            headText: EmDashboardStringManager.lastSoftUpdate, numberText: '', bottomText: 'Last updated on 14/11/2024',)),
                    ),
                  ],),
                ],),
              ),
              const SizedBox(width: AppSize.s60,),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    UserRoleDistribution(),
                    const SizedBox(height: AppSize.s20,),
                    Container(
                      height: AppSize.s550,
                      padding: const EdgeInsets.all(AppPadding.p10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.black.withOpacity(0.2),
                            blurRadius: 6.3,
                            spreadRadius: 0,
                            offset: const Offset(0, 14), // Downward shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSize.s10,),
                          Text(EmDashboardStringManager.encryptionKey,
                          style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s22,
                              color:ColorManager.mediumgrey,fontWeight: FontWeight.w600),),
                          Stack(
                            alignment: Alignment.center,
                            children:[
                              Container(
                              //width: 450,
                              height: AppSize.s450,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '01\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Generation', // Remaining text
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius if needed
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '02\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Distribution',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '03\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Use',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '04\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Storage',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '05\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Rotation',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '06\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Backup /\nRecovery',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                    PieChartSectionData(
                                      color: ColorManager.blueKeyGraph,
                                      value: 30,
                                      title: "",
                                      badgeWidget: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '07\n',
                                              style: GeneralSettingNumStyle.customTextStyle(context),
                                            ),
                                            TextSpan(
                                              text: 'Revocation',
                                              style: GeneralSettingTextStyle.customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      radius: 100, // Adjust the radius as required
                                    ),
                                  ],
                                  centerSpaceRadius: 100,
                                  centerSpaceColor: Colors.white,
                                  sectionsSpace: 5,
                                  borderData: FlBorderData(show: true),
                                  startDegreeOffset: -90,
                                ),
                              ),
                            ),
                              Positioned(
                                  child: Container(
                                    width: AppSize.s80,
                                    height: AppSize.s80,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage('images/em_dashboard/dashboard_key.png'), // Replace with your image path
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),),
                            ]
                          ),
                        ],
                      ),),
                  ],
                ),
              ),
            ],),
            const SizedBox(height: AppSize.s30,),
        ],),
      ),            // Padding(horizontal)
    ),              // SingleChildScrollView(vertical)
            ),      // SizedBox
          ),        // Padding(bottom)
        ),          // SingleChildScrollView(horizontal)
      );            // CustomScrollbar
    });             // LayoutBuilder
  }
}
