import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

///done by saloni
///button constant for circularborder with text and with/without icon
class CustomIconButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final FontWeight? textWeight;
  final double? textSize;
  final double? borderRadius;
  final bool isNotPopUpButton;
  final Future<void> Function() onPressed;

  const CustomIconButton({
    this.textColor,
    required this.text,
    this.icon,
    required this.onPressed,
    Key? key,
    this.color,
    this.textWeight,
    this.textSize,
    this.borderRadius,
    required this.isNotPopUpButton,
  }) : super(key: key);

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              if (widget.isNotPopUpButton) {
                setState(() => isLoading = true);
              }
              try {
                await widget.onPressed();
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        backgroundColor:
            widget.color == null ? const Color(0xFF50B5E5) : widget.color,
        disabledBackgroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon!, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: widget.textSize == null
                            ? FontSize.s14
                            : widget.textSize,
                        fontWeight: widget.textWeight == null
                            ? FontWeight.w600
                            : widget.textWeight,
                        color: widget.textColor == null
                            ? ColorManager.white
                            : widget.textColor)),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

///button constant with white bg, colored text
class CustomButtonTransparent extends StatefulWidget {
  final String text;
  VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? verticalPadding;
  final double? borderRadius;
  final TextStyle? style;

  CustomButtonTransparent({
    required this.text,
    required this.onPressed,
    this.height = AppSize.s35,
    this.width = AppSize.s100,
    this.verticalPadding,
    this.style,
    Key? key,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<CustomButtonTransparent> createState() =>
      _CustomButtonTransparentState();
}

class _CustomButtonTransparentState extends State<CustomButtonTransparent> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator(
            color: ColorManager.blueprime,
          )
        : SizedBox(
            height: widget.height,
            width: widget.width,
            child: OutlinedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  widget.onPressed();
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: widget.verticalPadding ?? 10),
                backgroundColor: ColorManager.white,
                overlayColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                ),
                side: const BorderSide(color: Color(0xFF50B5E5)),
              ),
              child: Text(widget.text,
                  style: widget.style ??
                      TransparentButtonTextConst.customTextStyle(context)),
            ),
          );
  }
}

class CustomeFormCancelButton extends StatefulWidget {
  final String text;
  VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? borderRadius;
  final TextStyle? style;
  CustomeFormCancelButton({
    required this.text,
    required this.onPressed,
    this.height = AppSize.s35,
    this.width = AppSize.s100,
    this.style,
    Key? key,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<CustomeFormCancelButton> createState() =>
      _CustomeFormCancelButtonState();
}

class _CustomeFormCancelButtonState extends State<CustomeFormCancelButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        onPressed: () async {
          widget.onPressed();
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          backgroundColor: ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            side: const BorderSide(color: Color(0xFF50B5E5)),
          ),
        ),
        child: Text(widget.text,
            style: widget.style ??
                TransparentButtonTextConst.customTextStyle(context)),
      ),
    );
  }
}

class CustomeTransparentAddShift extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  const CustomeTransparentAddShift(
      {super.key,
      required this.text,
      required this.onPressed,
      this.icon,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
          height: height ?? MediaQuery.of(context).size.height / 30,
          width: width ?? MediaQuery.of(context).size.width / 17,
          decoration: BoxDecoration(
              border: Border.all(color: ColorManager.blueprime),
              borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.only(right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.add,
                  color: ColorManager.blueprime, size: IconSize.I14),
              Text(
                text,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.blueprime,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          )),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color backgroundColor; // Added parameter for background color
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final TextStyle? style;
  final Widget? child;
  final bool isLoading;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;

  const CustomButton({
    Key? key,
    this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF50B5E5), // Default background color
    this.textColor = Colors.white,
    this.borderRadius = 14.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 50,
    this.height = 50.0,
    this.style,
    this.child,
    this.isLoading = false,
    this.disabledBackgroundColor = const Color(0xFFBFBFBF),
    this.disabledTextColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: textColor,
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,
    );
    final mergedTextStyle = defaultTextStyle.merge(style);
    final spinnerSize =
        ((height < width ? height : width) * 0.6).clamp(12.0, 24.0);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor, // Utilizing the backgroundColor parameter
          foregroundColor: textColor,
          disabledBackgroundColor: disabledBackgroundColor,
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
            : (text != null
                ? Text(text!,
                    textAlign: TextAlign.center, style: mergedTextStyle)
                : child),
      ),
    );
  }
}

///CustomTitleButton
class CustomTitleButton extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const CustomTitleButton({
    required this.height,
    required this.width,
    required this.onPressed,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AppClickableWidget(
        onTap: onPressed,
        onHover: (bool val) {},
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFFFFFF),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x52000000),
                      offset: Offset(0, 3),
                      blurRadius: 2,
                      spreadRadius: -1,
                    ),
                  ],
                )
              : null,
          child: Text(
            text,
            style: GoogleFonts.firaSans(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
              color: isSelected
                  ? const Color(0xFF0096C8)
                  : const Color(0xFF687986),
            ),
          ),
        ),
      ),
    );
  }
}

/// DZone button
class DZoneButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final double? height;
  const DZoneButton(
      {super.key, required this.isSelected, required this.onTap, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height ?? AppSize.s36,
      height: height ?? AppSize.s36,
      decoration: BoxDecoration(
        color: isSelected ? ColorManager.blueprime : ColorManager.whiteGrey,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Center(
          child: Text(
            'DZ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w600,
              color: isSelected ? ColorManager.white : ColorManager.mediumgrey,
            ),
          ),
        ),
      ),
    );
  }
}

///sm
class CustomTitleButtonsm extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const CustomTitleButtonsm({
    required this.height,
    required this.width,
    required this.onPressed,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isSelected ? 3 : 0,
      borderRadius: BorderRadius.circular(12),
      color: ColorManager.white,
      child: AppClickableWidget(
        onTap: onPressed,
        onHover: (bool val) {},
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff51B5E6),
                      Color(0xff008ABD),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              : null,
          child: Text(
            text,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w700,
              color: isSelected ? ColorManager.white : const Color(0xFF2EA3D4),
            ),
          ),
        ),
      ),
    );
  }
}

///emr
class CustomTitleButtonemr extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const CustomTitleButtonemr({
    required this.height,
    required this.width,
    required this.onPressed,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isSelected ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      color: ColorManager.white,
      child: AppClickableWidget(
        onTap: onPressed,
        onHover: (bool val) {},
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff51B5E6),
                      Color(0xff008ABD),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              : null,
          child: Text(
            text,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w700,
              color: isSelected ? ColorManager.white : const Color(0xFF2EA3D4),
            ),
          ),
        ),
      ),
    );
  }
}

class SkipButtonTransparent extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? borderRadius;
  final TextStyle? style;

  const SkipButtonTransparent({
    required this.text,
    required this.onPressed,
    this.height = AppSize.s35,
    this.width = AppSize.s100,
    this.style,
    this.borderRadius = 12,
    Key? key,
  }) : super(key: key);

  @override
  State<SkipButtonTransparent> createState() => _SkipButtonTransparentState();
}

class _SkipButtonTransparentState extends State<SkipButtonTransparent> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator(color: ColorManager.blueprime)
        : SizedBox(
            height: widget.height,
            width: widget.width,
            child: ElevatedButton(
              onPressed: () {
                print("🔹 CustomButtonTransparent: ${widget.text} tapped");
                setState(() {
                  isLoading = true;
                });

                try {
                  widget.onPressed(); // ✅ Correctly call
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                backgroundColor: ColorManager.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 12),
                  side: const BorderSide(color: Color(0xFF50B5E5)),
                ),
              ),
              child: Text(
                widget.text,
                style: widget.style ??
                    TransparentButtonTextConst.customTextStyle(context),
              ),
            ),
          );
  }
}

/// The "+ Add New" button used by the Qualifications tabs: white fill, blue
/// outline, blue label — not the filled blue [CustomIconButtonConst] used
/// elsewhere in the app. A thin wrapper over [OutlinedActionButton], which
/// carries the shared look so in-card actions can use it too.
class AddNewOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double width;
  final double height;

  const AddNewOutlinedButton({
    super.key,
    required this.onPressed,
    this.width = 117,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedActionButton(
      label: '+ ${AppStringHr.addNew}',
      onPressed: onPressed,
      width: width,
      height: height,
    );
  }
}

/// The outlined button look shared by "+ Add New" and the actions inside the
/// cards: white fill, #008ABD outline and label, 11px corners and a soft
/// drop shadow. Sized down (and given an icon) for in-card use.
class OutlinedActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;

  /// Icon shown before the label.
  final IconData? icon;

  /// Icon shown after the label — e.g. the eye on "Void Check".
  final IconData? trailingIcon;

  const OutlinedActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 117,
    this.height = 45,
    this.fontSize = 16,
    this.icon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF008ABD);
    return Container(
      width: width,
      height: height,
      // The soft drop shadow from the design. Painted here rather than via
      // the button's own elevation so it stays a rounded shadow that matches
      // the 12px corner radius exactly.
      // Figma: box-shadow 0px 2px 2px rgba(0, 0, 0, 0.25).
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: blue,
          side: const BorderSide(color: blue),
          padding: EdgeInsets.zero,
          // Flat, like the "Select Document" field it sits next to.
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          // Figma: Fira Sans 400, 16/19, #008ABD.
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            height: 19 / 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2, color: blue),
              SizedBox(width: fontSize / 2),
            ],
            Text(label),
            if (trailingIcon != null) ...[
              SizedBox(width: fontSize / 2),
              Icon(trailingIcon, size: fontSize + 2, color: blue),
            ],
          ],
        ),
      ),
    );
  }
}
