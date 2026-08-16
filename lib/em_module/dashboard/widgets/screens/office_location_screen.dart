import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/widgets/const_linear_widget.dart';
import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/widgets/office_location_const.dart';
import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/common_resources/em_dashboard_theme.dart';
import '../../../../../../app/resources/establishment_resources/em_dashboard_string_manager.dart';
import '../../../../../../app/resources/value_manager.dart';
import '../em_dashboard_const.dart';
import '../../../../../../presentation/widgets/widgets/custom_scrollbar.dart';

class OfficeLocationScreen extends StatefulWidget {
  const OfficeLocationScreen({super.key});

  @override
  State<OfficeLocationScreen> createState() => _OfficeLocationScreenState();
}

class _OfficeLocationScreenState extends State<OfficeLocationScreen> {
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
      child: Padding(padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p25
      ),
        child: Column(children: [
          ///first row
          Row(
            mainAxisAlignment:MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 4,
                  child: OfficeLocationConst()),
              SizedBox(width: AppSize.s15,),
              Expanded(
                  flex: 2,
                  child: EMDashboardContainerBBorderConst(
                    child: LinearCardWidget(headingText: EmDashboardStringManager.totaloffice, totalCount: '10', totalValue: 10,imagePath: "images/em_dashboard/TNO.png"
                    ),)),
              SizedBox(width: AppSize.s15,),
              Expanded(
                  flex: 2,
                  child: EMDashboardContainerBBorderConst(
                    child: LinearCardWidget(headingText: EmDashboardStringManager.occupancyrate, totalCount: '04', totalValue:4,imagePath: "images/em_dashboard/OOR.png"
                    ),)),
              SizedBox(width: AppSize.s15,),
              Expanded(
                  flex: 2,
                  child: EMDashboardContainerBBorderConst(
                    child: GestureDetector(
                        onTap: (){
                          showDialog(context: context, builder: (context) => OfficeLocationPopup());
                        },
                        child: LinearCardWidget(headingText: EmDashboardStringManager.dailyattendance, totalCount: '100%', totalValue: 100,imagePath: "images/em_dashboard/calendar_check.png")),)),
            ],),
          SizedBox(height: AppSize.s15,),
          ///2nd row
          Row(children: [
            Expanded(
                flex: 4,
                child: EMDashboardContainerConst(
                    height: AppSize.s600,
                    child: Padding(
                      padding: const EdgeInsets.all(AppPadding.p10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(EmDashboardStringManager.avgdistance,
                              style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppPadding.p10),
                            child: Container(
                              height: AppSize.s420,// Adjust the height as needed
                               child: GoogleMap(
                                initialCameraPosition:
                                CameraPosition(
                                  target: LatLng(
                                  //  double.parse(snapshot.data![index].lat),
                                    double.parse("18.516726"),
                                   // double.parse(snapshot.data![index].long),
                                    double.parse("73.856255"),
                                  ),
                                  zoom: 15.0,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(''),
                                    position: LatLng(
                                      double.parse("18.516726"),
                                      double.parse("73.856255"),
                                    ),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                          Text('1 hr ( 30 km )',style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                        ],
                      ),
                    ),)),
            SizedBox(width: AppSize.s15,),
            Expanded(
              flex: 6,
              child: Column(children: [
                ///listview
                EMDashboardContainerBBorderConst(
                    height: AppSize.s240,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(EmDashboardStringManager.equipmentInventory,
                                style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                EmDashboardStringManager.viewMore,
                                textAlign: TextAlign.end,
                                style: EmDashViewMoreText.customTextStyle(context),
                              ),
                            ),
                          ],),
                        SizedBox(height: AppSize.s10,),
                        OfficeEquipmentHead(),
                        OfficeEquipmentData()
                      ],
                    )),
                SizedBox(height: AppPadding.p20,),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///graph
                    Expanded(
                      flex:3,
                      child: EMDashboardContainerBBorderConst(
                          height: AppSize.s340,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                  Text(EmDashboardStringManager.onsiteStaff,
                                  style: EmDashstaffText.customTextStyle(context),),
                                  SizedBox(width: AppSize.s70,),
                                  Text(EmDashboardStringManager.remoteStaff,
                                  style: EmDashstaffText.customTextStyle(context)),
                                ],),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(height: AppSize.s100,),
                                        GraphMenuConst(text: EmDashboardStringManager.onsiteStaff, squareColor: ColorManager.pieChartGreen,textColor: ColorManager.mediumgrey,),
                                        SizedBox(height: AppSize.s10,),
                                        GraphMenuConst(text: EmDashboardStringManager.remoteStaff, squareColor: ColorManager.pieChartBlue,textColor: ColorManager.mediumgrey,),

                                      ],
                                    ),
                                    SizedBox(width: AppSize.s40,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: AppSize.s250,
                                          height: AppSize.s250,
                                          child: PieChart(
                                            PieChartData(
                                              sections: [
                                                PieChartSectionData(
                                                  color: ColorManager.pieChartBlue,
                                                  value: 60,
                                                  title: '65%',
                                                  titleStyle:  TextStyle(
                                                      fontSize: 10, fontWeight: FontWeight.bold, color: ColorManager.mediumgrey),
                                                  radius: 40,
                                                ),
                                                PieChartSectionData(
                                                  // borderSide: BorderSide(
                                                  //   color: Colors.white, // Border color
                                                  //   width: 2, // Border width
                                                  // ),
                                                  color: ColorManager.pieChartGreen,
                                                  value: 40,
                                                  title: '35%',
                                                  titleStyle:  TextStyle(
                                                      fontSize: 10, fontWeight: FontWeight.bold, color: ColorManager.mediumgrey),
                                                  radius: 45,
                                                ),
                                              ],
                                              centerSpaceRadius: 70,
                                              centerSpaceColor: Colors.white,
                                              sectionsSpace: 2,
                                              borderData: FlBorderData(show: true),
                                              startDegreeOffset: -90,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(width: AppSize.s15,),
                    Expanded(
                      flex:2,
                      child: EMDashboardContainerBBorderConst(
                          height: AppSize.s170,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    EmDashboardStringManager.viewMore,
                                    textAlign: TextAlign.end,
                                    style: EmDashViewMoreText.customTextStyle(context),
                                  ),
                                ),
                              ],),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Text(EmDashboardStringManager.serviceAvailability,
                                    style: EmDashContainerHeadTextStyle.customTextStyle(context)),
                              ],),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                Column(children: [
                                  Icon(Icons.home,color: ColorManager.bluebottom,size: IconSize.I30,),
                                  SizedBox(height: AppSize.s8,),
                                  Text(EmDashboardStringManager.home,
                                      style: EmDashHelloSubText.customTextStyle(context))
                                ],),
                                Column(children: [
                                  Icon(Icons.local_hospital,color: ColorManager.bluebottom,size: IconSize.I30,),
                                  SizedBox(height: AppSize.s8,),
                                  Text(EmDashboardStringManager.health,
                                      style: EmDashHelloSubText.customTextStyle(context))
                                ],),
                                Column(children: [
                                  Image.asset("images/em_dashboard/hospice.png",height: IconSize.I30,width: IconSize.I20,fit: BoxFit.fill,color: ColorManager.bluebottom,),
                                  //Icon(Icons.location_on_outlined,color: ColorManager.bluebottom,size: IconSize.I30,),
                                  SizedBox(height: AppSize.s8,),
                                  Text(EmDashboardStringManager.hospice,
                                      style: EmDashHelloSubText.customTextStyle(context))
                                ],),
                              ],),
                            ],
                          )),
                    ),
                  ],
                ),
              ],),
            )
          ],),
          SizedBox(height: AppSize.s30,),
        ],),),  // Column, Padding(horizontal)
    ),              // SingleChildScrollView(vertical)
            ),      // SizedBox
          ),        // Padding(bottom)
        ),          // SingleChildScrollView(horizontal)
      );            // CustomScrollbar
    });             // LayoutBuilder
  }
}
