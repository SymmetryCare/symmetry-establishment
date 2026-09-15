import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/home_hr.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

class ConfirmationPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onConfirm; // Change this to support async
  final bool? loadingDuration;
  final String title;
  final String containerText;
  final bool loading;

  const ConfirmationPopup({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.loadingDuration,
    required this.title,
    required this.containerText,
    this.loading = false,
  });

  @override
  State<ConfirmationPopup> createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends State<ConfirmationPopup> {
  bool _isLoading = false; // Local loading state

  static const Color _confirmationBlue = Color(0xFF0B8CBF);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s350,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 70,
              color: _confirmationBlue,
              child: Center(
                child: SvgPicture.asset(
                  'images/confirmation_question_icon.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.textBlack,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.containerText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      color: ColorManager.grey,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppSize.s105,
                        height: AppSize.s30,
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: ColorManager.white,
                            foregroundColor: ColorManager.lightGrey,
                            side: BorderSide(
                                color: ColorManager.greyShade300, width: 1.2),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Complete',
                            style: TextStyle(
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.lightGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: AppSize.s105,
                        height: AppSize.s30,
                        child: CustomElevatedButton(
                          width: AppSize.s105,
                          height: AppSize.s30,
                          borderRadius: AppSize.s30 / 2,
                          color: _confirmationBlue,
                          text: 'Confirm',
                          isLoading: _isLoading,
                          onPressed: () async {
                            setState(() {
                              _isLoading = true; // Set loading state to true
                            });
                            await widget
                                .onConfirm(); // Await the async confirmation
                            setState(() {
                              _isLoading = false; // Reset loading state
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///success popup
class SuccessPopup extends StatelessWidget {
  const SuccessPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s300,
        height: AppSize.s150,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Success",
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text('Successfully Enrolled!\nThank You.',
                    textAlign: TextAlign.center,
                    style: ConstTextFieldRegister.customTextStyle(context)),
              ),
            ),
            const Spacer(),

            //
          ],
        ),
      ),
    );
  }
}
/////
