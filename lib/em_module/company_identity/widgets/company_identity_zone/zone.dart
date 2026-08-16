import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/const_string.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/zone_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/zone/zone_model_data.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/ci_zone_country.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/ci_zone_zone.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/widgets/ci_zone_zipcode.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/widgets/location_screen.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/widgets/zone_widgets_constants.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../app/resources/font_manager.dart';
import '../../../../../widgets/widgets/constant_textfield/const_textfield.dart';
import '../../../../../widgets/widgets/custom_icon_button_constant.dart';
import '../../company_identity_screen.dart';
import '../vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';

class CiZone extends StatefulWidget {
  final double officeLat;
  final double officeLon;
  final int companyID;
  final String officeId;
  final int docId;
  final String stateName;
  final String countryName;
  const CiZone(
      {super.key,
      required this.stateName,
      required this.countryName,
      required this.companyID,
      required this.officeId,
      required this.docId, required this.officeLat, required this.officeLon});

  @override
  State<CiZone> createState() => _CiOrgDocumentState();
}

class _CiOrgDocumentState extends State<CiZone> {
  final PageController _tabPageController = PageController();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController countynameController = TextEditingController();
  TextEditingController zonenameController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mapController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zoneNumberController = TextEditingController();
  TextEditingController countyNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  int _selectedIndex = 0;
  int docZoneId = 0;
  int countyId = 0;
  int countySortId = 0;
  int countyZipCodeSortId = 0;
  int zoneSortId = 0;
  String zoneNameVal = 'Select Zone';
  double? _latitude;
  double? _longitude;
  String coyntyNameVal = 'Select County';
  String coyntyZipNameVal = 'Select County';

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabPageController.jumpToPage(index,);
  }

  String? selectedCounty;
  String? selectedZipCodeCounty;
  String? selectedZipCodeZone;
  LatLng _selectedLocation =
       LatLng(37.7749, -122.4194); // Default location
  String?_location ;
  final StreamController<List<AllCountyZoneGet>> _zoneController =
      StreamController<List<AllCountyZoneGet>>.broadcast();
  void _pickLocation() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: _selectedLocation,
          onLocationPicked: (location) {
            setState(() {
              _selectedLocation = location;
              _latitude = location.latitude;
              _longitude = location.longitude;
              String formatLatLong(double? latitude, double? longitude) {
                if (latitude != null && longitude != null) {
                  // print('Lat : ${latitude}')
                  return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
                } else {
                  return 'Lat/Long not selected';
                }
              }

              final latlong = formatLatLong(_latitude, _longitude);

              print("Selected LatLong :: $latlong");

              // Update the location in the UI directly
              _updateLocation(latlong);
            });
          },
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });
    }
  }
  void _updateLocation(String latlong) {
    setState(() {
      _location = latlong;
      print("Updated Location: $_location");
      locationController = TextEditingController(text:_location);
      print("locationController ${locationController.text}");// Check this log to see if the value updates
    });
  }
  bool isAddButtonEnabled = false;

  // Helper: Show button only when both county and zone are selected
  bool get shouldShowAddButton {
    return selectedCounty != 'Select County' && zoneNameVal != 'Select Zone';
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: _selectedIndex == 2 ?EdgeInsets.only(
              right: AppPadding.p65,left: AppPadding.p10) : EdgeInsets.symmetric(
              horizontal: AppPadding.p65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _selectedIndex == 1
                  ? Expanded(
                flex: 2,
                    child: FutureBuilder<List<OfficeWiseCountyData>>(
                      future: getCountyListOfficeIdWise(context: context, OfficeId: widget.officeId),
                      builder: (context, snapshotZone) {
                    if (snapshotZone.connectionState == ConnectionState.waiting) {
                      return Container(
                        width:  354,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorManager.containerBorderGrey, width: AppSize.s1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: AppSize.s10),
                            Expanded(
                              child: Text(
                                coyntyNameVal ??  "Select County",
                                style: DocumentTypeDataStyle.customTextStyle(context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshotZone.data!.isEmpty) {
                      return Container(
                        height: AppSize.s30,
                        width: AppSize.s354,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: ColorManager.containerBorderGrey,
                              width: AppSize.s1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              ErrorMessageString.noCountyAdded,
                              style: DocumentTypeDataStyle.customTextStyle(context),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshotZone.hasData) {
                      List<DropdownMenuItem<String>> dropDownTypesList = [];

                      for (var i in snapshotZone.data!) {
                        dropDownTypesList.add(
                          DropdownMenuItem<String>(
                            value: i.countyName,
                            child: Text(i.countyName),
                          ),
                        );
                      }

                      if (coyntyNameVal == 'Select County') {
                        countySortId = snapshotZone.data![0].countyId;
                        countynameController.text = coyntyNameVal;
                      }

                      return CICCDropdown(
                        initialValue: coyntyNameVal,
                        onChange: (val) {
                          setState(() {
                            coyntyNameVal = val!;
                            var selectedCounty = snapshotZone.data!.firstWhere((a) => a.countyName == val);
                            countySortId = selectedCounty.countyId;
                            countynameController.text = selectedCounty.countyName;
                            isAddButtonEnabled = true;
                            _selectButton(1);
                          });
                        },
                        items: dropDownTypesList,
                      );
                    }
                    return const SizedBox();
                                      },
                                    ),
                  )
                  : _selectedIndex == 0
                  ?  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    Text( AppStringLegalDocument.ZonesMsgHead,
                      style:  LegalDocumentPopupMessage.customTextStyle(context),),
                                      ],),
                  )
                  : Expanded(
                flex: 3,
                    child: Row(
                      spacing: 10,
                      children: [
                    FutureBuilder<List<OfficeWiseCountyData>>(
                      future: getCountyListOfficeIdWise(context: context, OfficeId: widget.officeId),
                      builder: (context, snapshotZone) {
                        if (snapshotZone.connectionState == ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0, bottom: 2),
                                child: RichText(
                                  text: TextSpan(
                                    text:"County", // Main text
                                    style: AllPopupHeadings.customTextStyle(context), // Main style
                                    children: [
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: AppSize.s30,
                                width: AppSize.s200,
                                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4, right: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorManager.containerBorderGrey,
                                      width: AppSize.s1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          coyntyZipNameVal ?? 'Select Zone',
                                          style: TextStyle(
                                            fontWeight:FontWeight.w600,
                                            fontSize:  FontSize.s13,
                                            color: ColorManager.mediumgrey,
                                            decoration: TextDecoration.none,
                                          ) //DocumentTypeDataStyle.customTextStyle(context),
                                      ),
                                    ),

                                    Icon(Icons.arrow_drop_down_sharp, color:Colors.grey)
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        if (snapshotZone.data!.isEmpty) {
                          return
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5.0, bottom: 2),
                                  child: RichText(
                                    text: TextSpan(
                                      text:"County", // Main text
                                      style: AllPopupHeadings.customTextStyle(context), // Main style
                                      children: [
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: AppSize.s30,
                                  width: AppSize.s200,
                                  padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4,),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorManager.containerBorderGrey,
                                        width: AppSize.s1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 1,vertical: 3),
                                          child: Text(
                                              ErrorMessageString.noCountyAdded,
                                              style: TextStyle(
                                                fontWeight:FontWeight.w600,
                                                fontSize:  FontSize.s13,
                                                color: ColorManager.mediumgrey,
                                                decoration: TextDecoration.none,
                                              ) //DocumentTypeDataStyle.customTextStyle(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                        }
                        if (snapshotZone.hasData) {
                          List<DropdownMenuItem<String>> dropDownTypesList = [];

                          for (var i in snapshotZone.data!) {
                            dropDownTypesList.add(
                              DropdownMenuItem<String>(
                                value: i.countyName,
                                child: Text(i.countyName),
                              ),
                            );
                          }

                          if (coyntyZipNameVal == 'Select County') {
                            countyZipCodeSortId = snapshotZone.data![0].countyId;
                            countynameController.text = coyntyZipNameVal;
                          }

                          return CustomZoneFilterDropdownTextField(
                            width: AppSize.s200,
                            height: AppSize.s30,
                            initialValue: coyntyZipNameVal,
                            onChanged: (val) {
                              setState(() {
                                coyntyZipNameVal = val!;
                                var selectedCounty = snapshotZone.data!.firstWhere((a) => a.countyName == val);
                                countyZipCodeSortId = selectedCounty.countyId;
                                countynameController.text = selectedCounty.countyName;
                                zoneNameVal = 'Select Zone';
                                zoneSortId = 0;
                               // isAddButtonEnabled = true;
                                _selectButton(2);
                              });
                            },
                            dropDownMenuList: dropDownTypesList, headText: 'County',
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    FutureBuilder<List<AllCountyZoneGet>>(
                      future:  getZoneByCounty(context, widget.officeId, countyZipCodeSortId, 1, 200),
                      builder: (context, snapshotZone) {
                        if (snapshotZone.connectionState == ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0, bottom: 2),
                                child: RichText(
                                  text: TextSpan(
                                    text:"Zone", // Main text
                                    style: AllPopupHeadings.customTextStyle(context), // Main style
                                    children: [
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: AppSize.s30,
                                width: AppSize.s200,
                                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4, right: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorManager.containerBorderGrey,
                                      ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          zoneNameVal?? 'Select Zone',
                                          style: TextStyle(
                                            fontWeight:FontWeight.w600,
                                            fontSize:  FontSize.s13,
                                            color: ColorManager.mediumgrey,
                                            decoration: TextDecoration.none,
                                          ) //DocumentTypeDataStyle.customTextStyle(context),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_sharp, color:Colors.grey),
                                  ],
                                ),
                              ),
                            ],
                          );
                          //   Container(
                          //   width:  AppSize.s200,
                          //   height: 30,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color: ColorManager.containerBorderGrey, width: AppSize.s1),
                          //     borderRadius: BorderRadius.circular(5),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       SizedBox(width: AppSize.s10),
                          //       Expanded(
                          //         child: Text(
                          //           zoneNameVal ??  "Select County",
                          //           style: DocumentTypeDataStyle.customTextStyle(context),
                          //         ),
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                          //         child: Icon(Icons.arrow_drop_down),
                          //       ),
                          //     ],
                          //   ),
                          // );
                        }
                        if (snapshotZone.data!.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0, bottom: 2),
                                child: RichText(
                                  text: TextSpan(
                                    text:"Zone", // Main text
                                    style: AllPopupHeadings.customTextStyle(context), // Main style
                                    children: [
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: AppSize.s30,
                                width: AppSize.s200,
                                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorManager.containerBorderGrey,),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 1,vertical: 3),
                                        child: Text(
                                            ErrorMessageString.noZoneAdded,
                                            style: TextStyle(
                                              fontWeight:FontWeight.w600,
                                              fontSize:  FontSize.s13,
                                              color: ColorManager.mediumgrey,
                                              decoration: TextDecoration.none,
                                            ) //DocumentTypeDataStyle.customTextStyle(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                          //   Container(
                          //   height: AppSize.s30,
                          //   width: AppSize.s200,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color: ColorManager.containerBorderGrey,
                          //         width: AppSize.s1),
                          //     borderRadius: BorderRadius.circular(4),
                          //   ),
                          //   child: Align(
                          //     alignment: Alignment.centerLeft,
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(horizontal: 10),
                          //       child: Text(
                          //         ErrorMessageString
                          //             .noZoneAdded,
                          //         style: DocumentTypeDataStyle.customTextStyle(context),
                          //       ),
                          //     ),
                          //   ),
                          // );
                        }
                        if (snapshotZone.hasData) {
                          List<DropdownMenuItem<String>> dropDownTypesList = [];
                          for (var i in snapshotZone.data!) {
                            dropDownTypesList.add(
                              DropdownMenuItem<String>(
                                value: i.zoneName,
                                child: Text(i.zoneName),
                              ),
                            );
                          }
                          //zoneSortId = snapshotZone.data![0].zoneId;
                          zonenameController.text = zoneNameVal;
                          return CustomZoneFilterDropdownTextField(
                            width: AppSize.s200,
                            height: AppSize.s30,
                            headText: 'Zone',
                            initialValue: zoneNameVal,
                            dropDownMenuList: dropDownTypesList,
                            onChanged: (val) {
                              setState(() {
                                zoneNameVal = val!;
                                var selectedCounty = snapshotZone.data!.firstWhere((a) => a.zoneName == val);
                                zoneSortId = selectedCounty.zoneId;
                                zonenameController.text = selectedCounty.zoneName;
                                //isAddButtonEnabled = true;
                                _selectButton(2);
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    )
                                    ],
                                  ),
                  ),
             _selectedIndex == 0
                 ? Offstage()
                 : _selectedIndex == 1
                 ? Expanded(
                  flex: 1,
                  child: Container())
                 : Expanded(
                     flex: 1,
                     child: Container()),
              ///tabbar
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EMTabbar(onTap: (int index){
                        _selectButton(0);
                      }, index: 0, grpIndex: _selectedIndex, heading: AppString.county,),
                      EMTabbar(onTap: (int index){
                        _selectButton(1);
                      }, index: 1, grpIndex: _selectedIndex, heading: AppString.zone,),
                      EMTabbar(onTap: (int index){
                        _selectButton(2);
                      }, index: 2, grpIndex: _selectedIndex, heading: AppString.zipCode,),
                    ],
                  ),
                ),
              ),

              Expanded(
                  flex: 2,
                  child: Container()),
              ///button
              _selectedIndex == 0
              ? CustomIconButtonConst(
              width: AppSize.s80,
              icon: Icons.add,
              text: AppStringEM.add,
              onPressed: () {
                countynameController.clear();
                countyController.clear();
                stateController.clear();
                showDialog(
                    context: context,
                    builder: (context) {
                      return CIZoneAddPopup(
                        buttonTitle: AppStringEM.save,
                        title: 'Add County',
                        onSavePressed: () async {
                          await addCounty(
                              context,
                              countynameController.text,
                              widget.stateName,
                              widget.countryName,
                              "37.0902°",
                              "95.7129°",
                              widget.officeId);
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddSuccessPopup(
                                message: 'County Added Successfully',
                              );
                            },
                          );
                        },
                        title1: 'County Name',
                        countynameController: countynameController,
                        // title2: 'Country Name',
                        // zipcodeController: countyController,
                        // title3: 'County Name',
                        // mapController: countynameController,
                      );
                    });
              })
              : _selectedIndex == 1
              ? CustomIconButtonConst(
                width: AppSize.s80,
                icon: Icons.add,
                text: AppStringEM.add,
              onPressed: isAddButtonEnabled
                  ? () {
                //selectedExpiryType = expiryType;
                zoneNumberController.clear();
                print('County Name ${countynameController.text}');
                print('County id ${countySortId}');
                showDialog(
                    context: context,
                    builder: (context) {
                      return AddZonePopup(
                        countyNameController: countynameController,
                        buttonTitle: AppStringEM.save,
                        zoneNumberController: zoneNumberController,
                        title: 'Add Zone',
                        onSavePressed: () async {
                          var response = await addZoneCountyData(
                              context,
                              zoneNumberController.text,
                              countySortId,
                              widget.officeId);
                          Navigator.pop(context);
                          if(response.statusCode == 200 || response.statusCode == 201){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddSuccessPopup(
                                  message: 'Zone Added Successfully',
                                );
                              },
                            );
                          }
                        },
                        child: FutureBuilder<
                            List<AllCountyGetList>>(
                            future: getCountyZoneList(context),
                            builder: (context, snapshotZone) {
                              if (snapshotZone.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  width: 354,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorManager
                                            .containerBorderGrey,
                                        width: AppSize.s1),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "",
                                    //AppString.dataNotFound,
                                  ),
                                );
                              }
                              if (snapshotZone.data!.isEmpty) {
                                return Container(
                                  width: 354,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorManager
                                            .containerBorderGrey,
                                        width: AppSize.s1),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10),
                                      child: Text(
                                          ErrorMessageString
                                              .noCounties,
                                          //AppString.dataNotFound,
                                          style: DocumentTypeDataStyle.customTextStyle(context)
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (snapshotZone.hasData) {
                                List dropDown = [];
                                int docType = 0;
                                List<DropdownMenuItem<String>>
                                dropDownTypesList = [];
                                dropDownTypesList.add(
                                    const DropdownMenuItem<String>(
                                      child: Text('Select County'),
                                      value: 'Select County',
                                    ));
                                for (var i in snapshotZone.data!) {
                                  dropDownTypesList.add(
                                    DropdownMenuItem<String>(
                                      value: i.countyName,
                                      child: Text(i.countyName),
                                    ),
                                  );
                                }
                                if (selectedCounty == null) {
                                  selectedCounty = 'Select County';
                                }
                                print('County Id : ${countyId}');
                                return CICCDropdown(
                                    initialValue:
                                    dropDownTypesList[0].value,
                                    onChange: (val) {
                                      selectedCounty = val;
                                      for (var a
                                      in snapshotZone.data!) {
                                        if (a.countyName == val) {
                                          docType = a.countyId;
                                          print(
                                              "County id :: ${a.companyId}");
                                          countyId = docType;
                                        }
                                      }
                                      print(":::${docType}");
                                      print(":::<>${countyId}");
                                    },
                                    items: dropDownTypesList);
                              }
                              return const SizedBox();
                            }),
                      );
                    });
              }
                  : () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return VendorSelectNoti(message: "Select county first.",);
                  },
                );
              },
                            enabled: isAddButtonEnabled,)
              : CustomIconButtonConstzipcode(
                width: AppSize.s80,
                  icon: Icons.add,
                  text: AppStringEM.add,
              onPressed:  shouldShowAddButton
                  ? () {
                countynameController.clear();
                cityController.clear();
                zipcodeController.clear();
                showDialog(
                    context: context,
                    builder: (context) {
                      print(
                          "Location passed to dialog: $_location");
                      return AddZipCodePopup(
                        officeId: widget.officeId,
                        title: 'Add Zip Code',
                        countynameController: countynameController,
                        zipcodeController: zipcodeController,
                        onPickLocation: _pickLocation,
                        onSavePressed: () async {
                          setState(() {
                            String latlong = _selectedLocation.latitude.toString();
                          });
                        },
                        mapController: mapController,
                        locationController: locationController,
                        officeLat: widget.officeLat,
                        officeLong: widget.officeLon,
                        countyId: countyZipCodeSortId,
                        zoneId: zoneSortId,
                      );
                    });
              }
                  : null,
              ),

            ],
          ),
        ),
        const SizedBox(
          height: AppSize.s20,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 50),
            child: NonScrollablePageView(
              controller: _tabPageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                // Page 1
                CIZoneCountry(
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                ),
                CIZoneZone(
                  countyId: countySortId,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                ),
                CiZoneZipcode(
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  countySortId: countyZipCodeSortId,
                  zoneSortId: zoneSortId, onRefresh: () {  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}