import 'package:flutter/material.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/font_manager.dart';

///saloni///
class CustomIconButtonConst extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool? enabled;
  final Color? color;
  final double? paddingLeft;
  final double? paddingRight;

  const CustomIconButtonConst({
    this.text,
    this.icon,
    this.paddingLeft,
    this.paddingRight,
    required this.onPressed,
    this.width,
    this.color,
    Key? key, this.enabled, this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? AppSize.s145,
      height: height ?? 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ColorManager.blueprime,
          elevation: 4,
          padding: EdgeInsets.only(left: paddingLeft?? AppPadding.p8,right: paddingRight ?? AppPadding.p15, top: AppPadding.p5,bottom: AppPadding.p5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          icon != null
                  ? Icon(icon!,
                  color: ColorManager.white, size: IconSize.I20)
                  : const Offstage(),
             const SizedBox(width: 2,),
             Text(
                text!,
                style: BlueButtonTextConst.customTextStyle(context)
              ),
          ],
        ),
      ),
    );
  }
}




class CustomIconButtonConstzipcode extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final bool? enabled;
  final Color? color;
  final double? paddingLeft;
  final double? paddingRight;

  const CustomIconButtonConstzipcode({
    this.text,
    this.icon,
    this.paddingLeft,
    this.paddingRight,
    required this.onPressed,
    this.width,
    this.color,
    Key? key, this.enabled, this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Container(
            width: width ?? AppSize.s145,
            height: height ?? 32,
            // padding: EdgeInsets.symmetric(horizontal: AppPadding.p15, vertical: AppPadding.p5),
            decoration: BoxDecoration(
              color:color ?? ColorManager.blueprime,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
            Padding(
              padding: EdgeInsets.only(left: paddingLeft?? AppPadding.p8,right: paddingRight ?? AppPadding.p15, top: AppPadding.p5,bottom: AppPadding.p5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  icon != null
                      ? Icon(icon!,
                      color: ColorManager.white, size: IconSize.I20)
                      : const Offstage(),
                  const SizedBox(width: 2,),
                  Text(
                      text!,
                      style: BlueButtonTextConst.customTextStyle(context)
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
