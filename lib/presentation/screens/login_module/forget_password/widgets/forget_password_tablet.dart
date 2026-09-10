import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/tablet_constant/tab_const.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

class ForgetPasswordTablet extends StatefulWidget {
  const ForgetPasswordTablet({super.key});

  @override
  State<ForgetPasswordTablet> createState() => _ForgetPasswordTabletState();
}

class _ForgetPasswordTabletState extends State<ForgetPasswordTablet> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  FocusNode emailFocusNode = FocusNode();

  void submitForm() {
    if (formKey.currentState!.validate()) {
      setState(() {});
      AuthManager().forgotPassword(emailController.text, context);
      Navigator.pushNamed(context, VerifyPassword.routeName,
          arguments: ScreenArguments(title: emailController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstTab(
      titleText: AppString.forgotpassword,
      onTap: () {
        Navigator.push(
          context,
          RouteTransitions.slideTransition(page: const LoginScreen()),
        );
      },
      textAction: AppString.backtologin,
      childTab: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: MediaQuery.of(context).size.height / 3.5,
          width: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(25)),
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.forgotenter,
                    style: LoginFlowSubtitle.customTextStyle(context),
                  ),
                  const SizedBox(height: AppSize.s16),
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
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      submitForm();
                    },
                  ),

                  const SizedBox(height: AppSize.s16),

                  ///button
                  Center(
                    child: CustomButton(
                      borderRadius: 24,
                      height: MediaQuery.of(context).size.height / 18,
                      width: double.infinity,
                      text: AppString.continuet,
                      onPressed: submitForm,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
