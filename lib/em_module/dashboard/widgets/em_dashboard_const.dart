import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/theme_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/common_resources/em_dashboard_theme.dart';
import '../../../../../app/resources/font_manager.dart';
import '../../../../widgets/app_clickable_widget.dart';

typedef void OnManuButtonTapCallBack(int index);
///tabbar
class EMDashboardMenuButtons extends StatelessWidget {
  const EMDashboardMenuButtons({
    super.key,
    required this.onTap,
    required this.index,
    required this.grpIndex,
    required this.heading,
  });

  final OnManuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return AppClickableWidget(
      onTap: () {
        onTap(index);
      },
      onHover: (bool val) {},
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p14),
            child: Text(
              heading,
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w700,
                color: grpIndex == index
                    ? ColorManager.tabbarText
                    : ColorManager.mediumgrey,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: heading,
                  style: TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final textWidth = textPainter.size.width;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: AppMargin.m5),
                height: AppSize.s6,
                width: textWidth + 10,
                decoration: BoxDecoration(
                  color: grpIndex == index
                      ? ColorManager.tabbarText
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12)
                ),
               
              );
            },
          ),
        ],
      ),
    );
  }
}

///bottom Shadow container const
class EMDashboardContainerConst extends StatelessWidget {
  final Widget child;
  final double? height;
  const EMDashboardContainerConst({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppSize.s300,
      padding: EdgeInsets.all(AppPadding.p10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        // border: Border.symmetric(vertical: BorderSide.none,horizontal: BorderSide(width: 1,color: Color(0xFFBCBCBC)),),//all(width: 1, color: Color(0xFFBCBCBC)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.mediumgrey.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 4), // Downward shadow
          ),
        ],
      ),
      child: child,);
  }
}

///top blue border
class EMDashboardContainerBBorderConst extends StatelessWidget {
  final Widget child;
  final double? height;
  const EMDashboardContainerBBorderConst({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppSize.s130,
      padding: EdgeInsets.all(AppPadding.p10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(top: BorderSide(
          color: Color(0xFF6FC2EA),
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

/// all blue border container
class EMDashboardAllBlueSideContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  const EMDashboardAllBlueSideContainer({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppSize.s110,
      padding: EdgeInsets.all(AppPadding.p10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorManager.blueBorder,width: 2),
      ),
      child: child,);
  }
}

class BlueBorderContainerConst extends StatelessWidget {
  final IconData? imageTile;
  final String headText;
  final String numberText;
  final String bottomText;
  final String? imagePath;
  final double padding ;
  const BlueBorderContainerConst({super.key, this.imageTile, required this.headText, required this.numberText, required this.bottomText, this.imagePath, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Column(children: [
              SizedBox(height: AppSize.s10,),
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.all(AppPadding.p12),
                      width: AppSize.s50,
                      height: AppSize.s50,
                      color: ColorManager.bluebottom,
                      child:
                      Image.asset(
                  //fit: BoxFit.contain,
                  imagePath!,
                  // height: 20, // Adjust the size as needed
                  // width: 20,
                  // color: ColorManager.bluebottom,
                )
                ),
                )
              else if (imageTile != null)
                 ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: AppSize.s50,
                  height: AppSize.s50,
                  color: ColorManager.bluebottom,
                  //padding: EdgeInsets.all(10),
                  child: Icon(imageTile,color: ColorManager.white,size: IconSize.I24,)
                  // Image.asset(
                  //   imageTile, // Replace with your image path
                  //   fit: BoxFit.cover,
                  // ),
                ),
              )
            ],),
            SizedBox(width: AppSize.s15,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: padding ),
                  child: Text(numberText,
                    textAlign: TextAlign.center,
                    style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s28,
                        color: ColorManager.mediumgrey,fontWeight: FontWeight.w600),),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headText,
                    textAlign: TextAlign.center,
                    style: EmDashText.customTextStyle(context),),
                ],
              ),

            ],)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(bottomText,
              textAlign: TextAlign.end,
              style: CustomTextStylesCommon.commonStyle(
                fontSize: FontSize.s10,
                color: ColorManager.mediumgrey,
              ),)
          ],),
      ],
    );
  }
}

