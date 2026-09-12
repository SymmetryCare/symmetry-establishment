import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_layout.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/offer_letter_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/add_speciality_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/offer_letter_description_screen.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/speciality_modeldata.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
// TODO: adjust these two imports to your actual file paths:
// 1) the manager file that contains getSpecialityListByDeptId()
// 2) the model file that contains SpecialityModeldata

// TODO: adjust these two imports to your actual file paths:
// 1) the manager file that contains getEmployeeOfferLatterCheck() + CheckOfferLatterData
// 2) the widget file that contains AddErrorPopup

const double _kRegisterEnrollPopupDesignWidth = 900;

/// Every piece of text inside this dialog renders in Fira Sans, matching the
/// app theme. Applying it once at the dialog root means descendants that don't
/// name a family — including the shared `*Style.customTextStyle()` helpers —
/// inherit it, instead of falling back to the platform font.
final String? _kFiraSansFamily = GoogleFonts.firaSans().fontFamily;

class RegisterEnrollPopup extends StatelessWidget {
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final int employeeEnrollId;
  final List<AEClinicalCity> cities;
  final List<CompanyOfficeListData> companyOffices;
  final List<AEClinicalZone> zones;
  final int userId;
  final String role;
  final String status;
  final int employeeId;
  final int depId;
  final VoidCallback onReferesh;
  final VoidCallback onPressed;

  const RegisterEnrollPopup({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.onPressed,
    required this.userId,
    required this.role,
    required this.status,
    required this.employeeId,
    required this.onReferesh,
    required this.depId,
    required this.cities,
    required this.companyOffices,
    required this.zones,
    required this.employeeEnrollId,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kRegisterEnrollPopupDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    String? selectedCountry;
    int countryId = 1;
    String selectedCounty = 'Select';
    int cityId = 0;
    String selectedZone = 'Select';
    String? emptype;
    String? empStatus;
    int zoneId = 0;
    int countyId = 0;
    String reportingOfficeId = 'Select';
    String officeId = '';
    String specialityName = '';
    int specialityId = 0; // selected speciality id (from dropdown)
    String clinicialName = 'Select';
    int clinicalId = 0;
    String cityName = '';
    String serviceVal = '';
    String generatedURL = '';
    bool _isLoading = false;

    // ── Radio-button validation flags ──────────────────────────────────
    // These stay false until the user hits "Next" once. On that first
    // attempt we flip whichever group is still unselected to true, which
    // turns its radio buttons + label red. Picking a value in that group
    // clears its own flag immediately (see onChanged below).
    bool employmentError = false;
    bool serviceError = false;
    // Shown as inline red text above the Next button when the
    // offer-letter availability check fails or errors out.
    String? offerLetterError;

    String? selectedService = "Hospice";
    String? selectedServiceName;
    final TextEditingController phone = TextEditingController();
    final TextEditingController position = TextEditingController();
    final TextEditingController speciality = TextEditingController();
    double textFieldWidth = 250;
    double textFieldHeight = 38;
    List<AEClinicalDiscipline> _clinicalDisciplines = [];
    final enrollProviderState =
        Provider.of<HrEnrollEmployeeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      enrollProviderState.clearValidationText();
      enrollProviderState.enrollServicesList(context);
    });
    // FrontendConfigStore.data is populated asynchronously elsewhere and can
    // still be null when this dialog first builds — read it defensively
    // instead of force-unwrapping (see email_verification_web.dart for the
    // same pattern).
    final frontendConfig = FrontendConfigStore.data?.config;
    return Consumer<HrEnrollEmployeeProvider>(
        builder: (context, providerState, child) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: FormDialogSurface(
            width: 900,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Blue header bar ──────────────────────────────────────────
                FormDialogHeader(
                    title: 'Enroll',
                    onClose: () {
                      Navigator.pop(context);
                    }),

                // ── Body (grows to fit, scrolls once it would overflow
                // the viewport) ─────────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Personal Details ───────────────────────────────
                          _enrollSectionTitle(context, 'Personal Details'),
                          _enrollCard(
                            children: [
                              _enrollRow([
                                // First Name
                                _enrollField(
                                  error: providerState.firstnameError,
                                  child: CustomTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollValueStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding: _kEnrollFieldContentPadding,
                                    width: textFieldWidth,
                                    height: textFieldHeight,
                                    cursorHeight: 15,
                                    controller: firstName,
                                    text: 'First Name',
                                    onChanged: (val) {
                                      providerState.validateField(
                                        firstName.text,
                                        'Please Enter First Name',
                                        providerState.setFirstnameError,
                                      );
                                    },
                                  ),
                                ),
                                // Last Name
                                _enrollField(
                                  error: providerState.lastnameError,
                                  child: CustomTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollValueStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding: _kEnrollFieldContentPadding,
                                    width: textFieldWidth,
                                    height: textFieldHeight,
                                    cursorHeight: 15,
                                    text: 'Last Name',
                                    controller: lastName,
                                    onChanged: (val) {
                                      providerState.validateField(
                                        lastName.text,
                                        'Please Enter Last Name',
                                        providerState.setLastnameError,
                                      );
                                    },
                                  ),
                                ),
                                // Phone No
                                _enrollField(
                                  error: providerState.phoneError,
                                  child: CustomTextFieldPhone(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollValueStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding: _kEnrollFieldContentPadding,
                                    width: textFieldWidth,
                                    height: textFieldHeight,
                                    cursorHeight: 15,
                                    text: 'Phone No',
                                    controller: phone,
                                    onChanged: (val) {
                                      providerState.validateField(
                                        val,
                                        'Please Enter Phone Number',
                                        providerState.setPhoneError,
                                      );
                                    },
                                  ),
                                ),
                              ]),
                              const SizedBox(height: AppSize.s6),
                              _enrollRow([
                                // Speciality
                                _enrollField(
                                  error: providerState.specialityError,
                                  child: SpecialityByDeptDropdown(
                                    departmentId: depId,
                                    headText: 'Speciality',
                                    onChanged: (SpecialityModeldata item) {
                                      // keep the existing controller in sync so
                                      // validateFields() and OfferLetterScreen
                                      // keep working
                                      speciality.text = item.speciality;
                                      specialityName = item.speciality;
                                      specialityId = item.specialityId;
                                      providerState.validateField(
                                        item.speciality,
                                        'Please Select Speciality',
                                        providerState.setSpecialityError,
                                      );
                                    },
                                  ),
                                ),
                                // Clinical / Sales / Admin Type
                                _enrollField(
                                  error: providerState.clinicalType,
                                  child: CustomDropdownTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollPlaceholderStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding:
                                        _kEnrollDropdownContentPadding,
                                    horiPadding: 5,
                                    headText: frontendConfig == null
                                        ? 'Select Type'
                                        : depId == frontendConfig.clinicalId
                                            ? 'Select Clinical Type'
                                            : depId == frontendConfig.salesId
                                                ? 'Select Sales Type'
                                                : depId ==
                                                        frontendConfig
                                                            .administrationId
                                                    ? 'Select Admin Type'
                                                    : 'Unknown',
                                    initialValue: clinicialName,
                                    items: providerState
                                            .clinicalDisciplines.isEmpty
                                        ? ['']
                                        : providerState.clinicalDisciplines
                                            .map((e) => e.empType!)
                                            .toList(),
                                    onChanged: (newValue) {
                                      for (var a in providerState
                                          .clinicalDisciplines) {
                                        if (a.empType == newValue) {
                                          providerState.validateField(
                                            a.empType!,
                                            'Please Select Clinical Type',
                                            providerState.setClinicalTypeError,
                                          );
                                          clinicialName = a.empType!;
                                          clinicalId = a.employeeTypesId;
                                        }
                                      }
                                    },
                                  ),
                                ),
                                // Reporting Office
                                _enrollField(
                                  error: providerState.reportingOfficeError,
                                  child: CustomDropdownTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollPlaceholderStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding:
                                        _kEnrollDropdownContentPadding,
                                    horiPadding: 5,
                                    initialValue: reportingOfficeId,
                                    headText: 'Reporting Office',
                                    items: companyOffices
                                        .map((e) => e.name)
                                        .toList(),
                                    onChanged: (newValue) {
                                      for (var office in companyOffices) {
                                        if (office.name == newValue) {
                                          providerState.validateField(
                                            office.name,
                                            'Please Select Reporting Office',
                                            providerState
                                                .setReportingOfficeError,
                                          );
                                          providerState.fetchSelectCounty(
                                              context: context,
                                              countyName: 'Select');
                                          providerState.fetchOfficeWiseCounty(
                                              context, office.officeId);
                                          providerState.fetchZoneDropdown(
                                              context, 0);
                                          reportingOfficeId = office.name;
                                          officeId = office.officeId;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ]),
                            ],
                          ),
                          const SizedBox(height: AppSize.s12),

                          // ── Contact Details ────────────────────────────────
                          _enrollSectionTitle(context, 'Contact Details'),
                          _enrollCard(
                            children: [
                              _enrollRow([
                                // Email
                                _enrollField(
                                  error: providerState.emailError,
                                  child: CustomTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollValueStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding: _kEnrollFieldContentPadding,
                                    width: textFieldWidth,
                                    height: textFieldHeight,
                                    cursorHeight: 15,
                                    text: 'Email',
                                    isEmail: true,
                                    lettersOnly: false,
                                    controller: email,
                                    onChanged: (val) {
                                      providerState.validateField(
                                        email.text,
                                        'Please Enter Email',
                                        providerState.setEmailError,
                                      );
                                    },
                                  ),
                                ),
                                // County
                                _enrollField(
                                  error: providerState.cityError,
                                  child: providerState.allCountyRecord.isEmpty
                                      ? _enrollEmptyDropdown(
                                          context,
                                          'County',
                                          ErrorMessageString.noCountyAdded,
                                        )
                                      : CustomDropdownTextField(
                                          labelStyle: _kEnrollFieldLabelStyle,
                                          textStyle: _kEnrollPlaceholderStyle,
                                          borderColor: _kEnrollRadioBorder,
                                          borderRadius:
                                              _kEnrollFieldBorderRadius,
                                          boxHeight: _kEnrollFieldBoxHeight,
                                          contentPadding:
                                              _kEnrollDropdownContentPadding,
                                          horiPadding: 5,
                                          initialValue:
                                              providerState.selectCounty,
                                          headText: 'County',
                                          items: providerState.allCountyRecord
                                              .map((e) => e.countyName!)
                                              .toList(),
                                          onChanged: (newValue) {
                                            for (var city in providerState
                                                .allCountyRecord) {
                                              if (city.countyName == newValue) {
                                                providerState.validateField(
                                                  city.countyName!,
                                                  'Please Select County',
                                                  providerState.setCityError,
                                                );
                                                providerState.fetchZoneDropdown(
                                                    context, city.countyId);
                                                providerState.fetchSelectCounty(
                                                    context: context,
                                                    countyName:
                                                        city.countyName);
                                                selectedCounty =
                                                    city.countyName!;
                                                countyId = city.countyId!;
                                              }
                                            }
                                          },
                                        ),
                                ),
                                // Zone
                                _enrollField(
                                  error: providerState.zoneError,
                                  child: providerState.zoneByCounty.isEmpty
                                      ? _enrollEmptyDropdown(
                                          context,
                                          'Zone',
                                          ErrorMessageString.noZoneAdded,
                                        )
                                      : CustomDropdownTextField(
                                          labelStyle: _kEnrollFieldLabelStyle,
                                          textStyle: _kEnrollPlaceholderStyle,
                                          borderColor: _kEnrollRadioBorder,
                                          borderRadius:
                                              _kEnrollFieldBorderRadius,
                                          boxHeight: _kEnrollFieldBoxHeight,
                                          contentPadding:
                                              _kEnrollDropdownContentPadding,
                                          horiPadding: 5,
                                          headText: 'Zone',
                                          items: providerState.zoneByCounty
                                              .map((e) => e.zoneName)
                                              .toList(),
                                          initialValue: selectedZone,
                                          onChanged: (newValue) {
                                            for (var zone
                                                in providerState.zoneByCounty) {
                                              if (zone.zoneName == newValue) {
                                                providerState.validateField(
                                                  zone.zoneName!,
                                                  'Please Select Zone',
                                                  providerState.setZoneError,
                                                );
                                                selectedZone = zone.zoneName!;
                                                zoneId = zone.zoneId!;
                                              }
                                            }
                                          },
                                        ),
                                ),
                              ]),
                              const SizedBox(height: AppSize.s6),
                              _enrollRow([
                                // Position
                                _enrollField(
                                  error: providerState.positionError,
                                  child: CustomTextField(
                                    labelStyle: _kEnrollFieldLabelStyle,
                                    textStyle: _kEnrollValueStyle,
                                    borderColor: _kEnrollRadioBorder,
                                    borderRadius: _kEnrollFieldBorderRadius,
                                    boxHeight: _kEnrollFieldBoxHeight,
                                    contentPadding: _kEnrollFieldContentPadding,
                                    width: textFieldWidth,
                                    height: textFieldHeight,
                                    cursorHeight: 15,
                                    text: 'Position',
                                    controller: position,
                                    onChanged: (val) {
                                      providerState.validateField(
                                        val,
                                        'Please Enter Position',
                                        providerState.setPositionError,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox.shrink(),
                                const SizedBox.shrink(),
                              ]),
                            ],
                          ),
                          const SizedBox(height: AppSize.s12),

                          // ─────────────────────────────────────────────────
                          // Employment radios + Service radios + action buttons
                          // share ONE StatefulBuilder (instead of three
                          // separate ones). That's required for validation:
                          // when "Next" is pressed, a single setState() call
                          // needs to be able to turn BOTH radio groups red
                          // at once if either is still unselected. With
                          // separate builders, the Next button's setState
                          // could only ever rebuild its own subtree.
                          // ─────────────────────────────────────────────────
                          StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _enrollCard(
                                    children: [
                                      // ── Employment type radio buttons ──────
                                      Text.rich(
                                        TextSpan(
                                          text: "Employment",
                                          style: FormDialogFields
                                              .sectionTitleStyle,
                                          children: [
                                            TextSpan(
                                              text: ' *',
                                              style: FormDialogFields
                                                  .sectionTitleStyle
                                                  .copyWith(
                                                      color: ColorManager.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.s6),
                                      Row(
                                        children: [
                                          _enrollRadioTile(
                                            context: context,
                                            label: 'Full Time',
                                            value: 'Full Time',
                                            groupValue: emptype,
                                            hasError: employmentError,
                                            onChanged: (value) {
                                              setState(() {
                                                empStatus =
                                                    "templateId_salaried";
                                                emptype = value;
                                                employmentError = false;
                                              });
                                            },
                                          ),
                                          const SizedBox(width: AppSize.s12),
                                          _enrollRadioTile(
                                            context: context,
                                            label: 'Part Time',
                                            value: 'Part Time',
                                            groupValue: emptype,
                                            hasError: employmentError,
                                            onChanged: (value) {
                                              setState(() {
                                                empStatus =
                                                    "templateId_parttime";
                                                emptype = value;
                                                employmentError = false;
                                              });
                                            },
                                          ),
                                          const SizedBox(width: AppSize.s12),
                                          _enrollRadioTile(
                                            context: context,
                                            label: 'Per Diem',
                                            value: 'Per Diem',
                                            groupValue: emptype,
                                            hasError: employmentError,
                                            onChanged: (value) {
                                              setState(() {
                                                empStatus =
                                                    "templateId_perdiem";
                                                emptype = value;
                                                employmentError = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSize.s12),

                                      // ── Service radio buttons ───────────────
                                      Text.rich(
                                        TextSpan(
                                          text: "Service",
                                          style: FormDialogFields
                                              .sectionTitleStyle,
                                          children: [
                                            TextSpan(
                                              text: ' *',
                                              style: FormDialogFields
                                                  .sectionTitleStyle
                                                  .copyWith(
                                                      color: ColorManager.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.s6),
                                      Wrap(
                                        spacing: AppSize.s12,
                                        runSpacing: AppSize.s8,
                                        children: providerState.enrollService
                                            .map((service) => _enrollRadioTile(
                                                  context: context,
                                                  label: service.servicename,
                                                  value: service.servicename,
                                                  groupValue:
                                                      selectedServiceName,
                                                  hasError: serviceError,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedServiceName =
                                                          value;
                                                      serviceError = false;
                                                    });
                                                  },
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),

                                  // ── Offer-letter check error (inline) ───
                                  if (offerLetterError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        offerLetterError!,
                                        style: TextStyle(
                                          color: ColorManager.red,
                                          fontSize: FontSize.s10,
                                        ),
                                      ),
                                    ),

                                  // ── Back / Next buttons ─────────────────
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 14, bottom: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 32,
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: const BorderSide(
                                                    color: Color(0xFFE0E0E0)),
                                              ),
                                            ),
                                            child: Text(
                                              'Back',
                                              style:
                                                  _kEnrollButtonStyle.copyWith(
                                                      color:
                                                          _kEnrollBackTextColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSize.s12),
                                        providerState.load
                                            ? SizedBox(
                                                height: 25,
                                                width: 25,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: ColorManager
                                                            .blueprime),
                                              )
                                            : SizedBox(
                                                height: 32,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    providerState
                                                        .validateFields(
                                                      position: position.text,
                                                      phone: phone.text,
                                                      speciality:
                                                          speciality.text,
                                                      firstName: firstName.text,
                                                      lastName: lastName.text,
                                                      email: email.text,
                                                      clinicalType:
                                                          clinicialName,
                                                      repoartingOffice:
                                                          reportingOfficeId,
                                                      zone: selectedZone,
                                                      city: selectedCounty,
                                                    );

                                                    // Radio-button validation —
                                                    // flips the red highlight on
                                                    // for any group still unset.
                                                    setState(() {
                                                      employmentError =
                                                          emptype == null;
                                                      serviceError =
                                                          selectedServiceName ==
                                                              null;
                                                      // Clear any leftover error
                                                      // text from a previous
                                                      // failed attempt.
                                                      offerLetterError = null;
                                                    });

                                                    if (!(providerState
                                                            .isFormValid &&
                                                        !employmentError &&
                                                        !serviceError)) {
                                                      return;
                                                    }

                                                    // Capture a stable BuildContext
                                                    // reference *before* the async
                                                    // gap. `providerState.loaderTrue()`
                                                    // below triggers a Consumer
                                                    // rebuild, which recreates this
                                                    // StatefulBuilder subtree — so we
                                                    // must guard every use of
                                                    // `context` after the `await`
                                                    // with `context.mounted`.
                                                    providerState.loaderTrue();

                                                    try {
                                                      // ── Offer letter availability check ──
                                                      // Verify (clinicalId, depId) combo is
                                                      // allowed before proceeding. If not
                                                      // available, stop here and show error.
                                                      final offerLatterCheck =
                                                          await getEmployeeOfferLatterCheck(
                                                              context: context,
                                                              employeeTypeId:
                                                                  clinicalId,
                                                              deptId: depId,
                                                              employeeStatus:
                                                                  empStatus!);

                                                      // Bail out safely if this
                                                      // element is no longer in
                                                      // the tree (dialog closed,
                                                      // rebuilt away, etc.) —
                                                      // calling showDialog on a
                                                      // stale context silently
                                                      // does nothing, which is
                                                      // what was happening before.
                                                      if (!context.mounted)
                                                        return;

                                                      if (offerLatterCheck
                                                              .available !=
                                                          true) {
                                                        setState(() {
                                                          offerLetterError =
                                                              offerLatterCheck
                                                                      .message ??
                                                                  'Unable to proceed. Please try again.';
                                                        });
                                                        return;
                                                      }

                                                      providerState
                                                          .generateUrlLink();

                                                      if (!context.mounted)
                                                        return;

                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            OfferLetterScreen(
                                                          employeeEnrollId:
                                                              employeeEnrollId,
                                                          officeId: officeId,
                                                          employeeId:
                                                              employeeId,
                                                          email: email.text,
                                                          userId: userId,
                                                          status: status,
                                                          firstName:
                                                              firstName.text,
                                                          lastName:
                                                              lastName.text,
                                                          role: role,
                                                          position:
                                                              position.text,
                                                          phone: phone.text,
                                                          reportingOffice:
                                                              reportingOfficeId,
                                                          services:
                                                              selectedServiceName
                                                                  .toString(),
                                                          employement: emptype
                                                              .toString(),
                                                          clinicalId:
                                                              clinicalId,
                                                          soecalityName:
                                                              specialityId,
                                                          onRefreshRegister:
                                                              onReferesh,
                                                          depId: depId,
                                                          cityId: 0,
                                                          countyId: countyId,
                                                          zoneId: zoneId,
                                                          link: providerState
                                                              .generatedURL,
                                                          countryId: countryId,
                                                        ),
                                                      );
                                                    } catch (e, st) {
                                                      // Any exception from the API
                                                      // call (network error, null
                                                      // message access, parsing
                                                      // failure, etc.) used to be
                                                      // swallowed silently by the
                                                      // async callback — nothing
                                                      // was shown to the user, and
                                                      // the loader just reset.
                                                      // Now we log it and surface
                                                      // an inline error instead.
                                                      debugPrint(
                                                          'getEmployeeOfferLatterCheck failed: $e\n$st');
                                                      setState(() {
                                                        offerLetterError =
                                                            'Something went wrong. Please try again.';
                                                      });
                                                    } finally {
                                                      // Always clear the loader,
                                                      // whether we succeeded,
                                                      // hit the "not available"
                                                      // branch, or threw.
                                                      providerState
                                                          .loaderFalse();
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 22),
                                                    backgroundColor:
                                                        const Color(0xFF0B8CBF),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Next",
                                                    style: _kEnrollButtonStyle,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
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

/// ─────────────────────────────────────────────────────────────────────────────
/// Enroll popup layout helpers
/// The dialog is laid out as labelled sections ("Personal Details",
/// "Contact Details", …), each one a bordered card holding row-major
/// three-column form rows.
/// ─────────────────────────────────────────────────────────────────────────────

// ── Typography + colours, straight from the Enroll dialog design spec ──────
const Color _kEnrollSectionTitleColor = Color(0xFF333333);
const Color _kEnrollFieldLabelColor = Color(0xFF505050);
const Color _kEnrollValueColor = Color(0xFF050505);
const Color _kEnrollPlaceholderColor = Color(0xFF555555);
const Color _kEnrollRadioAccent = Color(0xFF3AB0E2);
const Color _kEnrollRadioBorder = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
const Color _kEnrollRadioOutline = Color(0xFF757575);
const Color _kEnrollBackTextColor = Color(0xFF2D2D2D);

/// Field geometry. The shared field widgets inset their box by 5px on every
/// side, so the outer height is 10px more than the visible border box — 52
/// here gives the 42px-tall field the design asks for. The content padding
/// then keeps the text off the border instead of jammed into its
/// bottom-left corner, which is what the legacy `left: 4, bottom: 3` did.
/// Fields share the radio pill's border — 1px rgba(0, 0, 0, 0.1), 8px radius.
const double _kEnrollFieldBorderRadius = 8;
const double _kEnrollFieldBoxHeight = 38;
const EdgeInsets _kEnrollFieldContentPadding =
    EdgeInsets.symmetric(horizontal: 10, vertical: 6);
// Horizontal only: the dropdown's box is a fixed height whose Row centres its
// contents, and the value Text carries 3px of its own vertical padding. Adding
// vertical padding here on top of that left the line taller than the box, which
// clipped the descenders.
const EdgeInsets _kEnrollDropdownContentPadding =
    EdgeInsets.symmetric(horizontal: 9);

/// 20 / 700 — the "Enroll" heading in the blue bar.

/// 13 / 400 — "Kindly fill these following fields."

/// 14 / 600 — section titles ("Personal Details") and the Employment /
/// Service group labels.

/// 14 / 400 — every field label ("First Name *").
final TextStyle _kEnrollFieldLabelStyle = FormDialogFields.labelStyle;

/// 14 / 400 — text the user has entered.
final TextStyle _kEnrollValueStyle = FormDialogFields.valueStyle;

/// 14 / 400 — dropdown placeholders and the "No county added" stand-ins.
final TextStyle _kEnrollPlaceholderStyle = FormDialogFields.hintStyle;

/// 14 / 400 — radio option labels ("Full Time").
final TextStyle _kEnrollRadioLabelStyle = TextStyle(
  fontFamily: _kFiraSansFamily,
  fontSize: 10,
  height: 13 / 10,
  fontWeight: FontWeight.w400,
  color: _kEnrollSectionTitleColor,
  decoration: TextDecoration.none,
);

/// 13 / 400 — Back / Next button labels.
final TextStyle _kEnrollButtonStyle = TextStyle(
  fontFamily: _kFiraSansFamily,
  fontSize: 10,
  height: 13 / 10,
  fontWeight: FontWeight.w400,
  color: Colors.white,
  decoration: TextDecoration.none,
);

Widget _enrollSectionTitle(BuildContext context, String text) =>
    FormDialogSectionTitle(text);

Widget _enrollCard({required List<Widget> children}) => FormDialogCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children),
    );

Widget _enrollRow(List<Widget> cells) => FormDialogGrid(children: cells);

/// A single form field plus its inline validation message. The
/// fixed-height placeholder keeps rows from jumping when an error
/// appears or clears.
Widget _enrollField({required Widget child, String? error}) =>
    FormDialogField(child: child, error: error);

/// Read-only stand-in shown where a dropdown has no options yet
/// (e.g. "No county added" until a reporting office is picked).
Widget _enrollEmptyDropdown(
        BuildContext context, String label, String message) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 2),
          child: Text.rich(
            TextSpan(
              text: label,
              style: _kEnrollFieldLabelStyle,
              children: [
                TextSpan(
                  text: ' *',
                  style:
                      _kEnrollFieldLabelStyle.copyWith(color: ColorManager.red),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Container(
            height: _kEnrollFieldBoxHeight - 10,
            width: AppSize.s250,
            alignment: Alignment.centerLeft,
            padding: _kEnrollDropdownContentPadding,
            decoration: BoxDecoration(
              border: Border.all(color: _kEnrollRadioBorder, width: AppSize.s1),
              borderRadius: BorderRadius.circular(_kEnrollFieldBorderRadius),
            ),
            child: Text(message, style: _kEnrollPlaceholderStyle),
          ),
        ),
      ],
    );

/// One radio option rendered as the bordered pill from the design.
Widget _enrollRadioTile({
  required BuildContext context,
  required String label,
  required String value,
  required String? groupValue,
  required bool hasError,
  required ValueChanged<String?> onChanged,
}) {
  // `activeColor` alone only colors the circle once it is selected/filled.
  // The outline of an UNselected circle is controlled by `fillColor`
  // (Flutter resolves it per MaterialState), so that is what needs to be
  // red for the validation highlight.
  final Color accent = hasError ? ColorManager.red : _kEnrollRadioAccent;
  return InkWell(
    onTap: () => onChanged(value),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 30,
      padding: const EdgeInsets.only(left: 4, right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: hasError ? accent : _kEnrollRadioBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.75,
            child: Radio<String>(
              splashRadius: 0,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              activeColor: accent,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) return accent;
                return hasError ? accent : _kEnrollRadioOutline;
              }),
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: _kEnrollRadioLabelStyle),
        ],
      ),
    ),
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Speciality dropdown populated by department id
/// Fetches the list once via getSpecialityListByDeptId(departmentId: depId)
/// and re-fetches automatically if departmentId ever changes.
/// ─────────────────────────────────────────────────────────────────────────────
class SpecialityByDeptDropdown extends StatefulWidget {
  final int departmentId;
  final String headText;
  final Function(SpecialityModeldata) onChanged;

  const SpecialityByDeptDropdown({
    Key? key,
    required this.departmentId,
    required this.onChanged,
    this.headText = 'Speciality',
  }) : super(key: key);

  @override
  State<SpecialityByDeptDropdown> createState() =>
      _SpecialityByDeptDropdownState();
}

class _SpecialityByDeptDropdownState extends State<SpecialityByDeptDropdown> {
  List<SpecialityModeldata> _specialityList = [];
  String _selectedValue = 'Select';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSpecialities();
    });
  }

  @override
  void didUpdateWidget(SpecialityByDeptDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.departmentId != widget.departmentId) {
      _selectedValue = 'Select';
      _specialityList = [];
      _fetchSpecialities();
    }
  }

  Future<void> _fetchSpecialities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await getSpecialityListByDeptId(
        context: context,
      );
      if (!mounted) return;
      setState(() {
        _specialityList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _specialityList = [];
        _isLoading = false;
      });
    }
  }

  /// Opens the Add Speciality popup and refreshes the list on success, so a
  /// speciality that is missing can be created without leaving the enroll
  /// form - including from the "No Speciality Found" dead end.
  Widget _addSpecialityButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 28,
          width: 150,
          child: CustomIconButton(
            icon: Icons.add,
            text: 'Add Speciality',
            textSize: FontSize.s12,
            color: const Color(0xFF0B8CBF),
            borderRadius: 24.0,
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSpecialityPopup(
                    onSpecialityAdded: _fetchSpecialities,
                  );
                },
              );
            },
            isNotPopUpButton: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Placeholder while the list loads (same footprint as the dropdown)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdownTextField(
            labelStyle: _kEnrollFieldLabelStyle,
            textStyle: _kEnrollPlaceholderStyle,
            borderColor: _kEnrollRadioBorder,
            borderRadius: _kEnrollFieldBorderRadius,
            boxHeight: _kEnrollFieldBoxHeight,
            contentPadding: _kEnrollDropdownContentPadding,
            horiPadding: 5,
            headText: widget.headText,
            initialValue: _selectedValue,
            items: const [],
            onChanged: (newValue) {},
          )
        ],
      );
    }

    if (_specialityList.isEmpty) {
      // No specialities configured yet
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _enrollEmptyDropdown(
              context, widget.headText, 'No Speciality Found'),
          _addSpecialityButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownTextField(
          labelStyle: _kEnrollFieldLabelStyle,
          textStyle: _kEnrollPlaceholderStyle,
          borderColor: _kEnrollRadioBorder,
          borderRadius: _kEnrollFieldBorderRadius,
          boxHeight: _kEnrollFieldBoxHeight,
          contentPadding: _kEnrollDropdownContentPadding,
          horiPadding: 5,
          headText: widget.headText,
          initialValue: _selectedValue,
          items: _specialityList.map((e) => e.speciality).toList(),
          onChanged: (newValue) {
            for (var item in _specialityList) {
              if (item.speciality == newValue) {
                setState(() => _selectedValue = item.speciality);
                widget.onChanged(item);
              }
            }
          },
        ),
        _addSpecialityButton(),
      ],
    );
  }
}
