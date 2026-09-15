import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/screen_transition.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';

class NewPasswordScreenWeb extends StatefulWidget {
  final String email;
  final String otp;
  const NewPasswordScreenWeb({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordScreenWeb> createState() => _NewPasswordScreenWebState();
}

class _NewPasswordScreenWebState extends State<NewPasswordScreenWeb> {
  final TextEditingController controllerNew = TextEditingController();
  final TextEditingController controllerConfirm = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _obscureTextconfirm = true;
  String? _errorMessage;
  bool _isUpdatingPassword = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> updatePassword(String email, String otp) async {
    String newPassword = newPasswordController.text;
    try {
      var headers = {'Content-Type': 'application/json'};
      var data = json.encode({
        "email": email,
        "verificationCode": otp,
        "newPassword": newPassword
      });

      var response = await Dio().post(
        '${AppConfig.endpoint}/auth/ResetPassword',
        // http://54.245.136.133:3000/auth/ResetPassword
        data: data,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        print(AppString.resetsuccessfully);
        print(json.encode(response.data));
        Navigator.pop(context as BuildContext);
      } else {
        print('Failed to change password: ${response.statusMessage}');
        print(json.encode(response.data));
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstant(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      textAction: AppString.backtologin,
      titleText: AppString.newPass,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width / 3.6,
          height: MediaQuery.of(context).size.height / 2.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 30),
              child: Column(
                spacing: 24,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.setnewPassword,
                    style: LoginFlowSubtitle.customTextStyle(context),
                  ),


                  ///txtfield
                  TextFormField(
                    style: LoginFlowTextField.customTextStyle(context),
                    focusNode: newPasswordFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(confirmPasswordFocusNode);
                    },
                    cursorHeight: 22,
                    obscuringCharacter: '*',
                    controller: controllerNew,
                    cursorColor: Colors.black,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.only(top: AppPadding.p2),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: AppSize.s15,
                          color: ColorManager.whitesheed,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      labelText: AppString.newPass,
                      labelStyle: EmailTextStyle.enterEmail(context),
                      hintText: AppString.enternewpass,
                      hintStyle: EmailTextStyle.enterEmail(context),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: ColorManager.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorManager.black.withOpacity(0.5),
                            width: 0.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: ColorManager.grey),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppString.enterpass;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    focusNode: confirmPasswordFocusNode,
                    onFieldSubmitted: (_) {},
                    cursorHeight: 22,
                    obscuringCharacter: '*',
                    controller: controllerConfirm,
                    style: LoginFlowTextField.customTextStyle(context),
                    cursorColor: ColorManager.black,
                    obscureText: _obscureTextconfirm,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 2),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextconfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: AppSize.s15,
                          color: ColorManager.whitesheed,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureTextconfirm = !_obscureTextconfirm;
                          });
                        },
                      ),
                      labelText: AppString.confmpass,
                      labelStyle: EmailTextStyle.enterEmail(context),
                      hintText: AppString.enterconfmpass,
                      hintStyle: EmailTextStyle.enterEmail(context),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: ColorManager.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorManager.black.withOpacity(0.5),
                            width: 0.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: ColorManager.grey),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppString.enterconfmpass;
                      }
                      return null;
                    },
                  ),

                  ///button
                  Center(
                    child: CustomButton(
                      width: double.infinity,
                      text: AppString.updatepass,
                      backgroundColor: ColorManager.blueprime,
                      isLoading: _isUpdatingPassword,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (controllerNew.text !=
                              controllerConfirm.text) {
                            setState(() {
                              _errorMessage = AppString.passdontmatch;
                            });
                            return;
                          }
                          setState(() {
                            _isUpdatingPassword = true;
                          });
                          try {
                            var response = await AuthManager().confirmPassword(
                                widget.email,
                                widget.otp,
                                controllerNew.text,
                                context);
                            print('${widget.email}');
                            print('${controllerNew.text}');
                            if(response.statusCode == 200 || response.statusCode == 201) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: ColorManager.white,
                                    content: Container(
                                      padding: const EdgeInsets.only(
                                          top: AppPadding.p25),
                                      height: AppSize.s300,
                                      width: AppSize.s400,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'images/upload.png',
                                            width: AppSize.s120,
                                            height: AppSize.s120,
                                          ),
                                          Text(
                                              AppString.successfully,
                                              style:
                                              LoginFlowHeading.customTextStyle(
                                                  context)
                                          ),
                                          Text(
                                            AppString.resetsuccessfully,
                                            style: LoginFlowTheme.enterEmail(
                                                context),
                                          ),
                                          CustomButton(
                                            width: AppSize.s181,
                                            height: AppSize.s45,
                                            text: AppString
                                                .continuebutton,
                                            borderRadius: 24,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen()),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }else{
                              AlertDialog(
                                backgroundColor: ColorManager.white,
                                content: Container(
                                  padding: const EdgeInsets.only(
                                      top: AppPadding.p10),
                                  height: AppSize.s300,
                                  width: AppSize.s400,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        response.message,
                                        style: LoginFlowHeading.customTextStyle(context),
                                      ),
                                      Text(
                                        response.message,
                                        style: LoginFlowTheme.enterEmail(context),
                                      ),
                                      CustomButton(
                                        width: AppSize.s181,
                                        height: AppSize.s45,
                                        text: AppString.continuebutton,
                                        borderRadius: 24,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen()),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            AlertDialog(
                              backgroundColor: ColorManager.white,
                              content: Container(
                                padding: const EdgeInsets.only(
                                    top: AppPadding.p10),
                                height: AppSize.s300,
                                width: AppSize.s400,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppString.threetimepasscanchange,
                                      style: LoginFlowHeading.customTextStyle(context),
                                    ),
                                    Text(
                                      AppString.cannotchangepass,
                                      style: LoginFlowTheme.enterEmail(context),
                                    ),
                                    CustomButton(
                                      width: AppSize.s181,
                                      height: AppSize.s45,
                                      text: AppString.continuebutton,
                                      borderRadius: 24,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                            print(
                                'Error occurred while confirming password: $e');
                            // Handle error
                          } finally {
                            setState(() {
                              _isUpdatingPassword = false;
                            });
                          }
                        }
                      },
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
        ),
      ),
    );
  }

}
