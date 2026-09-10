import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';

class CustomRadioListTile extends StatefulWidget {
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final String title;
  final TextStyle? style;

  const CustomRadioListTile({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.style,
  }) : super(key: key);

  @override
  _CustomRadioListTileState createState() => _CustomRadioListTileState();
}
class _CustomRadioListTileState extends State<CustomRadioListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
      child: Row(
        children: [
          Radio<String>(
           splashRadius: 0,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            value: widget.value,
            activeColor: ColorManager.blueprime,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          Text(
            widget.title,
            style: widget.style ?? DocumentTypeDataStyle.customTextStyle(context),
          ),
        const SizedBox( width: AppSize.s40,)
        ],
      ),
    );
  }
}

///eyebutton screen
/// ✅ Custom Radio Button Widget
class EyePageRadioButton extends StatefulWidget {
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final String title;
  final TextStyle? style;

  const EyePageRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.style,
  }) : super(key: key);

  @override
  _EyePageRadioButtonState createState() => _EyePageRadioButtonState();
}

class _EyePageRadioButtonState extends State<EyePageRadioButton> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value == widget.groupValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Row(
        children: [
          Radio<String>(
            splashRadius: 0,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            value: widget.value,
            activeColor: ColorManager.blueprime,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          Text(
            widget.title,
            style: (widget.style ?? DocumentTypeDataStyle.customTextStyle(context)).copyWith(
              color: isSelected ? ColorManager.blueprime : null,
            ),
          ),
          const SizedBox(width: AppSize.s40),
        ],
      ),
    );
  }
}


