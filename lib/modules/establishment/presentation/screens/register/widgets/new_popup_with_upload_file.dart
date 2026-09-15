import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/user.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/password_text_field.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/header_content_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';

enum _DialogStep { createUser, uploadDoc }

class CustomDialogUploadefile extends StatefulWidget {
  final String title;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController passwordController;
  final VoidCallback? onCancel;

  const CustomDialogUploadefile({
    required this.title,
    this.onCancel,
    required this.lastNameController,
    required this.emailController,
    required this.firstNameController,
    required this.passwordController,
  });

  @override
  State<CustomDialogUploadefile> createState() => _CustomDialogUploadefileState();
}

class _CustomDialogUploadefileState extends State<CustomDialogUploadefile> {
  _DialogStep _step = _DialogStep.createUser;

  // ✅ store created user id after createUser API
  int? _createdUserId;

  // ===== upload state =====
  String displayFileName = "Choose file";
  String? pickedFileName;
  String? filePath;
  Uint8List? fileBytes;
  bool isFilePicked = false;

  // Set true when the last picked file exceeded the 10 MB limit. Used to
  // disable the Submit button so the user can't try to upload it — they
  // have to pick a smaller file (or Skip) first.
  bool _isFileTooLarge = false;

  bool isUploading = false;
  bool isCreating = false;

  String? _nameDocError;
  String? _emailDocError;
  String? _stateDocError;
  String? _PasswordDocError;
  String? _departmentError;

  // ─────────────────────────────────────────────────────────────
  // Backend / API errors are now shown as inline red text inside
  // this same popup instead of a separate FailedPopup dialog.
  // _createBackendError -> shown in the "createUser" step body.
  // _uploadBackendError -> shown in the "uploadDoc" step body.
  // Both are cleared at the start of their respective action so a
  // fresh attempt doesn't show a stale message.
  // ─────────────────────────────────────────────────────────────
  String? _createBackendError;
  String? _uploadBackendError;

  bool _isFormValid = true;

  var deptId = 1;
  String selectedDeptName = "Select Department";
  int? selectedDeptId;

  // ─────────────────────────────────────────────────────────────
  // FIX: widget.firstNameController / lastNameController /
  // emailController / passwordController are owned by the PARENT
  // screen, not this dialog — they get passed in and reused across
  // every "Create User" click. Previously they were only cleared
  // inside specific button handlers (Skip, onClear, successful
  // Submit). But showDialog's barrier is dismissible by default, so
  // tapping outside the popup pops the route directly without going
  // through any of those handlers — leaving whatever was typed still
  // sitting in the controllers, so the next time "Create User" opens
  // it shows the stale data instead of a fresh form.
  //
  // `_guardReset()` centralizes that cleanup, and PopScope's
  // onPopInvoked below runs it on EVERY dismissal path — barrier tap,
  // system back gesture/button, or our own Navigator.pop calls — so
  // the controllers are guaranteed empty before the popup can ever be
  // reopened. The `_hasReset` flag stops it from running twice when a
  // button already triggered a pop that also fires onPopInvoked.
  // ─────────────────────────────────────────────────────────────
  bool _hasReset = false;

  // Focus nodes for keyboard Enter-key navigation
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _deptFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  void _guardReset() {
    if (_hasReset) return;
    _hasReset = true;
    widget.firstNameController.clear();
    widget.lastNameController.clear();
    widget.emailController.clear();
    widget.passwordController.clear();
    widget.onCancel?.call();
  }

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<HRHeadBar>> _hrHeadFuture;

  @override
  void initState() {
    super.initState();
    _hrHeadFuture = companyHRHeadApi(context, deptId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _generatePassword();
    });
    _firstNameFocus.onKeyEvent = (_, event) => _handleEnterKey(event, _lastNameFocus);
    _lastNameFocus.onKeyEvent = (_, event) => _handleEnterKey(event, _deptFocus);
    // _deptFocus Enter is handled by HRUManageDropdown's internal Focus.onKeyEvent
    // (opens/closes the dropdown). After item selection, onChanged calls _emailFocus.requestFocus().
    _emailFocus.onKeyEvent = (_, event) => _handleEnterKey(event, _passwordFocus);
    _passwordFocus.onKeyEvent = (_, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _triggerCreate();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode next) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      next.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _deptFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _generatePassword() {
    final random = Random();
    // Ensure generated password satisfies validation: letters + at least
    // one number and one special character.
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '@#\$%&';
    final allChars = letters + numbers + special;

    final passwordChars = <String>[];
    // Guarantee at least one number and one special character.
    passwordChars.add(numbers[random.nextInt(numbers.length)]);
    passwordChars.add(special[random.nextInt(special.length)]);
    for (int i = 0; i < 6; i++) {
      passwordChars.add(allChars[random.nextInt(allChars.length)]);
    }
    passwordChars.shuffle(random);

    widget.passwordController.text = passwordChars.join();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.passwordController.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    });
  }

  // =========================
  // Pick file (WEB SAFE)
  // =========================
  // Max upload size — 10 MB, matches the "File is too large." message
  // shown below. Bump this if the backend's limit ever changes.
  static const int _kMaxFileSizeBytes = 10 * 1024 * 1024;

  Future<void> pickAckFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;

    // Reject anything over 10 MB before it's accepted as the selected
    // file — leaves the previous selection (or "Choose file") in place
    // and shows the same inline red error slot used for backend errors.
    if (picked.size > _kMaxFileSizeBytes) {
      setState(() {
        _uploadBackendError = "File is too large. ";
        _isFileTooLarge = true;
      });
      return;
    }

    setState(() {
      displayFileName = picked.name;
      pickedFileName = picked.name;

      if (kIsWeb) {
        filePath = null;
        fileBytes = picked.bytes;
      } else {
        filePath = picked.path;
        fileBytes = picked.bytes;
      }

      isFilePicked = (fileBytes != null) || (!kIsWeb && filePath != null);

      // Clear any previous upload error once the user picks a new (valid)
      // file, and re-enable Submit.
      _uploadBackendError = null;
      _isFileTooLarge = false;
    });
  }

  // =========================
  // Convert file to base64
  // =========================
  Future<String?> _getPickedFileBase64() async {
    if (fileBytes != null) {
      return base64Encode(fileBytes!);
    }

    if (!kIsWeb && filePath != null) {
      final bytes = await File(filePath!).readAsBytes();
      return base64Encode(bytes);
    }

    return null;
  }

  // ✅ Try extracting userId from createUser response
  int? _extractUserId(Object? rawData) {
    if (rawData == null) return null;

    // response.data from Dio is usually Map<String,dynamic>
    if (rawData is Map) {
      final dynamic id =
          rawData["userId"] ??
              rawData["id"] ??
              rawData["data"]?["userId"] ??
              rawData["data"]?["id"] ??
              rawData["result"]?["id"];

      if (id is int) return id;
      return int.tryParse(id?.toString() ?? "");
    }

    return null;
  }

  // =========================
  // Upload optional submit
  // =========================
  Future<void> _submitUploadOptional() async {
    if (isUploading) return;

    // Defensive guard — the Submit button below is already disabled while
    // this is true, but this stops anything from slipping through if it's
    // ever invoked another way.
    if (_isFileTooLarge) return;

    // ✅ If no file picked -> just close
    if (!isFilePicked) {
      Navigator.pop(context);
      return;
    }

    // Clear any previous inline error before a fresh attempt.
    setState(() => _uploadBackendError = null);

    if (_createdUserId == null) {
      setState(() {
        _uploadBackendError = "Missing user id. Please create user again. ";
      });
      return;
    }

    final base64 = await _getPickedFileBase64();
    if (base64 == null || pickedFileName == null) {
      setState(() {
        _uploadBackendError = "Could not read selected file. ";
      });
      return;
    }

    setState(() => isUploading = true);

    try {
      final res = await uploadUserDocumentPost(
        context,
        _createdUserId!,
        base64,
        pickedFileName!,
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
      } else {
        setState(() {
          _uploadBackendError = res.message;
        });
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  // =========================
  // Upload UI (optional)
  // =========================
  List<Widget> _uploadStepBody() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kindly upload candidates resume in .pdf format.",
              style: TextStyle(fontSize: 13, color: ColorManager.grey),
            ),
            const SizedBox(height: 18),
            HeaderContentConst(
              isAsterisk: false,
              heading: " ",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: pickAckFile,
                    child: Container(
                      height: AppSize.s30,
                      width: AppSize.s354,
                      padding: const EdgeInsets.only(left: AppPadding.p10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorManager.containerBorderGrey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayFileName,
                              style: DocumentTypeDataStyle.customTextStyle(context),
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(4),
                            onPressed: pickAckFile,
                            icon: Icon(
                              Icons.file_upload_outlined,
                              color: ColorManager.black,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Inline backend/error text for the upload step —
                  // replaces the old FailedPopup dialog.
                  //
                  // NOTE: this always occupies the same slot (text OR a
                  // same-height SizedBox) instead of only being added to
                  // the tree when there's an error. Conditionally adding
                  // the widget was changing the dialog's total height
                  // whenever the error appeared/disappeared, which made
                  // the fields above visibly "shake"/jump.
                  const SizedBox(height: 6),
                  _uploadBackendError != null
                      ? Text(
                    _uploadBackendError!,
                    style: CommonErrorMsg.customBackendErrorTextStyle(context),
                  )
                      : const SizedBox(height: AppSize.s12),

                  const SizedBox(height: 18),

                ],
              ),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip button — unchanged
                CustomElevatedButton(
                  height: AppSize.s34,
                  width: AppSize.s140,
                  color: ColorManager.blueprime,
                  text: 'Skip',
                  onPressed: () {
                    // Controller clearing + onCancel now happen centrally
                    // in _guardReset() via PopScope's onPopInvoked below,
                    // so this just needs to pop.
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(width: 12),

                // Submit / Loader (same space)
                SizedBox(
                  height: AppSize.s34,
                  width: AppSize.s140,
                  child: CustomElevatedButton(
                    // Greyed out + inert while "File is too large. " is
                    // showing, so there's no way to try submitting the
                    // oversized file. Picking a valid file (or Skip)
                    // clears `_isFileTooLarge` and this goes back to
                    // normal.
                    color: _isFileTooLarge
                        ? ColorManager.containerBorderGrey
                        : ColorManager.blueprime,
                    height: AppSize.s34,
                    width: AppSize.s140,
                    text: 'Submit',
                    isLoading: isUploading,
                    onPressed:
                    _isFileTooLarge ? () {} : _submitUploadOptional,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    ];
  }

  // =========================
  // Create user validations
  // =========================
  String? _validateTextField(String value, String fieldName) {
    return value.isEmpty ? "Please enter ${fieldName.toLowerCase()}. " : null;
  }

  // NEW: dedicated email validator — the old _validateTextField only
  // checked for emptiness, so something like "abc" or "test@" would pass
  // validation as long as the field wasn't blank. This adds a proper
  // format check on top of the empty check.
  String? _validateEmail(String value) {
    if (value.isEmpty) return "Please enter email. ";
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email address. ";
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return "Please enter password. ";
    }
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[@#\$%&]').hasMatch(value);

    if (value.length < 8 || !hasNumber || !hasSpecialChar) {
      return "Min 8 characters, and must have 1 number & 1 symbol. ";
    }
    return null;
  }

  void _validateForm() {
    final nameError = _validateTextField(widget.firstNameController.text, 'First Name');
    final lastNameError = _validateTextField(widget.lastNameController.text, 'Last Name');
    final emailError = _validateEmail(widget.emailController.text); // CHANGED: proper format check
    final passwordError = _validatePassword(widget.passwordController.text);

    final deptError =
    (selectedDeptId == null || selectedDeptId == 0) ? "Please select a department. " : null;

    setState(() {
      _nameDocError = nameError;
      _stateDocError = lastNameError;
      _emailDocError = emailError;
      _PasswordDocError = passwordError;
      _departmentError = deptError;
    });

    _isFormValid =
        [nameError, lastNameError, emailError, passwordError, deptError].every((e) => e == null);
  }

  List<Widget> _createUserBody() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SMTextfieldAsteric(
              hintText: "First Name",
              controller: widget.firstNameController,
              keyboardType: TextInputType.text,
              text: "First Name",
              focusNode: _firstNameFocus,
              onChange: () {
                if (_nameDocError != null) setState(() => _nameDocError = null);
              },
            ),
            _nameDocError != null
                ? Text(_nameDocError!, style: CommonErrorMsg.customTextStyle(context))
                : const SizedBox(height: AppSize.s12),

            const SizedBox(height: AppSize.s10),

            SMTextfieldAsteric(
              hintText: 'Last Name',
              controller: widget.lastNameController,
              keyboardType: TextInputType.text,
              text: 'Last Name',
              focusNode: _lastNameFocus,
              onChange: () {
                if (_stateDocError != null) setState(() => _stateDocError = null);
              },
            ),
            _stateDocError != null
                ? Text(_stateDocError!, style: CommonErrorMsg.customTextStyle(context))
                : const SizedBox(height: AppSize.s12),

            const SizedBox(height: AppSize.s12),

            RichText(
              text: TextSpan(
                text: "Select Department",
                style: AllPopupHeadings.customTextStyle(context),
                children: [
                  TextSpan(
                    text: ' *',
                    style: AllPopupHeadings.customTextStyle(context).copyWith(color: ColorManager.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s5),

            FutureBuilder<List<HRHeadBar>>(
              future: _hrHeadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    child: HRUManageDropdown(
                      controller: TextEditingController(text: selectedDeptName),
                      labelFontSize: FontSize.s12,
                      items: const [],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      ErrorMessageString.noroleAdded,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }

                // FIX: exclude "Patient" from the dropdown entirely — it should
                // never be a selectable department here. Filtered on the raw list
                // first so both `items` (shown) and the lookup in onChanged stay
                // in sync.
                final list = snapshot.data!
                    .where((d) => d.deptName != 'Patient')
                    .toList();
                final items = list.map((e) => e.deptName!).toList();

                return HRUManageDropdown(
                  controller: TextEditingController(text: selectedDeptName),
                  hintText: "Department",
                  labelFontSize: FontSize.s12,
                  items: items,
                  focusNode: _deptFocus,
                  onChanged: (val) {
                    setState(() {
                      _departmentError = null;
                      selectedDeptName = val;
                      selectedDeptId = list.firstWhere((d) => d.deptName == val).deptId;
                    });
                    _emailFocus.requestFocus();
                  },
                );
              },
            ),
            _departmentError != null
                ? Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(_departmentError!, style: CommonErrorMsg.customTextStyle(context)),
            )
                : const SizedBox(height: AppSize.s14),

            const SizedBox(height: AppSize.s9),

            SMTextfieldAsteric(
              hintText: 'Email',
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              text: 'Email',
              focusNode: _emailFocus,
              onChange: () {
                if (_emailDocError != null) setState(() => _emailDocError = null);
              },
            ),
            _emailDocError != null
                ? Text(_emailDocError!, style: CommonErrorMsg.customTextStyle(context))
                : const SizedBox(height: AppSize.s12),

            const SizedBox(height: AppSize.s12),

            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text.rich(
                TextSpan(
                  text: "Password",
                  style: AllPopupHeadings.customTextStyle(context),
                  children:  [
                    TextSpan(
                      text: ' *',
                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                        color: Colors.red, // Asterisk color
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSize.s5),

            PasswordTextField(
              controller: widget.passwordController,
              focusNode: _passwordFocus,
              onCopyPressed: _copyToClipboard,
              onChanged: (_) {
                if (_PasswordDocError != null) {
                  setState(() {
                    _PasswordDocError = null;
                  });
                }
              },
            ),

            _PasswordDocError != null
                ? Text(_PasswordDocError!, style: CommonErrorMsg.customTextStyle(context))
                : const SizedBox(height: AppSize.s12),

            // Inline backend/error text for the create-user step —
            // replaces the old FailedPopup dialog (e.g. duplicate email,
            // server error, missing userId in response, etc.).
            //
            // NOTE: this always occupies the same slot (text OR a
            // same-height SizedBox) instead of only being added to the
            // tree when there's an error. Conditionally adding the
            // widget was changing the dialog's total height whenever
            // the error appeared/disappeared, which made the fields
            // above visibly "shake"/jump.
            const SizedBox(height: 4),
            _createBackendError != null
                ? Center(
              child: Text(
                _createBackendError!,
                style: CommonErrorMsg.customBackendErrorTextStyle(context),
              ),
            )
                : const SizedBox(height: AppSize.s12),
          ],
        ),
      )
    ];
  }

  Future<void> _triggerCreate() async {
    _validateForm();

    // Clear any previous inline backend error before a fresh attempt.
    setState(() => _createBackendError = null);

    if (!_isFormValid) return;

    setState(() => isCreating = true);

    try {
      final response = await createUserPost(
        context,
        widget.firstNameController.text,
        widget.lastNameController.text,
        selectedDeptId!,
        widget.emailController.text,
        widget.passwordController.text,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdId = _extractUserId(response.data);

        if (createdId == null) {
          setState(() {
            _createBackendError =
            "User created but user id not found in response data. Check API response keys. ";
          });
          return;
        }

        setState(() {
          _createdUserId = createdId;
          _step = _DialogStep.uploadDoc;
        });

        showDialog(
          context: context,
          builder: (_) => const AddSuccessPopup(message: 'User Added Successfully'),
        );
      } else {
        setState(() {
          _createBackendError = response.message;
        });
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  Widget _bottomButtons() {
    if (_step == _DialogStep.uploadDoc) return const SizedBox.shrink();

    return CustomElevatedButton(
      color: ColorManager.blueprime,
      height: AppSize.s30,
      width: AppSize.s120,
      text: 'Create',
      isLoading: isCreating,
      onPressed: _triggerCreate,
    );
  }

  // Below this width there's no comfortable room for this popup's fixed
  // 354px-wide fields — close it instead of letting it render broken.
  static const double _kDesignWidth = 855;

  // ─────────────────────────────────────────────────────────────
  // The upload-resume step is much shorter than the create-user step
  // (one line of text, a file picker, an optional error line, and two
  // buttons), so keeping the full create-user height around it just
  // left a big block of empty space at the bottom. This gives each
  // step its own height instead of reusing a single fixed one for both.
  // Tweak AppSize.s320 if you want it taller/shorter.
  // ─────────────────────────────────────────────────────────────
  double get _popupHeight =>
      _step == _DialogStep.uploadDoc ? AppSize.s310 : AppSize.s570;

  // ✅ Heading swaps per step: "Create User" while filling the form,
  // "Uploaded Resume" once a user's been created and we're on the
  // optional upload step. widget.title is only used as the create-step
  // label (falls back to it so callers passing a custom title for step
  // 1 still see it there); the upload step always shows "Uploaded Resume"
  // regardless of what the caller passed in.
  String get _popupTitle =>
      _step == _DialogStep.createUser ? widget.title : 'Upload Resume';

  @override
  Widget build(BuildContext context) {
    // If the window/screen is resized below the popup's design width, close
    // the popup instead of letting it render broken. Scheduled as a
    // post-frame callback since we can't call Navigator.pop synchronously
    // inside build(). PopScope's onPopInvoked below will still run
    // _guardReset() for this pop, same as any other dismissal path.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    // FIX: PopScope's onPopInvoked fires on every dismissal path for this
    // route — barrier tap (tapping outside), system back gesture/button,
    // and our own Navigator.pop calls (Skip, Submit, onClear) — so
    // _guardReset() is guaranteed to run and clear the shared controllers
    // no matter how the popup was closed. Without this, tapping outside
    // the popup skipped every button handler entirely and left whatever
    // was typed sitting in the controllers for the next open.
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) _guardReset();
      },
      child: DialogueTemplate(
        width: 410,
        height: _popupHeight,
        title: _popupTitle,
        color: ColorManager.blueprime,
        onClear: () {
          // Local UI state only — the shared controllers are cleared by
          // _guardReset() via onPopInvoked once this pop completes.
          selectedDeptId = FrontendConfigStore.data!.config.administrationId;

          setState(() {
            _createdUserId = null;
            displayFileName = "Choose file";
            pickedFileName = null;
            filePath = null;
            fileBytes = null;
            isFilePicked = false;
            _isFileTooLarge = false;
            isUploading = false;
            isCreating = false;
            _createBackendError = null;
            _uploadBackendError = null;

            _step = _DialogStep.createUser;
          });

          Navigator.pop(context);
        },
        body: _step == _DialogStep.createUser ? _createUserBody() : _uploadStepBody(),
        bottomButtons: _bottomButtons(),
      ),
    );
  }
}






///
