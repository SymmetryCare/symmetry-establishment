import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';

///Add new popup

class AddNewOrgDocButtonProvider extends ChangeNotifier {
  String _selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
  // String _selectedExpiryType = AppConfig.notApplicable;
  TextEditingController idDocController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");
  bool loading = false;
  bool _isFormValid = true;
  String? _idDocError;
  String? _nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  bool isDropdownAvailability = false;
  String get selectedExpiryType => _selectedExpiryType;

  AddNewOrgDocButtonProvider({required int docTypeId, required int subDocTypeId}) {
    debugPrint("Initializing Provider with docTypeId: $docTypeId, subDocTypeId: $subDocTypeId");

    // Set selectedExpiryType based on conditions
    if (docTypeId ==  FrontendConfigStore.data!.config.vendorContracts && subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC) {
    // if (docTypeId == AppConfig.vendorContracts && subDocTypeId == AppConfig.subDocId10MISC) {
      _selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
      // _selectedExpiryType = AppConfig.scheduled;
      debugPrint("Setting expiry type to: Scheduled");
    } else {
      _selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
      // _selectedExpiryType = AppConfig.notApplicable;
      debugPrint("Setting expiry type to: Not Applicable");
    }
    notifyListeners();
  }

  void setSelectedExpiryType(String value) {
    if (_selectedExpiryType != value) {
      _selectedExpiryType = value;
      notifyListeners(); // Ensure UI updates
    }
  }

  void validateForm() {
    _isFormValid = true;
    _idDocError = _validateTextField(idDocController.text, 'ID of the Document');
    _nameDocError = _validateTextField(nameDocController.text, 'Name of the Document');
    notifyListeners();
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  void setupTextFieldListeners() {
    idDocController.addListener(() {
      if (idDocController.text.isNotEmpty) {
        _idDocError = null;
        notifyListeners();
      }
    });

    nameDocController.addListener(() {
      if (nameDocController.text.isNotEmpty) {
        _nameDocError = null;
        notifyListeners();
      }
    });
  }
}

class AddNewOrgDocButton extends StatelessWidget {
  final double? height;
  final String docTypeText;
  final int docTypeId;
  final int subDocTypeId;
  final String subDocTypeText;
  final String title;
  final String? selectedSubDocType;
  const AddNewOrgDocButton({super.key, this.height, required this.docTypeText, required this.docTypeId, required this.subDocTypeId, required this.subDocTypeText, required this.title, this.selectedSubDocType});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddNewOrgDocButtonProvider>(
      builder: (context, provider, child) {
        return DialogueTemplate(
          width: AppSize.s420,
          height: subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
          // height: subDocTypeId == AppConfig.subDocId10MISC
              ? height ?? AppSize.s530
              : docTypeId == FrontendConfigStore.data!.config.policiesAndProcedure
              // : docTypeId == AppConfig.policiesAndProcedure
              ? height ??AppSize.s540
              : height ??AppSize.s610,
          body: [ Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ID of the Document
                SMTextfieldAsteric(
                  controller: provider.idDocController,
                  keyboardType: TextInputType.text,
                  text: AppString.id_of_the_document,
                  onChange: (){provider.setupTextFieldListeners();},
                ),
                provider._idDocError != null ? // Display error if any
                Text(
                  provider._idDocError!,
                  style:CommonErrorMsg.customTextStyle(context),
                ) : SizedBox(height: AppSize.s12,),
                SizedBox(height: AppSize.s3,),
                /// Name of the Document
                SMTextfieldAsteric(
                  controller: provider.nameDocController,
                  keyboardType: TextInputType.text,
                  text: AppString.name_of_the_document,
                  onChange: (){provider.setupTextFieldListeners();},
                ),
                provider._nameDocError != null ? // Display error if any
                Text(
                  provider. _nameDocError!,
                  style:CommonErrorMsg.customTextStyle(context),
                ) :SizedBox(height: AppSize.s12,),
                SizedBox(height: AppSize.s3,),
                /// Type of the Document
                HeaderContentConst(
                  // isAsterisk: true,
                  heading: AppString.type_of_the_document,
                  content: Container(
                    width: AppSize.s354,
                    height: AppSize.s30,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          docTypeText,
                          style: TableSubHeading.customTextStyle(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSize.s8,),
                /// Sub Type of the Document
                docTypeId == FrontendConfigStore.data!.config.policiesAndProcedure
                // docTypeId == AppConfig.policiesAndProcedure
                    ? SizedBox(
                  height: 1,
                )
                    : Column(
                  children: [
                    HeaderContentConst(
                      heading: AppString.sub_type_of_the_document,
                      content: Container(
                        width: AppSize.s354,
                        height: AppSize.s30,
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: ColorManager.fmediumgrey, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subDocTypeText,
                              style: TableSubHeading.customTextStyle(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.s8,),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      HeaderContentConst(
                          isAsterisk: true,
                          heading: AppString.expiry_type,
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
                              // subDocTypeId == AppConfig.subDocId10MISC
                                  ? Offstage()
                                  : Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    activeColor: ColorManager.bluebottom,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    value: FrontendConfigStore.data!.config.notApplicable,
                                    // value: AppConfig.notApplicable,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Not Applicable",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),

                              // Scheduled
                              Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    activeColor: ColorManager.bluebottom,
                                    value: FrontendConfigStore.data!.config.scheduled,
                                    // value: AppConfig.scheduled,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Scheduled",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),

                              subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
                              // subDocTypeId == AppConfig.subDocId10MISC
                                  ? Offstage()
                                  : Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    activeColor: ColorManager.bluebottom,
                                    value: FrontendConfigStore.data!.config.issuer,
                                    // value: AppConfig.issuer,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Issuer",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppPadding.p20,
                          right: AppPadding.p20,
                        ),
                        child: Visibility(
                          visible: provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled,
                          // visible: provider.selectedExpiryType == AppConfig.scheduled,
                          child: Column(
                            children: [
                              SizedBox(height: AppSize.s20,),
                              Row(
                                children: [
                                  Container(
                                    width: AppSize.s50,
                                    height: AppSize.s30,
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
                                  SizedBox(width: AppSize.s10,),
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
                                  // Container(
                                  //   width: AppSize.s80,
                                  //   height: AppSize.s30,
                                  //   padding: EdgeInsets.symmetric(horizontal: 5),
                                  //   decoration: BoxDecoration(
                                  //     border:
                                  //     Border.all(color: ColorManager.fmediumgrey),
                                  //     borderRadius: BorderRadius.circular(8),
                                  //   ),
                                  //   child: DropdownButtonFormField<String>(
                                  //     value:
                                  //     provider.selectedYear, // Initial value (you should define this variable)
                                  //     items: [
                                  //       DropdownMenuItem(
                                  //         value: AppConfig.year,
                                  //         child: Text(
                                  //           AppConfig.year,
                                  //           style: DocumentTypeDataStyle.customTextStyle(context),
                                  //         ),
                                  //       ),
                                  //       DropdownMenuItem(
                                  //         value: AppConfig.month,
                                  //         child: Text(
                                  //           AppConfig.month,
                                  //           style:DocumentTypeDataStyle.customTextStyle(context),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //     onChanged: (value) {
                                  //         provider.selectedYear = value;
                                  //         provider.notifyListeners();
                                  //
                                  //     },
                                  //     decoration: InputDecoration(
                                  //       enabledBorder: InputBorder.none,
                                  //       focusedBorder: InputBorder.none,
                                  //       hintText: AppConfig.year,
                                  //       hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                                  //       contentPadding: EdgeInsets.only(bottom: 20),
                                  //     ),
                                  //     icon: Icon(
                                  //       Icons.arrow_drop_down,
                                  //       color: ColorManager.black,
                                  //       size: 16,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
          bottomButtons: provider.loading == true
            ? SizedBox(
          height: AppSize.s30,
          width: AppSize.s30,
          child: CircularProgressIndicator(
            color: ColorManager.blueprime,
          ),
        )
            : CustomElevatedButton(
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.add,
          onPressed: () async {
           provider.validateForm();
            if (provider._isFormValid) {
              provider.loading = true;
              int threshold = 0;
              if (provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
              // if (provider.selectedExpiryType == AppConfig.scheduled &&
                  provider.daysController.text.isNotEmpty) {
                int enteredValue = int.parse(provider.daysController.text);
                if (provider.selectedYear == FrontendConfigStore.data!.config.year) {
                // if (provider.selectedYear == AppConfig.year) {
                  threshold = enteredValue * 365;
                } else if (provider.selectedYear == FrontendConfigStore.data!.config.month) {
                // } else if (provider.selectedYear == AppConfig.month) {
                  threshold = enteredValue * 30;
                }
              }
              try {
                var response =  await addNewOrgDocumentPost(
                    context: context,
                    docName: provider.nameDocController.text,
                    docTypeID: docTypeId,
                    docSubTypeID: subDocTypeId,
                    threshold: threshold,
                    expiryType: provider.selectedExpiryType.toString(),
                    expiryDate: null, //expiryTypeToSend,
                    expiryReminder: provider.selectedExpiryType.toString(),
                    idOfDoc: provider.idDocController.text);
                // await getNewOrgDocument(context);
                if(response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddSuccessPopup(
                        message: 'Added Successfully',
                      );
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
              } finally {
                provider.loading = false;
                provider.notifyListeners();
              }
            }
          },
        ),
          title: title,
        );
      },
    );
  }

// @override
//   Widget build(BuildContext context) {
//     return Consumer<AddNewOrgDocButtonProviider>(builder: (context, provider, child){
//       provider.setupTextFieldListeners();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         provider.updateExpiryTypeBasedOnDocSelection(docTypeId, subDocTypeId);
//       });
//       // provider.updateExpiryTypeBasedOnDocSelection(docTypeId, subDocTypeId);
//       return DialogueTemplate(
//         width: AppSize.s420,
//         height: subDocTypeId == AppConfig.subDocId10MISC
//             ? height ?? AppSize.s530
//             : docTypeId == AppConfig.policiesAndProcedure
//             ? height ??AppSize.s540
//             : height ??AppSize.s610,
//         body: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppPadding.p10,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// ID of the Document
//                 SMTextfieldAsteric(
//                   controller: provider.idDocController,
//                   keyboardType: TextInputType.text,
//                   text: AppString.id_of_the_document,
//                 ),
//                 provider._idDocError != null ? // Display error if any
//                   Text(
//                     provider._idDocError!,
//                     style:CommonErrorMsg.customTextStyle(context),
//                   ) : SizedBox(height: AppSize.s12,),
//                 SizedBox(height: AppSize.s3,),
//                 /// Name of the Document
//                 SMTextfieldAsteric(
//                   controller: provider.nameDocController,
//                   keyboardType: TextInputType.text,
//                   text: AppString.name_of_the_document,
//                 ),
//                 provider._nameDocError != null ? // Display error if any
//                   Text(
//                     provider. _nameDocError!,
//                     style:CommonErrorMsg.customTextStyle(context),
//                   ) :SizedBox(height: AppSize.s12,),
//                 SizedBox(height: AppSize.s3,),
//                 /// Type of the Document
//                 HeaderContentConst(
//                   // isAsterisk: true,
//                   heading: AppString.type_of_the_document,
//                   content: Container(
//                     width: AppSize.s354,
//                     height: AppSize.s30,
//                     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     decoration: BoxDecoration(
//                       color: ColorManager.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: ColorManager.fmediumgrey, width: 1),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           docTypeText,
//                           style: TableSubHeading.customTextStyle(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: AppSize.s8,),
//                 /// Sub Type of the Document
//                 docTypeId == AppConfig.policiesAndProcedure
//                     ? SizedBox(
//                   height: 1,
//                 )
//                     : Column(
//                       children: [
//                         HeaderContentConst(
//                           heading: AppString.sub_type_of_the_document,
//                           content: Container(
//                         width: AppSize.s354,
//                         height: AppSize.s30,
//                         padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: ColorManager.white,
//                           borderRadius: BorderRadius.circular(8),
//                           border:
//                           Border.all(color: ColorManager.fmediumgrey, width: 1),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               subDocTypeText,
//                               style: TableSubHeading.customTextStyle(context),
//                             ),
//                           ],
//                         ),
//                           ),
//                         ),
//                         SizedBox(height: AppSize.s8,),
//                       ],
//                     ),
//                 /// Radio Button Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 2),
//                   child: Row(
//                     children: [
//                       HeaderContentConst(
//                         isAsterisk: true,
//                         heading: AppString.expiry_type,
//                         content: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Offstage if subDocTypeId matches
//                             subDocTypeId == AppConfig.subDocId10MISC
//                                 ? Offstage()
//                                 : CustomRadioListTile(
//                               value: AppConfig.notApplicable,
//                               groupValue: provider.selectedExpiryType,
//                               onChanged: (value) {
//                                 provider.selectedExpiryType = value!;
//                                 provider.notifyListeners(); // Notify listeners to rebuild UI
//                               },
//                               title: AppConfig.notApplicable,
//                             ),
//                             CustomRadioListTile(
//                               value: AppConfig.scheduled,
//                               groupValue: provider.selectedExpiryType,
//                               onChanged: (value) {
//                                 provider.selectedExpiryType = value!;
//                                 provider.notifyListeners(); // Notify listeners to rebuild UI
//                               },
//                               title: AppConfig.scheduled,
//                             ),
//                             subDocTypeId == AppConfig.subDocId10MISC
//                                 ? Offstage()
//                                 : CustomRadioListTile(
//                               value: AppConfig.issuer,
//                               groupValue: provider.selectedExpiryType,
//                               onChanged: (value) {
//                                 provider.selectedExpiryType = value!;
//                                 provider.notifyListeners(); // Notify listeners to rebuild UI
//                               },
//                               title: AppConfig.issuer,
//                             ),
//                             // provider.expiryTypeError != null ?
//                             //   Text(
//                             //     provider.expiryTypeError!,
//                             //     style: CommonErrorMsg.customTextStyle(context),
//                             //   ) : SizedBox(height: 10,),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                           left: AppPadding.p20,
//                           right: AppPadding.p20,
//                         ),
//                         child: Visibility(
//                           visible: provider.selectedExpiryType == AppConfig.scheduled,
//                           child: Column(
//                             children: [
//                               SizedBox(height: AppSize.s20,),
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: AppSize.s50,
//                                     height: AppSize.s30,
//                                     //color: ColorManager.red,
//                                     child: TextFormField(
//                                       textAlign: TextAlign.center,
//                                       controller: provider.daysController, // Use the controller initialized with "1"
//                                       cursorColor: ColorManager.black,
//                                       cursorWidth: 1,
//                                       style: DocumentTypeDataStyle.customTextStyle(context),
//                                       decoration: InputDecoration(
//                                         enabledBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.grey,
//                                               width: 1),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.grey,
//                                               width: 1),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                                       ),
//                                       keyboardType: TextInputType.number,
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter
//                                             .digitsOnly, // This ensures only digits are accepted
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(width: AppSize.s10,),
//                                   Container(
//                                     width: AppSize.s80,
//                                     height: AppSize.s30,
//                                     child:CustomDropdownTextFieldwidh(
//                                       items: [
//                                         AppConfig.year,
//                                         AppConfig.month,
//                                       ],
//
//                                       // labelStyle: SearchDropdownConst.customTextStyle(context),
//                                       onChanged: (value) {
//                                         //  setState(() {
//                                         provider.selectedYear = value;
//                                         provider.isDropdownAvailability = true;
//                                         provider.notifyListeners();
//                                         print("Year,month Status :: ${provider.selectedYear}");
//                                         //  });
//                                       },
//                                     ),
//                                   )
//                                   // Container(
//                                   //   width: AppSize.s80,
//                                   //   height: AppSize.s30,
//                                   //   padding: EdgeInsets.symmetric(horizontal: 5),
//                                   //   decoration: BoxDecoration(
//                                   //     border:
//                                   //     Border.all(color: ColorManager.fmediumgrey),
//                                   //     borderRadius: BorderRadius.circular(8),
//                                   //   ),
//                                   //   child: DropdownButtonFormField<String>(
//                                   //     value:
//                                   //     provider.selectedYear, // Initial value (you should define this variable)
//                                   //     items: [
//                                   //       DropdownMenuItem(
//                                   //         value: AppConfig.year,
//                                   //         child: Text(
//                                   //           AppConfig.year,
//                                   //           style: DocumentTypeDataStyle.customTextStyle(context),
//                                   //         ),
//                                   //       ),
//                                   //       DropdownMenuItem(
//                                   //         value: AppConfig.month,
//                                   //         child: Text(
//                                   //           AppConfig.month,
//                                   //           style:DocumentTypeDataStyle.customTextStyle(context),
//                                   //         ),
//                                   //       ),
//                                   //     ],
//                                   //     onChanged: (value) {
//                                   //         provider.selectedYear = value;
//                                   //         provider.notifyListeners();
//                                   //
//                                   //     },
//                                   //     decoration: InputDecoration(
//                                   //       enabledBorder: InputBorder.none,
//                                   //       focusedBorder: InputBorder.none,
//                                   //       hintText: AppConfig.year,
//                                   //       hintStyle: DocumentTypeDataStyle.customTextStyle(context),
//                                   //       contentPadding: EdgeInsets.only(bottom: 20),
//                                   //     ),
//                                   //     icon: Icon(
//                                   //       Icons.arrow_drop_down,
//                                   //       color: ColorManager.black,
//                                   //       size: 16,
//                                   //     ),
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//         bottomButtons:
//         provider.loading == true
//             ? SizedBox(
//           height: AppSize.s30,
//           width: AppSize.s30,
//           child: CircularProgressIndicator(
//             color: ColorManager.blueprime,
//           ),
//         )
//             : CustomElevatedButton(
//           width: AppSize.s105,
//           height: AppSize.s30,
//           text: AppStringEM.add,
//           onPressed: () async {
//             provider.validateForm(); // Validate the form on button press
//             if (provider._isFormValid) {
//                 provider.loading = true;
//                 provider.notifyListeners();
//
//               int threshold = 0;
//               if (provider.selectedExpiryType == AppConfig.scheduled &&
//                   provider.daysController.text.isNotEmpty) {
//                 int enteredValue = int.parse(provider.daysController.text);
//                 if (provider.selectedYear == AppConfig.year) {
//                   threshold = enteredValue * 365;
//                 } else if (provider.selectedYear == AppConfig.month) {
//                   threshold = enteredValue * 30;
//                 }
//               }
//               try {
//                 var response =  await addNewOrgDocumentPost(
//                     context: context,
//                     docName: provider.nameDocController.text,
//                     docTypeID: docTypeId,
//                     docSubTypeID: subDocTypeId,
//                     threshold: threshold,
//                     expiryType: provider.selectedExpiryType.toString(),
//                     expiryDate: null, //expiryTypeToSend,
//                     expiryReminder: provider.selectedExpiryType.toString(),
//                     idOfDoc: provider.idDocController.text);
//                 // await getNewOrgDocument(context);
//                 if(response.statusCode == 200 || response.statusCode == 201) {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AddSuccessPopup(
//                         message: 'Added Successfully',
//                       );
//                     },
//                   );
//                 }
//                 else if(response.statusCode == 400 || response.statusCode == 404){
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => const FourNotFourPopup(),
//                   );
//                 }
//                 else {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => FailedPopup(text: response.message),
//                   );
//                 }
//               } finally {
//                   provider.loading = false;
//                   provider.notifyListeners();
//               }
//             }
//           },
//         ),
//         title: title,
//       );
//     });
//   }
}

///edit
class OrgDocNewEditPopupProvider extends ChangeNotifier {
  bool isFormValid = true;
  String selectedExpiryType = "";
  bool loading = false;
  TextEditingController idDocController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  String? nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  OrgDocNewEditPopupProvider() {
    // Adding listeners to the text fields to clear error dynamically.
    nameDocController.addListener(() {
      if (nameDocError != null && nameDocController.text.isNotEmpty) {
        nameDocError = null;  // Clear error when user starts typing.
        notifyListeners();
      }
    });
  }

  void initialize({
    required String docName,
    String? expiryType,
    int? threshold,
  }) {
    nameDocController.text = docName;
    if (expiryType == FrontendConfigStore.data!.config.scheduled) {
      selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
    } else if (expiryType == FrontendConfigStore.data!.config.notApplicable) {
      selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    } else if (expiryType == FrontendConfigStore.data!.config.issuer) {
      selectedExpiryType = FrontendConfigStore.data!.config.issuer;
    }

    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled && threshold != null) {
      if (threshold >= 365) {
        daysController.text = (threshold ~/ 365).toString(); // Set years
        selectedYear = FrontendConfigStore.data!.config.year;
      } else {
        daysController.text = (threshold ~/ 30).toString(); // Set months
        selectedYear = FrontendConfigStore.data!.config.month;
      }
    }
  }

  void validateForm() {
    isFormValid = true;
    nameDocError = validateTextField(nameDocController.text, 'Name of the Document');
    notifyListeners();
  }

  String? validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  void updateSelectedExpiryType(String value) {
    selectedExpiryType = value;
    notifyListeners();
  }

  Future<void> saveDocument({
    required BuildContext context,
    required int orgDocumentSetupid,
    required int docTypeID,
    required int docSubTypeID,
    required String docName,
    required String expiryReminder,
    required String idOfDoc,
    String? expiryType,
  }) async {
    validateForm();
    if (!isFormValid) return;

    loading = true;
    notifyListeners();

    int threshold = 0;
    String? expiryDateToSend = "";
    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled && daysController.text.isNotEmpty) {
    // if (selectedExpiryType == AppConfig.scheduled && daysController.text.isNotEmpty) {
      int enteredValue = int.parse(daysController.text);
      if (selectedYear == FrontendConfigStore.data!.config.year) {
      // if (selectedYear == AppConfig.year) {
        threshold = enteredValue * 365;
      } else if (selectedYear == FrontendConfigStore.data!.config.month) {
      // } else if (selectedYear == AppConfig.month) {
        threshold = enteredValue * 30;
      }
      expiryDateToSend = daysController.text;
    } else if (selectedExpiryType == FrontendConfigStore.data!.config.notApplicable || selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
    // } else if (selectedExpiryType == AppConfig.notApplicable || selectedExpiryType == AppConfig.issuer) {
      threshold = 0;
      expiryDateToSend = null;
    }

    try {
      String finalDocName = nameDocController.text.isNotEmpty
          ? nameDocController.text
          : docName;

      var response = await updateNewOrgDocumentPatch(
        context: context,
        orgDocumentSetupid: orgDocumentSetupid,
        docTypeID: docTypeID,
        docSubTypeID: docSubTypeID,
        docName: finalDocName,
        expiryType: selectedExpiryType,
        threshold: threshold,
        expiryDate: null,
        expiryReminder: expiryReminder,
        idOfDoc: idOfDoc,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddSuccessPopup(
              message: 'Edited Successfully',
            );
          },
        );
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => const FourNotFourPopup(),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => FailedPopup(text: response.message),
        );
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class OrgDocNewEditPopup extends StatelessWidget {
  final double? height;
  final String docTypeText;
  final int docTypeId;
  final int subDocTypeId;
  final String subDocTypeText;
  final String title;
  final String? selectedSubDocType;
  final int orgDocumentSetupid;
  final String docName;
  final String? expiryType;
  final int? threshhold;
  final String? expiryDate;
  final String expiryReminder;
  final String idOfDoc;

  const OrgDocNewEditPopup({
    super.key,
    required this.title,
    this.height,
    this.selectedSubDocType,
    required this.docTypeText,
    required this.docTypeId,
    required this.subDocTypeId,
    required this.subDocTypeText,
    required this.orgDocumentSetupid,
    required this.docName,
    this.expiryType,
    this.threshhold,
    this.expiryDate,
    required this.expiryReminder,
    required this.idOfDoc,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = OrgDocNewEditPopupProvider();
        provider.initialize(
          docName: docName,
          expiryType: expiryType,
          threshold: threshhold,
        );
        return provider;
      },
      child: Consumer<OrgDocNewEditPopupProvider>(
        builder: (context, provider, _) {
          return DialogueTemplate(
            width: AppSize.s420,
            height: height ?? AppSize.s450,
            body: [
              /// ID of the Document
              HeaderContentConst(
                heading: AppString.id_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        idOfDoc,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSize.s10,),
              /// Name of the Document
              SMTextfieldAsteric(
                controller: provider.nameDocController,
                keyboardType: TextInputType.text,
                text: AppString.name_of_the_document,
              ),
              provider.nameDocError != null ? // Display error if any
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                         left: AppPadding.p15),
                      child: Text(
                        provider.nameDocError!,
                        style: CommonErrorMsg.customTextStyle(context)
                      ),
                    ),
                  ],
                ) : SizedBox(height: AppSize.s12,),

              /// Type of the Document
              HeaderContentConst(
                heading: AppString.type_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        docTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSize.s10,),

              /// Sub Type of the Document
              docTypeId ==FrontendConfigStore.data!.config.policiesAndProcedure
              // docTypeId == AppConfig.policiesAndProcedure
                  ? const SizedBox(height: 1)
                  : HeaderContentConst(
                heading: AppString.sub_type_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subDocTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottomButtons: provider.loading
                ? SizedBox(
              height: AppSize.s30,
              width: AppSize.s30,
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            )
                : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              onPressed: () => provider.saveDocument(
                context: context,
                orgDocumentSetupid: orgDocumentSetupid,
                docTypeID: docTypeId,
                docSubTypeID: subDocTypeId,
                docName: docName,
                expiryReminder: expiryReminder,
                idOfDoc: idOfDoc,
                expiryType: expiryType,
              ),
            ), title: title,
          );
        },
      ),
    );
  }
}
