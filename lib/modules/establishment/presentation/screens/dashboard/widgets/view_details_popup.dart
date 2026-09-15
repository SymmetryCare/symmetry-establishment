import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/widgets/hr_dashboard_const.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

class ViewDetailsPopup extends StatelessWidget {
  const ViewDetailsPopup({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch $emailUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s900,
        height: AppSize.s650,
        title: "User Details",
        body: [
          ///profile
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular avatar for the image or icon
                      ClipOval(
                        child:
                        CircleAvatar(radius: 50,child: Image.asset("images/profilepic.png",fit: BoxFit.cover,),)
                      ),
                      // Circular progress indicator around the image
                      SizedBox(
                        height: AppSize.s70,
                        width: AppSize.s70,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorManager.greenF),
                          strokeWidth: 3,
                          value: 20
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ///"Expired License"
                    ViewDetailsLicenseConst(
                      onTap: () {
                      },
                      text: AppString.expiredlicense,
                      containerColor: const Color(0xffD16D6A),
                      textOval: "5",
                    ),
                    const SizedBox(height: 5),

                    ///"About To Expired License"
                    ViewDetailsLicenseConst(
                        onTap: () {
                        },
                        text: AppString.abouttoexpire,
                        containerColor: const Color(0xffFEBD4D),
                        textOval:"10"
                    ),
                    const SizedBox(height: 5),

                    ///"Up To Date License"
                    ViewDetailsLicenseConst(
                        onTap: () {
                        },
                        text: AppString.uptodate,
                        containerColor: const Color(0xffB4DB4C),
                        textOval: "2"
                      ),
                  ],
                ),
              ],),
          ),
          const SizedBox(height: 40,),
          ///data
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.name, dataText: 'John Scott',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.empType, dataText: 'Full Time',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.address, dataText: 'San Jose, Z4',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.age, dataText: '05-031997(27)',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.gender, dataText: 'Male',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.ssn, dataText: '32165321321',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.phone, dataText: '(+1) 123-4567',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.personal, dataText: '(+1) 123-4567',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.work, dataText: '(+1) 123-4567',),

                  ],),
                const SizedBox(width: 50,),
                Column(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _launchEmail('abc@gmail.com');
                      },
                      child: ViewDetailsRowConst(
                        isUnderlined: true,
                        color: ColorManager.blueprime,
                        headText: AppStringHr.email,
                        dataText: 'abc@gmail.com',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchEmail('abc@gmail.com');
                      },
                      child: ViewDetailsRowConst(
                        isUnderlined: true,
                        color: ColorManager.blueprime,
                        headText: AppStringHr.email,
                        dataText: 'abc@gmail.com',
                      ),
                    ),
                    ViewDetailsRowConst(isUnderlined: false, headText: AppStringHr.zone, dataText: 'ProHealth, San Jose Z4',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.speciality, dataText: 'Physical Thearpy',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.service, dataText: 'NA',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.reportingOffice, dataText: 'NA',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.summary, dataText: 'NA',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.hireDate, dataText: '09/02/2014 (09 Y 11 M)',),
                    ViewDetailsRowConst(isUnderlined: false,headText: AppStringHr.pta, dataText: '1.2',),
                  ],),
              ],),
          ),
        ],
        bottomButtons: Container(
          height:35,
          width: 120,
          child: ElevatedButton(
            onPressed: (){
                Navigator.pop(context);
            },
            child: Text(
                AppStringHr.back,
                style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s14p,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.blueprime,)
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: ColorManager.blueprime,width: 2),
              ),
            ),
          ),
        ),);
  }
}


class ViewDetailsRowConst extends StatelessWidget {
  final String headText;
  final String dataText;
  final bool isUnderlined;
  final Color? color;
  const ViewDetailsRowConst({super.key, required this.headText, required this.dataText, required this.isUnderlined, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 40,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Expanded(
              child: Container(
                  height: 30,
                  child: Text(headText,style: TableHeadHRDashboard.customTextStyle(context),)),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: Container(
                  height: 30,
                  child: Text(dataText,style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w400,
                      color: color ?? ColorManager.mediumgrey,
                    decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: ColorManager.blueprime
                  ),)),
            ),
          ],),
          Divider(thickness: 1,color: ColorManager.dashDivider,height: 1,)
        ],
      ),
    );
  }
}
///licenses
class ViewDetailsLicenseConst extends StatelessWidget {
  String? text;
  final String textOval;
  final Color containerColor;
  final VoidCallback? onTap;

  ViewDetailsLicenseConst({
    Key? key,
    required this.text,
    required this.containerColor,
    required this.textOval, this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text!,
              textAlign: TextAlign.start,
              style: CustomTextStylesCommon.commonStyle(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF579EBA)
              ),
            ),
            const SizedBox(width: 5),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( 20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  height: 20,
                  width: 21,
                  decoration: BoxDecoration(
                    color: containerColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      textOval,
                      textAlign: TextAlign.center,
                      style: ProfileBarClipText.profileTextStyle(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
