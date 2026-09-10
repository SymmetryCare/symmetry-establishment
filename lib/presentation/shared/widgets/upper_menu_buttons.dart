import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';

typedef void OnManuButtonTapCallBack(int index);

class UpperMenuButtons extends StatelessWidget {
  const UpperMenuButtons(
      {super.key,
      required this.onTap,
      required this.index,
      required this.grpIndex,
      required this.heading});
  final OnManuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return AppClickableWidget(
      onTap: () {
        onTap(index);
      },
      onHover: (bool val) {},
      child: Column(
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w700,
              color: grpIndex == index
                  ? ColorManager.blueprime
                  : const Color(0xff686464),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppMargin.m10),
            width: AppSize.s150,
            height: AppSize.s2,
            color:
                grpIndex == index ? ColorManager.blueprime : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

///org doc subtabbar const
class TabWidget extends StatelessWidget {
  final List<String> tabNames;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabWidget({
    required this.tabNames,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  double _getTextWidth(String text, TextStyle textStyle) {
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // Calculates the width
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 50,  // Adjust the height as per your requirement
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabNames.length, (index) {
          final textWidth = _getTextWidth(tabNames[index], const TextStyle(fontSize: 16));

          return InkWell(
            highlightColor: const Color(0xFFF2F9FC),
            hoverColor: const Color(0xFFF2F9FC),
            onTap: () => onTabSelected(index),
            child: Container(
              height: 50,  // Adjust the height as per your requirement
              width: textWidth + 20,  // Add some padding to the width
              child: Column(
                children: [
                  Text(
                    tabNames[index],
                    style: TextStyle(
                      fontSize: 16,  // Customize font size as needed
                      fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selectedIndex == index
                      ? const Divider(color: Color(0xFF0000FF), thickness: 2)
                      : const Offstage(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
