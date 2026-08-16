import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/widgets/widgets/custom_icon_button_constant.dart';

class CiTempalets extends StatefulWidget {
  const CiTempalets({super.key});

  @override
  State<CiTempalets> createState() => _CiTempaletsState();
}

class _CiTempaletsState extends State<CiTempalets> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppPadding.p10,right: AppPadding.p65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconButtonConst(
                    icon: Icons.add,
                    text: AppStringEM.addTemplate, onPressed: () {},
                    ),
              ],
            ),
          ),
          Center(child:
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p120),
            child: Text(
              ErrorMessageString.noTemplate,
              style:  AllNoDataAvailable.customTextStyle(context),),
          )),
        ],
      ),
    );
  }
}
