import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:provider/provider.dart';
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
         //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Radio<String>(
           splashRadius: 0,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            value: widget.value,
            activeColor: ColorManager.bluebottom,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          // const SizedBox(width: 0),
          Text(
            widget.title,
            style: widget.style ?? DocumentTypeDataStyle.customTextStyle(context),
          ),
        SizedBox( width: AppSize.s40,)
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
            activeColor: ColorManager.bluebottom,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
          ),
          Text(
            widget.title,
            style: (widget.style ?? DocumentTypeDataStyle.customTextStyle(context)).copyWith(
              color: isSelected ? ColorManager.bluebottom : null,
            ),
          ),
          const SizedBox(width: AppSize.s40),
        ],
      ),
    );
  }
}



/// SM
class CustomRadioListTileSM extends StatefulWidget {
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final String title;
  final TextStyle? style;
  const CustomRadioListTileSM({super.key, required this.value, this.groupValue, required this.onChanged, required this.title, this.style});

  @override
  State<CustomRadioListTileSM> createState() => _CustomRadioListTileSMState();
}

class _CustomRadioListTileSMState extends State<CustomRadioListTileSM> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Radio<String>(
            splashRadius: 0,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            value: widget.value,
            groupValue: widget.groupValue,
            onChanged: widget.onChanged,
            activeColor: ColorManager.bluebottom,
          ),
          // const SizedBox(width: 0),
          Text(
            widget.title,
            style: widget.style ?? DocumentTypeDataStyle.customTextStyle(context),
          ),
          SizedBox( width: AppSize.s40,)
        ],
      ),
    );
  }
}




// CustomRadioListTileSMp lived here too. It is unused in Establishment and its
// only dependency was the scheduler module's SmIntakeProviderManager, which is
// not part of this repo, so it was dropped with the rest of that module.
