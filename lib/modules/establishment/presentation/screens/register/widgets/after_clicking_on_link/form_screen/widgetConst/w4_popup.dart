import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/form_screen_const.dart';

class WFourSignPopup extends StatefulWidget {
  final int employeeId;
  final int htmlFormTemplateId;
  final VoidCallback? onSigned;
  const WFourSignPopup({super.key, required this.employeeId, required this.htmlFormTemplateId, this.onSigned});

  @override
  State<WFourSignPopup> createState() => _WFourSignPopupState();
}

class _WFourSignPopupState extends State<WFourSignPopup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController step3aController = TextEditingController();
  TextEditingController step3bController = TextEditingController();
  TextEditingController step3cController = TextEditingController();
  TextEditingController step4aController = TextEditingController();
  TextEditingController step4bController = TextEditingController();
  TextEditingController step4cController = TextEditingController();
  TextEditingController multipleJW1Controller = TextEditingController();
  TextEditingController multipleJW12aController = TextEditingController();
  TextEditingController multipleJW12bController = TextEditingController();
  TextEditingController multipleJW12cController = TextEditingController();
  TextEditingController multipleJW13Controller = TextEditingController();
  TextEditingController multipleJW14Controller = TextEditingController();
  TextEditingController dw1Controller = TextEditingController();
  TextEditingController dw2Controller = TextEditingController();
  TextEditingController dw3Controller = TextEditingController();
  TextEditingController dw4Controller = TextEditingController();
  TextEditingController dw5Controller = TextEditingController();
  bool loading = false;
  bool _isFormValid = true;
  bool _isSubmitted = false;
  String? nameError;
  String? statusError;
  String? step3aError;
  String? step3bError;
  String? step3cError;
  String? step4aError;
  String? step4bError;
  String? step4cError;
  String? multipleJW1Error;
  String? multipleJW12aError;
  String? multipleJW12bError;
  String? multipleJW12cError;
  String? multipleJW13Error;
  String? multipleJW14Error;
  String? dw1Error;
  String? dw2Error;
  String? dw3Error;
  String? dw4Error;
  String? dw5Error;
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
      nameError = _validateTextField(nameController.text, 'Middle Name');
      step3aError = _validateTextField(step3aController.text, 'Step 3a');
      step3bError = _validateTextField(step3bController.text, 'Step 3b');
      step3cError = _validateTextField(step3cController.text, 'Step 3c');
      multipleJW1Error = _validateTextField(multipleJW1Controller.text, 'Multiple JW1');
      multipleJW12aError = _validateTextField(multipleJW12aController.text, 'Multiple JW2a');
      multipleJW12bError = _validateTextField(multipleJW12bController.text, 'Multiple JW2b');
      multipleJW12cError = _validateTextField(multipleJW12cController.text, 'Multiple JW2c');
      multipleJW13Error = _validateTextField(multipleJW13Controller.text, 'Multiple JW3');
      multipleJW14Error = _validateTextField(multipleJW14Controller.text, 'Multiple JW4');
      dw1Error = _validateTextField(dw1Controller.text, 'Deduction Worksheet 1');
      dw2Error = _validateTextField(dw2Controller.text, 'Deduction Worksheet 2');
      dw3Error = _validateTextField(dw3Controller.text, 'Deduction Worksheet 3');
      dw4Error = _validateTextField(dw4Controller.text, 'Deduction Worksheet 4');
      dw5Error = _validateTextField(dw5Controller.text, 'Deduction Worksheet 5');
      if (nameError != null || step3aError != null || step3bError != null ||
          step3cError != null || multipleJW1Error != null || multipleJW12aError != null || multipleJW12bError != null || multipleJW12cError != null ||
          multipleJW13Error != null || multipleJW14Error != null || dw1Error != null ||
          dw2Error != null || dw3Error != null || dw4Error != null || dw5Error != null
      ) {
        _isFormValid = false;
      }
    });
  }

  bool mStatus1 = false;
  bool mStatus2 = false;
  bool mStatus3 = false;

  String status1 = '';
  String status2 = '';
  String status3 = '';

  String status = "";
  Future<String> _joinStatus() async {
    status = status1 + status2 + status3 ;
    return status;
  }


  int _getIntValue(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
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

    step3aController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          step3aError = _validateTextField(step3aController.text, 'Step 3a');
        });
      }
    });

    step3bController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          step3bError = _validateTextField(step3bController.text, 'Step 3b');
        });
      }
    });

    step3cController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          step3cError = _validateTextField(step3cController.text, 'Step 3c');
        });
      }
    });

    multipleJW1Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW1Error = _validateTextField(multipleJW1Controller.text, 'Multiple JW1');
        });
      }
    });

    multipleJW12aController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW12aError = _validateTextField(multipleJW12aController.text, 'Multiple JW2a');
        });
      }
    });

    multipleJW12bController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW12bError = _validateTextField(multipleJW12bController.text, 'Multiple JW2b');
        });
      }
    });
    multipleJW12cController.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW12cError = _validateTextField(multipleJW12cController.text, 'Multiple JW2c');
        });
      }
    });

    multipleJW13Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW13Error = _validateTextField(multipleJW13Controller.text, 'Multiple JW3');
        });
      }
    });

    multipleJW14Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          multipleJW14Error = _validateTextField(multipleJW14Controller.text, 'Multiple JW4');
        });
      }
    });

    dw1Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dw1Error = _validateTextField(dw1Controller.text, 'Deduction Worksheet 1');
        });
      }
    });

    dw2Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dw2Error = _validateTextField(dw2Controller.text, 'Deduction Worksheet 2');
        });
      }
    });

    dw3Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dw3Error = _validateTextField(dw3Controller.text, 'Deduction Worksheet 3');
        });
      }
    });

    dw4Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dw4Error = _validateTextField(dw4Controller.text, 'Deduction Worksheet 4');
        });
      }
    });

    dw5Controller.addListener(() {
      if (_isSubmitted) {
        setState(() {
          dw5Error = _validateTextField(dw5Controller.text, 'Deduction Worksheet 5');
        });
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return TerminationDialogueTemplate(
      width: AppSize.s800,
      height: AppSize.s610,
      title: "W4",
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
                  Column(
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
                      const SizedBox(height: AppSize.s9),
                      RichText(
                        text: TextSpan(
                          text: 'Married Status ', // Main text
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
                      Row(
                        children: [
                          Checkbox(
                            splashRadius: 0,
                            activeColor: ColorManager.blueprime,
                            value: mStatus1,
                            onChanged: (bool? value) {
                              setState(() {
                                mStatus1 = value ?? false;
                                status1 =  'Single or Married filing separately';
                              });
                            },
                          ),
                          Text(
                            'Single or Married filing separately',
                            style: NumberTExtFieldLegalDoc.customTextStyle(context),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            splashRadius: 0,
                            activeColor: ColorManager.blueprime,
                            value: mStatus2,
                            onChanged: (bool? value) {
                              setState(() {
                                mStatus2 = value ?? false;
                                status2 =  'Married filing jointly or Qualifying surviving spouse';
                              });
                            },
                          ),
                          Text(
                            'Married filing jointly or Qualifying surviving spouse',
                            style: NumberTExtFieldLegalDoc.customTextStyle(context),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            splashRadius: 0,
                            activeColor: ColorManager.blueprime,
                            value: mStatus3,
                            onChanged: (bool? value) {
                              setState(() {
                                mStatus3 = value ?? false;
                                status3 =  'Head of household';
                              });
                            },
                          ),
                          Text(
                            'Head of household',
                            style: NumberTExtFieldLegalDoc.customTextStyle(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSize.s9),
                      Text('Please enter further value in number only',
                        style: AllNoDataAvailable.customTextStyle(context),),
                      const SizedBox(height: AppSize.s10),
                      Text('Step 3: Claim  Dependent  and Other  Credits',
                      style: AllPopupHeadings.customTextStyle(context),),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: true,
                          controller: step3aController, text: 'Step 3a - If your total income will be \$200,000 or less (\$400,000 or less if married filing jointly): Multiply the number of qualifying children under age 17 by \$2,000'),
                       step3aError != null ?
                        Text(
                          step3aError!,
                          style: CommonErrorMsg.customTextStyle(context).copyWith(height: 1.5),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: true,
                          controller: step3bController, text: 'Step 3b- Multiply the number of other dependents by \$500'),
                      step3bError != null ?
                        Text(
                          step3bError!,
                          style: CommonErrorMsg.customTextStyle(context).copyWith(height: 1.5),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: true,
                          controller: step3cController, text: 'Step 3c- Add the amounts above for qualifying children and other dependents. You may add to  this the amount of any other credits. Enter the total here'),
                      step3cError != null ?
                        Text(
                          step3cError!,
                          style: CommonErrorMsg.customTextStyle(context).copyWith(height: 1.5),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s9),
                      Text('Step 4  (optional):  Other  Adjustments',
                        style: AllPopupHeadings.customTextStyle(context),),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: false,
                          controller: step4aController, text: 'Step 4a- Other income (not from jobs). If you want tax withheld for other income you expect  this year that won’t have withholding, enter the amount of other income here. This  may include interest, dividends, and retirement income.'),
                      const SizedBox(height: AppSize.s20),
                      SMNumberTextFConst(
                        isAsteric: false,
                          controller: step4bController, text: 'Step 4b – Deductions. If you expect to claim deductions other than the standard deduction  and want to reduce your withholding, use the Deductions Worksheet on page 3 and  enter the result here'),
                      const SizedBox(height: AppSize.s20),
                      SMNumberTextFConst(
                        isAsteric: false,
                          controller: step4cController, text: 'Step 4c- Extra withholding. Enter any additional tax you want withheld each pay period'),
                      const SizedBox(height: AppSize.s9),
                      Text('Multiple Jobs Worksheet',
                        style: AllPopupHeadings.customTextStyle(context),),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: true,
                          controller: multipleJW1Controller, text: 'Multiple JW1- Two jobs. If you have two jobs or you’re married filing jointly and your spouse each have one job,  find the amount from the appropriate table on page 4. Using the “Higher Paying Job” row and the  “Lower Paying Job” column, find the value at the intersection of the two household salaries and  enter that value on line 1. Then, skip to line 3'),
                      multipleJW1Error != null ?
                        Text(
                          multipleJW1Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s9),
                      Container(
                        width: 354,
                        child: Text('Three jobs. If you and/or your spouse have three jobs at the same time, complete lines 2a, 2b, and  2c below. Otherwise, skip to line 3',
                          style: SearchDropdownConst.customTextStyle(context).copyWith(height: 1.5),),
                      ),
                      const SizedBox(height: AppSize.s9),
                      SMNumberTextFConst(
                        isAsteric: true,
                          controller: multipleJW12aController, text: 'Multiple JW2a-If you have two jobs or you’re married filing jointly and your spouse each have one job,  find the amount from the appropriate table on page 4. Using the “Higher Paying Job” row and the  “Lower Paying Job” column, find the value at the intersection of the two household salaries and  enter that value on line 1. Then, skip to line 3'),
                      multipleJW12aError != null ?
                        Text(
                          multipleJW12aError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSize.s17),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: multipleJW12bController,
                          text: 'Multiple JW2b- Add the annual wages of the two highest paying jobs from line 2a together and use the total  as the wages in the “Higher Paying Job” row and use the annual wages for your third job in the  “Lower Paying Job” column to find the amount from the appropriate table on page 4 and enter  this amount on line 2b'),
                      multipleJW12bError != null ?
                        Text(
                          multipleJW12bError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                       const SizedBox(height: AppSize.s12),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: multipleJW12cController, text: 'Multiple JW2c- Add the amounts from lines 2a and 2b and enter the result on line 2c'),
                      multipleJW12cError != null ?
                        Text(
                          multipleJW12cError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s10),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: multipleJW13Controller, text: 'Multiple JW3- Enter the number of pay periods per year for the highest paying job. For example, if that job pays  weekly, enter 52; if it pays every other week, enter 26; if it pays monthly, enter 12, etc'),
                      multipleJW13Error != null ?
                        Text(
                          multipleJW13Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s10),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: multipleJW14Controller, text: 'Multiple JW4- Divide the annual amount on line 1 or line 2c by the number of pay periods on line 3. Enter this  amount here and in Step 4(c) of Form W-4 for the highest paying job (along with any other  additional amount you want withheld)'),
                      multipleJW14Error != null ?
                        Text(
                          multipleJW14Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s10),

                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: dw1Controller, text: 'Deductions Worksheet 1- Enter an estimate of your 2023 itemized deductions (from Schedule A (Form 1040)). Such  deductions may include qualifying home mortgage interest, charitable contributions, state and  local taxes (up to \$10,000), and medical expenses in excess of 7.5% of your income'),
                      dw1Error != null ?
                        Text(
                          dw1Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s12),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: dw2Controller, text: 'Deductions Worksheet 2- Enter: • \$27,700 if you’re married filing jointly or a qualifying surviving spouse • \$20,000 if you’re head of household • \$13,850 if you’re single or married filing separately'),
                      dw2Error != null ?
                        Text(
                          dw2Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s12),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: dw3Controller, text: 'Deductions Worksheet 3- If line 1 is greater than line 2, subtract line 2 from line 1 and enter the result here. If line 2 is greater  than line 1, enter “-0-”'),
                      dw3Error != null ?
                        Text(
                          dw3Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s12),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: dw4Controller, text: 'Deductions Worksheet 4- Enter an estimate of your student loan interest, deductible IRA contributions, and certain other  adjustments (from Part II of Schedule 1 (Form 1040)). See Pub. 505 for more information'),
                      dw4Error != null ?
                        Text(
                          dw4Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                      const SizedBox(height: AppSize.s12),
                      SMNumberTextFConst(
                          isAsteric: true,
                          controller: dw5Controller, text: 'Deductions Worksheet 5- Add lines 3 and 4. Enter the result here and in Step 4(b) of Form W-4'),
                      dw5Error != null ?
                        Text(
                          dw5Error!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ) : const SizedBox(height: AppSize.s12,),
                    ],
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
              _isSubmitted = true; // Mark form as submitted
              loading = true; // Start loading
            });
            _validateForm(); // Validate the form on button press
          await _joinStatus();
            if (!_isFormValid) {
              setState(() {
                loading = false;
              });
              return;
            }
            try{
            WFourDocument wfourDocument = await getW4Document(context: context, templateId: widget.htmlFormTemplateId, employeeId: widget.employeeId,
                middleName: nameController.text,
                marriedStatus: status.isEmpty ? AppConfig.dash : status, step3a: int.parse(step3aController.text),
                step3b: int.parse(step3bController.text), step3c: int.parse(step3cController.text),
                step4a: _getIntValue(step4aController), // No validation, pass 0 if empty
                step4b: _getIntValue(step4bController), // No validation, pass 0 if empty
                step4c: _getIntValue(step4cController),
                multipleJW1: int.parse(multipleJW1Controller.text),
                multipleJW12a: int.parse(multipleJW12aController.text), multipleJW12b: int.parse(multipleJW12bController.text),
                multipleJW12c: int.parse(multipleJW12cController.text), multipleJW13: int.parse(multipleJW13Controller.text),
                multipleJW14: int.parse(multipleJW14Controller.text), deductionsWorksheet1: int.parse(dw1Controller.text),
                deductionsWorksheet2: int.parse(dw2Controller.text), deductionsWorksheet3: int.parse(dw3Controller.text),
                deductionsWorksheet4: int.parse(dw4Controller.text), deductionsWorksheet5: int.parse(dw5Controller.text));
            if(wfourDocument.statusCode == 200 || wfourDocument.statusCode == 201){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
                isDisable:false,
                documentName: wfourDocument.name,
                onPressed: () { widget.onSigned?.call(); },
                htmlFormData: wfourDocument.html,
                employeeId: widget.employeeId,//widget.employeeID,
                htmlFormTemplateId: wfourDocument.wFourDocumentId,)));
            }
            else if(wfourDocument.statusCode == 400 || wfourDocument.statusCode == 404){
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

          }
          finally {
          setState(() {
            loading = false;
          });
           }
          }
      ),);
  }
}
