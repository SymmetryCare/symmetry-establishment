// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/mobile_constant/mobile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/email_verification.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final TextEditingController _emailController = TextEditingController();
  FocusNode fieldOne = FocusNode();
  FocusNode fieldTow = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = true;
  bool _isSendingEmail = false;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  String? otpFromRunTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileConst(
        containerHeight: MediaQuery.of(context).size.height / 1.9,
        containerWidth: MediaQuery.of(context).size.width / 1.1,
        onTap: () {},
        titleText: AppString.login,
        textAction: '',
        mobileChild: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 8,
                ),
                child: TextFormField(
                  style: LoginFlowTextField.customTextStyle(context),
                  focusNode: emailFocusNode,
                  controller: _emailController,
                  cursorColor: ColorManager.black,
                  cursorHeight: 22,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 1),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorManager.black.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    errorStyle: CustomTextStylesCommon.commonStyle(
                      color: ColorManager.red,
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w700,
                    ),
                    labelText: AppString.email,
                    hintText: AppString.emailhint,
                    hintStyle: EmailTextStyle.enterEmail(context),
                    labelStyle: EmailTextStyle.enterEmail(context),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppString.enteremail;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppString.entervalidemail;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        _isSendingEmail = true;
                      });
                      try {
                        await AuthManager.getOTP(
                            _emailController.text, context);
                        Navigator.pushNamed(
                            context, EmailVerification.routeName,
                            arguments:
                            ScreenArguments(title: _emailController.text));
                      } catch (e) {
                        // Handle error
                        print('Error occurred: $e');
                      } finally {
                        setState(() {
                          _isSendingEmail = false;
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSize.s16),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 8,
                ),
                child: CustomButton(
                  borderRadius: 23.82,
                  height: MediaQuery.of(context).size.height / 24,
                  width: double.infinity,
                  paddingVertical: AppPadding.p5,
                  text: AppString.next,
                  isLoading: _isSendingEmail,
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        _isSendingEmail = true;
                      });
                      try {
                        await AuthManager.getOTP(
                            _emailController.text, context);
                        Navigator.pushNamed(
                            context, EmailVerification.routeName,
                            arguments: ScreenArguments(
                                title: _emailController.text));
                      } catch (e) {
                        // Handle error
                        print('Error occurred: $e');
                      } finally {
                        setState(() {
                          _isSendingEmail = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}