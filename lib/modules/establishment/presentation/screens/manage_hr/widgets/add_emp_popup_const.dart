import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/master_designation_s_dd.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';

class CustomPopupWidget extends StatefulWidget {
  final TextEditingController typeController;
  final TextEditingController abbreviationController;
  final TextEditingController? emailController;
  final bool isClinitian;

  final Future<void> Function(
      String colorHex,
      int masterTypeId,
      int roleId,
      List<int> childEmpTypeId,
      int templateIdSalaried,
      int templateIdParttime,
      int templateIdPerdiem
      ) onAddPressed;

  final Color containerColor;
  final Function(Color)? onColorChanged;
  final String title;
  final int departmentId;

  const CustomPopupWidget({
    super.key,
    required this.isClinitian,
    required this.typeController,
    required this.abbreviationController,
    this.emailController,
    required this.containerColor,
    required this.onAddPressed,
    required this.onColorChanged,
    required this.title,
    required this.departmentId,
  });

  @override
  State<CustomPopupWidget> createState() => _CustomPopupWidgetState();
}

class _CustomPopupWidgetState extends State<CustomPopupWidget> {
  late List<Color> _selectedColors;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  String? _typeError;
  String? _abbreviationError;

  String? selectedRadio;
  String? _radioError;
  String? _dropdownError;

  List<EmployeeTypeData> employeeTypeList = [];
  EmployeeTypeData? selectedEmployeeType;
  String _selectedDropdownLabel = "Select";

  // Role Manager variables
  late Future<List<HRAllData>> _childEmpFuture;
  late Future<List<RoleMasterData>> _RoleMasterFuture;
  String? _ChildTypeErrorText;
  // String? _MasterTypeErrorText;
  String? _RoleErrorText;
  int empTypeId = 0;
  bool _isClinicianSelected = true;
  bool _isClinicianValid = true;
  List<String> editChipValues = [];
  List<int> selectedChipsId = [];
  List<Widget> selectedEditChips = [];
  List<int> selectedChildTypeEditChipsId = [];
  String selectedRole = "Select Role";
  String selectedMasterEmployeeType = "Select Employee Type";
  String selectedChildEmployeeType = "Search Child Employee Type";
  int masterEmployeeTypeId = 0;
  int roleId = 0;

  // ========= File upload state per document =========
  // Salaried
  dynamic _salariedFilePath;
  String _salariedFileName = '';
  String? _salariedDocumentError;

  // Part Time
  dynamic _partTimeFilePath;
  String _partTimeFileName = '';
  String? _partTimeFileError;

  // Per Diem
  dynamic _perDiemFilePath;
  String _perDiemFileName = '';
  String? _perDiemFileError;

  String _salariedHtmlString = '';
  String _partTimeHtmlString = '';
  String _perDiemHtmlString = '';

  int salariedTemplateId = 0;
  int partTimeTemplateId = 0;
  int perDiemTemplateId = 0;

  @override
  void initState() {
    super.initState();
    _selectedColors = [Colors.white];
    _childEmpFuture = getAllHrDeptWise(context, widget.departmentId);
    _RoleMasterFuture = getAllMasterRole(context);
    widget.typeController.addListener(_onTypeChanged);
    widget.abbreviationController.addListener(_onAbbreviationChanged);
    _loadEmployeeTypes(departmentId: widget.departmentId);
  }

  @override
  void dispose() {
    widget.typeController.removeListener(_onTypeChanged);
    widget.abbreviationController.removeListener(_onAbbreviationChanged);
    super.dispose();
  }

  void _onTypeChanged() {
    if (_typeError != null && widget.typeController.text.isNotEmpty) {
      setState(() => _typeError = null);
    }
  }

  void _onAbbreviationChanged() {
    if (_abbreviationError != null &&
        widget.abbreviationController.text.isNotEmpty) {
      setState(() => _abbreviationError = null);
    }
  }

  Future<void> _loadEmployeeTypes({required int departmentId}) async {
    final list = await EmployeeTypeManager().getEmployeeTypeDropdown(
      context,
      departmentId,
    );
    if (!mounted) return;
    setState(() {
      employeeTypeList = list;
    });
  }





// ========= HTML Body Extractor =========
  /// Extracts raw HTML content inside <body>...</body>
  /// keeping all tags and {placeholders} intact.
  String _extractBodyText(String html) {
    final bodyMatch = RegExp(
      r'<body[^>]*>(.*?)</body>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(html);

    return bodyMatch != null ? bodyMatch.group(1)!.trim() : html.trim();
  }


// ========= Separate File Pickers =========
  Future<void> _pickSalariedFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html'],
    );

    if (!mounted) return;

    if (result != null) {
      final bytes = result.files.first.bytes;
      final rawHtml = bytes != null ? utf8.decode(bytes, allowMalformed: true) : '';
      final plainText = _extractBodyText(rawHtml);

      if (!mounted) return;

      setState(() {
        _salariedFilePath = bytes;
        _salariedFileName = result.files.first.name;
        _salariedDocumentError = null;
        _salariedHtmlString = plainText;
      });

      debugPrint('====== SALARIED HTML ======');
      debugPrint(_salariedHtmlString);
    }
  }

  Future<void> _pickPartTimeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html'],
    );

    if (!mounted) return;

    if (result != null) {
      final bytes = result.files.first.bytes;
      final rawHtml = bytes != null ? utf8.decode(bytes, allowMalformed: true) : '';
      final plainText = _extractBodyText(rawHtml);

      if (!mounted) return;

      setState(() {
        _partTimeFilePath = bytes;
        _partTimeFileName = result.files.first.name;
        _salariedDocumentError = null;
        _partTimeHtmlString = plainText;
      });

      debugPrint('====== PART TIME HTML ======');
      debugPrint(_partTimeHtmlString);
    }
  }

  Future<void> _pickPerDiemFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html'],
    );

    if (!mounted) return;

    if (result != null) {
      final bytes = result.files.first.bytes;
      final rawHtml = bytes != null ? utf8.decode(bytes, allowMalformed: true) : '';
      final plainText = _extractBodyText(rawHtml);

      if (!mounted) return;

      setState(() {
        _perDiemFilePath = bytes;
        _perDiemFileName = result.files.first.name;
        _salariedDocumentError = null;
        _perDiemHtmlString = plainText;
      });

      debugPrint('====== PER DIEM HTML ======');
      debugPrint(_perDiemHtmlString);
    }
  }

  void _openColorPicker() async {
    Color? pickedColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(left: AppPadding.p20),
            child: Text(
              'Pick a Color',
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w700,
                color: ColorManager.blueprime,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColorPicker(
                  borderColor: _selectedColors[0],
                  onColorChanged: (Color color) {
                    setState(() {
                      _selectedColors[0] = color;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(_selectedColors[0]),
            ),
          ],
        );
      },
    );

    setState(() {
      _selectedColors[0] = pickedColor ?? Colors.white;
      widget.onColorChanged?.call(_selectedColors[0]);
    });
  }

  // ========= Validation =========
  // ========= Validation =========
  void _validateFields() {
    setState(() {
      _abbreviationError = widget.abbreviationController.text.isEmpty
          ? 'Please Enter Abbreviation'
          : null;
      _typeError = widget.typeController.text.isEmpty
          ? 'Please Enter Employee Type'
          : null;
      // _MasterTypeErrorText = masterEmployeeTypeId == 0
      //     ? 'Please Select Master Employee Type'
      //     : null;
      _RoleErrorText = roleId == 0 ? 'Please Select Role' : null;
      // _ChildTypeErrorText =
      // selectedEditChips.isEmpty ? 'Please select Child Employee Type' : null;

      // If at least one document is uploaded, clear all three errors
      // final bool hasAtLeastOneDocument =
      //     _salariedFilePath != null ||
      //         _partTimeFilePath != null ||
      //         _perDiemFilePath != null;
      //
      // _salariedDocumentError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
      // _partTimeFileError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
      // _perDiemFileError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
    });
  }

  void _validateSalesAdminFields() {
    setState(() {
      _typeError = widget.typeController.text.isEmpty
          ? 'Please Enter Employee Type'
          : null;
      // _MasterTypeErrorText = masterEmployeeTypeId == 0
      //     ? 'Please Select Master Employee Type'
      //     : null;
      _RoleErrorText = roleId == 0 ? 'Please Select Role' : null;
      // _ChildTypeErrorText =
      // selectedEditChips.isEmpty ? 'Please select Child Employee Type' : null;

      // If at least one document is uploaded, clear all three errors
      // final bool hasAtLeastOneDocument =
      //     _salariedFilePath != null ||
      //         _partTimeFilePath != null ||
      //         _perDiemFilePath != null;
      //
      // _salariedDocumentError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
      // _partTimeFileError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
      // _perDiemFileError = hasAtLeastOneDocument
      //     ? null
      //     : 'Please upload at least one document';
    });
  }

  /// Returns true if all validations pass
  bool get _isFormValid {
    return _typeError == null &&
        _abbreviationError == null &&
       // _MasterTypeErrorText == null &&
        _RoleErrorText == null &&
        _ChildTypeErrorText == null &&
        _salariedDocumentError == null &&
        _partTimeFileError == null &&
        _perDiemFileError == null;
  }
  // void _validateSalesAdminFields() {
  //   setState(() {
  //     _typeError = widget.typeController.text.isEmpty
  //         ? 'Please Enter Employee Type'
  //         : null;
  //     _ChildTypeErrorText =
  //     selectedEditChips.isEmpty ? 'Please select Master Role' : null;
  //     _MasterTypeErrorText =
  //     masterEmployeeTypeId == 0 ? 'Please select Master Employee Type' : null;
  //     _RoleErrorText = roleId == 0 ? 'Please select Role' : null;
  //
  //     // File validations
  //     _salariedDocumentError = (_salariedFilePath == null || _partTimeFilePath == null || _perDiemFilePath == null)
  //         ? 'Please upload at least one document'
  //         : null;
  //     // _partTimeFileError = (_partTimeFilePath == null)
  //     //     ? 'Please upload a document'
  //     //     : null;
  //     // _perDiemFileError = (_perDiemFilePath == null)
  //     //     ? 'Please upload a document'
  //     //     : null;
  //   });
  // }
  //
  // void _validateFields() {
  //   setState(() {
  //     _typeError = widget.typeController.text.isEmpty
  //         ? 'Please Enter Employee Type'
  //         : null;
  //     _ChildTypeErrorText =
  //     selectedEditChips.isEmpty ? 'Please select Master Role' : null;
  //     _abbreviationError = widget.abbreviationController.text.isEmpty
  //         ? 'Please Enter Abbreviation'
  //         : null;
  //     _RoleErrorText = roleId == 0 ? 'Please select Role' : null;
  //     _MasterTypeErrorText =
  //     masterEmployeeTypeId == 0 ? 'Please select Master Employee Type' : null;
  //
  //     // File validations
  //     _salariedDocumentError = (_salariedFilePath == null)
  //         ? 'Please upload at least one document'
  //         : null;
  //     _partTimeFileError = (_partTimeFilePath == null)
  //         ? 'Please upload at least one document'
  //         : null;
  //     _perDiemFileError = (_perDiemFilePath == null)
  //         ? 'Please upload at least one document'
  //         : null;
  //   });
  // }
  //
  // /// Returns true if all validations pass
  // bool get _isFormValid {
  //   if (_typeError != null ||
  //       _abbreviationError != null ||
  //       _radioError != null ||
  //       _ChildTypeErrorText != null ||
  //       _MasterTypeErrorText != null ||
  //       _RoleErrorText != null ||
  //       _salariedDocumentError != null) {
  //     return false;
  //   }
  //   return true;
  // }

  // ========= Reusable file upload row =========
  Widget _buildFileUploadField({
    required String heading,
    required String fileName,
    required VoidCallback onPick,
    //required String? errorText,
    required String htmlString,
  }) {
    final bool hasHtml = htmlString.trim().isNotEmpty;
    return HeaderContentConst(
     // isAsterisk: true,
      heading: heading,
      marginVertical: 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onPick,
            child: Container(
              height: AppSize.s30,
              width: AppSize.s354,
              padding: const EdgeInsets.only(left: AppPadding.p10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorManager.containerBorderGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fileName.isEmpty ? "No file selected" : fileName,
                      style: DocumentTypeDataStyle.customTextStyle(context),
                    ),
                  ),
                  if (hasHtml)
                    Padding(
                      padding: const EdgeInsets.all(AppPadding.p4),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () => _openHtmlPreview(htmlString),
                        child: Text(
                          'view',
                          style: TextStyle(fontWeight: FontWeight.w600,
                            fontSize: FontSize.s13,
                            color: ColorManager.blueprime,
                            decoration: TextDecoration.none,),
                        ),
                      ),
                    ),
                  IconButton(
                    padding: const EdgeInsets.all(AppPadding.p4),
                    onPressed: onPick,
                    icon: Icon(
                      Icons.file_upload_outlined,
                      color: ColorManager.black,
                      size: IconSize.I16,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          // ✅ Same pattern as other error fields
          // errorText != null
          //     ? Padding(
          //   padding: const EdgeInsets.only(top: 2.0),
          //   child: Text(
          //     errorText,
          //     style: CommonErrorMsg.customTextStyle(context),
          //   ),
          // )
          //     :
              const SizedBox(height: AppSize.s14),
        ],
      ),
    );
  }
  // ✅ Opens decoded HTML in a new browser tab
  void _openHtmlPreview(String htmlString) {
    // ✅ Safely decode only if URL-encoded, otherwise use as-is
    String decoded;
    try {
      decoded = Uri.decodeComponent(htmlString);
    } catch (_) {
      decoded = htmlString; // not URL-encoded, use raw string directly
    }

    final blob = html.Blob([decoded], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');

    Future.delayed(const Duration(seconds: 5), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = employeeTypeList.isEmpty
        ? <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: "No available employee types",
        child: Text("No available employee types"),
      )
    ]
        : employeeTypeList.map((e) {
      final label = "${e.abbreviation} - ${e.employeeType}";
      return DropdownMenuItem<String>(
        value: label,
        child: Text(label),
      );
    }).toList();

    return DialogueTemplate(
      height: widget.isClinitian ? AppSize.s590 : AppSize.s500,
      width: AppSize.s800,
      isScrollable: true,
      body: [
        Form(
          key: _formKey,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: AppPadding.p10),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== LEFT COLUMN =====
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ========= TYPE =========
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SMTextfieldAsteric(
                            controller: widget.typeController,
                            keyboardType: TextInputType.text,
                            text: 'Employee Type',
                          ),
                          _typeError != null
                              ? Padding(
                                padding: const EdgeInsets.only(top:1.0),
                                child: Text(
                                                            _typeError!,
                                                            style: CommonErrorMsg.customTextStyle(context),
                                                          ),
                              )
                              : const SizedBox(height: AppSize.s14),
                        ],
                      ),

                      const SizedBox(height: AppSize.s13),

                      // ========= ROLE =========
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Role Type",
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
                          const SizedBox(height: AppSize.s5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<List<RoleMasterData>>(
                                future: _RoleMasterFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CICCDropdown(
                                      borderRadius: 8,
                                        items: [], hintText: selectedRole);
                                  }
                                  if (snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text(
                                        AppString.dataNotFound,
                                        style: AllNoDataAvailable.customTextStyle(
                                            context),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasData) {
                                    List<DropdownMenuItem<String>>
                                    dropDownTypesList = [];
                                    for (var i in snapshot.data!) {
                                      dropDownTypesList.add(
                                        DropdownMenuItem<String>(
                                          child: Text(i.roleName!),
                                          value: i.roleName,
                                        ),
                                      );
                                    }
                                    return CICCDropdown(
                                      borderRadius: 8,
                                      constraintHeight: 150,
                                      initialValue: selectedRole,
                                      onChange: (val) {
                                        for (var a in snapshot.data!) {
                                          if (a.roleName == val) {
                                            setState(() {
                                              roleId = a.roleId;
                                              _RoleErrorText = null;
                                              selectedRole = a.roleName;
                                            });
                                          }
                                        }
                                      },
                                      items: dropDownTypesList,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                              _RoleErrorText != null
                                  ? Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  _RoleErrorText!,
                                  style: CommonErrorMsg.customTextStyle(context),
                                ),
                              )
                                  : const SizedBox(height: AppSize.s14),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSize.s13),

                      // ========= ABBREVIATION (clinitian only) =========
                      widget.isClinitian
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CapitalSMTextFConst(
                            controller: widget.abbreviationController,
                            keyboardType: TextInputType.streetAddress,
                            text: AppStringEM.abbrevation,
                          ),
                          _abbreviationError != null
                              ? Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              _abbreviationError!,
                              style: CommonErrorMsg.customTextStyle(context),
                            ),
                          )
                              : const SizedBox(height: AppSize.s14),
                        ],
                      )
                          : const Offstage(),

                      SizedBox(
                          height: widget.isClinitian ? AppSize.s13 : 0),

                      // ========= MASTER EMPLOYEE TYPE =========
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     RichText(
                      //       text: TextSpan(
                      //         text: "Master Employee Type",
                      //         style: AllPopupHeadings.customTextStyle(context),
                      //         children: [
                      //           TextSpan(
                      //             text: ' *',
                      //             style: AllPopupHeadings.customTextStyle(context)
                      //                 .copyWith(color: ColorManager.red),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     const SizedBox(height: AppSize.s5),
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         FutureBuilder<List<HRAllData>>(
                      //           future: _childEmpFuture,
                      //           builder: (context, snapshot) {
                      //             if (snapshot.connectionState ==
                      //                 ConnectionState.waiting) {
                      //               return CICCDropdown(
                      //                   items: [],
                      //                   hintText: selectedMasterEmployeeType);
                      //             }
                      //             if (snapshot.data!.isEmpty) {
                      //               return Center(
                      //                 child: Text(
                      //                   AppString.dataNotFound,
                      //                   style: AllNoDataAvailable.customTextStyle(
                      //                       context),
                      //                 ),
                      //               );
                      //             }
                      //             if (snapshot.hasData) {
                      //               List<DropdownMenuItem<String>>
                      //               dropDownTypesList = [];
                      //               for (var i in snapshot.data!) {
                      //                 dropDownTypesList.add(
                      //                   DropdownMenuItem<String>(
                      //                     child: Text(i.empType!),
                      //                     value: i.empType,
                      //                   ),
                      //                 );
                      //               }
                      //               return StatefulBuilder(
                      //                 builder: (context, setState) =>
                      //                     CICCDropdown(
                      //                       constraintHeight: 150,
                      //                       initialValue: selectedMasterEmployeeType,
                      //                       onChange: (val) {
                      //                         for (var a in snapshot.data!) {
                      //                           if (a.empType == val) {
                      //                             setState(() {
                      //                               masterEmployeeTypeId =
                      //                                   a.employeeTypesId;
                      //                               _MasterTypeErrorText = null;
                      //                               selectedMasterEmployeeType =
                      //                               a.empType!;
                      //                             });
                      //                           }
                      //                         }
                      //                       },
                      //                       items: dropDownTypesList,
                      //                     ),
                      //               );
                      //             }
                      //             return const SizedBox();
                      //           },
                      //         ),
                      //         _MasterTypeErrorText != null
                      //             ? Padding(
                      //           padding: const EdgeInsets.only(top: 2.0),
                      //           child: Text(
                      //             _MasterTypeErrorText!,
                      //             style: CommonErrorMsg.customTextStyle(context),
                      //           ),
                      //         )
                      //             : const SizedBox(height: AppSize.s14),
                      //       ],
                      //     ),
                      //   ],
                      // ),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Master Employee Type",
                        style: AllPopupHeadings.customTextStyle(context),
                        children: [
                          TextSpan(
                            text: ' ',
                            style: AllPopupHeadings.customTextStyle(context)
                                .copyWith(color: ColorManager.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s5),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        FutureBuilder<List<HRAllData>>(
                          future: _childEmpFuture,
                          builder: (context, snapshot) {

                            /// Loading
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CICCDropdown(
                                borderRadius: 8,
                                items: const [],
                                hintText: selectedMasterEmployeeType,
                              );
                            }

                            /// No Data
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                width: AppSize.s354,
                                height: AppSize.s30,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    AppString.dataNotFound,
                                    style: AllNoDataAvailable.customTextStyle(context),
                                  ),
                                ),
                              );
                            }

                            /// Data Available
                            List<DropdownMenuItem<String>> dropDownTypesList =
                            snapshot.data!
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                value: e.empType,
                                child: Text(e.empType ?? ''),
                              ),
                            )
                                .toList();

                            return CICCDropdown(
                              borderRadius: 8,
                              constraintHeight: 150,
                              initialValue: selectedMasterEmployeeType,
                              items: dropDownTypesList,

                              onChange: (val) {
                                for (var a in snapshot.data!) {
                                  if (a.empType == val) {
                                    setState(() {
                                      masterEmployeeTypeId = a.employeeTypesId;
                                      selectedMasterEmployeeType = a.empType!;
                                      // _MasterTypeErrorText = null; // remove validation
                                    });
                                    break;
                                  }
                                }
                              },
                            );
                          },
                        ),

                        /// Validation Error Text
                        // _MasterTypeErrorText != null
                        //     ? Padding(
                        //   padding: const EdgeInsets.only(top: 2),
                        //   child: Text(
                        //     _MasterTypeErrorText!,
                        //     style: CommonErrorMsg.customTextStyle(context),
                        //   ),
                        // )
                        //     :
                        const SizedBox(height: AppSize.s14),
                      ],
                    ),
                  ],
                ),
                      const SizedBox(height: AppSize.s13),

                      // ========= CHILD EMPLOYEE TYPE =========
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Child Employee Type",
                              style: AllPopupHeadings.customTextStyle(context),
                              children: [
                                TextSpan(
                                  text: '',
                                  style: AllPopupHeadings.customTextStyle(context)
                                      .copyWith(color: ColorManager.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSize.s5),
                          // StatefulBuilder(
                          //   builder: (context, setLocalState) {
                          //     return Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         FutureBuilder<List<HRAllData>>(
                          //           future: _childEmpFuture,
                          //           builder: (context, snapshot) {
                          //             if (snapshot.connectionState ==
                          //                 ConnectionState.waiting) {
                          //               return RoleDropdown(
                          //                   items: [],
                          //                   hintText: selectedChildEmployeeType);
                          //             }
                          //             if (!snapshot.hasData ||
                          //                 snapshot.data!.isEmpty) {
                          //               return Center(
                          //                 child: Text(
                          //                   AppString.dataNotFound,
                          //                   style:
                          //                   AllNoDataAvailable.customTextStyle(context),
                          //                 ),
                          //               );
                          //             }
                          //
                          //             List<DropdownMenuItem<String>>
                          //             dropDownTypesList = snapshot.data!
                          //                 .map((i) => DropdownMenuItem<String>(
                          //               value: i.empType,
                          //               child: Text(i.empType!),
                          //             ))
                          //                 .toList();
                          //
                          //             return RoleDropdown(
                          //               constraintHeight: 150,
                          //               initialValue: selectedChildEmployeeType,
                          //               onChange: (val) {
                          //                 for (var a in snapshot.data!) {
                          //                   if (a.empType == val) {
                          //                     final docType = a.employeeTypesId;
                          //                     empTypeId = docType;
                          //
                          //                     if (!editChipValues.contains(val)) {
                          //                       setLocalState(() {
                          //                         editChipValues.add(val);
                          //                         selectedChildTypeEditChipsId.add(docType);
                          //                         _isClinicianValid = true;
                          //                         _ChildTypeErrorText = null;
                          //                         selectedChildEmployeeType =
                          //                         a.empType!;
                          //
                          //                         selectedEditChips.add(
                          //                           Chip(
                          //                             materialTapTargetSize:
                          //                             MaterialTapTargetSize
                          //                                 .shrinkWrap,
                          //                             visualDensity: const VisualDensity(
                          //                                 horizontal: 0,
                          //                                 vertical: -4),
                          //                             backgroundColor:
                          //                             const Color(0xFFE6E6),
                          //                             shape: const StadiumBorder(
                          //                               side: BorderSide(color: Color(0xFFE6E6)),
                          //                             ),
                          //                             deleteIcon: Icon(
                          //                               Icons.close,
                          //                               color:
                          //                               ColorManager.blueprime,
                          //                               size: IconSize.I16,
                          //                             ),
                          //                             label: Text(
                          //                               val,
                          //                               style: CustomTextStylesCommon.commonStyle(
                          //                                 fontWeight:
                          //                                 FontWeight.w500,
                          //                                 fontSize: FontSize.s10,
                          //                                 color: ColorManager.mediumgrey,
                          //                               ),
                          //                             ),
                          //                             onDeleted: () {
                          //                               setLocalState(() {
                          //                                 editChipValues.remove(val);
                          //                                 selectedEditChips
                          //                                     .removeWhere((chip) {
                          //                                       final chipText =
                          //                                       (chip as Chip).label as Text;
                          //                                       return chipText.data == val;
                          //                                     });
                          //                                 selectedChildTypeEditChipsId.remove(docType);
                          //                                 if (editChipValues.isEmpty) {
                          //                                   _isClinicianValid = false;
                          //                                 }
                          //                               });
                          //                             },
                          //                           ),
                          //                         );
                          //                       });
                          //                     }
                          //                     break;
                          //                   }
                          //                 }
                          //               },
                          //               items: dropDownTypesList,
                          //             );
                          //           },
                          //         ),
                          //         _ChildTypeErrorText != null
                          //             ? Padding(
                          //           padding: const EdgeInsets.only(top: 2.0),
                          //           child: Text(
                          //             _ChildTypeErrorText!,
                          //             style:
                          //             CommonErrorMsg.customTextStyle(context),
                          //           ),
                          //         )
                          //             : const SizedBox(height: AppSize.s14),
                          //         Wrap(
                          //           spacing: 8.0,
                          //           children: selectedEditChips.isEmpty
                          //               ? [const SizedBox(height: 0)]
                          //               : selectedEditChips,
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // ),

                          StatefulBuilder(
                            builder: (context, setLocalState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<List<HRAllData>>(
                                    future: _childEmpFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return RoleDropdown(
                                          borderRadius: 8,
                                          items: [],
                                          hintText: selectedChildEmployeeType,
                                        );
                                      }
                                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Container(
                                          width: AppSize.s354,
                                          height: AppSize.s30,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey, width: 1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppString.dataNotFound,
                                              style: AllNoDataAvailable.customTextStyle(context),
                                            ),
                                          ),
                                        );
                                      }

                                      List<DropdownMenuItem<String>> dropDownTypesList = snapshot.data!
                                          .map(
                                            (i) => DropdownMenuItem<String>(
                                          value: i.empType,
                                          child: Text(i.empType!),
                                        ),
                                      )
                                          .toList();

                                      return RoleDropdown(
                                        borderRadius: 8,
                                        constraintHeight: 150,
                                        initialValue: selectedEditChips.isEmpty ? null : selectedChildEmployeeType,
                                        hintText:  "Search Child Employee Type" ,
                                        items: dropDownTypesList,
                                        onChange: (val) {
                                          for (var a in snapshot.data!) {
                                            if (a.empType == val) {
                                              final docType = a.employeeTypesId;
                                              empTypeId = docType;

                                              if (!editChipValues.contains(val)) {
                                                setLocalState(() {
                                                  // Add selected chip value
                                                  editChipValues.add(val);
                                                  selectedChildTypeEditChipsId.add(docType);
                                                  // _isClinicianValid = true;
                                                  // _ChildTypeErrorText = null;
                                                  selectedChildEmployeeType = a.empType!;

                                                  // Add Chip widget dynamically
                                                  selectedEditChips.add(
                                                    Chip(
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      visualDensity:
                                                      const VisualDensity(horizontal: 0, vertical: -4),
                                                      backgroundColor: const Color(0xFFE6E6),
                                                      shape: const StadiumBorder(
                                                        side: BorderSide(color: Color(0xFFE6E6)),
                                                      ),
                                                      deleteIcon: Icon(
                                                        Icons.close,
                                                        color: ColorManager.blueprime,
                                                        size: IconSize.I16,
                                                      ),
                                                      label: Text(
                                                        val,
                                                        style: CustomTextStylesCommon.commonStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: FontSize.s10,
                                                          color: ColorManager.mediumgrey,
                                                        ),
                                                      ),
                                                      onDeleted: () {
                                                        setLocalState(() {
                                                          // Remove chip
                                                          editChipValues.remove(val);
                                                          selectedEditChips.removeWhere((chip) {
                                                            final chipText = (chip as Chip).label as Text;
                                                            return chipText.data == val;
                                                          });
                                                          selectedChildTypeEditChipsId.remove(docType);

                                                          // Update dropdown selection
                                                          if (editChipValues.isEmpty) {
                                                            selectedChildEmployeeType = "Search Child Employee Type";
                                                            // _isClinicianValid = false;
                                                          } else {
                                                            // Select last remaining chip in dropdown
                                                            selectedChildEmployeeType = editChipValues.last;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  );
                                                });
                                              }
                                              break;
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSize.s14),

                                  // Scrollable Chip Container (200 x 200)
                                  SizedBox(
                                    width: 330,height:40,
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: selectedEditChips, // empty → container stays empty
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),


                        ],
                      ),

                      SizedBox(height: widget.isClinitian ? AppSize.s13 : 0),
                    ],
                  ),

                  // ===== RIGHT COLUMN =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: widget.isClinitian ? AppSize.s25 : 0),
                      // ========= COLOR (clinitian only) =========
                      widget.isClinitian
                          ? Row(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(left: AppPadding.p3),
                            child: Text(
                              AppStringEM.color,
                              style: ConstTextFieldStyles.customTextStyle(
                                textColor: ColorManager.mediumgrey,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s25),
                          Container(
                            padding: const EdgeInsets.all(2),
                            width: AppSize.s62,
                            height: AppSize.s22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                  width: 1,
                                  color: const Color(0xffE9E9E9)),
                            ),
                            child: GestureDetector(
                              onTap: _openColorPicker,
                              child: Container(
                                width: AppSize.s60,
                                height: AppSize.s20,
                                decoration: BoxDecoration(
                                  color: _selectedColors[0],
                                  border: Border.all(
                                      width: 1,
                                      color: _selectedColors[0]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : const Offstage(),

                      SizedBox(height: widget.isClinitian ? AppSize.s35 : 0),

                      // ========= UPLOAD SALARIED =========
                      _buildFileUploadField(
                        heading: AppString.uploadLatterSalaried,
                        fileName: _salariedFileName,
                        onPick: _pickSalariedFile,
                       // errorText: _salariedDocumentError,
                        htmlString: _salariedHtmlString
                      ),

                       SizedBox(height: widget.isClinitian ? AppSize.s11 :AppSize.s13),

                      // ========= UPLOAD PART TIME =========
                      _buildFileUploadField(
                        heading: AppString.uploadLatterPartTime,
                        fileName: _partTimeFileName,
                        onPick: _pickPartTimeFile,
                        //errorText: _salariedDocumentError,
                        htmlString: _partTimeHtmlString
                      ),

                       SizedBox(height: widget.isClinitian ? AppSize.s9 :AppSize.s13),

                      // ========= UPLOAD PER DIEM =========
                      _buildFileUploadField(
                        heading: AppString.uploadLatterperDiem,
                        fileName: _perDiemFileName,
                        onPick: _pickPerDiemFile,
                        //errorText: _salariedDocumentError,
                        htmlString: _perDiemHtmlString
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      bottomButtons: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            CustomButtonTransparentSM(
              text: 'Cancel',
              onPressed: () {
                Navigator.pop(context);
              },),
            isLoading
                ? SizedBox(
              width: AppSize.s30,
              height: AppSize.s30,
              child:
              CircularProgressIndicator(color: ColorManager.blueprime),
            )
                : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: 'Save',
              onPressed: () async {
                widget.isClinitian
                    ? _validateFields()
                    : _validateSalesAdminFields();

                if (!_isFormValid) return;

                setState(() => isLoading = true);

                final colorToPass = _selectedColors[0];
                final colorHex =
                    '#${colorToPass.value.toRadixString(16).substring(2).toUpperCase()}';

                print("===== ADD EMPLOYEE TYPE =====");
                print("Radio value: $selectedRadio");
                print("Role Id: $roleId");
                print("Selected dropdown label: $_selectedDropdownLabel");
                print(
                    "Selected employeeTypeId: ${selectedEmployeeType?.employeeTypeId}");
                print("Master emp type sent: $masterEmployeeTypeId");
                if(_salariedHtmlString.isNotEmpty){
                  var templateResponse = await postOfferLatterTemplate(
                      context: context,
                      templateName: 'Salaried Offer Latter',
                      // deptId: widget.departmentId,
                      // empType: widget.typeController.text,
                      template: _salariedHtmlString);
                  if(templateResponse.statusCode == 200 || templateResponse.statusCode == 201){
                    salariedTemplateId = templateResponse.templateId!;
                  } else {
                    print("Failed to upload Part Time Template. Status code: ${templateResponse.statusCode}");
                  }
                }
                if(_partTimeHtmlString.isNotEmpty){
                  var templateResponse = await postOfferLatterTemplate(
                      context: context,
                      templateName: 'Part Time Offer Latter',
                      // deptId: widget.departmentId,
                      // empType: widget.typeController.text,
                      template: _partTimeHtmlString);
                  if(templateResponse.statusCode == 200 || templateResponse.statusCode == 201){
                    partTimeTemplateId = templateResponse.templateId!;
                  } else {
                    print("Failed to upload Part Time Template. Status code: ${templateResponse.statusCode}");
                  }
                }
                if(_perDiemHtmlString.isNotEmpty){
                  var templateResponse = await postOfferLatterTemplate(
                      context: context,
                      templateName: 'Per Diem Offer Latter',
                      // deptId: widget.departmentId,
                      // empType: widget.typeController.text,
                      template: _perDiemHtmlString);
                  if(templateResponse.statusCode == 200 || templateResponse.statusCode == 201){
                    perDiemTemplateId = templateResponse.templateId!;
                  } else {
                    print("Failed to upload Part Time Template. Status code: ${templateResponse.statusCode}");
                  }
                }

                await widget.onAddPressed(
                  colorHex,
                  masterEmployeeTypeId,
                  roleId,
                  selectedChildTypeEditChipsId,
                  salariedTemplateId,
                  partTimeTemplateId,
                  perDiemTemplateId,
                );

                setState(() => isLoading = false);
              },
            ),
          ],
        ),
      ),
      title: widget.title,
    );
  }
}