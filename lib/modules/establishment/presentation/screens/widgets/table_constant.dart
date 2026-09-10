import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';

import 'package:symmetry_establishment/app/resources/value_manager.dart';

class TableHeadConstant extends StatelessWidget {
  final List<TableHeadItem> items;

  const TableHeadConstant({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: AppPadding.p30,),
      height: AppSize.s30,
      decoration: BoxDecoration(
        color: ColorManager.fmediumgrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items.map((item) {
          return Expanded(
            child: Center(
              child: Text(
                item.text,
                textAlign: item.textAlign,
                style:  TableHeading.customTextStyle(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TableHeadItem {
  final String text;
  final TextAlign textAlign;


  const TableHeadItem({
    required this.text,
    this.textAlign = TextAlign.start,
  });
}
