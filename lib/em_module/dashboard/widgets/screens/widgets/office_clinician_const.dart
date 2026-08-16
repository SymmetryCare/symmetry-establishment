import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/em_dashboard_theme.dart';
import '../../../../../../../app/resources/establishment_resources/em_dashboard_string_manager.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../em_dashboard_const.dart';

class OfficeClinicianConst extends StatelessWidget {
  const OfficeClinicianConst({super.key});

  @override
  Widget build(BuildContext context) {
    return EMDashboardContainerConst(
        height: AppSize.s150,
        child: Padding(
          padding: const EdgeInsets.only(left: AppPadding.p30),
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 EmDashboardStringManager.hello,
                  style: EmDashHelloText.customTextStyle(context)
                ),
                Text(EmDashboardStringManager.enjoyLife,
                  style:EmDashHelloSubText.customTextStyle(context)
                ),
              ],
            ),
            SizedBox(
              width: AppSize.s20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Image.asset(
                      "images/em_dashboard/office_clinician.png",
                      fit: BoxFit.contain,
                    )),
              ],
            )
          ]),
        ));
  }
}

///average clinician listview
class AverageClinicianListview extends StatelessWidget {
  const AverageClinicianListview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(EmDashboardStringManager.avgTenureOffice,
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
          ///heading
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: AppSize.s30,
                  padding: EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p12),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: ColorManager.black.withOpacity(.02),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 2))
                    ],
                    color: ColorManager.dashBlueHead,

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EmDashboardStringManager.srNo,
                        textAlign: TextAlign.start,
                        style: EmDashListviewHeadText.customTextStyle(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right:AppPadding.p30),
                        child: Text(
                          EmDashboardStringManager.clinicianName,
                          textAlign: TextAlign.start,
                          style: EmDashListviewHeadText.customTextStyle(context),
                        ),
                      ),
                      Text(
                        EmDashboardStringManager.tenure,
                        textAlign: TextAlign.center,
                        style: EmDashListviewHeadText.customTextStyle(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppPadding.p10),
                        child: Text(
                          EmDashboardStringManager.startYear,
                          textAlign: TextAlign.end,
                          style: EmDashListviewHeadText.customTextStyle(context),
                        ),
                      ),
                      Text(
                        EmDashboardStringManager.orderQuantity,
                        textAlign: TextAlign.center,
                        style: EmDashListviewHeadText.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: AppSize.s30,
                ),
              ),
            ],
          ),
          ///data
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: AppSize.s200,
                 // width: 500,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(scrollbars: false),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        //int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                        // String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                        // EmployeeDocumentModal employeedoc = paginatedData[index];
                        return Column(
                          children: [
                            SizedBox(
                              height: AppSize.s10,
                            ),
                            Container(
                              height: AppSize.s44,
                              padding: EdgeInsets.only(left: AppPadding.p20),
                              //margin: EdgeInsets.symmetric(horizontal: AppMargin.m2),
                              decoration: BoxDecoration(
                                color: ColorManager.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(width: 1, color: Color(0xFFE9E9E9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorManager.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "01",
                                      textAlign: TextAlign.start,
                                      style: EmDashListviewDataText.customTextStyle(context),
                                    ),
                                  ),
                                  Expanded(
                                    flex:2,
                                    child: Text(
                                      "Clinician 1",
                                      textAlign: TextAlign.start,
                                      style: EmDashListviewDataText.customTextStyle(context),
                                    ),
                                  ),
                                  Expanded(
                                    flex:1,
                                    child: Text(
                                      "5",
                                      textAlign: TextAlign.start,
                                      style: EmDashListviewDataText.customTextStyle(context),
                                    ),
                                  ),
                                  Expanded(
                                    flex:1,
                                    child: Text(
                                      "2019",
                                      textAlign: TextAlign.start,
                                      style: EmDashListviewDataText.customTextStyle(context),
                                    ),
                                  ),
                                  Expanded(
                                    flex:1,
                                    child: Text(
                                      "100",
                                      textAlign: TextAlign.center,
                                      style: EmDashListviewDataText.customTextStyle(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSize.s10,),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        height: AppSize.s35,
                      decoration: BoxDecoration(
                        color: ColorManager.dashBlueHead,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(6),topRight: Radius.circular(6))
                      ),
                      child:  Center(
                        child: Text(EmDashboardStringManager.avgTenure,
                            style: MenuContainerTextStylling.customTextStyle(context)),
                      ),),
                      Container(height: AppSize.s160,
                        decoration: BoxDecoration(
                            color: ColorManager.white,
                            border: Border(top: BorderSide.none,bottom: BorderSide(color: ColorManager.blueBorder,width: 1),
                            left: BorderSide(color: ColorManager.blueBorder,width: 1),right: BorderSide(color: ColorManager.blueBorder,width: 1)),
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(6),bottomLeft: Radius.circular(6))
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppPadding.p60),
                            child: RichText(
                                text: TextSpan(
                                  text: '5',
                                  style:  CustomTextStylesCommon.commonStyle(
                                      color: ColorManager.mediumgrey,
                                      fontSize: FontSize.s64,
                                      fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(
                                      text: 'yrs',
                                      style:  CustomTextStylesCommon.commonStyle(
                                          color: ColorManager.mediumgrey,
                                          fontSize: FontSize.s32,
                                          fontWeight: FontWeight.w500)
                                      //AllPopupHeadings.customTextStyle(context),
                                    ),
                                  ],
                                ),
                                                  ),
                          ),
                        ),
                      )],
                  ))
            ],
          )
        ],
      ),
    );
  }
}


///office with highest patients listview
class OfficeHighestPatientList extends StatelessWidget {
  const OfficeHighestPatientList({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(EmDashboardStringManager.highestPatients,
                  style: EmDashContainerHeadTextStyle.customTextStyle(context)),
            ],),
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s30,
            // margin: EdgeInsets.symmetric(horizontal: 48,vertical: 10),
            padding: EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p10),
            // decoration: BoxDecoration(
            //   boxShadow: [
            //     BoxShadow(
            //         color: ColorManager.black.withOpacity(.02),
            //         blurRadius: 4,
            //         spreadRadius: 0,
            //         offset: Offset(0, 2))
            //   ],
            //   color: ColorManager.dashBlueHead,
            //
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                 EmDashboardStringManager.NoOfOffice,
                  textAlign: TextAlign.start,
                  style: EmDashContainerHeadTextStyle.customTextStyle(context),
                 // style: EmDashListviewHeadText.customTextStyle(context),
                ),
               Expanded(flex:1 ,child: Container()),
                Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p80),
                  child: Text(
                    EmDashboardStringManager.ratio,
                    textAlign: TextAlign.start,
                    style: EmDashContainerHeadTextStyle.customTextStyle(context),
                  ),
                ),
                SizedBox(width: AppSize.s30,),
                Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p40),
                  child: Text(
                    EmDashboardStringManager.count,
                    textAlign: TextAlign.center,
                    style: EmDashContainerHeadTextStyle.customTextStyle(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s10,),
          Container(
            height: AppSize.s200,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 15,
                itemBuilder: (context, index) {
                  //int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                  // String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                  // EmployeeDocumentModal employeedoc = paginatedData[index];
                  return Column(
                    children: [
                      SizedBox(
                        height: AppSize.s10,
                      ),
                      Container(
                        height: AppSize.s44,
                        padding: EdgeInsets.only(left: AppPadding.p20),
                        //margin: EdgeInsets.symmetric(horizontal: AppMargin.m2),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: Color(0xFFE9E9E9)),
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex:1,
                              child: Text(
                                "Office 1",
                                textAlign: TextAlign.start,
                                style: EmDashListviewDataText.customTextStyle(context),
                              ),
                            ),
                            Expanded(
                                flex:2,
                                child:  LinearProgressIndicator(
                                  backgroundColor: ColorManager.grey,
                                  color: ColorManager.pieChartYellow,
                                  value: 55/100,//.totalVal/100
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(30),
                                )
                            ),
                            //SizedBox(width: 20,),
                            Expanded(
                              flex:1,
                              child: Text(
                                "55%",
                                textAlign: TextAlign.center,
                                style: EmDashListviewDataText.customTextStyle(context),
                              ),
                            ),
                            Expanded(
                              flex:1,
                              child: Text(
                                "1000",
                                textAlign: TextAlign.center,
                                style: EmDashListviewDataText.customTextStyle(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),)
        ],
      ),
    );
  }
}

///clinician attendance
class AttendanceRatioConst extends StatelessWidget {
  final String officeName;
  final String attendance;
  final Color containerColor;
  const AttendanceRatioConst({super.key, required this.officeName, required this.attendance, required this.containerColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Container(
              width: AppSize.s10,
              height: AppSize.s15,
              decoration: BoxDecoration(
                color: containerColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSize.s10,),
            Text(officeName,style: EmDashListviewDataText.customTextStyle(context),),
          ],
        ),
        SizedBox(width: AppSize.s10,),
        Text(attendance,style: EmDashListviewDataText.customTextStyle(context),)
      ],
    );
  }
}

///popup
class OfficeClinicianPopup extends StatelessWidget {
  const OfficeClinicianPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: AppSize.s220,
        width: AppSize.s400,
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p15,vertical: AppPadding.p10),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(EmDashboardStringManager.customerSatisfactionRating,
            style: EmDashContainerHeadTextStyle.customTextStyle(context)),
            SizedBox(height: AppSize.s20,),
            ///heading
            Container(
              height: AppSize.s30,
              // margin: EdgeInsets.symmetric(horizontal: 48,vertical: 10),
              padding: EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p12),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: ColorManager.mediumgrey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 2))
                ],
                color: Color(0xFFC77AC4).withOpacity(0.74),

                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    EmDashboardStringManager.customer,
                    textAlign: TextAlign.start,
                    style: GeneralSettingTextStyle.customTextStyle(context)
                  ),
                  Text(
                    EmDashboardStringManager.satisfactionRating,
                    textAlign: TextAlign.start,
                    style: GeneralSettingTextStyle.customTextStyle(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.s10,),
            Expanded(
              child: Container(
                height: AppSize.s280,
                // width: 500,
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p10),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    //int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                    // String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                    // EmployeeDocumentModal employeedoc = paginatedData[index];
                    double rating = 4.5 - (index % 2) * 0.5;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Customer ${index + 1}",
                                textAlign: TextAlign.start,
                                style: EmDashListviewDataText.customTextStyle(context),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: RatingStars(
                                value: rating,
                                starCount: 5,
                                starSize: 18,
                                maxValue: 5,
                                starSpacing: 2,
                                maxValueVisibility: false,
                                valueLabelVisibility: false,
                                starOffColor: ColorManager.grey, // Unselected stars
                                starColor: Colors.orange, // Selected stars
                              ),
                            ),
                            Expanded(
                              flex:1,
                              child: Text(
                                "5",
                                textAlign: TextAlign.center,
                                style: EmDashListviewDataText.customTextStyle(context),
                              ),
                            ),
                          ],
                        ),
                        Divider()
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
  }
}
