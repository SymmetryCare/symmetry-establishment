import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/education_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';

// Design width both popups below are built for. If the window/screen shrinks
// below this, there's no room for a usable 3-column layout, so we close the
// popup instead of letting it render broken.
const double _kEducationPopupDesignWidth = 855;

class AddEducationPopup extends StatefulWidget {
  final TextEditingController collegeUniversityController;
  final TextEditingController phoneController;
  final TextEditingController calenderController;
  final TextEditingController cityController;
  final TextEditingController degreeController;
  final TextEditingController stateController;
  final TextEditingController majorSubjectController;
  final TextEditingController countryNameController;
  final VoidCallback onpressedClose;
  final int employeeId;
  final String title;

  const AddEducationPopup({
    super.key,
    required this.employeeId,
    required this.collegeUniversityController,
    required this.phoneController,
    required this.calenderController,
    required this.cityController,
    required this.degreeController,
    required this.stateController,
    required this.majorSubjectController,
    required this.countryNameController,
    required this.onpressedClose,
    required this.title,
  });

  @override
  State<AddEducationPopup> createState() => _AddEducationPopupState();
}

class _AddEducationPopupState extends State<AddEducationPopup> {
  final DateTime _selectedStartDate = DateTime.now();
  bool isLoading = false;
  bool _collegeUniversityError = false;
  bool _phoneError = false;
  bool _calendarError = false;
  bool _cityError = false;
  bool _degreeError = false;
  bool _stateError = false;
  bool _majorSubjectError = false;
  bool _countryNameError = false;
  bool _isRadioButtonSelected = false;

  // FIX: tracks whether showDatePicker's calendar dialog is currently open.
  // showDatePicker pushes its own route ON TOP of this popup's route, and
  // Navigator.pop(context) always pops whatever is topmost — so if the
  // window is resized below _kEducationPopupDesignWidth while the calendar
  // is open, a single pop would only close the calendar and leave this
  // popup rendering broken underneath. Set true right before showDatePicker
  // is called and false right after it resolves (picked or cancelled), so
  // the resize handler in build() knows to pop the calendar first.
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
  // the caller's controllers right before the save action runs.
  // ─────────────────────────────────────────────────────────────
  late final TextEditingController _collegeUniversityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _calenderController;
  late final TextEditingController _cityController;
  late final TextEditingController _degreeController;
  late final TextEditingController _stateController;
  late final TextEditingController _majorSubjectController;
  late final TextEditingController _countryNameController;

  final FocusNode _collegeFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _degreeFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _majorFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  // Error states
  Map<String, bool> errorStates = {
    'College/University': false,
    'phonenumber': false,
    'StartDate': false,
    'City': false,
    'Degree': false,
    'State': false,
    'majorsubject': false,
    'country': false,
  };
  String? expiryType = "No";

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
    _collegeUniversityController =
        TextEditingController(text: widget.collegeUniversityController.text);
    _phoneController = TextEditingController(text: widget.phoneController.text);
    _calenderController =
        TextEditingController(text: widget.calenderController.text);
    _cityController = TextEditingController(text: widget.cityController.text);
    _degreeController =
        TextEditingController(text: widget.degreeController.text);
    _stateController = TextEditingController(text: widget.stateController.text);
    _majorSubjectController =
        TextEditingController(text: widget.majorSubjectController.text);
    _countryNameController =
        TextEditingController(text: widget.countryNameController.text);

    _collegeFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _phoneFocus);
    _phoneFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _cityFocus);
    _cityFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _degreeFocus);
    _degreeFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _stateFocus);
    _stateFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _majorFocus);
    _majorFocus.onKeyEvent =
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
    _collegeUniversityController.dispose();
    _phoneController.dispose();
    _calenderController.dispose();
    _cityController.dispose();
    _degreeController.dispose();
    _stateController.dispose();
    _majorSubjectController.dispose();
    _countryNameController.dispose();
    _collegeFocus.dispose();
    _phoneFocus.dispose();
    _cityFocus.dispose();
    _degreeFocus.dispose();
    _stateFocus.dispose();
    _majorFocus.dispose();
    _countryFocus.dispose();
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
    if (screenWidth < _kEducationPopupDesignWidth) {
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
                Navigator.pop(context);
                _clearControllers();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Institution Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _collegeUniversityController,
                      labelText: "College/University",
                      errorKey: 'College/University',
                      hintText: 'Enter College/University',
                      focusNode: _collegeFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _phoneController,
                      labelText: "Phone",
                      errorKey: 'phonenumber',
                      hintText: 'Enter Phone Number',
                      focusNode: _phoneFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _cityController,
                      labelText: AppString.city,
                      errorKey: 'City',
                      hintText: 'Enter City',
                      focusNode: _cityFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _stateController,
                      labelText: AppString.state,
                      errorKey: 'State',
                      hintText: 'Enter State',
                      focusNode: _stateFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _countryNameController,
                      labelText: "Country Name",
                      errorKey: 'country',
                      hintText: 'Enter Country Name',
                      focusNode: _countryFocus,
                    )
                  ])),
              FormDialogSection(
                  title: 'Education Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _calenderController,
                      labelText: "Start Date",
                      errorKey: 'StartDate',
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: ColorManager.blueprime,
                        size: 22,
                      ),
                      onTap: () async {
                        // FIX: mark the calendar as open so the
                        // resize-close handler in build() knows to
                        // pop it first if the window shrinks while
                        // it's showing.
                        _isDatePickerOpen = true;
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        _isDatePickerOpen = false;
                        if (date != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);
                          _calenderController.text = formattedDate;
                          setState(() {
                            errorStates['StartDate'] = formattedDate.isEmpty;
                          });
                        }
                      },
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildTextField(
                      controller: _degreeController,
                      labelText: "Degree",
                      errorKey: 'Degree',
                      capitalIsSelect: false,
                      hintText: 'Enter Degree',
                      focusNode: _degreeFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _majorSubjectController,
                      labelText: "Major Subject",
                      errorKey: 'majorsubject',
                      hintText: 'Enter Major Subject',
                      focusNode: _majorFocus,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Graduate', style: FormDialogFields.labelStyle),
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return SizedBox(
                                width: 280,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomRadioListTile(
                                        value: "Yes",
                                        groupValue: expiryType,
                                        onChanged: (value) {
                                          setState(() {
                                            expiryType = value!;
                                          });
                                        },
                                        title: "Yes",
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomRadioListTile(
                                        value: "No",
                                        groupValue: expiryType,
                                        onChanged: (value) {
                                          setState(() {
                                            expiryType = value!;
                                          });
                                        },
                                        title: "No",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ])
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String errorKey,
    String? errorText,
    Widget? suffixIcon,
    required bool capitalIsSelect,
    VoidCallback? onTap,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          isDigitSelect: capitalIsSelect,
          phoneNumberField:
              labelText == "Phone", // Specify if this is the phone field
          height: AppSize.s30,
          controller: controller,
          hintText: hintText,
          focusNode: focusNode,
          keyboardType:
              labelText == "Phone" ? TextInputType.phone : TextInputType.text,
          padding: const EdgeInsets.only(bottom: AppPadding.p1, left: 2),
          suffixIcon: suffixIcon,
          onTap: onTap,
          onChanged: (value) {
            setState(() {
              if (value == null) {
                errorStates[errorKey] = value.isEmpty;
              } else {
                errorStates[errorKey] = value.isEmpty;
              }
              if (errorKey == 'phonenumber') {
                // Validate phone number fields
                String numericValue =
                    value.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
                errorStates[errorKey] = numericValue.length != 14;
              }
            });
          },
          validator: (value) {
            if (errorKey == 'Phone') {
              String numericValue =
                  value!.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
              if (numericValue.length != 14) {
                return 'Please enter a valid number. ';
              }
            }
            return null;
          },
        ),
        validation: errorStates[errorKey]!
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
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

  // Method to validate phone number with the USA phone mask
  bool _isPhoneValid(String phoneNumber) {
    // Define the regex pattern for (###) ###-####
    final RegExp phoneRegex = RegExp(r'^\(\d{3}\) \d{3}-\d{4}$');
    return phoneRegex.hasMatch(
        phoneNumber); // Checks if the phone number matches the pattern
  }

  void _handleSave() async {
    setState(() {
      errorStates['College/University'] =
          _collegeUniversityController.text.isEmpty;
      errorStates['phonenumber'] = !_isPhoneValid(
          _phoneController.text); // Update phone validation logic
      errorStates['StartDate'] = _calenderController.text.isEmpty;
      errorStates['City'] = _cityController.text.isEmpty;
      errorStates['Degree'] = _degreeController.text.isEmpty;
      errorStates['State'] = _stateController.text.isEmpty;
      errorStates['majorsubject'] = _majorSubjectController.text.isEmpty;
      errorStates['country'] = _countryNameController.text.isEmpty;
    });

    if (!errorStates.values.contains(true)) {
      try {
        setState(() {
          isLoading = true;
        });

        // Sync local values back into the caller-owned controllers before
        // using them, in case anything downstream still reads from those.
        widget.collegeUniversityController.text =
            _collegeUniversityController.text;
        widget.phoneController.text = _phoneController.text;
        widget.calenderController.text = _calenderController.text;
        widget.cityController.text = _cityController.text;
        widget.degreeController.text = _degreeController.text;
        widget.stateController.text = _stateController.text;
        widget.majorSubjectController.text = _majorSubjectController.text;
        widget.countryNameController.text = _countryNameController.text;

        var response = await addEmployeeEducation(
            context,
            widget.employeeId,
            expiryType.toString(),
            _degreeController.text,
            _majorSubjectController.text,
            _cityController.text,
            _collegeUniversityController.text,
            _phoneController.text,
            _stateController.text,
            _countryNameController.text,
            _calenderController.text);

        var educationResponse = await approveOnboardQualifyEducationPatch(
            context, response.educationId!);

        if (educationResponse.statusCode == 200 ||
            educationResponse.statusCode == 201) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddSuccessPopup(
                message: 'Education Added Successfully',
              );
            },
          );
        } else if (response.statusCode == 400 || response.statusCode == 404) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) => const FourNotFourPopup(),
          );
        } else {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                FailedPopup(text: response.message),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
        _clearControllers();
      }
    }
  }

  void _clearControllers() {
    _countryNameController.clear();
    _degreeController.clear();
    _majorSubjectController.clear();
    _stateController.clear();
    _cityController.clear();
    _phoneController.clear();
    _collegeUniversityController.clear();
    _calenderController.clear();
  }
}

/// Edit education
class EditEducationPopup extends StatefulWidget {
  final TextEditingController collegeUniversityController;
  final TextEditingController phoneController;
  final TextEditingController calenderController;
  final TextEditingController cityController;
  final TextEditingController degreeController;
  final TextEditingController stateController;
  final TextEditingController majorSubjectController;
  final TextEditingController countryNameController;
  final VoidCallback onpressedClose;
  Future<void> Function() onpressedSave;
  final String title;
  final Widget? radioButton;
  EditEducationPopup({
    super.key,
    required this.collegeUniversityController,
    required this.phoneController,
    required this.calenderController,
    required this.cityController,
    required this.degreeController,
    required this.stateController,
    required this.majorSubjectController,
    required this.countryNameController,
    required this.onpressedClose,
    required this.onpressedSave,
    this.radioButton,
    required this.title,
  });

  @override
  State<EditEducationPopup> createState() => _EditEducationPopupState();
}

class _EditEducationPopupState extends State<EditEducationPopup> {
  final DateTime _selectedStartDate = DateTime.now();
  bool isLoading = false;
  bool _collegeUniversityError = false;
  bool _phoneError = false;
  bool _calendarError = false;
  bool _cityError = false;
  bool _degreeError = false;
  bool _stateError = false;
  bool _majorSubjectError = false;
  bool _countryNameError = false;
  bool _isRadioButtonSelected = false;

  // FIX: same calendar-open tracking as _AddEducationPopupState above — see
  // that class's comment for why this is needed before popping on resize.
  bool _isDatePickerOpen = false;

  // Same self-owned-controller fix as AddEducationPopup above — see the
  // comment there for the full explanation of why this is needed.
  late final TextEditingController _collegeUniversityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _calenderController;
  late final TextEditingController _cityController;
  late final TextEditingController _degreeController;
  late final TextEditingController _stateController;
  late final TextEditingController _majorSubjectController;
  late final TextEditingController _countryNameController;

  final FocusNode _collegeFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _degreeFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _majorFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();

  // Error states
  Map<String, bool> errorStates = {
    'College/University': false,
    'phonenumber': false,
    'StartDate': false,
    'City': false,
    'Degree': false,
    'State': false,
    'majorsubject': false,
    'country': false,
  };

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
    _collegeUniversityController =
        TextEditingController(text: widget.collegeUniversityController.text);
    _phoneController = TextEditingController(text: widget.phoneController.text);
    _calenderController =
        TextEditingController(text: widget.calenderController.text);
    _cityController = TextEditingController(text: widget.cityController.text);
    _degreeController =
        TextEditingController(text: widget.degreeController.text);
    _stateController = TextEditingController(text: widget.stateController.text);
    _majorSubjectController =
        TextEditingController(text: widget.majorSubjectController.text);
    _countryNameController =
        TextEditingController(text: widget.countryNameController.text);

    _collegeFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _phoneFocus);
    _phoneFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _cityFocus);
    _cityFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _degreeFocus);
    _degreeFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _stateFocus);
    _stateFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _majorFocus);
    _majorFocus.onKeyEvent =
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
    _collegeUniversityController.dispose();
    _phoneController.dispose();
    _calenderController.dispose();
    _cityController.dispose();
    _degreeController.dispose();
    _stateController.dispose();
    _majorSubjectController.dispose();
    _countryNameController.dispose();
    _collegeFocus.dispose();
    _phoneFocus.dispose();
    _cityFocus.dispose();
    _degreeFocus.dispose();
    _stateFocus.dispose();
    _majorFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // Same auto-close-on-narrow-screen fix as AddEducationPopup above.
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kEducationPopupDesignWidth) {
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
                Navigator.pop(context);
                _clearControllers();
              },
            ),
            Flexible(
                child: FormDialogBody(children: [
              FormDialogSection(
                  title: 'Institution Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _collegeUniversityController,
                      labelText: "College/University",
                      errorKey: 'College/University',
                      hintText: 'Enter College/University',
                      focusNode: _collegeFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _phoneController,
                      labelText: "Phone",
                      errorKey: 'phonenumber',
                      hintText: 'Enter Phone Number',
                      focusNode: _phoneFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _cityController,
                      labelText: AppString.city,
                      errorKey: 'City',
                      hintText: 'Enter City',
                      focusNode: _cityFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _stateController,
                      labelText: AppString.state,
                      errorKey: 'State',
                      hintText: 'Enter State',
                      focusNode: _stateFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _countryNameController,
                      labelText: "Country Name",
                      errorKey: 'country',
                      hintText: 'Enter Country Name',
                      focusNode: _countryFocus,
                    )
                  ])),
              FormDialogSection(
                  title: 'Education Details',
                  child: FormDialogGrid(columns: 3, children: [
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _calenderController,
                      labelText: "Start Date",
                      errorKey: 'StartDate',
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        color: ColorManager.blueprime,
                        size: 22,
                      ),
                      onTap: () async {
                        // FIX: mark the calendar as open so the
                        // resize-close handler in build() knows to
                        // pop it first if the window shrinks while
                        // it's showing.
                        _isDatePickerOpen = true;
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        _isDatePickerOpen = false;
                        if (date != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);
                          _calenderController.text = formattedDate;
                          setState(() {
                            _calendarError = formattedDate.isEmpty;
                          });
                        }
                      },
                      hintText: 'yyyy-mm-dd',
                    ),
                    _buildTextField(
                      controller: _degreeController,
                      labelText: "Degree",
                      errorKey: 'Degree',
                      capitalIsSelect: false,
                      hintText: 'Enter Degree',
                      focusNode: _degreeFocus,
                    ),
                    _buildTextField(
                      capitalIsSelect: false,
                      controller: _majorSubjectController,
                      labelText: "Major Subject",
                      errorKey: 'majorsubject',
                      hintText: 'Enter Major Subject',
                      focusNode: _majorFocus,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Graduate',
                          style: FormDialogFields.labelStyle,
                        ),
                        widget.radioButton ?? const SizedBox.shrink(),
                      ],
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
                      onPressed: widget.onpressedClose,
                    ),
                    const SizedBox(width: AppSize.s10),
                    CustomElevatedButton(
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
    String? errorText,
    Widget? suffixIcon,
    required bool capitalIsSelect,
    VoidCallback? onTap,
    FocusNode? focusNode,
  }) {
    return FormDialogField(
        label: labelText,
        isRequired: true,
        child: CustomTextFieldRegister(
          isDigitSelect: capitalIsSelect,
          phoneNumberField:
              labelText == "Phone", // Specify if this is the phone field
          height: AppSize.s30,
          width: 240,
          controller: controller,
          hintText: hintText,
          focusNode: focusNode,
          keyboardType:
              labelText == "Phone" ? TextInputType.phone : TextInputType.text,
          padding: const EdgeInsets.only(bottom: AppPadding.p1, left: 2),
          suffixIcon: suffixIcon,
          onTap: onTap,
          onChanged: (value) {
            setState(() {
              if (value == null) {
                errorStates[errorKey] = value.isEmpty;
              } else {
                errorStates[errorKey] = value.isEmpty;
              }
              if (errorKey == 'phonenumber') {
                // Validate phone number fields
                String numericValue =
                    value.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
                errorStates[errorKey] = numericValue.length != 14;
              }
            });
          },
          validator: (value) {
            if (errorKey == 'Phone') {
              String numericValue =
                  value!.replaceAll(RegExp(r'^\(\d{4}\) \d{3}-\d{4}$'), '');
              if (numericValue.length != 14) {
                return 'Please enter a valid number. ';
              }
            }
            return null;
          },
        ),
        validation: errorStates[errorKey]!
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
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

  // Method to validate phone number with the USA phone mask
  bool _isPhoneValid(String phoneNumber) {
    // Define the regex pattern for (###) ###-####
    final RegExp phoneRegex = RegExp(r'^\(\d{3}\) \d{3}-\d{4}$');
    return phoneRegex.hasMatch(
        phoneNumber); // Checks if the phone number matches the pattern
  }

  void _handleSave() async {
    setState(() {
      errorStates['College/University'] =
          _collegeUniversityController.text.isEmpty;
      errorStates['phonenumber'] = !_isPhoneValid(
          _phoneController.text); // Update phone validation logic
      errorStates['StartDate'] = _calenderController.text.isEmpty;
      errorStates['City'] = _cityController.text.isEmpty;
      errorStates['Degree'] = _degreeController.text.isEmpty;
      errorStates['State'] = _stateController.text.isEmpty;
      errorStates['majorsubject'] = _majorSubjectController.text.isEmpty;
      errorStates['country'] = _countryNameController.text.isEmpty;
    });

    if (!errorStates.values.contains(true)) {
      try {
        setState(() {
          isLoading = true;
        });

        // Sync local values back into the caller-owned controllers before
        // invoking the save callback — widget.onpressedSave is provided by
        // the parent screen and presumably reads from these same controller
        // instances to build its save request.
        widget.collegeUniversityController.text =
            _collegeUniversityController.text;
        widget.phoneController.text = _phoneController.text;
        widget.calenderController.text = _calenderController.text;
        widget.cityController.text = _cityController.text;
        widget.degreeController.text = _degreeController.text;
        widget.stateController.text = _stateController.text;
        widget.majorSubjectController.text = _majorSubjectController.text;
        widget.countryNameController.text = _countryNameController.text;

        await widget.onpressedSave();
      } finally {
        setState(() {
          isLoading = false;
        });
        _clearControllers();
      }
    }
  }

  void _clearControllers() {
    _countryNameController.clear();
    _degreeController.clear();
    _majorSubjectController.clear();
    _stateController.clear();
    _cityController.clear();
    _phoneController.clear();
    _collegeUniversityController.clear();
    _calenderController.clear();
  }
}
