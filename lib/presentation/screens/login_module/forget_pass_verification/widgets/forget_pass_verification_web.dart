import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/update_password/update_password.dart';

class VerifyForgotPassWeb extends StatefulWidget {
  final String email;
  const VerifyForgotPassWeb({super.key, required this.email});

  @override
  State<VerifyForgotPassWeb> createState() => _VerifyForgotPassWebState();
}

class _VerifyForgotPassWebState extends State<VerifyForgotPassWeb> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  late Timer _timer;
  int _timerCount = 30;
  bool isOtpFieldEmpty = true;
  bool _isVerifyingOTP = false;

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
  Future<void> _verifyOTPAndLogin() async {
    setState(() {
      _isVerifyingOTP = true;
      _errorMessage = "";
    });
    String enteredOTP =
    _otpControllers.map((controller) => controller.text).join();
    try {
      ApiData result = await AuthManager.verifyOTPAndLogin(
          email: widget.email, otp: enteredOTP, context: context);
      if (result.success) {
        String otp = _otpControllers.map((controller) => controller.text).join();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UpdatePassword(email: widget.email, otp: otp)),
        );
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
      setState(() {
        _isVerifyingOTP = false;
      });
    } catch (e) {
      print(e);
    }
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

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstant(
      onTap: () {
        Navigator.push(
          context,
          RouteTransitions.slideTransition(page: const LoginScreen()),
        );
      },
      textAction: AppString.backtologin,
      titleText: AppString.verification,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width / 3.6,
          height: MediaQuery.of(context).size.height / 2.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: ColorManager.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppString.entersixdigitCode,
                    style: CodeVerficationText.VerifyCode(context)),

                ///txtfield
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                        (index) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 45,
                        height: MediaQuery.of(context).size.height / 19,
                        margin: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width / 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.26),
                          border: Border.all(
                            color: ColorManager.bluecontainer,
                            width: 0.85,
                          ),
                        ),
                        child: Focus(
                          onKey: (node, event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.backspace) {
                                if (_otpControllers[index].text.isEmpty &&
                                    index > 0) {
                                  // Clear current field and move focus to previous field
                                  _focusNodes[index].unfocus();
                                  _otpControllers[index].clear();
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[index - 1]);
                                  return KeyEventResult.handled;
                                }
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextFormField(
                            style: LoginFlowTextField.customTextStyle(context),
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            cursorColor: Colors.black,
                            cursorHeight: 20,
                            cursorWidth: 2,
                            cursorRadius: const Radius.circular(1),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            maxLength: 1,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 18),
                              counterText: '',
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                // Move focus to the next field
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index + 1]);
                              } else if (value.isNotEmpty && index == 5) {
                                // Last field, perform action (e.g., verify OTP)
                                _verifyOTPAndLogin();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),


                ///timer
                Text(
                  getTimerString(),
                  style: CustomTextStylesCommon.commonStyle(
                    color: ColorManager.orange,
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                  ),
                ),


                ///button
                Center(
                  child: CustomButton(
                    borderRadius: 24,
                    width: double.infinity,
                    text: AppString.continuet,
                    isLoading: _isVerifyingOTP,
                    onPressed: () {
                      _verifyOTPAndLogin();
                    },
                  ),
                ),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: LoginFlowErrorMsg.customTextStyle(context),
                  ),
                ],

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
            ),
          ),
        ),
      ),
    );
  }
}
