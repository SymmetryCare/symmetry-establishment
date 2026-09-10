import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

class CheckboxTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Function(bool)? onChanged;
  final bool? isInfoIconVisible;
  final Image? icon;

  const CheckboxTile({
    this.isInfoIconVisible = false,
    required this.title,
    this.initialValue = false,
    this.onChanged, this.icon,
  });

  @override
  _CheckboxTileState createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                unselectedWidgetColor:
                    ColorManager.blueprime, // border color when unchecked
                checkboxTheme: CheckboxThemeData(
                  side: BorderSide(
                      color: ColorManager.blueprime, width: 2), // border styling
                ),
              ),
              child: Checkbox(
                splashRadius: 0,
                activeColor: ColorManager.blueprime,
                value: _value,
                onChanged: (value) {
                  setState(() {
                    _value = value!;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(_value);
                  }
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style:
                  SMTextfieldHeadings.customTextStyle(context)
                ),
                const SizedBox(width: 10,),
                widget.isInfoIconVisible!
                    ? widget.icon ??
                    SvgPicture.asset(
                  'images/sm/sm_refferal/i_circle.svg',
                  height: IconSize.I20,
                  width: IconSize.I20,
                )
                    : const Offstage()
              ],
            ),
          ],
    );
  }
}

/// Use in Details Screen
class CheckboxTileDetails extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Function(bool)? onChanged;

  const CheckboxTileDetails({
    required this.title,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  _CheckboxTileDetailsState createState() => _CheckboxTileDetailsState();
}

class _CheckboxTileDetailsState extends State<CheckboxTileDetails> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          side: BorderSide(color: ColorManager.white),
          activeColor: ColorManager.blueprime,
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value!;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(_value);
            }
          },
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          widget.title,
          style: CustomTextStylesCommon.commonStyle(
              fontSize: AppSize.s12,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
      ],
    );
  }
}


class ExpCheckboxTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Function(bool)? onChanged;
  final bool? isInfoIconVisible;
  final Image? icon;

  const ExpCheckboxTile({
    this.isInfoIconVisible = false,
    required this.title,
    this.initialValue = false,
    this.onChanged, this.icon,
  });

  @override
  _ExpCheckboxTileState createState() => _ExpCheckboxTileState();
}

class _ExpCheckboxTileState extends State<ExpCheckboxTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  unselectedWidgetColor: ColorManager.blueprime,
                  checkboxTheme: CheckboxThemeData(
                    side: BorderSide(color: ColorManager.blueprime, width: 2),
                  ),
                ),
                child: Checkbox(
                  splashRadius: 0,
                  activeColor: ColorManager.blueprime,
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value!;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(_value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(  // Make text wrap if necessary
                child: Text(
                  widget.title,
                  style: SMTextfieldHeadings.customTextStyle(context),
                ),
              ),
            ],
    );
  }
}





class ExpCheckboxTileoo extends StatelessWidget {
  final String title;
  final bool value; // ✅ External state drives checkbox
  final ValueChanged<bool?>? onChanged;
  final bool? isInfoIconVisible;
  final Image? icon;

  const ExpCheckboxTileoo({
    Key? key,
    required this.title,
    required this.value,
    this.onChanged,
    this.isInfoIconVisible = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                unselectedWidgetColor: ColorManager.blueprime,
                checkboxTheme: CheckboxThemeData(
                  side: BorderSide(color: ColorManager.blueprime, width: 2),
                ),
              ),
              child: Checkbox(
                splashRadius: 0,
                activeColor: ColorManager.blueprime,
                value: value, // ✅ Controlled by parent
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: SMTextfieldHeadings.customTextStyle(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isInfoIconVisible!)
                    icon ??
                        SvgPicture.asset(
                          'images/sm/sm_refferal/i_circle.svg',
                          height: IconSize.I20,
                          width: IconSize.I20,
                        ),
                ],
              ),
            ),
          ],
    );
  }
}
