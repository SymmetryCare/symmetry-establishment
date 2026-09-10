import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/equipment_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_insurance_manager/device_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/equipment_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/device_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';

class EquipmentAddPopup extends StatefulWidget {
  final int employeeId;
  const EquipmentAddPopup({super.key, required this.employeeId});

  @override
  State<EquipmentAddPopup> createState() => _EquipmentAddPopupState();
}

TextEditingController idController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController calenderController = TextEditingController();

class _EquipmentAddPopupState extends State<EquipmentAddPopup> {
  bool isLoading = false;
  String? inventoryName;
  int inventoryId = 0;
  bool _isFormValid = true;
  String? _idDocError;
  String? _nameDocError;
  String? _dateDocError;
  String? _selectDocError;
  String? _categoryError;
  String selectDescription = 'Select';

  // FIX: tracks whether the Assign Date field's showDatePicker call is
  // currently open. showDatePicker pushes its own route ON TOP of this
  // popup's route, and Navigator.pop(context) always pops whatever is
  // topmost — so if the window is resized below _kDesignWidth while the
  // calendar is open, a single pop would only close the calendar and
  // leave this popup rendering broken underneath. Set true right before
  // showDatePicker is called and false right after it resolves (picked or
  // cancelled), so the resize handler in build() knows to pop the
  // calendar first.
  bool _isDatePickerOpen = false;

  late Future<List<SupplyOrderCategoryData>> _categoriesFuture;
  late Future<List<InventoryDropdownData>> _inventoryFuture; // ← cached
  String? selectedCategory;
  int? selectedCategoryId;

  final FocusNode _idFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descDropdownFocus = FocusNode();
  final FocusNode _categoryDropdownFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = getSupplyOrderCategories(context);
    _inventoryFuture = getDropdownInventory(context); // ← cached
    _idFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _nameFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _nameFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _descDropdownFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _descDropdownFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _categoryDropdownFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _categoryDropdownFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        FocusScope.of(context).unfocus();
        _validateForm();
        if (_isFormValid) _triggerAdd();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _idFocus.dispose();
    _nameFocus.dispose();
    _descDropdownFocus.dispose();
    _categoryDropdownFocus.dispose();
    super.dispose();
  }

  Future<void> _triggerAdd() async {
    setState(() => isLoading = true);
    var response = await addEquipment(
      context,
      inventoryId,
      calenderController.text,
      widget.employeeId,
      idController.text,
      inventoryName ?? '',
      nameController.text,
      selectedCategoryId!,
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) =>
            const AddSuccessPopup(message: 'Equipment Added Successfully'),
      );
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      Navigator.pop(context);
      showDialog(context: context, builder: (_) => const FourNotFourPopup());
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (_) => FailedPopup(text: response.message));
    }
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty || value == "Select") {
      _isFormValid = false;
      return fieldName;
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      _idDocError = _validateTextField(
          idController.text, 'Please enter id of the equipment. ');
      _nameDocError = _validateTextField(
          nameController.text, 'Please enter name of the equipment. ');
      _dateDocError =
          _validateTextField(calenderController.text, 'Please select date. ');
      _selectDocError = _validateTextField(
          selectDescription, 'Please select device description. ');
      if (selectedCategoryId == null) {
        _isFormValid = false;
        _categoryError = 'Please select a category. ';
      } else {
        _categoryError = null;
      }
    });
  }

  void clearControllerData() {
    inventoryId = 0;
    inventoryName = '';
    selectedCategory = null;
    selectedCategoryId = null;
    selectDescription = 'Select';
    nameController.clear();
    idController.clear();
    calenderController.clear();
  }

  // ─────────────────────────────────────────────────────────────
  // FIX: idController / nameController / calenderController are
  // top-level GLOBAL variables here, shared across every time this
  // popup is opened — not owned by this State. They were previously
  // only cleared inside onClear and the successful-Add path. But
  // showDialog's barrier is dismissible by default, so tapping
  // outside the popup pops the route directly without going through
  // either of those handlers — leaving whatever was typed still
  // sitting in the controllers, so the next "Add New Equipment" open
  // shows stale data instead of a fresh form.
  //
  // _guardReset() centralizes that cleanup, and PopScope's
  // onPopInvoked below runs it on EVERY dismissal path — barrier tap,
  // system back gesture/button, or our own Navigator.pop calls — so
  // the controllers are guaranteed empty before the popup can ever be
  // reopened. The _hasReset flag stops it firing twice when a button
  // already triggered a pop that also fires onPopInvoked.
  // ─────────────────────────────────────────────────────────────
  bool _hasReset = false;

  void _guardReset() {
    if (_hasReset) return;
    _hasReset = true;
    clearControllerData();
  }

  // Below this width there's no comfortable room for this popup's fixed
  // 350px-wide fields — close it instead of letting it render broken.
  static const double _kDesignWidth = 855;

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    // If the window/screen is resized below the popup's design width, close
    // the popup instead of letting it render broken. Scheduled as a
    // post-frame callback since we can't call Navigator.pop synchronously
    // inside build().
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
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

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) _guardReset();
      },
      child: DialogueTemplate(
        width: 900,
        height: AppSize.s560,
        title: "Add New Equipment",
        onClear: () {
          // Controller clearing now happens centrally in _guardReset()
          // via PopScope's onPopInvoked once this pop completes.
          Navigator.pop(context);
        },
        body: [
          FormDialogSection(
              title: 'Equipment Details',
              child: FormDialogGrid(columns: 3, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── ID ──────────────────────────────────────────────────────
                      FirstSMTextFConst(
                        controller: idController,
                        keyboardType: TextInputType.number,
                        text: 'Id',
                        focusNode: _idFocus,
                        onTapChange: (val) {
                          setState(() {
                            _isFormValid = true;
                            _idDocError = _validateTextField(idController.text,
                                'Please enter id of the equipment. ');
                          });
                        },
                      ),
                      _idDocError != null
                          ? Text(_idDocError!,
                              style: CommonErrorMsg.customTextStyle(context))
                          : const SizedBox(height: 12)
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Name ────────────────────────────────────────────────────
                      FirstSMTextFConst(
                        controller: nameController,
                        keyboardType: TextInputType.streetAddress,
                        text: 'Name',
                        focusNode: _nameFocus,
                        onTapChange: (val) {
                          setState(() {
                            _isFormValid = true;
                            _nameDocError = _validateTextField(
                                nameController.text,
                                'Please enter name of the equipment. ');
                          });
                        },
                      ),
                      _nameDocError != null
                          ? Text(_nameDocError!,
                              style: CommonErrorMsg.customTextStyle(context))
                          : const SizedBox(height: 12)
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Device Description ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Device Description",
                                style: FormDialogFields.labelStyle,
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: FormDialogFields.labelStyle
                                        .copyWith(color: ColorManager.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            FutureBuilder<List<InventoryDropdownData>>(
                              future: _inventoryFuture, // ← cached
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _dropdownPlaceholder();
                                }
                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return _dropdownEmpty('No available devices');
                                }
                                if (snapshot.hasData) {
                                  final items = snapshot.data!
                                      .map((i) => DropdownMenuItem<String>(
                                            value: i.name,
                                            child: Text(i.name),
                                          ))
                                      .toList();
                                  return CICCDropdown(
                                    initialValue: selectDescription,
                                    focusNode: _descDropdownFocus,
                                    // FIX: caps the dropdown menu's height so it
                                    // scrolls instead of growing unbounded once
                                    // there are more than ~4 items. Matches the
                                    // same constraintHeight pattern applied to
                                    // CICCDropdown elsewhere (Licenses tab,
                                    // AcknowledgementAddPopup, etc.).
                                    constraintHeight: 160,
                                    onChange: (val) {
                                      for (var a in snapshot.data!) {
                                        if (a.name == val) {
                                          setState(() {
                                            selectDescription = val;
                                            inventoryName = a.name;
                                            inventoryId = a.inventoryId;
                                            _isFormValid = true;
                                            _selectDocError = null;
                                          });
                                        }
                                      }
                                    },
                                    items: items,
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                      _selectDocError != null
                          ? Text(_selectDocError!,
                              style: CommonErrorMsg.customTextStyle(context))
                          : const SizedBox(height: 12)
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Category ────────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Category',
                                style: FormDialogFields.labelStyle,
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: FormDialogFields.labelStyle
                                        .copyWith(color: ColorManager.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            FutureBuilder<List<SupplyOrderCategoryData>>(
                              future: _categoriesFuture, // ← cached
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _dropdownPlaceholder();
                                }
                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return _dropdownEmpty(
                                      'No categories available');
                                }
                                if (snapshot.hasData) {
                                  final items = snapshot.data!
                                      .map((i) => DropdownMenuItem<String>(
                                            value: i.categoryName,
                                            child: Text(i.categoryName),
                                          ))
                                      .toList();
                                  return CICCDropdown(
                                    initialValue: selectedCategory,
                                    focusNode: _categoryDropdownFocus,
                                    // FIX: same scroll-cap fix as the Device
                                    // Description dropdown above.
                                    constraintHeight: 160,
                                    onChange: (val) {
                                      for (var a in snapshot.data!) {
                                        if (a.categoryName == val) {
                                          setState(() {
                                            selectedCategory = val;
                                            selectedCategoryId = a.categoryId;
                                            _categoryError = null;
                                          });
                                        }
                                      }
                                    },
                                    items: items,
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                      _categoryError != null
                          ? Text(_categoryError!,
                              style: CommonErrorMsg.customTextStyle(context))
                          : const SizedBox(height: AppSize.s4)
                    ])
              ])),
          FormDialogSection(
              title: 'Assignment Details',
              child: FormDialogGrid(columns: 3, children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Assign Date ──────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Assign Date",
                                style: FormDialogFields.labelStyle,
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: FormDialogFields.labelStyle
                                        .copyWith(color: ColorManager.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            FormField<String>(
                              builder: (FormFieldState<String> field) {
                                return SizedBox(
                                  width: 350,
                                  height: AppSize.s30,
                                  child: TextFormField(
                                    style:
                                        DocumentTypeDataStyle.customTextStyle(
                                            context),
                                    controller: calenderController,
                                    decoration: FormDialogFields.decoration(
                                        context,
                                        InputDecoration(
                                          focusColor: ColorManager.mediumgrey,
                                          hoverColor: ColorManager.mediumgrey,
                                          hintText: 'yyyy-mm-dd',
                                          hintStyle: DocumentTypeDataStyle
                                              .customTextStyle(context),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFB1B1B1),
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFB1B1B1),
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFB1B1B1),
                                                width: 1),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          suffixIcon: Icon(
                                              Icons.calendar_month_outlined,
                                              size: 18,
                                              color: ColorManager.blueprime),
                                          errorText: field.errorText,
                                        )),
                                    readOnly: true,
                                    onTap: () async {
                                      // FIX: mark the calendar as open so the
                                      // resize-close handler in build() knows to
                                      // pop it first if the window shrinks while
                                      // it's showing.
                                      _isDatePickerOpen = true;
                                      DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1100),
                                        lastDate: DateTime(2126),
                                      );
                                      _isDatePickerOpen = false;
                                      if (date != null) {
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(date);
                                        calenderController.text = formattedDate;
                                        field.didChange(formattedDate);
                                        setState(() {
                                          _isFormValid = true;
                                          _dateDocError = null;
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      _dateDocError != null
                          ? Text(_dateDocError!,
                              style: CommonErrorMsg.customTextStyle(context))
                          : const SizedBox(height: 12)
                    ])
              ]))
        ],
        bottomButtons: Center(
          child: CustomElevatedButton(
            color: ColorManager.blueprime,
            width: AppSize.s150,
            height: AppSize.s30,
            text: 'Add',
            isLoading: isLoading,
            onPressed: () async {
              _validateForm();
              if (_isFormValid) {
                setState(() => isLoading = true);
                var response = await addEquipment(
                  context,
                  inventoryId,
                  calenderController.text,
                  widget.employeeId,
                  idController.text,
                  inventoryName ?? '',
                  nameController.text,
                  selectedCategoryId!,
                );
                setState(() => isLoading = false);
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const AddSuccessPopup(
                        message: 'Equipment Added Successfully'),
                  );
                } else if (response.statusCode == 400 ||
                    response.statusCode == 404) {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (_) => const FourNotFourPopup());
                } else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => FailedPopup(text: response.message),
                  );
                }
                // Controller clearing now happens centrally in
                // _guardReset() via PopScope's onPopInvoked, triggered by
                // the Navigator.pop(context) calls above.
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _dropdownPlaceholder() {
    return Container(
      width: 350,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(' ', style: FormDialogFields.labelStyle),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
            child: Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  }

  Widget _dropdownEmpty(String msg) {
    return Container(
      width: 350,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
        borderRadius: BorderRadius.circular(FormDialogFields.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Text(msg, style: DocumentTypeDataStyle.customTextStyle(context)),
      ),
    );
  }
}
