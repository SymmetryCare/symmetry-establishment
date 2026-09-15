import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class DialogueTemplate extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final Color? color;
  final List<Widget> body;
  final Widget bottomButtons;
  VoidCallback? onClear;
  bool? isScrollable;
   DialogueTemplate(
      {super.key,
        this.onClear,
        this.color,
        this.isScrollable = false,
      required this.width,
      required this.height,
      required this.body,
      required this.bottomButtons,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color ?? ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: AppPadding.p2, horizontal: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      title,
                      style:PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: onClear == null? () {
                      Navigator.pop(context);
                    }:onClear,
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            isScrollable! ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p18,
                  horizontal: AppPadding.p18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: body,
                ),
              ),
            )  :Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p18,
                horizontal: AppPadding.p18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: body,
              ),
            ),
            SizedBox(height:isScrollable!? 0:AppSize.s15),
            ///button
            Padding(
              padding:  EdgeInsets.symmetric(vertical: isScrollable! ?AppPadding.p10 :AppPadding.p20),
              child: Center(
                child: bottomButtons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Termination template
class TerminationDialogueTemplate extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final List<Widget> body;
  final Widget bottomButtons;
  const TerminationDialogueTemplate(
      {super.key,
        required this.width,
        required this.height,
        required this.body,
        required this.bottomButtons,
        required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fixed blue container (not scrollable)
            Container(
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppPadding.p18,
                    horizontal: AppPadding.p18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...body,
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSize.s15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
              child: Center(
                child: bottomButtons,
              ),
            ),
          ],
        )
        ,
      ),
    );
  }
}
