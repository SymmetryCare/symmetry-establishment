import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class TopRowConstant extends StatelessWidget {
  const TopRowConstant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s60,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30), // Adjust padding as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust alignment as needed
          children: [
            Image.asset(
              'images/powered_logo.png',
              height: AppSize.s27, // Specify height if needed
            ),
            const SizedBox(width: AppSize.s12), // Adjust spacing as needed
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: CustomTextStylesCommon.commonStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.granitegray,
                  ),
                  children: const [
                    TextSpan(text: 'symmetry'),
                    TextSpan(text: '.'),
                    TextSpan(text: 'care'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSize.s12), // Adjust spacing as needed
            SvgPicture.asset(
              'images/face_man.svg',
              height: AppSize.s30, // Specify height if needed
            ),
            const SizedBox(width: AppSize.s12), // Adjust spacing as needed
            RichText(
              text: TextSpan(
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.calandercolour,
                ),
                children: [
                  TextSpan(text: '(4088) 555-1234',style: TextStyle(decoration: TextDecoration.underline,color:
                  ColorManager.calandercolour)),
                ],
              ),
            ),
            const SizedBox(width: AppSize.s20), // Adjust spacing as needed
            Image.asset('images/logo.png',height: 27, ),
          ],
        ),
      ),
    );
  }
}
