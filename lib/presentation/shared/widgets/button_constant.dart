import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
///register screen button enroll,onboard ... etc
class CustomTextButton extends StatefulWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Future<void> Function() onPressed;

  const CustomTextButton({
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await widget.onPressed();
      },
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: FontSize.s13,
          fontWeight: FontWeight.w600,
          color: widget.textColor ?? ColorManager.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: widget.color ?? const Color(0xFF50B5E5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }
}

///button constant with transparent bg, colored text
class CustomButtonTransparentSM extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButtonTransparentSM({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: Container(
        height:AppSize.s30,
        width: AppSize.s100,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: CustomTextStylesCommon.commonStyle( fontSize: FontSize.s14,
              fontWeight: FontWeight.w500,
              color: ColorManager.blueprime,)
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
            backgroundColor: Colors.white,
            splashFactory: NoSplash.splashFactory,
            shadowColor: Colors.transparent,
            overlayColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: ColorManager.blueprime),
            ),
          ),
        ),
      ),
    );
  }
}

///
class CustomElevatedButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final TextStyle? style;
  final Widget? child;
  final int? loadingDuration;
  final bool isSelectShow;
  final bool isLoading;
  final Color disabledColor;
  final Color disabledTextColor;

  const CustomElevatedButton({
    Key? key,
    this.text,
    this.isSelectShow = true,
    required this.onPressed,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 150,
    this.height = 35.0,
    this.style,
    this.child,
    this.loadingDuration = 3,
    this.isLoading = false,
    this.disabledColor = const Color(0xFFBFBFBF),
    this.disabledTextColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mergedStyle = style ?? BlueButtonTextConst.customTextStyle(context);
    final spinnerSize = ((height < width ? height : width) * 0.6).clamp(12.0, 24.0);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isSelectShow && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ColorManager.blueprime,
          foregroundColor: textColor,
          disabledBackgroundColor: disabledColor,
          disabledForegroundColor: disabledTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: isLoading
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  vertical: paddingVertical,
                  horizontal: paddingHorizontal,
                ),
        ),
        child: isLoading
            ? SizedBox(
                height: spinnerSize,
                width: spinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(disabledTextColor),
                ),
              )
            : (text != null ? Text(text!, style: mergedStyle) : child),
      ),
    );
  }
}




///


class CustomElevatedButtonnull extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final TextStyle? style;
  final Widget? child;
  final int? loadingDuration;
  final bool isSelectShow;
  final bool isLoading;
  final Color disabledColor;
  final Color disabledTextColor;

  const CustomElevatedButtonnull({
    Key? key,
    this.text,
    this.isSelectShow = true,
    required this.onPressed,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 150,
    this.height = 35.0,
    this.style,
    this.child,
    this.loadingDuration = 3,
    this.isLoading = false,
    this.disabledColor = const Color(0xFFBFBFBF),
    this.disabledTextColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mergedStyle = style ?? BlueButtonTextConst.customTextStyle(context);
    final spinnerSize = ((height < width ? height : width) * 0.6).clamp(12.0, 24.0);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isSelectShow && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? ColorManager.blueprime,
          foregroundColor: textColor,
          disabledBackgroundColor: disabledColor,
          disabledForegroundColor: disabledTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: isLoading
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  vertical: paddingVertical,
                  horizontal: paddingHorizontal,
                ),
        ),
        child: isLoading
            ? SizedBox(
                height: spinnerSize,
                width: spinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(disabledTextColor),
                ),
              )
            : (text != null ? Text(text!, style: mergedStyle) : child),
      ),
    );
  }
}


/// Communication const
class CustomElevatedButtonCM extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final double elevation;
  final TextStyle? style;
  final Widget? child;
  final int? loadingDuration;
  final bool isSelectShow;
  final bool isLoading;
  final Color disabledColor;
  final Color disabledTextColor;

  const CustomElevatedButtonCM({
    Key? key,
    this.text,
    this.isSelectShow = true,
    required this.onPressed,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 140,
    this.height = 35.0,
    required this.elevation,
    this.style,
    this.child,
    this.loadingDuration = 3,
    this.isLoading = false,
    this.disabledColor = const Color(0xFFBFBFBF),
    this.disabledTextColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mergedStyle = style ?? BlueButtonTextConst.customTextStyle(context);
    final spinnerSize = ((height < width ? height : width) * 0.6).clamp(12.0, 24.0);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isSelectShow && !isLoading) ? onPressed : null,
        style: ButtonStyle(
          elevation: MaterialStateProperty.resolveWith<double>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) {
              return 0; // No elevation for these states
            }
            return elevation;
          }),
          backgroundColor: MaterialStateProperty.all(
              isLoading ? disabledColor : (color ?? ColorManager.blueprime)),
          foregroundColor: MaterialStateProperty.all(textColor),
          padding: MaterialStateProperty.all(
            isLoading
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(
                    vertical: paddingVertical,
                    horizontal: paddingHorizontal,
                  ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: spinnerSize,
                width: spinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(disabledTextColor),
                ),
              )
            : (text != null ? Text(text!, style: mergedStyle) : child),
      ),
    );
  }
}
