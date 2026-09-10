import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/widgets/const_linear_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/widgets/data_file.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/screens/widgets/office_clinician_const.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/common_resources/em_dashboard_theme.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/em_dashboard_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

class OfficeClinicianScreen extends StatefulWidget {
   OfficeClinicianScreen({super.key});

  @override
  State<OfficeClinicianScreen> createState() => _OfficeClinicianScreenState();
}

class _OfficeClinicianScreenState extends State<OfficeClinicianScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  /// Bar Column chart data output ratio
  final List<BarChartEMData> barChartEMData = <BarChartEMData>[
    BarChartEMData('A', 50, 30),
    BarChartEMData('B', 40, 25),
    BarChartEMData('C', 100, 80),
    BarChartEMData('D', 80, 50),
  ];

  ///line graph
  final List<ChartData> chartData = [
    ChartData(1, 2),  // February
    ChartData(2, 3),  // March
    ChartData(3, 4),  // April
    ChartData(4, 4),  // May
    ChartData(5, 3),  // June
    ChartData(6, 2.5),  // July
    ChartData(7, 2),  // July
    ChartData(8, 3),  // July
    ChartData(9, 4),  // July
    ChartData(10, 5),  // July
    ChartData(11, 6),  // July
    ChartData(12, 6),  // July
  ];

  List<BarChartGroupData> _generateBarGroups() {
    return [
      // First bar
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 90,
            width: 32,
            borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6)),
            color: ColorManager.pieChartGreen,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: ColorManager.white, // Background color
            ),
          ),
        ],
      ),
      // Second bar
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 80,
            width: 32,
            borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6)),
            color: ColorManager.pieChartBlue,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: ColorManager.white,
            ),
          ),
        ],
      ),
      // Third bar
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 100,
            width: 32,
            borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6)),
            color: Color(0xFFFEBD4D),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: ColorManager.white,
            ),
          ),
        ],
      ),
      // Fourth bar
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: 75,
            width: 32,
            borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6)),
            color: Color(0xFFC77AC4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: ColorManager.white,
            ),
          ),
        ],
      ),
    ];
  }

  String selectedValue = "Daily";
  final List<String> items = ["Daily", "Weekly", "Monthly"];

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
      child: Padding(padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p14
      ),
      child: Column(children: [
        ///first row
        Row(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                child: OfficeClinicianConst()),
            SizedBox(width: AppSize.s15,),
            Expanded(
                flex: 2,
                child: EMDashboardContainerBBorderConst(
                  child: GestureDetector(
                      onTap: (){
                        showDialog(context: context, builder: (context) => OfficeClinicianPopup());
                      },
                      child: LinearCardWidget(headingText: EmDashboardStringManager.customerSatisfaction, totalCount: '04', totalValue: 04,imagePath: "images/em_dashboard/OCSR.png",)),)),
            SizedBox(width: AppSize.s15,),
            Expanded(
                flex: 2,
                child: EMDashboardContainerBBorderConst(
                  child: LinearCardWidget(headingText: EmDashboardStringManager.continueEduCredit, totalCount: '30', totalValue: 30,imagePath: "images/em_dashboard/CEC.png"),)),
            SizedBox(width: AppSize.s15,),
            Expanded(
                flex: 2,
                child: EMDashboardContainerBBorderConst(
                  child: LinearCardWidget(headingText: EmDashboardStringManager.clinicianTimeOff, totalCount: '07:00:00 pm', totalValue: 100,icon: CupertinoIcons.clock_fill,),)),
          ],),
        SizedBox(height: AppSize.s15,),
        ///2nd row
        Row(children: [
          ///patients ration graph
         Expanded(
              flex: 4,
              child: EMDashboardContainerConst(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p8),
                        child: Text(
                          EmDashboardStringManager.clinicianPatientRatio,
                          style: EmDashContainerHeadTextStyle.customTextStyle(context),
                        ),
                      ),
                      Container(
                        height: AppSize.s220,
                        child: SfCartesianChart(
                          backgroundColor: ColorManager.white,
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            // Set minimum, maximum, and interval for percentage labels
                            minimum: 0,
                            maximum: 90,
                            interval: 10,
                            axisLabelFormatter: (AxisLabelRenderDetails details) {
                              // Appends '%' symbol to the Y-axis labels
                              return ChartAxisLabel('${details.text}%', details.textStyle);
                            },
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<BarChartEMData, String>(
                              color: ColorManager.relativeResult,
                              dataSource: barChartEMData,
                              xValueMapper: (BarChartEMData data, _) => data.x,
                              yValueMapper: (BarChartEMData data, _) => data.y,
                            ),
                            ColumnSeries<BarChartEMData, String>(
                              color: ColorManager.ClinicianRatio,
                              dataSource: barChartEMData,
                              xValueMapper: (BarChartEMData data, _) => data.x,
                              yValueMapper: (BarChartEMData data, _) => data.y1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))),
          SizedBox(width: AppSize.s15,),
          Expanded(
              flex: 6,
              child: EMDashboardContainerBBorderConst(
                height:AppSize.s300,
                  child: Column(
                    children: [
                     AverageClinicianListview()
                    ],
                  ))),
        ],),
        SizedBox(height: AppSize.s15,),
        ///3rd row
        Row(children: [
          Expanded(
              flex: 4,
              child: EMDashboardContainerConst(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppPadding.p40,left: AppPadding.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(EmDashboardStringManager.clinicianOvertime,
                           style: EmDashContainerHeadTextStyle.customTextStyle(context)),

                          Container(
                            width:AppSize.s125,
                           child: StatefulBuilder(
                                builder: (BuildContext context,
                                    void Function(void Function()) setState) {
                                  return CustomDropdownEMDashboard(
                                    items: ["Daily", "Weekly", "Monthly"],
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue =
                                        newValue!;
                                      });
                                    },

                                  );

                                }
                            ),
                         ),

                        ],
                      ),
                    ),
          Container(
            height: AppSize.s210,
            child: SfCartesianChart(
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 8,
                interval: 1,
                title: AxisTitle(
                  text: 'Number of Clinicians',
                  textStyle: ConstTextFieldStyles.customTextStyle(textColor: ColorManager.mediumgrey),
                  alignment: ChartAlignment.center, // Center-align the title
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  return ChartAxisLabel(details.value.toInt().toString(), TextStyle(fontSize: FontSize.s12));
                },
              ),
              primaryXAxis: CategoryAxis(
                // title: AxisTitle(
                //   text: 'Months',
                //   textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                // ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  // Map integer values to month names
                  switch (details.value.toInt()) {
                    case 0:
                      return ChartAxisLabel('Jan', EmDashListviewDataText.customTextStyle(context));
                    case 1:
                      return ChartAxisLabel('Feb', EmDashListviewDataText.customTextStyle(context));
                    case 2:
                      return ChartAxisLabel('Mar', EmDashListviewDataText.customTextStyle(context));
                    case 3:
                      return ChartAxisLabel('Apr', EmDashListviewDataText.customTextStyle(context));
                    case 4:
                      return ChartAxisLabel('May', EmDashListviewDataText.customTextStyle(context));
                    case 5:
                      return ChartAxisLabel('Jun', EmDashListviewDataText.customTextStyle(context));
                    case 6:
                      return ChartAxisLabel('Jul', EmDashListviewDataText.customTextStyle(context));
                    case 7:
                      return ChartAxisLabel('Aug', EmDashListviewDataText.customTextStyle(context));
                    case 8:
                      return ChartAxisLabel('Sept', EmDashListviewDataText.customTextStyle(context));
                    case 9:
                      return ChartAxisLabel('Oct', EmDashListviewDataText.customTextStyle(context));
                    case 10:
                      return ChartAxisLabel('Nov', EmDashListviewDataText.customTextStyle(context));
                    case 11:
                      return ChartAxisLabel('Dec', EmDashListviewDataText.customTextStyle(context));
                    default:
                      return ChartAxisLabel('', TextStyle(fontSize: 12));
                  }
                },
              ),
              series: <CartesianSeries>[
                // Render spline chart
                SplineSeries<ChartData, int>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                ),
              ],
            ),
          )
                  ],
                ),)),
          SizedBox(width: AppSize.s15,),
          Expanded(
              flex: 4,
              child: EMDashboardContainerConst(child: OfficeHighestPatientList())),
        ],),
        SizedBox(height: AppSize.s15,),
        ///4th row
        Row(children: [
          Expanded(
              flex: 4,
              child: Container(
                height: AppSize.s300,
                decoration: BoxDecoration(
                  color: Color(0xFFE7F6F8),
                  borderRadius: BorderRadius.circular(14),
                  // border: Border.symmetric(vertical: BorderSide.none,horizontal: BorderSide(width: 1,color: Color(0xFFBCBCBC)),),//all(width: 1, color: Color(0xFFBCBCBC)),
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.mediumgrey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 4), // Downward shadow
                    ),
                  ],
                ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(EmDashboardStringManager.avgclinScore,
                  style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                  Container(
                  height: AppSize.s200,
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  child: BarChart(
                    BarChartData(
                      baselineY: 2,
                      maxY: 100, // Maximum value for the Y-axis
                      barGroups: _generateBarGroups(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false, // Disable Y-axis tick labels
                          ),
                          axisNameWidget: Padding(
                            padding: const EdgeInsets.only(right: AppPadding.p50),
                            child: Text(
                              'Clinician Score',
                              style: EmDashContainerHeadTextStyle.customTextStyle(context),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          axisNameSize: 20, // Reserve space for the Y-axis title
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              // X-axis labels
                              switch (value.toInt()) {
                                case 0:
                                  return Text('90%');
                                case 1:
                                  return Text('80%');
                                case 2:
                                  return Text('100%');
                                case 3:
                                  return Text('75%');
                                default:
                                  return Text('');
                              }
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide top titles
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                      ),
                      barTouchData: BarTouchData(enabled: false),
                      gridData: FlGridData(show: false), // Hide grid lines
                      borderData: FlBorderData(show: false), // Hide chart borders
                    ),
                  ),
                )
                ],
              ),)),
          SizedBox(width: AppSize.s15,),
          Expanded(
              flex: 3,
              child: EMDashboardContainerConst(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p15),
                    child: Text(EmDashboardStringManager.avgOfficeclinratio,
                    style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                  ),
                  Center(
                    child: Container(
                      height: AppSize.s200,
                      padding: EdgeInsets.only(left: AppPadding.p15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Circle
                          SizedBox(
                            width: AppSize.s160,
                            height: AppSize.s160,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: ColorManager.pieChartGreen,
                                    value: 85, // Patients % value
                                    radius: 15,
                                    title: "",

                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey[300],
                                    value: 15, // Remaining % value
                                    radius: 15,
                                    title: "",
                                  ),
                                ],
                                centerSpaceRadius: 70, // Space between inner and outer circle
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                          // Inner Circle
                          SizedBox(
                            width: AppSize.s100,
                            height: AppSize.s100,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: ColorManager.pieChartfGrey,
                                    value: 90, // Clinicians % value
                                    radius: 13,
                                    title: "",
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey[200],
                                    value: 10, // Remaining % value
                                    radius: 13,
                                    title: "",
                                  ),
                                ],
                                centerSpaceRadius: 50,
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: AppSize.s10,
                        height: AppSize.s15,
                        decoration: BoxDecoration(
                          color: ColorManager.pieChartGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSize.s10,),
                      Text("Patients",
                        style: NumberTExtFieldLegalDoc.customTextStyle(context),),
                      SizedBox(width: AppSize.s10,),
                      Text("3225+",style: NumberTExtFieldLegalDoc.customTextStyle(context),)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: AppSize.s10,
                        height: AppSize.s15,
                        decoration: BoxDecoration(
                          color: ColorManager.pieChartfGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSize.s10,),
                      Text("Clinicians",
                        style: NumberTExtFieldLegalDoc.customTextStyle(context),),
                      SizedBox(width: AppSize.s10,),
                      Text("309+",style: NumberTExtFieldLegalDoc.customTextStyle(context),)
                    ],
                  ),

                ],
              ))),
          SizedBox(width: AppSize.s15,),
          ///attendance
          Expanded(
              flex: 5,
              child: EMDashboardContainerConst(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(EmDashboardStringManager.clinAttendanceRate,
                      style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                  Row(
                    children: [
                      Container(
                        height: AppSize.s200,
                        width: AppSize.s200,
                      // color: Colors.red,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: ColorManager.mediumgrey,
                                value: 40,
                                title: '',
                                //titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                radius: 25,
                              ),
                              PieChartSectionData(
                                color: ColorManager.pieChartGreen,
                                value: 20,
                                title: '',
                                //titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                radius: 25,
                              ),
                              PieChartSectionData(
                                color: ColorManager.relativeResult,
                                value: 10,
                                title: '',
                                //titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                radius: 25,
                              ),
                              PieChartSectionData(
                                color: ColorManager.pieChartBlue,
                                value: 25,
                                title: '',
                                //titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                radius: 25,
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          AttendanceRatioConst(officeName: "Office 1", attendance: "80%", containerColor: ColorManager.mediumgrey),
                          SizedBox(height: AppSize.s20,),
                          AttendanceRatioConst(officeName: "Office 2", attendance: "95%", containerColor: ColorManager.pieChartGreen),
                          SizedBox(height: AppSize.s20,),
                          AttendanceRatioConst(officeName: "Office 3", attendance: "50%", containerColor: ColorManager.pieChartBlue),
                            SizedBox(height: AppSize.s20,),
                            AttendanceRatioConst(officeName: "Office 4", attendance: "20%", containerColor: ColorManager.relativeResult),
                        ],),
                      )
                    ],
                  )
                ],
              ))),
          SizedBox(width: AppSize.s15,),
          ///speedometer
          Expanded(
              flex: 4,
              child: EMDashboardContainerConst(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(EmDashboardStringManager.longavgvisit,
                      style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                  Center(
                    child: Container(
                      height:AppSize.s190,
                      width: AppSize.s250,
                      //color: Colors.pink,
                      child:SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(
                            showLabels: false,
                            startAngle: 180, // Start from the bottom center
                            endAngle: 0,     // End at the bottom center
                            minimum: 0,      // Minimum value of the gauge
                            maximum: 100,    // Maximum value of the gauge
                            ranges: <GaugeRange>[
                              GaugeRange(startValue: 0, endValue: 80, color: ColorManager.pieChartBBlue,
                                startWidth: 20,
                                endWidth: 20, ),
                              GaugeRange(startValue: 80, endValue: 100, color: ColorManager.faintGrey,
                                startWidth: 20,
                                endWidth: 20, ),
                            ],
                            // pointers: <GaugePointer>[
                            //   // Custom gradient for the range pointer
                            //   RangePointer(
                            //     value: 80, // The value up to which the gradient should appear
                            //     width: 20,
                            //     enableAnimation: true,
                            //     gradient: const SweepGradient(
                            //       colors: [
                            //         Color(0xFF3A6FA0), // Start color
                            //         Color(0xFF2BC2C2), // End color
                            //       ],
                            //       stops: [0.0, 1.0],
                            //     ),
                            //   ),
                            // ],
                            annotations: <GaugeAnnotation>[
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
                    ),
                  )
                ],
              ))),
        ],),
        SizedBox(height: AppSize.s15,),
      ],),),  // Column, Padding(horizontal)
    ),              // SingleChildScrollView(vertical)
            ),      // SizedBox
          ),        // Padding(bottom)
        ),          // SingleChildScrollView(horizontal)
      );            // CustomScrollbar
    });             // LayoutBuilder
  }
}
