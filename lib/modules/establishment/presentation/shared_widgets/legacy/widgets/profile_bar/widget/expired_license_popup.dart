import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';

class ExpiredLicensePopup extends StatefulWidget {
  final String title;
  final Widget child;
  const ExpiredLicensePopup(
      {super.key, required this.title, required this.child});

  @override
  State<ExpiredLicensePopup> createState() => _ExpiredLicensePopupState();
}

class _ExpiredLicensePopupState extends State<ExpiredLicensePopup> {
  // NEW: this popup had no auto-close-on-narrow-screen handling at all.
  // Below this width, the fixed 660px-wide dialog (with its 3-column
  // license table inside) has no comfortable room to sit — close the
  // popup instead of letting it render broken.
  static const double _kDesignWidth = 855;

  @override
  Widget build(BuildContext context) {
    // NEW: if the window/screen is resized below the popup's design
    // width, close the popup instead of letting it render broken.
    // Scheduled as a post-frame callback since we can't call
    // Navigator.pop synchronously inside build().
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s660,
        height: AppSize.s580,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                  color: ColorManager.blueprime,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorManager.white,
                        //size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
class ProfileBarNameLicenseStyle {
  static TextStyle customEditTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      decoration: TextDecoration.none,
    );
  }
}