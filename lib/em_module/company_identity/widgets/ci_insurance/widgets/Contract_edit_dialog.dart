import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import '../../../../../../../app/constants/app_config.dart';
import '../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../app/resources/const_string.dart';
import '../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import '../../../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../../../widgets/error_popups/failed_popup.dart';
import '../../../../../../widgets/error_popups/four_not_four_popup.dart';
import '../../../../widgets/dialogue_template.dart';
import '../../../../widgets/header_content_const.dart';
import '../../whitelabelling/success_popup.dart';

class ContractEditDialog extends StatefulWidget {
  final String title;
  final int insuranceVendorContracId;
  final int selectedVendorId;
  final String contractName;
  final String contractId;
  final String? expiryType;
  final int? threshhold;
  final String officeid;
  final String? expiryDate;

  ContractEditDialog({
    Key? key,
    required this.title,
    required this.selectedVendorId,
    required this.officeid,
    required this.contractName,
    required this.contractId,
    this.expiryType,
    this.threshhold,
    this.expiryDate, required this.insuranceVendorContracId,
  }) : super(key: key);

  @override
  State<ContractEditDialog> createState() => _ContractEditDialogState();
}

class _ContractEditDialogState extends State<ContractEditDialog> {
  TextEditingController birthdayController = TextEditingController();

  TextEditingController nameDocController = TextEditingController();
  TextEditingController idDocController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  bool loading = false;
  bool _isFormValid = true;
  String selectedExpiryType = "";
  String? _nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  bool showExpiryDateField = false;

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
      _nameDocError = _validateTextField(nameDocController.text, 'Name of the Document');
    });
  }
  @override
  void initState() {
    super.initState();
    expiryDateController.text = widget.expiryDate!;
    nameDocController.text = widget.contractName;
    if (widget.expiryType == FrontendConfigStore.data!.config.scheduled) {
      selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
    } else if (widget.expiryType == FrontendConfigStore.data!.config.notApplicable) {
      selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    } else if (widget.expiryType == FrontendConfigStore.data!.config.issuer) {
      selectedExpiryType = FrontendConfigStore.data!.config.issuer;
    }

    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
        widget.threshhold != null) {
      int threshold = widget.threshhold!;

      if (threshold >= 365) {
        daysController.text = (threshold ~/ 365).toString(); // Set years
        selectedYear = FrontendConfigStore.data!.config.year;
      } else {
        daysController.text = (threshold ~/ 30).toString(); // Set months
        selectedYear = FrontendConfigStore.data!.config.month;
      }
    }
  }

  DateTime? datePicked;

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s420,
      height: AppSize.s330,
      body: [
        HeaderContentConst(
          heading: AppString.id_of_the_document,
          content: Container(
            height: AppSize.s30,
            width: AppSize.s354,
            padding: EdgeInsets.symmetric(vertical: AppPadding.p5, horizontal: AppPadding.p12),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorManager.fmediumgrey, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.contractId,
                  style: DocumentTypeDataStyle.customTextStyle(context)
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSize.s8,),
        /// Name of the Document
        SMTextfieldAsteric(
          controller: nameDocController,
          keyboardType: TextInputType.text,
          text: AppString.name_of_the_document,
          onChanged: (value) {
            setState(() {
              _nameDocError = null;
            });
          },
        ),
        _nameDocError != null ?
          Padding(
            padding: const EdgeInsets.only(left: AppPadding.p12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameDocError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ),
              ],
            ),
          ): SizedBox(height: AppSize.s12,),
      ],
      bottomButtons: loading == true
          ? SizedBox(
              height: AppSize.s25,
              width: AppSize.s25,
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            )
          : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              onPressed: () async {
                _validateForm(); // Validate the form on button press
                if (_isFormValid) {
                  setState(() {
                    loading = true;
                  });
                  int threshold = 0;
                  String? expiryDateToSend = "";
                  if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
                      daysController.text.isNotEmpty) {
                    int enteredValue = int.parse(daysController.text);
                    if (selectedYear == FrontendConfigStore.data!.config.year) {
                      threshold = enteredValue * 365;
                    } else if (selectedYear == FrontendConfigStore.data!.config.month) {
                      threshold = enteredValue * 30;
                    }
                    expiryDateToSend = daysController.text;
                  } else if (selectedExpiryType == FrontendConfigStore.data!.config.notApplicable ||
                      selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
                    threshold = 0;
                    expiryDateToSend = null;
                  }
                  try {
                    ///docname
                    String contractName;
                    if (nameDocController.text.isNotEmpty && nameDocController.text != widget.contractName) {
                      contractName = nameDocController.text;
                    } else {
                      contractName = widget.contractName;
                    }
                   var response = await patchCompanyContract(context,
                        widget.insuranceVendorContracId,
                        widget.selectedVendorId,
                        threshold,
                        widget.officeid,
                        contractName,
                        selectedExpiryType == selectedExpiryType.toString() ? selectedExpiryType.toString(): widget.expiryType!,
                        widget.contractId,
                       expiryDateController.text );
                    if(response.statusCode == 200 || response.statusCode == 201){
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddSuccessPopup(message:'Added Successfully');
                        },
                      );
                    }
                    else if(response.statusCode == 400 || response.statusCode == 404){
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => const FourNotFourPopup(),
                      );
                    }
                    else {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => FailedPopup(text: response.message),
                      );
                    }
                    nameDocController.clear();
                    idDocController.clear();
                  } finally {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              }),
      title: widget.title,
    );
  }
}
//
// Row(
//   children: [
//     Padding(
//       padding: const EdgeInsets.only(left: AppPadding.p20),
//       child: HeaderContentConst(
//         heading: AppString.expiry_type,
//         content: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomRadioListTile(
//               value: AppConfig.scheduled,
//               groupValue: selectedExpiryType,
//               onChanged: (value) {
//                 setState(() {
//                   selectedExpiryType = value!;
//                 });
//               },
//               title: AppConfig.scheduled,
//             ),
//             CustomRadioListTile(
//               value: AppConfig.issuer,
//               groupValue: selectedExpiryType,
//               onChanged: (value) {
//                 setState(() {
//                   selectedExpiryType = value!;
//                 });
//               },
//               title: AppConfig.issuer,
//             ),
//           ],
//         ),
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.only(
//         left: AppPadding.p20,
//         right: AppPadding.p20,
//         bottom: AppPadding.p15,
//       ),
//       child: Visibility(
//         visible: selectedExpiryType == AppConfig.scheduled,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   height: 30,
//                   width: 50,
//                   //color: ColorManager.red,
//                   child: TextFormField(
//                     controller:
//                         daysController,
//                     cursorColor: ColorManager.black,
//                     cursorWidth: 1,
//                     style: GoogleFonts.firaSans(
//                       fontSize: FontSize.s10,
//                       fontWeight: FontWeight.w500,
//                       color: ColorManager.mediumgrey,
//                     ),
//                     decoration: InputDecoration(
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                             color: ColorManager.fmediumgrey, width: 2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                             color: ColorManager.fmediumgrey, width: 2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 10),
//                     ),
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter
//                           .digitsOnly, // This ensures only digits are accepted
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Container(
//                   height: 30,
//                   width: 80,
//                   padding: EdgeInsets.symmetric(horizontal: 5),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: ColorManager.fmediumgrey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: DropdownButtonFormField<String>(
//                     value:
//                         selectedYear, // Initial value (you should define this variable)
//                     items: [
//                       DropdownMenuItem(
//                         value: AppConfig.year,
//                         child: Text(
//                           AppConfig.year,
//                           style:DocumentTypeDataStyle.customTextStyle(context),
//                         ),
//                       ),
//                       DropdownMenuItem(
//                         value: AppConfig.month,
//                         child: Text(
//                           AppConfig.month,
//                          style:DocumentTypeDataStyle.customTextStyle(context),
//                         ),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         selectedYear =
//                             value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       enabledBorder: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       hintText: AppConfig.year,
//                       hintStyle: GoogleFonts.firaSans(
//                         fontSize: FontSize.s10,
//                         fontWeight: FontWeight.w500,
//                         color: ColorManager.mediumgrey,
//                       ),
//                       contentPadding: EdgeInsets.only(bottom: 20),
//                     ),
//                     icon: Icon(
//                       Icons.arrow_drop_down,
//                       color: ColorManager.black,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   ],
// ),
// Visibility(
//   visible: selectedExpiryType == AppConfig.issuer,
//
//   /// Conditionally display expiry date field
//   child: HeaderContentConst(
//     heading: AppString.expiry_date,
//     content: FormField<String>(
//       builder: (FormFieldState<String> field) {
//         return SizedBox(
//           width: 354,
//           height: 30,
//           child: TextFormField(
//             controller: expiryDateController,
//             cursorColor: ColorManager.black,
//             style: GoogleFonts.firaSans(
//               fontSize: FontSize.s12,
//               fontWeight: FontWeight.w500,
//               color: ColorManager.mediumgrey,
//             ),
//             decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: ColorManager.fmediumgrey, width: 1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: ColorManager.fmediumgrey, width: 1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               hintText: 'MM-DD-YYYY',
//               hintStyle: GoogleFonts.firaSans(
//                 fontSize: FontSize.s12,
//                 fontWeight: FontWeight.w500,
//                 color: ColorManager.mediumgrey,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(6),
//                 borderSide: BorderSide(
//                     width: 1, color: ColorManager.fmediumgrey),
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16),
//               suffixIcon: Icon(Icons.calendar_month_outlined,
//                   color: ColorManager.blueprime),
//               errorText: field.errorText,
//             ),
//             onTap: () async {
//               DateTime? pickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: datePicked,
//                 firstDate: DateTime(1901),
//                 lastDate: DateTime(3101),
//               );
//               if (pickedDate != null) {
//                 datePicked = pickedDate;
//                 expiryDateController.text =
//                     DateFormat('MM-dd-yyyy').format(pickedDate);
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'please select date';
//               }
//               return null;
//             },
//           ),
//         );
//       },
//     ),
//   ),
// ),
