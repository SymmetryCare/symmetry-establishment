import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_general_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/repository/hr_module_repository/manage_emp/gender_api.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/gender_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profile_bar_editor_popup.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/profile_editor/profile_editor.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/add_coverage_popup.dart';

class ProfileEditScreen extends StatefulWidget {
  final Future<void> Function() onCancel;
  final int employeeId;

  const ProfileEditScreen({
    required this.onCancel,
    required this.employeeId,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  late Future<ProfileEditorModal> _profileFuture;

  Future<EmployeeModel>? _coverageFuture;
  int? _employeeEnrollId;

  late Future<List<AEClinicalDiscipline>> _employeeTypeFuture;
  late Future<List<GenderData>> _genderFuture;
  late Future<List<ServicesMetaData>> _serviceFuture;
  late Future<List<CompanyOfficeListData>> _officeFuture;

  void _refreshCoverage() {
    if (_employeeEnrollId == null) return;
    setState(() {
      _coverageFuture = getCoverageList(
        context: context,
        employeeId: widget.employeeId,
        employeeEnrollId: _employeeEnrollId!,
      );
    });
  }

  String? selectedDepartment;
  String? selectedGender;
  String? selectedZone;
  String? selectedCounty;
  String? selectedSSn;
  String? selectedServices;
  String? selectedEmployeType;
  String? selectedReportingOffice;
  DateTime? selectedDate;
  List<DropdownMenuItem<String>> dropDownList = [];
  int selectedZoneId = 0;
  int selectedCountyId = 0;
  int selectedCityId = 0;
  String reportingOfficeId = '';
  String genderId = '';
  Map<String, bool> checkedZipCodes = {};
  Map<String, bool> checkedCityName = {};
  List<String> selectedZipCodes = [];
  List<String> selectedCityName = [];
  String selectedZipCodesString = '';
  var deptId = 1;
  int? firstDeptId;
  String? selectedDeptName;
  int? selectedDeptId;
  String? selectedServiceName;
  String? serviceId;
  TextEditingController dummyCtrl = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController deptController = TextEditingController();
  TextEditingController empTypeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController ssNController = TextEditingController();
  TextEditingController workPhoneController = TextEditingController();
  TextEditingController phoneNController = TextEditingController();
  TextEditingController personalEmailController = TextEditingController();
  TextEditingController workEmailController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController reportingOfficeController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  List<DropdownMenuItem<String>> countyDropDownList = [];
  List<DropdownMenuItem<String>> zoneDropDownList = [];
  String selectedCovrageCounty = "Select County";
  String selectedCovrageZone = "Select Zone";
  String? selectedServiceId;
  String? selectedOfficeId;
  String? selectedGenderId;
  bool _isLoading = false;
  String? selectedEmployeeColor;
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier<bool>(false);

  bool _controllersInitialized = false;

  String? _nameError;
  String? _employeeTypeError;
  String? _addressError;
  String? _dobError;
  String? _genderError;
  String? _ssnError;
  String? _phoneError;
  String? _workPhoneError;
  String? _personalEmailError;
  String? _workEmailError;
  String? _summaryError;
  String? _serviceError;
  String? _reportingOfficeError;

  void _applyFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'firstName':
            _nameError = e.message;
            break;
          case 'employeeTypeId':
            _employeeTypeError = e.message;
            break;
          case 'address':
          case 'finalAddress':
            _addressError = e.message;
            break;
          case 'dateOfBirth':
            _dobError = e.message;
            break;
          case 'gender':
            _genderError = e.message;
            break;
          case 'SSNNbr':
            _ssnError = e.message;
            break;
          case 'primaryPhoneNbr':
            _phoneError = e.message;
            break;
          case 'workPhoneNbr':
            _workPhoneError = e.message;
            break;
          case 'personalEmail':
            _personalEmailError = e.message;
            break;
          case 'workEmail':
            _workEmailError = e.message;
            break;
          case 'summary':
            _summaryError = e.message;
            break;
          case 'service':
            _serviceError = e.message;
            break;
          case 'regOfficId':
            _reportingOfficeError = e.message;
            break;
          default:
            break;
        }
      }
    });
  }

  void _clearFieldErrors() {
    if (!mounted) return;
    setState(() {
      _nameError = null;
      _employeeTypeError = null;
      _addressError = null;
      _dobError = null;
      _genderError = null;
      _ssnError = null;
      _phoneError = null;
      _workPhoneError = null;
      _personalEmailError = null;
      _workEmailError = null;
      _summaryError = null;
      _serviceError = null;
      _reportingOfficeError = null;
    });
  }

  final FocusNode _nameFocus         = FocusNode();
  final FocusNode _empTypeFocus      = FocusNode();
  final FocusNode _addressFocus      = FocusNode();
  final FocusNode _dobFocus          = FocusNode();
  final FocusNode _genderFocus       = FocusNode();
  final FocusNode _ssnFocus          = FocusNode();
  final FocusNode _phoneFocus        = FocusNode();
  final FocusNode _workPhoneFocus    = FocusNode();
  final FocusNode _personalEmailFocus = FocusNode();
  final FocusNode _workEmailFocus    = FocusNode();
  final FocusNode _summaryFocus      = FocusNode();
  final FocusNode _serviceFocus      = FocusNode();
  final FocusNode _reportingOfficeFocus = FocusNode();

  KeyEventResult _handleEnterKey(KeyEvent event, FocusNode next) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      next.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
    _profileFuture = getEmployeePrefill(context, widget.employeeId);
    _employeeTypeFuture = HrAddEmplyClinicalDisciplinApi(context, deptId);
    _genderFuture = getGenderDropdown(context);
    _serviceFuture = getServicesMetaData(context);
    _officeFuture = getCompanyOfficeList(context);

    _nameFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _empTypeFocus);
    _addressFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _dobFocus);
    _dobFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _genderFocus);
    _ssnFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _phoneFocus);
    _phoneFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _workPhoneFocus);
    _workPhoneFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _personalEmailFocus);
    _personalEmailFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _workEmailFocus);
    _workEmailFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _summaryFocus);
    _summaryFocus.onKeyEvent = (_, e) => _handleEnterKey(e, _serviceFocus);
  }

  @override
  void didUpdateWidget(ProfileEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employeeId != widget.employeeId) {
      setState(() {
        _profileFuture = getEmployeePrefill(context, widget.employeeId);
        _controllersInitialized = false;
      });
    }
  }

  void _addListeners() {
    List<TextEditingController> controllers = [
      nameController,
      addressController,
      ageController,
      ssNController,
      phoneNController,
      personalEmailController,
      workEmailController,
      summaryController,
    ];
    for (var controller in controllers) {
      controller.addListener(_checkIfAllFieldsFilled);
    }
  }

  void _checkIfAllFieldsFilled() {
    bool allFilled = _areAllFieldsFilled();
    if (_isButtonEnabled.value != allFilled) {
      _isButtonEnabled.value = allFilled;
    }
  }

  bool _areAllFieldsFilled() {
    bool allFilled = nameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        ssNController.text.isNotEmpty &&
        phoneNController.text.isNotEmpty &&
        personalEmailController.text.isNotEmpty &&
        workEmailController.text.isNotEmpty &&
        summaryController.text.isNotEmpty;
    return allFilled;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _nameFocus.dispose();
    _empTypeFocus.dispose();
    _addressFocus.dispose();
    _dobFocus.dispose();
    _genderFocus.dispose();
    _ssnFocus.dispose();
    _phoneFocus.dispose();
    _workPhoneFocus.dispose();
    _personalEmailFocus.dispose();
    _workEmailFocus.dispose();
    _summaryFocus.dispose();
    _serviceFocus.dispose();
    _reportingOfficeFocus.dispose();
    _isButtonEnabled.dispose();
    nameController.dispose();
    deptController.dispose();
    empTypeController.dispose();
    addressController.dispose();
    ageController.dispose();
    genderController.dispose();
    ssNController.dispose();
    workPhoneController.dispose();
    phoneNController.dispose();
    personalEmailController.dispose();
    workEmailController.dispose();
    zoneController.dispose();
    countyController.dispose();
    serviceController.dispose();
    reportingOfficeController.dispose();
    summaryController.dispose();
    super.dispose();
  }

  void _ppp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddSuccessPopup(message: 'Employee updated successfully');
      },
    );
  }
  void _pppError({required String errorMessage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => FailedPopup(text: errorMessage),
    );
  }

  List<int> zipCodes = [];
  String? selectedZipCodeZone;
  int docZoneId = 0;
  bool pickedFilePath = false;
  dynamic finalPath;
  String fileName = '';
  int selectedEmployeeTypeId = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth =
          constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return CustomScrollbar(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppPadding.p10),
                child: SizedBox(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  child: FutureBuilder<ProfileEditorModal>(
                    future: _profileFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error fetching profile data'),
                        );
                      }

                      if (snapshot.hasData) {
                        var profileData = snapshot.data!;

                        if (!_controllersInitialized) {
                          nameController.text = profileData.firstName ?? '';
                          deptController.text = profileData.department ?? '';
                          empTypeController.text =
                              profileData.employeType ?? '';
                          addressController.text =
                              profileData.finalAddress ?? '';
                          ageController.text =
                              profileData.dateOfBirth ?? '';
                          genderController.text = profileData.gender ?? '';
                          ssNController.text = profileData.SSNNbr ?? '';
                          workPhoneController.text =
                              profileData.workPhoneNbr ?? '';
                          phoneNController.text =
                              profileData.primaryPhoneNbr ?? '';
                          personalEmailController.text =
                              profileData.personalEmail ?? '';
                          workEmailController.text =
                              profileData.workEmail ?? '';
                          zoneController.text = profileData.zone ?? '';
                          countyController.text = profileData.county ?? '';
                          serviceController.text = profileData.service ?? '';
                          reportingOfficeController.text =
                              profileData.regOfficId ?? '';
                          summaryController.text = profileData.summary ?? '';
                          selectedEmployeeColor = profileData.color;
                          selectedDeptName = profileData.department;
                          selectedDeptId = profileData.departmentId;
                          _employeeEnrollId = profileData.employeeEnrollId;
                          _coverageFuture = getCoverageList(
                            context: context,
                            employeeId: widget.employeeId,
                            employeeEnrollId: profileData.employeeEnrollId,
                          );
                          _controllersInitialized = true;
                        }
                        print('Profile image ${profileData.imgurl}');
                        String countyName = "";
                        String zoneName = "";

                        return Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                        color: ColorManager.blueprime,
                                        width: 8.0),
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.grey.withOpacity(0.5),
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Stack(children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    right: 23,
                                                    top: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .end,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          left: 18),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                        children: [
                                                          StatefulBuilder(
                                                            builder: (BuildContext
                                                            context,
                                                                void Function(
                                                                    void
                                                                    Function())
                                                                setState) {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    right:
                                                                    20),
                                                                child:
                                                                Row(
                                                                  children: [
                                                                    pickedFilePath
                                                                        ? Container(
                                                                      decoration: BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withOpacity(0.2),
                                                                            spreadRadius: 2,
                                                                            blurRadius: 5,
                                                                            offset: const Offset(0, 3),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: CircleAvatar(
                                                                        radius: 30,
                                                                        child: ClipOval(
                                                                          child: Image.memory(
                                                                            finalPath!,
                                                                            fit: BoxFit.cover,
                                                                            width: double.infinity,
                                                                            height: double.infinity,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : profileData.imgurl == null
                                                                        ? const Text('')
                                                                        : Container(
                                                                      decoration: const BoxDecoration(
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: CircleAvatar(
                                                                        radius: 30,
                                                                        backgroundColor: Colors.white,
                                                                        child: ClipOval(
                                                                          child: Image.network(
                                                                            profileData.imgurl,
                                                                            fit: BoxFit.cover,
                                                                            width: double.infinity,
                                                                            height: double.infinity,
                                                                            loadingBuilder: (context, child, loadingProgress) {
                                                                              if (loadingProgress == null) {
                                                                                return child;
                                                                              } else {
                                                                                return const CircularProgressIndicator();
                                                                              }
                                                                            },
                                                                            errorBuilder: (context, error, stackTrace) {
                                                                              return CircleAvatar(
                                                                                radius: 30,
                                                                                child: Image.asset("images/profilepic.png", fit: BoxFit.cover),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                        10),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 5),
                                                                      child: CustomIconButton(
                                                                        icon: Icons.upload_outlined,
                                                                        text: AppString.photo,
                                                                        onPressed: () async {
                                                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                                            allowMultiple: false,
                                                                            type: FileType.custom,
                                                                            allowedExtensions: ['png', 'jpg', 'jpeg'],
                                                                          );
                                                                          if (result != null) {
                                                                            print("Result::: ${result}");
                                                                            try {
                                                                              final pickedFile = result.files.first;
                                                                              const int maxSizeInBytes = 200 * 1024;

                                                                              if (pickedFile.size > maxSizeInBytes) {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return const AddErrorPopup(
                                                                                      message: 'Please upload an image smaller than 200 KB',
                                                                                    );
                                                                                  },
                                                                                );
                                                                                return;
                                                                              }

                                                                              setState(() {
                                                                                pickedFilePath = true;
                                                                                fileName = pickedFile.name;
                                                                                finalPath = pickedFile.bytes;
                                                                              });
                                                                              print('File picked: ${fileName}');
                                                                            } catch (e) {
                                                                              print(e);
                                                                            }
                                                                          }
                                                                        }, isNotPopUpButton: false,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    StatefulBuilder(
                                                      builder: (BuildContext
                                                      context,
                                                          void Function(
                                                              void
                                                              Function())
                                                          setState) {
                                                        return Padding(
                                                          padding: const EdgeInsets.only(bottom: 13),
                                                          child: Row(
                                                            children: [
                                                              ProfileEditCancelButton(
                                                                height: AppSize
                                                                    .s30,
                                                                width: AppSize
                                                                    .s100,
                                                                text: AppString
                                                                    .cancel,
                                                                onPressed:
                                                                    () async {
                                                                  widget
                                                                      .onCancel();
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              // FIX: keep this slot's width fixed at
                                                              // AppSize.s100 regardless of isLoading.
                                                              //
                                                              // Previously the spinner rendered inside a
                                                              // 30-wide SizedBox while the Save button used a
                                                              // 100-wide one. Because this Row sits inside a
                                                              // PARENT Row using
                                                              // mainAxisAlignment.spaceBetween (photo group on
                                                              // the left, Cancel/Save group anchored right),
                                                              // shrinking this block's total width from ~140px
                                                              // to ~70px pulled its right-anchored position
                                                              // left — moving the Cancel button along with it
                                                              // every time isLoading toggled true/false. That
                                                              // was the "shaking" on Save.
                                                              //
                                                              // With this slot always AppSize.s100 wide, the
                                                              // whole Cancel/Save block's width never changes,
                                                              // so its position (and the Cancel button inside
                                                              // it) stays fixed.
                                                              SizedBox(
                                                                height: AppSize.s30,
                                                                width: AppSize.s100,
                                                                child: ValueListenableBuilder<bool>(
                                                                    valueListenable:
                                                                    _isButtonEnabled,
                                                                    builder:
                                                                        (context,
                                                                        isEnabled,
                                                                        child) {
                                                                      return CustomButton(
                                                                        height:
                                                                        AppSize.s30,
                                                                        width:
                                                                        AppSize.s100,
                                                                        isLoading: isLoading,
                                                                        onPressed: isEnabled
                                                                            ? () async {
                                                                          BuildContext dialogContext = context;
                                                                          setState(() {
                                                                            isLoading = true;
                                                                          });
                                                                          _clearFieldErrors();
                                                                          try {
                                                                            var response = await patchEmployeeEdit(
                                                                              context: dialogContext,
                                                                              filePicked: pickedFilePath,
                                                                              pickedFilepath: finalPath,
                                                                              pickedFileName: fileName,
                                                                              employeeId: widget.employeeId,
                                                                              code: profileData.code,
                                                                              userId: profileData.userId,
                                                                              firstName: nameController.text,
                                                                              lastName: profileData.lastName,
                                                                              departmentId: profileData.departmentId,
                                                                              employeeTypeId: selectedEmployeeTypeId,
                                                                              expertise: profileData.speciality,
                                                                              cityId: profileData.cityId,
                                                                              countryId: profileData.countryId,
                                                                              countyId: profileData.countyId,
                                                                              zoneId: profileData.zoneId,
                                                                              SSNNbr: ssNController.text,
                                                                              primaryPhoneNbr: phoneNController.text,
                                                                              secondryPhoneNbr: profileData.secondryPhoneNbr,
                                                                              workPhoneNbr: workPhoneController.text,
                                                                              regOfficId: selectedOfficeId ?? profileData.regOfficId,
                                                                              personalEmail: personalEmailController.text,
                                                                              workEmail: workEmailController.text,
                                                                              address: addressController.text,
                                                                              dateOfBirth: profileData.dateOfBirth == ageController.text ? profileData.dateOfBirth.toString() : ageController.text,
                                                                              emergencyContact: profileData.emergencyContact,
                                                                              covreage: profileData.covreage,
                                                                              employment: profileData.employment,
                                                                              gender: selectedGenderId ?? genderController.text,
                                                                              status: profileData.status,
                                                                              service: selectedServiceId ?? profileData.service,
                                                                              summary: summaryController.text,
                                                                              imgurl: profileData.imgurl,
                                                                              resumeurl: profileData.resumeurl,
                                                                              onboardingStatus: profileData.onboardingStatus,
                                                                              driverLicenceNbr: profileData.driverLicenceNbr,
                                                                              dateofTermination: profileData.dateofTermination,
                                                                              dateofResignation: profileData.dateofResignation,
                                                                              dateofHire: profileData.dateofHire,
                                                                              rehirable: profileData.rehirable,
                                                                              position: profileData.position,
                                                                              finalAddress: addressController.text,
                                                                              type: profileData.type,
                                                                              reason: profileData.reason,
                                                                              finalPayCheck: profileData.finalPayCheck,
                                                                              checkDate: profileData.checkDate,
                                                                              grossPay: profileData.grossPay,
                                                                              netPay: profileData.netPay,
                                                                              methods: profileData.methods,
                                                                              materials: profileData.materials,
                                                                              race: profileData.race,
                                                                              rating: profileData.rating,
                                                                              signatureURL: profileData.signatureURL,
                                                                              colorCode: selectedEmployeeColor!,
                                                                              departmentName: selectedDeptName!,
                                                                            );

                                                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                                                              print("File Value ::::::::::::: ${pickedFilePath}");
                                                                              _ppp();
                                                                              await widget.onCancel();
                                                                              nameController.clear();
                                                                              deptController.clear();
                                                                              empTypeController.clear();
                                                                              addressController.clear();
                                                                              ageController.clear();
                                                                              ssNController.clear();
                                                                              phoneNController.clear();
                                                                              workPhoneController.clear();
                                                                              personalEmailController.clear();
                                                                              workEmailController.clear();
                                                                              countyController.clear();
                                                                              serviceController.clear();
                                                                              zoneController.clear();
                                                                              summaryController.clear();
                                                                            }
                                                                            else if (response.statusCode == 400 || response.statusCode == 404) {
                                                                              if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
                                                                                _applyFieldErrors(response.fieldErrors!);
                                                                              }
                                                                            } else {
                                                                              if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
                                                                                _applyFieldErrors(response.fieldErrors!);
                                                                              }
                                                                            }
                                                                          } catch (e) {
                                                                            print(e);
                                                                          }
                                                                          if (mounted) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          }
                                                                        }
                                                                            : null,
                                                                        text:
                                                                        'Save',
                                                                      );
                                                                    }),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 25),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(left: 18),
                                                    child: Text(
                                                      AppString.editProfile,
                                                      style: EditProfile
                                                          .customEditTextStyle(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 18, right: 23),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    IntrinsicHeight(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                FirstSMTextFConst(
                                                                  controller: nameController,
                                                                  keyboardType: TextInputType.text,
                                                                  text: AppString.name,
                                                                  focusNode: _nameFocus,
                                                                ),
                                                                if (_nameError != null)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      _nameError!,
                                                                      style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 15),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 4),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "Select Employee Type",
                                                                      style: AllPopupHeadings.customTextStyle(context),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: ' *',
                                                                          style: AllPopupHeadings.customTextStyle(context)
                                                                              .copyWith(color: ColorManager.red),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 5),
                                                                  FutureBuilder<List<AEClinicalDiscipline>>(
                                                                    future: _employeeTypeFuture,
                                                                    builder: (context, snapshot) {
                                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                                        return HRUManageDropdown(
                                                                          controller: TextEditingController(text: ''),
                                                                          labelFontSize: 12,
                                                                          items: const [],
                                                                        );
                                                                      }
                                                                      if (snapshot.hasData && snapshot.data!.isEmpty) {
                                                                        return HRUManageDropdown(
                                                                          controller: TextEditingController(text: ''),
                                                                          labelFontSize: 12,
                                                                          items: const [],
                                                                        );
                                                                      }
                                                                      if (snapshot.hasData) {
                                                                        List<AEClinicalDiscipline> employeeTypeList = snapshot.data!;
                                                                        List<String> dropDownEmployeeTypes = employeeTypeList
                                                                            .map((employeeType) => employeeType.empType!)
                                                                            .toList();
                                                                        String? selectedEmployeeType = profileData.employeType;
                                                                        print('Employee type ${profileData.employeType}');
                                                                        selectedEmployeeTypeId = profileData.employeeTypeId;
                                                                        return HRUManageDropdown(
                                                                          controller: TextEditingController(text: profileData.employeType),
                                                                          labelFontSize: 12,
                                                                          items: dropDownEmployeeTypes,
                                                                          focusNode: _empTypeFocus,
                                                                          onChanged: (val) {
                                                                            selectedEmployeeTypeId = employeeTypeList
                                                                                .firstWhere((employeeType) => employeeType.empType == val)
                                                                                .employeeTypesId;
                                                                            selectedEmployeeColor = employeeTypeList
                                                                                .firstWhere((employeeType) => employeeType.empType == val)
                                                                                .color;
                                                                            _addressFocus.requestFocus();
                                                                          },
                                                                        );
                                                                      }
                                                                      return const SizedBox();
                                                                    },
                                                                  ),
                                                                  if (_employeeTypeError != null)
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 4),
                                                                      child: Text(
                                                                        _employeeTypeError!,
                                                                        style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 15),
                                                          Expanded(
                                                            flex: 3,
                                                            child: FirstSMTextFConst(
                                                              controller: TextEditingController(text: profileData.department),
                                                              keyboardType: TextInputType.text,
                                                              text: 'Department',
                                                              enable: false,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              AddressInput(
                                                                controller: addressController,
                                                                focusNode: _addressFocus,
                                                                onSuggestionSelected: (selectedSuggestion) {
                                                                  print("Selected suggestion: $selectedSuggestion");
                                                                },
                                                                onChanged: (String) {},
                                                              ),
                                                              if (_addressError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _addressError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              HrUpdateProfileDOB(
                                                                controller: ageController,
                                                                keyboardType: TextInputType.text,
                                                                text: 'DOB',
                                                                showDatePicker: true,
                                                                focusNode: _dobFocus,
                                                              ),
                                                              if (_dobError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _dobError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 3),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                RichText(
                                                                  text: TextSpan(
                                                                    text: "Gender",
                                                                    style: AllPopupHeadings.customTextStyle(context),
                                                                    children: [
                                                                      TextSpan(
                                                                        text: ' *',
                                                                        style: AllPopupHeadings.customTextStyle(context)
                                                                            .copyWith(color: ColorManager.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                FutureBuilder<List<GenderData>>(
                                                                  future: _genderFuture,
                                                                  builder: (context, snapshot) {
                                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                                      return HRUManageDropdown(
                                                                        hintText: "",
                                                                        controller: TextEditingController(text: ''),
                                                                        items: const ['item 1', 'item 2'],
                                                                        labelFontSize: 12,
                                                                      );
                                                                    }
                                                                    if (snapshot.hasData) {
                                                                      List<String> dropDownList = [];
                                                                      for (var i in snapshot.data!) {
                                                                        dropDownList.add(i.gender);
                                                                      }
                                                                      return HRUManageDropdown(
                                                                        hintText: "Gender",
                                                                        labelFontSize: 12,
                                                                        items: dropDownList,
                                                                        focusNode: _genderFocus,
                                                                        onChanged: (newValue) {
                                                                          for (var a in snapshot.data!) {
                                                                            if (a.gender == newValue) {
                                                                              selectedGenderId = a.gender;
                                                                            }
                                                                          }
                                                                          _ssnFocus.requestFocus();
                                                                        },
                                                                        controller: TextEditingController(text: profileData.gender),
                                                                      );
                                                                    } else {
                                                                      return const Offstage();
                                                                    }
                                                                  },
                                                                ),
                                                                if (_genderError != null)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      _genderError!,
                                                                      style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SSNTextFConst(
                                                                controller: ssNController,
                                                                keyboardType: TextInputType.number,
                                                                text: AppString.ssnProfile,
                                                                focusNode: _ssnFocus,
                                                              ),
                                                              if (_ssnError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _ssnError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SMTextFConstPhone(
                                                                controller: phoneNController,
                                                                keyboardType: TextInputType.phone,
                                                                text: AppString.phone_number,
                                                                focusNode: _phoneFocus,
                                                              ),
                                                              if (_phoneError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _phoneError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SMTextFConstPhone(
                                                                controller: workPhoneController,
                                                                keyboardType: TextInputType.text,
                                                                text: AppStringMobile.worNo,
                                                                focusNode: _workPhoneFocus,
                                                              ),
                                                              if (_workPhoneError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _workPhoneError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SMTextFConst(
                                                                controller: personalEmailController,
                                                                keyboardType: TextInputType.text,
                                                                text: AppStringMobile.perEmail,
                                                                focusNode: _personalEmailFocus,
                                                              ),
                                                              if (_personalEmailError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _personalEmailError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SMTextFConst(
                                                                controller: workEmailController,
                                                                keyboardType: TextInputType.text,
                                                                text: AppStringMobile.worEmail,
                                                                focusNode: _workEmailFocus,
                                                              ),
                                                              if (_workEmailError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _workEmailError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              FirstSMTextFConst(
                                                                controller: summaryController,
                                                                keyboardType: TextInputType.text,
                                                                text: AppStringMobile.summry,
                                                                focusNode: _summaryFocus,
                                                              ),
                                                              if (_summaryError != null)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    _summaryError!,
                                                                    style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 5),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                RichText(
                                                                  text: TextSpan(
                                                                    text: "Select Service",
                                                                    style: AllPopupHeadings.customTextStyle(context),
                                                                    children: [
                                                                      TextSpan(
                                                                        text: ' *',
                                                                        style: AllPopupHeadings.customTextStyle(context)
                                                                            .copyWith(color: ColorManager.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                FutureBuilder<List<ServicesMetaData>>(
                                                                  future: _serviceFuture,
                                                                  builder: (context, snapshot) {
                                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                                      return HRUManageDropdown(
                                                                        hintText: '',
                                                                        controller: TextEditingController(text: ''),
                                                                        items: const [],
                                                                        labelFontSize: 12,
                                                                      );
                                                                    }
                                                                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                                                      List<String> serviceNames = snapshot.data!
                                                                          .map((service) => service.serviceName)
                                                                          .toList();
                                                                      return HRUManageDropdown(
                                                                        controller: TextEditingController(text: profileData.service),
                                                                        hintText: 'Select Service',
                                                                        items: serviceNames,
                                                                        focusNode: _serviceFocus,
                                                                        onChanged: (val) {
                                                                          var selectedService = snapshot.data!
                                                                              .firstWhere((service) => service.serviceName == val);
                                                                          selectedServiceId = selectedService.serviceName;
                                                                          _reportingOfficeFocus.requestFocus();
                                                                        },
                                                                        labelFontSize: 12,
                                                                      );
                                                                    }
                                                                    return const Text('No services available');
                                                                  },
                                                                ),
                                                                if (_serviceError != null)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      _serviceError!,
                                                                      style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Expanded(
                                                          flex: 3,
                                                          child: FirstSMTextFConst(
                                                            controller: TextEditingController(text: profileData.regOfficId),
                                                            keyboardType: TextInputType.text,
                                                            text: 'Reporting Office',
                                                            enable: false,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        const Expanded(
                                                          flex: 3,
                                                          child: SizedBox(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              StatefulBuilder(
                                                builder: (BuildContext
                                                context,
                                                    void Function(void
                                                    Function())
                                                    setState) {
                                                  return Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                top: 10.0,
                                                                left: 18,
                                                                bottom: 5),
                                                            child:
                                                            Container(
                                                              height: 20,
                                                              width: 354,
                                                              child: Text(
                                                                  "Coverage",
                                                                  style: AllPopupHeadings
                                                                      .customTextStyle(
                                                                      context)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      FutureBuilder<EmployeeModel>(
                                                          future: _coverageFuture,
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const Center(
                                                                child:
                                                                CircularProgressIndicator(),
                                                              );
                                                            }
                                                            if (snapshot
                                                                .hasError) {
                                                              return const Center(
                                                                child: Text(
                                                                    'Error fetching profile data'),
                                                              );
                                                            }
                                                            if (snapshot
                                                                .hasError) {
                                                              return Center(
                                                                  child:
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                        100),
                                                                    child: Text(
                                                                      "No available coverage!",
                                                                      style: CustomTextStylesCommon.commonStyle(
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                          FontSize
                                                                              .s14,
                                                                          color:
                                                                          ColorManager.mediumgrey),
                                                                    ),
                                                                  ));
                                                            }
                                                            if (snapshot
                                                                .hasData) {
                                                              final coverageList = snapshot.data!.coverageDetails;
                                                              final rowCount = (coverageList.length / 2).ceil();
                                                              return Container(
                                                                width: double.infinity,
                                                                child: Column(
                                                                  children: List.generate(rowCount, (rowIndex) {
                                                                    final firstIndex = rowIndex * 2;
                                                                    final secondIndex = firstIndex + 1;
                                                                    Widget buildCard(int index) {
                                                                      return Expanded(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
                                                                          child: CoverageRowWidget(
                                                                            countyName: coverageList[index].countyName,
                                                                            zoneName: coverageList[index].zoneName,
                                                                            onDelete: () {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) => DeletePopup(
                                                                                  title: DeletePopupString.deleteCoverage,
                                                                                  loadingDuration: _isLoading,
                                                                                  onCancel: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  onDelete: () async {
                                                                                    setState(() {
                                                                                      _isLoading = true;
                                                                                    });
                                                                                    try {
                                                                                      await deleteCoverageEditor(context, coverageList[index].employeeEnrollCoverageId);
                                                                                      _refreshCoverage();
                                                                                    } finally {
                                                                                      setState(() {
                                                                                        _isLoading = false;
                                                                                        Navigator.pop(context);
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              );
                                                                            },
                                                                            onEdit: () {
                                                                              // FIX: compute the future once here, when Edit is tapped, and
                                                                              // capture it in the dialog builder's closure below — instead of
                                                                              // calling getCoveragePreFill() inline inside FutureBuilder's
                                                                              // `future:` param, which re-fires the API call every time the
                                                                              // dialog builder rebuilds (e.g. on MediaQuery/window-resize
                                                                              // changes on web).
                                                                              final _coveragePreFillFuture = getCoveragePreFill(context: context, employeeId: widget.employeeId, employeeEnrollCoverageId: coverageList[index].employeeEnrollCoverageId);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return FutureBuilder(
                                                                                    future: _coveragePreFillFuture,
                                                                                    builder: (context, snapshotPreFill) {
                                                                                      if (snapshotPreFill.connectionState == ConnectionState.waiting) {
                                                                                        return Center(
                                                                                          child: CircularProgressIndicator(color: ColorManager.blueprime),
                                                                                        );
                                                                                      }
                                                                                      var coverageDetails = snapshotPreFill.data!.coverageDetails;
                                                                                      return ProfileBarEditPopup(
                                                                                        employeeId: profileData.employeeId,
                                                                                        employeeEnrollId: profileData.employeeEnrollId,
                                                                                        employeeEnrollCoverageId: coverageList[index].employeeEnrollCoverageId,
                                                                                        onRefresh: () {
                                                                                          _refreshCoverage();
                                                                                        },
                                                                                        countyNameValue: snapshotPreFill.data!.coverageDetails.countyName,
                                                                                        zoneNameValue: snapshotPreFill.data!.coverageDetails.zoneName,
                                                                                        zoneId: snapshotPreFill.data!.coverageDetails.zoneId,
                                                                                        countyId: snapshotPreFill.data!.coverageDetails.countyId,
                                                                                        officeId: profileData.officeId,
                                                                                        zipCode: snapshotPreFill.data!.coverageDetails.zipCodes,
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    return Row(
                                                                      children: [
                                                                        buildCard(firstIndex),
                                                                        if (secondIndex < coverageList.length)
                                                                          buildCard(secondIndex)
                                                                        else
                                                                          const Expanded(child: SizedBox()),
                                                                      ],
                                                                    );
                                                                  }),
                                                                ),
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          }),
                                                      const SizedBox(height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                  context,
                                                                  builder: (BuildContext
                                                                  context) =>
                                                                      ProfileBarAddPopup(
                                                                        officeId:
                                                                        profileData.officeId,
                                                                        employeeId:
                                                                        widget.employeeId,
                                                                        employeeEnrollId:
                                                                        profileData.employeeEnrollId,
                                                                        onRefresh:
                                                                            () {
                                                                          _refreshCoverage();
                                                                        },
                                                                      ));
                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              width: 200,
                                                              decoration:
                                                              BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    14),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .add_circle,
                                                                      size:
                                                                      26,
                                                                      color: ColorManager
                                                                          .blueprime,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                        3),
                                                                    Text(
                                                                      'Add Coverage',
                                                                      style: CustomTextStylesCommon.commonStyle(
                                                                          fontSize:
                                                                          FontSize.s15,
                                                                          fontWeight:
                                                                          FontWeight.w700,
                                                                          color:
                                                                          ColorManager.blueprime),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ]),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: Text('No data available!'),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CoverageRowWidget extends StatelessWidget {
  final String countyName;
  final String zoneName;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CoverageRowWidget({
    Key? key,
    required this.countyName,
    required this.zoneName,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorManager.blueprime,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.only(left: 17, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "County :",
                style: AllPopupHeadings.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              countyName,
              style: EditTextFontStyle.customEditTextStyle(),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: Text(
              "Zones :",
              style: AllPopupHeadings.customTextStyle(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              zoneName,
              style: EditTextFontStyle.customEditTextStyle(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: Icon(Icons.edit_outlined, color: ColorManager.bluebottom, size: IconSize.I16),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 3),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.delete, color: Colors.red, size: IconSize.I16),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfile {
  static TextStyle customEditTextStyle() {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.blueprime,
    );
  }
}

class Coverage {
  static TextStyle customEditTextStyle() {
    return TextStyle(
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w700,
      color: ColorManager.blueprime,
    );
  }
}

class EditTextFontStyle {
  static TextStyle customEditTextStyle() {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
    );
  }
}

class ProfileEditCancelButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double width;
  final double height;
  final TextStyle? style;
  final Widget? child;
  const ProfileEditCancelButton({
    Key? key,
    this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF50B5E5),
    this.textColor = const Color(0xFF50B5E5),
    this.borderRadius = 14.0,
    this.paddingVertical = 12.0,
    this.paddingHorizontal = 16.0,
    this.width = 50,
    this.height = 50.0,
    this.style,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =  CustomTextStylesCommon.commonStyle( color: textColor,
      fontSize: FontSize.s14,
      fontWeight: FontWeight.w600,);
    final mergedTextStyle = defaultTextStyle.merge(style);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
        ],
      ),
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            backgroundColor: ColorManager.white,
            side: const BorderSide(color: Color(0xFF50B5E5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child:
          Text(text!, textAlign: TextAlign.center, style: mergedTextStyle)),
    );
  }
}

class AddressInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSuggestionSelected;
  final Function(String) onChanged;
  final FocusNode? focusNode;

  const AddressInput({required this.controller, this.onSuggestionSelected, required this.onChanged, this.focusNode});

  @override
  _AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCountyNameChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCountyNameChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onCountyNameChanged() async {
    final query = widget.controller.text;
    if (query.isEmpty) {
      _suggestions.clear();
      _removeOverlay();
      return;
    }

    final suggestions = await fetchSuggestions(query);
    setState(() {
      _suggestions = suggestions.isNotEmpty && suggestions[0] != query ? suggestions : [];
    });
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
          children:[
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height,
              width: 354,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _suggestions.length > 5 ? 80.0 : double.infinity,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _suggestions[index],
                            style: TableSubHeading.customTextStyle(context),
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            widget.controller.text = _suggestions[index];
                            _suggestions.clear();
                            _removeOverlay();

                            if (widget.onSuggestionSelected != null) {
                              widget.onSuggestionSelected!(_suggestions[index]);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return FirstSMTextFConst(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      text: AppString.addresss,
      focusNode: widget.focusNode,
    );
  }
}