import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/tablet_constant/tab_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/update_password/update_password.dart';

class VerifyForgotPassTab extends StatefulWidget {
  final String email;
  const VerifyForgotPassTab({super.key, required this.email});

  @override
  State<VerifyForgotPassTab> createState() => _VerifyForgotPassTabState();
}

class _VerifyForgotPassTabState extends State<VerifyForgotPassTab> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  late Timer _timer;
  int _timerCount = 30;
  bool isOtpFieldEmpty = true;

  final List<bool> _otpFieldFilledStatus = List.generate(6, (_) => false);
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_timerCount == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timerCount--;
        });
      }
    });
  }

  String getTimerString() {
    int minutes = _timerCount ~/ 60;
    int seconds = _timerCount % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void navigateToNextScreen() {
    bool allFieldsFilled = _otpFieldFilledStatus.every((filled) => filled);
    if (allFieldsFilled) {
      String otp = _otpControllers.map((controller) => controller.text).join();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UpdatePassword(email: widget.email, otp: otp)),
      );
    } else {
      setState(() {
        _errorMessage = AppString.enterotp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstTab(
        titleText: AppString.login,
        onTap: () {},
        textAction: '',
        childTab: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(25),
            child: Container(
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const  EdgeInsets.symmetric(horizontal: AppPadding.p14),
                      child: Text(AppString.entersixdigitCode,
                          style: CodeVerficationText.VerifyCode(context)),
                    ),
                    const SizedBox(height: AppSize.s16),

                    ///txtfield
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        6,
                        (index) => Container(
                          width: MediaQuery.of(context).size.width / 25,
                          height: MediaQuery.of(context).size.height / 22,
                          margin:  const EdgeInsets.symmetric(horizontal: AppPadding.p6),
                          // EdgeInsets.symmetric(
                          //     horizontal:
                          //         MediaQuery.of(context).size.width / 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.26),
                            border: Border.all(
                              color: ColorManager.bluecontainer,
                              width: 0.85,
                            ),
                          ),
                          child: TextFormField(
                            style: LoginFlowTextField.customTextStyle(context),
                            controller: _otpControllers[index],
                            cursorColor: ColorManager.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            focusNode: _focusNodes[index],
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(bottom: AppPadding.p11),
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppString.enterotp
                                  : null;
                            },

                            ///
                            onChanged: (value) {
                              _otpFieldFilledStatus[index] = value.isNotEmpty;
                              bool allFieldsFilled = _otpFieldFilledStatus
                                  .every((filled) => filled);
                              setState(() {
                                isOtpFieldEmpty = !allFieldsFilled;
                              });
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index + 1]);
                              } else if (allFieldsFilled) {
                                navigateToNextScreen();
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSize.s16),

                    ///timer
                    Text(
                      getTimerString(),
                      style: CustomTextStylesCommon.commonStyle(
                        color: ColorManager.orange,
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSize.s16),

                    ///button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p14),
                      child: CustomButton(
                        borderRadius: 24,
                        height: MediaQuery.of(context).size.height / 20,
                        width: double.infinity,
                        text: AppString.continuet,
                        onPressed: () {
                          navigateToNextScreen();
                        },
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSize.s8),
                      Text(
                        _errorMessage!,
                        style: LoginFlowErrorMsg.customTextStyle(context),
                      ),
                    ],
                    const SizedBox(height: AppSize.s16),

                    ///didnt receive code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppString.didntrecieveCode,
                            style: CodeVerficationText.VerifyCode(context)),
                        TextButton(
                          onPressed: () {
                            print("Resend tapped!");
                          },
                          child: Text(AppString.resend,
                              style: LoginFlowText.customTextStyle(context)),
                        )
                      ],
                    ),
                  ],
                ))));
  }
}
