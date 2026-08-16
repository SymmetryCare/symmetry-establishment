import 'package:flutter/material.dart';
import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
///stateless
class TableHeadingConst extends StatelessWidget {
  const TableHeadingConst({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s30,
      margin: EdgeInsets.symmetric(horizontal: AppMargin.m48,vertical: AppMargin.m10),
      padding: EdgeInsets.only(left: AppPadding.p100,right: AppPadding.p50),
      decoration: BoxDecoration(
        color: ColorManager.fmediumgrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
      //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              AppStringEM.srNo,
              style: TableHeading.customTextStyle(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: AppPadding.p90),
              child: Text(
                AppStringEM.docID,
                textAlign: TextAlign.start,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: AppPadding.p55),
              child: Text(
                AppStringEM.name,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p20),
              child: Text(
                AppStringEM.reminderthershold,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              AppStringEM.actions,
              textAlign: TextAlign.center,
              style: TableHeading.customTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }
}

