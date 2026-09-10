import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';

// NEW: manager functions + model used to save/update and read per-field
// server validation errors.
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/references_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';

// Design width this popup is built for. Below this, the 3-column layout
// (each field sized to screenWidth / 6) has no room to work with, so we
// close the popup instead of letting it render broken.
const double _kReferencePopupDesignWidth = 860;

class AddReferencePopup extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController titlePositionController;
  final TextEditingController knowPersonController;
  final TextEditingController companyNameController;
  final TextEditingController associationLengthController;
  final TextEditingController mobileNumberController;
  final TextEditingController referredBy;
  final String title;

  // NEW: needed to call addReferencePost / updateReferencePatch directly
  // from inside this popup.
  final int employeeId;

  // NEW: this is what makes the SAME popup work for both Add and Edit.
  // Pass null to add a new reference; pass an existing reference's ID to
  // edit it. The popup decides which API to call based on this.
  final int? referenceId;

  final VoidCallback onpressedClose;

  // CHANGED: was `Future<void> Function() onpressedSave` — the caller
  // used to be responsible for actually calling the save API. Now this
  // popup does that itself (so it can read the response and show
  // field-level errors), so this callback is just a post-save hook —
  // e.g. to refresh a list or close a parent dialog. It only fires after
  // a genuine 200/201, never after a validation failure.
  final Future<void> Function() onSaved;

  const AddReferencePopup(
      {super.key,
      required this.nameController,
      required this.emailController,
      required this.titlePositionController,
      required this.knowPersonController,
      required this.companyNameController,
      required this.associationLengthController,
      required this.mobileNumberController,
      required this.onpressedClose,
      required this.onSaved,
      required this.title,
      required this.referredBy,
      required this.employeeId,
      this.referenceId});

  @override
  State<AddReferencePopup> createState() => _AddReferencePopupState();
}

class _AddReferencePopupState extends State<AddReferencePopup> {
  bool isLoading = false;

  bool get _isEditMode => widget.referenceId != null;

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
  // the caller's controllers right before onSaved runs.
  // ─────────────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _titlePositionController;
  late final TextEditingController _knowPersonController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _associationLengthController;
  late final TextEditingController _mobileNumberController;
  late final TextEditingController _referredBy;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _knowPersonFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _associationFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();

  // Error states
  Map<String, bool> errorStates = {
    'name': false,
    'email': false,
    'titlePosition': false,
    'knowPerson': false,
    'companyName': false,
    'associationLength': false,
    'mobileNumber': false,
    'referredBy': false,
  };

  // ---------------------------------------------------------------------
  // NEW: server-driven error messages, keyed the same as `errorStates`.
  // When set, these override the generic "Please enter X" text under a
  // field so the user sees the server's actual validation message.
  // ---------------------------------------------------------------------
  Map<String, String?> _serverErrorMessages = {
    'name': null,
    'email': null,
    'titlePosition': null,
    'knowPerson': null,
    'companyName': null,
    'associationLength': null,
    'mobileNumber': null,
  };

  // NEW: guards against custom text-field widgets re-firing onChanged
  // with an unchanged value during a rebuild — see the Licenses popup
  // for the full explanation of why this matters.
  Map<String, String?> _lastKnownFieldValue = {};

  /// Maps the server's [ErrorDetail.key] values (matching the POST/PATCH
  /// body field names: association, comment, company, email, mob, name,
  /// references, title) onto this popup's fields.
  ///
  /// Returns true if at least one error was actually matched to a field.
  bool _applyServerFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return false;
    bool appliedAny = false;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'name':
            errorStates['name'] = true;
            _serverErrorMessages['name'] = e.message;
            appliedAny = true;
            break;
          case 'email':
            errorStates['email'] = true;
            _serverErrorMessages['email'] = e.message;
            appliedAny = true;
            break;
          case 'title':
            errorStates['titlePosition'] = true;
            _serverErrorMessages['titlePosition'] = e.message;
            appliedAny = true;
            break;
          case 'references':
            errorStates['knowPerson'] = true;
            _serverErrorMessages['knowPerson'] = e.message;
            appliedAny = true;
            break;
          case 'company':
            errorStates['companyName'] = true;
            _serverErrorMessages['companyName'] = e.message;
            appliedAny = true;
            break;
          case 'association':
            errorStates['associationLength'] = true;
            _serverErrorMessages['associationLength'] = e.message;
            appliedAny = true;
            break;
          case 'mob':
            errorStates['mobileNumber'] = true;
            _serverErrorMessages['mobileNumber'] = e.message;
            appliedAny = true;
            break;
          default:
            // 'comment' (referredBy — currently a disabled/commented-out
            // field) or any casing mismatch ends up here.
            debugPrint('[AddReferencePopup] Unmapped field error key: '
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
  /// reusing the 'mobileNumber' slot (the last real field in this form)
  /// instead of introducing a separate error variable/widget.
  void _showGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      errorStates['mobileNumber'] = true;
      _serverErrorMessages['mobileNumber'] = message;
    });
  }

  // Email validation
  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }

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
    _nameController = TextEditingController(text: widget.nameController.text);
    _emailController = TextEditingController(text: widget.emailController.text);
    _titlePositionController =
        TextEditingController(text: widget.titlePositionController.text);
    _knowPersonController =
        TextEditingController(text: widget.knowPersonController.text);
    _companyNameController =
        TextEditingController(text: widget.companyNameController.text);
    _associationLengthController =
        TextEditingController(text: widget.associationLengthController.text);
    _mobileNumberController =
        TextEditingController(text: widget.mobileNumberController.text);
    _referredBy = TextEditingController(text: widget.referredBy.text);

    _nameFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _emailFocus);
    _emailFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _titleFocus);
    _titleFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _knowPersonFocus);
    _knowPersonFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _companyFocus);
    _companyFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _associationFocus);
    _associationFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _mobileFocus);
    _mobileFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _handleSave();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titlePositionController.dispose();
    _knowPersonController.dispose();
    _companyNameController.dispose();
    _associationLengthController.dispose();
    _mobileNumberController.dispose();
    _referredBy.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _titleFocus.dispose();
    _knowPersonFocus.dispose();
    _companyFocus.dispose();
    _associationFocus.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // If the window/screen is resized below the popup's design width, the
    // layout has no room to work with — close the popup instead of letting
    // it render broken. Scheduled as a post-frame callback since we can't
    // call Navigator.pop synchronously inside build().
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kReferencePopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                Navigator.pop(context);
                _clearControllers();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Reference Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: "Name",
                      errorKey: 'name',
                      capitalIsSelect: false,
                      hintText: 'Enter Name',
                      focusNode: _nameFocus,
                    ),
                    _buildTextField(
                      controller: _titlePositionController,
                      labelText: "Title/Position",
                      errorKey: 'titlePosition',
                      capitalIsSelect: false,
                      hintText: 'Enter Title',
                      focusNode: _titleFocus,
                    ),
                    _buildTextField(
                      controller: _companyNameController,
                      labelText: "Company",
                      errorKey: 'companyName',
                      capitalIsSelect: false,
                      hintText: 'Enter Company',
                      focusNode: _companyFocus,
                    )
                  ])),
              FormDialogSection(
                  title: 'Contact Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      controller: _emailController,
                      labelText: "Email",
                      errorKey: 'email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => !_isEmailValid(value)
                          ? 'Please enter a valid email. '
                          : null,
                      capitalIsSelect: false,
                      phoneNumberField: false,
                      hintText: 'Enter Email',
                      focusNode: _emailFocus,
                    ),
                    _buildTextField(
                      controller: _mobileNumberController,
                      labelText: "Mobile Number",
                      errorKey: 'mobileNumber',
                      keyboardType: TextInputType.number,
                      capitalIsSelect: false,
                      phoneNumberField: true,
                      hintText: 'Enter Mobile Number',
                      focusNode: _mobileFocus,
                    )
                  ])),
              FormDialogSection(
                  title: 'Relationship Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      controller: _knowPersonController,
                      labelText: "How do you know this person?",
                      errorKey: 'knowPerson',
                      capitalIsSelect: false,
                      hintText: 'Enter Text',
                      focusNode: _knowPersonFocus,
                    ),
                    _buildTextField(
                      controller: _associationLengthController,
                      labelText: "Length of Association",
                      errorKey: 'associationLength',
                      capitalIsSelect: false,
                      hintText: 'Enter Length of Association',
                      focusNode: _associationFocus,
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
                        onPressed: () {
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
                      onPressed: _handleSave,
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
    TextInputType? keyboardType,
    String? Function(String)? validator,
    bool capitalIsSelect = false,
    bool phoneNumberField = false,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          phoneNumberField: phoneNumberField,
          height: AppSize.s30,
          width: 240,
          controller: controller,
          hintText: hintText,
          focusNode: focusNode,
          keyboardType: keyboardType ?? TextInputType.text,
          padding: const EdgeInsets.only(
              bottom: AppPadding.p5, left: AppPadding.p20),
          isDigitSelect: capitalIsSelect, // Pass the parameter here
          onChanged: (value) {
            // NEW: skip spurious rebuild-triggered re-fires with an
            // unchanged value — see the Licenses popup for the full
            // explanation of why this guard exists.
            if (_lastKnownFieldValue[errorKey] == value) return;
            _lastKnownFieldValue[errorKey] = value;

            setState(() {
              if (validator != null) {
                errorStates[errorKey] = validator(value) != null;
              } else {
                errorStates[errorKey] = value.isEmpty;
              }
              if (errorKey == 'mobileNumber') {
                // Validate phone number fields
                String numericValue =
                    value.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
                errorStates[errorKey] = numericValue.length != 14;
              }
              // NEW: clear the stale server message once the user edits
              // this field again.
              _serverErrorMessages[errorKey] = null;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${labelText.toLowerCase()}. ';
            }
            if (errorKey == 'mobileNumber') {
              String numericValue =
                  value.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
              if (numericValue.length != 14) {
                return 'Please enter a valid mobile number. ';
              }
            }
            return null;
          },
        ),
        validation: errorStates[errorKey]!
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  // NEW: server message takes priority when present.
                  _serverErrorMessages[errorKey] ??
                      (errorKey == 'email'
                          ? 'Please enter a valid email. '
                          : 'Please enter ${labelText.toLowerCase()}. '),
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

  void _handleSave() async {
    // NEW: clear any previously shown server field errors before a fresh
    // validation/submit pass.
    _clearServerFieldErrors();

    setState(() {
      errorStates['name'] = _nameController.text.isEmpty;
      errorStates['email'] = !_isEmailValid(_emailController.text);
      errorStates['titlePosition'] = _titlePositionController.text.isEmpty;
      errorStates['knowPerson'] = _knowPersonController.text.isEmpty;
      errorStates['companyName'] = _companyNameController.text.isEmpty;
      errorStates['associationLength'] =
          _associationLengthController.text.isEmpty;
      errorStates['mobileNumber'] = _mobileNumberController.text.isEmpty;
    });

    if (errorStates.values.contains(true)) return;

    setState(() {
      isLoading = true;
    });

    try {
      // NEW: this popup now calls the API itself — Add or Edit — instead
      // of delegating to a caller-provided callback that just returned
      // void with no way to report back a validation failure.
      final ApiData response;
      if (!_isEditMode) {
        response = await addReferencePost(
          context,
          _associationLengthController.text,
          _referredBy.text, // "comment" — currently unused in the UI
          _companyNameController.text,
          _emailController.text,
          widget.employeeId,
          _mobileNumberController.text,
          _nameController.text,
          _knowPersonController.text,
          _titlePositionController.text,
        );
      } else {
        response = await updateReferencePatch(
          context,
          widget.referenceId!,
          _associationLengthController.text,
          _referredBy.text,
          _companyNameController.text,
          _emailController.text,
          widget.employeeId,
          _mobileNumberController.text,
          _nameController.text,
          _knowPersonController.text,
          _titlePositionController.text,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sync local values back into the caller-owned controllers before
        // invoking the post-save hook — some callers may still read from
        // these same controller instances elsewhere.
        if (!_isEditMode) {
          await approveOnboardQualifyReferencePatch(
              context, response.referenceId!);
          widget.nameController.text = _nameController.text;
          widget.emailController.text = _emailController.text;
          widget.titlePositionController.text = _titlePositionController.text;
          widget.knowPersonController.text = _knowPersonController.text;
          widget.companyNameController.text = _companyNameController.text;
          widget.associationLengthController.text =
              _associationLengthController.text;
          widget.mobileNumberController.text = _mobileNumberController.text;
          widget.referredBy.text = _referredBy.text;

          // NEW: this popup closes itself on success now (previously the
          // caller's onpressedSave was responsible for that).
          Navigator.pop(context);
          await widget.onSaved();
          _clearControllers();
        } else {
          widget.nameController.text = _nameController.text;
          widget.emailController.text = _emailController.text;
          widget.titlePositionController.text = _titlePositionController.text;
          widget.knowPersonController.text = _knowPersonController.text;
          widget.companyNameController.text = _companyNameController.text;
          widget.associationLengthController.text =
              _associationLengthController.text;
          widget.mobileNumberController.text = _mobileNumberController.text;
          widget.referredBy.text = _referredBy.text;

          // NEW: this popup closes itself on success now (previously the
          // caller's onpressedSave was responsible for that).
          Navigator.pop(context);
          await widget.onSaved();
          _clearControllers();
        }
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        // NEW: apply per-field errors and keep the popup open with the
        // user's input intact, instead of unconditionally closing and
        // clearing (which the old code did in `finally`, wiping the
        // user's input right as they needed to fix a validation error).
        bool appliedFieldErrors = false;
        if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
          appliedFieldErrors = _applyServerFieldErrors(response.fieldErrors!);
        }
        if (!appliedFieldErrors) {
          _showGeneralError(response.message);
        }
      } else {
        _showGeneralError(response.message);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _companyNameController.clear();
    _titlePositionController.clear();
    _mobileNumberController.clear();
    _associationLengthController.clear();
    _knowPersonController.clear();
    _referredBy.clear();
    setState(() {
      errorStates.updateAll((key, value) => false);
      _serverErrorMessages.updateAll((key, value) => null);
      // FIX: reset the guard map too — otherwise a stale value here could
      // cause a genuine keystroke right after clearing (e.g. if this
      // popup's State is reused for a second Add) to be wrongly treated
      // as "no change" and skipped.
      _lastKnownFieldValue.clear();
    });
  }
}
