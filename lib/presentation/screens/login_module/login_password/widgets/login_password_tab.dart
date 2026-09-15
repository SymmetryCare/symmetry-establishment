import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/tablet_constant/tab_const.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';

class LoginPassswordTab extends StatefulWidget {
  static const String label = "/logInWithPassword";
  final String email;
  const LoginPassswordTab({super.key, required this.email});

  @override
  State<LoginPassswordTab> createState() => _LoginPassswordTabState(email: email);
}

class _LoginPassswordTabState extends State<LoginPassswordTab> {
  final String email;
  bool _isLoading = false;
  String? _errorMessage;
  _LoginPassswordTabState({required this.email});
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
          RouteStrings.emDesktop,
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
    return LoginBaseConstTab(
      titleText: AppString.login,
      onTap: () {
        Navigator.push(
          context,
          RouteTransitions.slideTransition(page: const ForgetPassword()),
        );
      },
      textAction: AppString.forgotpass,
      childTab: Container(
        height: MediaQuery.of(context).size.height / 3.5,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Form(
          key: _formKey,
          child: Column(
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
              ),
              const SizedBox(height: AppSize.s16),

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
