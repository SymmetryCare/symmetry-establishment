import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';

import 'package:symmetry_establishment/app/resources/font_manager.dart';

class FailedPopup extends StatelessWidget {
  final String text;
  const FailedPopup({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: 450,
        height: 250,
        body: [
          const Center(
            child: Icon(
              Icons.cancel,
              color: Colors.red, // Icon color
              size: 30,
            ),
          ),
          const SizedBox(height: 20,),
          Text(text,
            textAlign: TextAlign.center,
            style: CustomTextStylesCommon.commonStyle(
            fontWeight: FontWeight.w600,
            fontSize: FontSize.s15,
            color: ColorManager.mediumgrey
          ),),

        ],
        bottomButtons: CustomElevatedButton(onPressed: (){
          Navigator.pop(context);
        },text: 'OK',height: 30,width: 90,), title: 'Error');
  }
}
