import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establish_theme_manager.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import '../../../../../../../app/resources/const_string.dart';
import '../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/ci_visit_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/manage_details_manager.dart';
import '../../../../../../../data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import '../../../../../../../data/api_data/establishment_data/ci_manage_button/manage_details_data.dart';
import '../../../../../../../data/api_data/establishment_data/company_identity/ci_visit_data.dart';
import '../../../../widgets/dialogue_template.dart';
import '../../whitelabelling/success_popup.dart';

class EditVisitPopup extends StatefulWidget {
  final TextEditingController nameOfDocumentController;
  final TextEditingController idOfDocumentController;
  final TextEditingController serviceNameSelected;
  final bool? enable;
  final String title;
  final int visitId;
  final List<EligibleClinician> prefilledClinicians;

  const EditVisitPopup({
    super.key,
    this.enable,
    required this.nameOfDocumentController,
    required this.idOfDocumentController,
    required this.title,
    required this.visitId,
    required this.prefilledClinicians,
    required this.serviceNameSelected,
  });

  @override
  State<EditVisitPopup> createState() => _EditVisitPopupState();
}

class _EditVisitPopupState extends State<EditVisitPopup> {
  bool isLoading = false;
  bool _isNameOfDocumentValid = true;
  String _nameOfDocumentErrorText = '';

  List<Widget> selectedChips = [];
  List<Widget> chipsList = [];
  List<String> editChipValues = [];
  List<int> selectedChipsId = [];
  List<Widget> selectedEditChips = [];
  List<int> selectedEditChipsId = [];

  String? selectedServiceName;
  String? serviceId;
  int empTypeId = 0;
  late String originalName;

  bool _isClinicianSelectionValid = true;
  String _clinicianErrorText = '';

  @override
  void initState() {
    super.initState();
    originalName = widget.nameOfDocumentController.text;
    for (var clinician in widget.prefilledClinicians) {
      selectedEditChipsId.add(clinician.employeeTypeId);
      editChipValues.add(clinician.eligibleClinician);
      selectedEditChips.add(
        Chip(
          backgroundColor: ColorManager.white,
          shape: StadiumBorder(
            side: BorderSide(color: ColorManager.blueprime),
          ),
          deleteIcon: Icon(
            Icons.close,
            color: ColorManager.blueprime,
            size: IconSize.I16,
          ),
          label: Text(
            clinician.eligibleClinician,
            style: CustomTextStylesCommon.commonStyle(
              fontWeight: FontWeight.w500,
              fontSize: FontSize.s10,
              color: ColorManager.mediumgrey,
            ),
          ),
          onDeleted: () {
            setState(() {
              editChipValues.remove(clinician.eligibleClinician);
              selectedEditChips.removeWhere((chip) {
                final chipText = (chip as Chip).label as Text;
                return chipText.data == clinician.eligibleClinician;
              });
              selectedEditChipsId.remove(clinician.employeeTypeId);
              _validateClinicianSelection();
            });
          },
        ),
      );
    }
  }

  void _validateClinicianSelection() {
    setState(() {
      if (selectedEditChips.isEmpty) {
        _isClinicianSelectionValid = false;
        _clinicianErrorText = 'Please select at least one clinician.';
      } else {
        _isClinicianSelectionValid = true;
        _clinicianErrorText = '';
      }
    });
  }

  void _validateInputs() {
    setState(() {
      final nameOfDocumentText = widget.nameOfDocumentController.text;

      if (nameOfDocumentText.isEmpty) {
        _isNameOfDocumentValid = false;
        _nameOfDocumentErrorText = 'Please Enter Type of Visit';
      } else {
        _isNameOfDocumentValid = true;
        _nameOfDocumentErrorText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s500,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p10,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FirstSMTextFConst(
                      enable: widget.enable,
                      controller: widget.nameOfDocumentController,
                      keyboardType: TextInputType.text,
                      text: AppStringEM.typeVisit,
                    ),
                  ],
                ),
                SizedBox(height: AppSize.s10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FirstSMTextFConst(
                      enable: false,
                      controller: widget.serviceNameSelected,
                      keyboardType: TextInputType.text,
                      text: AppStringEM.serviceName,
                    ),
                  ],
                ),
                SizedBox(height: AppSize.s14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Select Eligible Clinician",
                        style: AllPopupHeadings.customTextStyle(context),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: AllPopupHeadings.customTextStyle(context).copyWith(
                              color: ColorManager.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.s5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<List<HRAllData>>(
                          future: getAllHrDeptWise(context, 1),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CICCDropdown(
                                items: [],
                              );
                            }
                            if (snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  AppString.dataNotFound,
                                  style: AllNoDataAvailable.customTextStyle(context),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              int docType = 0;
                              List<DropdownMenuItem<String>> dropDownTypesList = [];
                              for (var i in snapshot.data!) {
                                dropDownTypesList.add(
                                  DropdownMenuItem<String>(
                                    child: Text(i.abbrivation!),
                                    value: i.abbrivation,
                                  ),
                                );
                              }
                              return CICCDropdown(
                                constraintHeight: 100,
                                //initialValue: dropDownTypesList[0].value,
                                hintText: 'Select',
                                onChange: (val) {
                                  for (var a in snapshot.data!) {
                                    if (a.abbrivation == val) {
                                      docType = a.employeeTypesId;
                                      empTypeId = docType;

                                      setState(() {
                                        if (val.isNotEmpty && !editChipValues.contains(val)) {
                                          editChipValues.add(val);

                                          selectedEditChips.add(
                                            Chip(
                                              backgroundColor: ColorManager.white,
                                              shape: StadiumBorder(
                                                side: BorderSide(color: ColorManager.blueprime),
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
                                                setState(() {
                                                  editChipValues.remove(val);
                                                  selectedEditChips.removeWhere((chip) {
                                                    final chipText = (chip as Chip).label as Text;
                                                    return chipText.data == val;
                                                  });
                                                  selectedEditChipsId.remove(docType);
                                                  _validateClinicianSelection();
                                                });
                                              },
                                            ),
                                          );

                                          selectedEditChipsId.add(docType);
                                          _validateClinicianSelection();
                                        }
                                      });
                                    }
                                  }
                                },
                                items: dropDownTypesList,
                              );
                            }
                            return SizedBox();
                          },
                        ),
                        SizedBox(height: AppSize.s3),
                        // ── FIXED: constrained height + scrollbar to avoid RenderFlex overflow ──
                        SizedBox(
                          height: 90,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: selectedEditChips,
                              ),
                            ),
                          ),
                        ),
                        // ────────────────────────────────────────────────────────────────────────
                        !_isClinicianSelectionValid
                            ? Container(
                          height: AppSize.s35,
                          color: Colors.white,
                          child: Text(
                            _clinicianErrorText,
                            style: CommonErrorMsg.customTextStyle(context),
                          ),
                        )
                            : SizedBox(height: AppSize.s5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      bottomButtons: isLoading
          ? SizedBox(
        width: AppSize.s30,
        height: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          _validateInputs();
          _validateClinicianSelection();
          if (_isNameOfDocumentValid && _isClinicianSelectionValid) {
            setState(() {
              isLoading = true;
            });
            try {
              if (selectedEditChips.isEmpty) {
                for (var i in widget.prefilledClinicians) {
                  selectedEditChipsId.add(i.employeeTypeId);
                  editChipValues.add(i.eligibleClinician);
                  selectedEditChips.add(
                    Chip(
                      backgroundColor: ColorManager.white,
                      shape: StadiumBorder(
                        side: BorderSide(color: ColorManager.blueprime),
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        color: ColorManager.blueprime,
                        size: 17,
                      ),
                      label: Text(
                        i.eligibleClinician,
                        style: CustomTextStylesCommon.commonStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: FontSize.s10,
                          color: ColorManager.mediumgrey,
                        ),
                      ),
                      onDeleted: () {
                        setState(() {
                          editChipValues.remove(i.eligibleClinician);
                          selectedEditChips.removeWhere((chip) {
                            final chipText = (chip as Chip).label as Text;
                            return chipText.data == i.eligibleClinician;
                          });
                          selectedEditChipsId.remove(i.employeeTypeId);
                        });
                      },
                    ),
                  );
                }
              }
              String finalVisitName = widget.nameOfDocumentController.text == originalName
                  ? originalName
                  : widget.nameOfDocumentController.text;
              var response = await updateVisitPatch(
                context: context,
                typeVisist: widget.visitId,
                visitType: finalVisitName,
                eligibleClinical: selectedEditChipsId,
                serviceId: widget.serviceNameSelected.text,
              );
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddSuccessPopup(
                      message: 'Edit Successfully',
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
                  builder: (BuildContext context) => FailedPopup(text: response.message),
                );
              }
            } finally {
              setState(() {
                isLoading = false;
              });
              widget.idOfDocumentController.clear();
              widget.nameOfDocumentController.clear();
              editChipValues.clear();
              selectedEditChipsId.clear();
              selectedEditChips.clear();
            }
          } else {
            _validateInputs();
            _validateClinicianSelection();
          }
        },
      ),
      title: widget.title,
    );
  }
}

///add popup
class AddVisitPopup extends StatefulWidget {
  final TextEditingController nameOfDocumentController;
  final TextEditingController idOfDocumentController;
  final bool? enable;
  final String title;

  const AddVisitPopup({
    super.key,
    this.enable,
    required this.nameOfDocumentController,
    required this.idOfDocumentController,
    required this.title,
  });

  @override
  State<AddVisitPopup> createState() => _AddVisitPopupState();
}

class _AddVisitPopupState extends State<AddVisitPopup> {
  bool isLoading = false;
  bool _isNameOfDocumentValid = true;
  String _nameOfDocumentErrorText = '';

  bool _isServiceSelected = true;
  String _serviceErrorText = '';
  bool _isClinicianSelected = true;
  bool _isClinicianValid = true;
  String _clinicianErrorText = '';

  String selectedServiceName = 'Select';
  String? serviceId;
  int empTypeId = 0;

  List<Widget> selectedChips = [];
  List<Widget> chipsList = [];
  List<String> editChipValues = [];
  List<int> selectedChipsId = [];
  List<Widget> selectedEditChips = [];
  List<int> selectedEditChipsId = [];

  @override
  void initState() {
    super.initState();
    widget.nameOfDocumentController.addListener(_handleNameOfDocumentChange);
  }

  @override
  void dispose() {
    widget.nameOfDocumentController.removeListener(_handleNameOfDocumentChange);
    super.dispose();
  }

  void _handleNameOfDocumentChange() {
    setState(() {
      if (widget.nameOfDocumentController.text.isNotEmpty) {
        _isNameOfDocumentValid = true;
        _nameOfDocumentErrorText = '';
      }
    });
  }

  void _onServiceChanged(String? value, List<ServicesMetaData> services) {
    setState(() {
      selectedServiceName = value!;

      final selectedService = services.firstWhere(
            (service) => service.serviceName == value,
      );

      serviceId = selectedService.serviceId;

      if (selectedServiceName != 'Select') {
        _isServiceSelected = true;
        _serviceErrorText = '';
      }
    });
  }

  void _validateInputs() {
    setState(() {
      final nameOfDocumentText = widget.nameOfDocumentController.text;
      if (nameOfDocumentText.isEmpty) {
        _isNameOfDocumentValid = false;
        _nameOfDocumentErrorText = 'Please Enter Type of Visit';
      } else {
        _isNameOfDocumentValid = true;
        _nameOfDocumentErrorText = '';
      }

      if (selectedServiceName.isEmpty || selectedServiceName == "Select") {
        _isServiceSelected = false;
        _serviceErrorText = 'Please select a service';
      } else {
        _isServiceSelected = true;
        _serviceErrorText = '';
      }

      if (selectedEditChips.isEmpty) {
        _isClinicianSelected = false;
        _clinicianErrorText = 'Please select at least one eligible clinician';
      } else {
        _isClinicianSelected = true;
        _clinicianErrorText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s500,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Type of Visit field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SMTextfieldAsteric(
                    enable: widget.enable,
                    controller: widget.nameOfDocumentController,
                    keyboardType: TextInputType.text,
                    text: AppStringEM.typeVisit,
                  ),
                  !_isNameOfDocumentValid
                      ? Text(
                    _nameOfDocumentErrorText,
                    style: CommonErrorMsg.customTextStyle(context),
                  )
                      : SizedBox(height: AppSize.s12),
                ],
              ),
              SizedBox(height: AppSize.s8),

              // Service dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Select Services",
                      style: AllPopupHeadings.customTextStyle(context),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: AllPopupHeadings.customTextStyle(context).copyWith(
                            color: ColorManager.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSize.s5),
                  FutureBuilder<List<ServicesMetaData>>(
                    future: getServicesMetaData(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: AppSize.s354,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorManager.containerBorderGrey,
                              width: AppSize.s1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: AppSize.s10),
                              Expanded(
                                child: Text(
                                  selectedServiceName,
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: AppPadding.p8),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshot.data!.isEmpty) {
                        return Container(
                          width: AppSize.s354,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorManager.containerBorderGrey,
                              width: AppSize.s1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p7,
                              vertical: AppPadding.p5,
                            ),
                            child: Text(
                              ErrorMessageString.noserviceAdded,
                              style: AllNoDataAvailable.customTextStyle(context),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        List<DropdownMenuItem<String>> dropDownServiceList = [];
                        for (var service in snapshot.data!) {
                          dropDownServiceList.add(
                            DropdownMenuItem<String>(
                              value: service.serviceName,
                              child: Text(service.serviceName ?? ''),
                            ),
                          );
                        }

                        return StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return CICCDropdown(
                              initialValue: selectedServiceName,
                              onChange: (val) => _onServiceChanged(val, snapshot.data!),
                              items: dropDownServiceList,
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  !_isServiceSelected
                      ? Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      _serviceErrorText,
                      style: CommonErrorMsg.customTextStyle(context),
                    ),
                  )
                      : SizedBox(height: AppSize.s14),
                ],
              ),

              SizedBox(height: AppSize.s8),

              // Eligible Clinician section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Select Eligible Clinician",
                      style: AllPopupHeadings.customTextStyle(context),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: AllPopupHeadings.customTextStyle(context).copyWith(
                            color: ColorManager.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSize.s5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<HRAllData>>(
                        future: getAllHrDeptWise(context, 1),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CICCDropdown(
                              items: [],
                              hintText: 'Select Clinician',
                            );
                          }
                          if (snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                AppString.dataNotFound,
                                style: AllNoDataAvailable.customTextStyle(context),
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            int docType = 0;
                            List<DropdownMenuItem<String>> dropDownTypesList = [];
                            for (var i in snapshot.data!) {
                              dropDownTypesList.add(
                                DropdownMenuItem<String>(
                                  child: Text(i.abbrivation!),
                                  value: i.abbrivation,
                                ),
                              );
                            }
                            return CICCDropdown(
                              constraintHeight: 150,
                             // initialValue: null,
                              hintText: 'Select',
                              onChange: (val) {
                                for (var a in snapshot.data!) {
                                  if (a.abbrivation == val) {
                                    docType = a.employeeTypesId;
                                    empTypeId = docType;

                                    if (!editChipValues.contains(val)) {
                                      setState(() {
                                        editChipValues.add(val);
                                        selectedEditChips.add(
                                          Chip(
                                            backgroundColor: ColorManager.white,
                                            shape: StadiumBorder(
                                              side: BorderSide(color: ColorManager.blueprime),
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
                                              setState(() {
                                                editChipValues.remove(val);
                                                selectedEditChips.removeWhere((chip) {
                                                  final chipText = (chip as Chip).label as Text;
                                                  return chipText.data == val;
                                                });
                                                selectedEditChipsId.remove(docType);
                                                if (editChipValues.isEmpty) {
                                                  _isClinicianValid = false;
                                                  _clinicianErrorText =
                                                  'Please select eligible clinician';
                                                }
                                              });
                                            },
                                          ),
                                        );
                                        selectedEditChipsId.add(docType);
                                        _isClinicianValid = true;
                                        _clinicianErrorText = '';
                                      });
                                    }
                                  }
                                }
                              },
                              items: dropDownTypesList,
                            );
                          }
                          return SizedBox();
                        },
                      ),
                      !_isClinicianSelected
                          ? Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          _clinicianErrorText,
                          style: CommonErrorMsg.customTextStyle(context),
                        ),
                      )
                          : SizedBox(height: AppSize.s14),
                      // ── FIXED: constrained height + scrollbar to avoid RenderFlex overflow ──
                      SizedBox(
                        height: 90,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedEditChips,
                            ),
                          ),
                        ),
                      ),
                      // ────────────────────────────────────────────────────────────────────────
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      bottomButtons: isLoading
          ? SizedBox(
        width: AppSize.s30,
        height: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          _validateInputs();
          if (_isNameOfDocumentValid && _isServiceSelected && _isClinicianSelected) {
            setState(() {
              isLoading = true;
            });
            try {
              var response = await addVisitPost(
                context: context,
                typeOfVisit: widget.nameOfDocumentController.text,
                eligibleClinician: selectedEditChipsId,
                serviceId: serviceId!,
              );
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddSuccessPopup(
                      message: 'Added Successfully',
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
                  builder: (BuildContext context) => FailedPopup(text: response.message),
                );
              }
              selectedChipsId.clear();
              selectedChips.clear();
            } finally {
              setState(() {
                isLoading = false;
              });
              widget.idOfDocumentController.clear();
              widget.nameOfDocumentController.clear();
            }
          }
        },
      ),
      title: widget.title,
    );
  }
}