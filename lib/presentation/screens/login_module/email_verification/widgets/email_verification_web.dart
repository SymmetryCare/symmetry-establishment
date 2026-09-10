import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/login_resources/login_flow_theme_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/screen_route_name.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/main.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/login_screen/widgets/login_flow_base_struct.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/hr_home_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login_password/login_password.dart';
import 'package:symmetry_establishment/services/notification_service.dart';

class EmailVerifyWeb extends StatefulWidget {
  final String email;
  const EmailVerifyWeb({super.key, required this.email});

  @override
  State<EmailVerifyWeb> createState() => _EmailVerifyWebState();
}

class _EmailVerifyWebState extends State<EmailVerifyWeb> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool _isVerifyingOTP = false;
  String? _errorMessage = "";
  Future<void> _verifyOTPAndLogin() async {
    setState(() {
      _isVerifyingOTP = true;
      _errorMessage = "";
    });

    String enteredOTP =
        _otpControllers.map((controller) => controller.text).join();

    try {
      ApiData result = await AuthManager.verifyOTPAndLogin(
        email: widget.email,
        otp: enteredOTP,
        context: context,
      );

      if (!mounted)
        return; // ✅ bail out immediately if disposed during the await

      if (result.success) {
        initFCM(deviceName: '', context: context);

        int dept = await TokenManager.getdepartmentId();
        print("DEPARTMENT AFTER LOGIN: $dept");

        if (!mounted) return; // ✅ another await happened above — check again

        final frontendConfig = FrontendConfigStore.data?.config;
        if (frontendConfig != null &&
            (dept == frontendConfig.salesId ||
                dept == frontendConfig.clinicalId)) {
          Provider.of<RouteProvider>(context, listen: false)
              .setRoute(RouteStrings.hrDesktop);

          await Navigator.pushReplacementNamed(
            context,
            HRHomeScreen.routeName,
          );
        } else {
          await Navigator.pushReplacementNamed(
            context,
            HRHomeScreen.routeName,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result.message;
          });
        }
      }
    } catch (e) {
      print("OTP Verify Error: $e");
    } finally {
      if (mounted) {
        // ✅ this is the exact line that was crashing
        setState(() {
          _isVerifyingOTP = false;
        });
      }
    }
  }

  Future<void> _getOtpByEmail() async {
    try {
      ApiData response = await AuthManager.getOTP(widget.email, context);
      print('OTP request completed with status ${response.statusCode}');
      if (response.success) {
        print('OTP resend request accepted');
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginBaseConstant(
      onTap: () {
        Navigator.pushNamed(context, LoginScreen.routeName);
      },
      textAction: '',
      titleText: AppString.verification,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: MediaQuery.of(context).size.width / 3.5,
          height: MediaQuery.of(context).size.height / 2.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 38, vertical: 38),
          child: Column(
            spacing: 24,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppString.enter6digitcode,
                style: CodeVerficationText.VerifyCode(context),
              ),

              ///txtfield
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 45,
                      height: MediaQuery.of(context).size.height / 19,
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.26),
                        border: Border.all(
                          color: ColorManager.bluecontainer,
                          width: 0.85,
                        ),
                      ),
                      child: Focus(
                        onKey: (node, event) {
                          if (event is RawKeyDownEvent) {
                            if (event.logicalKey ==
                                LogicalKeyboardKey.backspace) {
                              if (_otpControllers[index].text.isEmpty &&
                                  index > 0) {
                                // Clear current field and move focus to previous field
                                _focusNodes[index].unfocus();
                                _otpControllers[index].clear();
                                FocusScope.of(context)
                                    .requestFocus(_focusNodes[index - 1]);
                                return KeyEventResult.handled;
                              }
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextFormField(
                          style: LoginFlowTextField.customTextStyle(context),
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          cursorColor: Colors.black,
                          cursorHeight: 20,
                          cursorWidth: 2,
                          cursorRadius: const Radius.circular(1),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 18),
                            counterText: '',
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              // Move focus to the next field
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index + 1]);
                            } else if (value.isNotEmpty && index == 5) {
                              // Last field, perform action (e.g., verify OTP)
                              _verifyOTPAndLogin();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              ///didnt receive code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppString.didntrecieveCode,
                      style: CodeVerficationText.VerifyCode(context)),
                  TextButton(
                    onPressed: () {
                      _getOtpByEmail();
                    },
                    child: Text(AppString.resend,
                        style: LoginFlowText.customTextStyle(context)),
                  )
                ],
              ),

              ///button
              CustomButton(
                borderRadius: 24,
                width: double.infinity,
                text: AppString.loginbtn,
                isLoading: _isVerifyingOTP,
                onPressed: () {
                  _verifyOTPAndLogin();
                },
              ),
              if (_errorMessage!.isNotEmpty) ...[
                Text(
                  _errorMessage!,
                  style: LoginFlowErrorMsg.customTextStyle(context),
                ),
              ],

              ///bottomtxt
              InkWell(
                child: Text(AppString.donthaveauth,
                    style: LoginFlowText.customTextStyle(context)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginWithPassword(email: widget.email)));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
