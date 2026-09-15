import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

class ForgetPasswordWeb extends StatefulWidget {
  const ForgetPasswordWeb({
    super.key,
  });

  @override
  State<ForgetPasswordWeb> createState() => _ForgetPasswordWebState();
}

class _ForgetPasswordWebState extends State<ForgetPasswordWeb> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FocusNode emailFocusNode = FocusNode();
  bool _isSendingEmail = false;
  String? _errorMessage;
  Future<void> _getOtpByEmail() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSendingEmail = true;
      });
      try {
        ApiData response =
            await AuthManager.getOTP(emailController.text, context);
        print(
            'Password reset OTP request completed with status ${response.statusCode}');
        if (response.success) {
          Navigator.pushNamed(context, VerifyPassword.routeName,
              arguments: ScreenArguments(title: emailController.text));
        } else {
          setState(() {
            _errorMessage = response.message;
          });
        }
      } finally {
        setState(() {
          _isSendingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstant(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        titleText: AppString.forgotpassword,
        textAction: AppString.backtologin,
        textActionPadding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width / 2),
        child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: ColorManager.white,
              ),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 30),
                  child: Column(
                    spacing: 24,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppString.forgotenter,
                        style: LoginFlowSubtitle.customTextStyle(context),
                      ),
                      TextFormField(
                        controller: emailController,
                        style: LoginFlowTextField.customTextStyle(context),
                        cursorHeight: 22,
                        cursorColor: ColorManager.black,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 2),
                          hintText: AppString.emailhint,
                          hintStyle: EmailTextStyle.enterEmail(context),
                          labelText: AppString.email,
                          labelStyle: EmailTextStyle.enterEmail(context),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorManager.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.black.withOpacity(0.5),
                                width: 0.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppString.enteremail;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return AppString.entervalidemail;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          _getOtpByEmail();
                        },
                      ),

                      ///button
                      Center(
                        child: CustomButton(
                          borderRadius: 24,
                          width: double.infinity,
                          text: AppString.continuet,
                          isLoading: _isSendingEmail,
                          onPressed: _getOtpByEmail,
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: LoginFlowErrorMsg.customTextStyle(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )));
  }
}
