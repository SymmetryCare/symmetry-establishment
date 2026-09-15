import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';

class RoleManagerRoleRules extends StatelessWidget {
  const RoleManagerRoleRules({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Center(
          child: Text(
            ErrorMessageString.noRoleRules,
            style: AllNoDataAvailable.customTextStyle(context),
          ),
        ),
      ],
    );
  }
}
