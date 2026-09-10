import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/qulification_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';

// Below this width, each field (sized at screenWidth / 6) drops under a
// usable ~160px and the 3-column rows have no room left — close the popup
// instead of letting it render broken.
const double _kLicencesPopupDesignWidth = 855;

class AddLicencesPopup extends StatefulWidget {
  final String title;
  final int employeeId;
  final VoidCallback onpressedClose;

  const AddLicencesPopup({
    super.key,
    required this.onpressedClose,
    required this.title,
    required this.employeeId,
  });

  @override
  State<AddLicencesPopup> createState() => _AddLicencesPopupState();
}

class _AddLicencesPopupState extends State<AddLicencesPopup> {
  final DateTime _selectedIssueDate = DateTime.now();
  final DateTime _selectedExpDate = DateTime.now();
  // These were already self-owned (created directly here rather than
  // passed in via `widget.xController`), so they were never at risk of
  // the "used after disposed" crash. They just weren't being disposed —
  // added dispose() below to fix that leak.
  TextEditingController livensureController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController issuingOrganizationController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController numberIDController = TextEditingController();
  dynamic pickedFile;
  String pickedFileName = '';
  bool isLoading = false;
  bool isFilePicked = false;
  String docName = 'Select';
  String docNameadd = 'Select';

  // FIX: tracks whether showDatePicker (opened from _buildDateField, used
  // for both Issue Date and Expiry Date) is currently open. showDatePicker
  // pushes its own route ON TOP of this popup's route, and
  // Navigator.pop(context) always pops whatever is topmost — so if the
  // window is resized below _kLicencesPopupDesignWidth while a calendar is
  // open, a single pop would only close the calendar and leave this popup
  // rendering broken underneath. Set true right before showDatePicker is
  // called and false right after it resolves (picked or cancelled), so the
  // resize handler in build() knows to pop the calendar first.
  bool _isDatePickerOpen = false;

  // Error states for validations
  Map<String, bool> errorStates = {
    'Livensure': false,
    'issueDate': false,
    'expiryDate': false,
    'issuingOrganization': false,
    'country': false,
    'numberID': false,
    'document': false,
    'pickFile': false,
  };
  bool fileAbove20Mb = false;

  // ---------------------------------------------------------------------
  // NEW: server-driven error messages, keyed the same as `errorStates`.
  // When set, these override the generic "Please enter X" text under a
  // field so the user sees the server's actual validation message.
  //
  // General (non-field-specific) failures also route through this same
  // map — reusing the 'document' slot — instead of a separate variable,
  // so there's only one mechanism for showing server error text inline.
  // ---------------------------------------------------------------------
  Map<String, String?> _serverErrorMessages = {
    'Livensure': null,
    'issueDate': null,
    'expiryDate': null,
    'issuingOrganization': null,
    'country': null,
    'numberID': null,
    'document': null,
  };

  // ---------------------------------------------------------------------
  // NEW: tracks the last value seen per field. Some custom text-field
  // widgets (CustomTextFieldRegister here) call `onChanged` again during
  // a rebuild even when the user didn't type anything — e.g. if they wire
  // it to controller.addListener internally rather than only to genuine
  // keystrokes. Without this guard, that spurious re-fire runs
  // `errorStates[errorKey] = value.isEmpty` with the CURRENT (non-empty)
  // text right after a server error sets errorStates[errorKey] = true,
  // flipping it back to false and hiding the error the instant it
  // appears — which is exactly the symptom of a matched field-error case
  // never actually showing on screen.
  // ---------------------------------------------------------------------
  Map<String, String?> _lastKnownFieldValue = {};

  /// Maps the server's [ErrorDetail.key] values (matching the POST body
  /// field names sent to addLicensePost) onto this popup's fields, marking
  /// each as errored and storing the server's own message for display.
  ///
  /// Returns true if at least one error was actually matched to a field.
  /// This matters because if the server sends error keys that don't match
  /// any case below, this would otherwise silently do nothing — no field
  /// highlight AND no generic popup, since the caller only fell back to a
  /// popup when `fieldErrors` was empty, not when it was non-empty but
  /// unrecognized. That's the bug behind field errors sometimes not
  /// showing up anywhere at all.
  bool _applyServerFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return false;
    bool appliedAny = false;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'licensure':
            errorStates['Livensure'] = true;
            _serverErrorMessages['Livensure'] = e.message;
            appliedAny = true;
            break;
          case 'issueDate':
            errorStates['issueDate'] = true;
            _serverErrorMessages['issueDate'] = e.message;
            appliedAny = true;
            break;
          case 'expDate':
            errorStates['expiryDate'] = true;
            _serverErrorMessages['expiryDate'] = e.message;
            appliedAny = true;
            break;
          case 'org':
            errorStates['issuingOrganization'] = true;
            _serverErrorMessages['issuingOrganization'] = e.message;
            appliedAny = true;
            break;
          case 'country':
            errorStates['country'] = true;
            _serverErrorMessages['country'] = e.message;
            appliedAny = true;
            break;
          case 'licenseNumber':
            errorStates['numberID'] = true;
            _serverErrorMessages['numberID'] = e.message;
            appliedAny = true;
            break;
          case 'documentType':
            errorStates['document'] = true;
            _serverErrorMessages['document'] = e.message;
            appliedAny = true;
            break;
          default:
            // NEW: prints the real key name so the mapping above can be
            // corrected if it doesn't match what the server actually
            // sends.
            debugPrint('[AddLicencesPopup] Unmapped field error key: '
                '"${e.key}" -> ${e.message}');
            break;
        }
      }
    });
    return appliedAny;
  }

  /// Clears server-driven messages before a fresh submit so a stale
  /// message from a previous attempt doesn't linger under a field the
  /// user has since fixed. Local validation (`errorStates`) is left
  /// alone here since `_validateFields()` recomputes it right after.
  void _clearServerFieldErrors() {
    if (!mounted) return;
    setState(() {
      _serverErrorMessages.updateAll((key, value) => null);
    });
  }

  /// Shows a general (non-field-specific) server error using the same
  /// `_serverErrorMessages` map the individual fields already use —
  /// reusing the 'numberID' slot (Number/ID) instead of introducing a
  /// separate error variable/widget.
  ///
  /// CHANGED: this used to reuse the 'document' slot, but that meant any
  /// interaction with the Select Document dropdown (its onChange clears
  /// errorStates['document']/_serverErrorMessages['document']) would wipe
  /// out a general error that had nothing to do with the document field —
  /// making it look like the message "automatically changed" when the
  /// user picked a different document type. 'numberID' isn't touched by
  /// any other field's onChange, so it holds the message reliably.
  void _showGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      errorStates['numberID'] = true;
      _serverErrorMessages['numberID'] = message;
    });
  }

  final FocusNode _licensureFocus = FocusNode();
  final FocusNode _issuingOrgFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _numberIDFocus = FocusNode();
  final FocusNode _documentDropdownFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode nextFocus) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      nextFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<NewOrgDocument>> _orgDocFuture;

  @override
  void initState() {
    super.initState();
    // FrontendConfigStore.data is populated asynchronously at startup and is
    // still null if this popup is opened before that lands — the `!` threw
    // "Unexpected null value" out of initState. Read it defensively and fall
    // back to an empty document list, same as licenses_child_tabbar.
    final cfg = FrontendConfigStore.data?.config;
    _orgDocFuture = cfg == null
        ? Future<List<NewOrgDocument>>.value(const <NewOrgDocument>[])
        : getNewOrgDocfetch(
            context, cfg.corporateAndCompliance, cfg.subDocId1Licenses, 1, 200);
    _licensureFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _issuingOrgFocus);
    _issuingOrgFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _countryFocus);
    _countryFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _numberIDFocus);
    _numberIDFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _documentDropdownFocus);
    _documentDropdownFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        FocusScope.of(context).unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    livensureController.dispose();
    issueDateController.dispose();
    expiryDateController.dispose();
    issuingOrganizationController.dispose();
    countryController.dispose();
    numberIDController.dispose();
    _licensureFocus.dispose();
    _issuingOrgFocus.dispose();
    _countryFocus.dispose();
    _numberIDFocus.dispose();
    _documentDropdownFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // If the window/screen is resized below the popup's usable width, the
    // layout has no room to work with — close the popup instead of letting
    // it render broken. Scheduled as a post-frame callback since we can't
    // call Navigator.pop synchronously inside build().
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kLicencesPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !Navigator.canPop(context)) return;
        // FIX: close the calendar dialog first if it's open (either Issue
        // Date or Expiry Date — both go through the same
        // _isDatePickerOpen flag) — otherwise this pop closes the
        // calendar (topmost route) instead of the popup, leaving the
        // broken-width popup still on screen.
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FormDialogSurface(
          width: 900,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FormDialogHeader(
              title: widget.title,
              onClose: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Document Details',
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Select Document', // Main text
                                    style: FormDialogFields
                                        .labelStyle, // Main style
                                    children: [
                                      TextSpan(
                                        text: ' *', // Asterisk
                                        style: FormDialogFields.labelStyle
                                            .copyWith(
                                          color: ColorManager
                                              .red, // Asterisk color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                FutureBuilder<List<NewOrgDocument>>(
                                  future: _orgDocFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        height: AppSize.s30,
                                        width: 240,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ColorManager
                                                  .containerBorderGrey,
                                              width: AppSize.s1),
                                          borderRadius: BorderRadius.circular(
                                              FormDialogFields.radius),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: AppSize.s10),
                                            Expanded(
                                              child: Text(
                                                docNameadd ?? '',
                                                style: DocumentTypeDataStyle
                                                    .customTextStyle(context),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  right: AppPadding.p8),
                                              child:
                                                  Icon(Icons.arrow_drop_down),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (snapshot.hasData &&
                                        snapshot.data!.isEmpty) {
                                      return Container(
                                        width: 240,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Text("No licenses available",
                                              style: DocumentTypeDataStyle
                                                  .customTextStyle(context)),
                                        ),
                                      );
                                    }

                                    if (snapshot.hasData) {
                                      List<DropdownMenuItem<String>>
                                          dropDownMenuItems = snapshot.data!
                                              .map((doc) =>
                                                  DropdownMenuItem<String>(
                                                    value: doc.docName,
                                                    child: Text(doc.docName),
                                                  ))
                                              .toList();

                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            void Function(void Function())
                                                setState) {
                                          return CICCDropdown(
                                            width: 240,
                                            focusNode: _documentDropdownFocus,
                                            initialValue: docNameadd ??
                                                snapshot.data!.first
                                                    .docName, // Set default value
                                            onChange: (val) {
                                              setState(() {
                                                docNameadd = val;
                                              });

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                this.setState(() {
                                                  errorStates["document"] =
                                                      false;
                                                  _serverErrorMessages[
                                                      "document"] = null;
                                                });
                                              });
                                            },
                                            items: dropDownMenuItems,
                                          );
                                        },
                                      );
                                    }

                                    return const SizedBox();
                                  },
                                ),
                                if (errorStates["document"]!)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      _serverErrorMessages["document"] ??
                                          'Please select document. ',
                                      style: CommonErrorMsg.customTextStyle(
                                          context),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 13),
                              ],
                            );
                          },
                        ),

                        ///upload
                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: Row(
                                children: [
                                  pickedFileName == ''
                                      ? const Offstage()
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30, bottom: 10),
                                            child: Text(
                                              pickedFileName,
                                              style: DocumentTypeDataStyle
                                                  .customTextStyle(context),
                                            ),
                                          ),
                                        ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: AppSize.s170,
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                                        type: FileType.custom,
                                                        allowedExtensions: [
                                                  'pdf'
                                                ]);
                                            final fileSize = result?.files.first
                                                .size; // File size in bytes
                                            final isAbove20MB =
                                                fileSize! > (20 * 1024 * 1024);
                                            if (result != null) {
                                              final file = result.files.first;
                                              setState(() {
                                                pickedFileName = file.name;
                                                pickedFile = file.bytes;
                                                fileAbove20Mb = !isAbove20MB;
                                                errorStates["pickFile"] = false;
                                              });
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.file_upload_outlined,
                                              color: Colors.white),
                                          label: Text(
                                            '  Upload License',
                                            style: BlueButtonTextConst
                                                .customTextStyle(context),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ColorManager.blueprime,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // CustomIconButton(
                                      //     icon: Icons.file_upload_outlined,
                                      //     text: ' Upload License',
                                      //     onPressed: () async {
                                      //       FilePickerResult? result = await FilePicker.platform.pickFiles(
                                      //           type: FileType.custom,
                                      //           allowedExtensions: ['pdf']
                                      //       );
                                      //       final fileSize = result?.files.first.size; // File size in bytes
                                      //       final isAbove20MB = fileSize! > (20 * 1024 * 1024);
                                      //       if (result != null) {
                                      //         final file = result.files.first;
                                      //         setState(() {
                                      //           pickedFileName = file.name;
                                      //           pickedFile = file.bytes;
                                      //           fileAbove20Mb = !isAbove20MB;
                                      //           errorStates ["pickFile"]= false;
                                      //         });
                                      //       }
                                      //     }, isNotPopUpButton: true,
                                      //
                                      //
                                      // ),
                                      errorStates["pickFile"]!
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                'Please upload license. ',
                                                style: TextStyle(
                                                  color: ColorManager.red,
                                                  fontSize: FontSize.s10,
                                                ),
                                              ),
                                            )
                                          : const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 4.0),
                                              child: SizedBox(height: 13),
                                            )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )),
              FormDialogSection(
                  title: 'License Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: livensureController,
                      labelText: "Licensure / Certification",
                      errorKey: 'Livensure',
                      hintText: 'Enter certification',
                      focusNode: _licensureFocus,
                    ),
                    _buildDateField(
                      controller: issueDateController,
                      labelText: "Issue Date",
                      errorKey: 'issueDate',
                      issueDate: true,
                      initialDate: _selectedIssueDate,
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildDateField(
                      controller: expiryDateController,
                      labelText: "Expiry Date",
                      errorKey: 'expiryDate',
                      issueDate: false,
                      initialDate: _selectedExpDate,
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: issuingOrganizationController,
                      labelText: "Issuing Organization",
                      errorKey: 'issuingOrganization',
                      hintText: 'Enter Issuing Organization',
                      focusNode: _issuingOrgFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: countryController,
                      labelText: "Country",
                      errorKey: 'country',
                      hintText: 'Enter Country',
                      focusNode: _countryFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: numberIDController,
                      labelText: "Number/ID",
                      errorKey: 'numberID',
                      hintText: 'Enter Number',
                      focusNode: _numberIDFocus,
                    )
                  ]))
            ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonTransparent(
                        text: AppString.cancel,
                        onPressed: () async {
                          Navigator.pop(context);
                          _clearControllers();
                        }),
                    const SizedBox(
                      width: AppSize.s10,
                    ),
                    CustomElevatedButton(
                      color: ColorManager.blueprime,
                      width: AppSize.s100,
                      text: AppString.save,
                      isLoading: isLoading,
                      onPressed: () async {
                        // NEW: clear any previously shown server field errors
                        // before a fresh validation/submit pass.
                        _clearServerFieldErrors();

                        // Validate form fields
                        _validateFields();

                        // Validate file size first
                        if (pickedFile != null) {
                          // Check if the file is too large
                          if (!fileAbove20Mb) {
                            // 20MB in bytes
                            setState(() {
                              isLoading = false;
                            });

                            // Show validation message if the file is too large
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddErrorPopup(
                                  message: 'File is too large. ',
                                );
                              },
                            );
                            return; // Stop further execution if the file is too large
                          }
                        }

                        // Proceed if no validation errors
                        if (!_hasErrors()) {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            // Make the API call to add the license
                            var response = await addLicensePost(
                              context,
                              countryController.text,
                              widget.employeeId,
                              expiryDateController.text,
                              issueDateController.text,
                              'url',
                              livensureController.text,
                              numberIDController.text,
                              issuingOrganizationController.text,
                              docNameadd.toString(),
                            );

                            // NEW: stop here on a validation failure — apply the
                            // server's field errors to this popup's own fields
                            // and leave the popup open (and the user's typed
                            // values intact) so they can fix and resubmit.
                            // Previously this fell through to Navigator.pop +
                            // _clearControllers() regardless of outcome, which
                            // closed the popup and wiped the user's input the
                            // moment a validation error came back.
                            if (response.statusCode == 400 ||
                                response.statusCode == 404) {
                              bool appliedFieldErrors = false;
                              if (response.fieldErrors != null &&
                                  response.fieldErrors!.isNotEmpty) {
                                appliedFieldErrors = _applyServerFieldErrors(
                                    response.fieldErrors!);
                              }
                              // CHANGED: was showDialog(FailedPopup(...)). Now
                              // shown as inline validation text near the Save
                              // button instead of a popup — same as
                              // previously, this fires when fieldErrors was
                              // empty, or non-empty but none of its keys
                              // matched a known field.
                              if (!appliedFieldErrors) {
                                _showGeneralError(response.message);
                              }
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            if (response.statusCode != 200 &&
                                response.statusCode != 201) {
                              // Non-validation failure (network/server error) —
                              // CHANGED: shown inline instead of a popup, and
                              // still keeps the popup open rather than closing
                              // it out from under the user's typed data.
                              _showGeneralError(response.message);
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            // Make the API call to approve the license
                            var licenseResponse =
                                await approveOnboardQualifyLicensePatch(
                              context,
                              response.licenseId!,
                            );

                            // Handle successful license approval
                            if (licenseResponse.statusCode == 200 ||
                                licenseResponse.statusCode == 201) {
                              // If a file is picked, upload it
                              await attachLicenseDocument(
                                context,
                                response.licenseId!,
                                pickedFile,
                                pickedFileName!,
                              );
                              if (licenseResponse.statusCode == 200 ||
                                  licenseResponse.statusCode == 201) {
                                // If document upload is successful, navigate back
                                Navigator.pop(context);

                                // Show success dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AddSuccessPopup(
                                      message: 'Licenses Added Successfully.',
                                    );
                                  },
                                );
                                // Only clear controllers after a genuine
                                // success — clearing them on failure wiped the
                                // user's input right as they needed to fix it.
                                _clearControllers();
                              }
                            } else {
                              // approveOnboardQualifyLicensePatch failed after a
                              // successful license save — CHANGED: shown inline
                              // instead of the FourNotFourPopup, and the popup
                              // stays open rather than silently closing.
                              _showGeneralError(licenseResponse.message);
                            }
                          } finally {
                            // Ensure the loading state is turned off after the process
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                    ),
                  ],
                )),
          ])),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String errorKey,
    required bool capitalIsSelect,
    FocusNode? focusNode,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return FormDialogField(
            label: labelText,
            isRequired: true,
            child: CustomTextFieldRegister(
              isDigitSelect: capitalIsSelect,
              height: AppSize.s30,
              width: 240,
              controller: controller,
              hintText: hintText,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              padding: const EdgeInsets.only(
                  bottom: AppPadding.p5, left: AppPadding.p20),
              onChanged: (value) {
                // NEW: skip if this isn't a genuine change — some custom
                // text field widgets re-fire onChanged with the current
                // text on rebuild, which would otherwise silently clear a
                // just-applied server error before the user ever sees it.
                if (this._lastKnownFieldValue[errorKey] == value) return;
                this._lastKnownFieldValue[errorKey] = value;

                setState(() {
                  errorStates[errorKey] = value.isEmpty;
                  // NEW: clear the server message once the user edits the
                  // field again — the stale server text shouldn't linger
                  // once local validation state moves on.
                  this.setState(() {
                    _serverErrorMessages[errorKey] = null;
                  });
                });
              },
            ),
            validation: errorStates[errorKey]!
                ? Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      _serverErrorMessages[errorKey] ??
                          'Please enter ${labelText.toLowerCase()}. ',
                      style: TextStyle(
                        color: ColorManager.red,
                        fontSize: FontSize.s10,
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 12,
                  ));
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String errorKey,
    required bool issueDate,
    required DateTime initialDate,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return FormDialogField(
            label: labelText,
            isRequired: true,
            child: CustomTextFieldRegister(
              height: AppSize.s30,
              width: 240,
              controller: controller,
              hintText: hintText,
              keyboardType: TextInputType.text,
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: ColorManager.blueprime,
                size: 22,
              ),
              padding: const EdgeInsets.only(
                  bottom: AppPadding.p5, left: AppPadding.p20),
              onChanged: (value) {
                // NEW: same spurious-rebuild guard as the text fields.
                if (this._lastKnownFieldValue[errorKey] == value) return;
                this._lastKnownFieldValue[errorKey] = value;
                setState(() {
                  errorStates[errorKey] = value.isEmpty;
                });
              },
            ),
            validation: errorStates[errorKey]!
                ? Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      _serverErrorMessages[errorKey] ??
                          'Please select a valid ${labelText.toLowerCase()}. ',
                      style: TextStyle(
                        color: ColorManager.red,
                        fontSize: FontSize.s10,
                      ),
                    ),
                  )
                : const SizedBox(height: 13));
      },
    );
  }

  void _validateFields() {
    errorStates.forEach((key, value) {
      setState(() {
        if (key == 'Livensure' && livensureController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'issueDate' && issueDateController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'expiryDate' && expiryDateController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'issuingOrganization' &&
            issuingOrganizationController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'country' && countryController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'numberID' && numberIDController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'document' &&
            (docNameadd.isEmpty || docNameadd == 'Select')) {
          errorStates[key] = true;
        }
        if (key == 'pickFile' &&
            (pickedFileName.isEmpty || pickedFileName == '')) {
          errorStates[key] = true;
        }
      });
    });
  }

  bool _hasErrors() {
    return errorStates.containsValue(true);
  }

  void _clearControllers() {
    livensureController.clear();
    issuingOrganizationController.clear();
    issueDateController.clear();
    expiryDateController.clear();
    countryController.clear();
    numberIDController.clear();
    docNameadd = 'Select';
    setState(() {
      pickedFileName = '';
      errorStates.updateAll((key, value) => false);
      _serverErrorMessages.updateAll((key, value) => null);
      // FIX: this guard map was never reset, so if this popup's State is
      // ever reused for a second Add without being recreated, a stale
      // leftover value here could cause a genuine keystroke right after
      // clearing to be wrongly treated as "no change" and skipped.
      _lastKnownFieldValue.clear();
    });
  }
}

/// Edit license
class EditLicencesPopup extends StatefulWidget {
  final TextEditingController LivensureController;
  final TextEditingController issueDateController;
  final TextEditingController expiryDateController;
  final TextEditingController issuingOrganizationController;
  final TextEditingController countryController;
  final TextEditingController numberIDController;
  final String documentName;
  final int licenseId;
  final String title;
  final Widget child;
  final VoidCallback onpressedClose;
  // CHANGED: was `Future<void> Function()`. This popup previously had no
  // way to know whether the save actually succeeded — it just called this
  // and moved on. Now it returns the ApiData from updateLicensePatch so
  // this popup can apply field-level errors on failure (and only clear
  // its own controllers / let the caller close the dialog on success).
  // NOTE: update the call site in the screen that builds this popup —
  // its onpressedSave implementation must now return the ApiData from
  // updateLicensePatch instead of returning void.
  final Future<ApiData> Function() onpressedSave;

  const EditLicencesPopup({
    super.key,
    required this.LivensureController,
    required this.issueDateController,
    required this.expiryDateController,
    required this.issuingOrganizationController,
    required this.countryController,
    required this.numberIDController,
    required this.onpressedClose,
    required this.onpressedSave,
    required this.title,
    required this.child,
    required this.licenseId,
    required this.documentName,
  });

  @override
  State<EditLicencesPopup> createState() => _EditLicencesPopupState();
}

class _EditLicencesPopupState extends State<EditLicencesPopup> {
  final DateTime _selectedIssueDate = DateTime.now();
  final DateTime _selectedExpDate = DateTime.now();
  dynamic pickedFile;
  String? pickedFileName;
  bool isLoading = false;
  bool isFilePicked = false;

  // FIX: same calendar-open tracking as _AddLicencesPopupState above — see
  // that class's comment for why this is needed before popping on resize.
  // Shared by both Issue Date and Expiry Date since they both call this
  // same _buildDateField method.
  bool _isDatePickerOpen = false;

  // ─────────────────────────────────────────────────────────────
  // FIX: This popup now owns its own TextEditingControllers.
  // The controllers passed in via `widget.xController` are owned by
  // the caller (the screen behind this dialog). If that caller's
  // State gets disposed while this Dialog route is still open (tab
  // switch, rebuild, etc.), those controllers get disposed too — but
  // this Dialog is a separate route and stays mounted, so its
  // TextFormFields keep listening to a disposed controller =>
  // "A TextEditingController was used after being disposed."
  //
  // Local controllers are seeded from the caller's initial text and
  // used everywhere in this popup's UI. Values are written back to
  // the caller's controllers right before onpressedSave runs.
  // ─────────────────────────────────────────────────────────────
  late final TextEditingController _livensureController;
  late final TextEditingController _issueDateController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _issuingOrganizationController;
  late final TextEditingController _countryController;
  late final TextEditingController _numberIDController;

  // Error states for validations
  Map<String, bool> errorStates = {
    'Livensure': false,
    'issueDate': false,
    'expiryDate': false,
    'issuingOrganization': false,
    'country': false,
    'numberID': false,
    // NEW: this popup doesn't own the Select Document field itself (it's
    // rendered via widget.child from the parent screen), but it still
    // needs to track and display errors for it — including the
    // 'documentType' field-error key and the general-error fallback.
    'document': false,
  };

  // ---------------------------------------------------------------------
  // NEW: server-driven error messages, keyed the same as `errorStates`.
  // Same mechanism as AddLicencesPopup — when set, these override the
  // generic "Please enter X" text under a field.
  // ---------------------------------------------------------------------
  Map<String, String?> _serverErrorMessages = {
    'Livensure': null,
    'issueDate': null,
    'expiryDate': null,
    'issuingOrganization': null,
    'country': null,
    'numberID': null,
    'document': null,
  };

  // NEW: same spurious-onChanged guard as AddLicencesPopup — see the
  // comment on the field of the same name there for why this is needed.
  Map<String, String?> _lastKnownFieldValue = {};

  /// Maps the server's [ErrorDetail.key] values (matching the PATCH body
  /// field names sent to updateLicensePatch) onto this popup's fields.
  ///
  /// Returns true if at least one error was matched. Same reasoning as
  /// AddLicencesPopup's version — without this, an unrecognized key would
  /// silently show nothing at all instead of falling back to a popup.
  bool _applyServerFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return false;
    bool appliedAny = false;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'licensure':
            errorStates['Livensure'] = true;
            _serverErrorMessages['Livensure'] = e.message;
            appliedAny = true;
            break;
          case 'issueDate':
            errorStates['issueDate'] = true;
            _serverErrorMessages['issueDate'] = e.message;
            appliedAny = true;
            break;
          case 'expDate':
            errorStates['expiryDate'] = true;
            _serverErrorMessages['expiryDate'] = e.message;
            appliedAny = true;
            break;
          case 'org':
            errorStates['issuingOrganization'] = true;
            _serverErrorMessages['issuingOrganization'] = e.message;
            appliedAny = true;
            break;
          case 'country':
            errorStates['country'] = true;
            _serverErrorMessages['country'] = e.message;
            appliedAny = true;
            break;
          case 'licenseNumber':
            errorStates['numberID'] = true;
            _serverErrorMessages['numberID'] = e.message;
            appliedAny = true;
            break;
          case 'documentType':
            // NEW: this popup doesn't render the Select Document field
            // itself (it's widget.child from the parent), but it still
            // owns the error slot for it so the error shows in the same
            // place as the other fields.
            errorStates['document'] = true;
            _serverErrorMessages['document'] = e.message;
            appliedAny = true;
            break;
          default:
            // NEW: surfaces the real key (e.g. any casing mismatch) so
            // the mapping can be corrected.
            debugPrint('[EditLicencesPopup] Unmapped field error key: '
                '"${e.key}" -> ${e.message}');
            break;
        }
      }
    });
    return appliedAny;
  }

  /// Clears server-driven messages before a fresh submit.
  void _clearServerFieldErrors() {
    if (!mounted) return;
    setState(() {
      _serverErrorMessages.updateAll((key, value) => null);
    });
  }

  /// Shows a general (non-field-specific) server error using the same
  /// `_serverErrorMessages` map the individual fields already use —
  /// reusing the 'numberID' slot, same as AddLicencesPopup.
  ///
  /// CHANGED: this used to reuse the 'document' slot, but the parent
  /// screen's document dropdown (rendered via widget.child) can clear
  /// that slot's error independently of this popup, which could wipe out
  /// a general error that had nothing to do with the document field.
  void _showGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      errorStates['numberID'] = true;
      _serverErrorMessages['numberID'] = message;
    });
  }

  bool fileAbove20Mb = false;

  final FocusNode _licensureFocus = FocusNode();
  final FocusNode _issuingOrgFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _numberIDFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode nextFocus) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      nextFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    pickedFileName = widget.documentName;
    _livensureController =
        TextEditingController(text: widget.LivensureController.text);
    _issueDateController =
        TextEditingController(text: widget.issueDateController.text);
    _expiryDateController =
        TextEditingController(text: widget.expiryDateController.text);
    _issuingOrganizationController =
        TextEditingController(text: widget.issuingOrganizationController.text);
    _countryController =
        TextEditingController(text: widget.countryController.text);
    _numberIDController =
        TextEditingController(text: widget.numberIDController.text);

    _licensureFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _issuingOrgFocus);
    _issuingOrgFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _countryFocus);
    _countryFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _numberIDFocus);
    _numberIDFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        FocusScope.of(context).unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _livensureController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _issuingOrganizationController.dispose();
    _countryController.dispose();
    _numberIDController.dispose();
    _licensureFocus.dispose();
    _issuingOrgFocus.dispose();
    _countryFocus.dispose();
    _numberIDFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // Same auto-close-on-narrow-screen fix as AddLicencesPopup above.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kLicencesPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !Navigator.canPop(context)) return;
        // FIX: close the calendar dialog first if it's open — otherwise
        // this pop closes the calendar (topmost route) instead of the
        // popup, leaving the broken-width popup still on screen.
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FormDialogSurface(
          width: 900,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FormDialogHeader(
              title: widget.title,
              onClose: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Document Details',
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Select Document', // Main text
                                style:
                                    FormDialogFields.labelStyle, // Main style
                                children: [
                                  TextSpan(
                                    text: ' *', // Asterisk
                                    style: FormDialogFields.labelStyle.copyWith(
                                      color: ColorManager.red, // Asterisk color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            widget.child,
                            // NEW: shows the 'documentType' field error (or the
                            // general-error fallback, which also routes here)
                            // right under the document dropdown — same slot
                            // used by AddLicencesPopup for this field.
                            if (errorStates['document'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _serverErrorMessages['document'] ??
                                      'Please select document. ',
                                  style: TextStyle(
                                    color: ColorManager.red,
                                    fontSize: FontSize.s10,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        ///upload
                        Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Row(
                            children: [
                              pickedFileName == null
                                  ? const SizedBox(height: 11)
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 30),
                                        child: Text(
                                          pickedFileName!,
                                          style: DocumentTypeDataStyle
                                              .customTextStyle(context),
                                        ),
                                      ),
                                    ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomIconButton(
                                    icon: Icons.file_upload_outlined,
                                    text: 'Upload License',
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['pdf']);
                                      final fileSize = result?.files.first
                                          .size; // File size in bytes
                                      final isAbove20MB =
                                          fileSize! > (20 * 1024 * 1024);
                                      if (result != null) {
                                        final file = result.files.first;
                                        setState(() {
                                          pickedFileName = file.name;
                                          pickedFile = file.bytes;
                                          fileAbove20Mb = !isAbove20MB;
                                        });
                                      }
                                    },
                                    isNotPopUpButton: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              FormDialogSection(
                  title: 'License Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _livensureController,
                      labelText: "Licensure / Certification",
                      errorKey: 'Livensure',
                      hintText: 'Enter certification',
                      focusNode: _licensureFocus,
                    ),
                    _buildDateField(
                      controller: _issueDateController,
                      labelText: "Issue Date",
                      errorKey: 'issueDate',
                      issueDate: true,
                      initialDate: _selectedIssueDate,
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildDateField(
                      controller: _expiryDateController,
                      labelText: "Expiry Date",
                      errorKey: 'expiryDate',
                      issueDate: false,
                      initialDate: _selectedExpDate,
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _issuingOrganizationController,
                      labelText: "Issuing Organization",
                      errorKey: 'issuingOrganization',
                      hintText: 'Enter Issuing Organization',
                      focusNode: _issuingOrgFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _countryController,
                      labelText: "Country",
                      errorKey: 'country',
                      hintText: 'Enter Country',
                      focusNode: _countryFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _numberIDController,
                      labelText: "Number/ID",
                      errorKey: 'numberID',
                      hintText: 'Enter Number',
                      focusNode: _numberIDFocus,
                    )
                  ]))
            ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonTransparent(
                        text: AppString.cancel,
                        onPressed: () async {
                          Navigator.pop(context);
                          _clearControllers();
                        }),
                    const SizedBox(
                      width: AppSize.s10,
                    ),
                    CustomElevatedButton(
                      width: AppSize.s100,
                      text: AppString.save,
                      isLoading: isLoading,
                      onPressed: () async {
                        // Validate file size only if a file is picked
                        if (pickedFile != null) {
                          // If the file is greater than 20MB, show an error dialog
                          if (!fileAbove20Mb) {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddErrorPopup(
                                  message: 'File is too large. ',
                                );
                              },
                            );
                            return; // Stop further execution if the file is too large
                          }
                        }

                        setState(() {
                          _validateFields();
                        });

                        // NEW: clear any previously shown server field errors
                        // before a fresh submit attempt.
                        _clearServerFieldErrors();

                        // If no validation errors, proceed with the API calls
                        if (!_hasErrors()) {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            // Sync local values back into the caller-owned
                            // controllers before invoking the save callback —
                            // widget.onpressedSave is provided by the parent
                            // screen and presumably reads from these same
                            // controller instances to build its save request.
                            widget.LivensureController.text =
                                _livensureController.text;
                            widget.issueDateController.text =
                                _issueDateController.text;
                            widget.expiryDateController.text =
                                _expiryDateController.text;
                            widget.issuingOrganizationController.text =
                                _issuingOrganizationController.text;
                            widget.countryController.text =
                                _countryController.text;
                            widget.numberIDController.text =
                                _numberIDController.text;

                            // Log the license ID
                            print(">>>>License ID: ${widget.licenseId}");

                            // If a file is picked, upload the document
                            print("Uploading document...");
                            await attachLicenseDocument(
                              context,
                              widget.licenseId,
                              pickedFile,
                              pickedFileName!,
                            );

                            // Proceed with saving — now returns the ApiData
                            // from updateLicensePatch instead of void, so we
                            // can tell success from a validation failure.
                            final response = await widget.onpressedSave();

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              // Only clear controllers on genuine success —
                              // clearing them on failure wiped the user's
                              // input right as they needed to fix it. Closing
                              // the dialog itself (Navigator.pop) is left to
                              // the caller's onpressedSave, same as before.
                              _clearControllers();
                            } else if (response.statusCode == 400 ||
                                response.statusCode == 404) {
                              // NEW: apply per-field errors and keep the
                              // popup open with the user's input intact.
                              bool appliedFieldErrors = false;
                              if (response.fieldErrors != null &&
                                  response.fieldErrors!.isNotEmpty) {
                                appliedFieldErrors = _applyServerFieldErrors(
                                    response.fieldErrors!);
                              }
                              // CHANGED: shown as inline validation text near
                              // the Save button instead of a popup — fires
                              // when fieldErrors was empty, or non-empty but
                              // none of its keys matched a known field.
                              if (!appliedFieldErrors) {
                                _showGeneralError(response.message);
                              }
                            } else {
                              // CHANGED: shown inline instead of a popup.
                              _showGeneralError(response.message);
                            }
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                    ),
                  ],
                )),
          ])),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String errorKey,
    required bool capitalIsSelect,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          isDigitSelect: capitalIsSelect,
          height: AppSize.s30,
          width: 240,
          controller: controller,
          hintText: hintText,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          padding: const EdgeInsets.only(
              bottom: AppPadding.p5, left: AppPadding.p20),
          onChanged: (value) {
            // NEW: skip spurious rebuild-triggered re-fires with an
            // unchanged value — see AddLicencesPopup's onChanged for the
            // full explanation.
            if (_lastKnownFieldValue[errorKey] == value) return;
            _lastKnownFieldValue[errorKey] = value;

            setState(() {
              errorStates[errorKey] = value.isEmpty;
              // NEW: clear the stale server message once the user edits
              // this field again.
              _serverErrorMessages[errorKey] = null;
            });
          },
        ),
        validation: errorStates[errorKey]!
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  _serverErrorMessages[errorKey] ??
                      'Please enter ${labelText.toLowerCase()}. ',
                  style: TextStyle(
                    color: ColorManager.red,
                    fontSize: FontSize.s10,
                  ),
                ),
              )
            : const SizedBox(
                height: 13,
              ));
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String errorKey,
    required bool issueDate,
    required DateTime initialDate,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          height: AppSize.s30,
          width: 240,
          controller: controller,
          hintText: hintText,
          keyboardType: TextInputType.text,
          suffixIcon: Icon(
            Icons.calendar_month_outlined,
            color: ColorManager.blueprime,
          ),
          padding: const EdgeInsets.only(
              bottom: AppPadding.p5, left: AppPadding.p20),
          onChanged: (value) {
            // NEW: same spurious-rebuild guard as the other fields.
            if (_lastKnownFieldValue[errorKey] == value) return;
            _lastKnownFieldValue[errorKey] = value;
            setState(() {
              errorStates[errorKey] = value.isEmpty;
            });
          },
        ),
        validation: errorStates[errorKey]!
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  _serverErrorMessages[errorKey] ??
                      'Please select a valid ${labelText.toLowerCase()}. ',
                  style: TextStyle(
                    color: ColorManager.red,
                    fontSize: FontSize.s10,
                  ),
                ),
              )
            : const SizedBox(height: 13));
  }

  void _validateFields() {
    errorStates.forEach((key, value) {
      setState(() {
        if (key == 'Livensure' && _livensureController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'issueDate' && _issueDateController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'expiryDate' && _expiryDateController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'issuingOrganization' &&
            _issuingOrganizationController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'country' && _countryController.text.isEmpty) {
          errorStates[key] = true;
        }
        if (key == 'numberID' && _numberIDController.text.isEmpty) {
          errorStates[key] = true;
        }
      });
    });
  }

  bool _hasErrors() {
    return errorStates.containsValue(true);
  }

  void _clearControllers() {
    _livensureController.clear();
    _issuingOrganizationController.clear();
    _issueDateController.clear();
    _expiryDateController.clear();
    _countryController.clear();
    _numberIDController.clear();
    setState(() {
      pickedFileName = null;
      errorStates.updateAll((key, value) => false);
      _serverErrorMessages.updateAll((key, value) => null);
      // FIX: same reset as AddLicencesPopup — see comment there.
      _lastKnownFieldValue.clear();
    });
  }
}
