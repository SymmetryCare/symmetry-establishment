import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/offer_letter_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/offer_letter_html_data/offer_letter_html.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/multi_step_form.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/offer_letter_description_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/verify_user_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';

class OnBoardingWelcome extends StatefulWidget {
  static const String routeName = AppString.onboardingWelcome;
  const OnBoardingWelcome({
    Key? key,
  }) : super(key: key);

  @override
  State<OnBoardingWelcome> createState() => _OnBoardingWelcomeState();
}

class _OnBoardingWelcomeState extends State<OnBoardingWelcome> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return CustomScrollbar(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p10),
                child: SizedBox(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                          border: const Border(
                            bottom:
                            BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                            maxWidth: 1202, maxHeight: 500),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'images/doctors.png',
                                    width: MediaQuery.of(context).size.width /
                                        3,
                                    height:
                                    MediaQuery.of(context).size.height /
                                        1.9,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Welcome to Prohealth Onboarding Wizard',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff686464),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizeConst.A20),
                                  const Text(
                                    AppConfig.version,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff686464),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizeConst.A20),
                                  const Text(
                                    'Please go through each section and fill valid information',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff686464),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizeConst.A20),
                                  Container(
                                    width: 140,
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const VerifyUserpopup();
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xff50B5E5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Start',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomBarRow(),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final Widget? labelWidget;
  final IconData icon;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.icon,
    this.labelWidget,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        label: labelWidget,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffB1B1B1)),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}


class OnBoardingCongratulation extends StatelessWidget {
  final int employeeId;
  final int depID;
  final int tempalteId;
  final int enrollId;
  const OnBoardingCongratulation({
    super.key,
    required this.employeeId,
    required this.depID, required this.tempalteId, required this.enrollId,
  });
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Container(
        width: 700,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.asset(
                    'images/single_doctor.png',
                    height: 277.0,
                    width: 372.0,
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Color(0xFF686464),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You are a part of ProHealth family,',
                      style: TextStyle(
                        color: Color(0xFF686464),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Please fill the information and provide necessary documents for the upcoming sections.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF686464),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () async {
                      int templateId = await TokenManager.getTemplateIdRegister();

                      OfferLetterData offerLetterData = await GetOfferLetter(
                          context, employeeId, templateId);

                      if (offerLetterData.statusCode == 409) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiStepForm(
                                    employeeID: employeeId,
                                    depID: depID,
                                  )),
                        );
                      } else if (offerLetterData.statusCode == 200 ||
                          offerLetterData.statusCode == 201) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OfferLetterDescriptionScreen(
                                      employeeId: employeeId,
                                      depID: depID,
                                      templateId: tempalteId,
                                      employeeEnrollId: enrollId,
                                    )));
                      } else if (offerLetterData.statusCode != 200 ||
                          offerLetterData.statusCode != 201 ||
                          offerLetterData.statusCode != 409) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FailedPopup(
                                text: offerLetterData.message,
                              );
                            });
                      } else {
                        print("Something went wrong!");
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FailedPopup(
                                text: offerLetterData.message,
                              );
                            });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF50B5E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5.0,
                  runSpacing: 5.0,
                  children: [
                    SvgPicture.asset(
                      'images/face_man.svg',
                      height: 24.0,
                      width: 24.0,
                    ),
                    const Text(
                      'For any assistance please call:',
                      style: TextStyle(
                        color: Color(0xFF686464),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      '(4088) 555-1234',
                      style: TextStyle(
                        color: Color(0xFF50B5E5),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF50B5E5),
                      ),
                    ),
                    const Text(
                      'or email:',
                      style: TextStyle(
                        color: Color(0xFF686464),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        decorationColor: Color(0xFF686464),
                      ),
                    ),
                    const Text(
                      'support@symmetry.com',
                      style: TextStyle(
                        color: Color(0xFF50B5E5),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF50B5E5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
