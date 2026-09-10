import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_general_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/onlink_general_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onlink_general/onlink_general_data.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/speciality_modeldata.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/toast_notify.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';

class generalForm extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onNext;
  const generalForm({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onNext,
  });

  final BuildContext context;

  @override
  State<generalForm> createState() => _generalFormState();
}

class _generalFormState extends State<generalForm> {
  double textFieldWidth = 430;
  double textFieldHeight = 38;

  TextEditingController dobcontroller = TextEditingController();
  TextEditingController dobcontrollervv = TextEditingController();

  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController ssecuritynumber = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController personalemail = TextEditingController();
  TextEditingController driverlicensenumb = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController spalicity = TextEditingController();

  int _currentStep = 0;
  bool isChecked = false;
  bool isDobSelected = false;
  String? specialityName;
  int specialityId = 0;
  late Future<List<SpecialityModeldata>> _specialityFuture;
  String? clinicialName;
  bool get isFirstStep => _currentStep == 0;
  bool isCompleted = false;
  String? _selectedCountry;
  String? _selectedClinician;
  String? _selectedSpeciality;
  String? _selectedDegree;
  late bool _passwordVisible = false;
  String? gendertype;
  int? generalId;
  bool isLoading = false;
  String? racetype;

  String? _fileNames;
  bool _loading = false;
  bool _documentUploaded = true;
  var fileName;
  var fileName1;
  dynamic filePath;
  File? xfileToFile;
  var finalPath;
  String? signatureUrl;

  // holds the employee's existing/prefilled photo URL from the API,
  // shown until the user picks a new file.
  String? _prefilledImageUrl;

  // ---------------------------------------------------------------------
  // Per-field error strings driven by the server's `key` values
  // ---------------------------------------------------------------------
  String? _ssnError;
  String? _mobileError;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _driverLicenseError;
  String? _specialityError;

  // simple client-side validators, reused in onChanged and in the Save guard
  bool _isValidSsn(String value) => RegExp(r'^\d{9}$').hasMatch(value);

  bool _isValidEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  bool _isValidDriverLicenseLength(String value) =>
      value.isEmpty || (value.length >= 5 && value.length <= 16);

  // strips any query string (?AWSAccessKeyId=...&Signature=...) off a
  // signed S3 URL so only the real file name remains.
  String _extractDisplayFileName(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    final lastSegment = rawUrl.split('/').last;
    return lastSegment.split('?').first;
  }

  // NEW — always returns a short, complete filename that never needs
  // ellipsis truncation in the UI. Keeps the first 2 UUID segments
  // (e.g. "a895c094-2d4b-4937-96d6") + the original extension, so the
  // label always ends cleanly with .png / .jpg / etc, never with "...".
  String _formatDisplayFileName(String rawUrl) {
    final extracted = _extractDisplayFileName(rawUrl);
    if (extracted.isEmpty) return '';

    final dotIndex = extracted.lastIndexOf('.');
    final ext = dotIndex != -1 ? extracted.substring(dotIndex) : '';
    final nameOnly = dotIndex != -1 ? extracted.substring(0, dotIndex) : extracted;

    final parts = nameOnly.split('-');
    final shortName = parts.length >= 2 ? parts.take(2).join('-') : nameOnly;

    return '$shortName$ext';
  }

  void _applyFieldErrors(List<ErrorDetail> errors) {
    setState(() {
      _ssnError = null;
      _mobileError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _driverLicenseError = null;
      _specialityError = null;

      for (final e in errors) {
        switch (e.key) {
          case 'SSNNbr':
            _ssnError = e.message;
            break;
          case 'primaryPhoneNbr':
            _mobileError = e.message;
            break;
          case 'personalEmail':
            _emailError = e.message;
            break;
          case 'firstName':
            _firstNameError = e.message;
            break;
          case 'lastName':
            _lastNameError = e.message;
            break;
          case 'driverLicenceNbr':
            _driverLicenseError = e.message;
            break;
          case 'expertise':
            _specialityError = e.message;
            break;
          default:
            break;
        }
      }
    });
  }

  void _clearFieldErrors() {
    setState(() {
      _ssnError = null;
      _mobileError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _driverLicenseError = null;
      _specialityError = null;
    });
  }

  Widget buildSpecialityDropdown(BuildContext context) {
    return FutureBuilder<List<SpecialityModeldata>>(
      future: _specialityFuture,
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
                  spalicity.text.isNotEmpty ? spalicity.text : 'Select',
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

          for (var i in snapshot.data!) {
            dropDownList.add(DropdownMenuItem<String>(
              child: Text(i.speciality),
              value: i.speciality,
            ));
          }

          String initialValue = spalicity.text.isNotEmpty ? spalicity.text : "Select";

          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return CustomDropdownTextFieldwidh(
                menuMaxHeight: 150,
                dropDownMenuList: dropDownList,
                onChanged: (newValue) {
                  for (var a in snapshot.data!) {
                    if (a.speciality == newValue) {
                      this.setState(() {
                        spalicity.text = a.speciality;
                        specialityId = a.specialityId;
                        _specialityError = null;
                        print("Speciality :: ${spalicity.text}");
                      });
                    }
                  }
                },
                hintText: initialValue,
                height: 31,
              );
            },
          );
        } else {
          return CustomDropdownTextField(
            headText: 'Speciality',
            items: const ['No Data'],
          );
        }
      },
    );
  }

  void initState() {
    super.initState();
    _specialityFuture = getSpecialityListByDeptId(context: context);
    _initializeFormWithPrefilledData();
  }

  var fetchedData;
  Future<void> _initializeFormWithPrefilledData() async {
    try {
      OnlinkGeneralData onlinkGeneralData = await getGeneralIdPrefill(context, widget.employeeID);
      fetchedData = onlinkGeneralData;
      var data = onlinkGeneralData;
      setState(() {
        print("Inside function");
        final providerState = Provider.of<HrProgressMultiStape>(context,listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          providerState.isGeneralChnaged();
        });

        if (!isDobSelected && data.dateOfBirth.isNotEmpty) {
          DateTime apiDob = DateTime.parse(data.dateOfBirth!);
          DateTime today = DateTime.now();

          if (apiDob.year == today.year && apiDob.month == today.month && apiDob.day == today.day) {
            dobcontroller.text = '';
          } else {
            dobcontroller.text = data.dateOfBirth!;
          }
        }

        firstname.text = data.firstName ?? '';
        lastname.text = data.lastName ?? '';
        ssecuritynumber.text = data.SSNNbr ?? '';
        phonenumber.text = data.primaryPhoneNbr ?? '';
        personalemail.text = data.personalEmail ?? '';
        driverlicensenumb.text = data.driverLicenceNbr ?? '';
        address.text = data.address ?? '';
        spalicity.text = data.expertise ?? '';
        racetype = data.race ?? "";
        gendertype = data.gender ?? "";
        generalId = data.employeeId ?? 0;
        signatureUrl = data.signatureURL ?? "";
        // UPDATED: use the shortened, never-truncated formatter instead of
        // the raw extractor, so the label always fits without "..."
        fileName = _formatDisplayFileName(data.imgurl ?? "");
        // capture the existing photo URL so we can preview it below,
        // but only when the user hasn't already picked a new local file.
        _prefilledImageUrl = (data.imgurl != null && data.imgurl.isNotEmpty)
            ? data.imgurl
            : null;
      });
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }

  Future<WebFile> saveFileFromBytes(dynamic bytes, String fileName) async {
    final blob = html.Blob(bytes);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final file = html.File([blob], fileName);
    print(file.toString());
    return WebFile(file, url);
  }

  Future<XFile> convertBytesToXFile(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final file = html.File([blob], fileName);
    print("XFILE ${url}");
    return XFile(url);
  }

  Future<Uint8List> loadFileBytes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/somefile.txt');
    if (await file.exists()) {
      return await file.readAsBytes();
    } else {
      throw Exception('File not found');
    }
  }

  List<String> _suggestions = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _onCountyNameChanged() async {
    if (address.text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    final suggestions = await fetchSuggestions(address.text);
    if (suggestions[0] == address.text) {
      setState(() {
        _suggestions.clear();
      });
    } else if (address.text.isEmpty) {
      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  String? _addressDocError;
  String? _dobDocError;
  String? _genderError;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p150),
            child: FormsBlueHeaderConst(
              text: 'Please fill all your personal information below. Your personal details will be required to proceed through the recruitment process.',
            ),
          ),
          const SizedBox(height: AppSizeConst.A20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p150),
            child:
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─────────────────────────────────────────────────────
                      // UPLOAD PHOTO SECTION

                      // ─────────────────────────────────────────────────────
                      StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload Photo",
                              style: AllPopupHeadings.customTextStyle(context),
                            ),
                            const SizedBox(height: AppSize.s5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff50B5E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpeg','jpg','png']
                                    );

                                    if (result != null) {
                                      print("Result::: ${result}");

                                      try {
                                        Uint8List? bytes = result.files.first.bytes;
                                        XFile xlfile =
                                        XFile(result.xFiles.first.path);
                                        xfileToFile = File(xlfile.path);

                                        print(
                                            "::::XFile To File ${xfileToFile.toString()}");
                                        XFile xFile = await convertBytesToXFile(
                                            bytes!, result.xFiles.first.name);

                                        fileName = _formatDisplayFileName(
                                            result.files.first.name);
                                        print('File picked: ${fileName}');
                                        finalPath = result.files.first.bytes;
                                        setState(() {
                                          _fileNames;
                                          _documentUploaded = true;
                                          // a freshly picked file takes over the preview,
                                          // so drop the old prefilled image reference.
                                          _prefilledImageUrl = null;
                                        });
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  },
                                  label: Text(
                                    "Choose File",
                                    style: BlueButtonTextConst.customTextStyle(context),
                                  ),
                                  icon: const Icon(Icons.file_upload_outlined),
                                ),
                                if (finalPath != null)
                                  Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              finalPath as Uint8List,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -8,
                                          right: -8,
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            onTap: () {
                                              setState(() {
                                                finalPath = null;
                                                fileName = null;
                                              });
                                            },
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: ColorManager.bordercolorcontainer),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 12,
                                                color: ColorManager.blueprime,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_prefilledImageUrl != null && _prefilledImageUrl!.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    width: 60,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _prefilledImageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor: Colors.grey.shade100,
                                            child: Container(color: Colors.grey.shade300),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey.shade400,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Filename label — driven by `fileName`, which is
                            // always the short formatted string now, so this
                            // shows correctly for both a fresh pick AND a
                            // prefilled/reloaded value without truncation.
                            if (_loading)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Uploading...',
                                  style: onlyFormDataStyle.customTextStyle(context),
                                ),
                              )
                            else if (fileName != null && fileName.toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 300),
                                  child: Text(
                                    'File picked: $fileName',
                                    style: onlyFormDataStyle.customTextStyle(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: AppSizeConst.A20,),
                          ],
                        );
                      },

                      ),

                      const SizedBox(height: AppSizeConst.A20,),
                      CustomTextFieldRegister(
                        header: 'Legal First Name',
                        controller: firstname,
                        hintText: 'Enter First Name',
                        hintStyle: onlyFormDataStyle.customTextStyle(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        height: 32,
                      ),
                      if (_firstNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _firstNameError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                      const SizedBox(height: AppSizeConst.A20,),
                      CustomTextFieldRegister(
                        header: 'Legal Last Name',
                        controller: lastname,
                        hintText: 'Enter Last Name',
                        hintStyle: onlyFormDataStyle.customTextStyle(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        height: 32,
                      ),
                      if (_lastNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _lastNameError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                      const SizedBox(height: AppSizeConst.A20,),
                      Text(
                        'Social Security Number',
                        style: AllPopupHeadings.customTextStyle(context),
                      ),
                      const SizedBox(height: AppSize.s5),
                      StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return CustomTextFieldSSn(
                            controller: ssecuritynumber,
                            hintText: 'Enter Security Number',
                            obscureText: !_passwordVisible,
                            hintStyle: onlyFormDataStyle.customTextStyle(context),
                            onChanged: (value) {
                              this.setState(() {
                                if (value.isEmpty) {
                                  _ssnError = null;
                                } else if (_isValidSsn(value)) {
                                  _ssnError = null;
                                } else {
                                  _ssnError = 'SSN must be exactly 9 digits';
                                }
                              });
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                color: const Color(0xff50B5E5),
                                size: 16,
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            height: 32,
                            keyboardType:  TextInputType.number,
                          ); },

                      ),
                      if (_ssnError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _ssnError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                      const SizedBox(height: AppSizeConst.A20),
                      Text(
                        'Personal Mobile Number',
                        style:  AllPopupHeadings.customTextStyle(context),
                      ),
                      const SizedBox(height: AppSize.s5),
                      CustomTextFieldRegisterPhone(
                        controller: phonenumber,
                        keyboardType: TextInputType.name,
                        hintText: 'Enter Mobile Number',
                        hintStyle: onlyFormDataStyle.customTextStyle(context),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              _mobileError = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        height: 32,
                      ),
                      if (_mobileError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _mobileError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                      const SizedBox(height: AppSizeConst.A20),
                      Text(
                        'Personal Email',
                        style:  AllPopupHeadings.customTextStyle(context),
                      ),
                      const SizedBox(height: AppSize.s5),
                      CustomTextFieldForEmail(
                        controller: personalemail,
                        hintText: 'Enter Email',
                        hintStyle:  onlyFormDataStyle.customTextStyle(context),
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              _emailError = null;
                            } else if (_isValidEmail(value)) {
                              _emailError = null;
                            } else {
                              _emailError = 'Please enter a valid email address.';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        height: 32,
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _emailError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                      const SizedBox(height: AppSizeConst.A20),
                      CustomTextFieldRegister(
                        header: "Driver's License Number",
                        controller: driverlicensenumb,
                        hintText: "Enter License Number",
                        hintStyle: onlyFormDataStyle.customTextStyle(context),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                          LengthLimitingTextInputFormatter(16),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              _driverLicenseError = null;
                            } else if (value.length < 5 || value.length > 16) {
                              _driverLicenseError = 'License number must be between 5 and 16 characters';
                            } else {
                              _driverLicenseError = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value.length < 5 || value.length > 16) {
                            return 'License number must be between 5 and 16 characters';
                          }
                          return null;
                        },
                        height: 32,
                      ),
                      if (_driverLicenseError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _driverLicenseError!,
                            style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(flex:1,child: Container()),
                Expanded(flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: AppSize.s5),
                      RichText(
                        text: TextSpan(
                          text: "Gender",
                          style: AllPopupHeadings.customTextStyle(context),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: AllPopupHeadings.customTextStyle(context).copyWith(color: ColorManager.red),
                            ),
                          ],
                        ),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) { return  Container(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              CustomRadioListTile(
                                title: 'Male',
                                value: 'Male',
                                groupValue: gendertype,
                                onChanged: (value) {
                                  setState(() {
                                    gendertype = value;
                                    _genderError = null;
                                  });
                                },
                              ),
                              CustomRadioListTile(
                                title: 'Female',
                                value: 'Female',
                                groupValue: gendertype,
                                onChanged: (value) {
                                  setState(() {
                                    gendertype = value;
                                    _genderError = null;
                                  });
                                },
                              ),
                              CustomRadioListTile(
                                title: 'Other',
                                value: 'Other',
                                groupValue: gendertype,
                                onChanged: (value) {
                                  setState(() {
                                    gendertype = value;
                                    _genderError = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        );  },

                      ),
                      if (_genderError != null)
                        Row(
                          children: [
                            Text(
                              _genderError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: FontSize.s10,
                              ),
                            ),
                          ],
                        )else
                        const SizedBox(height:12),
                      const SizedBox(height: AppSizeConst.A20),
                      RichText(
                        text: TextSpan(
                          text: 'DOB',
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
                      CustomTextFieldRegister(
                        onTap:() async {
                          final now = DateTime.now();
                          final maxDate = DateTime(now.year - 21, now.month, now.day);

                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: maxDate,
                            firstDate: DateTime(1900),
                            lastDate: maxDate,
                          );
                          if (pickedDate != null) {
                            dobcontroller.text =
                            "${pickedDate.toLocal()}".split(' ')[0];
                            setState(() {
                              isDobSelected = true;
                              _dobDocError = null;
                            });
                          }
                        } ,
                        readOnly: true,
                        controller: dobcontroller,
                        hintText: 'yyyy-mm-dd',
                        hintStyle: onlyFormDataStyle.customTextStyle(context),
                        height: 32,
                        suffixIcon:  const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xff50B5E5),
                          size: 22,
                        ),
                      ),

                      if (_dobDocError != null)
                        Row(
                          children: [
                            Text(
                              _dobDocError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: FontSize.s10,
                              ),
                            ),
                          ],
                        )else
                        const SizedBox(height: AppSizeConst.A20),

                      AddressInput(
                        controller: address,
                        onSuggestionSelected: (selectedSuggestion) {
                          print("Selected suggestion: $selectedSuggestion");
                        },
                        onChanged: (String value) {
                          setState(() {
                            if (value.isEmpty) {
                              _addressDocError = 'Address cannot be empty';
                            } else {
                              _addressDocError = null;
                            }
                          });
                        },
                      ),
                      if (_addressDocError != null)
                        Row(
                          children: [
                            Text(
                              _addressDocError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: FontSize.s10,
                              ),
                            ),
                          ],
                        )else
                        const SizedBox(),

                      const SizedBox(height: AppSizeConst.A20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Speciality',
                            style: AllPopupHeadings.customTextStyle(context),
                          ),
                          const SizedBox(height: AppSize.s5),
                          buildSpecialityDropdown(context),
                          if (_specialityError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _specialityError!,
                                style: const TextStyle(color: Colors.red, fontSize: FontSize.s10),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSizeConst.A20),
                      Text(
                        "Race",
                        style: AllPopupHeadings.customTextStyle(context),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {  return Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      CustomRadioListTile(
                                        title: 'Asian',
                                        value: 'Asian',
                                        groupValue: racetype,
                                        onChanged: (value) {
                                          setState(() {
                                            racetype = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      CustomRadioListTile(
                                        title: 'White',
                                        value: 'White',
                                        groupValue: racetype,
                                        onChanged: (value) {
                                          setState(() {
                                            racetype = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [

                                      CustomRadioListTile(
                                        title: 'Hispanic or Latino',
                                        value: 'Hispanic or Latino',
                                        groupValue: racetype,
                                        onChanged: (value) {
                                          setState(() {
                                            racetype = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      CustomRadioListTile(
                                        title: 'Other',
                                        value: 'Other',
                                        groupValue: racetype,
                                        onChanged: (value) {
                                          setState(() {
                                            racetype = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomRadioListTile(
                                    title: 'Black or African American',
                                    value: 'Black or African American',
                                    groupValue: racetype,
                                    onChanged: (value) {
                                      setState(() {
                                        racetype = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ); },

                      ),
                      const SizedBox(height: AppSizeConst.A20),
                      Container(
                        height: 25,
                      ),
                      Container(
                        height: 25,
                      ),


                    ],
                  ),
                ),
              ],
            ),),
          const SizedBox(height: AppSizeConst.A20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormSaveButtonConst(
                isLoading: isLoading,
                onPressed: () async {

                  String addressText = address.text;
                  String dobText = dobcontroller.text;

                  bool isDriverLicenseValid = _isValidDriverLicenseLength(driverlicensenumb.text);

                  if (addressText.isEmpty ||
                      dobText.isEmpty ||
                      gendertype!.isEmpty ||
                      !isDriverLicenseValid) {
                    setState(() {
                      _addressDocError = addressText.isEmpty ? 'Address cannot be empty' : null;
                      _dobDocError = dobText.isEmpty ? 'DOB cannot be empty' : null;
                      _genderError = gendertype!.isEmpty ? 'Please select gender' : null;
                      _driverLicenseError = !isDriverLicenseValid
                          ? 'License number must be between 5 and 16 characters'
                          : null;
                    });
                    return;
                  }
                  else {
                    setState(() {
                      _addressDocError = null;
                      _dobDocError = null;
                      _genderError = null;
                    });
                  }
                  print("Address is valid: $addressText");

                  _clearFieldErrors();

                  setState(() {
                    isLoading = true;
                  });


                  final userId = await TokenManager.getUserID();
                  final departMentId = await TokenManager.getdepIdRegister();

                  print("User ID: $userId");

                  print("Sending data:");
                  print("Employee ID: ${widget.employeeID}");
                  print("Code: EMP-C10-U48");
                  print("User ID: $userId");
                  print("First Name: ${firstname.text}");
                  print("Last Name: ${lastname.text}");
                  print("Speciality: ${spalicity.text}");
                  print("File: ${filePath}");
                  print("SSN: ${ssecuritynumber.text}");
                  print("Phone Number: ${phonenumber.text}");
                  print("Personal Email: ${personalemail.text}");
                  print("Address: ${address.text}");
                  print("Date of Birth: ${dobcontroller.text}");
                  print("Gender: ${gendertype.toString()}");
                  print("Driver License Number: ${driverlicensenumb.text}");
                  print("Position: position");
                  print("Clinician: ${_selectedClinician.toString()}");
                  print("Race: ${racetype.toString()}");


                  var response = await updateOnlinkGeneralPatch(
                    context,
                    generalId!,
                    userId,
                    firstname.text,
                    lastname.text,
                    departMentId,
                    spalicity.text,
                    ssecuritynumber.text,
                    phonenumber.text,
                    personalemail.text,
                    address.text,
                    dobcontroller.text,
                    gendertype.toString(),
                    '',
                    driverlicensenumb.text,
                    "0000-00-00",
                    "0000-00-00",
                    address.text,
                    _selectedClinician.toString(),
                    "0000-00-00",
                    racetype.toString(),
                    signatureUrl!,
                  );

                  print("Response Status Code: ${response.statusCode}");

                  if (response.statusCode == 200 ||
                      response.statusCode == 201 ) {
                    var uploadResponse = await UploadEmployeePhoto(
                        context: context, documentFile: finalPath,
                        employeeId: generalId!);
                    if(uploadResponse.statusCode == 200 ||
                        uploadResponse.statusCode == 201){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(
                            message: 'User Data Updated.',
                          );
                        },
                      );
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(
                            message: 'User Data Updated.',
                          );
                        },
                      );
                    }
                    _initializeFormWithPrefilledData();
                    widget.onSave();
                  } else if(response.statusCode == 400 || response.statusCode == 404){
                    if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
                      _applyFieldErrors(response.fieldErrors!);
                    }
                  }
                  else {
                    if (response.fieldErrors != null && response.fieldErrors!.isNotEmpty) {
                      _applyFieldErrors(response.fieldErrors!);
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });

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
      ),
    );
  }
}

class AddressInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSuggestionSelected;
  final Function(String) onChanged;

  const AddressInput({required this.controller, this.onSuggestionSelected, required this.onChanged});

  @override
  _AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCountyNameChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCountyNameChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onCountyNameChanged() async {
    if (!_focusNode.hasFocus) return;

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
              width: 450,
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
    return   Column(
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: 'Address',
                style: AllPopupHeadings.customTextStyle(context),
                children: [
                  TextSpan(
                    text: ' *',
                    style: AllPopupHeadings.customTextStyle(context).copyWith(color: ColorManager.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSize.s5),
        CustomTextFieldRegister(
          controller: widget.controller,
          focusNode: _focusNode,
          hintText: 'Enter Address',
          hintStyle: onlyFormDataStyle.customTextStyle(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          height: 32,
          onChanged: widget.onChanged,
        ),

      ],
    );
  }
}