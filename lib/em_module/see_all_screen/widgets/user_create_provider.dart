import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/user.dart';
import 'package:prohealth/data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:prohealth/presentation/screens/em_module/see_all_screen/widgets/user_delete_provider.dart';
import 'package:prohealth/presentation/screens/em_module/see_all_screen/widgets/user_popup_const_provider.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:prohealth/presentation/widgets/widgets/constant_textfield/const_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserCreationProvider with ChangeNotifier {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? _nameDocError;
  String? _emailDocError;
  String? _stateDocError;
  String? _passwordDocError;

  bool isLoading = false;
  bool _isFormValid = true;

  // Getter methods for error messages
  String? get nameDocError => _nameDocError;
  String? get emailDocError => _emailDocError;
  String? get stateDocError => _stateDocError;
  String? get passwordDocError => _passwordDocError;

  bool get isFormValid => _isFormValid;

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    _nameDocError = null;
    _emailDocError = null;
    _stateDocError = null;
    _passwordDocError = null;
    _isFormValid = true;
    notifyListeners();
  }

  void validateForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    _isFormValid = true;

    // Validate each field
    _nameDocError = _validateTextField(firstName, 'First Name');
    _emailDocError = email.isEmpty
        ? "Please Enter Email"
        : _validateEmail(email); // Validate email format
    _stateDocError = _validateTextField(lastName, 'Last Name');
    _passwordDocError = _validateTextField(password, 'Password');

    // Check if any field has an error
    if (_nameDocError != null ||
        _emailDocError != null ||
        _stateDocError != null ||
        _passwordDocError != null) {
      _isFormValid = false;
    }

    notifyListeners();
  }

  String? _validateEmail(String value) {
    final emailRegExp =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Enter valid email";
    }
    return null;
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      return "Please Enter $fieldName";
    }
    return null;
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}


/// create user provider class
// class UserCreationProvider with ChangeNotifier {
//
//   TextEditingController firstNameController = TextEditingController();
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   // TextEditingController emailController = TextEditingController();
//
//   // Getter for the email
//   String get email => emailController.text;
//   String? _nameDocError;
//   String? _emailDocError;
//   String? _stateDocError;
//   String? _passwordDocError;
//
//   bool isLoading = false;
//   bool _isFormValid = true;
//
//   // Getter methods for error messages
//   String? get nameDocError => _nameDocError;
//   String? get emailDocError => _emailDocError;
//   String? get stateDocError => _stateDocError;
//   String? get passwordDocError => _passwordDocError;
//
//   bool get isFormValid => _isFormValid;
//
//   void clearForm() {
//     firstNameController.clear();
//     lastNameController.clear();
//     emailController.clear();
//     passwordController.clear();
//     _isFormValid = true;
//     notifyListeners();
//   }
//
//
//   void validateForm() {
//     _isFormValid = true;
//     _nameDocError = _validateTextField(firstNameController.text, 'First Name');
//     _emailDocError = _validateTextField(emailController.text, 'Email');
//     _stateDocError = _validateTextField(lastNameController.text, 'Last Name');
//     _passwordDocError = _validateTextField(passwordController.text, 'Password');
//
//     if (_nameDocError != null || _emailDocError != null || _stateDocError != null || _passwordDocError != null) {
//       _isFormValid = false;
//     }
//
//     notifyListeners();
//   }
//
//
//
// /// Updated method to validate email format
//   String? _validateEmail(String value) {
//     final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//     if (value.isEmpty) {
//       return "Please Enter Email";
//     } else if (!emailRegExp.hasMatch(value)) {
//       return "Enter valid email";
//     }
//     return null;
//   }
//
//   String? _validateTextField(String value, String fieldName) {
//     if (value.isEmpty) {
//       return "Please Enter $fieldName";
//     }
//     return null;
//   }
//
//   /// Method to create a user (simulate API call)
//   Future<void> createUser(BuildContext context) async {
//     validateForm();
//
//     if (!_isFormValid) return;
//
//     isLoading = true;
//     notifyListeners();
//
//     try {
//
//       await Future.delayed(Duration(seconds: 2));
//
//       // Show success message
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Text('User Created Successfully'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//
//
//       clearForm();
//     } catch (e) {
//
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: Text('Error: ${e.toString()}'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// }

/// dept dropdown provider class
class DepartmentProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<HRHeadBar> _departments = [];
  String? _selectedDeptName;
  int? _selectedDeptId;

  bool get isLoading => _isLoading;
  List<HRHeadBar> get departments => _departments;
  String? get selectedDeptName => _selectedDeptName;
  int? get selectedDeptId => _selectedDeptId;

  void setSelectedDept(String? deptName) {
    _selectedDeptName = deptName;
    _selectedDeptId = _departments
        .firstWhere((dept) => dept.deptName == deptName)
        .deptId;
    notifyListeners();
  }

  Future<void> fetchDepartments(BuildContext context, int deptId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Pass the BuildContext to the companyHRHeadApi function
      _departments = await companyHRHeadApi(context, deptId);
    } catch (e) {
      // Handle error
      _departments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}


///with provider UserFormProvider
class UserFormProvider extends ChangeNotifier {
  bool _isFormValid = true;
  bool _isLoading = false;
  String? _nameDocError;
  String? _emailDocError;
  String? _stateDocError;
  String? _PasswordDocError;

  bool get isFormValid => _isFormValid;
  bool get isLoading => _isLoading;
  String? get nameDocError => _nameDocError;
  String? get emailDocError => _emailDocError;
  String? get stateDocError => _stateDocError;
  String? get passwordDocError => _PasswordDocError;

  void validateForm(
      String firstName,
      String lastName,
      String email,
      String password,
      ) {
    _isFormValid = true;
    _nameDocError = _validateTextField(firstName, 'First Name');
    _emailDocError = _validateTextField(email, 'Email');
    _stateDocError = _validateTextField(lastName, 'Last Name');
    _PasswordDocError = _validateTextField(password, 'Password');

    if (_nameDocError != null || _emailDocError != null || _stateDocError != null || _PasswordDocError != null) {
      _isFormValid = false;
    }

    notifyListeners();
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      return "Please Enter $fieldName";
    }
    return null;
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}

///CustomDialoghSEE using provider
// class CustomDialoghSEE extends StatelessWidget {
//   final String title;
//   final TextEditingController lastNameController;
//   final TextEditingController emailController;
//   final TextEditingController firstNameController;
//   final TextEditingController passwordController;
//
//   CustomDialoghSEE({
//     required this.title,
//     required this.lastNameController,
//     required this.emailController,
//     required this.firstNameController,
//     required this.passwordController,
//   });
//
//   var deptId = 1;
//   String? selectedDeptName;
//   int? selectedDeptId;
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => UserFormProvider(),
//       child: Consumer<UserFormProvider>(
//         builder: (context, formProvider, child) {
//           return DialogueTemplate(
//             width: 410,
//             height: 550,
//             title: title,
//             onClear: () {
//               firstNameController.clear();
//               lastNameController.clear();
//               emailController.clear();
//               passwordController.clear();
//               Navigator.pop(context);
//             },
//             body: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SMTextfieldAsteric(
//                       controller: firstNameController,
//                       keyboardType: TextInputType.text,
//                       text: "First Name",
//                     ),
//                     if (formProvider.nameDocError != null)
//                       Text(
//                         formProvider.nameDocError!,
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     SizedBox(height: 5),
//                     SMTextfieldAsteric(
//                       controller: lastNameController,
//                       keyboardType: TextInputType.text,
//                       text: "Last Name",
//                     ),
//                     if (formProvider.stateDocError != null)
//                       Text(
//                         formProvider.stateDocError!,
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     SizedBox(height: 10),
//                     // Department Dropdown
//                     RichText(
//                       text: TextSpan(
//                         text: "Select Department",
//                         style: AllPopupHeadings.customTextStyle(context),
//                         children: [
//                           TextSpan(
//                             text: ' *',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     // FutureBuilder for fetching departments
//                     FutureBuilder<List<HRHeadBar>>(
//                       future: companyHRHeadApi(context, deptId), // Pass the context first
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           List<String> dropDownServiceList = [];
//                           return Container(
//                               alignment: Alignment.center,
//                               child: HRUManageDropdown(
//                                 controller: TextEditingController(text: ''),
//                                 labelFontSize: FontSize.s12,
//                                 items: dropDownServiceList,
//                               ));
//                         }
//                         if (snapshot.hasData && snapshot.data!.isEmpty) {
//                           return Center(
//                             child: Text(
//                               ErrorMessageString.noroleAdded,
//                               style: AllNoDataAvailable.customTextStyle(context),
//                             ),
//                           );
//                         }
//                         if (snapshot.hasData) {
//                           List<String> dropDownServiceList = snapshot
//                               .data!
//                               .map((dept) => dept.deptName!)
//                               .toList();
//                           String? firstDeptName = snapshot.data!.isNotEmpty
//                               ? snapshot.data![0].deptName
//                               : null;
//                           int? firstDeptId = snapshot.data!.isNotEmpty
//                               ? snapshot.data![0].deptId
//                               : null;
//
//                           if (selectedDeptName == null && dropDownServiceList.isNotEmpty) {
//                             selectedDeptName = firstDeptName;
//                             selectedDeptId = firstDeptId;
//                           }
//
//                           return StatefulBuilder(
//                             builder: (BuildContext context, void Function(void Function()) setState) {
//                               return HRUManageDropdown(
//                                 controller: TextEditingController(text: selectedDeptName ?? ''),
//                                 hintText: "Department",
//                                 labelFontSize: FontSize.s12,
//                                 items: dropDownServiceList,
//                                 onChanged: (val) {
//                                   setState(() {
//                                     selectedDeptName = val;
//                                     selectedDeptId = snapshot.data!
//                                         .firstWhere((dept) => dept.deptName == val)
//                                         .deptId;
//                                   });
//                                 },
//                               );
//                             },
//                           );
//                         }
//                         return const SizedBox();
//                       },
//                     ),
//                     ///
//                     SizedBox(height: 14),
//                     SMTextfieldAsteric(
//                       controller: emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       text: 'Email',
//                     ),
//                     if (formProvider.emailDocError != null)
//                       Text(
//                         formProvider.emailDocError!,
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ///
//
//                     SizedBox(height: 14),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 1),
//                       child: Text(
//                         "Password",
//                         style:AllPopupHeadings.customTextStyle(context),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     CustomTextFieldWithIcon(
//                       controller: passwordController,
//                       keyboardType: TextInputType.text,
//                       text: "Password",
//                       cursorHeight: 12,
//                       hintText: "Password",
//                       onSuffixIconPressed: () {
//                         Clipboard.setData(ClipboardData(text: passwordController
//                             .text));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Copied to clipboard')),
//                         );
//                       },  labelFontSize: 12,
//                     ),
//                     if (formProvider.passwordDocError != null)
//                       Text(
//                         formProvider.passwordDocError!,
//                         style: TextStyle(color: Colors.red),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//             bottomButtons: formProvider.isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//               onPressed: () async {
//                 formProvider.validateForm(
//                   firstNameController.text,
//                   lastNameController.text,
//                   emailController.text,
//                   passwordController.text,
//                 );
//
//                 if (formProvider.isFormValid) {
//                   formProvider.setLoading(true);
//                   try {
//
//                     var response = await createUserPost(
//                       context,
//                       firstNameController.text,
//                       lastNameController.text,
//                       selectedDeptId!,
//                       emailController.text,
//                       passwordController.text,
//                     );
//
//                     if (response.success) {
//                       Navigator.pop(context);
//                     } else {
//
//                       print(response.message);
//                     }
//                   } catch (e) {
//                     // Handle error
//                     print("Error: $e");
//                   } finally {
//                     formProvider.setLoading(false);
//                   }
//                 }
//               },
//               child: Text('Create'),
//             ),
//             ///
//
//           );
//         },
//       ),
//     );
//   }
// }
///

class CustomDialoghSEE extends StatelessWidget {
  final String title;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController passwordController;

  CustomDialoghSEE({
    required this.title,
    required this.lastNameController,
    required this.emailController,
    required this.firstNameController,
    required this.passwordController,
  });

  var deptId = 1;
  String? selectedDeptName;
  int? selectedDeptId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserCreationProvider(),
      child: Consumer<UserCreationProvider>(
        builder: (context, formProvider, child) {
          return DialogueTemplate(
            width: 410,
            height: 550,
            title: title,
            onClear: () {
              formProvider.clearForm();
              Navigator.pop(context);
            },
            body: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SMTextfieldAsteric(
                      controller: firstNameController,
                      keyboardType: TextInputType.text,
                      text: "First Name",
                    ),
                    if (formProvider.nameDocError != null)
                      Text(
                        formProvider.nameDocError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 5),
                    SMTextfieldAsteric(
                      controller: lastNameController,
                      keyboardType: TextInputType.text,
                      text: "Last Name",
                    ),
                    if (formProvider.stateDocError != null)
                      Text(
                        formProvider.stateDocError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "Select Department",
                        style: AllPopupHeadings.customTextStyle(context),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    // FutureBuilder<List<HRHeadBar>>(
                    //   future: companyHRHeadApi(context, deptId), // This should trigger a new fetch every time the dialog is opened
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       List<String> dropDownServiceList = [];
                    //       return Container(
                    //         alignment: Alignment.center,
                    //         child: HRUManageDropdownP(
                    //           controller: TextEditingController(text: ''),
                    //           labelFontSize: FontSize.s12,
                    //           items: dropDownServiceList,
                    //         ),
                    //       );
                    //     }
                    //
                    //     if (snapshot.hasData && snapshot.data!.isEmpty) {
                    //       return Center(
                    //         child: Text(
                    //           ErrorMessageString.noroleAdded,
                    //           style: AllNoDataAvailable.customTextStyle(context),
                    //         ),
                    //       );
                    //     }
                    //
                    //     if (snapshot.hasData) {
                    //       List<String> dropDownServiceList = snapshot
                    //           .data!
                    //           .map((dept) => dept.deptName!)
                    //           .toList();
                    //       String? firstDeptName = snapshot.data!.isNotEmpty
                    //           ? snapshot.data![0].deptName
                    //           : null;
                    //       int? firstDeptId = snapshot.data!.isNotEmpty
                    //           ? snapshot.data![0].deptId
                    //           : null;
                    //
                    //       // Reset the selected department if it's null
                    //       if (selectedDeptName == null && dropDownServiceList.isNotEmpty) {
                    //         selectedDeptName = firstDeptName;
                    //         selectedDeptId = firstDeptId;
                    //       }
                    //
                    //       return StatefulBuilder(
                    //         builder: (BuildContext context, void Function(void Function()) setState) {
                    //           return HRUManageDropdownP(
                    //             controller: TextEditingController(text: selectedDeptName ?? ''),
                    //             hintText: "Department",
                    //             labelFontSize: FontSize.s12,
                    //             items: dropDownServiceList,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 selectedDeptName = val;
                    //                 selectedDeptId = snapshot.data!
                    //                     .firstWhere((dept) => dept.deptName == val)
                    //                     .deptId;
                    //               });
                    //             },
                    //           );
                    //         },
                    //       );
                    //     }
                    //
                    //     return const SizedBox();
                    //   },
                    // ),
///
                    // FutureBuilder<List<HRHeadBar>>(
                    //   future: companyHRHeadApi(context, deptId),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       List<String> dropDownServiceList = [];
                    //       return Container(
                    //         alignment: Alignment.center,
                    //         child: HRUManageDropdownP(
                    //           controller: TextEditingController(text: ''),
                    //           labelFontSize: FontSize.s12,
                    //           items: dropDownServiceList,
                    //         ),
                    //       );
                    //     }
                    //     if (snapshot.hasData && snapshot.data!.isEmpty) {
                    //       return Center(
                    //         child: Text(
                    //           ErrorMessageString.noroleAdded,
                    //           style: AllNoDataAvailable.customTextStyle(context),
                    //         ),
                    //       );
                    //     }
                    //     if (snapshot.hasData) {
                    //       List<String> dropDownServiceList = snapshot
                    //           .data!
                    //           .map((dept) => dept.deptName!)
                    //           .toList();
                    //       String? firstDeptName = snapshot.data!.isNotEmpty
                    //           ? snapshot.data![0].deptName
                    //           : null;
                    //       int? firstDeptId = snapshot.data!.isNotEmpty
                    //           ? snapshot.data![0].deptId
                    //           : null;
                    //
                    //       if (selectedDeptName == null && dropDownServiceList.isNotEmpty) {
                    //         selectedDeptName = firstDeptName;
                    //         selectedDeptId = firstDeptId;
                    //       }
                    //
                    //       return StatefulBuilder(
                    //         builder: (BuildContext context, void Function(void Function()) setState) {
                    //           return HRUManageDropdownP(
                    //             controller: TextEditingController(text: selectedDeptName ?? ''),
                    //             hintText: "Department",
                    //             labelFontSize: FontSize.s12,
                    //             items: dropDownServiceList,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 selectedDeptName = val;
                    //                 selectedDeptId = snapshot.data!
                    //                     .firstWhere((dept) => dept.deptName == val)
                    //                     .deptId;
                    //               });
                    //             },
                    //           );
                    //         },
                    //       );
                    //     }
                    //     return const SizedBox();
                    //   },
                    // ),
                    /// Department Dropdown
                    FutureBuilder<List<HRHeadBar>>(
                      future: companyHRHeadApi(context, deptId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          List<String> dropDownServiceList = [];
                          return Container(
                              alignment: Alignment.center,
                              child: HRUManageDropdownP(
                                controller: TextEditingController(text: ''),
                                labelFontSize: FontSize.s12,
                                items: dropDownServiceList,
                              ));
                        }
                        if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              ErrorMessageString.noroleAdded,
                              style: AllNoDataAvailable.customTextStyle(context),
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          List<String> dropDownServiceList = snapshot
                              .data!
                              .map((dept) => dept.deptName!)
                              .toList();
                          String? firstDeptName = snapshot.data!.isNotEmpty
                              ? snapshot.data![0].deptName
                              : null;
                          int? firstDeptId = snapshot.data!.isNotEmpty
                              ? snapshot.data![0].deptId
                              : null;

                          if (selectedDeptName == null && dropDownServiceList.isNotEmpty) {
                            selectedDeptName = firstDeptName;
                            selectedDeptId = firstDeptId;
                          }

                          return StatefulBuilder(
                            builder: (BuildContext context, void Function(void Function()) setState) {
                              return HRUManageDropdownP(
                                controller: TextEditingController(text: selectedDeptName ?? ''),
                                hintText: "Department",
                                labelFontSize: FontSize.s12,
                                items: dropDownServiceList,
                                onChanged: (val) {
                                  setState(() {
                                    selectedDeptName = val;
                                    selectedDeptId = snapshot.data!
                                        .firstWhere((dept) => dept.deptName == val)
                                        .deptId;
                                  });
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    SizedBox(height: 14),
                    SMTextfieldAsteric(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      text: 'Email',
                    ),
                    if (formProvider.emailDocError != null)
                      Text(
                        formProvider.emailDocError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Text(
                        "Password",
                        style: AllPopupHeadings.customTextStyle(context),
                      ),
                    ),
                    SizedBox(height: 5),
                    CustomTextFieldWithIcon(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      text: "Password",
                      cursorHeight: 12,
                      hintText: "Password",
                      onSuffixIconPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: passwordController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      labelFontSize: 12,
                    ),
                    if (formProvider.passwordDocError != null)
                      Text(
                        formProvider.passwordDocError!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
            bottomButtons: formProvider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                formProvider.validateForm(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );

                if (formProvider.isFormValid) {
                  formProvider.setLoading(true);
                  try {
                    var response = await createUserPost(
                      context,
                      firstNameController.text,
                      lastNameController.text,
                      selectedDeptId!,
                      emailController.text,
                      passwordController.text,
                    );

                    if (response.success) {
                      Navigator.pop(context);
                    } else {
                      print(response.message);
                    }
                  } catch (e) {
                    print("Error: $e");
                  } finally {
                    formProvider.setLoading(false);
                  }
                }
              },
              child: Text('Create'),
            ),


            ///
            // bottomButtons: formProvider.isLoading
            //     ? CircularProgressIndicator()
            //     : ElevatedButton(
            //   onPressed: () async {
            //     formProvider.validateForm(
            //       firstName: firstNameController.text,
            //       lastName: lastNameController.text,
            //       email: emailController.text,
            //       password: passwordController.text,
            //     );
            //
            //     if (formProvider.isFormValid) {
            //       formProvider.setLoading(true);
            //       try {
            //         var response = await createUserPost(
            //           context,
            //           firstNameController.text,
            //           lastNameController.text,
            //           selectedDeptId!,
            //           emailController.text,
            //           passwordController.text,
            //         );
            //
            //         if (response.success) {
            //           Navigator.pop(context);
            //         } else {
            //           print(response.message);
            //         }
            //       } catch (e) {
            //         print("Error: $e");
            //       } finally {
            //         formProvider.setLoading(false);
            //       }
            //     }
            //   },
            //   child: Text('Create'),
            // ),
          );
        },
      ),
    );
  }
}



