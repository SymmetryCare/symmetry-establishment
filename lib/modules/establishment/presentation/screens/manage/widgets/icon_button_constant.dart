import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
///done by saloni
class IconButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final IconData? iconData1;
  final String buttonText;
  final Color? iconColor;
  final Color? textColor;
  final Function onPressed;
  final double? width;

  const IconButtonWidget({
    Key? key,
    this.iconData,
    this.width,
    required this.buttonText,
    required this.onPressed,
    this.iconColor,
    this.textColor,
    this.iconData1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color resolvedIconColor = iconColor ?? ColorManager.blueprime;
    final Color resolvedTextColor = textColor ?? ColorManager.blueprime;

    return Container(
      height:30,
      width: width,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: 15), // Adjust vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(width: 1, color: ColorManager.calandercolour),
          ),
        ),
        onPressed: () => onPressed(),
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconData == null ? const Offstage():
            Icon(
              iconData,
              color: resolvedIconColor,
              size: 15,
            ),
            iconData == null ? const Offstage(): const SizedBox(
              width: 20,
            ),
            Text(
              buttonText,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: resolvedTextColor,
              ),
            ),
            iconData1 == null ? const Offstage():
            const SizedBox(
              width: 9,
            ),
            iconData1 == null ? const Offstage():
            Icon(
              iconData1,
              color: resolvedIconColor,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class BorderIconTButton extends StatelessWidget {
  final IconData iconData;
  final String buttonText;
  final VoidCallback onPressed;
  const BorderIconTButton({super.key, required this.iconData, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: AppSize.s30,
      decoration: BoxDecoration(border: Border.all(
          color: ColorManager.blueprime
      ),borderRadius:BorderRadius.circular(8)),
      child: InkWell(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconData == null ? const Offstage():
              Icon(
                iconData,
                color: ColorManager.blueprime,
                size: 18,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 200,
              ),
              Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize:12,
                  color: ColorManager.blueprime,
                ),
              ),

            ],),
        ),
      ),
    );
  }
}


class BorderIconButton extends StatelessWidget {
  final IconData iconData;
  final String buttonText;
  final VoidCallback onPressed;
  const BorderIconButton({super.key, required this.iconData, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s28,
      width: AppSize.s90,
      decoration: BoxDecoration(border: Border.all(
          color: ColorManager.blueprime
      ),borderRadius:BorderRadius.circular(8)),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconData == null ? const Offstage():
              Icon(
                iconData,
                color: ColorManager.blueprime,
                 size: 18,
              ),
             const SizedBox(width: 10,),
              Text(
                buttonText,
                style: TransparentButtonTextConst.customTextStyle(context)
              ),

          ],),
        ),
      ),
    );
  }
}

class BorderIconProfileButton extends StatelessWidget {
  final IconData iconData;
  final String buttonText;
  final double buttonWidth;
  final VoidCallback onPressed;
  const BorderIconProfileButton({super.key, required this.iconData, required this.buttonText, required this.onPressed, required this.buttonWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s30,
      width: buttonWidth,
      decoration: BoxDecoration(color: Colors.white,
          border: Border.all(
              color: ColorManager.blueprime
          ),borderRadius:BorderRadius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconData == null ? const Offstage():
              Icon(
                iconData,
                color: ColorManager.blueprime,
                size: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 200,
              ),
              Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize:12,
                  color: ColorManager.blueprime,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 200,
              ),
            ],),
        ),
      ),
    );
  }
}

