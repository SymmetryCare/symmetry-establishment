///upload add
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';

class UploadDocumentAddPopup extends StatefulWidget {
  final String title;
  bool? loadingDuration;
  final String officeId;
  final int docTypeMetaIdCC;
  final String docTypeText;
  final String subDocTypeText;
  final int selectedSubDocId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;
  final List<TypeofDocpopup> dataList;
  // final Visibility? child3;
  UploadDocumentAddPopup({
    required this.title,
    this.loadingDuration,
    this.height,
    this.uploadField,
    required this.officeId,
    required this.docTypeMetaIdCC,
    required this.selectedSubDocId,
    required this.dataList,
    required this.docTypeText,
    required this.subDocTypeText,
    // this.child3
  });

  @override
  State<UploadDocumentAddPopup> createState() => _UploadDocumentAddPopupState();
}

class _UploadDocumentAddPopupState extends State<UploadDocumentAddPopup> {
  int docTypeId = 0;
  String documentTypeName = "";
  dynamic filePath;
  String? selectedDocType;
  String fileName = '';
  String _url = "";
  bool showExpiryDateField = false;
  bool isFileSelected = false;
  bool isFileErrorVisible = false;

  TextEditingController expiryDateController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController idDocController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController subTypeController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");
  bool load = false;
  DateTime? datePicked;
  List<DropdownMenuItem<String>> dropDownMenuItems = [];
  String selectedExpiryType = "Not Applicable";
  bool _isFormValid = true;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  bool isDropdownAvailability = false;
  String? _idDocError;
  String? _nameDocError;
  String? _dropdownError;
  String? _expiryTypeError;
  String? _issueDateError;
  @override
  void initState() {
    dropDownMenuItems = widget.dataList
        .map((doc) => DropdownMenuItem<String>(
      value: doc.docname,
      child: Text(doc.docname),
    ))
        .toList();

    super.initState();
    _url = "";
    showExpiryDateField;
  }
  bool fileAbove20Mb = false;
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final fileSize = result?.files.first.size; // File size in bytes
    final isAbove20MB = fileSize! > (20 * 1024 * 1024); // 20MB in bytes
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        isFileSelected = true;
        isFileErrorVisible = false;
        fileAbove20Mb = !isAbove20MB;
      });
    }
  }
  bool loading = false;
  String selectedRadio = "Pre-defined";

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }
  void _validateForm() {
    setState(() {
      _isFormValid = true;  // Assume form is valid, and mark false only if errors are found.

      _idDocError = _validateTextField(idDocController.text, 'ID of the Document');
      if (_idDocError != null) _isFormValid = false;

      _nameDocError = _validateTextField(nameDocController.text, 'Name of the Document');
      if (_nameDocError != null) _isFormValid = false;

      isFileErrorVisible = !isFileSelected;
      if (!isFileSelected) _isFormValid = false;

      // Check if a document type is selected
      if (selectedRadio == "Pre-defined" && (selectedDocType == null || selectedDocType == "Select" || selectedDocType == "No available documents")) {
        setState(() {
          _dropdownError = "Please select a document type";  // Show error
        });
        return;
      } else {
        setState(() {
          _dropdownError = null;  // Clear error if valid
        });
      }


      if (selectedExpiryType == FrontendConfigStore.data!.config.issuer && expiryDateController.text.isEmpty) {
      // if (selectedExpiryType == AppConfig.issuer && expiryDateController.text.isEmpty) {
        _issueDateError = "Please select an expiry date";
        _isFormValid = false;
      } else {
        _issueDateError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TerminationDialogueTemplate(
      width: AppSize.s420,
      height: selectedRadio == "Pre-defined"
          ? widget.height == null
          ? AppSize.s374
          : widget.height!
          : widget.height == null
          ? 660
          : widget.height!,
      body: [
        Padding(
          padding: const EdgeInsets.only(left: AppPadding.p5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRadioListTile(
                title: 'Pre-defined',
                value: 'Pre-defined',
                groupValue: selectedRadio,
                onChanged: (value) {
                  setState(() {
                    selectedRadio = value!;
                  });
                },
              ),
              CustomRadioListTile(
                title: 'Other',
                value: 'Other',
                groupValue: selectedRadio,
                onChanged: (value) {
                  setState(() {
                    selectedRadio = value!;
                  });
                },
              ),
            ],
          ),
        ),
        selectedRadio == "Pre-defined"
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
              HeaderContentConst(
                isAsterisk: true,
                heading: AppString.type_of_the_document,
                content:  Column(
                  children: [
                    CICCDropdown(
                      constraintHeight: 200,
                      width: AppSize.s354,
                      borderRadius: 8,
                      initialValue: dropDownMenuItems.isEmpty ? "No available documents":selectedDocType ?? "Select",
                      onChange: (val) {
                        setState(() {
                          selectedDocType = val;
                          _dropdownError = null;
                          showExpiryDateField = false;
                          isFileErrorVisible = false;
                          for (var doc in widget.dataList) {
                            if (doc.docname == val) {
                              docTypeId = doc.orgDocumentSetupid;
                              documentTypeName = doc.idOfDocument;
                              if (doc.expirytype == FrontendConfigStore.data!.config.issuer) {
                              // if (doc.expirytype == AppConfig.issuer) {
                                showExpiryDateField = true;
                              }
                            }
                          }
                        });
                      },
                      items: dropDownMenuItems,
                    ),
                   _dropdownError != null ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Please select a document type',
                            style:
                            CommonErrorMsg.customTextStyle(context),
                          ),
                        ],
                      ) : SizedBox(height: AppSize.s12,),
                  ],
                ),
              ),
              Visibility(
                visible: showExpiryDateField,
                child: HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.expiry_date,
                  content: FormField<String>(
                    builder: (FormFieldState<String> field) {
                      return SizedBox(
                        height: AppSize.s30,
                        width: AppSize.s354,
                        child: TextFormField(
                          controller: expiryDateController,
                          cursorColor: ColorManager.black,
                          style: DocumentTypeDataStyle.customTextStyle(
                              context),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorManager.fmediumgrey,
                                  width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorManager.fmediumgrey,
                                  width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'yyyy-mm-dd',
                            hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: ColorManager.fmediumgrey),
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p12),
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
                              expiryDateController.text =
                                  DateFormat('yyyy-MM-dd')
                                      .format(pickedDate);
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
              ),

              /// Upload document
              HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.upload_document,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap:
                        _pickFile, // Trigger file picking when the whole container is tapped
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s354,
                          padding: EdgeInsets.only(left: AppPadding.p10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorManager.containerBorderGrey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    fileName.isEmpty
                                        ? "No file selected"
                                        : fileName,
                                    style: DocumentTypeDataStyle
                                        .customTextStyle(context),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.all(AppPadding.p4),
                                  onPressed:
                                  _pickFile, // Keep file picker here as well for icon press
                                  icon: Icon(
                                    Icons.file_upload_outlined,
                                    color: ColorManager.black,
                                    size: IconSize.I16,
                                  ),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isFileErrorVisible)
                        Padding(
                          padding: const EdgeInsets.only(top: AppPadding.p5),
                          child: Text(
                            'Please upload a document',
                            style: CommonErrorMsg.customTextStyle(context),
                          ),
                        ),
                    ],
                  ))
                        ],
                      ),
            )



            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///name
              SMTextfieldAsteric(
                controller: nameDocController,
                keyboardType: TextInputType.text,
                text: AppStringEM.NameOfDoc,
                onChanged: (value){
                  setState(() {
                    _isFormValid = true;
                    _nameDocError = _validateTextField(nameDocController.text, 'Name of the Document');
                  });
                },
              ),
              _nameDocError != null ? // Display error if any
              Text(
                _nameDocError!,
                style:CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s2),

              ///id
              SMTextfieldAsteric(
                controller: idDocController,
                keyboardType: TextInputType.text,
                text: AppStringEM.idOfDOc,
                onChanged: (value){
                  setState(() {
                    _isFormValid = true;
                    _idDocError = _validateTextField(idDocController.text, 'ID of the Document');
                  });
                },
              ),
              _idDocError != null ? // Display error if any
              Text(
                _idDocError!,
                style:CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s2),

              /// Type of the Document
              HeaderContentConst(
                heading: AppString.type_of_the_document,
                content: Container(
                  height: AppSize.s30,
                  width: AppSize.s354,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p5, horizontal: AppPadding.p10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.docTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSize.s8),

              /// SubType of the Document
              widget.selectedSubDocId == FrontendConfigStore.data!.config.subDocId0
              // widget.selectedSubDocId == AppConfig.subDocId0
                  ? SizedBox()
                  : HeaderContentConst(
                isAsterisk: true,
                heading: AppString.sub_type_of_the_document,
                content: Container(
                  height: AppSize.s30,
                  width: AppSize.s354,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p5, horizontal: AppPadding.p10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.subDocTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSize.s8),
              /// Upload document
              HeaderContentConst(
                  isAsterisk: true,
                 // isDoc: true,
                  heading: AppString.upload_document,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap:
                        _pickFile, // Trigger file picking when the whole container is tapped
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s354,
                          padding: EdgeInsets.only(left: AppPadding.p8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorManager.containerBorderGrey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: TableSubHeading.customTextStyle(context),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.all(AppPadding.p4),
                                  onPressed:
                                  _pickFile, // Keep file picker here as well for icon press
                                  icon: Icon(
                                    Icons.file_upload_outlined,
                                    color: ColorManager.black,
                                    size: IconSize.I16,
                                  ),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      isFileErrorVisible ?
                      Padding(
                        padding: const EdgeInsets.only(top: AppPadding.p1),
                        child: Text(
                          'Please upload a document',
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ) : SizedBox(height: AppSize.s12,),
                    ],
                  )),

              ///radio
              Row(
                children: [
                  HeaderContentConst(
                    // isAsterisk: true,
                    heading: AppString.expiry_type,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomRadioListTile(
                          value: FrontendConfigStore.data!.config.notApplicable,
                          // value: AppConfig.notApplicable,
                          groupValue: selectedExpiryType,
                          onChanged: (value) {
                            setState(() {
                              selectedExpiryType = value!;
                            });
                          },
                          title: FrontendConfigStore.data!.config.notApplicable,
                          // title: AppConfig.notApplicable,
                        ),
                        CustomRadioListTile(
                          value: FrontendConfigStore.data!.config.scheduled,
                          // value: AppConfig.scheduled,
                          groupValue: selectedExpiryType,
                          onChanged: (value) {
                            setState(() {
                              selectedExpiryType = value!;
                            });
                          },
                          title: FrontendConfigStore.data!.config.scheduled,
                          // title: AppConfig.scheduled,
                        ),
                        CustomRadioListTile(
                          value: FrontendConfigStore.data!.config.issuer,
                          // value: AppConfig.issuer,
                          groupValue: selectedExpiryType,
                          onChanged: (value) {
                            setState(() {
                              selectedExpiryType = value!;
                            });
                          },
                          title: FrontendConfigStore.data!.config.issuer,
                          // title: AppConfig.issuer,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                    ),
                    child: Visibility(
                      visible:
                      selectedExpiryType == FrontendConfigStore.data!.config.scheduled,
                      // selectedExpiryType == AppConfig.scheduled,
                      child: Column(
                        children: [
                          SizedBox(
                            height: AppSize.s20,
                          ),
                          Row(
                            children: [
                              Container(
                                height: AppSize.s30,
                                width: AppSize.s50,
                                //color: ColorManager.red,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  controller:
                                  daysController, // Use the controller initialized with "1"
                                  cursorColor: ColorManager.black,
                                  cursorWidth: 1,
                                  style: TableSubHeading.customTextStyle(context),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey),
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey),
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: AppPadding.p10),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly, // This ensures only digits are accepted
                                  ],
                                ),
                              ),
                              SizedBox(width: AppSize.s10),
                              Container(
                                width: AppSize.s80,
                                height: AppSize.s30,
                                child:CustomDropdownTextFieldwidh(
                                  hintText: selectedYear,
                                  items: [
                                    FrontendConfigStore.data!.config.year,
                                    // AppConfig.year,
                                    FrontendConfigStore.data!.config.month,
                                    // AppConfig.month,
                                  ],

                                  // labelStyle: SearchDropdownConst.customTextStyle(context),
                                  onChanged: (value) {
                                    //  setState(() {
                                    selectedYear = value;
                                    isDropdownAvailability = true;
                                    print("Year,month Status :: ${selectedYear}");
                                    //  });
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              ///date
              Visibility(
                visible: selectedExpiryType == FrontendConfigStore.data!.config.issuer,
                // visible: selectedExpiryType == AppConfig.issuer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HeaderContentConst(
                      isAsterisk: true,
                      heading: AppString.expiry_date,
                      content: FormField<String>(
                        builder: (FormFieldState<String> field) {
                          return SizedBox(
                            height: AppSize.s30,
                            width: AppSize.s354,
                            child: TextFormField(
                              controller: expiryDateController,
                              cursorColor: ColorManager.black,
                              style: TableSubHeading.customTextStyle(context),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorManager.fmediumgrey,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorManager.fmediumgrey,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'yyyy-mm-dd',
                                hintStyle: TableSubHeading.customTextStyle(context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: ColorManager.fmediumgrey),
                                ),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: AppPadding.p10),
                                suffixIcon: Icon(
                                    Icons.calendar_month_outlined,
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
                                  setState(() {
                                    datePicked = pickedDate;
                                    expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                    _issueDateError = null; // Hide error message when date is selected
                                  });
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  _issueDateError = null; // Hide error message when text is changed
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (_issueDateError != null) // Display error if any
                      Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p5),
                        child: Text(
                          _issueDateError!,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ),
                  ],
                )

                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     HeaderContentConst(
                //       isAsterisk: true,
                //       heading: AppString.expiry_date,
                //       content: FormField<String>(
                //         builder: (FormFieldState<String> field) {
                //           return SizedBox(
                //             height: AppSize.s30,
                //             width: AppSize.s354,
                //             child: TextFormField(
                //               controller: expiryDateController,
                //               cursorColor: ColorManager.black,
                //               style:TableSubHeading.customTextStyle(context),
                //               decoration: InputDecoration(
                //                 enabledBorder: OutlineInputBorder(
                //                   borderSide: BorderSide(
                //                       color: ColorManager.fmediumgrey,
                //                       width: 1),
                //                   borderRadius: BorderRadius.circular(6),
                //                 ),
                //                 focusedBorder: OutlineInputBorder(
                //                   borderSide: BorderSide(
                //                       color: ColorManager.fmediumgrey,
                //                       width: 1),
                //                   borderRadius: BorderRadius.circular(6),
                //                 ),
                //                 hintText: 'yyyy-mm-dd',
                //                 hintStyle:TableSubHeading.customTextStyle(context),
                //                 border: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(6),
                //                   borderSide: BorderSide(
                //                       width: 1,
                //                       color: ColorManager.fmediumgrey),
                //                 ),
                //                 contentPadding:
                //                 EdgeInsets.symmetric(horizontal: AppPadding.p16),
                //                 suffixIcon: Icon(
                //                     Icons.calendar_month_outlined,
                //                     color: ColorManager.blueprime),
                //                 errorText: field.errorText,
                //               ),
                //               onTap: () async {
                //                 DateTime? pickedDate = await showDatePicker(
                //                   context: context,
                //                   initialDate: DateTime.now(),
                //                   firstDate: DateTime(1901),
                //                   lastDate: DateTime(3101),
                //                 );
                //                 if (pickedDate != null) {
                //                   datePicked = pickedDate;
                //                   expiryDateController.text =
                //                       DateFormat('yyyy-MM-dd')
                //                           .format(pickedDate);
                //                 }
                //               },
                //             ),
                //           );
                //         },
                //       ),
                //     ),
                //     if (_issueDateError != null) // Display error if any
                //       Padding(
                //         padding: const EdgeInsets.only(left: AppPadding.p5),
                //         child: Text(
                //           _issueDateError!,
                //           style:CommonErrorMsg.customTextStyle(context),
                //         ),
                //       ),
                //   ],
                // ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        )
      ],
      bottomButtons: load
          ? SizedBox(
        height: AppSize.s30,
        width: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : selectedRadio == "Pre-defined"
          ? CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.add, // submit
        onPressed: () async {
          _validateForm();
          // setState(() {
          //   isFileErrorVisible = !isFileSelected;
          // });


          // Check if a document type is selected
          if (selectedDocType == null || selectedDocType == "Select" || selectedDocType == "No available documents") {
            setState(() {
              _dropdownError = "Please select a document type";  // Show error
            });
            return;
          }

          // Check if the file is selected
          if (!isFileSelected) {
            setState(() {
              isFileErrorVisible = true;  // Show file upload error
            });
            return;
          }
          // if (!isFileSelected) {
          //   return;
          // }

          setState(() {
            load = true;
          });

          try {
            String? expiryDate;
            if (expiryDateController.text.isEmpty) {
              expiryDate = null;
            } else {
              expiryDate = datePicked!.toIso8601String() + "Z";
            }
            if(fileAbove20Mb){
              ApiData response = await addOrgDocPPPost(
                context: context,
                orgDocumentSetupid: docTypeId,
                idOfDocument: documentTypeName,
                expiryDate: expiryDate,
                docCreated: DateTime.now().toIso8601String() + "Z",
                url: "url",
                officeId: widget.officeId,
                fileName: fileName,
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                try {
                  var uploadDocNew = await uploadDocumentsoffice(
                    context: context,
                    documentFile: filePath,
                    orgOfficeDocumentId: response.orgOfficeDocumentId!,
                    fileName: fileName,
                  );

                  if (uploadDocNew.statusCode == 413) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddErrorPopup(
                          message: 'Request entity too large! File size exceeds limit.',
                        );
                      },
                    );
                  } else if (uploadDocNew.statusCode == 200 || uploadDocNew.statusCode == 201) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CountySuccessPopup(
                          message: 'Saved Successfully',
                        );
                      },
                    );
                  } else {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FailedPopup(
                          text: 'Failed to upload document. Please edit upload again.',
                        );
                      },
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FailedPopup(
                        text: 'An error occurred during file upload. Check your connection or file size.',
                      );
                    },
                  );
                }
              }
              else if (response.statusCode == 400 || response.statusCode == 404) {
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
                  builder: (BuildContext context) {
                    return FailedPopup(
                      text: response.message ?? 'An error occurred. Please try again.',
                    );
                  },
                );
              }
            }else{
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddErrorPopup(
                    message: 'File is too large!',
                  );
                },
              );
            }
          } catch (e) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return FailedPopup(
                  text: 'An error occurred. Please try again later.',
                );
              },
            );
          } finally {
            setState(() {
              load = false; // Ensure loader is turned off
            });
          }
        },
      )







          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.add, // submit
        onPressed: () async {
          _validateForm();
          if (!_isFormValid) {
            print("Form is invalid, submission blocked.");
            return;
          }

          if (!isFileSelected) {
            return;
          }

          setState(() {
            load = true;
          });

          try {
            String? expiryDate;
            if (expiryDateController.text.isEmpty) {
              expiryDate = null;
            } else {
              expiryDate = datePicked!.toIso8601String() + "Z";
            }

            int threshold = 0;
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
            }
            if (fileAbove20Mb) {
              print("docTypeMetaIdCC @@@@@@@@@@@ ${widget.docTypeMetaIdCC}");
              print("subdocTypeMetaIdCC @@@@@@@@@@@ ${widget.selectedSubDocId}");
              print("documentname @@@@@@@@@@@ ${nameDocController.text}");
              print("idDocController @@@@@@@@@@@ ${idDocController.text}");
              print("selectedExpiryType @@@@@@@@@@@ ${selectedExpiryType.toString()}");
              print("threshold @@@@@@@@@@@ ${threshold}");
              print("exp date @@@@@@@@@@@ ${expiryDate}");
              ApiData newResponse = await addOtherOfficeDocPost(
                context: context,
                docTypeid: widget.docTypeMetaIdCC,
                docSubTypeid: widget.selectedSubDocId == FrontendConfigStore.data!.config.subDocId0
                // docSubTypeid: widget.selectedSubDocId == AppConfig.subDocId0
                    ? FrontendConfigStore.data!.config.subDocId0
                    // ? AppConfig.subDocId0
                    : widget.selectedSubDocId,
                documentName: nameDocController.text,
                expiryType: selectedExpiryType.toString(),
                threshold: threshold,
                expiryDate: expiryDate,
                expiryReminder: selectedExpiryType.toString(),
                idOfDoc: idDocController.text,
                docCreated: DateTime.now().toIso8601String() + "Z",
                fileName: fileName,
                url: 'url',
                officeId: widget.officeId,
              );

              if (newResponse.statusCode == 200 || newResponse.statusCode == 201) {
                try {
                  var uploadDocNew = await uploadDocumentsoffice(
                    context: context,
                    documentFile: filePath,
                    fileName: fileName,
                    orgOfficeDocumentId: newResponse.orgOfficeDocumentId!,
                  );

                  if (uploadDocNew.statusCode == 413) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddErrorPopup(
                          message: 'Request entity too large! File size exceeds limit.',
                        );
                      },
                    );
                  }
                  else if (uploadDocNew.statusCode == 200 ||
                      uploadDocNew.statusCode == 201) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CountySuccessPopup(
                          message: 'Saved Successfully',
                        );
                      },
                    );
                  } else {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FailedPopup(
                          text: 'Failed to upload document. Please edit upload again.',
                        );
                      },
                    );
                  }
                } catch (e) {
                  Navigator.pop(context); // Close the loader
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FailedPopup(
                        text: 'An error occurred during file upload. Check your connection or file size.',
                      );
                    },
                  );
                }
              }
              else if (newResponse.statusCode == 400 ||
                  newResponse.statusCode == 404) {
                Navigator.pop(context); // Close the loader
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const FourNotFourPopup(),
                );
              }
              else {
                Navigator.pop(context); // Close the loader
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FailedPopup(
                      text: newResponse.message ??
                          'An error occurred. Please try again.',
                    );
                  },
                );
              }
            } else {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddErrorPopup(
                    message: 'File is too large!',
                  );
                },
              );
            }
          }catch (e) {
            Navigator.pop(context); // Close the loader
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return FailedPopup(
                  text: 'An error occurred. Please try again later.',
                );
              },
            );
          } finally {
            setState(() {
              load = false; // Ensure loader is turned off
            });
          }
        },
      ),

      title: widget.title,
    );
  }
}
///