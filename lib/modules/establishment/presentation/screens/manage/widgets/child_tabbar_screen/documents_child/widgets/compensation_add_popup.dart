import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/employee_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/clinical_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_ack_health_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/employee_doc/employee_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/clinical_license_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/header_content_const.dart';

// Shared design-width threshold for the popups in this file. Below this
// width, the fixed 354px-wide fields have no room to sit comfortably —
// close the popup instead of letting it render broken.
const double _kDocPopupDesignWidth = 855;

class CustomDocumedEditPopup extends StatelessWidget {
  final String labelName;
  final int employeeId;
  final int docMetaDataId;
  final int docSetupId;
  final int empDocumentId;
  final String selectedExpiryType;
  dynamic filePath;
  String? expiryDate;
  String? fileName;
  final String docName;
  final String url;
  final String documentFileName;

  CustomDocumedEditPopup({
    Key? key,
    required this.docName,
    this.expiryDate,
    required this.labelName,
    required this.employeeId,
    required this.docMetaDataId,
    required this.docSetupId,
    required this.empDocumentId,
    required this.selectedExpiryType,
    required this.url,
    required this.documentFileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // If the window/screen is resized below the popup's design width, close
    // the popup instead of letting it render broken. Scheduled as a
    // post-frame callback since we can't call Navigator.pop synchronously
    // inside build(). This is a StatelessWidget, so there's no State.mounted
    // to check — `context.mounted` covers that instead.
    // FIX: docEditProviderState is grabbed below (before the Consumer), so
    // it's available here too. pickDateValue() (called from this popup's
    // expiry-date field onTap) now exposes isDatePickerOpen, set true/false
    // around its own showDatePicker call — checking it here means we pop
    // the calendar first if it's open, instead of a single pop only closing
    // the calendar (topmost route) and leaving this popup broken underneath.
    final double screenWidth = MediaQuery.of(context).size.width;
    final docEditProviderState =
        Provider.of<HrManageProvider>(context, listen: false);
    if (screenWidth < _kDocPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !Navigator.canPop(context)) return;
        if (docEditProviderState.isDatePickerOpen) {
          Navigator.pop(context);
        }
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    int docTypeId = 0;
    int documentMetaDataId = 0;
    int documentSetupId = 0;
    String documentTypeName = "";
    String? selectedDocType;
    TextEditingController expiryDateController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      docEditProviderState.assignedValue(documentFileName);
      docEditProviderState.editDocumentValue(
          selectedExpiryType, expiryDate, expiryDateController);
    });

    return Consumer<HrManageProvider>(
        builder: (context, editDocProvider, child) {
      return DialogueTemplate(
        width: 900,
        height: AppSize.s395,
        body: [
          FormDialogSection(
              title: 'Document Details',
              child: FormDialogGrid(columns: 3, children: [
                HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.type_of_the_document,
                  content: Container(
                    width: 354,
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius:
                          BorderRadius.circular(FormDialogFields.radius),
                      border: Border.all(
                          color: FormDialogFields.borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          docName,
                          style: DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        const Icon(
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
                    onTap: editDocProvider.pickEditFile,
                    child: Container(
                      height: AppSize.s30,
                      width: AppSize.s354,
                      padding: const EdgeInsets.only(left: AppPadding.p10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: FormDialogFields.borderColor,
                          width: 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(FormDialogFields.radius),
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
                                    editDocProvider.editFileName,
                                    style:
                                        DocumentTypeDataStyle.customTextStyle(
                                            context),
                                  ),
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(4),
                                  onPressed: editDocProvider.pickEditFile,
                                  icon: Icon(
                                    Icons.file_upload_outlined,
                                    color: ColorManager.black,
                                    size: 17,
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
                  ),
                ),
                Visibility(
                  visible: editDocProvider.showExpiryDateField,

                  /// Conditionally display expiry date field
                  // ─────────────────────────────────────────────────────
                  // FIX: Same issue as AcknowledgementAddPopup — a bare
                  // FormField's `validator` never runs without a wrapping
                  // `Form` calling `.validate()`. Replaced with an explicit
                  // conditional error Text driven by `editDocProvider.isSubmitted`
                  // (mirrors the pattern used elsewhere in this file).
                  // ─────────────────────────────────────────────────────
                  child: HeaderContentConst(
                    isAsterisk: true,
                    heading: AppString.expiry_date,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 354,
                          height: 30,
                          child: TextFormField(
                            controller: editDocProvider.expiryDateController,
                            cursorColor: ColorManager.black,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                            decoration: FormDialogFields.decoration(
                                context,
                                InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.fmediumgrey,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.fmediumgrey,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  hintText: 'yyyy-mm-dd',
                                  hintStyle:
                                      DocumentTypeDataStyle.customTextStyle(
                                          context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: ColorManager.fmediumgrey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  suffixIcon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: ColorManager.blueprime),
                                )),
                            onTap: () async {
                              editDocProvider.pickDateValue(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 2),
                        editDocProvider.isSubmitted &&
                                editDocProvider
                                    .expiryDateController.text.isEmpty
                            ? Text(
                                'Please select date. ',
                                style: TextStyle(
                                    fontSize: FontSize.s10,
                                    color: ColorManager.red),
                              )
                            : const SizedBox(
                                height: 13,
                              ),
                      ],
                    ),
                  ),
                )
              ]))
        ],
        bottomButtons: CustomElevatedButton(
          color: ColorManager.blueprime,
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.submit,
          isLoading: editDocProvider.load,
          onPressed: () async {
            // Mark submitted so the expiry-date error can show if empty.
            editDocProvider.isSumitted();
            if (editDocProvider.showExpiryDateField &&
                editDocProvider.expiryDateController.text.isEmpty) {
              return;
            }
            editDocProvider.loaderTrue();
            String? validateExpDate = editDocProvider.expiryDateController.text;
            String? expiryDate;
            expiryDate = selectedExpiryType ==
                    FrontendConfigStore.data?.config.issuer
                ? (validateExpDate == editDocProvider.expiryDateController.text
                    ? editDocProvider.expiryDateController.text
                    : "${editDocProvider.datePicked.toIso8601String()}Z")
                : null;

            try {
              print('Expiry date ${expiryDate}');
              var updatedResponse = await patchEmployeeDocuments(
                context: context,
                empDocumentId: empDocumentId,
                employeeDocumentMetaId: docMetaDataId,
                employeeDocumentTypeSetupId: docSetupId,
                employeeId: employeeId,
                documentUrl: url,
                uploadDate: DateTime.now().toIso8601String() + "Z",
                expiryDate: expiryDate,
              );

              if (!context.mounted) return; // ← guard after every await

              if (updatedResponse.statusCode == 200 ||
                  updatedResponse.statusCode == 201) {
                if (editDocProvider.fileIsPicked) {
                  if (editDocProvider.editFileAbove20Mb) {
                    var response = await patchEmployeeBase64Documents(
                      context: context,
                      employeeDocumentId: empDocumentId,
                      expiryDate: expiryDate,
                      employeeDocumentMetaId: docMetaDataId,
                      employeeDocumentTypeSetupId: docSetupId,
                      employeeId: employeeId,
                      documentName: editDocProvider.editFileName,
                      documentFile: editDocProvider.editFilePath,
                    );

                    if (!context.mounted)
                      return; // ← guard again, this is the crash site

                    editDocProvider.clearAddedValue();
                    Navigator.pop(context);

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      showDialog(
                          context: context,
                          builder: (_) => const AddSuccessPopup(
                              message: 'Document Edited Successfully.'));
                    } else if (response.statusCode == 413) {
                      showDialog(
                          context: context,
                          builder: (_) => const AddErrorPopup(
                              message: 'File is too large. '));
                    } else {
                      print('Error');
                    }
                  } else {
                    editDocProvider.clearAddedValue();
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (_) => const AddErrorPopup(
                            message: 'File is too large. '));
                  }
                } else {
                  editDocProvider.clearAddedValue();
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (_) => const AddSuccessPopup(
                          message: 'Document Edited Successfully'));
                }
              }
            } finally {
              if (context.mounted) editDocProvider.loaderFalse();
            }
          },
        ),
        title: labelName,
      );
    });
  }
}

///////////////////////////////////////////////////

class CustomDocumedAddPopup extends StatelessWidget {
  final String title;
  bool? loadingDuration;

  final List<EmployeeDocSetupModal> dataList;

  final int employeeId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;

  // FIX: tracks whether showDatePicker's calendar dialog is currently open.
  // showDatePicker pushes its own route ON TOP of this popup's route.
  // Navigator.pop(context) always pops whatever is topmost in the stack —
  // so if the window is resized below _kDocPopupDesignWidth while the
  // calendar is open, a single pop would only close the calendar and leave
  // this popup rendering broken underneath. Set true right before
  // showDatePicker is called and false right after it resolves (picked or
  // cancelled), so the resize handler below knows to pop the calendar first.
  bool _isDatePickerOpen = false;

  CustomDocumedAddPopup({
    required this.title,
    this.loadingDuration,
    this.height,
    this.uploadField,
    required this.employeeId,
    required this.dataList,
  });

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // Same auto-close-on-narrow-screen fix as CustomDocumedEditPopup above.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDocPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !Navigator.canPop(context)) return;
        // FIX: close the calendar dialog first if it's open — otherwise
        // this pop closes the calendar (topmost route) instead of the
        // popup, leaving the broken-width popup still on screen.
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    int docTypeId = 0;
    int documentMetaDataId = 0;
    int documentSetupId = 0;
    bool _submitted = false;
    String documentTypeName = "";
    String? selectedDocType;
    TextEditingController expiryDateController = TextEditingController();

    DateTime? datePicked;
    final docAddProviderState = Provider.of<HrManageProvider>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      docAddProviderState.loadDropDown(dataList);
      docAddProviderState.clearAddedValue();
    });
    return Consumer<HrManageProvider>(
        builder: (context, addDocProvider, child) {
      return DialogueTemplate(
        width: 900,
        height: height == null ? AppSize.s410 : height!,
        body: [
          FormDialogSection(
              title: 'Document Details',
              child: FormDialogGrid(columns: 3, children: [
                HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.type_of_the_document,
                  content: dataList.isEmpty
                      ? Container(
                          width: 354,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: FormDialogFields.borderColor,
                                width: AppSize.s1),
                            borderRadius:
                                BorderRadius.circular(FormDialogFields.radius),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Text('No available document',
                                style: DocumentTypeDataStyle.customTextStyle(
                                    context)),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CICCDropdown(
                              width: 354,
                              // FIX: caps the dropdown menu's height so it scrolls
                              // instead of growing unbounded once there are more
                              // than ~4 items. Matches the same constraintHeight
                              // pattern already used on CICCDropdown elsewhere
                              // (e.g. the Licenses tab's document-type dropdown).
                              constraintHeight: 160,
                              initialValue: 'Select Document',
                              onChange: (val) {
                                for (var a in dataList) {
                                  if (a.documentName == val) {
                                    documentMetaDataId =
                                        a.employeeDocMetaDataId;
                                    documentSetupId = a.employeeDocTypeSetupId;
                                    documentTypeName = a.documentName;
                                    if (a.reminderThreshould ==
                                        FrontendConfigStore
                                            .data?.config.issuer) {
                                      addDocProvider.showExpDateFieldDoc();
                                    } else {
                                      addDocProvider.showExpDateFieldDocFalse();
                                    }
                                  }
                                }
                              },
                              items: addDocProvider.dropDownMenuItems,
                            ),
                            const SizedBox(height: 2),
                            addDocProvider.isFormSubmitted &&
                                    documentTypeName.isEmpty
                                ? // Check _submitted before showing the error
                                Text(
                                    'Please select document. ',
                                    style:
                                        CommonErrorMsg.customTextStyle(context),
                                  )
                                : const SizedBox(height: 12),
                          ],
                        ),
                ),
                Visibility(
                  visible: addDocProvider.showAddDocExpiryDateField,
                  // ─────────────────────────────────────────────────────
                  // FIX: Same bare-FormField-validator issue — replaced
                  // with an explicit conditional error Text driven by
                  // `addDocProvider.isFormSubmitted`.
                  // ─────────────────────────────────────────────────────
                  child: HeaderContentConst(
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
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                            decoration: FormDialogFields.decoration(
                                context,
                                InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.fmediumgrey,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorManager.fmediumgrey,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  hintText: 'yyyy-mm-dd',
                                  hintStyle:
                                      DocumentTypeDataStyle.customTextStyle(
                                          context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: ColorManager.fmediumgrey),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  suffixIcon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: ColorManager.blueprime),
                                )),
                            onTap: () async {
                              final now = DateTime.now();
                              final today =
                                  DateTime(now.year, now.month, now.day);
                              // FIX: mark the calendar as open so the
                              // resize-close handler above knows to pop it
                              // first if the window shrinks while it's showing.
                              _isDatePickerOpen = true;
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: today,
                                firstDate: today,
                                lastDate: DateTime(3101),
                              );
                              _isDatePickerOpen = false;
                              if (pickedDate != null) {
                                datePicked = pickedDate;
                                expiryDateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                addDocProvider.listenData();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 2),
                        addDocProvider.isFormSubmitted &&
                                expiryDateController.text.isEmpty
                            ? Text(
                                'Please select date. ',
                                style: TextStyle(
                                    fontSize: FontSize.s10,
                                    color: ColorManager.red),
                              )
                            : const SizedBox(
                                height: 13,
                              ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: addDocProvider.showAddDocExpiryDateField,
                    child: const SizedBox(
                      height: 12,
                    )),
                HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.upload_document,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: addDocProvider.pickAckFile,
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
                                      child: Text(addDocProvider.fileName,
                                          style: DocumentTypeDataStyle
                                              .customTextStyle(context)),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      onPressed: addDocProvider.pickAckFile,
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
                      addDocProvider.isFormSubmitted &&
                              addDocProvider.filePath == null
                          ? // Show error only if filePath is null and form is submitted
                          Text(
                              'Please upload document. ',
                              style: TextStyle(
                                  fontSize: FontSize.s10,
                                  color: ColorManager.red),
                            )
                          : const SizedBox(
                              height: 12,
                            )
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
          isLoading: addDocProvider.load,
          onPressed: () async {
            addDocProvider.isFormSubmited();
            if (addDocProvider.filePath != null &&
                documentTypeName.isNotEmpty) {
              addDocProvider.loaderTrue();
              try {
                String? expiryDate;
                if (expiryDateController.text.isEmpty) {
                  expiryDate = null;
                } else {
                  expiryDate = datePicked!.toIso8601String() + "Z";
                }
                if (addDocProvider.fileAbove20Mb) {
                  var response = await uploadDocuments(
                    context: context,
                    employeeDocumentMetaId: documentMetaDataId,
                    employeeDocumentTypeSetupId: documentSetupId,
                    employeeId: employeeId,
                    documentName: addDocProvider.fileName,
                    documentFile: addDocProvider.filePath,
                    expiryDate: expiryDate,
                  );
                  // FIX: check the upload's own status BEFORE touching
                  // response.documentId — on failure (network error,
                  // 413, 500, ...) documentId is null, and the old code
                  // dereferenced it unconditionally with `!`, throwing
                  // and skipping past both the success AND the
                  // "file too large" handling below. That silent crash
                  // is why an add could fail with no feedback and the
                  // document would never show up in the list.
                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    // Auto-approve is best-effort: the document is
                    // already uploaded and will show in the list (as
                    // pending review) even if this secondary call fails.
                    try {
                      await singleBatchApproveOnboardAckHealthPatch(
                          context, response.documentId!);
                    } catch (_) {}
                    addDocProvider.clearAddedValue();
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddSuccessPopup(
                            message: 'Document Uploaded Successfully.');
                      },
                    );
                  } else {
                    addDocProvider.clearAddedValue();
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddErrorPopup(
                          message: response.statusCode == 413
                              ? 'File is too large. '
                              : 'Failed to upload document. ',
                        );
                      },
                    );
                  }
                } else {
                  addDocProvider.clearAddedValue();
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddErrorPopup(
                        message: 'File is too large. ',
                      );
                    },
                  );
                }

                addDocProvider.loaderFalse();
              } finally {
                addDocProvider.loaderFalse();
              }
            } else {
              print('Validation error');
            }
          },
        ),
        title: title,
      );
    });
  }
}

/// Clinical licenses popup
class ClinicalLicensesAddPopup extends StatelessWidget {
  final String title;
  bool? loadingDuration;
  final String licenseName;
  ClinicalLicensePrefillDataModel? drivingList;
  PractitionerLicensePreFillDataModel? practionerData;
  final String docId;
  final int employeeId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;

  // FIX: same calendar-open tracking as CustomDocumedAddPopup above — see
  // that class's comment for why this is needed before popping on resize.
  bool _isDatePickerOpen = false;

  ClinicalLicensesAddPopup({
    super.key,
    this.practionerData,
    required this.title,
    required this.employeeId,
    this.height,
    this.uploadField,
    this.drivingList,
    required this.docId,
    required this.licenseName,
  });
  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // Same auto-close-on-narrow-screen fix as the popups above.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDocPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !Navigator.canPop(context)) return;
        // FIX: close the calendar dialog first if it's open — otherwise
        // this pop closes the calendar (topmost route) instead of the
        // popup, leaving the broken-width popup still on screen.
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    TextEditingController expiryDateController = TextEditingController();
    DateTime? datePicked;
    final clinicalDocAddProviderState = Provider.of<HrManageProvider>(
      context,
      listen: false,
    );
    licenseName == "Driving License"
        ? expiryDateController =
            TextEditingController(text: drivingList!.expDate)
        : expiryDateController =
            TextEditingController(text: practionerData!.expDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      licenseName == "Driving License"
          ? clinicalDocAddProviderState.getFileName(drivingList!.fileName)
          : clinicalDocAddProviderState.getFileName(practionerData!.fileName);
    });
    return Consumer<HrManageProvider>(builder: (context, providerState, child) {
      return DialogueTemplate(
        width: 900,
        height: height == null ? AppSize.s374 : height!,
        body: [
          FormDialogSection(
              title: 'Document Details',
              child: FormDialogGrid(columns: 3, children: [
                HeaderContentConst(
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
                                      color: ColorManager.fmediumgrey,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorManager.fmediumgrey,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                hintText: 'yyyy-mm-dd',
                                hintStyle:
                                    DocumentTypeDataStyle.customTextStyle(
                                        context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: ColorManager.fmediumgrey),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                suffixIcon: Icon(Icons.calendar_month_outlined,
                                    color: ColorManager.blueprime),
                              )),
                          onTap: () async {
                            // FIX: mark the calendar as open so the
                            // resize-close handler above knows to pop it
                            // first if the window shrinks while it's showing.
                            _isDatePickerOpen = true;
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1901),
                              lastDate: DateTime(3101),
                            );
                            _isDatePickerOpen = false;
                            if (pickedDate != null) {
                              datePicked = pickedDate;
                              expiryDateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              providerState.listenData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 2),
                      providerState.isSubmitted &&
                              expiryDateController.text.isEmpty
                          ? Text(
                              'Please select date. ',
                              style: TextStyle(
                                  fontSize: FontSize.s10,
                                  color: ColorManager.red),
                            )
                          : const SizedBox(
                              height: 13,
                            ),
                    ],
                  ),
                ),
                HeaderContentConst(
                  heading: AppString.upload_document,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: providerState.pickClinicalEditFile,
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s354,
                          padding: const EdgeInsets.only(left: AppPadding.p15),
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
                                          providerState
                                              .editClinicalLicenseFileName,
                                          style: DocumentTypeDataStyle
                                              .customTextStyle(context)),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      onPressed:
                                          providerState.pickClinicalEditFile,
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
                      // ─────────────────────────────────────────────────────
                      // FIX: Uncommented and wired up the upload-document
                      // validation. It shows once Submit is tapped
                      // (providerState.isSubmitted) AND there's no file name
                      // to show — covers both "never picked a file" and,
                      // since this popup can prefill from an existing
                      // license, "prefilled name got cleared somehow."
                      // Uses `editClinicalLicenseFileName` (what's actually
                      // displayed) rather than `editClinicalLicenseFilePath`,
                      // because on open the field is prefilled via
                      // `getFileName()` with only a name, no path/bytes yet.
                      // ─────────────────────────────────────────────────────
                      providerState.isSubmitted &&
                              providerState.editClinicalLicenseFileName.isEmpty
                          ? Text(
                              'Please upload document. ',
                              style: TextStyle(
                                  fontSize: FontSize.s10,
                                  color: ColorManager.red),
                            )
                          : const SizedBox(
                              height: 13,
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
          isLoading: providerState.load,
          onPressed: () async {
            providerState.isSumitted();

            // ─────────────────────────────────────────────────────
            // FIX: Block submission when required fields are empty,
            // instead of only marking `isSubmitted` and letting the
            // request go through regardless. Mirrors the pattern used
            // in the other add/edit popups in this file.
            // ─────────────────────────────────────────────────────
            if (expiryDateController.text.isEmpty ||
                providerState.editClinicalLicenseFileName.isEmpty) {
              return;
            }

            providerState.loaderTrue();
            try {
              String? expiryDate;
              var response = licenseName == 'Driving License'
                  ? await patchDrivingLicense(
                      context: context,
                      docId: docId,
                      employeeId: drivingList!.employeeId,
                      idOfDocument: drivingList!.idOFDocument,
                      expiryDate: expiryDateController.text,
                      createdAt: drivingList!.createdAt,
                      url: drivingList!.url,
                      officeId: drivingList!.officeId,
                      fileName: providerState.editClinicalLicenseFileName,
                      approved: drivingList!.approve!)
                  : await patchPractitionerLicense(
                      context: context,
                      docId: docId,
                      employeeId: practionerData!.employeeId,
                      idOfDocument: practionerData!.idOFDocument,
                      expiryDate: expiryDateController.text,
                      createdAt: practionerData!.createdAt,
                      url: practionerData!.url,
                      officeId: practionerData!.officeId,
                      fileName: providerState.editClinicalLicenseFileName,
                      approved: practionerData!.approve!);
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddSuccessPopup(
                        message: 'License Uploaded Successfully');
                  },
                );
                if (providerState.clinicalFileIsPicked) {
                  if (providerState.editFileAbove20Mb) {
                    var docResponse = licenseName == 'Driving License'
                        ? await patchDocumentsDL(
                            context: context,
                            drivingLicenceId: int.parse(docId),
                            documentFile:
                                providerState.editClinicalLicenseFilePath,
                            documentName:
                                providerState.editClinicalLicenseFileName)
                        : await patchDocumentsPL(
                            context: context,
                            practitionerLicenceId: int.parse(docId),
                            documentFile:
                                providerState.editClinicalLicenseFilePath,
                            documentName:
                                providerState.editClinicalLicenseFileName);
                    if (docResponse.statusCode == 200 ||
                        docResponse.statusCode == 201) {
                      providerState.clearAddedValue();
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(
                            message: 'Document Edited Successfully',
                          );
                        },
                      );
                    } else if (response.statusCode == 413) {
                      providerState.clearAddedValue();
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddErrorPopup(
                            message: 'File is too large. ',
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context);
                      print('Error');
                    }
                  } else {
                    providerState.clearAddedValue();
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddErrorPopup(
                          message: 'File is too large. ',
                        );
                      },
                    );
                  }
                }
              }

              providerState.loaderFalse();
            } finally {
              providerState.clearAddedValue();
              providerState.loaderFalse();
            }
          },
        ),
        title: title,
      );
    });
  }
}
