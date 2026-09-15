import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/others_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/others_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/header_content_const.dart';

import 'package:symmetry_establishment/app/resources/font_manager.dart';

class OthersDocAddpopup extends StatefulWidget {
  final String title;
  bool? loadingDuration;
  final int employeeId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;
  OthersDocAddpopup(
      {super.key,
      required this.title,
      required this.employeeId,
      this.height,
      this.uploadField});

  @override
  State<OthersDocAddpopup> createState() => _OthersDocAddpopupState();
}

class _OthersDocAddpopupState extends State<OthersDocAddpopup> {
  bool _submitted = false;
  dynamic filePath;
  String fileName = '';
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController documentTypeName = TextEditingController();

  bool load = false;
  DateTime? datePicked;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    return DialogueTemplate(
      width: 900,
      height: widget.height == null ? AppSize.s410 : widget.height!,
      body: [
        FormDialogSection(
            title: 'Document Details',
            child: FormDialogGrid(columns: 3, children: [
              HeaderContentConst(
                isAsterisk: true,
                heading: 'Document Name',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 354,
                      height: 30,
                      child: TextFormField(
                        controller: documentTypeName,
                        cursorColor: ColorManager.black,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: FormDialogFields.decoration(
                            context,
                            InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              hintText: 'Enter document name',
                              hintStyle: DocumentTypeDataStyle.customTextStyle(
                                  context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    width: 1, color: ColorManager.fmediumgrey),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            )),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _submitted && documentTypeName.text.trim().isEmpty
                        ? Text(
                            'Please enter document name. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              ),
              HeaderContentConst(
                isAsterisk: true,
                heading: AppString.expiry_date,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 354,
                      height: 30,
                      child: TextFormField(
                        controller: expiryDateController,
                        cursorColor: ColorManager.black,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: FormDialogFields.decoration(
                            context,
                            InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              hintText: 'yyyy-mm-dd',
                              hintStyle: DocumentTypeDataStyle.customTextStyle(
                                  context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    width: 1, color: ColorManager.fmediumgrey),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              suffixIcon: Icon(Icons.calendar_month_outlined,
                                  color: ColorManager.blueprime),
                            )),
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
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 2),
                    _submitted && expiryDateController.text.isEmpty
                        ? Text(
                            'Please select date. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              ),
              HeaderContentConst(
                isAsterisk: true,
                heading: AppString.upload_document,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        height: AppSize.s30,
                        width: AppSize.s354,
                        padding: const EdgeInsets.only(left: AppPadding.p10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: FormDialogFields.borderColor, width: 1),
                          borderRadius:
                              BorderRadius.circular(FormDialogFields.radius),
                        ),
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fileName.isEmpty
                                          ? 'No file chosen'
                                          : fileName,
                                      style:
                                          DocumentTypeDataStyle.customTextStyle(
                                              context),
                                    ),
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    onPressed: _pickFile,
                                    icon: Icon(Icons.file_upload_outlined,
                                        color: ColorManager.black, size: 17),
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
                    ),
                    const SizedBox(height: 2),
                    _submitted && filePath == null
                        ? Text(
                            'Please upload document. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              )
            ]))
      ],
      bottomButtons: CustomElevatedButton(
        color: ColorManager.blueprime,
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.add,
        isLoading: load,
        onPressed: () async {
          setState(() {
            _submitted = true;
          });

          if (documentTypeName.text.trim().isEmpty ||
              expiryDateController.text.isEmpty ||
              filePath == null) {
            return;
          }

          setState(() {
            load = true;
          });
          try {
            var addedResponse = await addOthersDocumentData(
                context: context,
                fileName: '',
                url: '',
                employeeId: widget.employeeId,
                expDate: expiryDateController.text,
                ifOfDocument: documentTypeName.text,
                createdAt: DateTime.now().toString());
            // FIX: check the create call's own status before touching
            // otherDocId — on failure it's null, and dereferencing it with
            // `!` here would throw before the upload (or its error) ever ran.
            if (addedResponse.statusCode != 200 &&
                addedResponse.statusCode != 201) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddErrorPopup(
                      message: 'Failed to save document. ');
                },
              );
              return;
            }
            var response = await uploadOtherDoc(
              context: context,
              documentName: fileName,
              documentFile: filePath,
              otherDocId: addedResponse.otherDocId!,
            );
            if (response.statusCode == 200 || response.statusCode == 201) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddSuccessPopup(
                      message: 'Document Uploaded Successfully');
                },
              );
            } else {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddErrorPopup(
                    message: response.statusCode == 413
                        ? 'Request entity too large!'
                        : 'Failed to upload document. ',
                  );
                },
              );
            }
          } finally {
            // FIX: this used to set `load = true` here too, so the button's
            // spinner never turned back off after a submit attempt.
            if (mounted) {
              setState(() {
                load = false;
              });
            }
          }
        },
      ),
      title: widget.title,
    );
  }
}

class OthersEditPopup extends StatefulWidget {
  final int otherDocId;
  final String title;
  final String documentName;
  final String expDate;
  bool? loadingDuration;
  final int employeeId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;
  String? url;
  OthersEditPopup(
      {super.key,
      this.url,
      this.fileName,
      required this.title,
      required this.employeeId,
      this.height,
      this.uploadField,
      required this.otherDocId,
      required this.documentName,
      required this.expDate});

  @override
  State<OthersEditPopup> createState() => _OthersEditPopupState();
}

class _OthersEditPopupState extends State<OthersEditPopup> {
  bool _submitted = false;
  bool isFilePicked = false;
  dynamic filePath;
  String fileName = '';
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController documentTypeName = TextEditingController();

  bool load = false;
  DateTime? datePicked;

  @override
  void initState() {
    super.initState();
    expiryDateController = TextEditingController(text: widget.expDate);
    documentTypeName = TextEditingController(text: widget.documentName);
    fileName = widget.fileName ?? '';
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      isFilePicked = true;
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    return DialogueTemplate(
      width: 900,
      height: widget.height == null ? AppSize.s395 : widget.height!,
      body: [
        FormDialogSection(
            title: 'Document Details',
            child: FormDialogGrid(columns: 3, children: [
              HeaderContentConst(
                isAsterisk: true,
                heading: 'Document Name',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 354,
                      height: 30,
                      child: TextFormField(
                        controller: documentTypeName,
                        cursorColor: ColorManager.black,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: FormDialogFields.decoration(
                            context,
                            InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              hintText: 'Enter document name',
                              hintStyle: DocumentTypeDataStyle.customTextStyle(
                                  context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    width: 1, color: ColorManager.fmediumgrey),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            )),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _submitted && documentTypeName.text.trim().isEmpty
                        ? Text(
                            'Please enter document name. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              ),
              HeaderContentConst(
                isAsterisk: true,
                heading: AppString.expiry_date,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 354,
                      height: 30,
                      child: TextFormField(
                        controller: expiryDateController,
                        cursorColor: ColorManager.black,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                        decoration: FormDialogFields.decoration(
                            context,
                            InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.fmediumgrey, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              hintText: 'yyyy-mm-dd',
                              hintStyle: DocumentTypeDataStyle.customTextStyle(
                                  context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    width: 1, color: ColorManager.fmediumgrey),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              suffixIcon: Icon(Icons.calendar_month_outlined,
                                  color: ColorManager.blueprime),
                            )),
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
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 2),
                    _submitted && expiryDateController.text.isEmpty
                        ? Text(
                            'Please select date. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              ),
              HeaderContentConst(
                isAsterisk: true,
                heading: AppString.upload_document,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        height: AppSize.s30,
                        width: AppSize.s354,
                        padding: const EdgeInsets.only(left: AppPadding.p10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: FormDialogFields.borderColor, width: 1),
                          borderRadius:
                              BorderRadius.circular(FormDialogFields.radius),
                        ),
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fileName.isEmpty
                                          ? 'No file chosen'
                                          : fileName,
                                      style:
                                          DocumentTypeDataStyle.customTextStyle(
                                              context),
                                    ),
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    onPressed: _pickFile,
                                    icon: Icon(Icons.file_upload_outlined,
                                        color: ColorManager.black, size: 17),
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
                    ),
                    const SizedBox(height: 2),
                    _submitted && fileName.isEmpty
                        ? Text(
                            'Please upload document. ',
                            style: TextStyle(
                                fontSize: FontSize.s10,
                                color: ColorManager.red),
                          )
                        : const SizedBox(
                            height: 12,
                          ),
                  ],
                ),
              )
            ]))
      ],
      bottomButtons: CustomElevatedButton(
        color: ColorManager.blueprime,
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.submit,
        isLoading: load,
        onPressed: () async {
          setState(() {
            _submitted = true;
          });

          if (documentTypeName.text.trim().isEmpty ||
              expiryDateController.text.isEmpty) {
            return;
          }

          setState(() {
            load = true;
          });
          try {
            var editResponse = await patchOthersDocumentData(
                context: context,
                fileName: fileName,
                url: widget.url ?? '',
                employeeId: widget.employeeId,
                expDate: expiryDateController.text,
                ifOfDocument: documentTypeName.text,
                createdAt: DateTime.now().toString(),
                otherDocumentId: widget.otherDocId);
            if (editResponse.statusCode != 200 &&
                editResponse.statusCode != 201) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddErrorPopup(
                      message: 'Failed to save document. ');
                },
              );
              return;
            }
            if (isFilePicked) {
              await patchUploadOtherDoc(
                context: context,
                documentName: fileName,
                documentFile: filePath,
                otherDocId: widget.otherDocId,
              );
            }
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AddSuccessPopup(
                    message: 'Document Edited Successfully');
              },
            );
          } finally {
            // FIX: this used to set `load = true` here too, so the button's
            // spinner never turned back off after a submit attempt.
            if (mounted) {
              setState(() {
                load = false;
              });
            }
          }
        },
      ),
      title: widget.title,
    );
  }
}
