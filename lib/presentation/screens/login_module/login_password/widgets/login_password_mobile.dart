import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/hr_home_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/mobile_constant/mobile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';

class LoginPasswordMobile extends StatefulWidget {
  static const String label = "/logInWithPassword";
  final String email;
  const LoginPasswordMobile({super.key, required this.email});

  @override
  State<LoginPasswordMobile> createState() => _LoginPasswordMobileState(email: email);
}

class _LoginPasswordMobileState extends State<LoginPasswordMobile> {
  final String email;
  bool _isLoading = false;
  String? _errorMessage;
  _LoginPasswordMobileState({required this.email});
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]\.com$');
  bool _obscureText = true;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      ApiData apiData = await AuthManager.signInWithEmail(
          email, _passwordController.text, context);
      if (apiData.success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HRHomeScreen.routeName,
          (route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = apiData.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  MobileConst(
      containerHeight:
      MediaQuery.of(context).size.height / 2, // specify desired height
      containerWidth: MediaQuery.of(context).size.width / 1.1,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ForgetPassword()));
      },
      titleText: AppString.login,
      textAction: AppString.forgotpass,
      mobileChild: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.enterpasstologin,
                    style: LoginFlowSubtitle.customTextStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s16),
              TextFormField(
                style: LoginFlowTextField.customTextStyle(context),
                onFieldSubmitted: (_) {
                  _login();
                },
                obscuringCharacter: '*',
                controller: _passwordController,
                cursorColor: ColorManager.black,
                cursorHeight: 22,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: AppPadding.p1),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorManager.black.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  hintText: AppString.enterpass,
                  hintStyle: EmailTextStyle.enterEmail(context),
                  labelText: AppString.password,
                  labelStyle: EmailTextStyle.enterEmail(context),
                  errorStyle: CustomTextStylesCommon.commonStyle(
                    color: ColorManager.red,
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w700,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppString.enterpass;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSize.s16),

              ///button
              CustomButton(
                borderRadius: 23.82,
                height: MediaQuery.of(context).size.height / 24,
                width: double.infinity,
                paddingVertical: AppPadding.p5,
                text: AppString.loginbtn,
                isLoading: _isLoading,
                onPressed: _login,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSize.s8),
                Text(
                  _errorMessage!,
                  style: LoginFlowErrorMsg.customTextStyle(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
