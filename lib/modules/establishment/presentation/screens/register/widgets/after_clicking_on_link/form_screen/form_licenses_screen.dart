import 'dart:async';
import 'dart:html' as html;
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_licenses_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

// NEW: model used to read the per-field server validation errors

class LicenseService {
  static Future<void> perfFormLicense({
    required BuildContext context,
    required String country,
    required int employeeId,
    required String expDate,
    required String issueDate,
    required String licenseUrl,
    required String licensure,
    required String licenseNumber,
    required String org,
    required String documentType,
    dynamic documentFile, // optional
    String? documentName, // optional
  }) async {
    // Step 1: Submit license data
    ApiDataRegister response = await postlicensesscreenData(
      context,
      country,
      employeeId,
      expDate,
      issueDate,
      licenseUrl,
      licensure,
      licenseNumber,
      org,
      documentType,
    );

    print('📄 License ID from API: ${response.licenses}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save license: ${response.message}');
    }

    // Step 2: Conditionally upload document
    if (documentFile != null && documentFile != 'NA') {
      try {
        await uploadlinceses(
          context: context,
          employeeid: employeeId,
          documentFile: documentFile,
          documentName: documentName ?? 'Document',
          licensedId: response.licenses!,
        );
        print('📎 Document uploaded for licenseId: ${response.licenses}');
      } catch (e) {
        print('❌ Document upload failed: $e');
        // Optionally rethrow or handle silently
      }
    } else {
      print('ℹ️ No document file provided, skipping upload.');
    }
  }
}




class LicensesScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;
  const LicensesScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack, required this.onNext,
  });

  final BuildContext context;

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  List<GlobalKey<licensesFormState>> licenseFormKeys = [];
  bool isVisible = false;

  bool isLoading =false;
  double textFieldWidth = 430;
  double textFieldHeight = 38;

  TextEditingController firstName = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadLicensesData();
  }
  Future<void> _loadLicensesData() async {
    try {
      List<LicensesDataForm> prefilledData = await getLicensesForm(context, widget.employeeID);

      if (!mounted) return; // ⬅️ Add this line before setState

      if (prefilledData.isEmpty) {
        addLicensesForm();
      } else {
        setState(() {
          licenseFormKeys = List.generate(
            prefilledData.length,
                (index) => GlobalKey<licensesFormState>(),
          );
        });

        final providerState = Provider.of<HrProgressMultiStape>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) providerState.isLicenseChnaged();
        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }

  void addLicensesForm() {
    setState(() {
      licenseFormKeys.add(GlobalKey<licensesFormState>());
    });
  }

  void removeLicensesForm(GlobalKey<licensesFormState> key) {
    setState(() {
      licenseFormKeys.remove(key);
    });
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HRLicenseProvider>(context);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p150),
          child: FormsBlueHeaderBulletsConst(
            bullets: [
              'Please fill all the current and relevant licensure / certification below. If you are applying for a clinical or attorney position which is lists licensure in the requirements, your information will be required to proceed through the requirements process.',
              'Please note, MSW and Chaplains do not need a License. Rather, they need academic credentials.',
              'Clinical Staff MUST fill this section out. ',
            ],
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Column(
          children: licenseFormKeys.asMap().entries.map((entry) {
            int index = entry.key;
            GlobalKey<licensesFormState> key = entry.value;
            return licensesForm(
              key: key,
              index: index + 1,
              onRemove: () => removeLicensesForm(key),
              employeeID: widget.employeeID, isVisible: isVisible,
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppPadding.p150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isVisible = true;
                    addLicensesForm();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff50B5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Licenses',
                  style: BlueButtonTextConst.customTextStyle(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            FormOutlineButtonConst(
              text: 'Previous',
              onPressed: () {
                widget.onBack();
              },
            ),
            const SizedBox(
              width: 30,
            ),
            FormSaveButtonConst(
              isLoading: provider.isLoading,
              onPressed: () async {
                final provider = Provider.of<HRLicenseProvider>(context, listen: false);

                if (!mounted) return;

                for (var key in licenseFormKeys) {
                  key.currentState?.clearFieldErrors();
                }

                final result = await provider.saveLicenses(
                  licenseFormKeys: licenseFormKeys,
                  employeeId: widget.employeeID,
                  context: context,
                );

                if (!mounted) return;

                // UPDATED: only refresh + show success when there were zero failures
                if (result.saved > 0 && result.failed == 0) {
                  await _loadLicensesData();

                  await showDialog(
                    context: context,
                    builder: (_) => const AddSuccessPopup(
                      message: 'Licenses Document Saved Successfully.',
                    ),
                  );

                  // UPDATED: onSave() now only fires on a fully clean save —
                  // previously this ran unconditionally at the bottom
                  widget.onSave();
                }

                if (result.failed > 0) {
                  // UPDATED: show the real server message instead of a generic count
                  await showDialog(
                    context: context,
                    builder: (_) => AddErrorPopup(
                      message: result.lastErrorMessage ?? AppString.somethingWentWrong,
                    ),
                  );
                }
                // No navigation happens when result.failed > 0
              },
            ),
            const SizedBox(
              width: AppSize.s30,
            ),
            FormOutlineButtonConst(
              text: 'Next',
              onPressed: () {
                widget.onNext();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class licensesForm extends StatefulWidget {
  final int employeeID;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  const licensesForm(
      {Key? key,
        required this.onRemove,
        required this.index,
        required this.employeeID, required this.isVisible})
      : super(key: key);

  @override
  licensesFormState createState() => licensesFormState();
}

class licensesFormState extends State<licensesForm> {
  bool isPrefill= true;
  TextEditingController firstName = TextEditingController();
  TextEditingController licensure = TextEditingController();
  TextEditingController org = TextEditingController();
  TextEditingController licensurenumber = TextEditingController();
  TextEditingController controllerIssueDate = TextEditingController();
  TextEditingController controllerExpirationDate = TextEditingController();
  TextEditingController controllercountry= TextEditingController(text: 'United States Of America');

  int? licenseIdIndex;
  String? licenseUrl;
  String? licenseFullUrl;
  String? docName;
  int countryId =0;
  String? selectedCountry ='Select';
  String? documentTypeName ='Select';

  final StreamController<List<AEClinicalReportingOffice>> Countrystream =
  StreamController<List<AEClinicalReportingOffice>>();

  bool fileAbove20Mb = false;

  // ---------------------------------------------------------------------
  // NEW: per-field error strings driven by the server's `key` values
  // (matching the POST body field names sent to postlicensesscreenData)
  // ---------------------------------------------------------------------
  String? _licensureError;
  String? _orgError;
  String? _countryError;
  String? _licenseNumberError;
  String? _documentTypeError;
  String? _expDateError;
  String? _issueDateError;

  /// Maps the server's [ErrorDetail.key] values onto this specific
  /// license form's error variables. Public (no leading underscore) so
  /// the parent/provider can call it via the GlobalKey's currentState.
  void applyFieldErrors(List<ErrorDetail> errors) {
    if (!mounted) return;
    setState(() {
      for (final e in errors) {
        switch (e.key) {
          case 'licensure':
            _licensureError = e.message;
            break;
          case 'org':
            _orgError = e.message;
            break;
          case 'country':
            _countryError = e.message;
            break;
          case 'licenseNumber':
            _licenseNumberError = e.message;
            break;
          case 'documentType':
            _documentTypeError = e.message;
            break;
          case 'expDate':
            _expDateError = e.message;
            break;
          case 'issueDate':
            _issueDateError = e.message;
            break;
          default:
          // Unmapped key — the toast/dialog message already shown covers it.
            break;
        }
      }
    });
  }

  /// Clears all server-driven field errors on this form. Call before a
  /// fresh submit so stale errors from a previous attempt don't linger.
  void clearFieldErrors() {
    if (!mounted) return;
    setState(() {
      _licensureError = null;
      _orgError = null;
      _countryError = null;
      _licenseNumberError = null;
      _documentTypeError = null;
      _expDateError = null;
      _issueDateError = null;
    });
  }

  // ── Cached futures — prevent refetch/rebuild loop on every build ──
  late Future<List<CountryGetData>> _countryFuture;
  late Future<List<NewOrgDocument>> _orgDocFuture;

  void initState() {
    super.initState();
    HrAddEmplyClinicalReportingOfficeApi(context, 11).then((data) {
      Countrystream.add(data);
    }).catchError((error) {});
    _initializeFormWithPrefilledData();
    _countryFuture = getCountry(context: context);
    _orgDocFuture = getNewOrgDocfetch(context,
        FrontendConfigStore.data!.config.corporateAndCompliance,
        FrontendConfigStore.data!.config.subDocId1Licenses, 1, 200);
  }

  List<String> _fileNames = [];
  bool _loading = false;
  Future<void> _initializeFormWithPrefilledData() async {
    try {
      List<LicensesDataForm> prefilledData = await getLicensesForm(context, widget.employeeID);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1]; // Assuming index matches the data list
        setState(() {
          firstName.text = data.documentType ?? '';
          licensure.text = data.licensure ?? '';
          org.text = data.org ?? '';
          licensurenumber.text = data.licenseNumber ?? '';
          controllerIssueDate.text = data.issueDate ?? '';
          controllerExpirationDate.text = data.expDate ?? '';
          selectedCountry = (data.country == '--' || data.country == null) ? 'Select' : data.country!;
          documentTypeName = (data.documentType == '--' || data.documentType == null) ? 'Select' : data.documentType!;

          licenseUrl = data.licenseUrl.split('/').last;
          licenseFullUrl = data.licenseUrl;
          docName = data.documentName;
        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }


  bool _documentUploaded = true;
  var fileName;
  var fileName1;
  dynamic filePath;
  File? xfileToFile;
  var finalPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Licensure / Certification #${widget.index}',
                style: HeadingFormStyle.customTextStyle(context),
              ),
              if (widget.index > 1)
                IconButton(
                  icon:
                  const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFieldRegister(
                      header: 'Licensure / Certification',
                      controller: licensure,
                      hintText: 'Enter Licensure / Certification',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    ),
                    // NEW: server-driven error for Licensure / Certification
                    if (_licensureError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _licensureError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Issuing Organization',
                      controller: org,
                      hintText: 'Enter Organization Name',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                    ),
                    // NEW: server-driven error for Issuing Organization
                    if (_orgError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _orgError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    Text(
                      'Country',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setState) { return
                        FutureBuilder<List<CountryGetData>>(
                          future: _countryFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                height: 30,
                                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedCountry!,
                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                    ),
                                    const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                                  ],
                                ),

                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '',
                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                    ),
                                    const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                                  ],
                                ),

                              );
                            } else if (snapshot.hasData) {
                              List<DropdownMenuItem<String>> dropDownList = [];
                              int countryId = 0;

                              // Populate the dropdown list from the fetched data
                              for (var i in snapshot.data!) {
                                dropDownList.add(DropdownMenuItem<String>(
                                  child: Text(i.name),
                                  value: i.name,
                                ));
                              }

                              // Use the prefilled country if available, otherwise default to the first item
                              String initialValue = selectedCountry ?? "Select";


                              return CustomDropdownTextFieldwidh(
                                dropDownMenuList: dropDownList,
                                onChanged: (newValue) {
                                  isPrefill = false;
                                  for (var a in snapshot.data!) {
                                    if (a.name == newValue) {
                                      selectedCountry = a.name;
                                      countryId = a.countryId;
                                      print("Country :: ${selectedCountry}");
                                      print("Country ID :: ${countryId}");
                                    }
                                  }
                                },
                                hintText: initialValue,
                                height: 31,
                              );
                            } else {
                              return CustomDropdownTextField(
                                headText: 'Country',
                                items: const ['No Data'],
                              );
                            }
                          },
                        ); },

                    ),
                    // NEW: server-driven error for Country
                    if (_countryError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _countryError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      maxLength: 20,
                      header: 'Number / ID',
                      controller: licensurenumber,
                      hintText: 'Enter Number',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        setState(() {
                          if(value.isNotEmpty){
                            isPrefill= false;
                            _licenseNumberError = null;
                          }
                        });
                      },
                    ),
                    // NEW: server-driven error for Number / ID
                    if (_licenseNumberError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _licenseNumberError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(flex:1, child: Container()),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Type',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setState) {
                        return FutureBuilder<List<NewOrgDocument>>(
                          future: _orgDocFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                height: 30,
                                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      documentTypeName!,
                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                    ),
                                    const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                                  ],
                                ),

                              );
                            } else if (snapshot.hasError ||snapshot.data ==null ) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'No Data Available',
                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                    ),
                                    const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                                  ],
                                ),

                              );
                            } else if (snapshot.hasData) {

                              List<DropdownMenuItem<String>> dropDownList = [];

                              for (var i in snapshot.data!) {
                                dropDownList.add(DropdownMenuItem<String>(
                                  child: Text(i.docName),
                                  value: i.docName,
                                ));
                              }

                              String initialValue = documentTypeName ?? "Select";
                              return CustomDropdownTextFieldwidh(
                                dropDownMenuList: dropDownList,
                                onChanged: (newValue) {
                                  isPrefill = false;
                                  for (var a in snapshot.data!) {
                                    if (a.docName == newValue) {
                                      documentTypeName = a.docName;
                                      print("Document Type :: ${documentTypeName}");
                                    }
                                  }
                                },
                                hintText: initialValue,
                                height: 31,
                              );

                            } else {
                              return CustomDropdownTextField(
                                headText: 'Select Document',
                                items: const ['No Data'],
                              );
                            }
                          },
                        );
                      },
                    ),
                    // NEW: server-driven error for Document Type
                    if (_documentTypeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _documentTypeError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Expiration Date',
                      readOnly: true,
                      onTap:  () async {
                        DateTime? pickedDate =
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                          DateFormat('yyyy-MM-dd')
                              .format(pickedDate);
                          controllerExpirationDate.text =
                              formattedDate;
                        }
                      },
                      controller: controllerExpirationDate,
                      hintText: 'yyyy-mm-dd',
                      hintStyle: onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                      suffixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xff50B5E5),
                        size: 22,
                      ),


                    ),
                    // NEW: server-driven error for Expiration Date
                    if (_expDateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _expDateError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSizeConst.A20),
                    CustomTextFieldRegister(
                      header: 'Issue Date',
                      readOnly: true,
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(now.year, now.month + 1, now.day),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                          controllerIssueDate.text = formattedDate;
                        }
                      },
                      controller: controllerIssueDate,
                      hintText: 'yyyy-mm-dd',
                      hintStyle:onlyFormDataStyle.customTextStyle(context),
                      height: 32,
                      onChanged: (value){
                        if(value.isNotEmpty){
                          isPrefill= false;
                        }
                      },
                      suffixIcon:  const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xff50B5E5),
                        size: 22,
                      ),


                    ),
                    // NEW: server-driven error for Issue Date
                    if (_issueDateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _issueDateError!,
                          style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                        ),
                      ),
                    const SizedBox(height: AppSize.s5),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,  // Set the fixed height
                            child: Text(
                              'If the licensure / certification will be recieved in future, enter the expected issuing date.',
                              style: onlyFormDataStyle.customTextStyle(context),
                              overflow: TextOverflow.ellipsis,  // Optional: handle overflow text
                              maxLines: 5,  // Optional: limit the number of lines
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Upload your licensure / certifications as a pdf.',
                  style:FileuploadString.customTextStyle(context),
                ),
              ),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) {return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () async{
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf']
                          );

                          // UPDATED: guard result/files.isEmpty BEFORE touching .first,
                          // instead of relying on result?.files.first.size (crashes if
                          // the user cancels the picker or files list is empty).
                          if (result == null || result.files.isEmpty) {
                            return;
                          }

                          final file = result.files.first;
                          final fileSize = file.size; // File size in bytes
                          final isAbove20MB = fileSize > (20 * 1024 * 1024); // Check if file is larger than 20MB

                          if (isAbove20MB) {
                            // If the file is larger than 20MB, show an error message
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddErrorPopup(
                                  message: 'File is too large!',
                                );
                              },
                            );
                          } else {
                            // If the file is less than 20MB, proceed with the upload process
                            setState(() {
                              fileName = file.name;
                              docName = file.name; // FIX: keep docName in sync with the freshly picked file
                              finalPath = file.bytes;
                              fileAbove20Mb = false; // This flag indicates that the file is below 20MB
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff50B5E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),

                        ),
                        icon: docName == "--" ? const Icon(Icons.upload, color: Colors.white):null,
                        label:docName == null ?Text(
                          'Upload File',
                          style: BlueButtonTextConst.customTextStyle(context),
                        ):Text(
                          'Uploaded',
                          style:  BlueButtonTextConst.customTextStyle(context),
                        )
                    ),
                    const SizedBox(height: 8,),
                    // UPDATED: collapsed the old two-branch (docName != null / fileName != null)
                    // logic into a single docName-driven branch, since docName is now always
                    // set whenever fileName is set. This removes the null-crash path where
                    // the "File picked" branch called docName! while docName was still null.
                    docName != null
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          licenseFullUrl != null && licenseFullUrl!.isNotEmpty
                              ? 'Uploaded File: '
                              : 'File picked: ',
                          style: onlyFormDataStyle.customTextStyle(context),
                        ),
                        InkWell(
                          onTap: () async {
                            if (licenseFullUrl != null && licenseFullUrl!.isNotEmpty) {
                              // Previously submitted (prefilled) file: download it.
                              await downloadFile(
                                context: context,
                                fileUrl: licenseFullUrl!,
                                documentName: docName!,
                                apiPath: DownloadDocumentRepository.getEmployeeLicensesDocumentByFileName(),
                              );
                            } else if (finalPath != null) {
                              // Freshly picked (not yet submitted) file: preview locally.
                              final blob = html.Blob([finalPath], 'application/pdf');
                              final url = html.Url.createObjectUrlFromBlob(blob);
                              html.window.open(url, '_blank');
                            }
                          },
                          child: AutoSizeText(
                            docName!,
                            style: onlyFormDataStyle.customTextStyle(context).copyWith(
                              decoration: TextDecoration.underline,
                              color: const Color(0xff50B5E5),
                            ),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox(),
                  ],
                );  },

              ),
            ],
          ),
          const SizedBox(height: AppSizeConst.A20),
          const Divider(
            color: Colors.grey,
            thickness: 2,
          ),
          const SizedBox(height: AppSizeConst.A20),
        ],
      ),
    );
  }

}


//dobided919@ehwit.com