import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/header_content_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/form_screen_const.dart';

class INineSignPopup extends StatefulWidget {
  final int employeeId;
  final int htmlFormTemplateId;
  final VoidCallback? onSigned;
  const INineSignPopup({super.key, required this.employeeId, required this.htmlFormTemplateId, this.onSigned});

  @override
  State<INineSignPopup> createState() => _INineSignPopupState();
}

class _INineSignPopupState extends State<INineSignPopup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController aptNumController = TextEditingController();
  TextEditingController alienInfoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController uscisController = TextEditingController();
  TextEditingController work1Controller = TextEditingController();
  TextEditingController work2Controller = TextEditingController();
  TextEditingController work3Controller = TextEditingController();

  bool loading = false;
  bool _isFormValid = true;
  bool _isSubmitted = false;

  String? citizenshipError;
  String? nameError;
  String? lastNameError;
  String? aptNumError;
  String? dateError;
  String? alienInfoError;
  String? uscisError;
  String? work1Error;
  String? work2Error;
  String? work3Error;
  DateTime? datePicked;

  String? citizentype= 'A citizen of the United States';
  String  alienWork = "";
  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  // Validates the Alien Registration Number and USCIS Number fields shown for
  // "A lawful permanent resident". Each field is independently required.
  void _validateAlienFields() {
    if (citizentype == 'A lawful permanent resident') {
      alienInfoError = _validateTextField(alienInfoController.text, 'Alien Registration Number');
      uscisError = _validateTextField(uscisController.text, 'USCIS Number');
      if (alienInfoError != null || uscisError != null) {
        _isFormValid = false;
      }
    } else {
      alienInfoError = null;
      uscisError = null;
    }
  }

  // Validates the fields shown for "An alien authorized to work":
  // Available Date and all three work document fields are each independently required.
  void _validateWorkFields() {
    if (citizentype == 'An alien authorized to work') {
      if (dateController.text.isEmpty) {
        dateError = 'Please select available date';
        _isFormValid = false;
      } else {
        dateError = null;
      }

      work1Error = _validateTextField(work1Controller.text, 'Alien Registration / USCIS Number');
      work2Error = _validateTextField(work2Controller.text, 'Form I-94 Admission Number');
      work3Error = _validateTextField(work3Controller.text, 'Foreign Passport Number');
      if (work1Error != null || work2Error != null || work3Error != null) {
        _isFormValid = false;
      }
    } else {
      dateError = null;
      work1Error = null;
      work2Error = null;
      work3Error = null;
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      nameError = _validateTextField(nameController.text, 'name');
      lastNameError = _validateTextField(lastNameController.text, 'last name');
      aptNumError = _validateTextField(aptNumController.text, 'apt number');
      if (nameError != null || lastNameError != null || aptNumError != null) {
        _isFormValid = false;
      }
      _validateAlienFields();
      _validateWorkFields();
    });
  }
  Future<String> alienWorkDocument() async {
    if (citizentype == 'A citizen of the United States' ||
        citizentype == 'A noncitizen national of the United States') {
      return '-'; // Pass empty string for these two citizenship types.
    }
    else if (citizentype == 'A lawful permanent resident') {
      // Use either Alien Info or USCIS number
      return alienInfoController.text.isNotEmpty
          ? alienInfoController.text.isEmpty ? AppConfig.dash : alienInfoController.text
          : uscisController.text.isEmpty ? AppConfig.dash : uscisController.text;
    }
    else if (citizentype == 'An alien authorized to work') {
      // Use one of the work-related fields

      if (work1Controller.text.isNotEmpty) {
        return work1Controller.text.isEmpty ? AppConfig.dash : work1Controller.text;
      } else if (work2Controller.text.isNotEmpty) {
        return work2Controller.text.isEmpty ? AppConfig.dash : work2Controller.text;
      } else {
        return work3Controller.text.isEmpty ? AppConfig.dash : work3Controller.text;
      }
    }
    return '-'; // Default empty if none match (safety fallback).
  }
  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          nameError = _validateTextField(nameController.text, 'Name');
        });
      }
    });

    lastNameController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          lastNameError = _validateTextField(lastNameController.text, 'Last Name');
        });
      }
    });
    aptNumController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          aptNumError = _validateTextField(aptNumController.text, 'Apt Number');
        });
      }
    });

    // Live-validate Alien Registration / USCIS Number fields
    // (shown for "A lawful permanent resident") after first submit attempt.
    alienInfoController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateAlienFields();
        });
      }
    });
    uscisController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateAlienFields();
        });
      }
    });

    // Live-validate Available Date and work document fields
    // (shown for "An alien authorized to work") after first submit attempt.
    dateController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateWorkFields();
        });
      }
    });
    work1Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateWorkFields();
        });
      }
    });
    work2Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateWorkFields();
        });
      }
    });
    work3Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          _validateWorkFields();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TerminationDialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s610,
      title: "i-9 form",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8,),
              Text( AppStringLegalDocument.popupMsgHead,
                style:  LegalDocumentPopupMessage.customTextStyle(context),),
              const SizedBox(height: AppSize.s20),
              SMTextfieldAsteric(
                controller: nameController,
                keyboardType: TextInputType.text,
                text: 'Middle Name',
              ),
              nameError != null ?
              Text(
                nameError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s8),
              SMTextfieldAsteric(
                controller: lastNameController,
                keyboardType: TextInputType.text,
                text: 'Other Last Name',
              ),
              lastNameError != null ?
              Text(
                lastNameError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s8),
              SMTextfieldAsteric(
                controller: aptNumController,
                keyboardType: TextInputType.text,
                text: 'ATP Number',
              ),
              aptNumError != null ?
              Text(
                aptNumError!,
                style: CommonErrorMsg.customTextStyle(context),
              ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s8),
              const SizedBox(height: AppSize.s8),
              Text( 'Citizenship', style: AllPopupHeadings.customTextStyle(context),
              ),
              CustomRadioListTile(
                title: 'A citizen of the United States',
                value: 'A citizen of the United States',
                groupValue: citizentype,
                onChanged: (value) {
                  setState(() {
                    citizentype = value;
                    if (_isSubmitted) {
                      _validateAlienFields();
                      _validateWorkFields();
                    }
                  });
                },
              ),
              CustomRadioListTile(
                title: 'A noncitizen national of the United States',
                value: 'A noncitizen national of the United States',
                groupValue: citizentype,
                onChanged: (value) {
                  setState(() {
                    citizentype = value;
                    if (_isSubmitted) {
                      _validateAlienFields();
                      _validateWorkFields();
                    }
                  });
                },
              ),
              CustomRadioListTile(
                title: 'A lawful permanent resident',
                value: 'A lawful permanent resident',
                groupValue: citizentype,
                onChanged: (value) {
                  setState(() {
                    citizentype = value;
                    if (_isSubmitted) {
                      _validateAlienFields();
                      _validateWorkFields();
                    }
                  });
                },
              ),
              CustomRadioListTile(
                title: 'An alien authorized to work',
                value: 'An alien authorized to work',
                groupValue: citizentype,
                onChanged: (value) {
                  setState(() {
                    citizentype = value;
                    if (_isSubmitted) {
                      _validateAlienFields();
                      _validateWorkFields();
                    }
                  });
                },
              ),
              Visibility(
                visible: citizentype == 'A lawful permanent resident',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSize.s8),
                    Text(
                      'Enter Alien Registration Number / USCIS Number',
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                    SMTextFConst(
                      controller: alienInfoController,
                      keyboardType: TextInputType.text,
                      text: 'Alien Registration Number',
                    ),
                    alienInfoError != null ?
                    Text(
                      alienInfoError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                    const SizedBox(height: 20,),
                    SMTextFConst(
                      controller: uscisController,
                      keyboardType: TextInputType.text,
                      text: 'USCIS Number',
                    ),
                    uscisError != null ?
                    Text(
                      uscisError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                  ],
                ),),
              Visibility(
                visible: citizentype == 'An alien authorized to work',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSize.s8),
                    HeaderContentConst(
                      heading: "Available Date",
                      content : FormField<String>(
                        builder: (FormFieldState<String> field) {
                          return SizedBox(
                            width: 354,
                            height: 30,
                            child: TextFormField(
                              controller: dateController,
                              cursorColor: ColorManager.black,
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFFB1B1B1), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFFB1B1B1), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'yyyy-mm-dd',
                                hintStyle:
                                DocumentTypeDataStyle.customTextStyle(context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFB1B1B1), width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                suffixIcon: Icon(Icons.calendar_month_outlined,
                                    color: ColorManager.blueprime),
                                errorText: field.errorText,
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1901),
                                  lastDate: DateTime(3101),
                                );
                                if (pickedDate != null) {
                                  datePicked = pickedDate;
                                  dateController.text =
                                      DateFormat('MM-dd-yyyy').format(pickedDate);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    dateError != null ?
                    Text(
                      dateError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                    const SizedBox(height: AppSize.s20,),
                    Container(
                      width: 354,
                      child: Text(
                        'Aliens authorized to work must provide only one of following document number.',
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    ),
                    const SizedBox(height: AppSize.s10,),
                    SMTextFConst(
                      controller: work1Controller,
                      keyboardType: TextInputType.text,
                      text: 'Alien Registration / USCIS Number',
                    ),
                    work1Error != null ?
                    Text(
                      work1Error!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                    const SizedBox(height: AppSize.s20,),
                    SMTextFConst(
                      controller: work2Controller,
                      keyboardType: TextInputType.text,
                      text: 'Form I-94 Admission Number',
                    ),
                    work2Error != null ?
                    Text(
                      work2Error!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                    const SizedBox(height: AppSize.s20,),
                    SMTextFConst(
                      controller: work3Controller,
                      keyboardType: TextInputType.text,
                      text: 'Foreign Passport Number',
                    ),
                    work3Error != null ?
                    Text(
                      work3Error!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ) : const SizedBox(height: AppSize.s12,),
                  ],
                ),),
            ],
          ),
        )
      ],
      bottomButtons: CustomElevatedButton(
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.submit,
          isLoading: loading,
          onPressed: () async {
            setState(() {
              _isSubmitted = true; // Mark form as submitted
              loading = true; // Start loading
            });
            _validateForm(); // Validate the form before submission.
            String alienWork = await alienWorkDocument(); // Await the correct value.
            print("${alienWork}");
            if (!_isFormValid) {
              setState(() {
                loading = false;
              });
              return;
            }
            try{
              // Call the API with correct parameters.
              INineDocument iNineDocument = await getI9Document(
                  context: context,
                  i9FormhtmlId: widget.htmlFormTemplateId,
                  employeeId: widget.employeeId,
                  middleName: nameController.text,
                  otherLastName: lastNameController.text,
                  aptNumber: aptNumController.text,
                  alienInfo: alienWork.toString(), // Use the returned value.
                  citizenship: citizentype.toString(),
                  alienDate: dateController.text.isEmpty ? AppConfig.dash :dateController.text
              );
              print("Middle Name: ${nameController.text}");
              print("Last Name: ${lastNameController.text}");
              print("APT Number: ${aptNumController.text}");
              print("Alien Info: $alienWork");
              print("Citizenship: $citizentype");

              if (iNineDocument.statusCode == 200 || iNineDocument.statusCode == 201) {
                Navigator.pop(context); // Close the current popup.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignatureFormScreen(
                      isDisable:false,
                      documentName: iNineDocument.name,
                      onPressed: () { widget.onSigned?.call(); },
                      htmlFormData: iNineDocument.html,
                      employeeId: widget.employeeId,
                      htmlFormTemplateId: iNineDocument.iNineDocumentId,
                    ),
                  ),
                );
              }
              else if(iNineDocument.statusCode == 400 || iNineDocument.statusCode == 404){
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FourNotFourPopup(),
                );
              }
              else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FailedPopup(text: "Something Went Wrong"),
                );
              }


            } finally {
              setState(() {
                loading = false;
              });
            }
          }
      )
      ,);
  }
}