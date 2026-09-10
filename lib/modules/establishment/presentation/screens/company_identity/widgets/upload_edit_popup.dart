///upload edit
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';

class VCScreenPopupEditConst extends StatefulWidget {
  final String title;
  bool? loadingDuration;
  final String officeId;
  final int orgDocId;
  final String docName;
  final String idOfDoc;
  final String url;
  final String selectedExpiryType;
  final int orgDocumentSetupid;
  final String? expiryDate;
  final String fileName;
  final String documentType;
  final String documentSubType;
  final int docTypeMetaIdCC;
  final int selectedSubDocId;
  final bool isOthersDocs;
  final String? expiryType;
  final int? threshhold;
  final double? height;
  final Widget? uploadField;
  VCScreenPopupEditConst({
    super.key,
    required this.title,
    required this.fileName,
    this.height,
    this.expiryType,
    this.threshhold,
    this.loadingDuration,
    this.uploadField,
    required this.officeId,
    required this.docTypeMetaIdCC,
    required this.selectedSubDocId,
    required this.orgDocId,
    required this.orgDocumentSetupid,
    required this.docName,
    required this.selectedExpiryType,
    this.expiryDate,
    required this.url, required this.documentType,
    required this.documentSubType,
    required this.isOthersDocs, required this.idOfDoc,
  });

  @override
  State<VCScreenPopupEditConst> createState() => _VCScreenPopupEditConstState();
}

class _VCScreenPopupEditConstState extends State<VCScreenPopupEditConst> {
  int docTypeId = 0;
  String? documentTypeName;
  dynamic filePath;
  String? selectedDocType;
  String fileName = '';
  bool fileIsPicked = false;
  DateTime? datePicked;
  bool loading = false;
  String selectedRadio = "";
  String selectedExpiryType = "";
  bool _isFormValid = true;
  bool isFileErrorVisible = false;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  // String? selectedYear = AppConfig.year;
  bool isDropdownAvailability = false;
  String? _idDocError;
  String? _nameDocError;
  String? _expiryTypeError;
  bool fileAbove20Mb = false;


  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf']);
    final fileSize = result?.files.first.size; // File size in bytes
    final isAbove20MB = fileSize! > (20 * 1024 * 1024); // 20MB in bytes
    if (result != null) {
      setState(() {
        fileIsPicked = true;
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        fileAbove20Mb = !isAbove20MB;
      });
    }
  }

  bool showExpiryDateField = false;
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController idDocController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController subTypeController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  // void ExpityTypeRadio(){
  //   if (widget.expiryType == AppConfig.scheduled) {
  //     selectedExpiryType = AppConfig.scheduled;
  //   }
  //   else if (widget.expiryType == AppConfig.notApplicable) {
  //     selectedExpiryType = AppConfig.notApplicable;
  //   }
  //   else if (widget.expiryType == AppConfig.issuer) {
  //     selectedExpiryType = AppConfig.issuer;
  //   }
  // }

  void ExpityTypeRadio(){
    if (widget.expiryType == FrontendConfigStore.data!.config.scheduled) {
      selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
    }
    else if (widget.expiryType == FrontendConfigStore.data!.config.notApplicable) {
      selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    }
    else if (widget.expiryType == FrontendConfigStore.data!.config.issuer) {
      selectedExpiryType = FrontendConfigStore.data!.config.issuer;
    }
  }


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
      _idDocError = _validateTextField(idDocController.text, 'id of the Document');
      if (selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
      // if (selectedExpiryType == AppConfig.issuer) {
        if (expiryDateController.text.isEmpty) {
          _expiryTypeError = "Please select expiry date";
          _isFormValid = false;
        } else {
          _expiryTypeError = null;
        }
      } else {
        _expiryTypeError = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.expiryType);
    print(widget.expiryDate);
    print(expiryDateController.text);
    nameDocController.text = widget.docName;
    idDocController.text = widget.idOfDoc;
    if (widget.selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
    // if (widget.selectedExpiryType == AppConfig.issuer) {
      if(widget.expiryDate == "")
      {
        expiryDateController = TextEditingController(
            text: "");
      }
      else {
        DateTime dateTime =
        DateTime.parse(widget.expiryDate ?? DateTime.now().toString());
        showExpiryDateField = true;
        datePicked = dateTime;
        expiryDateController = TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(dateTime));
      }
    }
    fileName = widget.fileName;
    ExpityTypeRadio();
    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled && widget.threshhold != null) {
    // if (selectedExpiryType == AppConfig.scheduled && widget.threshhold != null) {
      int threshold = widget.threshhold!;

      if (threshold >= 365) {
        daysController.text = (threshold ~/ 365).toString(); // Set years
        selectedYear = FrontendConfigStore.data!.config.year;
        // selectedYear = AppConfig.year;
      } else {
        daysController.text = (threshold ~/ 30).toString(); // Set months
        selectedYear = FrontendConfigStore.data!.config.month;
        // selectedYear = AppConfig.month;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TerminationDialogueTemplate(
      width: AppSize.s420,
      height:  widget.isOthersDocs == false
          ? widget.height == null ? AppSize.s390 : widget.height!
          : widget.height == null ? AppSize.s580 : widget.height! ,

      body: [
        widget.isOthersDocs == false
            ? Column(
          children: [
            HeaderContentConst(
              heading: AppString.type_of_the_document,
              content: Container(
                width: AppSize.s354,
                padding: EdgeInsets.symmetric(vertical: AppPadding.p3, horizontal: AppPadding.p10),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.docName,
                      style: DocumentTypeDataStyle.customTextStyle(context),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),

            /// upload  doc
            HeaderContentConst(
                isAsterisk: true,
                heading: AppString.upload_document,
                content: InkWell(
                  onTap: _pickFile,
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
                    child: StatefulBuilder(
                      builder: (BuildContext context,
                          void Function(void Function()) setState) {
                        return Padding(
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.all(AppPadding.p4),
                                onPressed: _pickFile,
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
                        );
                      },
                    ),
                  ),
                )),
            Visibility(
              visible: showExpiryDateField,
              /// Conditionally display expiry date field
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.fmediumgrey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.fmediumgrey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'yyyy-mm-dd',
                          hintStyle: ConstTextFieldRegister.customTextStyle(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                width: 1, color: ColorManager.fmediumgrey),
                          ),
                          contentPadding: EdgeInsets.only(left: AppPadding.p13),
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              color: ColorManager.blueprime),
                          errorText: field.errorText,
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: datePicked,
                            firstDate: DateTime(1901),
                            lastDate: DateTime(3101),
                          );
                          if (pickedDate != null) {
                            datePicked = pickedDate;
                            expiryDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please select date';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        )



            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///name
              FirstSMTextFConst(
                controller: nameDocController,
                keyboardType: TextInputType.text,
                text: 'Name of the Document',
                onTapChange: (val){
                  _validateForm();
                },
              ),
              _nameDocError != null ? // Display error if any
              Text(
                _nameDocError!,
                style:CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s2),

              ///id
              SMTextFConst(
                controller: idDocController,
                keyboardType: TextInputType.text,
                text: 'ID of the Document',
                onChangeField: (val){
                  _validateForm();
                },
              ),
              _idDocError != null ? // Display error if any
              Text(
                _idDocError!,
                style:CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s2),
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
                                    fileName,
                                    style: DocumentTypeDataStyle
                                        .customTextStyle(context),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.all(4),
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
                        padding: const EdgeInsets.only(top: AppPadding.p5),
                        child: Text(
                          'Please upload a document',
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      ) : SizedBox(height: AppSize.s12,),
                    ],
                  )),
              // /// Type of the Document
              // HeaderContentConst(
              //   heading: AppString.type_of_the_document,
              //   content: Container(
              //     width: 354,
              //     height: 30,
              //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              //     decoration: BoxDecoration(
              //       color: ColorManager.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: ColorManager.fmediumgrey, width: 1),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           widget.documentType,
              //           style: DocumentTypeDataStyle.customTextStyle(context),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: AppSize.s2),
              //
              // /// SubType of the Document
              // widget.selectedSubDocId == AppConfig.subDocId0
              //     ? SizedBox()
              //     : HeaderContentConst(
              //   heading: AppString.sub_type_of_the_document,
              //   content: Container(
              //     width: 354,
              //     height: 30,
              //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              //     decoration: BoxDecoration(
              //       color: ColorManager.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: ColorManager.fmediumgrey, width: 1),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           widget.documentSubType,
              //           style: DocumentTypeDataStyle.customTextStyle(context),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: AppSize.s2),
              ///radio
              Row(
                children: [
                  HeaderContentConst(
                    //isAsterisk: true,
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
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:Colors.grey,),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:Colors.grey,),
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p13),
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
                                  hintText:selectedYear ,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppPadding.p5,
                      right: AppPadding.p5,
                    ),
                    child: Visibility(
                      visible: selectedExpiryType == FrontendConfigStore.data!.config.issuer,
                      // visible: selectedExpiryType == AppConfig.issuer,
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
                                  hintStyle:
                                  DocumentTypeDataStyle.customTextStyle(
                                      context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: ColorManager.fmediumgrey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p13),
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
                                    datePicked = pickedDate;
                                    expiryDateController.text =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    _validateForm();
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
                  ),
                  if (_expiryTypeError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: AppPadding.p5),
                      child: Text(
                        _expiryTypeError!,
                        style:  CommonErrorMsg.customTextStyle(context),
                      ),
                    ),
                ],
              ),

            ],
          ),
        )
      ],
      bottomButtons: loading
          ? SizedBox(
        height: AppSize.s25,
        width: AppSize.s25,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          :  widget.isOthersDocs == false
          ? CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          // ✅ Validate file
          if (fileIsPicked && !fileAbove20Mb) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddErrorPopup(
                  message: 'File is too large!',
                );
              },
            );
            return;
          }
          setState(() {
            loading = true; // Show loader
          });

          try {
            // ✅ Prepare expiry date
            String? expiryDate = widget.selectedExpiryType == FrontendConfigStore.data!.config.issuer
            // String? expiryDate = widget.selectedExpiryType == AppConfig.issuer
                ?  datePicked!.toIso8601String() + 'Z'
                : null;

            print('Final Expiry Date: $expiryDate');
            print('Expiry Date Field Text: ${expiryDateController.text}');

            // ✅ Step 1: Update metadata
            var response = await updateOrgDoc(
              context: context,
              orgDocId: widget.orgDocId,
              orgDocumentSetupid: widget.orgDocumentSetupid,
              idOfDocument: widget.docName,
              expiryDate: expiryDate,
              docCreatedat: DateTime.now().toIso8601String() + "Z",
              url: widget.url,
              fileName: (fileIsPicked && fileAbove20Mb) ? fileName : widget.fileName,
              officeid: widget.officeId,
            );

            // ✅ Step 2: Upload file if picked
            if (fileIsPicked) {
              var uploadDocNew = await uploadDocumentsoffice(
                context: context,
                documentFile: filePath,
                fileName: fileName,
                orgOfficeDocumentId: response.orgOfficeDocumentId!,
              );

              // Close loader

              if (uploadDocNew.statusCode == 200 || uploadDocNew.statusCode == 201) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddSuccessPopup(
                      message: 'Document updated successfully!',
                    );
                  },
                );
              } else {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FailedPopup(text: response.message);
                  },
                );
              }
            } else {
              // ✅ No file picked, but metadata updated — show success popup
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddSuccessPopup(
                    message: 'Document updated successfully!',
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
          }
            setState(() {
              loading = false; // Turn off loader
            });

        },
      )




          : CustomElevatedButton(
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.save, //submit
          onPressed: () async {
            _validateForm();
            if (!_isFormValid) {
              return; // Stop here if the form is not valid
            }
            if (fileIsPicked && !fileAbove20Mb) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddErrorPopup(
                    message: 'File is too large!',
                  );
                },
              );
              return;
            }
            setState(() {
              loading = true;
            });

            try {
              int threshold = 0;
              String? expiryDateToSend;

              if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled) {
              // if (selectedExpiryType == AppConfig.scheduled) {
                if (daysController.text.isNotEmpty) {
                  int enteredValue = int.parse(daysController.text);
                  if (selectedYear == FrontendConfigStore.data!.config.year) {
                  // if (selectedYear == AppConfig.year) {
                    threshold = enteredValue * 365;
                  } else if (selectedYear == FrontendConfigStore.data!.config.month) {
                  // } else if (selectedYear == AppConfig.month) {
                    threshold = enteredValue * 30;
                  }
                }
                expiryDateToSend = null;
              } else if (selectedExpiryType == FrontendConfigStore.data!.config.notApplicable) {
              // } else if (selectedExpiryType == AppConfig.notApplicable) {
                threshold = 0;
                expiryDateToSend = null;
              } else if (selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
              // } else if (selectedExpiryType == AppConfig.issuer) {
                if (expiryDateController.text.isEmpty) {
                  setState(() {
                    _expiryTypeError = "Please select expiry date";
                    loading = false;
                  });
                  return;
                }
                threshold = 0;
                // expiryDateToSend = datePicked != null
                // ? datePicked!.toIso8601String() + "Z"
                //     : widget.expiryDate;
                expiryDateToSend = datePicked != null
                    ? (datePicked!.toIso8601String().endsWith('Z')
                    ? datePicked!.toIso8601String()
                    : datePicked!.toIso8601String() + "Z")
                    : (widget.expiryDate?.endsWith('Z') == true
                    ? widget.expiryDate
                    : widget.expiryDate! + "Z");

                print("expiry ${widget.expiryDate}");
                print(expiryDateToSend);
              }

              // Determine the final document name and ID
              String finalDocName = nameDocController.text.isNotEmpty
                  ? nameDocController.text
                  : widget.docName;
              String finalDocId = idDocController.text.isNotEmpty
                  ? idDocController.text
                  : widget.idOfDoc;

              // Make the API call to update the document
              var response = await updateOtherDoc(
                context: context,
                orgOfficeDocumentId: widget.orgDocId,
                orgDocumentSetupid: widget.orgDocumentSetupid,
                docTypeID: widget.docTypeMetaIdCC,
                docSubTypeID: widget.selectedSubDocId,
                docName: finalDocName,
                expiryType: selectedExpiryType,
                threshold: threshold,
                expiryDate: expiryDateToSend,
                expiryReminder: selectedExpiryType,
                idOfDocument: finalDocId,
                docCreatedat: DateTime.now().toIso8601String() + "Z",
                url: widget.url,
                officeid: widget.officeId,
                fileName: fileIsPicked ? fileName : widget.fileName,
              );

              // Handle the response
              if (response.statusCode == 200 || response.statusCode == 201) {
                // Upload the document if a new file was picked
                if (fileIsPicked) {
                  var uploadDocNew =   await uploadDocumentsoffice(
                    context: context,
                    documentFile: filePath,
                    fileName: fileName,
                    orgOfficeDocumentId: response.orgOfficeDocumentId!,
                  );
                  if (uploadDocNew.statusCode == 413) {
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddErrorPopup(
                          message: 'File is too large!????',
                        );
                      },
                    );
                  }
                  else if (uploadDocNew.statusCode == 200 || uploadDocNew.statusCode == 201) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CountySuccessPopup(
                          message: 'Document updated and file uploaded successfully!',
                        );
                      },
                    );
                  } else {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FailedPopup(
                          text: 'Failed to upload file. File size exceeds limit.',
                        );
                      },
                    );
                  }

                }
                else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CountySuccessPopup(
                        message: 'Document updated successfully!',
                      );
                    },
                  );
                }
              } else {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FailedPopup(
                      text: response.message ?? 'Failed to update document. Please try again.',
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
                loading = false;
              });
            }
          }
      ),
      title: widget.title,
    );
  }
}
