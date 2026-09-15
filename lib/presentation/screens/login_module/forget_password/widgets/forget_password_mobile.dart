import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/mobile_constant/mobile_const.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

class ForgetPasswordMobile extends StatefulWidget {
  const ForgetPasswordMobile({super.key});

  @override
  State<ForgetPasswordMobile> createState() => _ForgetPasswordMobileState();
}

class _ForgetPasswordMobileState extends State<ForgetPasswordMobile> {
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
    return MobileConst(
      titleText: AppString.forgotpassword,
      textAction: AppString.backtologin,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      containerHeight:
          MediaQuery.of(context).size.height / 2, // specify desired height
      containerWidth: MediaQuery.of(context).size.width / 1.1,
      mobileChild: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.forgotentermobile,
                style: LoginFlowSubtitle.customTextStyle(context),
              ),
              const SizedBox(height: AppSize.s16),
              TextFormField(
                focusNode: emailFocusNode,
                keyboardType: TextInputType.visiblePassword,
                controller: emailController,
                style: LoginFlowTextField.customTextStyle(context),
                cursorHeight: 22,
                cursorColor: ColorManager.black,
                decoration: InputDecoration(
                  errorStyle: CustomTextStylesCommon.commonStyle(
                    color: ColorManager.red,
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w700,
                  ),
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
                        color: ColorManager.black.withOpacity(0.5), width: 0.5),
                  ),
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
                onFieldSubmitted: (_) {
                  submitForm();
                },
              ),

              const SizedBox(height: AppSize.s16),

              ///button
              Center(
                child: CustomButton(
                  borderRadius: 23.82,
                  height: MediaQuery.of(context).size.height / 24,
                  width: double.infinity,
                  paddingVertical: AppPadding.p5,
                  text: AppString.continuet,
                  onPressed: submitForm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
