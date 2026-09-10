import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profilebar_editor.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/profile_editor/profile_editor.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/offer_letter_screen.dart';

class ProfileBarAddPopup extends StatefulWidget {
  final int employeeId;
  final int employeeEnrollId;
  final VoidCallback onRefresh;
  final String officeId;
  const ProfileBarAddPopup({
    super.key,
    required this.employeeId,
    required this.employeeEnrollId,
    required this.onRefresh,
    required this.officeId,
  });

  @override
  State<ProfileBarAddPopup> createState() => _ProfileBarAddPopupState();
}

class _ProfileBarAddPopupState extends State<ProfileBarAddPopup> {
  int selectedZoneId = 0;
  int selectedCountyId = 0;
  String? selectedZone;
  String? selectedCounty;
  Map<String, bool> checkedZipCodes = {};
  List<String> selectedZipCodes = [];
  String selectedZipCodesString = '';
  List<int> zipCodes = [];
  String? selectedZipCodeZone;
  int docZoneId = 0;

  String selectedCovrageCounty = "Select County";
  String selectedCovrageZone = "Select Zone";

  final StreamController<List<CountyWiseZoneModal>> _zoneController =
  StreamController<List<CountyWiseZoneModal>>.broadcast();
  final StreamController<List<ZipcodeByCountyIdAndZoneIdData>>
  _countyStreamController =
  StreamController<List<ZipcodeByCountyIdAndZoneIdData>>.broadcast();
  List<ApiAddCovrageData> addCovrage = [];
  bool isButtonEnabled = false;

  Future<List<CountyWiseZoneModal>>? _zoneFuture;
  late Future<List<AllCountyByOfficeId>> _countyFuture;

  final FocusNode _countyFocus = FocusNode();
  final FocusNode _zoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _countyFuture = getCountyByCompanyId(context, widget.officeId);
    _fetchCountyWiseZone();
  }

  @override
  void dispose() {
    _countyFocus.dispose();
    _zoneFocus.dispose();
    super.dispose();
  }

  Widget _buildPlaceholder({String text = ""}) {
    return Container(
      width: 354,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.containerBorderGrey, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: Text(text, style: AllNoDataAvailable.customTextStyle(context))),
    );
  }

  void _fetchCountyWiseZone() async {
    if (selectedCountyId > 0) {
      try {
        final future = fetchCountyWiseZone(context, selectedCountyId);
        setState(() {
          _zoneFuture = future;
          selectedZipCodeZone = null; // reset zone while new county loads
        });
        List<CountyWiseZoneModal> data = await future;
        _zoneController.add(data);

        if (data.isNotEmpty) {
          // Auto-select the first zone
          setState(() {
            selectedZipCodeZone = data.first.zoneName;
            selectedCovrageZone = data.first.zoneName;
            docZoneId = data.first.zone_id;
          });

          // Fetch zip codes for the selected county and first zone
          _fetchZipCodes();
        }
      } catch (e) {
        _zoneController.addError("Error fetching zones");
      }
    } else {
      setState(() {
        _zoneFuture = null;
      });
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

  // void _updateButtonState() {
  //   setState(() {
  //     isButtonEnabled = selectedCounty != null &&
  //         selectedCounty!.isNotEmpty &&
  //         (zipCodes.isEmpty || selectedZipCodes.isNotEmpty) &&
  //         selectedZipCodeZone != null &&
  //         selectedZipCodeZone!.isNotEmpty;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: 420,
      height: 560,
      title: 'Add Coverage',
      body: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// County & Zone
            Container(
              height: 130,
              width: 355,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('County', style: AllPopupHeadings.customTextStyle(context)),
                  const SizedBox(height: 5),
                  FutureBuilder<List<AllCountyByOfficeId>>(
                    future: _countyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CICCDropdown(width: 354, hintText: 'Select County', items: []);
                      }
                      if (snapshot.hasError) {
                        return const Text("Error fetching counties");
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No Data available');
                      }

                      List<DropdownMenuItem<String>> countyDropDownList = snapshot.data!
                          .map((county) => DropdownMenuItem<String>(
                        value: county.countyName,
                        child: Text(county.countyName),
                      ))
                          .toList();

                      return CICCDropdown(
                        focusNode: _countyFocus,
                        items: countyDropDownList,
                        initialValue: selectedCounty,
                        width: 354,
                        onChange: (newValue) {
                          setState(() {
                            selectedCounty = newValue;
                            selectedCovrageCounty = newValue;
                            selectedCountyId = snapshot.data!
                                .firstWhere((county) => county.countyName == newValue)
                                .countyId;
                            _fetchCountyWiseZone(); // Fetch zones based on selected county
                            //  _updateButtonState();
                          });
                          _zoneFocus.requestFocus();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zone', style: AllPopupHeadings.customTextStyle(context)),
                          const SizedBox(height: 5),
                          FutureBuilder<List<CountyWiseZoneModal>>(
                            future: _zoneFuture,
                            builder: (context, snapshot) {
                              if (_zoneFuture == null || selectedCountyId == 0) {
                                return _buildPlaceholder(text: " ");
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildPlaceholder();
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildPlaceholder(text: "No zones available");
                              }

                              List<DropdownMenuItem<String>> zoneDropDownList = snapshot.data!
                                  .map((zone) => DropdownMenuItem<String>(
                                value: zone.zoneName,
                                child: Text(zone.zoneName),
                              ))
                                  .toList();

                              return CICCDropdown(
                                focusNode: _zoneFocus,
                                width: 354,
                                initialValue: selectedZipCodeZone, // Set the auto-selected zone
                                onChange: (val) {
                                  setState(() {
                                    selectedZipCodeZone = val;
                                    selectedCovrageZone = val;
                                    docZoneId = snapshot.data!
                                        .firstWhere((zone) => zone.zoneName == val)
                                        .zone_id;
                                  });

                                  _fetchZipCodes(); // Fetch zip codes for the selected zone
                                  FocusScope.of(context).unfocus(); // skip zip codes from focus chain
                                  // _updateButtonState();
                                },
                                items: zoneDropDownList,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Zip Codes
            StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zip Codes',
                      style: AllPopupHeadings.customTextStyle(context),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 350,
                      height: 200,
                      child: StreamBuilder<List<ZipcodeByCountyIdAndZoneIdData>>(
                        stream: _countyStreamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          if (selectedCountyId == 0 || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                selectedCountyId == 0
                                    ? 'Select County'
                                    : 'No Zipcode Available!',
                                style: NumberTExtFieldLegalDoc.customTextStyle(context),
                              ),
                            );
                          }

                          List<ZipcodeByCountyIdAndZoneIdData> zipCodeList = snapshot.data!;

                          // If only one zip code is available, set it as checked
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (zipCodeList.length == 1) {
                              String singleZip = zipCodeList.first.zipCode;
                              if (!checkedZipCodes.containsKey(singleZip)) {
                                setState(() {
                                  checkedZipCodes[singleZip] = true;
                                  selectedZipCodes.add(singleZip);
                                  zipCodes.add(int.parse(singleZip));
                                  selectedZipCodesString = selectedZipCodes.join(', ');
                                  // _updateButtonState();
                                });
                              }
                            }
                          });

                          return GridView.builder(
                            padding: EdgeInsets.zero, // remove default GridView padding for clean alignment
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two items per row
                              childAspectRatio: 6,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: zipCodeList.length,
                            itemBuilder: (context, index) {
                              String zipCode = zipCodeList[index].zipCode;
                              bool isChecked = checkedZipCodes[zipCode] ?? false;

                              return CheckBoxCoverageTileConst(
                                text: zipCode,
                                value: isChecked,
                                onChanged: (bool? val) {
                                  setState(() {
                                    checkedZipCodes[zipCode] = val ?? false;
                                    if (val == true) {
                                      selectedZipCodes.add(zipCode);
                                      zipCodes.add(int.parse(zipCode));
                                    } else {
                                      selectedZipCodes.remove(zipCode);
                                      zipCodes.remove(int.parse(zipCode));
                                    }
                                    selectedZipCodesString = selectedZipCodes.join(', ');
                                    //  _updateButtonState();
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
      bottomButtons: CustomButton(
        height: AppPadding.p30,
        width: AppSize.s100,
        text: 'Save',
        onPressed: () => _handleSave(),

        // onPressed: isButtonEnabled
        //     ? () => _handleSave()
        //     : null, // Disable button if fields are empty
      ),
    );
  }

  Future<void> _handleSave() async {
    if (selectedCounty == null || selectedCounty!.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AddErrorPopup(
            message: 'Please select a county',
          );
        },
      );
      return;
    }

    if (selectedZipCodes.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AddErrorPopup(
            message: 'Please select at least one zip code',
          );
        },
      );
      return;
    }

    if (selectedZipCodeZone == null || selectedZipCodeZone!.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AddErrorPopup(
            message: 'Please select a zone',
          );
        },
      );
      return;
    }

    addCovrage.add(await ApiAddCovrageData(
      city: '',
      countyId: selectedCountyId,
      zoneId: docZoneId,
      zipCodes: zipCodes,
    ));

    print('County ID:===== ${selectedCountyId}');
    print('Zone ID:::::::::=>> ${docZoneId}');
    print('Zip Codes:====== ${zipCodes}');

    await addEmpEnrollAddCoverage(
        context, widget.employeeEnrollId, widget.employeeId, addCovrage);

    widget.onRefresh();
    Navigator.pop(context);
  }
}

class CheckBoxCoverageTileConst extends StatelessWidget {
  final String text;
  bool value;
  ValueChanged<bool?> onChanged;

  CheckBoxCoverageTileConst({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        color: ColorManager.white,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                hoverColor: Colors.transparent,
                value: value,
                onChanged: onChanged,
                activeColor: ColorManager.blueprime,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(width: 1),
              ),
            ),
            const SizedBox(width: 8), // controlled gap between box and label
            Text(
              text,
              style: DocumentTypeDataStyle.customTextStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}