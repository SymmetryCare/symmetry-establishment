import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/main.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_establishment/services/notification_service.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';

class LoginPasswordWeb extends StatefulWidget {
  static const String label = "/logInWithPassword";
  final String email;
  const LoginPasswordWeb({super.key, required this.email});

  @override
  State<LoginPasswordWeb> createState() => _LoginPasswordWebState(email: email);
}

class _LoginPasswordWebState extends State<LoginPasswordWeb> {
  final String email;
  bool _isLoading = false;

  // General fallback error (no specific field matched)
  String? _errorMessage;

  // Field-specific errors (matched via ErrorDetail.key)
  String? _emailError;
  String? _passwordError;

  _LoginPasswordWebState({required this.email});
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]\.com$');
  bool _obscureText = true;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _emailError = null;
        _passwordError = null;
      });

      ApiData apiData = await AuthManager.signInWithEmail(
        email,
        _passwordController.text,
        context,
      );

      if (apiData.success) {
        initFCM(deviceName: 'Chrome', context: context);

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          RouteStrings.emDesktop,
        );

        print('Login completed successfully');
      } else {
        _handleLoginError(apiData);
      }
    }
  }

  /// Reads apiData.fieldErrors (List<ErrorDetail>?) and matches each
  /// error's `key` (e.g. "email", "password") to the right field.
  /// Falls back to apiData.message if no field-specific errors exist.
  void _handleLoginError(ApiData apiData) {
    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _emailError = null;
      _passwordError = null;

      final fieldErrors = apiData.fieldErrors;

      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        for (final ErrorDetail err in fieldErrors) {
          switch (err.key.toLowerCase()) {
            case 'email':
              _emailError = err.message;
              break;
            case 'password':
              _passwordError = err.message;
              break;
            default:
              // Unmatched key -> show as general error
              _errorMessage ??= err.message;
          }
        }
      } else {
        // No field-level errors -> show the general message
        _errorMessage = apiData.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
        return false; // prevent default back action
      },
      child: LoginBaseConstant(
        onTap: () {
          Navigator.pushNamed(context, ForgetPassword.routeName);
        },
        titleText: AppString.login,
        textAction: AppString.forgotpass,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.height / 3,
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 30,
                    ),
                    child: TextFormField(
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
                        contentPadding:
                            const EdgeInsets.only(top: AppPadding.p1),
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
                        // Shows the password-specific error inline,
                        // matched from ErrorDetail.key == "password"
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                  ),

                  ///button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 30,
                    ),
                    child: CustomButton(
                      borderRadius: 24,
                      height: MediaQuery.of(context).size.height / 18,
                      width: double.infinity,
                      text: AppString.loginbtn,
                      isLoading: _isLoading,
                      onPressed: _login,
                    ),
                  ),

                  // General/email error shown below the form
                  // (email field errors also land here since this
                  // screen only has a password TextFormField)
                  if (_errorMessage != null || _emailError != null) ...[
                    Text(
                      _emailError ?? _errorMessage!,
                      style: LoginFlowErrorMsg.customTextStyle(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
