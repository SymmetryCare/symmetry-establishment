// ignore_for_file: use_build_context_synchronously

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/provider/version_provider.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/email_verification/email_verification.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

class LoginWeb extends StatefulWidget {
  const LoginWeb({super.key});

  @override
  State<LoginWeb> createState() => _LoginWebState();
}

class _LoginWebState extends State<LoginWeb> {
  final TextEditingController _emailController = TextEditingController();
  FocusNode fieldOne = FocusNode();
  FocusNode fieldTow = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = true;
  bool _isSendingEmail = false;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  String? otpFromRunTab;
  String? _errorMessage;
  void clearSvgCache() {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  @override
  void initState() {
    super.initState();
    clearSvgCache();
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getOtpByEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSendingEmail = true;
      });
      try {
        ApiData response =
            await AuthManager.getOTP(_emailController.text, context);
        print('OTP request completed with status ${response.statusCode}');
        if (response.success) {
          Navigator.pushNamed(context, EmailVerification.routeName,
              arguments: ScreenArguments(title: _emailController.text));
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

  void _reloadPage() {
    html.window.location.reload();
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstant(
        onTap: () {},
        titleText: AppString.login,
        textAction:
            Provider.of<VersionProviderManager>(context).refreshVersionText,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.height / 4,
            margin: const EdgeInsets.symmetric(horizontal: 38, vertical: 38),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
                key: _formKey,
                child: Column(
                    spacing: 24,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppConfig.version,
                        style: LoginFlowTextField.customTextStyle(context)
                            .copyWith(fontSize: 10),
                      ),

                      ///textfield Email
                      TextFormField(
                        style: LoginFlowTextField.customTextStyle(context),
                        focusNode: emailFocusNode,
                        controller: _emailController,
                        cursorColor: ColorManager.black,
                        cursorHeight: 22,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 1),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: ColorManager.blackForLoginTexts,
                              width: 0.5,
                            ),
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
                      CustomButton(
                        borderRadius: 28,
                        width: double.infinity,
                        text: AppString.next,
                        isLoading: _isSendingEmail,
                        onPressed: () async {
                          _getOtpByEmail();
                        },
                      ),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: LoginFlowErrorMsg.customTextStyle(context),
                        ),
                      ],
                    ])),
          ),
        ));
  }
}

///
