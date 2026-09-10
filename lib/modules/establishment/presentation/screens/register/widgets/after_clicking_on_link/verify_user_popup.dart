import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/offer_letter_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/offer_letter_html_data/offer_letter_html.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/onboarding_verifyuser_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/on_boarding_welcome.dart';



class VerifyUserpopup extends StatefulWidget {


  const VerifyUserpopup({super.key, });
  @override
  VerifyUserpopupState createState() => VerifyUserpopupState();
}

class VerifyUserpopupState extends State<VerifyUserpopup> {
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  bool _isVerifyingOTP = false;
  String? _errorMessage = "";


  Future<void> _verifyOTPAndProcess(String email) async {
    setState(() {
      _isVerifyingOTP = true;
      _errorMessage = "";
    });
    String enteredOTP = otpControllers.map((controller) => controller.text).join();
    try {
      var response = await verifyOTPAndRegister(
          email: email, otp: enteredOTP, context: context);
      if (response.success) {
        if (response.userRole != "Onboarding") {
          print('Success navigate');
          int employeeIdRegister = 0;
          String email = await TokenManager.getEmailIdRegister();
          int companyId = await TokenManager.getCompanyIdRegister();
          int depID = await TokenManager.getdepIdRegister();
          int templateId = await TokenManager.getTemplateIdRegister();
          int enrollId = await TokenManager.getEnrollIdRegister();
          EmployeeIdByEmail result = await GetEmployeeIdByEmail(context, companyId, email);
          employeeIdRegister = result.employeeID;

          print('EmployeeId :::: $employeeIdRegister');
          print('depppp :::: $depID');
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: OnBoardingCongratulation(
                  employeeId: employeeIdRegister,
                  depID: depID,
                  tempalteId: templateId,
                  enrollId: enrollId,
                ),
              );
            },
          );
        } else {
          setState(() {
            _errorMessage = "This employee is already onboarded.";
          });
        }
        setState(() {
          _isVerifyingOTP = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => FailedPopup(text: response.message),
        );
      }
      setState(() {
        _isVerifyingOTP = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Timer? _timer;
  int _remainingTime = 59;
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool otpEnabled = false;
  bool emailEntered = false;
  bool isLoading = false;
  bool isOtpLoading = false;

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }

  FocusNode emailFocusNode = FocusNode();
  FocusNode otpFocusNode = FocusNode();
  FocusNode getOtpButtonFocusNode = FocusNode();
  FocusNode submitButtonFocusNode = FocusNode();


  Future<void> _pressGetOtpButton() async {
    if (!emailEntered) return;

    // validate first — don't call the API with an invalid email
    if (!_formKey.currentState!.validate()) return;

    // show loader while the API call is in flight
    setState(() {
      isLoading = true;
    });

    // ── wait for the real API result ──────────────────────────────
    final ApiData result = await postverifyuser(context, emailController.text);

    if (!mounted) return; // screen may have been disposed during the await

    if (result.success) {
      // ── SUCCESS: start the further process ──────────────────────
      setState(() {
        isLoading = false;
        emailEntered = false;
        otpEnabled = true;
        _remainingTime = 59; // Reset timer
      });
      _startTimer(); // Start timer
    } else {
      // ── FAILURE: just stop loading — the manager already shows
      // the FailedPopup with the backend error message
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Header Row
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.userCheck,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: AppSize.s10),
                          Text(
                            AppString.verify_user,
                            style:PopupBlueBarText.customTextStyle(context),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Email Input Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email',style: AllPopupHeadings.customTextStyle(context)),
                        const SizedBox(height: AppSize.s5),
                        TextFormField(
                          cursorColor: Colors.black,
                          controller: emailController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')), // no spaces, ever
                          ],
                          style: onlyFormDataStyle.customTextStyle(context),
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xffB1B1B1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xffB1B1B1)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(color: Color(0xffB1B1B1)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              emailEntered = _isEmailValid(value);
                            });
                          },
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(getOtpButtonFocusNode);
                            _pressGetOtpButton();  // Trigger the OTP button press
                          },

                        ),
                      ],
                    ),

                    const SizedBox(height: AppSize.s30),

                    // Get OTP Button
                    isLoading
                        ? SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : Container(
                      height: 30,
                          child: ElevatedButton(
                                                focusNode: getOtpButtonFocusNode,
                                                autofocus: true,
                                                style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50B5E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                                                ),
                                                onPressed: emailEntered
                            ? () async {
                          _pressGetOtpButton();
                                                }
                            : null,
                                                child: Text('Get OTP',
                            style: BlueButtonTextConst.customTextStyle(context)),
                                              ),
                        ),
                    const SizedBox(height: AppSize.s30),

                    // OTP Input Fields
                    Container(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OTP', style: AllPopupHeadings.customTextStyle(context)),
                          const SizedBox(height: AppSize.s5),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: List.generate(
                              6,
                                  (index) {
                                return Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: const Color(0xffB1B1B1),
                                      width: 0.85,
                                    ),
                                  ),
                                  child: Focus(
                                    onKey: (node, event) {
                                      if (event is RawKeyDownEvent) {
                                        if (event.logicalKey == LogicalKeyboardKey.backspace) {
                                          if (otpControllers[index].text.isEmpty && index > 0) {
                                            _focusNodes[index].unfocus();
                                            otpControllers[index].clear();
                                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                                            return KeyEventResult.handled;
                                          }
                                        }
                                      }
                                      return KeyEventResult.ignored;
                                    },
                                    child: TextFormField(
                                      cursorColor: Colors.black,
                                      controller: otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      style: onlyFormDataStyle.customTextStyle(context),
                                      enabled: otpEnabled,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      textAlignVertical: TextAlignVertical.center,
                                      maxLength: 1,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(bottom: 20),
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
                                          _verifyOTPAndProcess(emailController.text);
                                        }
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Allow only digits
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),


                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s5),

                    // Error message (left) and Timer/Resend (right) in same row
                    Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_errorMessage != null && _errorMessage!.isNotEmpty)
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: ColorManager.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20,),
                          if (otpEnabled)
                            _remainingTime > 0
                                ? Text(
                                    '00:${_remainingTime.toString().padLeft(2, '0')}',
                                    style: onlyFormDataStyle.customTextStyle(context),
                                  )
                                : InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () async {
                                      await postverifyuser(context, emailController.text);
                                      _remainingTime = 59;
                                      _startTimer();
                                    },
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: FontSize.s12,
                                        color: ColorManager.blueprime,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                          else
                            const SizedBox(height: 25,),
                        ],
                      ),
                    ),

                    if (otpEnabled) const SizedBox(height: AppSizeConst.A20),

                    // Submit Button
                    isOtpLoading
                        ? SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    )
                        : Container(
                      height: 30,
                          child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF50B5E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                                                ),
                                                onPressed: otpEnabled
                            ? () async {
                          if (_formKey.currentState!.validate()) {
                            String email = emailController.text;

                            setState(() {
                              isOtpLoading = true;
                            });
                            await _verifyOTPAndProcess(email);
                            Future.delayed(
                              const Duration(seconds: 2),
                                  () {
                                setState(() {
                                  isOtpLoading = false;
                                });
                              },
                            );
                          } else {
                            return print('OTP not valid');
                          }
                                                }
                            : null,
                                                child: _isVerifyingOTP
                            ? Text(AppString.verify, style: BlueButtonTextConst.customTextStyle(context))
                            : Text('Submit', style: BlueButtonTextConst.customTextStyle(context)),
                                              ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
