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

  CustomTextButton({
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
    // return isLoading
    //     ? Padding(
    //       padding: const EdgeInsets.only(right: 40),
    //       child: SizedBox(
    //             height: 20,
    //             width: 20,
    //             child: CircularProgressIndicator(color: ColorManager.blueprime),
    //           ),
    //     )
    //     :
   return Container(
      width: AppSize.s110,
      margin:
      const EdgeInsets.only(right: AppMargin.m5),
          child: ElevatedButton(
                onPressed: () async {
         // setState(() => isLoading = true);
          await widget.onPressed();
         // setState(() => isLoading = false);
                },
                child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w600,
            color: widget.textColor ?? ColorManager.white,
          ),
                ),
                style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          backgroundColor: widget.color ?? Color(0xFF50B5E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
                ),
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
      elevation: 4,
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
            padding: EdgeInsets.symmetric(horizontal: 23, vertical: 10),
            backgroundColor: Colors.white,
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
class CustomElevatedButton extends StatefulWidget {
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
  bool? isSelectShow;

   CustomElevatedButton({
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
    this.child,  this.loadingDuration = 3,
  }) : super(key: key);

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  bool _isLoading = false;
  bool  _isSubmitting= false;

  void _handlePress() {

    // setState(() {
    //   _isLoading = true;
    // });

    widget.onPressed();
    // Future.delayed(Duration(seconds: widget.loadingDuration!), () {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _isLoading ? Center(
        child: SizedBox(child: SizedBox(
          width: 25,
            height: 25,
            child: CircularProgressIndicator(color: ColorManager.blueprime,))),
      ) :ElevatedButton(
        onPressed: widget.isSelectShow! ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color ?? ColorManager.bluebottom,
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: widget.paddingVertical,
            horizontal: widget.paddingHorizontal,
          ),
        ),
        child: widget.text != null
            ? Text(widget.text!,
            style: widget.style ?? BlueButtonTextConst.customTextStyle(context))
            : widget.child,
      ),
    );
  }
}




///


class CustomElevatedButtonnull extends StatefulWidget {
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
  bool? isSelectShow;

  CustomElevatedButtonnull({
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
    this.child,  this.loadingDuration = 3,
  }) : super(key: key);

  @override
  State<CustomElevatedButtonnull> createState() => _CustomElevatedButtonnullState();
}

class _CustomElevatedButtonnullState extends State<CustomElevatedButtonnull> {
  bool _isLoading = false;
  bool  _isSubmitting= false;

  void _handlePress() {

    // setState(() {
    //   _isLoading = true;
    // });

    widget.onPressed;
    // Future.delayed(Duration(seconds: widget.loadingDuration!), () {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _isLoading ? Center(
        child: SizedBox(child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(color: ColorManager.blueprime,))),
      ) :ElevatedButton(
        onPressed: widget.isSelectShow! ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color ?? ColorManager.bluebottom,
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            vertical: widget.paddingVertical,
            horizontal: widget.paddingHorizontal,
          ),
        ),
        child: widget.text != null
            ? Text(widget.text!,
            style: widget.style ?? BlueButtonTextConst.customTextStyle(context))
            : widget.child,
      ),
    );
  }
}


/// Communication const
class CustomElevatedButtonCM extends StatefulWidget {
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
  bool? isSelectShow;

  CustomElevatedButtonCM({
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
    this.child,  this.loadingDuration = 3,
  }) : super(key: key);

  @override
  State<CustomElevatedButtonCM> createState() => _CustomElevatedButtonCMState();
}

class _CustomElevatedButtonCMState extends State<CustomElevatedButtonCM> {
  bool _isLoading = false;
  bool  _isSubmitting= false;

  void _handlePress() {

    // setState(() {
    //   _isLoading = true;
    // });

    widget.onPressed();
    // Future.delayed(Duration(seconds: widget.loadingDuration!), () {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _isLoading ? Center(
        child: SizedBox(child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(color: ColorManager.blueprime,))),
      )
          :ElevatedButton(
        onPressed: widget.isSelectShow! ? widget.onPressed : null,
          style: ButtonStyle(
            elevation: MaterialStateProperty.resolveWith<double>((states) {
              if (states.contains(MaterialState.hovered) ||
                  states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.pressed)) {
                return 0; // No elevation for these states
              }
              return widget.elevation ?? 0;
            }),

            backgroundColor: MaterialStateProperty.all(
                widget.color ?? ColorManager.bluebottom),
            foregroundColor: MaterialStateProperty.all(widget.textColor),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                vertical: widget.paddingVertical,
                horizontal: widget.paddingHorizontal,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          ),
        child: widget.text != null
            ? Text(widget.text!,
            style: widget.style ?? BlueButtonTextConst.customTextStyle(context))
            : widget.child,
      ),
    );
  }
}
