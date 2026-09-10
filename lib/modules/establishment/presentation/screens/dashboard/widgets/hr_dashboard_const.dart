import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/bottomsheet_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/view_details_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';

class HrDashboardContainerConst extends StatefulWidget {
  final String headText;
  final Color headSubTextColor;
  final String subText;
  final String imageTile;

  const HrDashboardContainerConst({super.key,
    required this.headText, required this.headSubTextColor,
    required this.subText, required this.imageTile,});

  @override
  State<HrDashboardContainerConst> createState() => _HrDashboardContainerConstState();
}

class _HrDashboardContainerConstState extends State<HrDashboardContainerConst> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: const Border(top: BorderSide(
          color: Color(0xFFBCBCBC),
          width: 3,
        ),),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 4), // Downward shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.headText,
                style: CustomTextStylesCommon.commonStyle(fontSize: 16,
                    color: widget.headSubTextColor,fontWeight: FontWeight.w600),),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(widget.subText,
                      style: CustomTextStylesCommon.commonStyle(fontSize: 32,
                          color: widget.headSubTextColor,fontWeight: FontWeight.w600),),
                  )),
              Expanded(child: Center(
                child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child:Image.asset(widget.imageTile,fit: BoxFit.cover,
                    height: 80,)),))
            ],)
        ],
      ),
    );
  }
}

///part 2 Graph container const
class HrDashboadGraphContainer extends StatelessWidget {
  final Widget child;
  const HrDashboadGraphContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 280,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(top: BorderSide(
            color: Color(0xFF579EBA),
            width: 3,
          ),),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 4), // Downward shadow
            ),
          ],
        ),
    child: child,);
  }
}

class HrDashboardSmallcontainer extends StatelessWidget {
  final Widget child;
  const HrDashboardSmallcontainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: const Border(top: BorderSide(
            color: Color(0xFF579EBA),
            width: 2.5,
          ),),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 4), // Downward shadow
            ),
          ],
        ),
    child: child,);
  }
}

class TextCircleConst extends StatelessWidget {
  final String text;
  final Color circleColor;
  final Color? textColor;
  const TextCircleConst({super.key, required this.text, required this.circleColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.0,
          height: 15.0,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10,),
        Text(text,style: CustomTextStylesCommon.commonStyle(
            color: textColor ?? ColorManager.dashListviewData,
        fontSize: FontSize.s12,
        fontWeight: FontWeight.w500),)
      ],
    );
  }
}


///bottomsheet listview
class HRDashBottomSheetData extends StatelessWidget {
  const HRDashBottomSheetData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s88,
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
      margin: const EdgeInsets.symmetric(horizontal: AppMargin.m2),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      'images/hr_dashboard/man.png', // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30,),
              Text(
                "Ace Prabhu",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s14,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.black,),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Text(
                "Employee Type",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
              const SizedBox(width: 15,),
              Text(
                "Clinical",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.black,),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Text(
                "Phone Number",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
              const SizedBox(width: 15,),
              Text(
                "1234567890",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.black,),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "Document Names",
                  textAlign: TextAlign.center,
                  style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                    fontWeight: FontWeight.w400,
                    color: ColorManager.mediumgrey,),
                ),
              ),
              const SizedBox(width: 20,),
              Expanded(
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.only(left: 50),
                  child: GestureDetector(
                    onTap: (){
                      showDialog(context: context, builder: (context) => const BottomsheetPopup());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Driving License",
                              textAlign: TextAlign.start,
                              style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                                fontWeight: FontWeight.w400,
                                color: ColorManager.textBlack,),
                            ),
                            const SizedBox(width: 20,),
                            Text(
                              "expiry in 10 month",
                              textAlign: TextAlign.start,
                              style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF428634)),
                            ),
                          ],
                        ),
                        Text(
                          "Domicile",
                          textAlign: TextAlign.start,
                          style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.textBlack,),
                        ),
                        Text(
                          "Birth Certificate",
                          textAlign: TextAlign.start,
                          style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.textBlack,),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],),
    );
  }
}


///part 3 listview container
class HRDashboardListViewData extends StatelessWidget {
  const HRDashboardListViewData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s88,
     padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
     margin: const EdgeInsets.symmetric(horizontal: AppMargin.m2),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorManager.mediumgrey.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    child: Row(children: [
      Expanded(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                width: 60,
                height: 70,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: ColorManager.dashListviewDataPink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
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
            ),
            const SizedBox(width: 30,),
            Text(
              "Ace Prabhu",
              textAlign: TextAlign.center,
              style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
                fontWeight: FontWeight.w500,
                color: ColorManager.black,),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                "Expiry Date for\nDriving License",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
            ),
            const SizedBox(width: 6,),
            Flexible(
              child: Text(
                "24.06.2025",
                textAlign: TextAlign.center,
                style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textBlack,),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                "Expiry Date for\nPractitioner License",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
            ),
            const SizedBox(width: 6,),
            Flexible(
              child: Text(
                "24.06.2025",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textBlack,),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                "Average Sick\nDays",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
            ),
            const SizedBox(width: 6,),
            Flexible(
              child: Text(
                "12 Days",
                textAlign: TextAlign.end,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textBlack,),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                "Driving License",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
            ),
            const SizedBox(width: 8,),
             PdfDownloadButton(
              apiPath: DownloadDocumentRepository.getDrivingLicenseDocumentByFileName(),
                apiUrl: 'apiUrl', documentName: 'documentName')
          ],
        ),
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                "Practitioner License",
                textAlign: TextAlign.start,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey,),
              ),
            ),
            const SizedBox(width: 8,),
             PdfDownloadButton(
              apiPath: DownloadDocumentRepository.getPractitionerLicenseDocumentByFileName(),
                apiUrl: 'apiUrl', documentName: 'documentName')
          ],
        ),
      ),
      Container(
        height:33,
        width: 100,
        child: ElevatedButton(
          onPressed: (){
            showDialog(context: context, builder: (context) => const ViewDetailsPopup());
          },
          child: Text(
              AppStringHr.viewDetails,
              style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s12,
                fontWeight: FontWeight.w500,
                color: ColorManager.white,)
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: ColorManager.blueprime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ColorManager.dashListviewData),
            ),
          ),
        ),
      )
    ],),
    );
  }
}
