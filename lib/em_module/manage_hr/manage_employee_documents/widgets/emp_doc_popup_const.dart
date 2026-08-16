import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import 'package:provider/provider.dart';
import '../../../../../../app/constants/app_config.dart';
import '../../../../../../app/resources/const_string.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../app/services/api/managers/establishment_manager/employee_doc_manager.dart';
import '../../../../../../app/services/api/repository/establishment_manager/employee_doc_repository.dart';
import '../../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../../widgets/widgets/constant_textfield/const_textfield.dart';
import '../../../company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../widgets/dialogue_template.dart';
import '../../../widgets/header_content_const.dart';


///add popup
class EmpDocADDPopupProvider extends ChangeNotifier {
  TextEditingController daysController = TextEditingController(text: "1");
  String selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
  // String selectedExpiryType = AppConfig.notApplicable;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  bool isDropdownAvailability = false;
  TextEditingController nameDocController = TextEditingController();
  TextEditingController idDocController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  final DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _idError;
  String? _nameError;
  bool _isFormValid = true;
  String? _expiryTypeError;

  EmpDocADDPopupProvider() {
    nameDocController.addListener(() {
      if (_nameError != null && nameDocController.text.isNotEmpty) {
        _nameError = null;
        notifyListeners();
      }
    });
    idDocController.addListener(() {
      if (_idError != null && idDocController.text.isNotEmpty) {
        _idError = null;
        notifyListeners();
      }
    });
  }

  void setSelectedExpiryType(String expiryType) {
    selectedExpiryType = expiryType;
    notifyListeners();
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      return "$fieldName";
    }
    return null;
  }

  void validateFields() {
    _isFormValid = true;
    _idError =
        _validateTextField(idDocController.text, 'Please Enter ID of Document');
    if (_idError != null) _isFormValid = false;

    _nameError = _validateTextField(
        nameDocController.text, 'Please Enter Name of the Document');
    if (_nameError != null) _isFormValid = false;

    if (selectedExpiryType.isEmpty) {
      _expiryTypeError = 'Please select an expiry type';
      _isFormValid = false;
    } else {
      _expiryTypeError = null; // Clear error if valid
    }
    notifyListeners();
  }

  void resetForm() {
    nameDocController.clear();
    idDocController.clear();
    dateController.clear();
    selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    // selectedExpiryType = AppConfig.notApplicable;

    _idError = null;
    _nameError = null;
    _expiryTypeError = null;
    _isFormValid = true;

    notifyListeners();
  }

  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class EmpDocADDPopup extends StatelessWidget {
  final bool? isSaving;
  String? expiryType;
  final String title;
  bool? enable;
  final int Subdocid;
  final VoidCallback onSave;
  EmpDocADDPopup(
      {super.key,
      this.isSaving,
      required this.title,
      required this.Subdocid,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpDocADDPopupProvider>(
        builder: (context, provider, child) {
      return DialogueTemplate(
        width: AppSize.s400,
        height: AppSize.s480,
        body: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SMTextfieldAsteric(
                  controller: provider.idDocController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.idOfDOc,
                ),
                 provider._idError != null ?
                  Text(
                    provider._idError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ): SizedBox(height: AppSize.s12,),
                SizedBox(height: AppSize.s8),
                SMTextfieldAsteric(
                  controller: provider.nameDocController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.NameOfDoc,
                ),
                provider._nameError != null ?
                  Text(
                    provider._nameError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ) : SizedBox(height: AppSize.s12,),
                SizedBox(height: AppSize.s8),
                Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p4),
                  child: Row(
                    children: [
                      HeaderContentConst(
                        isAsterisk: true,
                        heading: AppString.expiry_type,
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomRadioListTile(
                              value: FrontendConfigStore.data!.config.notApplicable,
                              // value: AppConfig.notApplicable,
                              groupValue: provider.selectedExpiryType,
                              onChanged: (value) {
                                // setState(() {
                                provider.selectedExpiryType = value!;
                                provider.notifyListeners();
                                // });
                              },
                              title: FrontendConfigStore.data!.config.notApplicable,
                              // title: AppConfig.notApplicable,
                            ),
                            CustomRadioListTile(
                              value: FrontendConfigStore.data!.config.scheduled,
                              // value: AppConfig.scheduled,
                              groupValue: provider.selectedExpiryType,
                              onChanged: (value) {
                                // setState(() {
                                provider.selectedExpiryType = value!;
                                provider.notifyListeners();
                                // });
                              },
                              title: FrontendConfigStore.data!.config.scheduled,
                              // title: AppConfig.scheduled,
                            ),
                            CustomRadioListTile(
                              value: FrontendConfigStore.data!.config.issuer,
                              // value: AppConfig.issuer,
                              groupValue: provider.selectedExpiryType,
                              onChanged: (value) {
                                //setState(() {
                                provider.selectedExpiryType = value!;
                                provider.notifyListeners();
                                //});
                              },
                              title: FrontendConfigStore.data!.config.issuer,
                              // title: AppConfig.issuer,
                            ),
                            //  provider._expiryTypeError != null ?
                            //   Text(
                            //     provider._expiryTypeError!,
                            //     style: CommonErrorMsg.customTextStyle(context),
                            //   )
                            // : SizedBox(height: 5,),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled,
                        // visible: provider.selectedExpiryType == AppConfig.scheduled,
                        child: Column(
                          children: [
                            SizedBox(
                              height: AppSize.s14,
                            ),
                            Row(
                              children: [
                                Container(
                                  height: AppSize.s30,
                                  width: AppSize.s50,
                                  //color: ColorManager.red,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: provider.daysController, // Use the controller initialized with "1"
                                    cursorColor: ColorManager.black,
                                    cursorWidth: 1,
                                    style: DocumentTypeDataStyle.customTextStyle(context),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // This ensures only digits are accepted
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSize.s10),
                                Container(
                                  width: AppSize.s80,
                                  height: AppSize.s30,
                                  child:CustomDropdownTextFieldwidh(
                                    value: FrontendConfigStore.data!.config.year,
                                    // value: AppConfig.year,
                                    items: [
                                      FrontendConfigStore.data!.config.year,
                                      // AppConfig.year,
                                      FrontendConfigStore.data!.config.month,
                                      // AppConfig.month,
                                    ],

                                    // labelStyle: SearchDropdownConst.customTextStyle(context),
                                    onChanged: (value) {
                                      //  setState(() {
                                      provider.selectedYear = value;
                                      provider.isDropdownAvailability = true;
                                      provider.notifyListeners();
                                      print("Year,month Status :: ${provider.selectedYear}");
                                      //  });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        bottomButtons: provider._isLoading
            ? SizedBox(
                width: AppSize.s30,
                height: AppSize.s30,
                child: CircularProgressIndicator(
                  color: ColorManager.blueprime,
                ),
              )
            : Center(
                child: CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: AppStringEM.add,
                  onPressed: () async {
                    provider.validateFields();
                    if (provider._isFormValid) {
                      provider.setLoading(true);
                      provider.notifyListeners();
                      int threshold = 0;
                      if (provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled && provider.daysController.text.isNotEmpty) {
                      // if (provider.selectedExpiryType == AppConfig.scheduled && provider.daysController.text.isNotEmpty) {
                        int enteredValue =
                            int.parse(provider.daysController.text);
                        if (provider.selectedYear == FrontendConfigStore.data!.config.year) {
                        // if (provider.selectedYear == AppConfig.year) {
                          threshold = enteredValue * 365;
                        } else if (provider.selectedYear == FrontendConfigStore.data!.config.month) {
                        // } else if (provider.selectedYear == AppConfig.month) {
                          threshold = enteredValue * 30;
                        }
                      }
                      try {
                        var response = await addEmployeeDocSetup(
                          context: context,
                          docName: provider.nameDocController.text,
                          expiryDate: "", //expiryDate,
                          remainderThreshold:
                              provider.selectedExpiryType.toString(),
                          empDocMetaDataId: Subdocid,
                          idOfDoc: provider.idDocController.text,
                          expiryType: provider.selectedExpiryType.toString(),
                          threshold: threshold, // Pass calculated or 0
                        );
                        provider.setLoading(false);
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          onSave();
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddSuccessPopup(
                                message: 'Added Successfully',
                              );
                            },
                          );
                        } else if (response.statusCode == 400 ||
                            response.statusCode == 404) {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                const FourNotFourPopup(),
                          );
                        } else {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                FailedPopup(text: response.message),
                          );
                        }
                      } finally {
                        provider._isLoading = false;
                        provider.notifyListeners();
                      }
                    }
                    print(provider.nameDocController.text);
                    print(provider.idDocController.text);
                    print(Subdocid);
                    print(provider.selectedExpiryType.toString());
                    provider.nameDocController.clear();
                    provider.dateController.clear();
                  },
                ),
              ),
        title: title,
      );
    });
  }
}

///edit popup
class EmpDocEditPopupProvider extends ChangeNotifier {
  TextEditingController nameDocController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController calenderController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _nameError;
  String? get nameError => _nameError;

  bool _isFormValid = true;
  bool get isFormValid => _isFormValid;

  String selectedExpiryType = "";
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;

  EmpDocEditPopupProvider() {
    nameDocController.addListener(() {
      // Automatically hide the error message when user starts typing
      if (nameDocController.text.isNotEmpty && _nameError != null) {
        clearNameError();
      }
    });
  }

  // Validate fields
  void validateFields({required String docNameController}) {
    _isFormValid = true;
    _nameError = validateTextField(docNameController, 'Name of the Document');
   // notifyListeners();
  }

  // Clear the name error message
  void clearNameError() {
    _nameError = null;
    _isFormValid = true;
    notifyListeners();
  }

  // Validate text field (generic method)
  String? validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      notifyListeners();
      return "Please Enter $fieldName";
    }
    return null;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class EmpDocEditPopup extends StatelessWidget {
  final TextEditingController idOfDocController;
  final TextEditingController nameDocController;
  final TextEditingController daysController;

  final bool? isSaving;
  String? expiryType;
  final String empdoctype;
  final bool? loadingDuration;
  final String title;
  bool? enable;
  final int empsetupId;
  final String docname;
  final int employeeDocTypeMetaDataId;
  final VoidCallback onEditSuccess;
  EmpDocEditPopup(
      {super.key,
      required this.idOfDocController,
      required this.nameDocController,
      required this.daysController,
      this.isSaving,
      required this.empdoctype,
      this.loadingDuration,
      required this.title,
      required this.empsetupId,
      required this.docname,
      required this.employeeDocTypeMetaDataId,
      this.enable,
      this.expiryType, required this.onEditSuccess});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpDocEditPopupProvider>(
        builder: (context, provider, child) {
      return DialogueTemplate(
        width: AppSize.s400,
        height: AppSize.s395,
        body: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SMTextFConst(
                  enable: enable ?? true,
                  controller: idOfDocController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.idOfDOc,
                ),
                SizedBox(height: AppSize.s10),
                SMTextfieldAsteric(
                  controller: nameDocController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.NameOfDoc,
                  onChange: () {
                    provider.clearNameError();
                  },
                ),
                provider.nameError != null
                    ? Text(
                  provider.nameError!,
                  style: CommonErrorMsg.customTextStyle(context),
                )
                    : SizedBox(height: AppSize.s12),

                SizedBox(height: AppSize.s2),
                HeaderContentConst(
                  heading: AppString.type_of_the_document,
                  content: Container(
                    width: AppSize.s354,
                    padding: EdgeInsets.symmetric(
                        vertical: AppPadding.p3, horizontal: AppPadding.p10),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: ColorManager.fmediumgrey, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(empdoctype,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context)),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottomButtons: provider.isLoading
            ? SizedBox(
                  width: AppSize.s30,
                  height: AppSize.s30,
                  child: CircularProgressIndicator(
                  color: ColorManager.blueprime,
                ),
              )
            : Center(
                child: CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: AppStringEM.save,
                  onPressed: () async {
                    print("Name controller ::::::::::::::::::: ${nameDocController.text}");
                    print("docname ::::::::::::::::::: ${docname}");
                    provider.validateFields(docNameController: nameDocController.text);
                    if (provider.isFormValid) {
                      provider.setLoading(true);
                      provider.notifyListeners();

                      try {
                        int threshold = 0;
                        String? expiryDateToSend = "";
                        if (provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled && daysController.text.isNotEmpty) {
                        // if (provider.selectedExpiryType == AppConfig.scheduled && daysController.text.isNotEmpty) {
                          int enteredValue = int.parse(daysController.text);
                          if (provider.selectedYear == FrontendConfigStore.data!.config.year) {
                          // if (provider.selectedYear == AppConfig.year) {
                            threshold = enteredValue * 365;
                          } else if (provider.selectedYear ==
                              FrontendConfigStore.data!.config.month) {
                              // AppConfig.month) {
                            threshold = enteredValue * 30;
                          }
                          expiryDateToSend = daysController.text;
                        } else if (provider.selectedExpiryType ==
                            FrontendConfigStore.data!.config.notApplicable || provider.selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
                                // AppConfig.notApplicable || provider.selectedExpiryType == AppConfig.issuer) {
                          threshold = 0;
                          expiryDateToSend = null;
                        }
                        String finalDocName = nameDocController.text.isNotEmpty
                            ? nameDocController.text
                            : docname;
                        print("Name controller ::::::::::::::::::: ${nameDocController.text}");
                        print("docname ::::::::::::::::::: ${docname}");
                      //  print("Name controller ::::::::::::::::::: ${nameController.text}");

                        var response = await editEmployeeDocTypeSetupId(
                          context: context,
                          employeeDoctypeSetupId: empsetupId,
                          docName: finalDocName,
                          threshold: threshold,
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                         onEditSuccess();
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddSuccessPopup(
                                message: 'Edited Successfully',
                              );
                            },
                          );
                        } else if (response.statusCode == 400 ||
                            response.statusCode == 404) {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                const FourNotFourPopup(),
                          );
                        } else {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                FailedPopup(text: response.message),
                          );
                        }
                      } finally {
                        provider.setLoading(false);
                      }
                    }
                  },
                ),
              ),
        title: title,
      );
    });
  }
}