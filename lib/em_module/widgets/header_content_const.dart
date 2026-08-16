import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import '../../../../app/resources/value_manager.dart';

class HeaderContentConst extends StatelessWidget {
  final String heading;
  final Widget content;
  final bool isAsterisk;
  final bool isDoc;
  final TextStyle? styleHeading;
  double? marginVertical;
   HeaderContentConst({
    super.key,
    required this.heading,
    required this.content,
    this.styleHeading,
    this.isAsterisk = false, // Default value is false
    this.isDoc = false,
    this.marginVertical = 6,// Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(vertical: marginVertical!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using RichText for heading with optional red asterisk
          RichText(
            text: TextSpan(
              text: heading, // Main heading text
              style: styleHeading ?? AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                if (isAsterisk)
                  TextSpan(
                    text: ' *', // Asterisk
                    style: AllPopupHeadings
                        .customTextStyle(context)
                        ?.copyWith(color: Colors.red), // Red color for asterisk
                  ),
                if (isDoc)
                  TextSpan(
                    text: ' Upload document upto 20MB only',
                    style: CommonErrorMsg.customTextStyle(context), // Custom style
                  ),
              ],
            )
            ,
            // text: TextSpan(
            //   text: heading, // Main heading text
            //   style: AllPopupHeadings.customTextStyle(context), // Main style
            //   children: isAsterisk
            //       ? [
            //     TextSpan(
            //       text: ' *', // Asterisk
            //       style: AllPopupHeadings
            //           .customTextStyle(context)?.copyWith(color: Colors.red), // Red color for asterisk
            //     ),
            //   ]
            //       : isDoc ?
            //       [
            //         TextSpan(
            //           text: 'upload upto 20MB',
            //             style: CommonErrorMsg.customTextStyle(context), // Red color for asterisk
            //         ),
            //       ]
            //   : [], // Empty if isAsterisk is false
            // ),
          ),
          const SizedBox(height: AppSize.s5),

          /// Content widget (e.g., upload doc)
          content,
        ],
      ),
    );
  }
}