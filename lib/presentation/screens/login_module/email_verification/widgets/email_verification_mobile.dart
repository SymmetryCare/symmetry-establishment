import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/mobile_constant/mobile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/hr_home_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login_password/login_password.dart';

class EmailVerifyMobile extends StatefulWidget {
  final String email;
  const EmailVerifyMobile({super.key, required this.email});

  @override
  State<EmailVerifyMobile> createState() => _EmailVerifyMobileState();
}

class _EmailVerifyMobileState extends State<EmailVerifyMobile> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _isVerifyingOTP = false;
  String? _errorMessage = "";

  ///
  Future<void> _verifyOTPAndLogin() async {
    setState(() {
      _isVerifyingOTP = true;
      _errorMessage = "";
    });
    String enteredOTP =
        _otpControllers.map((controller) => controller.text).join();
    ApiData result = await AuthManager.verifyOTPAndLogin(
        email: widget.email, otp: enteredOTP, context: context);
    if (result.success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HRHomeScreen.routeName,
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
    setState(() {
      _isVerifyingOTP = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileConst(
      containerHeight:
          MediaQuery.of(context).size.height / 1.9, // specify desired height
      containerWidth: MediaQuery.of(context).size.width / 1.1,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginWithPassword(email: AppString.email),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      textAction: AppString.donthaveauth,
      titleText: AppString.verification,
      mobileChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppString.enter6digitcode,
              style: CodeVerficationText.VerifyCode(context),
            ),
            const SizedBox(height: AppSize.s16),

            ///txtfield
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  width: MediaQuery.of(context).size.width / 13,
                  height: MediaQuery.of(context).size.height / 23,
                  margin: const EdgeInsets.symmetric(horizontal: AppPadding.p6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.26),
                    border: Border.all(
                      color: ColorManager.bluecontainer,
                      width: 0.85,
                    ),
                  ),
                  child: TextFormField(
                    controller: _otpControllers[index],
                    cursorColor: ColorManager.black,
                    cursorHeight: 20,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(1),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: AppSize.s15),
                      counterText: '',
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    validator: (value) {
                      return value!.isEmpty ? AppString.otp : null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isNotEmpty && index == 5) {
                        _verifyOTPAndLogin();
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSize.s16),

            ///didnt receive code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppString.didntrecieveCode,
                    style: CodeVerficationText.VerifyCode(context)),
                TextButton(
                  onPressed: () {},
                  child: Text(AppString.resend,
                      style: LoginFlowText.customTextStyle(context)),
                )
              ],
            ),
            const SizedBox(height: AppSize.s16),

            ///button
            CustomButton(
              borderRadius: 23.82,
              height: MediaQuery.of(context).size.height / 23,
              width: double.infinity,
              paddingVertical: AppPadding.p5,
              text: AppString.loginbtn,
              isLoading: _isVerifyingOTP,
              onPressed: () {
                _verifyOTPAndLogin();
              },
            ),
            if (_errorMessage!.isNotEmpty) ...[
              const SizedBox(height: AppSize.s8),
              Text(
                _errorMessage!,
                style: LoginFlowErrorMsg.customTextStyle(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
