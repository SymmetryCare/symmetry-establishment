import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/em_dashboard_theme.dart';
import '../../../../../../../app/resources/establishment_resources/em_dashboard_string_manager.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../em_dashboard_const.dart';

class OfficeLocationConst extends StatelessWidget {
  const OfficeLocationConst({super.key});

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
                Text(EmDashboardStringManager.locateElvtP,
                  style: EmDashHelloSubText.customTextStyle(context)
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
                  "images/em_dashboard/office_location.png",
                  fit: BoxFit.contain,
                )),
              ],
            )
          ]),
        ));
  }
}

/// listview head
class OfficeEquipmentHead extends StatelessWidget {
  const OfficeEquipmentHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s30,
      // margin: EdgeInsets.symmetric(horizontal: 48,vertical: 10),
      padding: EdgeInsets.only(left: AppPadding.p10,right: AppPadding.p10),
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
            padding: const EdgeInsets.only(right: AppPadding.p70),
            child: Text(
              EmDashboardStringManager.eqipmentName,
              textAlign: TextAlign.start,
              style: EmDashListviewHeadText.customTextStyle(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppPadding.p60),
            child: Text(
              EmDashboardStringManager.category ,
              textAlign: TextAlign.center,
              style: EmDashListviewHeadText.customTextStyle(context),
            ),
          ),
          Text(
            EmDashboardStringManager.quantityHand,
            textAlign: TextAlign.end,
            style: EmDashListviewHeadText.customTextStyle(context),
          ),
          Text(
            EmDashboardStringManager.orderQuantity,
            textAlign: TextAlign.center,
            style: EmDashListviewHeadText.customTextStyle(context),
          ),
        ],
      ),
    );
  }
}

///listview data
class OfficeEquipmentData extends StatelessWidget {
  const OfficeEquipmentData({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  height: 10,
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
                          "1",
                          textAlign: TextAlign.start,
                          style: EmDashListviewDataText.customTextStyle(context),
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: Text(
                          "Equipment",
                          textAlign: TextAlign.start,
                          style: EmDashListviewDataText.customTextStyle(context),
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: Text(
                          "Supplies",
                          textAlign: TextAlign.start,
                          style: EmDashListviewDataText.customTextStyle(context),
                        ),
                      ),
                      Expanded(
                        flex:1,
                        child: Text(
                          "100",
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
    );
  }
}

///graph list const
class GraphMenuConst extends StatelessWidget {
  final String text;
  final Color squareColor;
  final Color? textColor;
  const GraphMenuConst({super.key, required this.text, required this.squareColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,style: CustomTextStylesCommon.commonStyle(
            color: textColor ?? ColorManager.dashListviewData,
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500),),
        SizedBox(width: AppSize.s10,),
        Container(
          width: AppSize.s10,
          height: AppSize.s10,
          decoration: BoxDecoration(
            color: squareColor,
            shape: BoxShape.rectangle,
          ),
        ),

      ],
    );
  }
}

///popup
class OfficeLocationPopup extends StatelessWidget {
  const OfficeLocationPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s600, height: AppSize.s450,
        body: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EmDashboardStringManager.NoOfOffice,
                        style: AllPopupHeadings.customTextStyle(context)),
                    Row(children: [
                      Text(EmDashboardStringManager.attendanceRatio,
                          style: AllPopupHeadings.customTextStyle(context)),
                      SizedBox(width: AppSize.s20),
                      Icon(Icons.calendar_today,color: ColorManager.bluebottom,size: IconSize.I20,)
                    ],)
                  ],),
                SizedBox(height: AppSize.s10,),
                Container(
                  height: AppSize.s255,
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
                                  )
                                ),
                                SizedBox(width: AppSize.s20,),
                                Expanded(
                                  flex:1,
                                  child: Text(
                                    "55%",
                                    textAlign: TextAlign.start,
                                    style: EmDashListviewDataText.customTextStyle(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),)
              ],
            ),
          )

        ],
        bottomButtons: Offstage(),
        title: EmDashboardStringManager.attendancePopupHead);
  }
}
