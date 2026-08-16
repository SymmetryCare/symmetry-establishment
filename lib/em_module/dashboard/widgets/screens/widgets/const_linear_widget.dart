import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../../app/resources/common_resources/em_dashboard_theme.dart';

class LinearCardWidget extends StatelessWidget {
  final String headingText;
  final String totalCount;
  final IconData? icon;
  final String? imagePath;
  final int totalValue;
   LinearCardWidget({super.key, required this.headingText, required this.totalCount, required this.totalValue, this.icon, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8,vertical: AppPadding.p2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(headingText,
                    style:  EmDashContainerHeadTextStyle.customTextStyle(context)
                  ),
                SizedBox(height: AppSize.s15,),
                  Text(totalCount,style: TextStyle(fontSize: FontSize.s28,color: ColorManager.blueprime,fontWeight: FontWeight.w700),)
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        fit: BoxFit.fill,
                        imagePath!,
                        height: AppSize.s60, // Adjust the size as needed
                        width: AppSize.s50,
                        // color: ColorManager.bluebottom,
                      )
                    else if (icon != null)
                      Icon(
                        icon,
                        color: ColorManager.bluebottom.withOpacity(0.4),
                        size: IconSize.I40,
                      ),
                  ],
                ),
              )
            ],
          ),
          LinearProgressIndicator(
            backgroundColor: ColorManager.white,
            color: ColorManager.blueprime,
            value: totalValue/100,
            minHeight: 2,
          )
        ],
      ),
    );
  }
}
