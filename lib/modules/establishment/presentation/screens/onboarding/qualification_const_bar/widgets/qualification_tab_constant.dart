import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

class QualificationActionButtons extends StatelessWidget {
  final VoidCallback onRejectPressed;
  final VoidCallback onApprovePressed;
  final bool? approve;
  final bool? isBackColor;

  const QualificationActionButtons({super.key, required this.onRejectPressed,
    required this.onApprovePressed,this.approve,
    this.isBackColor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        approve == false
            ? Container(
          width: AppSize.s90,
          // ✅ Reject switched from ElevatedButton to OutlinedButton to
          // match the flat (no elevation/fill) style used in Health Record.
          child: OutlinedButton(
            onPressed: onRejectPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor:ColorManager.blueprime,
              side: BorderSide(color: ColorManager.blueprime,),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
                'Reject',
                style: TransparentButtonTextConst.customTextStyle(context)
            ),
          ),
        )
            : approve == false
            ? Container(
          width: AppSize.s90,
          child: Text(
            'Rejected',
            textAlign: TextAlign.center,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
              color: ColorManager.mediumgrey,
            ),
          ),
        )
            : const SizedBox(width: AppSize.s90),
        SizedBox(width: MediaQuery.of(context).size.width / 75),
        approve == false
            ? Container(
          width: AppSize.s90,
          child: ElevatedButton(
            onPressed: onApprovePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isBackColor!?Colors.white:ColorManager.blueprime,
              foregroundColor: isBackColor!?ColorManager.blueprime:Colors.white,
              side: BorderSide(color: isBackColor!? ColorManager.blueprime:ColorManager.blueprime,),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Approve',
              style: isBackColor!? TransparentButtonTextConst.customTextStyle(context) : BlueButtonTextConst.customTextStyle(context),
            ),
          ),
        )
            : approve == true
            ? Container(
          width: AppSize.s90,
          child: Text(
            'Approved',
            textAlign: TextAlign.center,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
              color: ColorManager.blueprime,
            ),
          ),
        )
            : const SizedBox(width: AppSize.s90),
      ],
    );
  }
}