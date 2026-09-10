import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/user.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_screen/widgets/user_create_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

// class CustomDialog extends StatefulWidget {
//   final String title;
//   final TextEditingController lastNameController;
//   final TextEditingController emailController;
//   final TextEditingController firstNameController;
//   final TextEditingController passwordController;
//   final VoidCallback? onCancel;
//   CustomDialog({
//     required this.title,
//      this.onCancel,
//     required this.lastNameController,
//     required this.emailController,
//     required this.firstNameController,
//     required this.passwordController,
//   });
//
//   @override
//   State<CustomDialog> createState() => _CustomDialogState();
// }
//
// class _CustomDialogState extends State<CustomDialog> {
//
//   @override
//   void initState() {
//     super.initState();
//     _generatePassword();
//   }
//
//   void _generatePassword() {
//     final random = Random();
//     final characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@';
//     String password = '';
//     for (int i = 0; i < 8; i++) {
//       password += characters[random.nextInt(characters.length)];
//     }
//     setState(() {
//       widget.passwordController.text = password;
//     });
//   }
//
//   void _copyToClipboard() {
//     Clipboard.setData(ClipboardData(text: widget.passwordController.text)).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Copied to clipboard')),
//       );
//     });
//   }
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String? _nameDocError;
//   String? _emailDocError;
//   String? _stateDocError;
//   String? _PasswordDocError;
//   bool isLoading = false;
//
//   bool _isFormValid = true;
//   String? _validateTextField(String value, String fieldName) {
//     if (value.isEmpty) {
//       _isFormValid = false;
//       return "Please Enter $fieldName";
//     }
//     return null;
//   }
//
//   void _validateForm() {
//     setState(() {
//       _isFormValid = true;
//       _nameDocError = _validateTextField(widget.firstNameController.text, 'First Name');
//       _emailDocError = _validateTextField(widget.emailController.text, 'Email');
//       _stateDocError = _validateTextField(widget.lastNameController.text, 'Last Name');
//       _PasswordDocError =
//           _validateTextField(widget.passwordController.text, 'Password');
//      });
//   }
//
//   var deptId = 1;
//   int? firstDeptId;
//   String? selectedDeptName;
//   int? selectedDeptId;
//
//   @override
//   Widget build(BuildContext context) {
//     return DialogueTemplate(
//         width: AppSize.s410,
//         height: AppSize.s550,
//         //title: "Create User",
//         title: widget.title,
//         onClear: (){
//           widget.firstNameController.clear();
//           widget.lastNameController.clear();
//           widget.emailController.clear();
//           selectedDeptId = AppConfig.AdministrationId;
//           Navigator.pop(context);
//         },
//         body: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 SMTextfieldAsteric(
//                   controller: widget.firstNameController,
//                   keyboardType: TextInputType.text,
//                   text: "First Name",
//                 ),
//                 if (_nameDocError != null)
//                   Text(
//                     _nameDocError!,
//                     style: CommonErrorMsg.customTextStyle(context),
//                   ),
//                 SizedBox(height: AppSize.s5,),
//                 ///
//                 SMTextfieldAsteric(
//                   controller: widget.lastNameController,
//                   keyboardType: TextInputType.text,
//                   text: 'Last Name',
//                 ),
//                 if (_stateDocError != null)
//                   Text(
//                     _stateDocError!,
//                     style: CommonErrorMsg.customTextStyle(context),
//                   ),
//                 SizedBox(height: AppSize.s10,),
//                 RichText(
//                   text: TextSpan(
//                     text:"Select Department",
//                     style: AllPopupHeadings.customTextStyle(context),
//                     children: [
//                       TextSpan(
//                         text: ' *', // Asterisk
//                         style: AllPopupHeadings.customTextStyle(context).copyWith(
//                           color: ColorManager.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: AppSize.s5,),
//                 FutureBuilder<List<HRHeadBar>>(
//                   future: companyHRHeadApi(context, deptId),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       List<String>dropDownServiceList =[];
//                       return Container(
//                           alignment: Alignment.center,
//                           child:
//                           HRUManageDropdown(
//                             controller:
//                             TextEditingController(
//                                 text: ''
//                             ),
//                             labelFontSize: FontSize.s12,
//                             items:  dropDownServiceList,
//                           )
//                       );
//                     }
//                     if (snapshot.hasData &&
//                         snapshot.data!.isEmpty) {
//                       return Center(
//                         child: Text(
//                           ErrorMessageString.noroleAdded,
//                           style: AllNoDataAvailable.customTextStyle(context),
//                         ),
//                       );
//                     }
//                     if (snapshot.hasData) {
//
//                       List<String> dropDownServiceList = snapshot
//                           .data!
//                           .map((dept) => dept.deptName!)
//                           .toList();
//                       String? firstDeptName =
//                       snapshot.data!.isNotEmpty
//                           ? snapshot.data![0].deptName
//                           : null;
//                       int? firstDeptId = snapshot.data!.isNotEmpty
//                           ? snapshot.data![0].deptId
//                           : null;
//
//                       if (selectedDeptName == null &&
//                           dropDownServiceList.isNotEmpty) {
//                         selectedDeptName = firstDeptName;
//                         selectedDeptId = firstDeptId;
//                       }
//
//                       return StatefulBuilder(
//                         builder: (BuildContext context, void Function(void Function()) setState) {
//                           return HRUManageDropdown(
//                             controller: TextEditingController(
//                                 text: selectedDeptName ?? ''),
//                             hintText: "Department",
//                             labelFontSize: FontSize.s12,
//                             items: dropDownServiceList,
//                             onChanged: (val) {
//                               setState(() {
//                                 selectedDeptName = val;
//
//                                 selectedDeptId = snapshot.data!
//                                     .firstWhere(
//                                         (dept) => dept.deptName == val)
//                                     .deptId;
//                               });
//                             },
//                           );
//                         },
//                       );
//                     }
//                     return const SizedBox();
//                   },
//                 ),
//                 SizedBox(height: AppSize.s14,),
//                 SMTextfieldAsteric(controller: widget.emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     text: 'Email'),
//                 if (_emailDocError != null) // Display error if any
//                   Text(
//                     _emailDocError!,
//                     style: CommonErrorMsg.customTextStyle(context),
//                   ),
//                 SizedBox(height: AppSize.s14,),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 1),
//                   child: Text("Password",
//                       style: AllPopupHeadings.customTextStyle(context)),
//                 ),
//                 SizedBox(height: AppSize.s5,),
//                 CustomTextFieldWithIcon(
//                   controller: widget.passwordController,
//                   // suffixIcon: Icon(Icons.copy, size: 14,color: Colors.black),
//                   keyboardType: TextInputType.text,
//                   text: "Password",
//                   cursorHeight: 12,
//                   // labelText: "Password",
//                   hintText: "Password",
//                   labelStyle: TextStyle(),
//                   labelFontSize: FontSize.s12,
//                   errorText: 'Password is required',
//                   onSuffixIconPressed: _copyToClipboard,
//                 ),
//                 if (_PasswordDocError != null)
//                   Text(
//                     _PasswordDocError!,
//                     style: CommonErrorMsg.customTextStyle(context),
//                   ),
//               ],
//             ),
//           )
//
//         ],
//       bottomButtons: isLoading
//           ? SizedBox(
//         height: AppSize.s25,
//         width: AppSize.s25,
//         child: CircularProgressIndicator(
//           color: ColorManager.blueprime,
//         ),
//       )
//           : CustomElevatedButton(
//         height: AppSize.s30,
//         width: AppSize.s120,
//         text: 'Create',
//         onPressed: () async {
//           _validateForm();
//           if (!_isFormValid) {
//             return;
//           }
//           if (widget.passwordController.text.length < 6) {
//             setState(() {
//               _PasswordDocError = "Password must be longer than or equal to 6 characters";
//             });
//             return;
//           }
//           setState(() {
//             isLoading = true;
//           });
//
//           print('$selectedDeptId');
//           print('${widget.firstNameController.text}');
//           print('${widget.lastNameController.text}');
//           print('${widget.emailController.text}');
//           print('${widget.passwordController.text}');
//
//           try {
//             var response = await createUserPost(
//               context,
//               widget.firstNameController.text,
//               widget.lastNameController.text,
//               selectedDeptId!,
//               widget.emailController.text,
//               widget.passwordController.text,
//             );
//
//             if (response.statusCode == 200 || response.statusCode == 201) {
//               Navigator.pop(context);
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AddSuccessPopup(
//                     message: 'User Added Successfully',
//                   );
//                 },
//               );
//               widget.onCancel!();
//               widget.firstNameController.clear();
//               widget.lastNameController.clear();
//               widget.emailController.clear();
//               selectedDeptId = AppConfig.AdministrationId;
//             } else {
//
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) => FailedPopup(text: response.message),
//               );
//             }
//           } catch (e) {
//
//             showDialog(
//               context: context,
//               builder: (BuildContext context) => FailedPopup(text: e.toString()),
//             );
//           } finally {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         },
//       ),
//         );
//   }
// }

///old code without provider
class CustomDialogSEE extends StatefulWidget {
  final String title;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController passwordController;
  final VoidCallback? onCancel;
  final VoidCallback? onUserCreated;
  CustomDialogSEE({
    required this.title,
    this.onCancel,
    this.onUserCreated,
    required this.lastNameController,
    required this.emailController,
    required this.firstNameController,
    required this.passwordController,
  });

  @override
  State<CustomDialogSEE> createState() => _CustomDialogSEEState();
}

class _CustomDialogSEEState extends State<CustomDialogSEE> {

  // @override
  // void initState() {
  //   super.initState();
  //   _generatePassword();
  // }
  //
  // void _generatePassword() {
  //   final random = Random();
  //   final characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@';
  //   String password = '';
  //   for (int i = 0; i < 8; i++) {
  //     password += characters[random.nextInt(characters.length)];
  //   }
  //   setState(() {
  //     widget.passwordController.text = password;
  //   });
  // }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _generatePassword();
      }
    });
  }

  void _generatePassword() {
    final random = Random();
    final characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@';
    String password = '';
    for (int i = 0; i < 8; i++) {
      password += characters[random.nextInt(characters.length)];
    }
    widget.passwordController.text = password;
  }



  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.passwordController.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    });
  }
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _nameDocError;
  String? _emailDocError;
  String? _stateDocError;
  String? _PasswordDocError;
  String? _departmentError;
  String? _deptDocError;
  bool isLoading = false;

  bool _isFormValid = true;
  // String? _validateTextField(String value, String fieldName) {
  //   if (value.isEmpty) {
  //     _isFormValid = false;
  //     return "Please Enter $fieldName";
  //   }
  //   return null;
  // }

  String? _validateTextField(String value, String fieldName) {
    return value.isEmpty ? "Please enter $fieldName" : null;
  }

  // void _validateForm() {
  //   bool isFormValid = true;
  //   setState(() {
  //     _nameDocError = _validateTextField(widget.firstNameController.text, 'First Name');
  //     _emailDocError = _validateTextField(widget.emailController.text, 'Email');
  //     _stateDocError = _validateTextField(widget.lastNameController.text, 'Last Name');
  //     _PasswordDocError = _validateTextField(widget.passwordController.text, 'Password');
  //     if (selectedDeptId == null || selectedDeptId == 0) {  // Assuming 1 is the default "Select Department"
  //       _departmentError = "Please select a department";
  //       isFormValid = false;
  //     } else {
  //       _departmentError = null;
  //     }
  //   });
  //   _isFormValid = isFormValid;
  // }

  void _validateForm() {
    final nameError = _validateTextField(widget.firstNameController.text, 'First Name');
    final lastNameError = _validateTextField(widget.lastNameController.text, 'Last Name');
    final emailError = _validateTextField(widget.emailController.text, 'Email');
    final passwordError = _validateTextField(widget.passwordController.text, 'Password');
    final deptError = (selectedDeptId == null || selectedDeptId == 0)
        ? "Please select a department"
        : null;

    setState(() {
      _nameDocError = nameError;
      _stateDocError = lastNameError;
      _emailDocError = emailError;
      _PasswordDocError = passwordError;
      _departmentError = deptError;
    });

    _isFormValid = [
      nameError,
      lastNameError,
      emailError,
      passwordError,
      deptError
    ].every((error) => error == null);
  }



  var deptId = 1;
  int? firstDeptId;
  String selectedDeptName = "Select Department";
  int? selectedDeptId;

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(width: 410,
      height: AppSize.s550,
      //title: "Create User",
      title: widget.title,
      onClear: (){
        widget.firstNameController.clear();
        widget.lastNameController.clear();
        widget.emailController.clear();
        selectedDeptId =  FrontendConfigStore.data!.config.administrationId;
            // AppConfig.AdministrationId;
        Navigator.pop(context);
      },
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                  hintText: "First Name",
                  controller: widget.firstNameController,
                  keyboardType: TextInputType.text,
                  text: "First Name",
                  onChange: () {
                    if (_nameDocError != null) {
                      setState(() {
                        _nameDocError = null;
                      });
                    }
                  }
              ),
              _nameDocError != null ?
              Text(
                _nameDocError!,
                style: CommonErrorMsg.customTextStyle(context),
              ): SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s10,),
              ///
              SMTextfieldAsteric(
                  hintText: 'Last Name',
                  controller: widget.lastNameController,
                  keyboardType: TextInputType.text,
                  text: 'Last Name',
                  onChange: () {
                    if (_stateDocError != null) {
                      setState(() {
                        _stateDocError = null;
                      });
                    }
                  }
              ),
              _stateDocError != null ?
              Text(
                _stateDocError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s12,),
              RichText(
                text: TextSpan(
                  text:"Select Department",
                  style: AllPopupHeadings.customTextStyle(context),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                        color: ColorManager.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.s5,),
              FutureBuilder<List<HRHeadBar>>(
                future: companyHRHeadApi(context, deptId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    List<String>dropDownServiceList =[];
                    return Container(
                        alignment: Alignment.center,
                        child: HRUManageDropdown(
                          controller: TextEditingController(text: selectedDeptName ?? ''),
                          labelFontSize: FontSize.s12,
                          items:  dropDownServiceList,
                        )
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ErrorMessageString.noroleAdded,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
                  }
                  if (snapshot.hasData) {

                    List<String> dropDownServiceList = snapshot.data!.map((dept) => dept.deptName!).toList();
                    return HRUManageDropdown(
                      controller: TextEditingController(
                          text: selectedDeptName ?? ''),
                      hintText: "Department",
                      labelFontSize: FontSize.s12,
                      items: dropDownServiceList,
                      onChanged: (val) {
                        setState(() {
                          _departmentError = null;
                          selectedDeptName = val;
                          selectedDeptId = snapshot.data!.firstWhere((dept) => dept.deptName == val).deptId;
                        });
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
              _departmentError != null ?
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  _departmentError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ),
              )
                  : SizedBox(height: AppSize.s14,),
              SizedBox(height: AppSize.s9,),
              SMTextfieldAsteric(
                  hintText: 'Email',
                  controller: widget.emailController,
                  keyboardType: TextInputType.emailAddress,
                  text: 'Email',
                  onChange: () {
                    if (_emailDocError != null) {
                      setState(() {
                        _emailDocError = null;
                      });
                    }
                  }),
              _emailDocError != null ?  // Display error if any
              Text(
                _emailDocError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s12,),
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text("Password",
                    style: AllPopupHeadings.customTextStyle(context)),
              ),
              SizedBox(height: AppSize.s5,),
              CustomTextFieldWithIcon(
                controller: widget.passwordController,
                // suffixIcon: Icon(Icons.copy, size: 14,color: Colors.black),
                keyboardType: TextInputType.text,
                text: "Password",
                cursorHeight: 12,
                // labelText: "Password",
                hintText: "Password",
                labelStyle: TextStyle(),
                labelFontSize: 12,
                errorText: 'Password is required',
                onSuffixIconPressed: _copyToClipboard,
              ),
              _PasswordDocError != null ?
              Text(
                _PasswordDocError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
            ],
          ),
        )

      ],
      bottomButtons: isLoading
          ? SizedBox(
        height: AppSize.s30,
        width: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        height: AppSize.s30,
        width: AppSize.s120,
        text: 'Create',
        onPressed: () async {
          // Validate the form fields first
          _validateForm();

          // Check if form is valid
          if (!_isFormValid) return; // Stop here if form is invalid

          // Check if password length is sufficient
          if (widget.passwordController.text.length < 6) {
            setState(() {
              _PasswordDocError = "Password must be longer than or equal to 6 characters";
            });
            return; // Exit if password validation fails
          }

          // If validations are successful, show loader and proceed
          setState(() {
            isLoading = true;
          });

          print('$selectedDeptId');
          print('${widget.firstNameController.text}');
          print('${widget.lastNameController.text}');
          print('${widget.emailController.text}');
          print('${widget.passwordController.text}');

          try {
            var response = await createUserPost(
              context,
              widget.firstNameController.text,
              widget.lastNameController.text,
              selectedDeptId!,
              widget.emailController.text,
              widget.passwordController.text,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              widget.firstNameController.clear();
              widget.lastNameController.clear();
              widget.emailController.clear();
              setState(() {
                selectedDeptName = "Select Department";
                selectedDeptId = null;
              });

              Navigator.pop(context);

              // ✅ Refresh the user list in SeeAllScreen
              widget.onUserCreated?.call();

              // ✅ Show success popup
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSuccessPopup(
                    message: 'User Added Successfully',
                  );
                },
              );
            } else {
              // Handle other errors, such as email already used
              showDialog(
                context: context,
                builder: (BuildContext context) => FailedPopup(text: response.message),
              );
            }
          } catch (e) {
            print('Create user error: $e');
            // Handle unexpected errors
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) => FailedPopup(text: e.toString()),
            // );
          } finally {
            setState(() {
              isLoading = false; // Ensure loader is always reset
            });
          }
        },
      ),
    );
  }
}


///CustomTextFieldWithIcon
class CustomTextFieldWithIcon extends StatefulWidget {
  final TextEditingController controller;
  final Icon? suffixIcon;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final double cursorHeight;
  final String? labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final double labelFontSize;
  final FocusNode? focusNode;
  final String? errorText;
  final VoidCallback? onSuffixIconPressed;
  final Function(String)? onChanged;
  // Callback for suffix icon

  const CustomTextFieldWithIcon({
    Key? key,
    required this.controller,
    this.suffixIcon,
    required this.keyboardType,
    required this.text,
    required this.cursorHeight,
    this.labelText,
    this.labelStyle,
    required this.labelFontSize,
    this.errorText,
    this.onSuffixIconPressed,  // Callback for suffix icon
    this.focusNode, this.hintText,
    this.textColor = const Color(0xff686464), this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextFieldWithIcon> createState() => _CustomTextFieldWithIconState();
}

class _CustomTextFieldWithIconState extends State<CustomTextFieldWithIcon> {
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    hasError = false;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 354,
      child: TextFormField(
        focusNode: widget.focusNode,
        controller: widget.controller,
        textAlign: TextAlign.start,
        style:  DocumentTypeDataStyle.customTextStyle(context),
        textAlignVertical: TextAlignVertical.center,
        cursorColor: ColorManager.black,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
              bottom: AppPadding.p3,
              top: AppPadding.p5,
              left: AppPadding.p10
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: widget.labelText,
          labelStyle: DocumentTypeDataStyle.customTextStyle(context),
          errorText: hasError ? widget.errorText : null,
          suffixIcon: IconButton(
            icon: widget.suffixIcon ?? Icon(Icons.copy, size: IconSize.I14,color: Colors.black),
            onPressed: widget.onSuffixIconPressed,
          ),
        ),

      ),
    );
  }
}


/// edit user
class EditUserPopUp extends StatefulWidget {
  final String title;
  final String deptName;
  final int userId;
  final String firstname;
  final String lastname;
  final String email;
  final int departmentId;
  final String department;
  final bool? enable;
  EditUserPopUp(
      {required this.title,
        required this.userId,
        this.enable,
        required this.deptName,
        required this.firstname,
        required this.lastname, required this.email,
        required this.departmentId, required this.department});

  @override
  State<EditUserPopUp> createState() => _EditUserPopUpState();
}

class _EditUserPopUpState extends State<EditUserPopUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var deptId = 1;
  String? selectedDeptName;
  int? selectedDeptId;

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? emailError;

  @override
  void initState() {
    super.initState();
    selectedDeptName = widget.deptName;
    selectedDeptId = widget.departmentId;
    firstnameController.text = widget.firstname;
    lastnameController.text = widget.lastname;
    emailController.text = widget.email;
  }
  void validateFields() {
    setState(() {
      firstNameError = firstnameController.text.isEmpty ? "First Name is required" : null;
      lastNameError = lastnameController.text.isEmpty ? "Last Name is required" : null;
      emailError = emailController.text.isEmpty ? "Email is required" : null;
    });
  }

  bool isFormValid() {
    validateFields();
    return firstNameError == null && lastNameError == null && emailError == null;
  }
  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      height: AppSize.s470,
      width: AppSize.s400,
      title: widget.title,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SMTextfieldAsteric(
                controller: firstnameController,
                keyboardType: TextInputType.text,
                text: "First Name",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      firstNameError = null;
                    });
                  }
                },
              ),
              firstNameError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    firstNameError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                ],
              ): SizedBox(height: AppSize.s12,),

              SizedBox(height: AppSize.s5,),
              ///
              SMTextfieldAsteric(
                controller:lastnameController,
                keyboardType: TextInputType.text,
                text: 'Last Name',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      lastNameError = null;
                    });
                  }
                },
              ),
              lastNameError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    lastNameError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                ],
              ): SizedBox(height: AppSize.s12,),

              SizedBox(height: AppSize.s8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Select Department',
                    style: AllPopupHeadings.customTextStyle(context),

                  ),
                ],
              ),
              SizedBox(height: AppSize.s5,),
              FutureBuilder<List<HRHeadBar>>(
                future: companyHRHeadApi(context, deptId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    List<String>dropDownServiceList =[];
                    return Container(
                        alignment: Alignment.center,
                        child:
                        HRUManageDropdown(
                          controller: TextEditingController(text: selectedDeptName),
                          labelFontSize: FontSize.s12,
                          items:  dropDownServiceList,
                        )
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        ErrorMessageString.noroleAdded,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
                  }
                  if (snapshot.hasData) {

                    List<String> dropDownServiceList = snapshot.data!
                        .map((dept) => dept.deptName)
                        .toList();
                    // String? firstDeptName =
                    // snapshot.data!.isNotEmpty
                    //     ? snapshot.data![0].deptName
                    //     : null;
                    // int? firstDeptId = snapshot.data!.isNotEmpty
                    //     ? snapshot.data![0].deptId
                    //     : null;
                    //
                    // if (selectedDeptName == null &&
                    //     dropDownServiceList.isNotEmpty) {
                    //   selectedDeptName = widget.deptName;
                    //   selectedDeptId = widget.departmentId;
                    // }

                    return HRUManageDropdown(
                      controller: TextEditingController(
                          text: selectedDeptName ?? ''),
                      hintText: "Department",
                      labelFontSize: 12,
                      items: dropDownServiceList,
                      onChanged: (val) {
                        setState(() {
                          selectedDeptName = val;

                          selectedDeptId = snapshot.data!
                              .firstWhere(
                                  (dept) => dept.deptName == val)
                              .deptId;
                        });
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
              SizedBox(height: AppSize.s20,),
              SMTextfieldAsteric(controller: emailController,
                keyboardType: TextInputType.emailAddress,
                text: 'Email',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      emailError = null;
                    });
                  }
                },),
              emailError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    emailError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                ],
              ): SizedBox(height: AppSize.s12,),
            ],
          ),
        )
      ],
      bottomButtons: ReusableLoadingButton(
        height: AppSize.s30,
        width: AppSize.s120,
        text: 'Submit',
        onPressed: ()  async{
          if(!isFormValid()) return;

          String FName = firstnameController.text.isNotEmpty
              ? firstnameController.text
              : widget.firstname;

          String LDocName = lastnameController.text.isNotEmpty
              ? lastnameController.text
              : widget.lastname;

          String EDocName = emailController.text.isNotEmpty
              ? emailController.text
              : widget.email;

          var responce = await updateUserPatch(
              context:
              context,
              userId: widget.userId,
              firstName: FName,
              lastName:LDocName,
              deptId: selectedDeptId!,
              email:EDocName

          );

          print('<<<<<<<<<<<....Response Status Code: ${responce.statusCode}');
          print('>>>>..........Response Body: ${responce.data}');

          if(responce.statusCode == 200 || responce.statusCode == 201){
            // print('.....Response: ${responce.statusCode} - ${responce.data}');
            // print('......>>>>>>Response: ${selectedDeptId} - ${responce.data}');

            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddSuccessPopup(
                  message: 'User Edit Successfully',
                );
              },
            );
          }
          else {
            showDialog(
              context: context,
              builder: (BuildContext context) => FailedPopup(text: responce.message),
            );
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
        },
        loadingDuration: 2,
      ),
    );
  }
}

///CustomIconButtonProvider using provider

// class ButtonProvider extends ChangeNotifier {
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
//
// class CustomIconButtonProvider extends StatelessWidget {
//   final String text;
//   final IconData? icon;
//   final Color? color;
//   final Color? textColor;
//   final Future<void> Function() onPressed;
//
//   const CustomIconButtonProvider({
//     required this.text,
//     this.icon,
//     required this.onPressed,
//     this.color,
//     this.textColor,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final buttonProvider = Provider.of<ButtonProvider>(context);
//
//     return buttonProvider.isLoading
//         ?  SizedBox(
//       height: 25,
//       width: 25,
//       child: CircularProgressIndicator(
//         color: ColorManager.bluebottom
//       ),
//     )
//         : ElevatedButton.icon(
//       onPressed: () async {
//         buttonProvider.setLoading(true);
//         try {
//           await onPressed();
//         } finally {
//           buttonProvider.setLoading(false);
//         }
//       },
//       icon: icon != null
//           ? Icon(icon, color: Colors.white, size: 20)
//           : const SizedBox.shrink(),
//       label: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: 14, // Replace with your `FontSize.s14`
//           fontWeight: FontWeight.w500,
//           color: textColor ?? Colors.white,
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         backgroundColor: color ?? const Color(0xFF50B5E5),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 5,
//       ),
//     );
//   }
// }


///HRUManageDropdown
class HRUManageDropdownP extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Color textColor;
  final double labelFontSize;
  final List<String> items;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  HRUManageDropdownP({
    Key? key,
    required this.controller,
    this.labelText,
    required this.labelFontSize,
    required this.items,
    this.errorText,
    this.onChanged,
    this.hintText,
    this.textColor = const Color(0xff686464),
  }) : super(key: key);

  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  void _toggleDropdown(BuildContext context) {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown(context);
    }
  }

  void _openDropdown(BuildContext context) {
    final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height,
                width: size.width,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200, // Show scroll for more than 5 items
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            items[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.s13,
                              color: ColorManager.mediumgrey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          onTap: () {
                            controller.text = items[index];
                            _closeDropdown();
                            if (onChanged != null) {
                              onChanged!(items[index]);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context)?.insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleDropdown(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null)
            Text(
              labelText!,
              style: TableSubHeading.customTextStyle(context),
            ),
          Container(
            key: _dropdownKey,
            width: 354,
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? hintText ?? '' : controller.text,
                  style: TableSubHeading.customTextStyle(context),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}


















//
// ///
// class CustomTextFieldWithIcon extends StatefulWidget {
//   final TextEditingController controller;
//   final Icon? suffixIcon;
//   final TextInputType keyboardType;
//   final String text;
//   final Color textColor;
//   final double cursorHeight;
//   final String? labelText;
//   final String? hintText;
//   final TextStyle? labelStyle;
//   final double labelFontSize;
//   final FocusNode? focusNode;
//   final String? errorText;
//   final VoidCallback? onSuffixIconPressed;  // Callback for suffix icon
//
//   const CustomTextFieldWithIcon({
//     Key? key,
//     required this.controller,
//     this.suffixIcon,
//     required this.keyboardType,
//     required this.text,
//     required this.cursorHeight,
//      this.labelText,
//     this.labelStyle,
//     required this.labelFontSize,
//     this.errorText,
//     this.onSuffixIconPressed,  // Callback for suffix icon
//     this.focusNode, this.hintText,
//     this.textColor = const Color(0xff686464),
//   }) : super(key: key);
//
//   @override
//   State<CustomTextFieldWithIcon> createState() => _CustomTextFieldWithIconState();
// }
//
// class _CustomTextFieldWithIconState extends State<CustomTextFieldWithIcon> {
//    bool hasError = false;
//
//    @override
//    void initState() {
//      super.initState();
//      hasError = false;
//    }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       width: 354,
//       child: TextFormField(
//         focusNode: widget.focusNode,
//         controller: widget.controller,
//         textAlign: TextAlign.start,
//         style:  DocumentTypeDataStyle.customTextStyle(context),
//         textAlignVertical: TextAlignVertical.center,
//         cursorColor: ColorManager.black,
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.only(
//               bottom: AppPadding.p3,
//               top: AppPadding.p5,
//               left: AppPadding.p12
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: ColorManager.containerBorderGrey, width: 1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           labelText: widget.labelText,
//           labelStyle: DocumentTypeDataStyle.customTextStyle(context),
//            errorText: hasError ? widget.errorText : null,
//           suffixIcon: IconButton(
//             icon: widget.suffixIcon ?? Icon(Icons.copy, size: IconSize.I14,color: Colors.black),
//             onPressed: widget.onSuffixIconPressed, // Use widget.onSuffixIconPressed
//           ),
//         ),
//
//       ),
//     );
//   }
// }
//
//
// /// edit user
// class EditUserPopUp extends StatefulWidget {
//   final String title;
//   final String deptName;
//  final int userId;
//   final String firstname;
//   final String lastname;
//   final String email;
//   final int departmentId;
//   final String department;
//   final bool? enable;
//   EditUserPopUp(
//       {required this.title,
//         required this.userId,
//         this.enable,
//         required this.deptName, required this.firstname, required this.lastname, required this.email, required this.departmentId, required this.department});
//
//   @override
//   State<EditUserPopUp> createState() => _EditUserPopUpState();
// }
//
// class _EditUserPopUpState extends State<EditUserPopUp> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   var deptId = 1;
//   int? firstDeptId;
//   String? selectedDeptName;
//   int? selectedDeptId;
//
//   TextEditingController firstnameController = TextEditingController();
//   TextEditingController lastnameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     firstnameController.text = widget.firstname;
//     lastnameController.text = widget.lastname;
//     emailController.text = widget.email;
//   }
//   @override
//   Widget build(BuildContext context) {
//     return DialogueTemplate(
//       height: AppSize.s450,
//       width: AppSize.s400,
//       title: widget.title,
//       body: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             children: [
//               SMTextfieldAsteric(
//                 controller: firstnameController,
//                 keyboardType: TextInputType.text,
//                 text: "First Name",
//               ),
//               // if (_nameDocError != null) // Display error if any
//               //   Text(
//               //     _nameDocError!,
//               //     style: CommonErrorMsg.customTextStyle(context),
//               //   ),
//               SizedBox(height: 5,),
//               ///
//               SMTextfieldAsteric(
//                 controller:lastnameController,
//                 keyboardType: TextInputType.text,
//                 text: 'Last Name',
//               ),
//               // if (_stateDocError != null) // Display error if any
//               //   Text(
//               //     _stateDocError!,
//               //     style: CommonErrorMsg.customTextStyle(context),
//               //   ),
//               SizedBox(height: AppSize.s10,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                       'Select Department',
//                       style: AllPopupHeadings.customTextStyle(context)),
//                 ],
//               ),
//               SizedBox(height: AppSize.s5,),
//               FutureBuilder<List<HRHeadBar>>(
//                 future: companyHRHeadApi(context, deptId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     List<String>dropDownServiceList =[];
//                     return Container(
//                         alignment: Alignment.center,
//                         child:
//                         HRUManageDropdown(
//                           controller: TextEditingController(text: ''),
//                           labelFontSize: FontSize.s12,
//                           items:  dropDownServiceList,
//                         )
//                     );
//                   }
//                   if (snapshot.hasData &&
//                       snapshot.data!.isEmpty) {
//                     return Center(
//                       child: Text(
//                         ErrorMessageString.noroleAdded,
//                         style: AllNoDataAvailable.customTextStyle(context),
//                       ),
//                     );
//                   }
//                   if (snapshot.hasData) {
//                     // Extract dropdown items from snapshot
//                     List<String> dropDownServiceList = snapshot
//                         .data!
//                         .map((dept) => dept.deptName)
//                         .toList();
//                     String? firstDeptName =
//                     snapshot.data!.isNotEmpty
//                         ? snapshot.data![0].deptName
//                         : null;
//                     int? firstDeptId = snapshot.data!.isNotEmpty
//                         ? snapshot.data![0].deptId
//                         : null;
//
//                     if (selectedDeptName == null &&
//                         dropDownServiceList.isNotEmpty) {
//                       selectedDeptName = widget.department;
//                       selectedDeptId = widget.departmentId;
//                     }
//
//                     return HRUManageDropdown(
//                       controller: TextEditingController(
//                           text: selectedDeptName ?? ''),
//                       hintText: "Department",
//                       labelFontSize: 12,
//                       items: dropDownServiceList,
//                       onChanged: (val) {
//                         setState(() {
//                           selectedDeptName = val;
//                           // Find the corresponding department ID from the snapshot
//                           selectedDeptId = snapshot.data!
//                               .firstWhere(
//                                   (dept) => dept.deptName == val)
//                               .deptId;
//                         });
//                       },
//                     );
//                   }
//                   return const SizedBox();
//                 },
//               ),
//               SizedBox(height: 14,),
//               SMTextfieldAsteric(controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   text: 'Email'),
//             ],
//           ),
//         )
//       ],
//       bottomButtons: ReusableLoadingButton(
//         height: AppSize.s30,
//         width: AppSize.s120,
//         text: 'Submit',
//         onPressed: ()  async{
//
//           String FName = firstnameController.text.isNotEmpty
//               ? firstnameController.text
//               : widget.firstname;
//
//           String LDocName = lastnameController.text.isNotEmpty
//               ? lastnameController.text
//               : widget.lastname;
//
//           String EDocName = emailController.text.isNotEmpty
//               ? emailController.text
//               : widget.email;
//
//           var responce = await updateUserPatch(
//           context:
//           context,
//           userId: widget.userId,
//           firstName: FName,
//           lastName:LDocName,
//           deptId: selectedDeptId!,
//           email:EDocName
//
//           );
//           if(responce.statusCode == 200 || responce.statusCode == 201){
//             Navigator.pop(context);
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AddSuccessPopup(
//                   message: 'User Edit Successfully',
//                 );
//               },
//             );
//           }else {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) => FailedPopup(text: responce.message),
//             );
//           }
//         },
//         loadingDuration: 2,
//       ),
//     );
//   }
// }
//
