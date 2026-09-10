import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/all_from_hr_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/all_from_hr/all_from_hr_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';

class EditPopupWidget extends StatefulWidget {
  final int? id;
  final TextEditingController typeController;
  final TextEditingController shorthandController;
  final TextEditingController? emailController;
  final Future<void> Function(
      String colorHex,
      int masterTypeId,
      int roleId,
      List<int> childEmpTypeId,
      int templateIdSalaried,
      int templateIdParttime,
      int templateIdPerdiem,
      ) onSavePressed;
  final Color containerColor;
  final int roleId;
  final String roleName;
  final int masterEmpId;
  final String masterEmpName;
  final bool isClinician;
  final List<int> childEmpTypeId;
  final List<String> childEmpTypeNames;
  final Function(Color)? onColorChanged;
  final String title;
  final int salariedTemplateId;
  final int partTimeTemplateId;
  final int perDiemTemplateId;

  EditPopupWidget({
    required this.typeController,
    required this.shorthandController,
    this.emailController,
    required this.containerColor,
    required this.onSavePressed,
    this.onColorChanged,
    this.id,
    required this.title,
    required this.roleId,
    required this.roleName,
    required this.masterEmpId,
    required this.masterEmpName,
    required this.isClinician,
    required this.childEmpTypeId,
    required this.childEmpTypeNames,
    required this.salariedTemplateId,
    required this.partTimeTemplateId,
    required this.perDiemTemplateId,
  });

  @override
  State<EditPopupWidget> createState() => _EditPopupWidgetState();
}

class _EditPopupWidgetState extends State<EditPopupWidget> {
  int index = 0;
  late List<Color> _selectedColors;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  String? _typeError;
  String? _abbreviationError;
  String? _RoleErrorText;

  int empTypeId = 0;
  int masterEmployeeTypeId = 0;
  int roleId = 0;

  late Future<List<HRAllData>> _childEmpFuture;
  late Future<List<RoleMasterData>> _RoleMasterFuture;

  List<String> editChipValues = [];
  List<Widget> selectedEditChips = [];
  List<int> selectedChildTypeEditChipsId = [];

  String selectedRole = "Select Role";
  String selectedMasterEmployeeType = "Select Employee Type";
  String selectedChildEmployeeType = "Search Child Employee Type";

  dynamic _salariedFilePath;
  String _salariedFileName = '';
  String _salariedHtmlString = '';

  dynamic _partTimeFilePath;
  String _partTimeFileName = '';
  String _partTimeHtmlString = '';

  dynamic _perDiemFilePath;
  String _perDiemFileName = '';
  String _perDiemHtmlString = '';

  String? _salariedTemplateName;
  String? _partTimeTemplateName;
  String? _perDiemTemplateName;
  bool _isTemplateLoading = true;

  int salariedTemplateId = 0;
  int partTimeTemplateId = 0;
  int perDiemTemplateId = 0;

  @override
  void initState() {
    super.initState();
    salariedTemplateId = widget.salariedTemplateId;
    partTimeTemplateId = widget.partTimeTemplateId;
    perDiemTemplateId = widget.perDiemTemplateId;

    _loadTemplateNames();
    _childEmpFuture = getAllHrDeptWise(context, widget.id!);
    _RoleMasterFuture = getAllMasterRole(context);

    selectedMasterEmployeeType = widget.masterEmpName.isNotEmpty
        ? widget.masterEmpName
        : "Search Employee Type";
    selectedRole = widget.roleName.isNotEmpty ? widget.roleName : "Search Role";

    masterEmployeeTypeId = widget.masterEmpId;
    roleId = widget.roleId;

    // ── safe copy — nulls and zeros already filtered at call site ──
    editChipValues = widget.childEmpTypeNames
        .where((n) => n.isNotEmpty)
        .toList();
    selectedChildTypeEditChipsId = widget.childEmpTypeId
        .where((id) => id != 0)
        .toList();

    for (int i = 0; i < editChipValues.length; i++) {
      final val = editChipValues[i];
      final id = selectedChildTypeEditChipsId.length > i
          ? selectedChildTypeEditChipsId[i]
          : 0;
      selectedEditChips.add(_buildChip(val, id));
    }

    _selectedColors = [
      widget.containerColor == Colors.white
          ? Colors.transparent
          : widget.containerColor,
    ];
  }

  Future<void> _loadTemplateNames() async {
    try {
      final results = await Future.wait([
        getPrefillTemplateData(context: context, templateId: widget.salariedTemplateId),
        getPrefillTemplateData(context: context, templateId: widget.partTimeTemplateId),
        getPrefillTemplateData(context: context, templateId: widget.perDiemTemplateId),
      ]);

      if (mounted) {
        setState(() {
          _salariedTemplateName = results[0]?.templateName;
          _partTimeTemplateName = results[1]?.templateName;
          _perDiemTemplateName = results[2]?.templateName;
          _salariedHtmlString = results[0]?.template ?? '';
          _partTimeHtmlString = results[1]?.template ?? '';
          _perDiemHtmlString = results[2]?.template ?? '';
          _isTemplateLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isTemplateLoading = false);
      print('Error loading template names: $e');
    }
  }

  String _extractBodyText(String html) {
    final bodyMatch = RegExp(
      r'<body[^>]*>(.*?)</body>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(html);
    return bodyMatch != null ? bodyMatch.group(1)!.trim() : html.trim();
  }

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
        _salariedHtmlString = plainText;
      });
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
        _partTimeHtmlString = plainText;
      });
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
        _perDiemHtmlString = plainText;
      });
    }
  }

  Widget _buildFileUploadField({
    required String heading,
    required String fileName,
    required String? templateName,
    required VoidCallback onPick,
    String htmlString = '',
  }) {
    final displayName = fileName.isNotEmpty
        ? fileName
        : (templateName != null && templateName.isNotEmpty)
        ? templateName
        : null;
    final bool hasHtml = htmlString.trim().isNotEmpty;

    return HeaderContentConst(
      //isAsterisk: true,
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
                border: Border.all(color: ColorManager.containerBorderGrey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _isTemplateLoading && fileName.isEmpty
                        ? Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: ColorManager.mediumgrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('Loading...', style: DocumentTypeDataStyle.customTextStyle(context)),
                      ],
                    )
                        : Text(
                      displayName ?? 'No file selected',
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: FontSize.s13,
                            color: ColorManager.blueprime,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    padding: const EdgeInsets.all(AppPadding.p4),
                    onPressed: onPick,
                    icon: Icon(Icons.file_upload_outlined, color: ColorManager.black, size: IconSize.I16),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSize.s14),
        ],
      ),
    );
  }

  void _openHtmlPreview(String htmlString) {
    String decoded;
    try {
      decoded = Uri.decodeComponent(htmlString);
    } catch (_) {
      decoded = htmlString;
    }
    final blob = html.Blob([decoded], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(const Duration(seconds: 5), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  Widget _buildChip(String val, int docType) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      backgroundColor: Color(0xFFE6E6E6),
      shape: StadiumBorder(side: BorderSide(color: Color(0xFFE6E6E6))),
      deleteIcon: Icon(Icons.close, color: ColorManager.blueprime, size: IconSize.I16),
      label: Text(
        val,
        style: CustomTextStylesCommon.commonStyle(
          fontWeight: FontWeight.w500,
          fontSize: FontSize.s10,
          color: ColorManager.mediumgrey,
        ),
      ),
      onDeleted: () {
        setState(() {
          editChipValues.remove(val);
          selectedChildTypeEditChipsId.remove(docType);
          selectedEditChips = selectedEditChips.where((chip) {
            if (chip is Chip) {
              final chipText = chip.label as Text;
              return chipText.data != val;
            }
            return true;
          }).toList();
        });
      },
    );
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
                    setState(() => _selectedColors[0] = color);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(_selectedColors[0]),
            ),
          ],
        );
      },
    );
    if (pickedColor != null) {
      setState(() {
        _selectedColors[0] = pickedColor;
        widget.onColorChanged?.call(pickedColor);
      });
    }
  }

  void _validationClinitianTab() {
    setState(() {
      _abbreviationError = widget.shorthandController.text.isEmpty ? 'Please Enter Abbreviation' : null;
      _typeError = widget.typeController.text.isEmpty ? 'Please Enter Employee Type' : null;
      _RoleErrorText = roleId == 0 ? 'Please Select Role' : null;
    });
  }

  void _validateSalesAdminFields() {
    setState(() {
      _typeError = widget.typeController.text.isEmpty ? 'Please Enter Employee Type' : null;
      _RoleErrorText = roleId == 0 ? 'Please Select Role' : null;
    });
  }

  bool get _isFormValid =>
      _typeError == null && _abbreviationError == null && _RoleErrorText == null;

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      height: widget.isClinician ? AppSize.s620 : AppSize.s511,
      width: AppSize.s800,
      isScrollable: true,
      title: widget.title,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ===== LEFT COLUMN =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SMTextfieldAsteric(
                        controller: widget.typeController,
                        keyboardType: TextInputType.text,
                        text: 'Employee Type',
                        onChange: () {
                          if (_typeError != null) setState(() => _typeError = null);
                        },
                      ),
                      _typeError != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Text(_typeError!, style: CommonErrorMsg.customTextStyle(context)),
                      )
                          : const SizedBox(height: AppSize.s12),

                      const SizedBox(height: AppSize.s5),

                      _buildSectionLabel("Role Type"),
                      const SizedBox(height: AppSize.s5),
                      FutureBuilder<List<RoleMasterData>>(
                        future: _RoleMasterFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CICCDropdown(   borderRadius: 8,items: [], hintText: selectedRole);
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text(AppString.dataNotFound,
                                style: AllNoDataAvailable.customTextStyle(context)));
                          }
                          final dropDownTypesList = snapshot.data!
                              .map((i) => DropdownMenuItem<String>(
                              value: i.roleName, child: Text(i.roleName!)))
                              .toList();
                          return CICCDropdown(
                            borderRadius: 8,
                            constraintHeight: 150,
                            initialValue: selectedRole == "Select Role" ? null : selectedRole,
                            onChange: (val) {
                              for (var a in snapshot.data!) {
                                if (a.roleName == val) {
                                  setState(() {
                                    roleId = a.roleId;
                                    _RoleErrorText = null;
                                    selectedRole = a.roleName!;
                                  });
                                  break;
                                }
                              }
                            },
                            items: dropDownTypesList,
                          );
                        },
                      ),
                      _RoleErrorText != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(_RoleErrorText!, style: CommonErrorMsg.customTextStyle(context)),
                      )
                          : const SizedBox(height: AppSize.s14),

                      const SizedBox(height: AppSize.s5),

                      widget.isClinician
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CapitalSMTextFConst(
                            controller: widget.shorthandController,
                            keyboardType: TextInputType.streetAddress,
                            text: 'Abbreviation',
                            onChange: () {
                              if (_abbreviationError != null) setState(() => _abbreviationError = null);
                            },
                          ),
                          _abbreviationError != null
                              ? Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(_abbreviationError!,
                                style: CommonErrorMsg.customTextStyle(context)),
                          )
                              : const SizedBox(height: AppSize.s12),
                        ],
                      )
                          : const Offstage(),

                      SizedBox(height: widget.isClinician ? AppSize.s5 : 0),

                      _buildSectionLabel("Master Employee Type"),
                      const SizedBox(height: AppSize.s5),
                      FutureBuilder<List<HRAllData>>(
                        future: _childEmpFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CICCDropdown(   borderRadius: 8,items: [], hintText: selectedMasterEmployeeType);
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: AppSize.s354,
                              height: AppSize.s30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text(AppString.dataNotFound,
                                  style: AllNoDataAvailable.customTextStyle(context))),
                            );
                          }
                          final dropDownTypesList = snapshot.data!
                              .map((i) => DropdownMenuItem<String>(
                              value: i.empType, child: Text(i.empType ?? '')))
                              .toList();
                          return CICCDropdown(
                            borderRadius: 8,
                            constraintHeight: 150,
                            initialValue: selectedMasterEmployeeType == "Select Employee Type"
                                ? null
                                : selectedMasterEmployeeType,
                            onChange: (val) {
                              for (var a in snapshot.data!) {
                                if (a.empType == val) {
                                  setState(() {
                                    masterEmployeeTypeId = a.employeeTypesId;
                                    selectedMasterEmployeeType = a.empType!;
                                  });
                                  break;
                                }
                              }
                            },
                            items: dropDownTypesList,
                          );
                        },
                      ),
                      const SizedBox(height: AppSize.s14),
                      const SizedBox(height: AppSize.s5),

                      _buildSectionLabel("Child Employee Type"),
                      const SizedBox(height: AppSize.s5),
                      FutureBuilder<List<HRAllData>>(
                        future: _childEmpFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return RoleDropdown(   borderRadius: 8,items: [], hintText: selectedChildEmployeeType);
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: AppSize.s354,
                              height: AppSize.s30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text(AppString.dataNotFound,
                                  style: AllNoDataAvailable.customTextStyle(context))),
                            );
                          }
                          final dropDownTypesList = snapshot.data!
                              .map((i) => DropdownMenuItem<String>(
                              value: i.empType, child: Text(i.empType ?? '')))
                              .toList();
                          return RoleDropdown(
                            borderRadius: 8,
                            constraintHeight: 150,
                            initialValue: null,
                            hintText: "Search Child Employee Type",
                            onChange: (val) {
                              for (var a in snapshot.data!) {
                                if (a.empType == val) {
                                  final docType = a.employeeTypesId;
                                  empTypeId = docType;
                                  if (!editChipValues.contains(val)) {
                                    setState(() {
                                      editChipValues.add(val!);
                                      selectedChildTypeEditChipsId.add(docType);
                                      selectedEditChips.add(_buildChip(val, docType));
                                    });
                                  }
                                  break;
                                }
                              }
                            },
                            items: dropDownTypesList,
                          );
                        },
                      ),
                      const SizedBox(height: AppSize.s14),

                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: selectedEditChips.isEmpty
                            ? [const SizedBox(height: 0)]
                            : selectedEditChips,
                      ),
                      const SizedBox(height: AppSize.s5),
                    ],
                  ),

                  // ===== RIGHT COLUMN =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: widget.isClinician ? AppSize.s25 : 0),

                      widget.isClinician
                          ? Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 1.0),
                            child: Text('Color',
                                style: ConstTextFieldStyles.customTextStyle(
                                    textColor: ColorManager.mediumgrey)),
                          ),
                          const SizedBox(width: AppSize.s25),
                          Container(
                            padding: const EdgeInsets.all(AppPadding.p2),
                            width: AppSize.s62,
                            height: AppSize.s22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(width: 1, color: const Color(0xffE9E9E9)),
                            ),
                            child: GestureDetector(
                              onTap: _openColorPicker,
                              child: Container(
                                width: AppSize.s60,
                                height: AppSize.s20,
                                decoration: BoxDecoration(
                                  color: _selectedColors[0],
                                  border: Border.all(width: 1, color: _selectedColors[0]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : const Offstage(),

                      SizedBox(height: widget.isClinician ? AppSize.s27 : 0),

                      _buildFileUploadField(
                        heading: AppString.uploadLatterSalaried,
                        fileName: _salariedFileName,
                        templateName: _salariedTemplateName,
                        onPick: _pickSalariedFile,
                        htmlString: _salariedHtmlString,
                      ),
                      SizedBox(height: widget.isClinician ? 0 : AppSize.s5),

                      _buildFileUploadField(
                        heading: AppString.uploadLatterPartTime,
                        fileName: _partTimeFileName,
                        templateName: _partTimeTemplateName,
                        onPick: _pickPartTimeFile,
                        htmlString: _partTimeHtmlString,
                      ),
                      SizedBox(height: widget.isClinician ? 0 : AppSize.s0),

                      _buildFileUploadField(
                        heading: AppString.uploadLatterperDiem,
                        fileName: _perDiemFileName,
                        templateName: _perDiemTemplateName,
                        onPick: _pickPerDiemFile,
                        htmlString: _perDiemHtmlString,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          CustomButtonTransparentSM(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          isLoading
              ? SizedBox(
            width: AppSize.s30,
            height: AppSize.s30,
            child: CircularProgressIndicator(color: ColorManager.blueprime),
          )
              : CustomElevatedButton(
            width: AppSize.s105,
            height: AppSize.s30,
            text: AppStringEM.save,
            onPressed: () async {
              widget.isClinician
                  ? _validationClinitianTab()
                  : _validateSalesAdminFields();

              if (!_isFormValid) return;

              setState(() => isLoading = true);

              final selectedColor = _selectedColors[0] == Colors.transparent
                  ? Colors.white
                  : _selectedColors[0];
              final selectedColorToSave =
                  '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

              if (_salariedHtmlString.isNotEmpty) {
                if (salariedTemplateId == 0) {
                  var res = await postOfferLatterTemplate(
                    context: context,
                    templateName: 'Salaried Offer Latter',
                    template: _salariedHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    salariedTemplateId = res.templateId!;
                  } else {
                    print('Failed to upload Salaried Template. Status: ${res.statusCode}');
                  }
                } else {
                  var res = await patchOfferLatterTemplate(
                    context: context,
                    templateId: salariedTemplateId,
                    templateName: 'Salaried Offer Latter',
                    template: _salariedHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    salariedTemplateId = res.templateId!;
                  } else {
                    print('Failed to patch Salaried Template. Status: ${res.statusCode}');
                  }
                }
              }

              if (_partTimeHtmlString.isNotEmpty) {
                if (partTimeTemplateId == 0) {
                  var res = await postOfferLatterTemplate(
                    context: context,
                    templateName: 'Part Time Offer Latter',
                    template: _partTimeHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    partTimeTemplateId = res.templateId!;
                  } else {
                    print('Failed to upload Part Time Template. Status: ${res.statusCode}');
                  }
                } else {
                  var res = await patchOfferLatterTemplate(
                    context: context,
                    templateId: partTimeTemplateId,
                    templateName: 'Part Time Offer Latter',
                    template: _partTimeHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    partTimeTemplateId = res.templateId!;
                  } else {
                    print('Failed to patch Part Time Template. Status: ${res.statusCode}');
                  }
                }
              }

              if (_perDiemHtmlString.isNotEmpty) {
                if (perDiemTemplateId == 0) {
                  var res = await postOfferLatterTemplate(
                    context: context,
                    templateName: 'Per Diem Offer Latter',
                    template: _perDiemHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    perDiemTemplateId = res.templateId!;
                  } else {
                    print('Failed to upload Per Diem Template. Status: ${res.statusCode}');
                  }
                } else {
                  var res = await patchOfferLatterTemplate(
                    context: context,
                    templateId: perDiemTemplateId,
                    templateName: 'Per Diem Offer Latter',
                    template: _perDiemHtmlString,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    perDiemTemplateId = res.templateId!;
                  } else {
                    print('Failed to patch Per Diem Template. Status: ${res.statusCode}');
                  }
                }
              }

              await widget.onSavePressed(
                selectedColorToSave,
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
    );
  }

  Widget _buildSectionLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AllPopupHeadings.customTextStyle(context),
        children: [
          TextSpan(
            text: (text == "Child Employee Type" || text == "Master Employee Type") ? '' : ' *',
            style: AllPopupHeadings.customTextStyle(context).copyWith(color: ColorManager.red),
          ),
        ],
      ),
    );
  }
}
///
///
///