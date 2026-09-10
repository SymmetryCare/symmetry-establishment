import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employee_banking_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

// NEW: model used to read the per-field server validation errors, and the
// ApiData type EditBankingPopUp's onPressed now returns.
import 'package:symmetry_establishment/data/api_data/api_data.dart'; // adjust path

// Shared design-width threshold for the banking popups below. Below this
// width, the fixed-width fields (240/150px) laid out in Rows have no room
// to sit comfortably — close the popup instead of letting it render broken.
const double _kBankingPopupDesignWidth = 855;

class AddBankingPopup extends StatefulWidget {
  final int employeeID;
  final int banckId;
  const AddBankingPopup(
      {super.key, required this.employeeID, required this.banckId});

  @override
  State<AddBankingPopup> createState() => _AddBankingPopupState();
}

class _AddBankingPopupState extends State<AddBankingPopup> {
  bool fileAbove20Mb = false;
  String pickedFileName = '';
  String selectedtype = 'Checking';
  dynamic pickedFile;
  bool isLoading = false;
  TextEditingController effectivecontroller = TextEditingController();
  TextEditingController requestammount = TextEditingController();
  TextEditingController accountnumber = TextEditingController();
  TextEditingController routingnumber = TextEditingController();
  TextEditingController bankname = TextEditingController();
  TextEditingController verifyaccountnumber = TextEditingController();

  // FIX: tracks whether the Effective Date field's showDatePicker call is
  // currently open. showDatePicker pushes its own route ON TOP of this
  // popup's route, and Navigator.pop(context) always pops whatever is
  // topmost — so if the window is resized below _kBankingPopupDesignWidth
  // while the calendar is open, a single pop would only close the calendar
  // and leave this popup rendering broken underneath. Set true right
  // before showDatePicker is called and false right after it resolves
  // (picked or cancelled), so the resize handler in build() knows to pop
  // the calendar first.
  bool _isDatePickerOpen = false;

  // ---------------------------------------------------------------------
  // NEW: guards against custom text-field widgets re-firing onChanged with
  // an unchanged value during a rebuild — without this, a spurious re-fire
  // right after a server error sets e.g. _banknameError would immediately
  // recompute it back to null (since the field's current text is
  // non-empty), hiding the error the instant it appears. Keyed by the
  // same field-name strings used below ('bankname', 'routing', 'account',
  // 'verifyAccount', 'amount').
  // ---------------------------------------------------------------------
  final Map<String, String?> _lastKnownFieldValue = {};

  /// Maps the server's [ErrorDetail.key] values (matching the POST body
  /// field names sent to addNewEmployeeBanking) directly onto this
  /// popup's existing error-message variables. Unlike the Licenses/
  /// Reference popups, this one already stores each field's error as a
  /// plain `String?` rather than a shared map, so we can just assign
  /// directly.
  ///
  /// Returns true if at least one error was actually matched to a field.
  bool _applyServerFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return false;
    bool appliedAny = false;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'accountNumber':
            _acError = e.message;
            appliedAny = true;
            break;
          case 'bankName':
            _banknameError = e.message;
            appliedAny = true;
            break;
          case 'amountRequested':
            _amountError = e.message;
            appliedAny = true;
            break;
          case 'effectiveDate':
            _dateError = e.message;
            appliedAny = true;
            break;
          case 'routingNumber':
            _numberError = e.message;
            appliedAny = true;
            break;
          default:
            // NEW: surfaces the real key (e.g. 'type',
            // 'requestedPercentage', or any casing mismatch) so the
            // mapping above can be corrected.
            debugPrint('[AddBankingPopup] Unmapped field error key: '
                '"${e.key}" -> ${e.message}');
            break;
        }
      }
    });
    return appliedAny;
  }

  /// Shows a general (non-field-specific) server error by reusing the
  /// Account Number field's error slot — a duplicate-account-number
  /// uniqueness check is the most likely source of an unmapped/general
  /// banking error, so that's the most natural place for it to land.
  void _showGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      _numberError = message;
    });
  }

  Future<void> _handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final fileSize = result?.files.first.size; // File size in bytes
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      final file = result.files.first;
      setState(() {
        pickedFileName = file.name;
        pickedFile = file.bytes;
        fileAbove20Mb = !isAbove20MB;
        _pickFileError =
            _validateTextField(pickedFileName, 'Please upload document. ');
      });
    }
  }

  String? errorMessage;
  void validateAccounts() {
    setState(() {
      // Validate that the account numbers match

      if (accountnumber.text.isEmpty) {
        _isFormValid = false;
        _vacError = 'Account number cannot be empty. ';
      } else if (verifyaccountnumber.text.isEmpty) {
        _isFormValid = false;
        _vacError = 'Please verify your account number. ';
      } else if (accountnumber.text != verifyaccountnumber.text) {
        _isFormValid = false;
        errorMessage = 'Account numbers do not match. ';
      } else {
        errorMessage = null;
      }
    });
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
    // Add listeners to controllers
    accountnumber.addListener(validateAccounts);
    verifyaccountnumber.addListener(validateAccounts);

    // Focus chain: bankname → routing → account → verify → amount → save
    _banknameFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _routingFocus);
    _routingFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _accountFocus);
    _accountFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _verifyFocus);
    _verifyFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _amountFocus);
    _amountFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _triggerSave();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    accountnumber.dispose();
    verifyaccountnumber.dispose();
    _banknameFocus.dispose();
    _routingFocus.dispose();
    _accountFocus.dispose();
    _verifyFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  String? _PositionError;
  String? _dateError;
  String? _amountError;
  String? _numberError;
  String? _banknameError;
  String? _acError;
  String? _vacError;
  String? _pickFileError;

  bool _isFormValid = true;

  // Focus nodes — effectivecontroller is a date picker (tap-based), so it is
  // excluded from the keyboard focus chain.
  final FocusNode _banknameFocus = FocusNode();
  final FocusNode _routingFocus = FocusNode();
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _verifyFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "$fieldName";
    }
    return null;
  }

  void _validateFields() {
    setState(() {
      _isFormValid = true;
      _dateError =
          _validateTextField(effectivecontroller.text, 'Please enter date. ');
      _amountError =
          _validateTextField(requestammount.text, 'Please enter amount. ');
      _acError = _validateTextField(
          accountnumber.text, 'Please enter account number. ');
      _numberError =
          _validateTextField(routingnumber.text, 'Please enter number. ');
      _banknameError =
          _validateTextField(bankname.text, 'Please enter bank name. ');
      _vacError = _validateTextField(
          verifyaccountnumber.text, 'Please enter verify account number. ');
      _pickFileError =
          _validateTextField(pickedFileName, 'Please upload document. ');
      if (_acError == null && _vacError == null) {
        validateAccounts();
      }
    });
  }

  Future<void> _triggerSave() async {
    _validateFields();
    if (pickedFile != null) {
      if (!fileAbove20Mb) {
        setState(() {
          isLoading = false;
        });
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddErrorPopup(message: 'File is too large. ');
          },
        );
        return;
      }
    }
    if (_isFormValid) {
      setState(() {
        isLoading = true;
      });
      var response = await addNewEmployeeBanking(
        context: context,
        employeeId: widget.employeeID,
        accountNumber: accountnumber.text,
        bankName: bankname.text,
        amountRequested: int.parse(requestammount.text),
        checkUrl: '--',
        effectiveDate: effectivecontroller.text,
        routingNumber: routingnumber.text,
        percentage: '',
        type: selectedtype.toString(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await uploadBanckingDocument(
            context, response.banckingId!, pickedFile, pickedFileName!);
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddSuccessPopup(message: 'Banking Added Successfully');
          },
        );
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        // CHANGED: was showDialog(FailedPopup(...)). Now applies
        // per-field errors inline (falling back to the Account Number
        // slot for unmapped/general errors), and keeps the popup open
        // with the user's input intact instead of just showing a popup
        // with nothing indicating which field is at fault.
        bool appliedFieldErrors = false;
        if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
          appliedFieldErrors = _applyServerFieldErrors(response.fieldErrors!);
        }
        if (!appliedFieldErrors) {
          _showGeneralError(response.message);
        }
      } else {
        bool appliedFieldErrors = false;
        if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
          appliedFieldErrors = _applyServerFieldErrors(response.fieldErrors!);
        }
        if (!appliedFieldErrors) {
          _showGeneralError(response.message);
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kBankingPopupDesignWidth) {
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
              title: "Add Banking",
              onClose: () {
                Navigator.pop(context);
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Bank Details',
                  child: FormDialogGrid(columns: 3, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Type",
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            CustomRadioListTile(
                              title: 'Checking',
                              value: 'Checking',
                              groupValue: selectedtype,
                              onChanged: (value) {
                                setState(() {
                                  selectedtype = value!;
                                });
                              },
                            ),
                            CustomRadioListTile(
                              title: 'Savings',
                              value: 'Savings',
                              groupValue: selectedtype,
                              onChanged: (value) {
                                setState(() {
                                  selectedtype = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Effective Date',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextFieldRegister(
                          readOnly: true,
                          width: 240,
                          controller: effectivecontroller,
                          hintText: 'yyyy-mm-dd',
                          hintStyle: onlyFormDataStyle.customTextStyle(context),
                          height: 30,
                          suffixIcon: IconButton(
                            padding: const EdgeInsets.only(bottom: 2),
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Color(0xff50B5E5),
                              size: 22,
                            ),
                            onPressed: () async {
                              final now = DateTime.now();
                              final today =
                                  DateTime(now.year, now.month, now.day);

                              // FIX: mark the calendar as open so
                              // the resize-close handler in
                              // build() knows to pop it first if
                              // the window shrinks while it's
                              // showing.
                              _isDatePickerOpen = true;
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: today,
                                firstDate: today,
                                lastDate: DateTime(2035),
                              );
                              _isDatePickerOpen = false;
                              if (pickedDate != null) {
                                effectivecontroller.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                                setState(() {
                                  _isFormValid = true;
                                  _dateError = _validateTextField(
                                      effectivecontroller.text,
                                      'Please enter date. ');
                                });
                              }
                            },
                          ),
                        ),
                        _dateError != null
                            ? Text(
                                _dateError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(
                                height: 12,
                              )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Bank Name',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextFieldRegister(
                          width: 240,
                          controller: bankname,
                          focusNode: _banknameFocus,
                          hintText: 'Enter Bank Name',
                          onChanged: (value) {
                            // NEW: skip spurious rebuild-triggered
                            // re-fires with an unchanged value —
                            // otherwise this would silently clear
                            // a just-applied server error.
                            if (_lastKnownFieldValue['bankname'] == value)
                              return;
                            _lastKnownFieldValue['bankname'] = value;
                            setState(() {
                              _isFormValid = true;
                              _banknameError = _validateTextField(
                                  bankname.text, 'Please enter bank name. ');
                            });
                          },
                          hintStyle: onlyFormDataStyle.customTextStyle(context),
                          height: 30,
                        ),
                        _banknameError != null
                            ? Text(
                                _banknameError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(
                                height: 12,
                              ),
                      ],
                    )
                  ])),
              FormDialogSection(
                  title: 'Account Details',
                  child: FormDialogGrid(columns: 3, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Routing/Transit Number',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextFieldSSn(
                          keyboardType: TextInputType.number,
                          width: 240,
                          maxLength: 9,
                          focusNode: _routingFocus,
                          controller: routingnumber,
                          hintText: 'Enter Number',
                          onChanged: (value) {
                            if (_lastKnownFieldValue['routing'] == value)
                              return;
                            _lastKnownFieldValue['routing'] = value;
                            setState(() {
                              _isFormValid = true;
                              _numberError = _validateTextField(
                                  routingnumber.text, 'Please enter number. ');
                            });
                          },
                          hintStyle: onlyFormDataStyle.customTextStyle(context),
                          height: 30,
                        ),
                        _numberError != null
                            ? Text(
                                _numberError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(height: 12),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Account Number',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextFieldRegister(
                          keyboardType: TextInputType.number,
                          isDigitSelect: true,
                          width: 240,
                          focusNode: _accountFocus,
                          controller: accountnumber,
                          hintText: 'Enter AC Number',
                          onChanged: (value) {
                            if (_lastKnownFieldValue['account'] == value)
                              return;
                            _lastKnownFieldValue['account'] = value;
                            setState(() {
                              _isFormValid = true;
                              _acError = _validateTextField(accountnumber.text,
                                  'Please enter account number. ');
                            });
                          },
                          hintStyle: onlyFormDataStyle.customTextStyle(context),
                          height: 30,
                        ),
                        _acError != null
                            ? Text(
                                _acError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(height: 12),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Verify Account Number',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        CustomTextFieldRegister(
                          keyboardType: TextInputType.number,
                          isDigitSelect: true,
                          width: 240,
                          focusNode: _verifyFocus,
                          controller: verifyaccountnumber,
                          onChanged: (val) {
                            if (_lastKnownFieldValue['verifyAccount'] == val)
                              return;
                            _lastKnownFieldValue['verifyAccount'] = val;
                            setState(() {
                              _isFormValid = true;
                              _vacError = _validateTextField(
                                  verifyaccountnumber.text,
                                  'Please enter verify account number. ');
                            });
                          },
                          hintText: 'Enter AC Number',
                          hintStyle: onlyFormDataStyle.customTextStyle(context),
                          height: 30,
                        ),
                        _acError != null || errorMessage != null
                            ? Text(
                                _acError ?? errorMessage!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(height: 12),
                      ],
                    )
                  ])),
              FormDialogSection(
                  title: 'Deposit Details',
                  child: FormDialogGrid(columns: 1, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Specific Amount',
                            style: FormDialogFields.labelStyle,
                            children: [
                              TextSpan(
                                text: ' *',
                                style: FormDialogFields.labelStyle.copyWith(
                                  color: ColorManager.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            CustomTextFieldRegister(
                              keyboardType: TextInputType.number,
                              isDigitSelect: true,
                              width: 150,
                              focusNode: _amountFocus,
                              controller: requestammount,
                              prefixText: '\$',
                              onChanged: (value) {
                                if (_lastKnownFieldValue['amount'] == value)
                                  return;
                                _lastKnownFieldValue['amount'] = value;
                                setState(() {
                                  _isFormValid = true;
                                  _amountError = _validateTextField(
                                      requestammount.text,
                                      'Please enter amount. ');
                                });
                              },
                              prefixStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.s13,
                                color: ColorManager.mediumgrey,
                                decoration: TextDecoration.none,
                              ),
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                requestammount.clear();
                              },
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: AppSize.s12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.blueprime,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _amountError != null
                            ? Text(
                                _amountError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              )
                            : const SizedBox(height: 12),
                      ],
                    )
                  ])),
              FormDialogSection(
                  title: 'Supporting Document',
                  child: Row(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      pickedFileName == ""
                          ? const Offstage()
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: Text(
                                  pickedFileName,
                                  style: DocumentTypeDataStyle.customTextStyle(
                                      context),
                                ),
                              ),
                            ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: AppSize.s120,
                            height: 30,
                            child: ElevatedButton.icon(
                              onPressed: _handleFileUpload,
                              icon: const Icon(Icons.file_upload_outlined,
                                  color: Colors.white),
                              label: Text(
                                '  Upload',
                                style: BlueButtonTextConst.customTextStyle(
                                    context),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.blueprime,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          _pickFileError != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    _pickFileError!,
                                    style:
                                        CommonErrorMsg.customTextStyle(context),
                                  ),
                                )
                              : const SizedBox(
                                  height: 14,
                                )
                        ],
                      ),
                    ],
                  ))
            ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButtonTransparent(
                      text: "Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: AppSize.s10),
                    CustomElevatedButton(
                      width: 100,
                      text: "Save",
                      isLoading: isLoading,
                      onPressed: _triggerSave,
                    )
                  ],
                )),
          ])),
    );
  }
}

class EditBankingPopUp extends StatefulWidget {
  final int banckId;
  String? selectedType;
  final String title;
  final String documentName;
  // NEW: URL of the already-uploaded/prefilled document (e.g. checkUrl
  // from the prefill API response). Used to make the document name
  // tappable so it opens the file in a new tab.
  final String? documentUrl;
  final TextEditingController effectiveDateController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController verifyAccountController;
  final TextEditingController routingNumberController;
  final TextEditingController specificAmountController;

  // CHANGED: was `Future<void> Function(String) onPressed`. The caller
  // used to be responsible for calling PatchEmployeeBanking AND handling
  // the success/failure UI itself (Navigator.pop, FailedPopup, etc.) —
  // this popup had no way to show field-level errors or keep itself open
  // on a validation failure. Now the caller just calls PatchEmployeeBanking
  // and returns the ApiData; this popup reads the response and decides
  // what to show.
  final Future<ApiData> Function(String) onPressed;

  // NEW: called after this popup has already handled a genuine success
  // (closed itself, shown the success dialog) — use this to refresh the
  // list on the screen behind the popup.
  final Future<void> Function()? onSaved;

  EditBankingPopUp({
    super.key,
    required this.title,
    required this.onPressed,
    this.onSaved,
    this.selectedType,
    this.documentUrl,
    required this.effectiveDateController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.verifyAccountController,
    required this.routingNumberController,
    required this.specificAmountController,
    required this.banckId,
    required this.documentName,
  });

  @override
  State<EditBankingPopUp> createState() => _EditBankingPopUpState();
}

class _EditBankingPopUpState extends State<EditBankingPopUp> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _typeFieldKey = GlobalKey<FormFieldState<String>>();
  String? pickedFileName;
  // NEW: holds the URL to open when the document name is tapped. Seeded
  // from widget.documentUrl in initState. Cleared out whenever a new
  // file is picked via _handleFileUpload, since a freshly picked local
  // file has no remote URL yet — tapping it shouldn't open the old
  // document's stale link.
  String? checkFullUrl;
  dynamic pickedFile;
  bool rnumber = false;
  bool eDate = false;
  bool bankname = false;
  bool sac = false;
  bool ac = false;
  bool vac = false;

  // FIX: same calendar-open tracking as _AddBankingPopupState above — see
  // that class's comment for why this is needed before popping on resize.
  bool _isDatePickerOpen = false;

  // ---------------------------------------------------------------------
  // NEW: server-driven error messages, keyed the same as the bool flags
  // above ('rnumber', 'eDate', 'bankname', 'sac', 'ac', 'vac'). When set,
  // these override the generic "Please enter X" text under a field.
  // ---------------------------------------------------------------------
  final Map<String, String?> _serverErrorMessages = {
    'rnumber': null,
    'eDate': null,
    'bankname': null,
    'sac': null,
    'ac': null,
    'vac': null,
  };

  // NEW: same spurious-onChanged guard as AddBankingPopup — keyed by
  // labelText since that's what _buildTextField's shared onChanged
  // switches on.
  final Map<String, String?> _lastKnownFieldValue = {};

  /// Maps the server's [ErrorDetail.key] values (matching the PATCH body
  /// field names sent to PatchEmployeeBanking) onto this popup's fields.
  ///
  /// Returns true if at least one error was actually matched to a field.
  bool _applyServerFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return false;
    bool appliedAny = false;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'accountNumber':
            ac = true;
            _serverErrorMessages['ac'] = e.message;
            appliedAny = true;
            break;
          case 'bankName':
            bankname = true;
            _serverErrorMessages['bankname'] = e.message;
            appliedAny = true;
            break;
          case 'amountRequested':
            sac = true;
            _serverErrorMessages['sac'] = e.message;
            appliedAny = true;
            break;
          case 'effectiveDate':
            eDate = true;
            _serverErrorMessages['eDate'] = e.message;
            appliedAny = true;
            break;
          case 'routingNumber':
            rnumber = true;
            _serverErrorMessages['rnumber'] = e.message;
            appliedAny = true;
            break;
          default:
            debugPrint('[EditBankingPopUp] Unmapped field error key: '
                '"${e.key}" -> ${e.message}');
            break;
        }
      }
    });
    return appliedAny;
  }

  /// Shows a general (non-field-specific) server error by reusing the
  /// Account Number field's slot — same choice as AddBankingPopup, for
  /// consistency between the two.
  void _showGeneralError(String message) {
    if (!mounted) return;
    setState(() {
      ac = true;
      _serverErrorMessages['ac'] = message;
    });
  }

  /// Clears server-driven messages before a fresh submit so a stale
  /// message from a previous attempt doesn't linger under a field the
  /// user has since fixed.
  void _clearServerFieldErrors() {
    if (!mounted) return;
    setState(() {
      _serverErrorMessages.updateAll((key, value) => null);
    });
  }

  String? errorKey;
  String gropvalue = '';

  // Focus nodes — effectiveDateController is a date picker (tap-based), so it
  // is excluded from the keyboard focus chain.
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _routingFocus = FocusNode();
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _verifyFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode nextFocus) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      nextFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    gropvalue = widget.selectedType!;
    pickedFileName = widget.documentName;
    checkFullUrl = widget.documentUrl;
    super.initState();

    // Focus chain: bankName → routing → account → verify → amount → save
    _bankNameFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _routingFocus);
    _routingFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _accountFocus);
    _accountFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _verifyFocus);
    _verifyFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _amountFocus);
    _amountFocus.onKeyEvent = (node, event) {
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
    _bankNameFocus.dispose();
    _routingFocus.dispose();
    _accountFocus.dispose();
    _verifyFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  bool fileAbove20Mb = false;

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // Same auto-close-on-narrow-screen fix as AddBankingPopup above.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kBankingPopupDesignWidth) {
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
              title: "Edit Banking",
              onClose: () {
                Navigator.pop(context);
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Bank Details', child: _buildFirstColumn()),
              FormDialogSection(
                  title: 'Account Details', child: _buildSecondColumn()),
              FormDialogSection(
                  title: 'Deposit Details', child: _buildThirdColumn()),
              FormDialogSection(
                  title: 'Supporting Document', child: _buildHeaderWithUpload())
            ])),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildDialogActions(context)),
          ])),
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return FormDialogHeader(
      title: widget.title,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildHeaderWithUpload() {
    return Row(
      children: [
        const SizedBox(
          height: 5,
        ),
        // CHANGED: the file name is now wrapped in a GestureDetector
        // and colored blueprime — tapping it opens checkFullUrl (the
        // already-uploaded/prefilled document's URL) in a new tab.
        // Only does anything when checkFullUrl is set; if the user
        // has picked a new local file (see _handleFileUpload below),
        // checkFullUrl is cleared so a stale link can't be opened.
        pickedFileName == null
            ? const Offstage()
            : Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () async {
                      if (checkFullUrl != null && checkFullUrl!.isNotEmpty) {
                        downloadFile(
                          context: context,
                          fileUrl: checkFullUrl!,
                          documentName: pickedFileName!,
                          apiPath: DownloadDocumentRepository
                              .getEmployeeBankingsDocumentByFileName(),
                        );
                      }
                    },
                    child: Text(
                      pickedFileName!,
                      style: DocumentTypeDataStyle.customTextStyle(context)
                          .copyWith(color: ColorManager.blueprime),
                    ),
                  ),
                ),
              ),
        SizedBox(
          width: AppSize.s120,
          height: 30,
          child: ElevatedButton.icon(
            onPressed: _handleFileUpload,
            icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
            label: Text(
              '  Upload',
              style: BlueButtonTextConst.customTextStyle(context),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.blueprime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final fileSize = result?.files.first.size; // File size in bytes
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      final file = result.files.first;
      setState(() {
        pickedFileName = file.name;
        pickedFile = file.bytes;
        fileAbove20Mb = !isAbove20MB;
        // NEW: a freshly picked local file has no remote URL yet — clear
        // the old document's link so tapping the new name doesn't open
        // a stale file.
        checkFullUrl = null;
      });
    }
  }

  Widget _buildFirstColumn() {
    return FormDialogGrid(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type',
            style: FormDialogFields.labelStyle,
          ),
          FormField<String>(
            key: _typeFieldKey,
            initialValue: widget.selectedType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an account type. ';
              }
              return null;
            },
            builder: (state) {
              print("IIII:::::${gropvalue}");
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 260,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio(
                              value: 'Checking',
                              groupValue: gropvalue,
                              onChanged: (value) {
                                setState(() {
                                  gropvalue = value.toString();
                                  _typeFieldKey.currentState
                                      ?.didChange(value.toString());
                                });
                              },
                            ),
                            Text(
                              'Checking',
                              style: DocumentTypeDataStyle.customTextStyle(
                                  context),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 'Savings',
                              groupValue: gropvalue,
                              onChanged: (value) {
                                setState(() {
                                  gropvalue = value.toString();
                                  _typeFieldKey.currentState
                                      ?.didChange(value.toString());
                                });
                              },
                            ),
                            Text(
                              'Savings',
                              style: DocumentTypeDataStyle.customTextStyle(
                                  context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      _buildTextField(
        isDigitSelect: false,
        errorText: eDate
            ? (_serverErrorMessages['eDate'] ?? "Please enter effective date. ")
            : null,
        suffixIcon: IconButton(
          padding: const EdgeInsets.only(bottom: 2),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(
            Icons.calendar_month,
            color: Color(0xff50B5E5),
            size: 22,
          ),
          onPressed: _selectDate,
        ),
        controller: widget.effectiveDateController,
        labelText: 'Effective Date',
      ),
      _buildTextField(
        controller: widget.bankNameController,
        labelText: 'Bank Name',
        isDigitSelect: false,
        errorText: bankname
            ? (_serverErrorMessages['bankname'] ?? "Please enter bank name. ")
            : null,
        focusNode: _bankNameFocus,
      )
    ]);
  }

  Widget _buildSecondColumn() {
    return FormDialogGrid(children: [
      _buildTextField(
        isDigitSelect: true,
        controller: widget.routingNumberController,
        labelText: 'Routing Number/ Transit Number',
        errorText: rnumber
            ? (_serverErrorMessages['rnumber'] ??
                "Please enter routing number. ")
            : null,
        focusNode: _routingFocus,
      ),
      _buildTextField(
        isDigitSelect: true,
        controller: widget.accountNumberController,
        labelText: 'Account Number',
        errorText: ac
            ? (_serverErrorMessages['ac'] ?? "Please enter account number. ")
            : null,
        focusNode: _accountFocus,
      ),
      _buildTextField(
        isDigitSelect: true,
        controller: widget.verifyAccountController,
        labelText: 'Verify Account Number',
        errorText: vac
            ? (_serverErrorMessages['vac'] ??
                errorVerifyAccountMessage ??
                "Please enter verify account number. ")
            : null,
        focusNode: _verifyFocus,
      )
    ]);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // FIX: mark the calendar as open so the resize-close handler in
    // build() knows to pop it first if the window shrinks while it's
    // showing.
    _isDatePickerOpen = true;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2035),
    );
    _isDatePickerOpen = false;
    if (pickedDate != null) {
      widget.effectiveDateController.text =
          "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? errorText,
    Widget? suffixIcon,
    String? prefixText,
    TextStyle? prefixStyle,
    required bool isDigitSelect,
    VoidCallback? onTap,
    double? width,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          prefixText: prefixText,
          isDigitSelect: isDigitSelect,
          phoneNumberField: false,
          height: AppSize.s30,
          width: width ?? 240,
          focusNode: focusNode,
          controller: controller,
          keyboardType:
              labelText == "Phone" ? TextInputType.phone : TextInputType.text,
          padding: const EdgeInsets.only(bottom: AppPadding.p1, left: 2),
          suffixIcon: suffixIcon,
          onTap: onTap,
          onChanged: (value) {
            // NEW: skip spurious rebuild-triggered re-fires with an
            // unchanged value — see AddBankingPopup for the full
            // explanation of why this guard exists.
            if (_lastKnownFieldValue[labelText] == value) return;
            _lastKnownFieldValue[labelText] = value;

            setState(() {
              if (labelText == "Specific Amount") {
                sac = value.isEmpty;
                _serverErrorMessages['sac'] = null;
              }
              if (labelText == "Routing Number/ Transit Number") {
                rnumber = value.isEmpty;
                _serverErrorMessages['rnumber'] = null;
              }
              if (labelText == "Account Number") {
                ac = value.isEmpty;
                _serverErrorMessages['ac'] = null;
              }
              if (labelText == "Effective Date") {
                eDate = value.isEmpty;
                _serverErrorMessages['eDate'] = null;
              }
              if (labelText == "Bank Name") {
                bankname = value.isEmpty;
                _serverErrorMessages['bankname'] = null;
              }
              if (labelText == "Verify Account Number") {
                vac = value.isEmpty;
                _serverErrorMessages['vac'] = null;
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppString.enterText;
            }
            return null;
          },
        ),
        validation: errorText != null
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  errorText,
                  style: CommonErrorMsg.customTextStyle(context),
                ),
              )
            : const SizedBox(
                height: 13,
              ));
  }

  String? errorVerifyAccountMessage = "Account number does not match. ";

  void _handleSave() async {
    // NEW: clear any previously shown server field errors before a fresh
    // validation/submit pass.
    _clearServerFieldErrors();

    setState(() {
      isLoading = true;
      eDate = widget.effectiveDateController.text.isEmpty;
      bankname = widget.bankNameController.text.isEmpty;
      vac = widget.verifyAccountController.text.isEmpty;
      rnumber = widget.routingNumberController.text.isEmpty;
      sac = widget.specificAmountController.text.isEmpty;
      ac = widget.accountNumberController.text.isEmpty;

      if (widget.accountNumberController.text !=
          widget.verifyAccountController.text) {
        vac = true;
        errorVerifyAccountMessage;
      } else {
        errorVerifyAccountMessage = null;
      }
    });

    if (pickedFile != null) {
      if (!fileAbove20Mb) {
        setState(() {
          isLoading = false;
        });
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddErrorPopup(
              message: 'File is too large. ',
            );
          },
        );
        return;
      }
    }

    if (!rnumber &&
        !eDate &&
        !bankname &&
        !sac &&
        !ac &&
        !vac &&
        errorVerifyAccountMessage == null &&
        _typeFieldKey.currentState!.validate()) {
      // CHANGED: widget.onPressed now returns the ApiData response
      // instead of void, so this popup can read it and decide what to
      // do — apply field errors and stay open on failure, or close and
      // show success only on a genuine 200/201. Previously this always
      // proceeded to _clearControllers() in `finally` regardless of
      // whether the save actually succeeded.
      final response = await widget.onPressed(gropvalue);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (pickedFile != null) {
            await uploadBanckingDocument(
                context, widget.banckId, pickedFile, pickedFileName!);
          }
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddSuccessPopup(
                  message: 'Banking Edit Successfully');
            },
          );
          if (widget.onSaved != null) {
            await widget.onSaved!();
          }
        } finally {
          _clearControllers();
          setState(() {
            isLoading = false;
          });
        }
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        bool appliedFieldErrors = false;
        if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
          appliedFieldErrors = _applyServerFieldErrors(response.fieldErrors!);
        }
        if (!appliedFieldErrors) {
          _showGeneralError(response.message);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        bool appliedFieldErrors = false;
        if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
          appliedFieldErrors = _applyServerFieldErrors(response.fieldErrors!);
        }
        if (!appliedFieldErrors) {
          _showGeneralError(response.message);
        }
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildThirdColumn() {
    return Row(
      children: [
        _buildTextField(
          isDigitSelect: true,
          prefixText: '\$',
          controller: widget.specificAmountController,
          labelText: 'Specific Amount',
          errorText: sac
              ? (_serverErrorMessages['sac'] ??
                  "Please enter specific amount. ")
              : null,
          width: 150,
          focusNode: _amountFocus,
          prefixStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: FontSize.s13,
            color: ColorManager.mediumgrey,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            widget.specificAmountController.clear();
          },
          child: const Text(
            'Reset',
            style: TextStyle(
              fontSize: AppSize.s12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.blueprime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ).paddingOnly(top: 5),
      ],
    );
  }

  void _clearControllers() {
    widget.effectiveDateController.clear();
    widget.specificAmountController.clear();
    widget.bankNameController.clear();
    widget.routingNumberController.clear();
    widget.accountNumberController.clear();
    widget.verifyAccountController.clear();
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: Color(0xff575757),
    );
  }

  Widget _buildDialogActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 13, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButtonTransparent(
            text: "Cancel",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: AppSize.s13),
          CustomElevatedButton(
            width: 100,
            text: "Save",
            isLoading: isLoading,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
