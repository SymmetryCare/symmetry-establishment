import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

class AddEmployeementPopup extends StatefulWidget {
  final TextEditingController positionTitleController;
  final TextEditingController leavingResonController;
  final TextEditingController startDateContoller;
  final TextEditingController endDateController;
  final TextEditingController lastSupervisorNameController;
  final TextEditingController supervisorMobileNumber;
  final TextEditingController cityNameController;
  final TextEditingController employeerController;
  final TextEditingController emergencyMobileNumber;
  final TextEditingController countryController;
  final String tite;
  final VoidCallback onpressedClose;
  final Future<void> Function() onpressedSave;
  // ✅ REPLACED: `Widget checkBoxTile` is gone. It was built in the
  // CALLER's own StatefulBuilder, so tapping it only rebuilt that tiny
  // widget — never this popup. That's why the End Date field's
  // enabled/disabled state and hint never updated after a tap, and why
  // the checkbox could visually flip even when unrelated logic elsewhere
  // returned early. The popup now builds + owns the checkbox itself.
  final bool Function() isCurrentlyWorking;
  final void Function(bool) onCurrentlyWorkingChanged;

  const AddEmployeementPopup({
    super.key,
    required this.positionTitleController,
    required this.leavingResonController,
    required this.startDateContoller,
    required this.endDateController,
    required this.lastSupervisorNameController,
    required this.supervisorMobileNumber,
    required this.cityNameController,
    required this.employeerController,
    required this.emergencyMobileNumber,
    required this.onpressedSave,
    required this.tite,
    required this.onpressedClose,
    required this.countryController,
    required this.isCurrentlyWorking,
    required this.onCurrentlyWorkingChanged,
  });

  @override
  State<AddEmployeementPopup> createState() => _AddEmployeementPopupState();
}

class _AddEmployeementPopupState extends State<AddEmployeementPopup> {
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isLoading = false;

  // FIX: tracks whether either showDatePicker call below (start date or
  // end date) is currently open. showDatePicker pushes its own route ON
  // TOP of this popup's route, and Navigator.pop(context) always pops
  // whatever is topmost — so if the window is resized below the design
  // width while a calendar is open, a single pop would only close the
  // calendar and leave this popup rendering broken underneath. Set true
  // right before showDatePicker is called and false right after it
  // resolves (picked or cancelled) in both _selectDate and _selectEndDate,
  // so the resize handler in build() knows to pop the calendar first.
  bool _isDatePickerOpen = false;

  late final TextEditingController _positionTitleController;
  late final TextEditingController _leavingResonController;
  late final TextEditingController _startDateController;
  // End Date field uses widget.endDateController directly (no local copy)
  // so external clear()/writes are reflected immediately and vice versa.
  late final TextEditingController _lastSupervisorNameController;
  late final TextEditingController _supervisorMobileNumberController;
  late final TextEditingController _cityNameController;
  late final TextEditingController _employeerController;
  late final TextEditingController _emergencyMobileNumberController;
  late final TextEditingController _countryController;

  final FocusNode _positionFocus = FocusNode();
  final FocusNode _leavingReasonFocus = FocusNode();
  final FocusNode _supervisorNameFocus = FocusNode();
  final FocusNode _supervisorMobileFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _employerFocus = FocusNode();
  final FocusNode _emergencyMobileFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode nextFocus) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      nextFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Error states
  Map<String, bool> errorStates = {
    'positionTitle': false,
    'leavingReason': false,
    'startDate': false,
    'lastSupervisorName': false,
    'supervisorMobileNumber': false,
    'cityName': false,
    'employer': false,
    'emergencyMobileNumber': false,
    'countryname': false,
  };

  @override
  void initState() {
    super.initState();
    _positionTitleController =
        TextEditingController(text: widget.positionTitleController.text);
    _leavingResonController =
        TextEditingController(text: widget.leavingResonController.text);
    _startDateController =
        TextEditingController(text: widget.startDateContoller.text);
    _lastSupervisorNameController =
        TextEditingController(text: widget.lastSupervisorNameController.text);
    _supervisorMobileNumberController =
        TextEditingController(text: widget.supervisorMobileNumber.text);
    _cityNameController =
        TextEditingController(text: widget.cityNameController.text);
    _employeerController =
        TextEditingController(text: widget.employeerController.text);
    _emergencyMobileNumberController =
        TextEditingController(text: widget.emergencyMobileNumber.text);
    _countryController =
        TextEditingController(text: widget.countryController.text);

    _positionFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _leavingReasonFocus);
    _leavingReasonFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _supervisorNameFocus);
    _supervisorNameFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _supervisorMobileFocus);
    _supervisorMobileFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _cityFocus);
    _cityFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _employerFocus);
    _employerFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _emergencyMobileFocus);
    _emergencyMobileFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _countryFocus);
    _countryFocus.onKeyEvent = (node, event) {
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
    _positionTitleController.dispose();
    _leavingResonController.dispose();
    _startDateController.dispose();
    // widget.endDateController is owned/disposed by the parent
    // (EmploymentContainerConstant) — never dispose it here.
    _lastSupervisorNameController.dispose();
    _supervisorMobileNumberController.dispose();
    _cityNameController.dispose();
    _employeerController.dispose();
    _emergencyMobileNumberController.dispose();
    _countryController.dispose();
    _positionFocus.dispose();
    _leavingReasonFocus.dispose();
    _supervisorNameFocus.dispose();
    _supervisorMobileFocus.dispose();
    _cityFocus.dispose();
    _employerFocus.dispose();
    _emergencyMobileFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  // ✅ Single place that flips "Currently work here" — always called via
  // this popup's OWN setState, so the checkbox, the End Date field's
  // enabled state, its icon color, its hint text, AND the clearing of the
  // date all update together in the exact same rebuild. No more
  // out-of-sync UI between a separate checkbox widget and this popup.
  void _setCurrentlyWorking(bool value) {
    setState(() {
      widget.onCurrentlyWorkingChanged(value);
      if (value) {
        // Checking the box always clears whatever End Date was there.
        widget.endDateController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // If the window/screen is resized below the popup's design width (860),
    // the layout has no room to work with — close the popup instead of
    // letting it render broken. Scheduled as a post-frame callback since we
    // can't call Navigator.pop synchronously inside build().
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 860) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !Navigator.canPop(context)) return;
        // FIX: close whichever calendar dialog (start date or end date) is
        // open first — otherwise this pop closes the calendar (topmost
        // route) instead of the popup, leaving the broken-width popup
        // still on screen.
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    final bool currentlyWorking = widget.isCurrentlyWorking();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FormDialogSurface(
          width: 900,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FormDialogHeader(
              title: widget.tite,
              onClose: () {
                Navigator.pop(context);
                _clearControllers();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Employment Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _positionTitleController,
                        labelText: "Final Position Title",
                        errorKey: 'positionTitle',
                        errorMessage: 'Please enter title. ',
                        hintText: 'Enter Position Title',
                        focusNode: _positionFocus),
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _leavingResonController,
                        labelText: "Reason For Leaving",
                        errorKey: 'leavingReason',
                        errorMessage: 'Please enter leaving reason. ',
                        hintText: 'Enter Reason For Leaving',
                        focusNode: _leavingReasonFocus),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _startDateController,
                      labelText: "Start Date",
                      errorKey: 'startDate',
                      errorMessage: 'Please enter start date. ',
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: ColorManager.blueprime,
                        size: 22,
                      ),
                      onTap: () {
                        _selectDate(_startDateController, _selectedStartDate);
                        errorStates["startDate"] =
                            _startDateController.text.isEmpty;
                      },
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      isAsteric: false,
                      controller: widget.endDateController,
                      labelText: "End Date",
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: currentlyWorking
                            ? ColorManager.mediumgrey
                            : ColorManager.blueprime,
                        size: 22,
                      ),
                      // Blocked while checked — this stays in sync now
                      // because _setCurrentlyWorking rebuilds THIS popup.
                      onTap: currentlyWorking
                          ? null
                          : () => _selectEndDate(
                              widget.endDateController, _selectedEndDate),
                      hintText:
                          currentlyWorking ? 'Currently Working' : 'yyyy-mm-dd',
                    ),
                    CheckboxTile(
                      title: 'Currently work here',
                      initialValue: currentlyWorking,
                      onChanged: (value) {
                        _setCurrentlyWorking(value ?? !currentlyWorking);
                      },
                    )
                  ])),
              FormDialogSection(
                  title: 'Supervisor Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _lastSupervisorNameController,
                        labelText: "Last Supervisor's Name",
                        errorKey: 'lastSupervisorName',
                        errorMessage: 'Please enter supervisor name. ',
                        hintText: "Enter Supervisor's Name",
                        focusNode: _supervisorNameFocus),
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _supervisorMobileNumberController,
                        labelText: "Supervisor's Mobile Number",
                        errorKey: 'supervisorMobileNumber',
                        errorMessage: 'Please enter supervisor mobile number. ',
                        hintText: "Enter Mobile Number",
                        focusNode: _supervisorMobileFocus)
                  ])),
              FormDialogSection(
                  title: 'Employer and Contact Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _cityNameController,
                        labelText: AppString.city,
                        errorKey: 'cityName',
                        errorMessage: 'Please enter city name. ',
                        hintText: 'Enter City Name',
                        focusNode: _cityFocus),
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _employeerController,
                        labelText: "Employer",
                        errorKey: 'employer',
                        errorMessage: 'Please enter employer. ',
                        hintText: 'Enter Employer',
                        focusNode: _employerFocus),
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _emergencyMobileNumberController,
                        labelText: "Emergency Mobile Number",
                        errorKey: 'emergencyMobileNumber',
                        errorMessage: 'Please enter mobile number. ',
                        hintText: 'Enter Mobile Number',
                        focusNode: _emergencyMobileFocus),
                    _buildTextField(
                        capitalIsSelect: false,
                        controller: _countryController,
                        labelText: "Country Name",
                        errorKey: 'countryname',
                        errorMessage: 'Please enter country. ',
                        hintText: 'Enter Country Name',
                        focusNode: _countryFocus)
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
                      },
                    ),
                    const SizedBox(width: AppSize.s10),
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

  double _fieldWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth < 860 ? screenWidth * 0.9 : 860;
    final double availableWidth = dialogWidth - (25 * 2); // horizontal padding
    final double width =
        (availableWidth / 3) - 24; // leave room for spaceAround gaps
    return width.clamp(160.0, 240.0);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? errorKey,
    required String labelText,
    required String hintText,
    Widget? suffixIcon,
    required bool capitalIsSelect,
    bool isAsteric = true,
    VoidCallback? onTap,
    String? errorMessage,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: isAsteric,
        child: CustomTextFieldRegister(
          isDigitSelect: capitalIsSelect,
          phoneNumberField: errorKey == 'supervisorMobileNumber' ||
              errorKey == 'emergencyMobileNumber',
          height: AppSize.s30,
          focusNode: focusNode,
          width: _fieldWidth(context),
          controller: controller,
          keyboardType:
              TextInputType.phone, // Ensure it's phone input for number fields
          padding: const EdgeInsets.only(bottom: AppPadding.p5, left: 10),
          hintText: hintText,
          suffixIcon: suffixIcon,
          onTap: onTap,
          onChanged: (value) {
            setState(() {
              if (errorKey == 'supervisorMobileNumber' ||
                  errorKey == 'emergencyMobileNumber') {
                // Validate phone number fields
                String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                errorStates[errorKey!] = numericValue.length != 10;
              } else {
                // Validate other text fields
                errorStates[errorKey!] = value.isEmpty;
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMessage;
            }
            if (errorKey == 'supervisorMobileNumber' ||
                errorKey == 'emergencyMobileNumber') {
              String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (numericValue.length != 10) {
                return 'Please enter a valid 10-digit phone number. ';
              }
            }
            return null;
          },
        ),
        validation: errorStates[errorKey] == true
            ? Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Text(
                  errorMessage!,
                  style: CommonErrorMsg.customTextStyle(context),
                ),
              )
            : const SizedBox(
                height: 13,
              ));
  }

  void _handleSave() {
    setState(() {
      isLoading = true;
    });

    bool hasError = false;

    // Check if any of the fields have errors
    errorStates.forEach((key, _) {
      TextEditingController controller = controllerByErrorKey(key);

      if (key == 'supervisorMobileNumber' || key == 'emergencyMobileNumber') {
        // Validate phone number fields
        String numericValue = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (numericValue.length != 10) {
          errorStates[key] = true;
          hasError = true;
        } else {
          errorStates[key] = false;
        }
      } else {
        // Validate other text fields
        if (controller.text.isEmpty) {
          errorStates[key] = true;
          hasError = true;
        } else {
          errorStates[key] = false;
        }
      }
    });
    if (hasError) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Sync local values back into the caller-owned controllers right
    // before invoking the save callback, so the caller's repository/
    // manager layer sees the final entered values.
    widget.positionTitleController.text = _positionTitleController.text;
    widget.leavingResonController.text = _leavingResonController.text;
    widget.startDateContoller.text = _startDateController.text;
    // widget.endDateController is already the live field controller —
    // nothing to sync.
    widget.lastSupervisorNameController.text =
        _lastSupervisorNameController.text;
    widget.supervisorMobileNumber.text = _supervisorMobileNumberController.text;
    widget.cityNameController.text = _cityNameController.text;
    widget.employeerController.text = _employeerController.text;
    widget.emergencyMobileNumber.text = _emergencyMobileNumberController.text;
    widget.countryController.text = _countryController.text;

    // Proceed to save when no errors
    widget.onpressedSave();
  }

  TextEditingController controllerByErrorKey(String errorKey) {
    switch (errorKey) {
      case 'positionTitle':
        return _positionTitleController;
      case 'leavingReason':
        return _leavingResonController;
      case 'startDate':
        return _startDateController;
      case 'lastSupervisorName':
        return _lastSupervisorNameController;
      case 'supervisorMobileNumber':
        return _supervisorMobileNumberController;
      case 'cityName':
        return _cityNameController;
      case 'employer':
        return _employeerController;
      case 'emergencyMobileNumber':
        return _emergencyMobileNumberController;
      case 'countryname':
        return _countryController;
      default:
        return TextEditingController();
    }
  }

  void _clearControllers() {
    _positionTitleController.clear();
    _leavingResonController.clear();
    _startDateController.clear();
    widget.endDateController.clear();
    _lastSupervisorNameController.clear();
    _supervisorMobileNumberController.clear();
    _cityNameController.clear();
    _employeerController.clear();
    _emergencyMobileNumberController.clear();
    _countryController.clear();
  }

  Future<void> _selectDate(
      TextEditingController controller, DateTime selectedDate) async {
    // Start date: any date allowed (past or future)
    final DateTime firstDate = DateTime(1900);

    // FIX: mark the calendar as open so the resize-close handler in
    // build() knows to pop it first if the window shrinks while it's
    // showing.
    _isDatePickerOpen = true;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );
    _isDatePickerOpen = false;

    if (picked != null && picked != selectedDate) {
      setState(() {
        _selectedStartDate = picked;
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        errorStates["startDate"] = _startDateController.text.isEmpty;
      });
    }
  }

  Future<void> _selectEndDate(
      TextEditingController controller, DateTime selectedDate) async {
    // End date: only today or future dates
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    DateTime initialDate = selectedDate.isBefore(today) ? today : selectedDate;

    // FIX: mark the calendar as open so the resize-close handler in
    // build() knows to pop it first if the window shrinks while it's
    // showing.
    _isDatePickerOpen = true;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    _isDatePickerOpen = false;

    if (picked != null && picked != selectedDate) {
      setState(() {
        _selectedEndDate = picked;
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        // ✅ Safety net for the reverse case ("end date selected → don't
        // check the box"): picking a concrete end date always uncheck the
        // box. In practice onTap is already null while checked, so this
        // mainly guards against future code paths.
        widget.onCurrentlyWorkingChanged(false);
      });
    }
  }
}
