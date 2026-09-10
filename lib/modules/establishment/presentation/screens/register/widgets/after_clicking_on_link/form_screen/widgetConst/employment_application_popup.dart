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

class EmploymentAppSignPopup extends StatefulWidget {
  final int employeeId;
  final int htmlFormTemplateId;
  final VoidCallback? onSigned;
  const EmploymentAppSignPopup({super.key, required this.employeeId, required this.htmlFormTemplateId, this.onSigned});

  @override
  State<EmploymentAppSignPopup> createState() => _EmploymentAppSignPopupState();
}

class _EmploymentAppSignPopupState extends State<EmploymentAppSignPopup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController faxNoController = TextEditingController();
  TextEditingController hiredController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController positionDesiredController = TextEditingController();

  TextEditingController dateAvailableController = TextEditingController();
  TextEditingController specifyWorkHrController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  final FocusNode _dateAvailableFocusNode = FocusNode();
  bool loading = false;
  bool _isFormValid = true;
  bool _isSubmitted = false;
  String? nameError;
  String? faxError;
  String? hiredError;
  String? positionError;
  String? positionDesireError;
  DateTime? datePicked;
  String? dateError;
  String? specifyError;
  String? salaryError;
  String? sourceError;
  String? valueError;
  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      nameError = _validateTextField(nameController.text, 'middle name');
      positionError = _validateTextField(positionController.text, 'position applying');
      dateError = _validateTextField(dateAvailableController.text, 'date available');
      salaryError = _validateTextField(salaryController.text, 'salary');
      if (nameError != null || positionError != null ||
          dateError != null || salaryError != null ) {
        _isFormValid = false;
      }
    });
  }
  bool Position1 = false;
  bool Position2 = false;
  bool Position3 = false;
  String position = "";

  void _updatePosition() {
    List<String> selectedPositions = [];
    if (Position1) selectedPositions.add('Full-Time');
    if (Position2) selectedPositions.add('Part-Time');
    if (Position3) selectedPositions.add('Temporary');
    position = selectedPositions.join(', ');
  }

  String? emptype ='Yes';
  @override
  void initState() {
    super.initState();

    nameController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          nameError = _validateTextField(nameController.text, 'name');
        });
      }
    });
    positionController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          positionError = _validateTextField(positionController.text, 'position');
        });
      }
    });

    dateAvailableController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dateError = _validateTextField(dateAvailableController.text, 'date');
        });
      }
    });
    salaryController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          salaryError = _validateTextField(salaryController.text, 'salery');
        });
      }
    });

  }

  @override
  void dispose() {
    _dateAvailableFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TerminationDialogueTemplate(
      width: AppSize.s800,
      height: AppSize.s700,
      title: "Employment Application",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text( AppStringLegalDocument.popupMsgHead,
                    style:  LegalDocumentPopupMessage.customTextStyle(context),),
                ],
              ),
              const SizedBox(height: AppSize.s20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: AppSize.s6),

                        SMTextFConst(
                          controller: specifyWorkHrController,
                          keyboardType: TextInputType.text,
                          text: 'Specify Work Hours',
                        ),
                        const SizedBox(height: AppSizeConst.A20),

                        SMTextFConst(
                          controller: sourceController,
                          keyboardType: TextInputType.text,
                          text: 'Source Of Referral',
                        ),
                        const SizedBox(height: AppSizeConst.A20),

                        SMTextFConst(
                          controller: faxNoController,
                          keyboardType: TextInputType.text,
                          text: 'Fax No.',
                        ),
                        const SizedBox(height: AppSizeConst.A20),

                        SMTextfieldAsteric(
                          controller: salaryController,
                          keyboardType: TextInputType.text,
                          text: 'Salary Expected',
                        ),
                        salaryError != null ?
                          Text(
                            salaryError!,
                            style: CommonErrorMsg.customTextStyle(context),
                          ) : const SizedBox(height: AppSize.s12,),
                        const SizedBox(height: AppSize.s6),

                        HeaderContentConst(
                          heading: "Available Date",
                          isAsterisk: true,
                          focusNode: _dateAvailableFocusNode,
                          content: FormField<String>(
                            builder: (FormFieldState<String> field) {
                              return SizedBox(
                                width: 354,
                                height: 30,
                                child: TextFormField(
                                  focusNode: _dateAvailableFocusNode,
                                  controller: dateAvailableController,
                                  cursorColor: ColorManager.black,
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorManager.containerBorderGrey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ColorManager.blueprime,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: ColorManager.containerBorderGrey,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    suffixIcon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: ColorManager.blueprime,
                                    ),
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
                                      dateAvailableController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SMTextfieldAsteric(
                          controller: positionController,
                          keyboardType: TextInputType.text,
                          text: 'Position Applying',
                        ),
                        positionError != null ?
                          Text(
                            positionError!,
                            style: CommonErrorMsg.customTextStyle(context),
                          ) : const SizedBox(height: AppSize.s12,),
                        const SizedBox(height: AppSize.s6),

                        SMTextFConst(
                          controller: valueController,
                          keyboardType: TextInputType.text,
                          text: 'Value',
                        ),
                        const SizedBox(height: AppSize.s25),
                        RichText(
                          text: TextSpan(
                            text: 'Desired Position ', // Main text
                            style: AllPopupHeadings.customTextStyle(context), // Apply the custom text style
                            children: [
                              TextSpan(
                                text: '*', // Asterisk
                                style: AllPopupHeadings.customTextStyle(context).copyWith(
                                  color: Colors.red, // Specify the color for the asterisk
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSize.s5),
                        Row(
                          children: [
                            Checkbox(
                              splashRadius: 0,
                              activeColor: ColorManager.blueprime,
                              value: Position1,
                              onChanged: (bool? value) {
                                setState(() {
                                  Position1 = value ?? false;
                                  _updatePosition();
                                });
                              },
                            ),
                            Text(
                              'Full-Time',
                              style: DocumentTypeDataStyle.customTextStyle(context),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              splashRadius: 0,
                              activeColor: ColorManager.blueprime,
                              value: Position2,
                              onChanged: (bool? value) {
                                setState(() {
                                  Position2 = value ?? false;
                                  _updatePosition();
                                });
                              },
                            ),
                            Text(
                              'Part-Time',
                              style:  DocumentTypeDataStyle.customTextStyle(context),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              splashRadius: 0,
                              activeColor : ColorManager.blueprime,
                              value: Position3,
                              onChanged: (bool? value) {
                                setState(() {
                                  Position3 = value ?? false;
                                  _updatePosition();
                                });
                              },
                            ),
                            Text(
                              'Temporary',
                              style:  DocumentTypeDataStyle.customTextStyle(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSize.s23),
                        Text( 'If hired can you provide proof of citizenship or legal right to work?', style: AllPopupHeadings.customTextStyle(context).copyWith(height: 1.5),
                        ),
                        CustomRadioListTile(
                          title: 'Yes',
                          value: 'Yes',
                          groupValue: emptype,
                          onChanged: (value) {
                            setState(() {
                              emptype = value;
                            });
                          },
                        ),
                        CustomRadioListTile(
                          title: 'No',
                          value: 'No',
                          groupValue: emptype,
                          onChanged: (value) {
                            setState(() {
                              emptype = value;
                            });
                          },
                        ),
                    
                      ],
                    ),
                  ),
                ],
              ),
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
              _isSubmitted = true;
              loading = true;
            });
            _validateForm();
            _updatePosition();
            if (!_isFormValid) {
              setState(() {
                loading = false;
              });
              return;
            }
            try{
              EmploymentAppDocument employmentAppDocument = await getEmployeeApplicationDocument(context: context, employmentAppFormhtmlId: widget.htmlFormTemplateId, employeeId: widget.employeeId,
                  middleName: nameController.text, faxNo: faxNoController.text.isEmpty ? AppConfig.dash : faxNoController.text,
                  ifHired: emptype.toString().isEmpty ? AppConfig.dash : emptype.toString(), positionApplying: positionController.text,
                  positionDesired: position.isEmpty ? AppConfig.dash : position, dateAvailable: dateAvailableController.text,
                  specifyWorkingHrs: specifyWorkHrController.text.isEmpty ? AppConfig.dash : specifyWorkHrController.text,
                  salary: salaryController.text, sourceReferral: sourceController.text.isEmpty ? AppConfig.dash : sourceController.text,
                  value: valueController.text.isEmpty ? AppConfig.dash : valueController.text);
              print( employmentAppDocument);
              print("Source :::::: ${sourceController.text}");
              print("salery :::::: ${salaryController.text}");
              if(employmentAppDocument.statusCode == 200 || employmentAppDocument.statusCode == 201){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
                  isDisable:false,
                  documentName: employmentAppDocument.name,
                  onPressed: () { widget.onSigned?.call(); },
                  htmlFormData: employmentAppDocument.html,
                  employeeId: widget.employeeId,
                  htmlFormTemplateId: employmentAppDocument.EmpAppDocumentId,)));
              }
              else if(employmentAppDocument.statusCode == 400 || employmentAppDocument.statusCode == 404){
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
      );
  }

}
