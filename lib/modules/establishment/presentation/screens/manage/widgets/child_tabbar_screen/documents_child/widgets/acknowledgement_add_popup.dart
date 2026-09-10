import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/employee_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_ack_health_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/employee_doc/employee_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/header_content_const.dart';

class WebFile {
  final html.File file;
  final String url;
  WebFile(this.file, this.url);

  void dispose() {
    print("File $file");
    html.Url.revokeObjectUrl(url);
  }
}

///

class AcknowledgementAddPopup extends StatelessWidget {
  final String title;
  bool? loadingDuration;

  final List<EmployeeDocSetupModal> dataList;

  final int employeeId;
  final double? height;
  final Widget? uploadField;
  dynamic filePath;
  String? fileName;

  AcknowledgementAddPopup({
    required this.title,
    this.loadingDuration,
    this.height,
    this.uploadField,
    required this.employeeId,
    required this.dataList,
  });

  // Below this width the dialog's fixed 354px-wide fields have no room to
  // sit comfortably — close the popup instead of letting it render broken.
  static const double _kDesignWidth = 855;

  // FIX: tracks whether showDatePicker's calendar dialog is currently open.
  // showDatePicker pushes its own route ON TOP of this popup's route.
  // Navigator.pop(context) always pops whatever is topmost in the stack —
  // so if the window is resized below _kDesignWidth while the calendar is
  // open, a single pop would only close the calendar and leave this popup
  // rendering broken underneath. Set true right before showDatePicker is
  // called and false right after it resolves (picked or cancelled), so the
  // resize handler below knows to pop the calendar first.
  bool _isDatePickerOpen = false;

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
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
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

    String documentTypeName = "";
    TextEditingController expiryDateController = TextEditingController();
    DateTime? datePicked;
    final ackProviderState = Provider.of<HrManageProvider>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ackProviderState.loadDropDown(dataList);
      ackProviderState.clearAddedValue();
    });
    return Consumer<HrManageProvider>(
        builder: (context, loaderProvider, child) {
      return DialogueTemplate(
        width: 900,
        height: height == null ? AppSize.s410 : height!,
        body: [
          FormDialogSection(
              title: 'Acknowledgement Details',
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
                            child: Text(
                              'No available document',
                              style: DocumentTypeDataStyle.customTextStyle(
                                  context),
                            ),
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
                              initialValue: "Select Document",
                              onChange: (val) {
                                for (var a in dataList!) {
                                  if (a.documentName == val) {
                                    documentMetaDataId =
                                        a.employeeDocMetaDataId;
                                    documentSetupId = a.employeeDocTypeSetupId;
                                    documentTypeName = a.documentName;
                                    if (a.reminderThreshould ==
                                        FrontendConfigStore
                                            .data?.config.issuer) {
                                      loaderProvider.showExpDateFieldAck();
                                      loaderProvider.listenData();
                                    } else {
                                      loaderProvider.showExpDateFieldAckFalse();
                                    }
                                  }
                                }
                              },
                              items: ackProviderState.dropDownMenuItems,
                            ),
                            const SizedBox(height: 2),
                            loaderProvider.isFormSubmitted &&
                                    documentTypeName == ""
                                ? Text(
                                    'Please select document. ',
                                    style: TextStyle(
                                        fontSize: 10, color: ColorManager.red),
                                  )
                                : const SizedBox(
                                    height: 12,
                                  ),
                          ],
                        ),
                ),
                Visibility(
                  visible: loaderProvider.showAddAckExpiryDateField,
                  child: HeaderContentConst(
                    isAsterisk: true,
                    heading: AppString.expiry_date,
                    // ─────────────────────────────────────────────────────
                    // FIX: Swapped the bare FormField/validator for the same
                    // explicit "isFormSubmitted && field-empty" pattern used
                    // by the document-type and upload-document errors below.
                    // A FormField's `validator` only runs when something
                    // calls `field.validate()` — normally triggered by a
                    // wrapping `Form`'s `validate()`/autovalidateMode. There
                    // is no `Form` here, so the validator was dead code and
                    // the expiry date error text never appeared, even when
                    // empty on submit.
                    // ─────────────────────────────────────────────────────
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
                                loaderProvider.listenData();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 1),
                        loaderProvider.isFormSubmitted &&
                                expiryDateController.text.isEmpty
                            ? Text(
                                'Please select expiry date. ',
                                style: TextStyle(
                                    fontSize: 10, color: ColorManager.red),
                              )
                            : const SizedBox(
                                height: 12,
                              ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: loaderProvider.showAddAckExpiryDateField,
                    child: const SizedBox(height: 12)),

                /// Upload document section...
                HeaderContentConst(
                  isAsterisk: true,
                  heading: AppString.upload_document,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: loaderProvider.pickAckFile,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        loaderProvider.fileName,
                                        style: DocumentTypeDataStyle
                                            .customTextStyle(context),
                                      ),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      onPressed: loaderProvider.pickAckFile,
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
                      const SizedBox(height: 2),
                      loaderProvider.isFormSubmitted &&
                              ackProviderState.filePath == null
                          ? Text(
                              'Please upload document. ',
                              style: TextStyle(
                                  fontSize: 10, color: ColorManager.red),
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
          isLoading: loaderProvider.load,
          onPressed: () async {
            loaderProvider.isFormSubmited();

            if (documentTypeName == "" ||
                ackProviderState.filePath == null ||
                expiryDateController.text.isEmpty &&
                    ackProviderState.showAddAckExpiryDateField) {
              return;
            }
            loaderProvider.loaderTrue();

            String? expiryDate;
            if (expiryDateController.text.isEmpty) {
              expiryDate = null;
            } else {
              expiryDate = datePicked!.toIso8601String() + "Z";
            }

            try {
              if (ackProviderState.fileAbove20Mb) {
                var response = await uploadDocuments(
                  context: context,
                  employeeDocumentMetaId: documentMetaDataId,
                  employeeDocumentTypeSetupId: documentSetupId,
                  employeeId: employeeId,
                  documentName: ackProviderState.fileName,
                  documentFile: ackProviderState.filePath,
                  expiryDate: expiryDate,
                );
                // FIX: the upload's own status must be checked BEFORE
                // touching response.documentId — on failure (network
                // error, 413, 500, ...) documentId is null, and the old
                // code dereferenced it unconditionally with `!`, which
                // threw and skipped straight past both the success AND
                // the "file too large" handling below. That silent
                // crash is why an add could fail with zero feedback and
                // the document would never show up in the list.
                if (response.statusCode == 200 || response.statusCode == 201) {
                  // Auto-approve is best-effort: the document is already
                  // uploaded and will show in the list (as pending
                  // review) even if this secondary call fails.
                  try {
                    await singleBatchApproveOnboardAckHealthPatch(
                        context, response.documentId!);
                  } catch (_) {}
                  ackProviderState.clearAddedValue();
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddSuccessPopup(
                        message: 'Document Uploaded Successfully.',
                      );
                    },
                  );
                } else {
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
            } finally {
              loaderProvider.loaderFalse();
            }
          },
        ),
        title: title,
      );
    });
  }
}
