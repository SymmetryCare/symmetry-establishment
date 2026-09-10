import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';


class ProfileBarClipConst extends StatelessWidget {
   String? text;
  String textOval;
  final Color containerColor;
  final VoidCallback? onTap;

   ProfileBarClipConst({
    Key? key,
    required this.text,
    required this.containerColor,
    required this.textOval, this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        children: [
          Text(
            text!,
            style: ProfileBarLastColText.profileTextStyle(context),
          ),
          const SizedBox(width: 20),
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular( 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                height: 20,
                width: 21,
                decoration: BoxDecoration(
                  color: containerColor,
                ),
                child: Center(
                  child: Text(
                    textOval,
                    textAlign: TextAlign.center,
                    style: ProfileBarClipText.profileTextStyle(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
///
class ProfileBarPhoneCmtConst extends StatelessWidget {
  final String? phoneNo;
  List<TextInputFormatter>? inputFormatters;

  ProfileBarPhoneCmtConst({super.key, required this.phoneNo});

  // Method to format the phone number
  String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "---------------   ";
    }

    // Example of formatting (XXX) XXX-XXXX
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6, 10)}';
    } else {
      return phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 14,
          width: 90,
          child: Text(
            formatPhoneNumber(phoneNo),
            style: ProfileBarTextBoldStyle.customEditTextStyle()
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        // Container(
        //   height: 14,
        //   width: 16.67,
        //   child: Icon(
        //     Icons.phone,
        //     color: ColorManager.green,
        //     size: IconSize.I14,
        //   ),
        // ),
        // SizedBox(
        //   width: 15,
        // ),
        // Container(
        //   height: 14,
        //   width: 16.67,
        //   child: Icon(
        //     Icons.message,
        //     color: ColorManager.blueprime,
        //     size: IconSize.I14,
        //   ),
        // )
      ],
    );
  }
}
