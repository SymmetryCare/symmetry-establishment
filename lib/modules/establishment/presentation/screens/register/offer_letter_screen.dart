import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/profile_editor/profile_editor.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/confirmation_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/offer_letter_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';

// ── Employee type IDs that must hide the "No. of Visit" field ────────────────
//   70 = QA Coordinator
//   71 = QA Manager
//   72 = Certified Coder
//   73 = Clinician Manager
const List<int> _kHideVisitEmployeeTypeIds = [70, 71, 72, 73];

// ── Offer-letter design tokens ──────────────────────────────────────────────
// Kept local to this screen so the dialog matches its design spec exactly
// without touching the app-wide theme constants.
const Color _kOfferBlue = Color(0xFF0B8CBF); // header bar + Enroll button
const Color _kOfferAccent = Color(0xFF1696C8); // badges + outlined accents
const Color _kFieldBorder = Color(0xFFD8DDE1); // input / dropdown border
const Color _kLabelColor = Color(0xFF2E3338); // field labels
const Color _kHintColor = Color(0xFF8A9199); // placeholder text
// Darker placeholder used where the design calls for it — the Visits field's
// "Enter Visits" and the Payment Mode "Salaried" value.
const Color _kDarkPlaceholderColor = Color(0xFF333333);
const Color _kCoverageHeaderBg = Color(0xFFEAF6FB);
const Color _kPillBg = Color(0xFFE3F1F9); // "Per day" pill inside Visits

/// Every piece of text inside this dialog renders in Fira Sans, matching the
/// app theme. Applying it once at the dialog root means descendants that don't
/// name a family — including the shared `*Style.customTextStyle()` helpers —
/// inherit it, instead of falling back to the platform font.

const TextStyle _kFieldLabelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: _kLabelColor,
  decoration: TextDecoration.none,
);

const TextStyle _kFieldTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: _kLabelColor,
  decoration: TextDecoration.none,
);

const TextStyle _kHintTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: _kHintColor,
  decoration: TextDecoration.none,
);

// Shared decoration so every card on this screen — date-fields, coverage,
// and payment mode — uses the exact same white rounded, bordered card style.

/// Field label with the optional red `*` required marker, so every label on
/// the form (date fields, Visits, County, Zone, Zip Codes) renders identically.
Widget _offerFieldLabel(String text, {bool isRequired = true}) {
  return Text.rich(
    TextSpan(
      text: text,
      style: _kFieldLabelStyle,
      children: isRequired
          ? [
              TextSpan(
                text: ' *',
                style: _kFieldLabelStyle.copyWith(color: ColorManager.red),
              ),
            ]
          : const <TextSpan>[],
    ),
  );
}

/// A read-only, input-shaped box used where a real field can't be shown yet
/// (e.g. Zip Codes before a county/zone is picked). Matches the height,
/// radius and border of the surrounding inputs so the row stays aligned.
Widget _offerPlaceholderBox(String text) {
  return Container(
    height: 32,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _kFieldBorder, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: _kHintTextStyle, overflow: TextOverflow.ellipsis),
  );
}

/// Returns true when the "No. of Visit" field should be hidden.
bool _hideVisitField({required int depId, required int clinicalId}) {
  // FrontendConfigStore.data can still be null here (see the same fix in
  // register_enroll_popup.dart) — read it defensively instead of crashing.
  final cfg = FrontendConfigStore.data?.config;
  if (cfg != null && (depId == cfg.salesId || depId == cfg.administrationId)) {
    return true;
  }
  if (_kHideVisitEmployeeTypeIds.contains(clinicalId)) return true;
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────

class OfferLetterScreen extends StatefulWidget {
  final String email;
  final int userId;
  final String role;
  final String status;
  final String firstName;
  final String lastName;
  final String position;
  final String phone;
  final String reportingOffice;
  final String services;
  final String employement;
  final int soecalityName;
  final int clinicalId;
  final int employeeEnrollId;
  final int employeeId;
  final int depId;
  final ApiData? apiData;
  final int cityId;
  final int countyId;
  final int zoneId;
  final int countryId;
  final String link;
  final String officeId;
  final Function() onRefreshRegister;

  const OfferLetterScreen({
    super.key,
    required this.email,
    required this.userId,
    required this.role,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.phone,
    required this.reportingOffice,
    required this.services,
    required this.employement,
    required this.soecalityName,
    required this.clinicalId,
    required this.employeeId,
    this.apiData,
    required this.onRefreshRegister,
    required this.depId,
    required this.cityId,
    required this.countyId,
    required this.zoneId,
    required this.link,
    required this.countryId,
    required this.officeId,
    required this.employeeEnrollId,
  });

  @override
  State<OfferLetterScreen> createState() => _OfferLetterScreenState();
}

class _OfferLetterScreenState extends State<OfferLetterScreen> {
  @override
  Widget build(BuildContext context) {
    final bool hideVisit =
        _hideVisitField(depId: widget.depId, clinicalId: widget.clinicalId);

    List<String> selectedCityName = [];
    final _formKey = GlobalKey<FormState>();

    TextEditingController issueDateController = TextEditingController();
    TextEditingController lastDateController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController verbalAcceptanceController = TextEditingController();
    TextEditingController patientsController = TextEditingController();
    TextEditingController _salaryController = TextEditingController();

    String selectedDropdownValue = 'Per day';
    String dropdownValue = 'Salaried';

    final providerState =
        Provider.of<HrEnrollOfferLatterProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      providerState.clearSalary();
      providerState.addContainer();
    });

    List<ApiAddCovrageData> addCovrage = [];

    return Consumer<HrEnrollOfferLatterProvider>(
        builder: (context, hrProviderState, state) {
      return Dialog(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: FormDialogSurface(
            width: 820,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Blue header bar ──────────────────────────────────
                FormDialogHeader(
                    title: 'Offer Letter Creation',
                    subtitle: null,
                    onClose: () {
                      hrProviderState.clearAllFields();
                      Navigator.of(context).pop();
                    }),

                // ── Scrollable body (non-scrolling horizontally — fixed
                // dialog width, grows vertically up to 90% of the screen
                // height and then scrolls, since coverage cards can be
                // added dynamically) ──────────────────────────────────
                Flexible(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Popup message heading ──────────────────────────────
                              const Padding(
                                padding: EdgeInsets.only(top: 0, bottom: 14),
                                child: FormDialogSectionTitle(
                                    "Kindly fill the required fields for offer letter creation."),
                              ),

                              // ── Row 1: Issue / Last / Start dates ─────────────────
                              FormDialogCard(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Column 1: Issue Date + Verbal Acceptance ──────
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstTextField(
                                            text: 'Issue Date',
                                            validationLabel: 'Issue Date',
                                            hintText: 'yyyy-mm-dd',
                                            isRequired: false,
                                            controller: issueDateController,
                                            errorText: hrProviderState.issueDate
                                                ? "Please enter issue date"
                                                : null,
                                          ),
                                          const SizedBox(height: 10),
                                          ConstTextField(
                                            hintText: 'yyyy-mm-dd',
                                            text: 'Verbal Acceptance',
                                            validationLabel:
                                                'Verbal Acceptance',
                                            controller:
                                                verbalAcceptanceController,
                                            errorText: hrProviderState
                                                    .verbalAcceptanceDate
                                                ? "Please enter Verbal Acceptance date"
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // ── Column 2: Last Date + No. of Visit ────────────
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstTextField(
                                            text: 'Last Date',
                                            validationLabel: 'Last Date',
                                            hintText: 'yyyy-mm-dd',
                                            controller: lastDateController,
                                            errorText: hrProviderState.lastDate
                                                ? "Please enter last date"
                                                : null,
                                          ),
                                          const SizedBox(height: 10),
                                          // ── No. of Visit: hidden for non-clinical roles ──
                                          if (hideVisit)
                                            const SizedBox(height: 30)
                                          else
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _offerFieldLabel('Visits'),
                                                const SizedBox(height: 6),
                                                StatefulBuilder(
                                                  builder: (BuildContext
                                                          context,
                                                      void Function(
                                                              void Function())
                                                          setState) {
                                                    // FIX: the unit selector used
                                                    // to be an InputDecoration
                                                    // suffixIcon, whose fixed
                                                    // width pushed this field
                                                    // wider than the date fields
                                                    // in the same column. Drawing
                                                    // the border on a Container
                                                    // and laying the (borderless)
                                                    // TextField + pill out inside
                                                    // it keeps every field in the
                                                    // card exactly the same width.
                                                    return Container(
                                                      height: 32,
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12,
                                                              right: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                _kFieldBorder,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              cursorColor:
                                                                  Colors.black,
                                                              controller:
                                                                  patientsController,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        r'^\d*\.?\d{0,2}$')),
                                                              ],
                                                              style:
                                                                  _kFieldTextStyle,
                                                              // ✅ clears the "No. of Visit" error the
                                                              // moment the user types something, mirroring
                                                              // how ConstTextField clears its own errors
                                                              // via validateFields on every keystroke.
                                                              onChanged:
                                                                  (value) {
                                                                if (hrProviderState
                                                                    .noOfPatientDate) {
                                                                  hrProviderState
                                                                      .validateVisitField(
                                                                    hideVisit:
                                                                        hideVisit,
                                                                    visitValue:
                                                                        value,
                                                                  );
                                                                }
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                isCollapsed:
                                                                    true,
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText:
                                                                    'Enter Visits',
                                                                hintStyle: _kHintTextStyle
                                                                    .copyWith(
                                                                        color:
                                                                            _kDarkPlaceholderColor),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          // The unit selector sits inside the field
                                                          // as a light-blue pill, per the design.
                                                          _VisitsUnitPill(
                                                            value:
                                                                selectedDropdownValue,
                                                            items: const [
                                                              'Per day',
                                                              'Per week',
                                                              'Per month',
                                                            ],
                                                            onChanged:
                                                                (String value) {
                                                              setState(() =>
                                                                  selectedDropdownValue =
                                                                      value);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (hrProviderState
                                                        .noOfPatientDate ==
                                                    true)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 1),
                                                    child: Text(
                                                      "Please enter no. of Visit",
                                                      style: CommonErrorMsg
                                                          .customTextStyle(
                                                              context),
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(height: 13),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // ── Column 3: Anticipated Start Date only ─────────
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ConstTextField(
                                            text: 'Anticipated Start Date',
                                            validationLabel:
                                                'Anticipated Start Date',
                                            hintText: 'yyyy-mm-dd',
                                            controller: startDateController,
                                            errorText: hrProviderState.startDate
                                                ? "Please enter anticipated start date"
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: 18),

                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: FormDialogSectionTitle("Add Coverage"),
                              ),

                              // ── Dynamic coverage containers ───────────────────────
                              Column(
                                children: hrProviderState.containerKeys
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  GlobalKey<_DynamciContainerState> key =
                                      entry.value;
                                  return DynamciContainer(
                                    key: key,
                                    index: index + 1,
                                    onRemove: () =>
                                        hrProviderState.removecontainer(key),
                                    officeId: widget.officeId,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 2),

                              // ── Add New Coverage button ────────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 34,
                                    child: OutlinedButton.icon(
                                      onPressed: hrProviderState.addContainer,
                                      icon: const Icon(
                                        Icons.add,
                                        color: _kOfferAccent,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Add New Coverage',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _kOfferAccent,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: _kOfferAccent),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Salary row ────────────────────────────────────────
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: FormDialogSectionTitle("Payment Mode"),
                              ),

                              FormDialogCard(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: _OfferDropdown(
                                            placeholder: 'Salaried',
                                            placeholderStyle:
                                                _kHintTextStyle.copyWith(
                                                    color:
                                                        _kDarkPlaceholderColor),
                                            initialValue: dropdownValue,
                                            items: (hideVisit
                                                    ? ['Salaried']
                                                    : ['Salaried', 'Per Visit'])
                                                .map((e) =>
                                                    DropdownMenuItem<String>(
                                                      value: e,
                                                      child: Text(e),
                                                    ))
                                                .toList(),
                                            onChange: (newValue) {
                                              setState(() {
                                                dropdownValue = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Thin rule separating the mode from
                                        // the amount, per the design.
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: const Color(0xffE3E3E3),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            hrProviderState.salary.isNotEmpty
                                                ? "\$ ${hrProviderState.salary}"
                                                : "Not Defined",
                                            style: hrProviderState
                                                    .salary.isNotEmpty
                                                ? _kFieldTextStyle.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  )
                                                : _kHintTextStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 96,
                                              height: 34,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                        ),
                                                        titlePadding:
                                                            EdgeInsets.zero,
                                                        title: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          width: 302,
                                                          height: 230,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 35,
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: ColorManager
                                                                      .blueprime,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            12.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12.0),
                                                                  ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5,
                                                                        bottom:
                                                                            5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Center(
                                                                      child:
                                                                          IconButton(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .close,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              IconSize.I18,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // ✅ FIX — Expanded gives this Padding a bounded height
                                                              // (230 - 35 header ≈ 195px) inside the outer Column.
                                                              // Without this, the Spacer() below has no bounded flex
                                                              // space to expand into and throws "RenderFlex children
                                                              // have non-zero flex but incoming height constraints
                                                              // are unbounded".
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          15.0,
                                                                      horizontal:
                                                                          16.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      dropdownValue ==
                                                                              'Salaried'
                                                                          ? Text(
                                                                              'Salary',
                                                                              style: DefineWorkWeekStyle.customTextStyle(context),
                                                                            )
                                                                          : Text(
                                                                              'Per Visit',
                                                                              style: DefineWorkWeekStyle.customTextStyle(context),
                                                                            ),
                                                                      const SizedBox(
                                                                          height:
                                                                              14),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _salaryController,
                                                                          cursorColor:
                                                                              Colors.black,
                                                                          style:
                                                                              DocumentTypeDataStyle.customTextStyle(context),
                                                                          decoration:
                                                                              InputDecoration(
                                                                            prefix:
                                                                                const Text("\$ "),
                                                                            hintText:
                                                                                '0.00',
                                                                            hintStyle:
                                                                                DocumentTypeDataStyle.customTextStyle(context),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              borderSide: const BorderSide(color: Color(0xff51B5E6), width: 1.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              borderSide: const BorderSide(color: Color(0xff51B5E6), width: 1.0),
                                                                            ),
                                                                            border:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              borderSide: const BorderSide(color: Color(0xff51B5E6), width: 1.0),
                                                                            ),
                                                                            contentPadding:
                                                                                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                                          ),
                                                                          keyboardType: const TextInputType
                                                                              .numberWithOptions(
                                                                              decimal: true),
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      // const SizedBox(height: 20),
                                                                      Center(
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            hrProviderState.addSalary(_salaryController.text);
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                ColorManager.blueprime,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                                                            child:
                                                                                Text(
                                                                              'Submit',
                                                                              style: BlueButtonTextConst.customTextStyle(context),
                                                                            ),
                                                                          ),
                                                                        ),
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
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      _kOfferAccent,
                                                  elevation: 0,
                                                  padding: EdgeInsets.zero,
                                                  side: const BorderSide(
                                                      color: _kOfferAccent),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                ),
                                                child: Text(
                                                  dropdownValue == 'Salaried'
                                                      ? '+ Add'
                                                      : '+ Add Visit',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: _kOfferAccent,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '*',
                                              style: _kFieldLabelStyle.copyWith(
                                                  color: ColorManager.red),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )),
                              const SizedBox(height: 20),
                              // ── Bottom buttons: Back + Enroll ────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 92,
                                    height: 34,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        hrProviderState.clearAllFields();
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: _kLabelColor,
                                        side: const BorderSide(
                                          color: Color(0xffDCE1E5),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: const Text(
                                        'Back',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _kLabelColor,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 92,
                                    height: 34,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (hrProviderState.salary.isEmpty) {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                const AddFailePopup(
                                                    message:
                                                        'Something is missing'),
                                          );
                                          return;
                                        }

                                        hrProviderState
                                            .validateFieldsUseController(
                                          issueDateController:
                                              issueDateController,
                                          startDateController:
                                              startDateController,
                                          lastDateController:
                                              lastDateController,
                                          verbalAcceptanceController:
                                              verbalAcceptanceController,
                                        );

                                        // ✅ Validate the "No. of Visit" field too — but
                                        // skip it entirely when hideVisit is true (the
                                        // field isn't even shown for those employee
                                        // types/departments), so it can never block
                                        // enrollment for roles that don't use it.
                                        hrProviderState.validateVisitField(
                                          hideVisit: hideVisit,
                                          visitValue: patientsController.text,
                                        );

                                        if (!hrProviderState.issueDate &&
                                            !hrProviderState.startDate &&
                                            !hrProviderState.lastDate &&
                                            !hrProviderState
                                                .verbalAcceptanceDate &&
                                            !hrProviderState.noOfPatientDate) {
                                          for (var key in hrProviderState
                                              .containerKeys) {
                                            final st = key.currentState!;
                                            addCovrage.add(ApiAddCovrageData(
                                              city: '',
                                              countyId: st.selectedCountyId,
                                              zoneId: st.docZoneId,
                                              zipCodes: st.zipCodes,
                                            ));
                                          }

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmationPopup(
                                                onCancel: () =>
                                                    Navigator.pop(context),
                                                onConfirm: () async {
                                                  String _buildErrorText(
                                                      ApiData response) {
                                                    if (response.fieldErrors !=
                                                            null &&
                                                        response.fieldErrors!
                                                            .isNotEmpty) {
                                                      // Join all field errors into one readable message, e.g.
                                                      // "primaryPhoneNbr: must be unique"
                                                      return response
                                                          .fieldErrors!
                                                          .map((e) => e.key
                                                                  .isNotEmpty
                                                              ? "${e.key}: ${e.message}"
                                                              : e.message)
                                                          .join('\n');
                                                    }
                                                    return response.message;
                                                  }

                                                  try {
                                                    final int patientsValue =
                                                        hideVisit
                                                            ? 0
                                                            : int.parse(
                                                                patientsController
                                                                    .text);

                                                    debugPrint(
                                                        '========== Employee Data ==========');
                                                    debugPrint(
                                                        'Employee ID: ${widget.employeeId}');
                                                    debugPrint(
                                                        'User ID: ${widget.userId}');
                                                    debugPrint(
                                                        'First Name: ${widget.firstName}');
                                                    debugPrint(
                                                        'Last Name: ${widget.lastName}');
                                                    debugPrint(
                                                        'Phone: ${widget.phone}');
                                                    debugPrint(
                                                        'Email: ${widget.email}');
                                                    debugPrint(
                                                        'Link: ${widget.link}');
                                                    debugPrint(
                                                        'Status: ${widget.status}');
                                                    debugPrint(
                                                        'Department ID: ${widget.depId}');
                                                    debugPrint(
                                                        'Position: ${widget.position}');
                                                    debugPrint(
                                                        'Speciality: ${widget.soecalityName}');
                                                    debugPrint(
                                                        'Clinician Type ID: ${widget.clinicalId}');
                                                    debugPrint(
                                                        'Reporting Office: ${widget.reportingOffice}');
                                                    debugPrint(
                                                        'Hide Visit: $hideVisit');
                                                    debugPrint(
                                                        '===================================');

                                                    ApiData response = widget
                                                                .employeeEnrollId ==
                                                            0
                                                        ? await addEmpEnroll(
                                                            context: context,
                                                            employeeId: widget
                                                                .employeeId,
                                                            code: "",
                                                            userId:
                                                                widget.userId,
                                                            firstName: widget
                                                                .firstName,
                                                            lastName:
                                                                widget.lastName,
                                                            phoneNbr:
                                                                widget.phone,
                                                            email: widget.email,
                                                            link: widget.link,
                                                            status:
                                                                widget.status,
                                                            departmentId:
                                                                widget.depId,
                                                            position:
                                                                widget.position,
                                                            speciality: widget
                                                                .soecalityName,
                                                            clinicianTypeId:
                                                                widget
                                                                    .clinicalId,
                                                            reportingOfficeId:
                                                                widget
                                                                    .reportingOffice,
                                                            cityId:
                                                                widget.cityId,
                                                            countryId: widget
                                                                .countryId,
                                                            countyId:
                                                                widget.countyId,
                                                            zoneId:
                                                                widget.zoneId,
                                                            employment: widget
                                                                .employement,
                                                            service:
                                                                widget.services,
                                                          )
                                                        : await patchEmpEnroll(
                                                            context: context,
                                                            employeeId: widget
                                                                .employeeId,
                                                            code: "",
                                                            userId:
                                                                widget.userId,
                                                            firstName: widget
                                                                .firstName,
                                                            lastName:
                                                                widget.lastName,
                                                            phoneNbr:
                                                                widget.phone,
                                                            email: widget.email,
                                                            link: widget.link,
                                                            status: "Opened",
                                                            departmentId:
                                                                widget.depId,
                                                            position:
                                                                widget.position,
                                                            speciality: widget
                                                                .soecalityName,
                                                            clinicianTypeId:
                                                                widget
                                                                    .clinicalId,
                                                            reportingOfficeId:
                                                                widget
                                                                    .reportingOffice,
                                                            cityId:
                                                                widget.cityId,
                                                            countryId: widget
                                                                .countryId,
                                                            countyId:
                                                                widget.countyId,
                                                            zoneId:
                                                                widget.zoneId,
                                                            employment: widget
                                                                .employement,
                                                            service:
                                                                widget.services,
                                                            employeeEnrollId: widget
                                                                .employeeEnrollId,
                                                          );

                                                    if (response.statusCode ==
                                                            200 ||
                                                        response.statusCode ==
                                                            201) {
                                                      widget
                                                          .onRefreshRegister();

                                                      var empEnrollOfferResponse =
                                                          await addEmpEnrollOffers(
                                                        context,
                                                        response
                                                            .employeeEnrollId!,
                                                        response.employeeId!,
                                                        patientsValue,
                                                        issueDateController
                                                            .text,
                                                        lastDateController.text,
                                                        startDateController
                                                            .text,
                                                        verbalAcceptanceController
                                                            .text,
                                                      );

                                                      await addEmpEnrollAddCoverage(
                                                        context,
                                                        response
                                                            .employeeEnrollId!,
                                                        response.employeeId!,
                                                        addCovrage,
                                                      );

                                                      await addEmpEnrollAddCompensation(
                                                        context,
                                                        response
                                                            .employeeEnrollId!,
                                                        response.employeeId!,
                                                        dropdownValue
                                                            .toString(),
                                                        int.parse(
                                                            hrProviderState
                                                                .salary!),
                                                      );

                                                      issueDateController
                                                          .clear();
                                                      lastDateController
                                                          .clear();
                                                      startDateController
                                                          .clear();
                                                      verbalAcceptanceController
                                                          .clear();

                                                      Navigator.pop(context);

                                                      if (empEnrollOfferResponse
                                                                  .statusCode ==
                                                              200 ||
                                                          empEnrollOfferResponse
                                                                  .statusCode ==
                                                              201) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            Future.delayed(
                                                              const Duration(
                                                                  seconds: 2),
                                                              () {
                                                                if (Navigator.of(
                                                                        context)
                                                                    .canPop()) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  hrProviderState
                                                                      .clearAllFields();
                                                                  hrProviderState
                                                                      .popNavigation(
                                                                          context);
                                                                }
                                                              },
                                                            );
                                                            return const offerSuccessPopup(
                                                                message:
                                                                    'Employee Enrolled Successfully.');
                                                          },
                                                        );
                                                      } else if (empEnrollOfferResponse
                                                                  .statusCode ==
                                                              400 ||
                                                          empEnrollOfferResponse
                                                                  .statusCode ==
                                                              404) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              FailedPopup(
                                                                  text: empEnrollOfferResponse
                                                                      .message),
                                                        );
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              FailedPopup(
                                                                  text: empEnrollOfferResponse
                                                                      .message),
                                                        );
                                                      }
                                                    } else {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            FailedPopup(
                                                          text: _buildErrorText(
                                                              response),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        "Error during enrollment: $e");
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          FailedPopup(
                                                              text:
                                                                  "Error during enrollment: $e"),
                                                    );
                                                  }
                                                },
                                                title: 'Confirm Enrollment',
                                                containerText:
                                                    'Do you really want to enroll?',
                                              );
                                            },
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kOfferBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                      ),
                                      child: const Text(
                                        'Enroll',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ConstTextField widget
// ─────────────────────────────────────────────────────────────────────────────

class ConstTextField extends StatefulWidget {
  final TextEditingController controller;
  final String validationLabel;
  final String text;
  final String hintText;
  final String? errorText;

  /// Issue Date is the only optional field on this form, so the red `*`
  /// marker is opt-out rather than always-on.
  final bool isRequired;
  VoidCallback? onTap;

  ConstTextField({
    super.key,
    required this.controller,
    this.errorText,
    required this.validationLabel,
    required this.text,
    required this.hintText,
    this.isRequired = true,
    this.onTap,
  });

  @override
  State<ConstTextField> createState() => _ConstTextFieldState();
}

class _ConstTextFieldState extends State<ConstTextField> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HrEnrollOfferLatterProvider>(
        builder: (context, hrProviderState, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _offerFieldLabel(widget.text, isRequired: widget.isRequired),
          const SizedBox(height: 6),
          CustomTextFieldOfferScreen(
            hintText: widget.hintText,
            height: 32,
            controller: widget.controller,
            onChanged: (value) {
              hrProviderState.validateFields(
                  validationLabel: widget.validationLabel, value: value);
            },
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(3000),
              );
              if (pickedDate != null) {
                widget.controller.text =
                    "${pickedDate.toLocal()}".split(' ')[0];
                // ✅ Setting controller.text directly does NOT fire
                // onChanged (that only fires on typed keystrokes), so
                // the "Please enter ..." error never cleared when a
                // date was picked from the calendar — only when typed
                // manually. Explicitly re-validate here so picking a
                // date clears the error the same way typing does.
                hrProviderState.validateFields(
                    validationLabel: widget.validationLabel,
                    value: widget.controller.text);
              }
            },
          ),
          widget.errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    widget.errorText!,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                )
              : const SizedBox(height: 13),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CheckBoxTileConst widget
// ─────────────────────────────────────────────────────────────────────────────

class CheckBoxTileConst extends StatelessWidget {
  final String text;
  bool value;
  ValueChanged<bool?> onChanged;

  CheckBoxTileConst({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? ColorManager.blueprime : const Color(0xffD9D9D9),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: ColorManager.white,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    splashRadius: 0,
                    value: value,
                    onChanged: onChanged,
                    activeColor: ColorManager.blueprime,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    text,
                    softWrap: false,
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DynamciContainer widget
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// _VisitsUnitPill — the "Per day ⌄" pill that sits inside the Visits field
// ─────────────────────────────────────────────────────────────────────────────

class _VisitsUnitPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _VisitsUnitPill({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final String? result = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              // Right-aligned to the pill so the menu doesn't hang off the
              // edge of the field.
              left: offset.dx - (120 - size.width),
              top: offset.dy + size.height + 4,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items
                        .map((item) => ListTile(
                              dense: true,
                              title: Text(item, style: _kFieldTextStyle),
                              onTap: () => Navigator.of(context).pop(item),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext innerContext) => GestureDetector(
        onTap: () => _pick(innerContext),
        child: Container(
          height: 26,
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: _kPillBg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: _kFieldTextStyle),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5A6169), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OfferDropdown — select control styled to the offer-letter design
// (32px tall, 8px radius, #D8DDE1 border, grey placeholder, chevron icon).
// Mirrors CICCDropdown's API so it's a drop-in replacement here, but keeps the
// styling local to this dialog instead of changing the app-wide dropdown.
// ─────────────────────────────────────────────────────────────────────────────

class _OfferDropdown extends StatefulWidget {
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;

  /// Shown greyed-out when [initialValue] still equals it (i.e. nothing
  /// picked yet) so the closed field reads as a placeholder.
  final String? placeholder;
  final ValueChanged<String>? onChange;

  /// Overrides the greyed-out placeholder style — the Payment Mode dropdown
  /// shows its "Salaried" default in the darker value colour.
  final TextStyle? placeholderStyle;

  const _OfferDropdown({
    required this.items,
    this.initialValue,
    this.placeholder,
    this.onChange,
    this.placeholderStyle,
  });

  @override
  State<_OfferDropdown> createState() => _OfferDropdownState();
}

class _OfferDropdownState extends State<_OfferDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(_OfferDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  void _showOverlay() {
    if (widget.items.isEmpty) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        return ListTile(
                          dense: true,
                          title:
                              Text(item.value ?? '', style: _kFieldTextStyle),
                          onTap: () {
                            setState(() => _selectedValue = item.value);
                            widget.onChange?.call(item.value!);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String text = _selectedValue ?? widget.placeholder ?? 'Select';
    final bool isPlaceholder =
        _selectedValue == null || _selectedValue == widget.placeholder;

    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: _showOverlay,
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(left: 12, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kFieldBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: isPlaceholder
                    ? (widget.placeholderStyle ?? _kHintTextStyle)
                    : _kFieldTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF5A6169), size: 20),
          ],
        ),
      ),
    );
  }
}

class DynamciContainer extends StatefulWidget {
  final VoidCallback onRemove;
  final int index;
  final String officeId;

  const DynamciContainer({
    super.key,
    required this.onRemove,
    required this.index,
    required this.officeId,
  });

  @override
  _DynamciContainerState createState() => _DynamciContainerState();
}

class _DynamciContainerState extends State<DynamciContainer> {
  int selectedZoneId = 0;
  int selectedCountyId = 0;
  int selectedCityId = 0;
  String selectedCounty = 'Select a County';
  Map<String, bool> checkedZipCodes = {};
  Map<String, bool> checkedCityName = {};
  List<int> selectedZipCodes = [];
  List<String> selectedCityName = [];
  String selectedZipCodesString = '';
  String selectedCityString = '';
  List<DropdownMenuItem<String>> dropDownList = [];
  int countyId = 0;
  List<int> zipCodes = [];
  int? employementIndex;

  final StreamController<List<CountyWiseZoneModal>> _zoneController =
      StreamController<List<CountyWiseZoneModal>>.broadcast();
  final StreamController<List<ZipcodeByCountyIdAndZoneIdData>>
      _countyStreamController =
      StreamController<List<ZipcodeByCountyIdAndZoneIdData>>.broadcast();

  String selectedZipCodeZone = "Select a Zone";
  int docZoneId = 0;
  List<ApiAddCovrageData> addCovrage = [];
  bool isButtonEnabled = false;

  // ── Cached futures — prevent refetch/rebuild loop on every build ──
  late Future<List<AllCountyByOfficeId>> _countyByOfficeFuture;
  late Future<List<CountyWiseZoneModal>> _countyZoneFuture;

  @override
  void initState() {
    super.initState();
    _countyByOfficeFuture = getCountyByCompanyId(context, widget.officeId);
    _countyZoneFuture = fetchCountyWiseZone(context, selectedCountyId);
  }

  // ✅ pushes this container's current county/zone/zip picks into the shared
  // provider so sibling coverage containers can exclude them from their own
  // zip lists when they match the same county + zone.
  void _syncSelectionToProvider() {
    context.read<HrEnrollOfferLatterProvider>().updateCoverageZipSelection(
          widget.key!,
          countyId: selectedCountyId,
          zoneId: docZoneId,
          zipCodes: zipCodes.toSet(),
        );
  }

  @override
  void dispose() {
    // ✅ previously missing — both stream controllers leaked on every
    // container removal/screen dispose.
    _zoneController.close();
    _countyStreamController.close();
    super.dispose();
  }

  /// Disabled-looking stand-in for the Zone dropdown (shown while zones load,
  /// or before a county is picked). Styled exactly like [_OfferDropdown] so
  /// swapping between the two doesn't shift the layout.
  Widget _buildPlaceholder({String text = ""}) {
    return Container(
      width: double.infinity,
      height: 32,
      padding: const EdgeInsets.only(left: 12, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kFieldBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: _kHintTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF5A6169), size: 20),
        ],
      ),
    );
  }

  void _fetchCountyWiseZone() async {
    if (selectedCountyId > 0) {
      try {
        List<CountyWiseZoneModal> data =
            await fetchCountyWiseZone(context, selectedCountyId);
        _zoneController.add(data);

        // ✅ no longer auto-selecting data.first — Zone stays on
        // "Select a Zone" until the user manually picks one from the dropdown.
        setState(() {
          selectedZipCodeZone = "Select a Zone";
          docZoneId = 0;
        });
        _syncSelectionToProvider();
        _countyStreamController.add([]);
      } catch (e) {
        _zoneController.addError("Error fetching zones");
      }
    }
  }

  void _fetchZipCodes() async {
    if (selectedCountyId > 0 && docZoneId > 0) {
      try {
        List<ZipcodeByCountyIdAndZoneIdData> data =
            await getZipcodeByCountyIdAndZoneId(
          context: context,
          countyId: selectedCountyId,
          zoneId: docZoneId,
        );
        _countyStreamController.add(data);
      } catch (e) {
        _countyStreamController.addError("Error fetching zip codes");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 12),
      child: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return FormDialogCard(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Coverage header ───────────────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      color: _kCoverageHeaderBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kOfferAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                employementIndex == null
                                    ? '#${widget.index}'
                                    : '#${employementIndex}',
                                style: _kFieldLabelStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              employementIndex == null
                                  ? 'Coverage #${widget.index}'
                                  : 'Coverage #${employementIndex}',
                              style: _kFieldLabelStyle,
                            ),
                          ],
                        ),
                        if (widget.index > 1)
                          InkWell(
                            onTap: widget.onRemove,
                            child: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── County + Zone row ─────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── County dropdown ───────────────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _offerFieldLabel('County'),
                                  const SizedBox(height: 6),
                                  FutureBuilder<List<AllCountyByOfficeId>>(
                                    future: _countyByOfficeFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildPlaceholder(
                                            text: selectedCounty);
                                      }
                                      if (snapshot.hasError) {
                                        return _buildPlaceholder(
                                            text: 'Select a County');
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return _buildPlaceholder(
                                            text: 'No Data available');
                                      }
                                      List<DropdownMenuItem<String>>
                                          countyDropDownList = snapshot.data!
                                              .map((county) =>
                                                  DropdownMenuItem<String>(
                                                    value: county.countyName,
                                                    child:
                                                        Text(county.countyName),
                                                  ))
                                              .toList();
                                      return _OfferDropdown(
                                        items: countyDropDownList,
                                        initialValue: selectedCounty,
                                        placeholder: 'Select a County',
                                        onChange: (newValue) {
                                          setState(() {
                                            selectedCounty = newValue;
                                            selectedCountyId = snapshot.data!
                                                .firstWhere((county) =>
                                                    county.countyName ==
                                                    newValue)
                                                .countyId;
                                            selectedZipCodeZone =
                                                "Select a Zone";
                                            docZoneId = 0;
                                            // Reset zip codes when county changes
                                            checkedZipCodes.clear();
                                            zipCodes.clear();
                                            _countyZoneFuture =
                                                fetchCountyWiseZone(
                                                    context, selectedCountyId);
                                            _fetchCountyWiseZone();
                                          });
                                          // ✅ report cleared zips + new county
                                          // immediately so other containers
                                          // release anything reserved for us.
                                          _syncSelectionToProvider();
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // ── Zone dropdown ─────────────────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _offerFieldLabel('Zone'),
                                  const SizedBox(height: 6),
                                  FutureBuilder<List<CountyWiseZoneModal>>(
                                    future: _countyZoneFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildPlaceholder(
                                            text: selectedZipCodeZone);
                                      }
                                      if (selectedCountyId == 0) {
                                        return _buildPlaceholder(
                                            text: "Select a Zone");
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return _buildPlaceholder(
                                            text: "No zones available");
                                      }
                                      List<DropdownMenuItem<String>>
                                          zoneDropDownList = snapshot.data!
                                              .map((zone) =>
                                                  DropdownMenuItem<String>(
                                                    value: zone.zoneName,
                                                    child: Text(zone.zoneName),
                                                  ))
                                              .toList();
                                      return _OfferDropdown(
                                        initialValue: selectedZipCodeZone,
                                        placeholder: 'Select a Zone',
                                        items: zoneDropDownList,
                                        onChange: (val) {
                                          setState(() {
                                            selectedZipCodeZone = val;
                                            docZoneId = snapshot.data!
                                                .firstWhere((zone) =>
                                                    zone.zoneName == val)
                                                .zone_id;
                                            // ✅ zone changed → clear previously
                                            // checked zips for the old zone,
                                            // matching the county-change reset
                                            // behavior above.
                                            checkedZipCodes.clear();
                                            zipCodes.clear();
                                          });
                                          _syncSelectionToProvider();
                                          _fetchZipCodes();
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Zip Codes ──────────────────────────────────────
                        _offerFieldLabel('Zip Codes'),
                        const SizedBox(height: 6),
                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return StreamBuilder<
                                List<ZipcodeByCountyIdAndZoneIdData>>(
                              stream: _countyStreamController.stream,
                              builder: (context, snapshot) {
                                // ── No county selected yet ────────────────────
                                if (selectedCountyId == 0) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: _offerPlaceholderBox(
                                              'Select County')),
                                      const SizedBox(width: 16),
                                      const Spacer(),
                                    ],
                                  );
                                }

                                // ── No zip codes available ────────────────────
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: _offerPlaceholderBox(
                                              'No Zipcode Available!')),
                                      const SizedBox(width: 16),
                                      const Spacer(),
                                    ],
                                  );
                                }

                                // ── Zip code list ──────────────────────────────
                                List<ZipcodeByCountyIdAndZoneIdData>
                                    zipCodeList = snapshot.data!;

                                // ✅ NEW: exclude zips already claimed by *other*
                                // coverage containers for this same county+zone
                                // combination, so the same zip can't be picked
                                // twice across coverages.
                                final provider = context
                                    .watch<HrEnrollOfferLatterProvider>();
                                final Set<int> usedElsewhere =
                                    provider.zipsUsedByOtherCoverages(
                                  excludeKey: widget.key!,
                                  countyId: selectedCountyId,
                                  zoneId: docZoneId,
                                );
                                zipCodeList = zipCodeList
                                    .where((z) => !usedElsewhere
                                        .contains(int.parse(z.zipCode)))
                                    .toList();

                                if (zipCodeList.isEmpty) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: _offerPlaceholderBox(
                                              'No Zipcode Available!')),
                                      const SizedBox(width: 16),
                                      const Spacer(),
                                    ],
                                  );
                                }

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (zipCodeList.length == 1) {
                                    String singleZip =
                                        zipCodeList.first.zipCode;
                                    if (!checkedZipCodes
                                        .containsKey(singleZip)) {
                                      setState(() {
                                        checkedZipCodes[singleZip] = true;
                                        zipCodes.add(int.parse(singleZip));
                                      });
                                      _syncSelectionToProvider(); // ✅
                                    }
                                  }
                                });

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: zipCodeList.map((zipData) {
                                    String zipCode = zipData.zipCode;
                                    bool isChecked =
                                        checkedZipCodes[zipCode] ?? false;
                                    return SizedBox(
                                      width: 150,
                                      child: CheckBoxTileConst(
                                        text: zipCode,
                                        value: isChecked,
                                        onChanged: (bool? val) {
                                          setState(() {
                                            checkedZipCodes[zipCode] =
                                                val ?? false;
                                            if (val == true) {
                                              zipCodes.add(int.parse(zipCode));
                                            } else {
                                              zipCodes
                                                  .remove(int.parse(zipCode));
                                            }
                                          });
                                          _syncSelectionToProvider(); // ✅
                                        },
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared per-coverage zip selection (NEW)
// ─────────────────────────────────────────────────────────────────────────────

class CoverageZipSelection {
  int countyId;
  int zoneId;
  Set<int> zipCodes;
  CoverageZipSelection({
    this.countyId = 0,
    this.zoneId = 0,
    Set<int>? zipCodes,
  }) : zipCodes = zipCodes ?? <int>{};
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class HrEnrollOfferLatterProvider extends ChangeNotifier {
  String _salary = '';
  bool _issueDate = false;
  bool _verbalAcceptanceDate = false;
  bool _startDate = false;
  bool _lastDate = false;
  bool _noOfPatientDate = false;
  bool _isLoading = false;

  bool get issueDate => _issueDate;
  bool get verbalAcceptanceDate => _verbalAcceptanceDate;
  bool get startDate => _startDate;
  bool get lastDate => _lastDate;
  bool get noOfPatientDate => _noOfPatientDate;
  String get salary => _salary;
  bool get isLoading => _isLoading;

  List<GlobalKey<_DynamciContainerState>> _containerKeys = [];
  List<GlobalKey<_DynamciContainerState>> get containerKeys => _containerKeys;

  // ✅ NEW: tracks each coverage container's county/zone/zip picks, keyed by
  // that container's own GlobalKey, so a container can see what zips its
  // siblings have already claimed for the same county + zone.
  final Map<Key, CoverageZipSelection> _coverageZipSelections = {};

  void updateCoverageZipSelection(
    Key containerKey, {
    required int countyId,
    required int zoneId,
    required Set<int> zipCodes,
  }) {
    _coverageZipSelections[containerKey] = CoverageZipSelection(
      countyId: countyId,
      zoneId: zoneId,
      zipCodes: zipCodes,
    );
    notifyListeners();
  }

  Set<int> zipsUsedByOtherCoverages({
    required Key excludeKey,
    required int countyId,
    required int zoneId,
  }) {
    final Set<int> used = {};
    _coverageZipSelections.forEach((key, selection) {
      if (key != excludeKey &&
          selection.countyId == countyId &&
          selection.zoneId == zoneId) {
        used.addAll(selection.zipCodes);
      }
    });
    return used;
  }

  void validateFields(
      {required String validationLabel, required String value}) {
    if (validationLabel == "Issue Date") _issueDate = value.isEmpty;
    if (validationLabel == "Last Date") _lastDate = value.isEmpty;
    if (validationLabel == "Anticipated Start Date") _startDate = value.isEmpty;
    if (validationLabel == "Verbal Acceptance")
      _verbalAcceptanceDate = value.isEmpty;
    notifyListeners();
  }

  void validateFieldsUseController({
    required TextEditingController issueDateController,
    required TextEditingController startDateController,
    required TextEditingController lastDateController,
    required TextEditingController verbalAcceptanceController,
  }) {
    _issueDate = issueDateController.text.isEmpty;
    _startDate = startDateController.text.isEmpty;
    _lastDate = lastDateController.text.isEmpty;
    _verbalAcceptanceDate = verbalAcceptanceController.text.isEmpty;
    notifyListeners();
  }

  // ✅ NEW: validates the "No. of Visit" field — but only when it's actually
  // shown. When hideVisit is true (QA Coordinator/Manager, Certified Coder,
  // Clinician Manager, Sales, Administration), the field is hidden from the
  // form entirely, so it's always treated as valid ("skip it") regardless
  // of whatever stale text sits in patientsController.
  void validateVisitField({
    required bool hideVisit,
    required String visitValue,
  }) {
    _noOfPatientDate = !hideVisit && visitValue.trim().isEmpty;
    notifyListeners();
  }

  void clearAllFields() {
    _salary = '';
    _containerKeys.clear();
    _coverageZipSelections.clear(); // ✅ reset shared zip tracking too
    notifyListeners();
  }

  void clearSalary() {
    _salary = '';
    notifyListeners();
  }

  void addSalary(String value) {
    _salary = value;
    notifyListeners();
  }

  void addContainer() {
    _containerKeys.add(GlobalKey<_DynamciContainerState>());
    notifyListeners();
  }

  void removecontainer(GlobalKey<_DynamciContainerState> key) {
    _containerKeys.remove(key);
    _coverageZipSelections
        .remove(key); // ✅ free zips reserved by this container
    notifyListeners();
  }

  void popNavigation(BuildContext context) {
    Navigator.pop(context);
    notifyListeners();
  }
}
