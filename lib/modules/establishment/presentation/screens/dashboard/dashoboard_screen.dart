import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/dashboard/hr_dashboard_graph_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/dashboard/hr_dashboard_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/dashboard/hr_dashboard_graph_model.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/dashboard/hr_dashboard_part_one_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/barChart_const_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/dataModel_barchart.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/hr_dashboard_const.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {

  final ScrollController _horizontalScrollController = ScrollController();

  /// Bar Column chart data output ratio
  final List<ComboChartData> CombochartData = <ComboChartData>[
    ComboChartData('Sat', 50, 30),
    ComboChartData('Sun', 40, 25),
    ComboChartData('Mon', 100, 80),
    ComboChartData('Tue', 80, 50),
    ComboChartData('Wed', 90, 75),
    ComboChartData('Thu', 80, 65),
    ComboChartData('Fri', 80, 40),
  ];
  String? emptype = 'Age Wise';

  // ── Cached future — shared by the two identical HrDashNewJoineeGet
  // FutureBuilders below, prevents refetch on every rebuild ──
  late Future<NewJoineeDash?> _newJoineeDashFuture;

  /// pie chart data
  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: ColorManager.pieChartGreen,
        value: 34,
        title: '34%',
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 45,
      ),
      PieChartSectionData(
        color: ColorManager.pieChartBBlue,
        value: 7,
        title: '7%',
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 40,
      ),
      PieChartSectionData(
        color: ColorManager.pieChartBlue,
        value: 60,
        title: '60%',
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 40,
      ),
    ];
  }

  /// Area chart
  final List<ChartAreaData> AreachartData = <ChartAreaData>[
    ChartAreaData(2010, 10.53, 3.3),
    ChartAreaData(2011, 9.5, 5.4),
    ChartAreaData(2012, 10, 2.65),
    ChartAreaData(2013, 9.4, 2.62),
    ChartAreaData(2014, 5.8, 1.99),
    ChartAreaData(2015, 4.9, 1.44),
    ChartAreaData(2016, 4.5, 2),
    ChartAreaData(2017, 3.6, 1.56),
    ChartAreaData(2018, 3.43, 2.1),

  ];

  @override
  void initState() {
    super.initState();
    _newJoineeDashFuture = HrDashNewJoineeGet(context);
  }
  String selectedValue = "Daily";

  final List<String> items = ["Daily", "Weekly", "Monthly"];

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return CustomScrollbar(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p10),
                  child: SizedBox(
                    width: contentWidth,
                    height: constraints.maxHeight,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p14),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: AppSize.s150,
                                  width: double.maxFinite,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE9F2F5), // Color(0xFFF2F9FC),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top:40, bottom: 30, left: 90, right: 90),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: FutureBuilder<NewJoineeDash?>(
                                            future: _newJoineeDashFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return HrDashboardContainerConst(
                                                  headText: "Total Employees",
                                                  headSubTextColor: ColorManager.skini,
                                                  subText: "0",
                                                  imageTile: 'images/hr_dashboard/total.png',
                                                );
                                              } else if (snapshot.hasError) {
                                                return HrDashboardContainerConst(
                                                  headText: "Total Employees",
                                                  headSubTextColor: ColorManager.skini,
                                                  subText: "Error",
                                                  imageTile: 'images/hr_dashboard/total.png',
                                                );
                                              } else if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                final newEmpCount =
                                                    snapshot.data!.totalEmployees ?? 0;
                                                return HrDashboardContainerConst(
                                                  headText: "Total Employees",
                                                  headSubTextColor: ColorManager.skini,
                                                  subText: newEmpCount.toString(),
                                                  imageTile: 'images/hr_dashboard/total.png',
                                                );
                                              } else {
                                                return HrDashboardContainerConst(
                                                  headText: "Total Employees",
                                                  headSubTextColor: ColorManager.skini,
                                                  subText: "0",
                                                  imageTile: 'images/hr_dashboard/total.png',
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                        Expanded(
                                          child: FutureBuilder<NewJoineeDash?>(
                                            future: _newJoineeDashFuture,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return HrDashboardContainerConst(
                                                  headText: "New Joining's",
                                                  headSubTextColor: ColorManager.blueDash,
                                                  subText: "0",
                                                  imageTile: 'images/hr_dashboard/joinies.png',
                                                );
                                              } else if (snapshot.hasError) {
                                                return HrDashboardContainerConst(
                                                  headText: "New Joining's",
                                                  headSubTextColor: ColorManager.blueDash,
                                                  subText: "Error",
                                                  imageTile: 'images/hr_dashboard/joinies.png',
                                                );
                                              } else if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                final newJoineesCount =
                                                    snapshot.data!.newJoineesCount ?? 0;
                                                return HrDashboardContainerConst(
                                                  headText: "New Joining's",
                                                  headSubTextColor: ColorManager.blueDash,
                                                  subText: newJoineesCount.toString(),
                                                  imageTile: 'images/hr_dashboard/joinies.png',
                                                );
                                              } else {
                                                return HrDashboardContainerConst(
                                                  headText: "New Joining's",
                                                  headSubTextColor: ColorManager.blueDash,
                                                  subText: "0",
                                                  imageTile: 'images/hr_dashboard/joinies.png',
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                        Expanded(
                                          child: HrDashboardContainerConst(
                                            headText: "Today's Attendance",
                                            headSubTextColor: ColorManager.pink,
                                            subText: "90%",
                                            imageTile: 'images/hr_dashboard/attendies.png',
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                        Expanded(
                                          child: HrDashboardContainerConst(
                                            headText: "Employees on Leave",
                                            headSubTextColor: ColorManager.purpleBlack,
                                            subText: "08",
                                            imageTile: 'images/hr_dashboard/emp_leave.png',
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            ///view text
                            Padding(
                              padding: const EdgeInsets.only(right: 25.0,bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        useSafeArea: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.8,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: AppPadding.p80,
                                                  right: AppPadding.p80,
                                                  bottom: AppPadding.p50),
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 20,),
                                                  Row( crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                          onTap: (){
                                                            Navigator.pop(context);
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.arrow_back,
                                                                size: IconSize.I16,
                                                                color: ColorManager.mediumgrey,

                                                              ),
                                                              const SizedBox(width: AppSize.s5,),
                                                              Text(
                                                                'Go Back',
                                                                style:TextStyle(
                                                                  fontSize: FontSize.s14,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: ColorManager.mediumgrey,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                      )
                                                    ],),
                                                  const SizedBox(height: 20,),
                                                  ///
                                                  Expanded(
                                                    child: ScrollConfiguration(
                                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                                      child: ListView.builder(
                                                        scrollDirection: Axis.vertical,
                                                        itemCount: 15,
                                                        itemBuilder: (context, index) {
                                                          return const Column(
                                                            children: [
                                                              SizedBox(height: AppSize.s5),
                                                              HRDashBottomSheetData(),
                                                              SizedBox(height: AppSize.s5),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "View Document Expired List",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: FontSize.s12,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.blueprime,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ///graph section
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p15,
                                  right: AppPadding.p15,
                                  bottom: AppPadding.p10),
                              child: Container(
                                height: 980,
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppPadding.p10, horizontal: 5),
                                child: Column(
                                  children: [
                                    ///row 1
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: HrDashboadGraphContainer(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Output Relative to Input",
                                                                textAlign: TextAlign.center,
                                                                style: GraphHeadingHRDashboard
                                                                    .customTextStyle(context),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(children: [
                                                            TextCircleConst(text: 'Work Hours', circleColor: ColorManager.emptenure,textColor: ColorManager.blackForLoginTexts,),
                                                            const SizedBox(width:5),
                                                            TextCircleConst(text: 'Result', circleColor: ColorManager.relativeResult, textColor: ColorManager.blackForLoginTexts,),
                                                          ],),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 125,
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: StatefulBuilder(
                                                                    builder: (BuildContext context,
                                                                        void Function(void Function()) setState) {
                                                                      return CustomDropdownTextFieldwidh(
                                                                        items: const ["Daily", "Weekly", "Monthly"],
                                                                        onChanged: (newValue) {
                                                                          setState(() {
                                                                            selectedValue =
                                                                            newValue!;
                                                                          });
                                                                        },

                                                                      );

                                                                    }
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 200,
                                                      child: SfCartesianChart(
                                                        backgroundColor: ColorManager.white,
                                                        primaryXAxis: CategoryAxis(
                                                          labelStyle: TextStyle(color: ColorManager.dashListviewData),
                                                        ),
                                                        primaryYAxis: NumericAxis(
                                                          minimum: 0,
                                                          maximum: 100,
                                                          interval: 10,
                                                          labelStyle: TextStyle(color: ColorManager.dashListviewData),
                                                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                                                            // Appends '%' symbol to the Y-axis labels
                                                            return ChartAxisLabel('${details.text}%', details.textStyle);
                                                          },
                                                        ),
                                                        series: <CartesianSeries>[
                                                          ColumnSeries<ComboChartData, String>(
                                                            color: ColorManager.emptenure,
                                                            dataSource: CombochartData,
                                                            xValueMapper: (ComboChartData data, _) => data.x,
                                                            yValueMapper: (ComboChartData data, _) => data.y,
                                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                            width: 0.5,
                                                            spacing: 0.5,
                                                          ),
                                                          ColumnSeries<ComboChartData, String>(
                                                            color: ColorManager.relativeResult,
                                                            dataSource: CombochartData,
                                                            xValueMapper: (ComboChartData data, _) => data.x,
                                                            yValueMapper: (ComboChartData data, _) => data.y1,
                                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                            width: 0.5,
                                                            spacing: 0.5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ))),
                                        const SizedBox(width: AppSize.s15,),
                                        ///diverity
                                        Expanded(
                                          flex: 3,
                                          child: HrDashboadGraphContainer(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Metrics on Ethnic Diversity',
                                                      textAlign: TextAlign.start,
                                                      style: GraphHeadingHRDashboard.customTextStyle(context),
                                                    ),
                                                    Container(
                                                      height: 200,
                                                      width: 200,
                                                      child: PieChart(
                                                        PieChartData(
                                                          sections: [
                                                            PieChartSectionData(
                                                              color: ColorManager.pieChartFYellow,
                                                              value: 40,
                                                              title: '',
                                                              radius: 40,
                                                            ),
                                                            PieChartSectionData(
                                                              color: ColorManager.pieChartpurple,
                                                              value: 20,
                                                              title: '',
                                                              radius: 40,
                                                            ),
                                                            PieChartSectionData(
                                                              color: ColorManager.pieChartFpurple,
                                                              value: 10,
                                                              title: '',
                                                              radius: 40,
                                                            ),
                                                            PieChartSectionData(
                                                              color: ColorManager.pieChartYellow,
                                                              value: 25,
                                                              title: '',
                                                              radius: 40,
                                                            ),
                                                          ],
                                                          centerSpaceRadius: 60,
                                                          centerSpaceColor: Colors.white,
                                                          sectionsSpace: 3,
                                                          borderData:
                                                          FlBorderData(show: false),
                                                          startDegreeOffset: -90,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 150,
                                                    width: 190,
                                                    padding: const EdgeInsets.only(left: 30),
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          TextCircleConst(text: 'American', circleColor: ColorManager.pieChartpurple),
                                                          TextCircleConst(text: 'African', circleColor: ColorManager.pieChartYellow),
                                                          TextCircleConst(text: 'Asian', circleColor: ColorManager.pieChartFpurple),
                                                          TextCircleConst(text: 'American African', circleColor: ColorManager.pieChartFYellow),

                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )

                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSize.s15,),
                                        Expanded(
                                          flex: 2,
                                          child: HrDashboadGraphContainer(
                                              child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 10.0, horizontal: 10),
                                                    child: Container(
                                                      height: 220,
                                                      child: ListView.builder(
                                                          itemCount: 5,
                                                          itemBuilder: (context, index) {
                                                            return Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                      'Offer Acceptance Rate',
                                                                      style: GraphHeadingHRDashboard.customTextStyle(context)),
                                                                  Text(
                                                                    '15%',
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                        color: ColorManager.dashListviewData,
                                                                        fontSize: FontSize.s12,
                                                                        fontWeight: FontWeight.w500),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  ))),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: AppSize.s25,),

                                    ///row 2
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: HrDashboadGraphContainer(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('Attendance & Punctuality Rates',style:
                                                  TableHeadHRDashboard.customTextStyle(
                                                      context),),
                                                  const Divider(),
                                                  Container(
                                                    height:AppSize.s190,
                                                    width: AppSize.s250,
                                                    child:SfRadialGauge(
                                                      axes: <RadialAxis>[
                                                        RadialAxis(
                                                          showLabels: false,
                                                          startAngle: 180, // Start from the bottom center
                                                          endAngle: 0,     // End at the bottom center
                                                          minimum: 0,      // Minimum value of the gauge
                                                          maximum: 100,    // Maximum value of the gauge
                                                          ranges: <GaugeRange>[

                                                            GaugeRange(startValue: 0, endValue: 80,
                                                              gradient: const SweepGradient(
                                                                colors: [
                                                                  Color(0xFFA158F7), // Start color: #2B98D5
                                                                  Color(0xFF2B98D5), // End color: faint grey
                                                                ],
                                                                stops: [0.2, 0.8],
                                                              ),
                                                              startWidth: 22,
                                                              endWidth: 20, ),
                                                            GaugeRange(startValue: 80, endValue: 100, color: const Color(0xFFEAEAEA),
                                                              startWidth: 20,
                                                              endWidth: 20, ),
                                                          ],
                                                          annotations: const <GaugeAnnotation>[
                                                            GaugeAnnotation(
                                                              widget: Text(
                                                                '84%',
                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                                              ),
                                                              angle: 90,
                                                              positionFactor: 0,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15,),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    HrDashboardSmallcontainer(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Audit Readiness\nScore',
                                                                textAlign: TextAlign.start,
                                                                style: CustomTextStylesCommon.commonStyle(
                                                                  fontSize: FontSize.s12,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: ColorManager.mediumgrey,),
                                                              ),
                                                              Text(
                                                                '92%',
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(color: ColorManager.blueBorderText,  fontWeight: FontWeight.w500,
                                                                    fontSize: AppSize.s30),
                                                              )
                                                            ],
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              height: 120,
                                                              alignment: Alignment.center,
                                                              child: Stack(
                                                                alignment: Alignment.center,
                                                                children: [
                                                                  ShaderMask(
                                                                    shaderCallback: (rect) {
                                                                      return const RadialGradient(
                                                                        colors: [
                                                                          Color(0xff59A9F4),
                                                                          Color(0xff34628E),
                                                                        ],
                                                                        center: Alignment.center,
                                                                        radius: 0.5,
                                                                      ).createShader(rect);
                                                                    },
                                                                    blendMode: BlendMode.srcATop,
                                                                    child: PieChart(
                                                                      PieChartData(
                                                                        sections: [
                                                                          PieChartSectionData(
                                                                            color:  ColorManager
                                                                                .faintGrey.withOpacity(0.11),
                                                                            value: 20,
                                                                            title: '',
                                                                            radius: 27,
                                                                          ),
                                                                          PieChartSectionData(
                                                                            color: Colors.white,
                                                                            value: 90,
                                                                            title: '',
                                                                            radius: 27,
                                                                          ),
                                                                        ],
                                                                        centerSpaceRadius: 10,
                                                                        centerSpaceColor: Colors.white,
                                                                        sectionsSpace: 0,
                                                                        borderData: FlBorderData(show: false),
                                                                        startDegreeOffset: 0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration: const BoxDecoration(
                                                                      color: Colors.white,
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    ///Employee Ratio
                                                    HrDashboardSmallcontainer(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Hr Staff To\nEmployee Ratio',
                                                            textAlign: TextAlign.start,
                                                            style: CustomTextStylesCommon.commonStyle(
                                                              fontSize: FontSize.s12,
                                                              fontWeight: FontWeight.w500,
                                                              color: ColorManager.mediumgrey,),
                                                          ),
                                                          Text(
                                                            '56%',
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(color: ColorManager.blueBorderText,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: AppSize.s30),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10,),

                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    ///Attrition Rate
                                                    HrDashboardSmallcontainer(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 20),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                Text(
                                                                  'Filter',
                                                                  textAlign: TextAlign.start,
                                                                  style: CustomTextStylesCommon.commonStyle(
                                                                    fontSize: FontSize.s12,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: ColorManager.mediumgrey,),
                                                                ),
                                                                const SizedBox(width: 10,),
                                                                Image.asset('images/hr_dashboard/filter.png',fit: BoxFit.contain,height: 14,width: 14,)
                                                              ],),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Attrition Rate',
                                                                    textAlign: TextAlign.start,
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                      fontSize: FontSize.s12,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: ColorManager.mediumgrey,),
                                                                  ),
                                                                  Text(
                                                                    '12%',
                                                                    textAlign: TextAlign.start,
                                                                    style: TextStyle(color: ColorManager.blueBorderText,  fontWeight: FontWeight.w500,
                                                                        fontSize: AppSize.s30),
                                                                  )
                                                                ],
                                                              ),
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                      width: 105,
                                                                      height: 55,
                                                                      child: Image.asset('images/hr_dashboard/person.png',fit: BoxFit.contain,))
                                                                ],
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    ///hiring ratio
                                                    HrDashboardSmallcontainer(
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.all(8.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Hiring Ratio',
                                                                  textAlign: TextAlign.start,
                                                                  style: CustomTextStylesCommon.commonStyle(
                                                                    fontSize: FontSize.s12,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: ColorManager.mediumgrey,),
                                                                ),
                                                                Text(
                                                                  '56%',
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(color: ColorManager.blueBorderText,  fontWeight: FontWeight.w500,
                                                                      fontSize: AppSize.s30),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              height: 150,
                                                              child: PieChart(
                                                                PieChartData(
                                                                  sections: [
                                                                    PieChartSectionData(
                                                                      color: ColorManager.greenGraph,
                                                                      value: 56,
                                                                      title: '',
                                                                      radius: 15,
                                                                    ),
                                                                    PieChartSectionData(
                                                                      color: ColorManager
                                                                          .faintGrey.withOpacity(0.5),
                                                                      value: 88,
                                                                      title: '',
                                                                      radius: 15,
                                                                    ),
                                                                  ],
                                                                  centerSpaceRadius: 30,
                                                                  centerSpaceColor: Colors.white,
                                                                  sectionsSpace: 2,
                                                                  borderData: FlBorderData(show: false),
                                                                  startDegreeOffset: -150,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15,),
                                        ///incidence and violation
                                        Expanded(
                                          flex: 2,
                                          child: HrDashboadGraphContainer(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Incident and violation tracking",
                                                        textAlign: TextAlign.start,
                                                        style: GraphHeadingHRDashboard.customTextStyle(context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 200,
                                                  child: SfCartesianChart(
                                                    primaryXAxis: const NumericAxis(
                                                      isVisible: true, // Keeps the X-axis line visible
                                                      axisLine: AxisLine(width: 1, color: Colors.grey), // X-axis base line
                                                      labelStyle: TextStyle(color: Colors.transparent), // Hides the labels on X-axis
                                                      majorGridLines: MajorGridLines(width: 0), // Disables grid lines
                                                      tickPosition: TickPosition.inside, // Keeps ticks inside the graph
                                                      majorTickLines: MajorTickLines(size: 6, color: Colors.grey), // Small ticks
                                                    ),
                                                    primaryYAxis: const NumericAxis(
                                                      isVisible: false, // Hides the Y-axis completely
                                                    ),
                                                    series: <CartesianSeries>[
                                                      SplineAreaSeries<ChartAreaData, int>(
                                                        color: ColorManager.incidentBlue.withOpacity(0.2),
                                                        borderColor: ColorManager.incidentBlue,
                                                        borderWidth: 2,
                                                        dataSource: AreachartData,
                                                        xValueMapper: (ChartAreaData data, _) => data.x,
                                                        yValueMapper: (ChartAreaData data, _) => data.y,
                                                      ),
                                                      SplineAreaSeries<ChartAreaData, int>(
                                                        color: ColorManager.incidentskin.withOpacity(0.3),
                                                        borderColor: ColorManager.incidentskin,
                                                        borderWidth: 2,
                                                        dataSource: AreachartData,
                                                        yValueMapper: (ChartAreaData data, _) => data.y1,
                                                        xValueMapper: (ChartAreaData data, _) => data.x,
                                                      ),
                                                    ],
                                                  ),
                                                ),


                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    TextCircleConst(text: "Safety Incidents", circleColor: ColorManager.incidentBlue, textColor: ColorManager.black,),
                                                    TextCircleConst(text:  "Policy Breaches", circleColor: ColorManager.incidentskin, textColor: ColorManager.black)
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15,),
                                        ///employee tenure
                                        Expanded(
                                          flex: 2,
                                          child: HrDashboadGraphContainer(
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Employee Tenure",
                                                      textAlign: TextAlign.center,
                                                      style: CustomTextStylesCommon.commonStyle(
                                                        fontSize: FontSize.s12,
                                                        fontWeight: FontWeight.w700,
                                                        color: ColorManager.mediumgrey,),
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Radio<String>(
                                                                splashRadius: 0,
                                                                activeColor: ColorManager.mediumgrey,
                                                                value: 'Age Wise',
                                                                groupValue: emptype, // Matches default value for pre-selection
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    emptype = value;
                                                                  });
                                                                },
                                                              ),
                                                              Text('Age Wise',  style: CustomTextStylesCommon.commonStyle(
                                                                fontSize: FontSize.s12,
                                                                fontWeight: emptype == 'Age Wise' ? FontWeight.w700 : FontWeight.w400,
                                                                color: ColorManager.mediumgrey,),),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Radio<String>(
                                                                splashRadius: 0,
                                                                activeColor: ColorManager.mediumgrey,
                                                                value: 'Service Wise',
                                                                groupValue: emptype, // Different from default initially
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    emptype = value;
                                                                  });
                                                                },
                                                              ),
                                                              Text('Service Wise', style: CustomTextStylesCommon.commonStyle(
                                                                fontSize: FontSize.s12,
                                                                fontWeight: emptype == 'Service Wise' ? FontWeight.w700 : FontWeight.w400,
                                                                color: ColorManager.mediumgrey,),),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left:8.0),
                                                      child: Row(children: [
                                                        Text(
                                                          "Oldest",
                                                          textAlign: TextAlign.center,
                                                          style: CustomTextStylesCommon.commonStyle(
                                                            fontSize: FontSize.s14,
                                                            fontWeight: FontWeight.w700,
                                                            color: ColorManager.blueprime,),
                                                        ),
                                                        const SizedBox(width: 100,),
                                                        Text(
                                                          "Youngest",
                                                          textAlign: TextAlign.center,
                                                          style: CustomTextStylesCommon.commonStyle(
                                                            fontSize: FontSize.s14,
                                                            fontWeight: FontWeight.w700,
                                                            color: ColorManager.blueprime,),
                                                        ),
                                                      ],),
                                                    ),
                                                    const Divider(),
                                                    Container(
                                                      child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [


                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                                                                crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                                                                children: [
                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    padding: const EdgeInsets.all(2),
                                                                    decoration: BoxDecoration(
                                                                      color: ColorManager.blueprime,
                                                                      borderRadius: BorderRadius.circular(30),
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(30),
                                                                      child: SizedBox(
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: Image.asset(
                                                                          'images/hr_dashboard/man.png', // Replace with your image path
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 10), // Optional: Add space between the image and text
                                                                  Text(
                                                                    "Ross G",
                                                                    textAlign: TextAlign.center,
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                      fontSize: FontSize.s12,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: ColorManager.blueprime,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 10),
                                                                  Text(
                                                                    "Age 49Y",
                                                                    textAlign: TextAlign.center,
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                      fontSize: FontSize.s12,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: ColorManager.mediumgrey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                                                                crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                                                                children: [
                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    padding: const EdgeInsets.all(2),
                                                                    decoration: BoxDecoration(
                                                                      color: ColorManager.blueprime,
                                                                      borderRadius: BorderRadius.circular(30),
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(30),
                                                                      child: SizedBox(
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: Image.asset(
                                                                          'images/hr_dashboard/man.png', // Replace with your image path
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 10), // Optional: Add space between the image and text
                                                                  Text(
                                                                    "Ross G",
                                                                    textAlign: TextAlign.center,
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                      fontSize: FontSize.s12,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: ColorManager.blueprime,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 10),
                                                                  Text(
                                                                    "Age 49Y",
                                                                    textAlign: TextAlign.center,
                                                                    style: CustomTextStylesCommon.commonStyle(
                                                                      fontSize: FontSize.s12,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: ColorManager.mediumgrey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                  ],
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSize.s20,),

                                    ///listview section
                                    Expanded(
                                      child: ScrollConfiguration(
                                        behavior: const ScrollBehavior().copyWith(scrollbars: false),
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: 15,
                                          itemBuilder: (context, index) {
                                            return const
                                            Column(
                                              children: [
                                                SizedBox(height: AppSize.s5),
                                                HRDashboardListViewData(),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
