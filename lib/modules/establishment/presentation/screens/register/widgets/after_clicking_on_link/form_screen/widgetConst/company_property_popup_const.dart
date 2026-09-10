import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/legal_documents/legal_document_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/legal_document_data/legal_oncall_doc_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/form_screen_const.dart';

class CompanyPropertySignPopup extends StatefulWidget {
  final int employeeId;
  final int htmlFormTemplateId;
  final VoidCallback? onSigned;
  const CompanyPropertySignPopup({super.key,required this.employeeId, required this.htmlFormTemplateId, this.onSigned,});

  @override
  State<CompanyPropertySignPopup> createState() => _CompanyPropertySignPopupState();
}

class _CompanyPropertySignPopupState extends State<CompanyPropertySignPopup> {

   TextEditingController companyController = TextEditingController();
   TextEditingController specificationController = TextEditingController();
  bool loading = false;
  bool _isFormValid = true;
   bool _isSubmitted = false;
  String? companyError;
  String? specificationError;

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
      companyError = _validateTextField(companyController.text, 'company property');
      specificationError = _validateTextField(specificationController.text, 'specifications');
      if (companyError != null || specificationError != null) {
        _isFormValid = false;
      }
    });
  }
   @override
   void initState() {
     super.initState();

     companyController.addListener(() {
       if (_isSubmitted) {
         setState(() {
           companyError = _validateTextField(companyController.text, 'company property');
         });
       }
     });

     specificationController.addListener(() {
       if (_isSubmitted) {
         setState(() {
           specificationError = _validateTextField(specificationController.text, 'specifications');
         });
       }
     });
   }
  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s400,
        height: AppSize.s383,
        title: 'Return of Company Property',
        body: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( AppStringLegalDocument.popupMsgHead,
                style:  LegalDocumentPopupMessage.customTextStyle(context),),
                const SizedBox(height: AppSize.s25),
                FirstSMTextFConst(
                  controller: companyController,
                  keyboardType: TextInputType.text,
                  text: 'Company Property',
                ),
                if (companyError != null) // Display error if any
                  Text(
                    companyError!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),

                const SizedBox(height: AppSize.s8),
                SMTextFConst(
                  controller: specificationController,
                  keyboardType: TextInputType.text,
                  text: 'Specification',
                ),
                if (specificationError != null)
                  Text(
                    specificationError!,
                    style: CommonErrorMsg.customTextStyle(context),
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

              _validateForm();
              if (!_isFormValid) {
                setState(() {
                  loading = false;
                });
                return;
              }
              try{
                ReturnOfCompanyProperty returnOfCompanyProperty = await getReturnOfCompanyPropertyDocument(context: context,
                  employeeId: widget.employeeId,templateId: widget.htmlFormTemplateId, companyProperty: companyController.text, specifications: specificationController.text,
                );
                if(returnOfCompanyProperty.statusCode == 200 || returnOfCompanyProperty.statusCode == 201){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>SignatureFormScreen(
                    isDisable:false,
                    documentName: returnOfCompanyProperty.name,
                    onPressed: () { widget.onSigned?.call(); },
                    htmlFormData: returnOfCompanyProperty.html,
                    employeeId: widget.employeeId,//widget.employeeID,
                    htmlFormTemplateId: returnOfCompanyProperty.returnOfCompanyPropertyId,)
                  ));
                }
                else if(returnOfCompanyProperty.statusCode == 400 || returnOfCompanyProperty.statusCode == 404){
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
