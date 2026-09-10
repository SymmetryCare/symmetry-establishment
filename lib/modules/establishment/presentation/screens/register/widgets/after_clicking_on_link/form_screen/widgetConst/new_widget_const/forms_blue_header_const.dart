import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

/// Reusable blue header container for form screens (simple centered text).
class FormsBlueHeaderConst extends StatelessWidget {
  final String text;

  const FormsBlueHeaderConst({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD7EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: ZoneDataStyle.customTextStyle(context).copyWith(height: 1.5),
      ),
    );
  }
}

/// Reusable blue header container for form screens with bullet point list.
class FormsBlueHeaderBulletsConst extends StatelessWidget {
  final List<String> bullets;

  const FormsBlueHeaderBulletsConst({super.key, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD7EEF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets.asMap().entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.key != 0)
                const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '• ',
                      style: DefineWorkWeekStyle.customTextStyle(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.start,
                      style: ZoneDataStyle.customTextStyle(context).copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Reusable blue filled Save button for form screens.
/// Shows a [CircularProgressIndicator] when [isLoading] is true.
class FormSaveButtonConst extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const FormSaveButtonConst({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      width: 117,
      height: 30,
      text: 'Save',
      style: BlueButtonTextConst.customTextStyle(context),
      borderRadius: 12,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}

/// Reusable white outlined Next/Previous button for form screens.
class FormOutlineButtonConst extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const FormOutlineButtonConst({
    super.key,
    required this.onPressed,
    this.text = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 117,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: ColorManager.blueprime,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: TransparentButtonTextConst.customTextStyle(context),
        ),
      ),
    );
  }
}

