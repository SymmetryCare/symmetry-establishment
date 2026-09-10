import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/termination_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/termination_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

// Shared design-width threshold for the termination popups below. Below
// this width, the multi-column layouts (3-column form, timeline detail
// card) have no room to sit comfortably — close the popup instead of
// letting it render broken.
const double _kTerminationPopupDesignWidth = 855;

class TerminationHeadTabbar extends StatefulWidget {
  final int employeeId;
  final VoidCallback onTerminateSuccess;
  const TerminationHeadTabbar(
      {super.key, required this.onTerminateSuccess, required this.employeeId});

  @override
  State<TerminationHeadTabbar> createState() => _TerminationHeadTabbarState();
}

class _TerminationHeadTabbarState extends State<TerminationHeadTabbar> {
  TerminationDetailData? detailData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await getTerminationDetail(
        context: context,
        employeeId: widget.employeeId,
      );
      setState(() {
        detailData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading termination detail: $e");
    }
  }

  void _openTerminatePopup() {
    // FIX: compute the future once per call instead of inline inside the
    // dialog's builder, which re-fires the API call on every rebuild of
    // the dialog.
    final Future<TerminateEmployeePrefillData> terminationPrefillFuture =
        getTerminationEmployeePerfill(
      context: context,
      employeeId: widget.employeeId,
    );
    showDialog(
      context: context,
      builder: (_) => FutureBuilder<TerminateEmployeePrefillData>(
        future: terminationPrefillFuture,
        builder: (context, snapshotPrefill) {
          if (snapshotPrefill.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            );
          }
          if (snapshotPrefill.hasData) {
            return TerminatePopup(
              employeeId: widget.employeeId,
              preFillData: snapshotPrefill.data!,
              onSuccess: () {
                widget.onTerminateSuccess();
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

// ✅ NEW — single timeline row: blue check-circle + connecting line,
  // label on the left, bold value on the right. Matches the vertical
  // timeline design in the reference image.
  // ✅ FIX: line was `Expanded` inside an `IntrinsicHeight` Row — it
  // stretched to fill whatever height the label/value Row on the right
  // needed, which is what pushed an extra empty checkmark below the last
  // row (the Row content wasn't matching the line's stretched height).
  // Wrapped the icon+line in a SizedBox with a fixed height instead so the
  // spacing is predictable and doesn't depend on sibling content height.
  Widget _timelineRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + connecting line column ──────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: ColorManager.blueprime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
                Container(
                  height: 15,
                  width: 2,
                  color: ColorManager.blueprime,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSize.s16),

          // ── Label + value ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: CustomTextStylesCommon.commonStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Text(
                      value.isEmpty ? '--' : value,
                      style: CustomTextStylesCommon.commonStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: FontSize.s12,
                        color: ColorManager.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED — Last Working Date now wired to d.lastWorkingDay (real API
  // field), replacing the previous literal '--' placeholder.
  void _openTerminationDetailsPopup(TerminationDetailData d) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // If the window/screen is resized below the popup's design width,
        // close the popup instead of letting it render broken. Scheduled
        // as a post-frame callback since we can't call Navigator.pop
        // synchronously inside a builder. This builder isn't a State, so
        // we use `dialogContext.mounted` instead of `State.mounted`.
        // NOTE: this popup has no showDatePicker calls of its own (it's a
        // read-only timeline view), so no calendar-close tracking is
        // needed here — that's only relevant for TerminatePopup below.
        final double screenWidth = MediaQuery.of(dialogContext).size.width;
        if (screenWidth < _kTerminationPopupDesignWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          });
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            height: 385,
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ── Header bar — same styling as DialogueTemplate ────────────────
                Container(
                  decoration: BoxDecoration(
                    color: ColorManager.blueprime,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppPadding.p2, horizontal: AppPadding.p20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10),
                        child: Text(
                          'Termination Details',
                          style: PopupBlueBarText.customTextStyle(context),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: ColorManager.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Body — no bottomButtons section, no reserved bottom space ────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppPadding.p18,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _timelineRow(
                            context, 'Registration Date:', d.registrationDate),
                        _timelineRow(context, 'Offer Letter Acceptance Date:',
                            d.offerLetterAcceptanceDate),
                        _timelineRow(context, 'Onboarding Date:', d.dateofHire),
                        _timelineRow(context, 'Date of Resignation:',
                            d.dateofResignation),
                        _timelineRow(
                            context, 'Last Working Date:', d.lastWorkingDay),
                        _timelineRow(context, 'Date of Termination:',
                            d.dateofTermination),
                        _timelineRow(
                          context,
                          'Final Paycheck Date:',
                          d.checkDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fixed row height so the label and value columns stay aligned, matching
  /// the Banking and Qualifications cards.
  static const double _rowHeight = 34;
  static const double _buttonHeight = 35;

  Widget _labelText(BuildContext context, String text) {
    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: ManageCardLabelStyle.customTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _valueText(BuildContext context, String text) {
    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.isEmpty ? '--' : text,
          style: ManageCardValueStyle.customTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The same inset manage_screen's _scroll/_bounded helpers give the other
    // tabs, so Termination lines up with Banking and Qualifications.
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ColorManager.blueprime),
      );
    }

    // Not terminated — the toolbar button sits top-left like every other
    // tab's "+ Add New", over the empty-state illustration.
    if (detailData == null || detailData!.terminationFlag == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedActionButton(
            label: 'Terminate',
            icon: Icons.add,
            width: 130,
            height: _buttonHeight,
            fontSize: 13,
            onPressed: _openTerminatePopup,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: Image.asset(
                'images/hr_dashboard/termination.png',
                height: 250,
              ),
            ),
          ),
        ],
      );
    }

    final d = detailData!;
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terminated Successfully',
              style: ManageCardTitleStyle.customTextStyle(context)
                  .copyWith(color: ColorManager.greenDark),
            ),
            const SizedBox(height: 15),
            // Same responsive card grid as Banking and the Qualifications
            // tabs, so the single card is sized like a card in any of them.
            ManageCardGrid(children: [_detailCard(context, d)]),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(BuildContext context, TerminationDetailData d) {
    return CardDetails(
      childWidget: DetailsFormate(
        title: 'Termination Details',
        // The action rides in the title row, in the free space beside the
        // title — as the Banking and Employment cards do — so nothing sits
        // under the field columns.
        titleTrailing: SizedBox(
          height: _buttonHeight,
          child: OutlinedActionButton(
            label: 'View Employment History',
            trailingIcon: Icons.remove_red_eye_outlined,
            width: 215,
            height: _buttonHeight,
            fontSize: 13,
            onPressed: () => _openTerminationDetailsPopup(d),
          ),
        ),
        row1Child1: [
          const SizedBox(height: 5),
          _labelText(context, AppString.nameTermination),
          _labelText(context, 'Date of Termination :'),
          _labelText(context, 'Date of Resignation :'),
          _labelText(context, 'Date of Hire :'),
          _labelText(context, AppString.terminationStatus),
          _labelText(context, AppString.terminationPosition),
          _labelText(context, 'Phone No. :'),
          _labelText(context, 'Rehirable :'),
          _labelText(context, 'Final Address :'),
        ],
        row1Child2: [
          const SizedBox(height: 5),
          _valueText(context, '${d.firstName} ${d.lastName}'),
          _valueText(context, d.dateofTermination),
          _valueText(context, d.dateofResignation),
          _valueText(context, d.dateofHire),
          _valueText(context, d.status),
          _valueText(context, d.position),
          _valueText(context, d.primaryPhoneNbr),
          _valueText(context, d.rehirable),
          _valueText(context, d.finalAddress),
        ],
        row2Child1: [
          const SizedBox(height: 5),
          _labelText(context, AppString.terminationType),
          _labelText(context, 'Reason :'),
          _labelText(context, 'Final Paycheck :'),
          _labelText(context, AppString.terminationDate),
          _labelText(context, 'Gross Pay :'),
          _labelText(context, 'Net Pay :'),
          _labelText(context, 'Methods :'),
          _labelText(context, 'Materials :'),
        ],
        row2Child2: [
          const SizedBox(height: 5),
          _valueText(context, d.type),
          _valueText(context, d.reason),
          _valueText(context, '\$${d.finalPayCheck}'),
          _valueText(context, d.checkDate),
          _valueText(context, '\$${d.grossPay}'),
          _valueText(context, '\$${d.netPay}'),
          _valueText(context, d.methods),
          _valueText(context, d.materials),
        ],
        // Nothing under the field columns: the action moved up into the
        // title row, same as the Banking card.
        button: const SizedBox.shrink(),
      ),
    );
  }
}

///new popup
class TerminatePopup extends StatefulWidget {
  final int employeeId;
  final TerminateEmployeePrefillData preFillData;
  final VoidCallback? onSuccess;

  const TerminatePopup({
    super.key,
    required this.employeeId,
    required this.preFillData,
    this.onSuccess,
  });

  @override
  State<TerminatePopup> createState() => _TerminatePopupState();
}

class _TerminatePopupState extends State<TerminatePopup>
    with SingleTickerProviderStateMixin {
  TextEditingController terminationdatecltr = TextEditingController();
  TextEditingController namecltr = TextEditingController();
  TextEditingController resignationdatecltr = TextEditingController();
  TextEditingController dateofhirecltr = TextEditingController();
  TextEditingController materialscltr = TextEditingController();
  TextEditingController methodscltr = TextEditingController();
  TextEditingController rehirablecltr = TextEditingController();
  TextEditingController phonenocltr = TextEditingController();
  TextEditingController finaladdrescltr = TextEditingController();
  TextEditingController finalpaycheckcltr = TextEditingController();
  TextEditingController typecltr = TextEditingController();
  TextEditingController reasoncltr = TextEditingController();
  TextEditingController statuscltr = TextEditingController();
  TextEditingController positioncltr = TextEditingController();
  TextEditingController grosspaycltr = TextEditingController();
  TextEditingController netpaycltr = TextEditingController();
  TextEditingController datecltr = TextEditingController();
  TextEditingController resignationLetterCltr = TextEditingController();
  TextEditingController lastworkingdaycltr = TextEditingController();

  String? _nameError;
  String? _positionError;
  String? _finalAddressError;
  String? _finalPaycheckError;
  String? _netPayError;
  String? _terminationDateError;
  String? _dateOfHireError;
  String? _phoneError;
  String? _typeError;
  String? _paycheckDateError;
  String? _methodsError;
  String? _resignationDateError;
  String? _statusError;
  String? _rehirableError;
  String? _reasonError;
  String? _grossPayError;
  String? _materialsError;
  String? _fileError;
  String? _lastWorkingDayError;

  String displayFileName = "Upload Resignation Letter";
  String? pickedFileName;
  String? filePath;
  Uint8List? fileBytes;
  bool isFilePicked = false;
  bool _isSubmitting = false; // ✅ NEW — loader flag for Terminate button
  String? _serverError;

  late final AnimationController _errorAnimCtrl;
  late final Animation<Offset> _errorSlide;
  late final Animation<double> _errorFade;
  Timer? _errorTimer;

  bool _isDatePickerOpen = false;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _positionFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _finalPaycheckFocus = FocusNode();
  final FocusNode _netPayFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _typeFocus = FocusNode();
  final FocusNode _methodsFocus = FocusNode();
  final FocusNode _statusFocus = FocusNode();
  final FocusNode _rehirableFocus = FocusNode();
  final FocusNode _reasonFocus = FocusNode();
  final FocusNode _grossPayFocus = FocusNode();
  final FocusNode _materialsFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode nextFocus) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      nextFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _showServerError(String msg) {
    _errorTimer?.cancel();
    _errorAnimCtrl.reset();
    setState(() => _serverError = msg);
    _errorAnimCtrl.forward();
    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _serverError = null);
    });
  }

  @override
  void initState() {
    super.initState();
    _errorAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _errorSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _errorAnimCtrl, curve: Curves.easeOut));
    _errorFade = CurvedAnimation(parent: _errorAnimCtrl, curve: Curves.easeIn);

    terminationdatecltr.text = widget.preFillData.dateofTermination;
    namecltr.text = widget.preFillData.firstName;
    resignationdatecltr.text = widget.preFillData.dateofResignation;
    dateofhirecltr.text = widget.preFillData.dateofHire;
    materialscltr.text = widget.preFillData.materials;
    methodscltr.text = widget.preFillData.methods;
    rehirablecltr.text = widget.preFillData.rehirable;
    phonenocltr.text = widget.preFillData.primaryPhoneNbr;
    finaladdrescltr.text = widget.preFillData.finalAddress;
    finalpaycheckcltr.text = widget.preFillData.finalPayCheck.toString();
    typecltr.text = widget.preFillData.type;
    reasoncltr.text = widget.preFillData.reason;
    statuscltr.text = widget.preFillData.status;
    positioncltr.text = widget.preFillData.position;
    grosspaycltr.text = widget.preFillData.grossPay.toString();
    netpaycltr.text = widget.preFillData.netPay.toString();
    datecltr.text = widget.preFillData.checkDate;
    lastworkingdaycltr.text = widget.preFillData.lastWorkingDay == '--'
        ? ''
        : widget.preFillData.lastWorkingDay;

    _nameFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _positionFocus);
    _positionFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _addressFocus);
    _addressFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _finalPaycheckFocus);
    _finalPaycheckFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _netPayFocus);
    _netPayFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _phoneFocus);
    _phoneFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _typeFocus);
    _typeFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _methodsFocus);
    _methodsFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _statusFocus);
    _statusFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _rehirableFocus);
    _rehirableFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _reasonFocus);
    _reasonFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _grossPayFocus);
    _grossPayFocus.onKeyEvent =
        (node, event) => _handleEnterKey(event, _materialsFocus);
    _materialsFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _handleTerminate();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    terminationdatecltr.dispose();
    namecltr.dispose();
    resignationdatecltr.dispose();
    dateofhirecltr.dispose();
    materialscltr.dispose();
    methodscltr.dispose();
    rehirablecltr.dispose();
    phonenocltr.dispose();
    finaladdrescltr.dispose();
    finalpaycheckcltr.dispose();
    typecltr.dispose();
    reasoncltr.dispose();
    statuscltr.dispose();
    positioncltr.dispose();
    grosspaycltr.dispose();
    netpaycltr.dispose();
    datecltr.dispose();
    lastworkingdaycltr.dispose();
    resignationLetterCltr.dispose();
    _nameFocus.dispose();
    _positionFocus.dispose();
    _addressFocus.dispose();
    _finalPaycheckFocus.dispose();
    _netPayFocus.dispose();
    _phoneFocus.dispose();
    _typeFocus.dispose();
    _methodsFocus.dispose();
    _statusFocus.dispose();
    _rehirableFocus.dispose();
    _reasonFocus.dispose();
    _grossPayFocus.dispose();
    _materialsFocus.dispose();
    _errorAnimCtrl.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  String? _validateField(String value, String message) {
    if (value.trim().isEmpty) return message;
    return null;
  }

  bool _validateAll() {
    setState(() {
      _nameError = _validateField(namecltr.text, 'Please enter name. ');
      _positionError =
          _validateField(positioncltr.text, 'Please enter position. ');
      _finalAddressError =
          _validateField(finaladdrescltr.text, 'Please enter final address. ');
      _finalPaycheckError = _validateField(
          finalpaycheckcltr.text, 'Please enter final paycheck. ');
      _netPayError = _validateField(netpaycltr.text, 'Please enter net pay. ');
      _terminationDateError = _validateField(
          terminationdatecltr.text, 'Please select termination date. ');
      _dateOfHireError =
          _validateField(dateofhirecltr.text, 'Please select date of hire. ');
      _phoneError = _validateField(phonenocltr.text, 'Please enter phone no. ');
      _typeError = _validateField(typecltr.text, 'Please enter type. ');
      _paycheckDateError =
          _validateField(datecltr.text, 'Please enter final paycheck date. ');
      _methodsError =
          _validateField(methodscltr.text, 'Please enter methods. ');
      _resignationDateError = _validateField(
          resignationdatecltr.text, 'Please select resignation date. ');
      _statusError = _validateField(statuscltr.text, 'Please enter status. ');
      _rehirableError =
          _validateField(rehirablecltr.text, 'Please enter rehirable. ');
      _reasonError = _validateField(reasoncltr.text, 'Please enter reason. ');
      _grossPayError =
          _validateField(grosspaycltr.text, 'Please enter gross pay. ');
      _materialsError =
          _validateField(materialscltr.text, 'Please enter materials. ');
      _fileError = !isFilePicked ? 'Please upload resignation letter. ' : null;
      _lastWorkingDayError = _validateField(
          lastworkingdaycltr.text, 'Please select last working day. ');
    });

    return _nameError == null &&
        _positionError == null &&
        _finalAddressError == null &&
        _finalPaycheckError == null &&
        _netPayError == null &&
        _terminationDateError == null &&
        _dateOfHireError == null &&
        _phoneError == null &&
        _typeError == null &&
        _paycheckDateError == null &&
        _methodsError == null &&
        _resignationDateError == null &&
        _statusError == null &&
        _rehirableError == null &&
        _reasonError == null &&
        _grossPayError == null &&
        _materialsError == null &&
        _fileError == null &&
        _lastWorkingDayError == null;
  }

  Future<void> pickAckFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    setState(() {
      displayFileName = picked.name;
      pickedFileName = picked.name;
      resignationLetterCltr.text = picked.name;
      if (kIsWeb) {
        filePath = null;
        fileBytes = picked.bytes;
      } else {
        filePath = picked.path;
        fileBytes = picked.bytes;
      }
      isFilePicked = (fileBytes != null) || (!kIsWeb && filePath != null);
      if (isFilePicked) _fileError = null;
    });
  }

  // ✅ NEW — extracted submit logic so onPressed can guard with _isSubmitting
  Future<void> _handleTerminate() async {
    if (!_validateAll()) return;

    setState(() {
      _isSubmitting = true;
      _serverError =
          null; // ✅ NEW — clear any previous error on a fresh attempt
    });
    try {
      final result = await patchEmployeeTermination(
        context: context,
        employeeId: widget.employeeId,
        dateofTermination: terminationdatecltr.text,
        dateofResignation: resignationdatecltr.text,
        dateofHire: dateofhirecltr.text,
        lastWorkingDay: lastworkingdaycltr.text,
        rehirable: rehirablecltr.text,
        position: positioncltr.text,
        finalAddress: finaladdrescltr.text,
        type: typecltr.text,
        reason: reasoncltr.text,
        finalPayCheck: double.parse(finalpaycheckcltr.text),
        checkDate: datecltr.text,
        grossPay: double.parse(grosspaycltr.text),
        netPay: double.parse(netpaycltr.text),
        methods: methodscltr.text,
        materials: materialscltr.text,
        status: statuscltr.text,
      );

      if (!result.success) {
        // ✅ NEW — stop here on failure: show the server message above the
        // button, don't upload the resignation letter, don't close the
        // popup, don't fire onSuccess.
        _showServerError(result.message);
        return;
      }

      if (isFilePicked && fileBytes != null && pickedFileName != null) {
        final String base64String = base64Encode(fileBytes!);
        await uploadResignationLetterPost(
          context,
          widget.employeeId,
          base64String,
          pickedFileName!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess?.call();
      showDialog(
        context: context,
        builder: (context) => const AddSuccessPopup(
          message: 'Employee Terminated Successfully',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => FormDialogFields(
        child: Builder(builder: _buildForm),
      );

  Widget _buildForm(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kTerminationPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !Navigator.canPop(context)) return;
        if (_isDatePickerOpen) {
          Navigator.pop(context);
          _isDatePickerOpen = false;
        }
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    final dialogHeight = MediaQuery.of(context).size.height * 0.9;

    return TerminationDialogueTemplate(
      width: 900,
      height: dialogHeight,
      body: [
        FormDialogSection(
            title: 'Employee and Departure Details',
            child: FormDialogGrid(columns: 3, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: namecltr,
                  keyboardType: TextInputType.text,
                  text: 'Name',
                  focusNode: _nameFocus,
                  onChanged: () => setState(() => _nameError =
                      _validateField(namecltr.text, 'Please enter name. ')),
                ),
                _nameError != null
                    ? Text(_nameError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                InkWell(
                  onTap: pickAckFile,
                  child: FirstHRTextFConst(
                    controller: resignationLetterCltr,
                    keyboardType: TextInputType.text,
                    text: "Upload Resignation Letter",
                    readOnly: true,
                    icon: Icon(Icons.file_upload_outlined,
                        color: ColorManager.blueprime, size: 17),
                    onChange: () async => await pickAckFile(),
                  ),
                ),
                _fileError != null
                    ? Text(_fileError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: positioncltr,
                  keyboardType: TextInputType.text,
                  text: 'Position',
                  focusNode: _positionFocus,
                  onChanged: () => setState(() => _positionError =
                      _validateField(
                          positioncltr.text, 'Please enter position. ')),
                ),
                _positionError != null
                    ? Text(_positionError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: finaladdrescltr,
                  keyboardType: TextInputType.text,
                  text: 'Final Address',
                  focusNode: _addressFocus,
                  onChanged: () => setState(() => _finalAddressError =
                      _validateField(finaladdrescltr.text,
                          'Please enter final address. ')),
                ),
                _finalAddressError != null
                    ? Text(_finalAddressError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: finalpaycheckcltr,
                  keyboardType: TextInputType.text,
                  text: 'Final Paycheck',
                  focusNode: _finalPaycheckFocus,
                  onChanged: () => setState(() => _finalPaycheckError =
                      _validateField(finalpaycheckcltr.text,
                          'Please enter final paycheck. ')),
                ),
                _finalPaycheckError != null
                    ? Text(_finalPaycheckError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: netpaycltr,
                  keyboardType: TextInputType.text,
                  text: 'Net Pay',
                  focusNode: _netPayFocus,
                  onChanged: () => setState(() => _netPayError = _validateField(
                      netpaycltr.text, 'Please enter net pay. ')),
                ),
                _netPayError != null
                    ? Text(_netPayError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                FirstHRTextFConst(
                  controller: lastworkingdaycltr,
                  keyboardType: TextInputType.text,
                  text: 'Last Working Day',
                  readOnly: true,
                  icon: Icon(Icons.calendar_month_outlined,
                      color: ColorManager.blueprime, size: 18),
                  onChange: () async {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    _isDatePickerOpen = true;
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: today,
                      firstDate: today,
                      lastDate: DateTime(3101),
                    );
                    _isDatePickerOpen = false;
                    if (pickedDate != null) {
                      lastworkingdaycltr.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                      setState(() => _lastWorkingDayError = null);
                    }
                  },
                ),
                _lastWorkingDayError != null
                    ? Text(_lastWorkingDayError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12)
              ])
            ])),
        FormDialogSection(
            title: 'Exit Checklist',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FirstHRTextFConst(
                  controller: resignationdatecltr,
                  keyboardType: TextInputType.text,
                  text: 'Resignation Date',
                  readOnly: true,
                  icon: Icon(Icons.calendar_month_outlined,
                      color: ColorManager.blueprime, size: 18),
                  onChange: () async {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    _isDatePickerOpen = true;
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: today,
                      firstDate: DateTime(1900),
                      lastDate: today,
                    );
                    _isDatePickerOpen = false;
                    if (pickedDate != null) {
                      resignationdatecltr.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                      setState(() => _resignationDateError = null);
                    }
                  },
                ),
                _resignationDateError != null
                    ? Text(_resignationDateError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
                const SizedBox(height: 5),
                FirstHRTextFConst(
                  controller: statuscltr,
                  keyboardType: TextInputType.text,
                  text: 'Status',
                  focusNode: _statusFocus,
                  onChanged: () => setState(() => _statusError =
                      _validateField(statuscltr.text, 'Please enter status. ')),
                ),
                _statusError != null
                    ? Text(_statusError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
                const SizedBox(height: 5),
                FirstHRTextFConst(
                  controller: rehirablecltr,
                  keyboardType: TextInputType.text,
                  text: 'Rehirable',
                  focusNode: _rehirableFocus,
                  onChanged: () => setState(() => _rehirableError =
                      _validateField(
                          rehirablecltr.text, 'Please enter rehirable. ')),
                ),
                _rehirableError != null
                    ? Text(_rehirableError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
                const SizedBox(height: 5),
                FirstHRTextFConst(
                  controller: reasoncltr,
                  keyboardType: TextInputType.text,
                  text: 'Reason',
                  focusNode: _reasonFocus,
                  onChanged: () => setState(() => _reasonError =
                      _validateField(reasoncltr.text, 'Please enter reason. ')),
                ),
                _reasonError != null
                    ? Text(_reasonError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
                const SizedBox(height: 5),
                FirstHRTextFConst(
                  controller: grosspaycltr,
                  keyboardType: TextInputType.text,
                  text: 'Gross Pay',
                  focusNode: _grossPayFocus,
                  onChanged: () => setState(() => _grossPayError =
                      _validateField(
                          grosspaycltr.text, 'Please enter gross pay. ')),
                ),
                _grossPayError != null
                    ? Text(_grossPayError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
                const SizedBox(height: 5),
                FirstHRTextFConst(
                  controller: materialscltr,
                  keyboardType: TextInputType.text,
                  text: 'Materials',
                  focusNode: _materialsFocus,
                  onChanged: () => setState(() => _materialsError =
                      _validateField(
                          materialscltr.text, 'Please enter materials. ')),
                ),
                _materialsError != null
                    ? Text(_materialsError!,
                        style: CommonErrorMsg.customTextStyle(context))
                    : const SizedBox(height: 12),
              ],
            ))
      ],
      bottomButtons: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ NEW — server-side error from patchEmployeeTermination, shown
          // above the buttons until the next submit attempt clears it.
          if (_serverError != null)
            FadeTransition(
              opacity: _errorFade,
              child: SlideTransition(
                position: _errorSlide,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF5252).withValues(alpha: 0.15),
                              const Color(0xFFFF8A65).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: ColorManager.red.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: ColorManager.red, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _serverError!,
                              style: TextStyle(
                                color: ColorManager.red,
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () {
                                _errorTimer?.cancel();
                                setState(() => _serverError = null);
                              },
                              child: Icon(Icons.close,
                                  size: 14, color: ColorManager.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButtonTransparent(
                text: AppString.cancel,
                onPressed: _isSubmitting ? () {} : () => Navigator.pop(context),
              ),
              const SizedBox(width: 25),
              CustomElevatedButton(
                width: AppSize.s100,
                text: "Terminate",
                isLoading: _isSubmitting,
                onPressed: _handleTerminate,
              ),
            ],
          ),
        ],
      ),
      title: "Terminate",
    );
  }
}
