import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

/// Password field retained from the parent application's user-enrollment UI.
class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCopyPressed,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCopyPressed;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 354,
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        style: DocumentTypeDataStyle.customTextStyle(context),
        textAlignVertical: TextAlignVertical.center,
        cursorColor: ColorManager.black,
        textInputAction: TextInputAction.next,
        obscureText: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            bottom: AppPadding.p3,
            top: AppPadding.p5,
            left: AppPadding.p10,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorManager.containerBorderGrey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorManager.containerBorderGrey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.blueprime),
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.copy, size: IconSize.I14),
            onPressed: onCopyPressed,
          ),
        ),
      ),
    );
  }
}
