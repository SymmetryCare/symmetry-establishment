import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profilebar_editor.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
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
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/add_coverage_popup.dart';

class ProfileBarEditPopup extends StatefulWidget {
  final int employeeId;
  final int employeeEnrollId;
  final int employeeEnrollCoverageId;
  final String countyNameValue;
  final String zoneNameValue;
  final int zoneId;
  final int countyId;
  final List<int> zipCode;
  final VoidCallback onRefresh;
  final String officeId;
  const ProfileBarEditPopup({
    super.key,
    required this.employeeId,
    required this.employeeEnrollId,
    required this.employeeEnrollCoverageId,
    required this.onRefresh,
    required this.countyNameValue,
    required this.zoneNameValue,
    required this.zoneId,
    required this.countyId,
    required this.zipCode,
    required this.officeId,
  });

  @override
  State<ProfileBarEditPopup> createState() => _ProfileBarEditPopupState();
}

class _ProfileBarEditPopupState extends State<ProfileBarEditPopup> {
  // FIX: cache the future once instead of calling getCountyByCompanyId()
  // inline inside FutureBuilder's `future:` param — that re-fired the API
  // call on every rebuild.
  late final Future<List<AllCountyByOfficeId>> _countyFuture;

  @override
  void initState() {
    // TODO: implement initState
    selectedCounty = widget.countyNameValue;
    countyName = widget.countyNameValue;
    zoneName = widget.zoneNameValue;
    docZoneId = widget.zoneId;
    selectedCountyId = widget.countyId;
    selectedZipCodeZone = widget.zoneNameValue;
    zipCodes = widget.zipCode;

    // If zip codes are passed in initState, check the checkboxes
    for (var zip in zipCodes) {
      checkedZipCodes[zip.toString()] = true;
    }

    print("<<<<<<<Selected County: $selectedCounty");
    print("<<<<<<<County Name: $countyName");
    print(">>>>Zone Name: $zoneName");
    print("><<<<<<<Document Zone ID: $docZoneId");
    print(">>>>Selected County ID: $selectedCountyId");
    print(">>>>Selected Zip Code Zone: $selectedZipCodeZone");
    print("><<<<<<<Selected Zip Code Zone: $zipCodes");

    super.initState();

    _countyFuture = getCountyByCompanyId(context, widget.officeId);

    // FIX: these were previously fetched inline inside their StreamBuilder's
    // `builder:` callback, which re-fired the API call on every rebuild.
    // Load once here for the initial (pre-filled) selection, and re-trigger
    // explicitly from the county/zone onChange handlers below when the
    // dependent selection actually changes.
    _loadZoneData();
    _loadZipCodeData();

    // Call the method to load the zone value based on pre-filled data
    //loadZoneValue();
  }

  void _loadZoneData() {
    fetchCountyWiseZone(context, selectedCountyId).then((data) {
      if (!mounted) return;
      _zoneController.add(data);
    }).catchError((error) {
      if (!mounted) return;
      _zoneController.addError(error);
    });
  }

  void _loadZipCodeData() {
    getZipcodeByCountyIdAndZoneId(
      context: context,
      countyId: selectedCountyId,
      zoneId: docZoneId,
    ).then((data) {
      if (!mounted) return;
      _countyStreamController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  int selectedZoneId = 0;
  int selectedCountyId = 0;
  int selectedCityId = 0;
  String? selectedZone;
  String? selectedCounty;
  Map<String, bool> checkedZipCodes = {};
  Map<String, bool> checkedCityName = {};
  List<String> selectedZipCodes = [];
  List<String> selectedCityName = [];
  String selectedZipCodesString = '';
  List<int> zipCodes = [];
  String? selectedZipCodeZone;
  int docZoneId = 0;
  var deptId = 1;
  int? firstDeptId;
  String? selectedDeptName;
  List<DropdownMenuItem<String>> countyDropDownList = [];
  List<DropdownMenuItem<String>> zoneDropDownList = [];
  String selectedCovrageCounty = "Select County";
  String selectedCovrageZone = "Select Zone";
  final StreamController<List<CountyWiseZoneModal>> _zoneController =
  StreamController<List<CountyWiseZoneModal>>.broadcast();
  List<ApiPatchCovrageData> addCovrage = [];
  final StreamController<List<ZipcodeByCountyIdAndZoneIdData>>
  _countyStreamController =
  StreamController<List<ZipcodeByCountyIdAndZoneIdData>>.broadcast();

  String countyName = "";
  String? zoneName = "";

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: 420,
      height: 560,
      title: 'Edit Coverage',
      body: [
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///county zone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 125,
                width: 354,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "County", // Main text
                        style: AllPopupHeadings.customTextStyle(context), // Main style
                        children: [
                          TextSpan(
                            text: ' *', // Asterisk
                            style: AllPopupHeadings.customTextStyle(context).copyWith(
                              color: ColorManager.red, // Asterisk color
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder<List<AllCountyByOfficeId>>(
                      future: _countyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CICCDropDownedit(
                                width: AppSize.s354,
                                hintText: '',
                                items: [],
                              ),
                              const SizedBox(height: 15),
                              RichText(
                                text: TextSpan(
                                  text: "Zone", // Main text
                                  style: AllPopupHeadings.customTextStyle(context), // Main style
                                  children: [
                                    TextSpan(
                                      text: ' *', // Asterisk
                                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                                        color: ColorManager.red, // Asterisk color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              const CICCDropDownedit(
                                width: AppSize.s354,
                                hintText: '',
                                items: [],
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const Text("Error fetching counties");
                        } else if (snapshot.hasData) {
                          countyDropDownList.clear();
                          for (var county in snapshot.data!) {
                            countyDropDownList.add(
                              DropdownMenuItem<String>(
                                child: Text(county.countyName),
                                value: county.countyName,
                              ),
                            );
                          }
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // County Dropdown
                                  CICCDropDownedit(
                                    items: countyDropDownList,
                                    initialValue: selectedCounty,
                                    width: AppSize.s354,
                                    onChange: (newValue) async {
                                      setState(() {
                                        selectedCounty = newValue;
                                        selectedCovrageCounty = newValue;
                                      });
                                      for (var county in snapshot.data!) {
                                        if (county.countyName == newValue) {
                                          selectedCountyId = county.countyId;
                                          countyName = county.countyName;
                                          // break;
                                        }
                                      }
                                      print("Selected CountyId: $selectedCountyId");
                                      // Re-fetch zones for the newly selected county.
                                      _loadZoneData();
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  RichText(
                                    text: TextSpan(
                                      text: "Zone", // Main text
                                      style: AllPopupHeadings.customTextStyle(context), // Main style
                                      children: [
                                        TextSpan(
                                          text: ' *', // Asterisk
                                          style: AllPopupHeadings.customTextStyle(context).copyWith(
                                            color: ColorManager.red, // Asterisk color
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  StreamBuilder<List<CountyWiseZoneModal>>(
                                      stream: _zoneController.stream,
                                      builder: (context, snapshotZone) {
                                        if (snapshotZone.connectionState == ConnectionState.waiting) {
                                          return Container(
                                            width: AppSize.s354,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: ColorManager.containerBorderGrey, width: AppSize.s1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  zoneName!,
                                                  style: AllNoDataAvailable.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        if (snapshotZone.data!.isEmpty) {
                                          return Container(
                                            width: AppSize.s354,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: ColorManager.containerBorderGrey, width: AppSize.s1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  ErrorMessageString.noZones,
                                                  style: AllNoDataAvailable.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        if (snapshotZone.hasData) {
                                          // List dropDown = [];
                                          // int docType = 0;
                                          List<DropdownMenuItem<String>> dropDownTypesList = [];
                                          for (var i in snapshotZone.data!) {
                                            dropDownTypesList.add(
                                              DropdownMenuItem<String>(
                                                value: i.zoneName,
                                                child: Text(i.zoneName),
                                              ),
                                            );
                                          }
                                          // if (selectedZipCodeZone == null) {
                                          //   selectedZipCodeZone =
                                          //       snapshotZone.data![0].zoneName;
                                          // }
                                          return CICCDropDownedit(
                                              width: AppSize.s354,
                                              initialValue: zoneName,
                                              onChange: (val) {
                                                selectedZipCodeZone = val;
                                                selectedCovrageZone = val;
                                                for (var a in snapshotZone.data!) {
                                                  if (a.zoneName == val) {
                                                    // docType = a.zone_id;
                                                    zoneName = a.zoneName;
                                                    print("ZONE id :: ${a.zone_id}");
                                                    docZoneId = a.zone_id;
                                                  }
                                                }
                                                //print(":::${docType}");
                                                print(":::<>${docZoneId}");
                                                // Re-fetch zip codes for the newly selected zone.
                                                _loadZipCodeData();
                                              },
                                              items: dropDownTypesList);
                                        }
                                        return const SizedBox();
                                      }),
                                ],
                              );
                            },
                          );
                        } else {
                          return const Text('No Data available');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        /// Zipcode
        Container(
          height: 200,
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: "Zip Codes", // Main text
                  style: AllPopupHeadings.customTextStyle(context), // Main style
                  children: [
                    TextSpan(
                      text: ' *', // Asterisk
                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                        color: ColorManager.red, // Asterisk color
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              /// Removed TabBar code
              Expanded(
                child: StreamBuilder<List<ZipcodeByCountyIdAndZoneIdData>>(
                  stream: _countyStreamController.stream,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }

                    if (selectedCountyId == 0) {
                      return Center(
                        child: Text(
                          'Select county',
                          style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12, fontWeight: FontWeight.w500, color: ColorManager.mediumgrey),
                        ),
                      );
                    }

                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No Zipcode Available!',
                          style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12, color: ColorManager.mediumgrey, fontWeight: FontWeight.w500),
                        ),
                      );
                    }

                    return StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) setState) {
                        return GridView.builder(
                          padding: EdgeInsets.zero, // no default GridView padding, keeps checkboxes flush left under heading
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two items per row
                            childAspectRatio: 6,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            String zipCode = snapshot.data![index].zipCode;
                            bool isChecked = zipCodes.contains(int.parse(zipCode))
                                ? checkedZipCodes[zipCode] = true
                                : checkedZipCodes[zipCode] ?? false;
                            return CheckBoxCoverageTileConst(
                              text: zipCode,
                              value: isChecked,
                              onChanged: (bool? val) {
                                setState(() {
                                  print('Clicked check box 1');
                                  checkedZipCodes[zipCode] = val ?? false;
                                  if (val == true) {
                                    selectedZipCodes.add(zipCode);
                                    zipCodes.add(int.parse(snapshot.data![index].zipCode));
                                  } else {
                                    selectedZipCodes.remove(zipCode);
                                    zipCodes.remove(int.parse(snapshot.data![index].zipCode));
                                  }
                                  selectedZipCodesString = selectedZipCodes.join(', ');
                                });
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
      bottomButtons: CustomButton(
        height: AppSize.s30,
        width: AppSize.s100,
        text: 'Save',
        onPressed: () async {
          if (selectedCounty == null || selectedCounty!.isEmpty) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AddErrorPopup(
                  message: 'Please select a county',
                );
              },
            );
            // _showErrorDialog('Please select a county.');
            return;
          }

          // if (selectedZipCodes.isEmpty) {
          //   await showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return AddErrorPopup(
          //       message: 'Please select at least one zip code',
          //     );
          //   },
          //   );
          //   // _showErrorDialog('Please select at least one zip code.');
          //   return;
          // }

          if (checkedZipCodes.values.every((isChecked) => !isChecked)) {
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
            // _showErrorDialog('Please select a zone.');
            return;
          }
          // List<int> zipCodesAsInt = selectedZipCodes.map((zip) => int.parse(zip)).toList();

          addCovrage.add(ApiPatchCovrageData(
              employeeEnrollCoverageId: widget.employeeEnrollCoverageId,
              city: "",
              countyId: selectedCountyId,
              countyName: countyName,
              zoneId: docZoneId,
              zoneName: zoneName!,
              zipCodes: zipCodes));
          //var patchCoverage =
          patchEmpEnrollAddCoverage(context, widget.employeeEnrollId, widget.employeeId, addCovrage);
          // if (patchCoverage.success) {
          //     print("Coverage added successfully");
          //   } else {
          //     print("Failed To Add Coverage........");
          //   }

          print('Selected County ID: $selectedCountyId');
          print('Selected coverage ID::::::::::::::::: ${widget.employeeEnrollCoverageId} ...................,');
          print('Selected Zone ID: $docZoneId');
          print('//////Selected Zip Codes: $selectedZipCodes');
          print('?>>>>>>>>>>>Selected Zip Codes: $zipCodes');
          //  print('Selected City: $selectedCityName');
          setState(() {
            getCoverageList(context: context, employeeId: widget.employeeId, employeeEnrollId: widget.employeeEnrollId);
          });
          widget.onRefresh();
          Navigator.pop(context);
        },
      ),
    );
  }
}