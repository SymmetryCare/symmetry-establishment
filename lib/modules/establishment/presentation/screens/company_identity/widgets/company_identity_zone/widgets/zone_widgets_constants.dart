///zone widget const
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/pay_rates_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/company_identity_zone/widgets/location_screen.dart';
///add county
class CIZoneAddPopup extends StatefulWidget {
  final TextEditingController countynameController;
  final TextEditingController? zipcodeController;
  final TextEditingController? mapController;
  final TextEditingController? landmarkController;
  final TextEditingController? zoneController;
  final TextEditingController? cityController;
  final TextEditingController? countryController;
  final TextEditingController? stateController;
  final Future<void> Function() onSavePressed;
  final String buttonTitle;
  final String title1;
  final String? title2;
  final String? title3;
  final String? title4;
  final String? title5;
  final String? title6;
  final String title;

  const CIZoneAddPopup({
    Key? key,
    required this.onSavePressed,
    required this.title1,
    this.title2,
    this.title3,
    this.title4,
    this.title5,
    this.title6,
    required this.countynameController,
    this.zipcodeController,
    this.mapController,
    this.landmarkController,
    this.zoneController,
    this.cityController,
    this.countryController,
    this.stateController,
    required this.title,
    required this.buttonTitle,
  }) : super(key: key);

  @override
  State<CIZoneAddPopup> createState() => _CIZoneAddPopupState();
}

class _CIZoneAddPopupState extends State<CIZoneAddPopup> {
  bool isLoading = false;
  String? countyNameError;
  String? zipcodeError;
  String? mapError;
  String? landmarkError;
  bool validateFields() {
    bool isValid = true;

    setState(() {
      countyNameError = widget.countynameController.text.isEmpty
          ? 'County Field Cannot Be Empty'
          : null;
      isValid = countyNameError == null;
    });
    return isValid;
  }
  @override
  void initState() {
    super.initState();
    widget.countynameController.addListener(() {
      if (widget.countynameController.text.isNotEmpty && countyNameError != null) {
        setState(() {
          countyNameError = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      title: widget.title,
      width: AppSize.s407,
      height: AppSize.s260,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: widget.countynameController,
                keyboardType: TextInputType.text,
                text: widget.title1,
              ),
              countyNameError != null ?
              Text(
                countyNameError!,
                textAlign: TextAlign.start,
                style: CommonErrorMsg.customTextStyle(context),
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s10),
              if (widget.title2 != null) ...[
                SMTextfieldAsteric(
                  inputFormated: [UpperCaseTextFormatter()],
                  controller: widget.zipcodeController!,
                  keyboardType: TextInputType.text,
                  text: widget.title2!,
                ),
                if (zipcodeError != null)
                  Text(
                    zipcodeError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
              ],
              if (widget.title3 != null) ...[
                SizedBox(height: AppSize.s20),
                SMTextfieldAsteric(
                  controller: widget.mapController!,
                  keyboardType: TextInputType.text,
                  text: widget.title3!,
                ),
                if (mapError != null)
                  Text(
                    mapError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
              ],
            ],
          ),
        ),
      ],
      bottomButtons:  isLoading
          ? SizedBox(
          width: AppSize.s30,
          height: AppSize.s30,
          child: CircularProgressIndicator(
            color: ColorManager.blueprime,
          ))
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: widget.buttonTitle,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            await widget.onSavePressed();
            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }
}

///add zipcode
class AddZipCodePopup extends StatefulWidget {
  final int countyId;
  final int zoneId;
  final String title;
  final String officeId;
  final double officeLat;
  final double officeLong;
  final TextEditingController countynameController;
  final TextEditingController zipcodeController;
  final TextEditingController mapController;
  // final TextEditingController cityNameController;
  // final TextEditingController landmarkController;
  final Widget? locationText;
  final TextEditingController? locationController;
  final Future<void> Function() onSavePressed;
  final VoidCallback? onPickLocation;
  AddZipCodePopup({
    super.key,
    required this.title,
    required this.countynameController,
    required this.zipcodeController,
    required this.mapController,
    // this.landmarkController,
    required this.onSavePressed,
    // this.cityNameController,
    this.onPickLocation,
    this.locationText,
    this.locationController, required this.officeId, required this.officeLat, required this.officeLong, required this.countyId, required this.zoneId,
  });

  @override
  State<AddZipCodePopup> createState() => _AddZipCodePopupState();
}

class _AddZipCodePopupState extends State<AddZipCodePopup> {
  bool isLoading = false;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default location
  String _location = 'Select Lat/Long'; // Default text
  double? _latitude;
  double? _longitude;
  String? selectedCounty;
  String selectedZipCodeCounty = 'Select County';
  String selectedZipCodeZone ="Select Zone";
  int docZoneId = 0;
  int countyId = 0;
  int countySortId = 0;
  // String? locationError;
  String? countyError;
  String? zoneError;

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

              // Format Lat/Long
              String formatLatLong(double? latitude, double? longitude) {
                if (latitude != null && longitude != null) {
                  return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
                } else {
                  return 'Lat/Long not selected';
                }
              }

              final latlong = formatLatLong(_latitude, _longitude);
              _updateLocation(latlong);

              // Hide locationError as soon as a valid location is picked
              // locationError = null;
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

        // Ensure error message is hidden if a valid location is selected
        // locationError = null;
      });
    }
  }

  void _updateLocation(String latlong) {
    setState(() {
      _location = latlong;
    });
  }

  String? zipcodeError;

  bool validateFields() {
    bool isValid = true;

    // Validate Zip Code field
    setState(() {
      var val = zipCodes;
      if (val.isEmpty) {
        zipcodeError = 'Zip Code Field Cannot Be Empty';
        isValid = false;
      } else {
        zipcodeError = null;
        //isValid = false;
      }



      // locationError = (_latitude == null || _longitude == null)
      //     ? 'Please select location'
      //     : null;
      // if (locationError != null) {
      //   isValid = false;
      // }

      // countyError = (selectedZipCodeCounty == 'Select County')
      //     ? 'Please select a county'
      //     : null;
      // if (countyError != null) {
      //   isValid = false;
      // }

      // zoneError = (selectedZipCodeZone == 'Select Zone')
      //     ? 'Please select a zone'
      //     : null;
      // if (zoneError != null) {
      //   isValid = false;
      // }
    });

    return isValid;
  }
  @override
  void initState() {
    // TODO: implement initState
    _selectedLocation = LatLng(widget.officeLat, widget.officeLong);
    print('default office lat long ${_selectedLocation}');
    super.initState();
  }
  List<String> zipCodes = [];
  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s600,
      height: AppSize.s374,
      title: widget.title,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p10,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: AppPadding.p15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: AppStringEM.zipCode, // Main text
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
                  SizedBox(height: 10),
                  Container(
                   constraints: BoxConstraints(minHeight: 70, maxHeight: 110),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                           // Only allow digits  LengthLimitingTextInputFormatter(9), // Limit to 9 digits],
                            style: TableSubHeading.customTextStyle(context),
                            keyboardType: TextInputType.number,
                            controller: widget.zipcodeController,
                            decoration: InputDecoration.collapsed(hintText: "Enter zip and press space"),
                            onChanged: (value) {
                              if (value.endsWith(" ")) {
                                final zip = value.trim();
                                if (zip.isNotEmpty && !zipCodes.contains(zip)) {
                                  setState(() {
                                    zipCodes.add(zip);
                                  });
                                }
                                widget.zipcodeController.clear();
                                validateFields();
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                              LengthLimitingTextInputFormatter(10)],
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: zipCodes.map((zip) {
                                return  Chip(
                                  label:  Text(
                                    zip,
                                    style: TextStyle(
                                        fontSize: AppSize.s12,
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: ColorManager.blueprime,
                                  deleteIcon: Icon(Icons.close, color: Colors.white, size: AppSize.s14),
                                  onDeleted: () {
                                    setState(() {
                                      zipCodes.remove(zip);
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                                // return Container(
                                //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //   decoration: BoxDecoration(
                                //     color: ColorManager.blueprime,
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                //   child: Row(
                                //     spacing: 5,
                                //     children: [
                                //       Text(
                                //         zip,
                                //         style: TextStyle(
                                //           fontSize: AppSize.s12,
                                //             color: Colors.white, fontWeight: FontWeight.bold),
                                //       ),
                                //       Icon(Icons.close,size: AppSize.s12,color: Colors.white,)
                                //     ],
                                //   ),
                                // );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  zipcodeError != null ?
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      zipcodeError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ),
                  ) : SizedBox(height: AppSize.s12,),
                  SizedBox(height: AppSize.s15),
                  // Location Picker Section
                 Opacity(
                   opacity:zipCodes.length > 1 ? 0.2 :  0.9,
                   child: Container(
                     child: IgnorePointer(
                       ignoring: zipCodes.length > 1 ,
                       child: Row(
                          children: [
                            TextButton(
                              onPressed: _pickLocation,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                'Pick Location',
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.bluelight,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on_outlined,
                              color: ColorManager.granitegray,
                              size: AppSize.s18,
                            ),
                            SizedBox(width: AppSize.s10),
                            Padding(
                              padding: const EdgeInsets.only(left: AppPadding.p10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _location,
                                    style: AllNoDataAvailable.customTextStyle(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                     ),
                   ),
                 ),
                  // locationError != null ?
                  // Text(
                  //   locationError!,
                  //   style: CommonErrorMsg.customTextStyle(context),
                  // ) : SizedBox(height: AppSize.s12,),
                ],
              ),
            ),
          ),
        ),
      ],
      bottomButtons: isLoading
          ? SizedBox(
        height: AppSize.s30,
        width: AppSize.s30,
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            var response = await addZipCodeSetup(
              context,
              widget.zoneId,
              widget.countyId,
              widget.officeId,
              "",
              zipCodes,
              _selectedLocation.latitude.toString(),
              _selectedLocation.longitude.toString(),
              "",
            );

            if(response.statusCode == 200 || response.statusCode == 201){
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSuccessPopup(
                    message: 'Save Successfully',
                  );
                },
              );
            }else if(response.statusCode == 400 || response.statusCode == 404){
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => const FourNotFourPopup(),
              );
            }
            else {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => FailedPopup(text: response.message),
              );
            }

            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }
}

///edit
class EditZipCodePopup extends StatefulWidget {
  final String title;
  // final TextEditingController? countynameController;
  final TextEditingController zipcodeController;
  final TextEditingController? mapController;
  // final TextEditingController? cityNameController;
  // final TextEditingController? landmarkController;
  final String officeId;
  final int zoneId;
  final int countyId;
  final int zipCodeSetupId;
  final String zipCodes;
  final String latitude;
  final String longitude;
  final String zoneName;
  final String countyName;
  final String lat;
  final String long;
  final Future<void> Function() onSavePressed;
  EditZipCodePopup({
    super.key,
    required this.title,
    // this.countynameController,
    required this.zipcodeController,
    this.mapController,
    // this.landmarkController,
    required this.onSavePressed,
    // this.cityNameController,
    required this.latitude, required this.longitude, required this.zoneId, required this.countyId,
    required this.zipCodes, required this.zipCodeSetupId,
    required this.officeId, required this.zoneName, required this.countyName, required this.lat, required this.long,
  });

  @override
  State<EditZipCodePopup> createState() => _EditZipCodePopupState();
}

class _EditZipCodePopupState extends State<EditZipCodePopup> {
  bool isLoading = false;
  String? fetchedLatitude;
  String? fetchedLng;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default location
  String _location = "Lat 37.7749 lng -122.4194"; // Default text
  double? _latitude;
  double? _longitude;
  int docZoneId =0;
  int countyId =0;
  String zoneNameText = '';
  String countyNameText= '';
  final StreamController<List<AllCountyZoneGet>> _zoneController =
  StreamController<List<AllCountyZoneGet>>.broadcast();
  // late Future<List<SortByZoneData>> _zoneFuture;

  @override
  void initState() {
    // TODO: implement initState
    fetchedLatitude = widget.latitude;
    fetchedLng = widget.longitude;
    docZoneId = widget.zoneId;
    countyId = widget.countyId;
    zoneNameText = widget.zoneName;
    countyNameText = widget.countyName;
    _location = "Lat ${widget.lat} lng ${widget.long}";
    super.initState();
    // _zoneFuture = getZoneByCounty(context, widget.officeId, countyId, 1, 200);
    //ZoneZipcodeDropdown(widget.officeId, context); // Initialize Future once

  }
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
      print("Updated Location: $_location"); // Check this log to see if the value updates
    });
  }
  String? zipcodeError;
  bool validateFields() {
    bool isValid = true;

    setState(() {
      zipcodeError =widget.zipcodeController.text.isEmpty
          ? 'Zip Code Field Cannot Be Empty'
          : null;

      isValid = zipcodeError == null;

    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(

      title: widget.title,
      width: AppSize.s400,
      height: AppSize.s300,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            //vertical: AppPadding.p1,
            horizontal: AppPadding.p14,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              //     RichText(
              //       text: TextSpan(
              //         text: AppStringEM.countyName, // Main text
              //         style: AllPopupHeadings.customTextStyle(context), // Main style
              //         children: [
              //           TextSpan(
              //             text: ' *', // Asterisk
              //             style: AllPopupHeadings.customTextStyle(context).copyWith(
              //               color: ColorManager.red, // Asterisk color
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     SizedBox(height: AppSize.s5),
              //     FutureBuilder<List<OfficeWiseCountyData>>(
              //         future: getCountyListOfficeIdWise(context:context,OfficeId: widget.officeId),
              //         builder: (context,snapshotZone) {
              //           if(snapshotZone.connectionState == ConnectionState.waiting){
              //             return Container(
              //               height: AppSize.s30,
              //               width: AppSize.s354,
              //               decoration: BoxDecoration(
              //                 border: Border.all(
              //                     color: ColorManager.containerBorderGrey, width: AppSize.s1),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child:  Row(
              //                 children: [
              //                   SizedBox(width: AppSize.s10),
              //                   Expanded(
              //                     child: Text(
              //                       countyNameText ?? '',
              //                       style:  DocumentTypeDataStyle.customTextStyle(context),
              //                     ),
              //                   ),
              //                   Padding(
              //                     padding: const EdgeInsets.only(right: AppPadding.p8),
              //                     child: Icon(Icons.arrow_drop_down),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           }
              //           if (snapshotZone.data!.isEmpty) {
              //             return Container(
              //               height: AppSize.s30,
              //               width: AppSize.s354,
              //               decoration: BoxDecoration(
              //                 border: Border.all(
              //                     color: ColorManager.containerBorderGrey, width: AppSize.s1),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Align(
              //                 alignment: Alignment.centerLeft,
              //                 child: Padding(
              //                   padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
              //                   child: Text(
              //                       ErrorMessageString.noCountyAdded,
              //                       // AppString.dataNotFound,
              //                       style: AllNoDataAvailable.customTextStyle(context)
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }
              //           if(snapshotZone.hasData){
              //             List dropDown = [];
              //             int docType = 0;
              //             List<DropdownMenuItem<String>> dropDownTypesList = [];
              //             for(var i in snapshotZone.data!){
              //               dropDownTypesList.add(
              //                 DropdownMenuItem<String>(
              //                   value: i.countyName,
              //                   child: Text(i.countyName),
              //                 ),
              //               );
              //             }
              //             // if (countyName == null) {
              //             //   countyName = 'Select County';
              //             // }
              //             return CICCDropdown(
              //                 borderRadius: 8,
              //                 initialValue: countyNameText,
              //                 onChange: (val){
              //                   for(var a in snapshotZone.data!){
              //                     if(a.countyName == val){
              //                       countyNameText = val;
              //                       docType = a.countyId;
              //                       print("County id :: ${a.companyId}");
              //                       countyId = docType;
              //                     }
              //                   }
              //                   print(":::${docType}");
              //                   print(":::<>${countyId}");
              //                 },
              //                 items:dropDownTypesList
              //             );
              //           }
              //           return const SizedBox();
              //         }
              //     ),
              //   ],
              // ),
              // SizedBox(height: AppSize.s10),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     RichText(
              //       text: TextSpan(
              //         text:AppString.zone, // Main text
              //         style: AllPopupHeadings.customTextStyle(context), // Main style
              //         children: [
              //           TextSpan(
              //             text: ' *', // Asterisk
              //             style: AllPopupHeadings.customTextStyle(context).copyWith(
              //               color: ColorManager.red, // Asterisk color
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     SizedBox(height: AppSize.s5),
              //     // FutureBuilder<List<SortByZoneData>>(
              //     FutureBuilder<List<AllCountyZoneGet>>(
              //         future: getZoneByCounty(context, widget.officeId, countyId, 1, 200),
              //         builder: (context,snapshotZone) {
              //           getZoneByCounty(
              //               context,
              //               widget.officeId,
              //               countyId,
              //               1,
              //               200)
              //               .then((data) {
              //             _zoneController.add(data);
              //           }).catchError((error) {});
              //           if(snapshotZone.connectionState == ConnectionState.waiting){
              //             return Container(
              //               height: AppSize.s30,
              //               width: AppSize.s354,
              //               decoration: BoxDecoration(
              //                 border: Border.all(
              //                     color: ColorManager.containerBorderGrey, width: AppSize.s1),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Align(
              //                 alignment: Alignment.centerLeft,
              //                 child: Padding(
              //                   padding: const EdgeInsets.symmetric(horizontal: 10),
              //                   child: Text(
              //                       zoneNameText,
              //                       //  AppString.dataNotFound,
              //                       style: AllNoDataAvailable.customTextStyle(context)
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }
              //           if (snapshotZone.data!.isEmpty) {
              //             return Container(
              //               height: AppSize.s30,
              //               width: AppSize.s354,
              //               decoration: BoxDecoration(
              //                 border: Border.all(
              //                     color: ColorManager.containerBorderGrey, width: AppSize.s1),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Align(
              //                 alignment: Alignment.centerLeft,
              //                 child: Padding(
              //                   padding: const EdgeInsets.symmetric(horizontal: 10),
              //                   child: Text(
              //                       ErrorMessageString.noZoneAdded,
              //                       //  AppString.dataNotFound,
              //                       style: AllNoDataAvailable.customTextStyle(context)
              //                   ),
              //                 ),
              //               ),
              //             );
              //           }
              //           if (snapshotZone.hasData) {
              //             int docType = 0;
              //             List<DropdownMenuItem<String>> dropDownTypesList = [];
              //
              //             // Populate dropdown list from API response
              //             for (var i in snapshotZone.data!) {
              //               dropDownTypesList.add(
              //                 DropdownMenuItem<String>(
              //                   value: i.zoneName,
              //                   child: Text(i.zoneName),
              //                 ),
              //               );
              //             }
              //
              //             return CICCDropdown(
              //               borderRadius: 8,
              //               initialValue: zoneNameText,//dropDownTypesList.isNotEmpty ? dropDownTypesList[0].value : null,
              //               onChange: (val) {
              //                 for (var a in snapshotZone.data!) {
              //                   if (a.zoneName == val) {
              //                     zoneNameText = val;
              //                     docType = a.zoneId;
              //                     docZoneId = docType;
              //                     print("ZONE id :: ${a.zoneId}");
              //                   }
              //                 }
              //                 print(":::${docType}");
              //                 print(":::<>${docZoneId}");
              //               },
              //               items: dropDownTypesList,
              //             );
              //           }
              //
              //           // if(snapshotZone.hasData){
              //           //   List dropDown = [];
              //           //   int docType = 0;
              //           //   List<DropdownMenuItem<String>> dropDownTypesList = [];
              //           //   if(widget.zoneName == zoneNameText){
              //           //     dropDownTypesList.add(
              //           //         DropdownMenuItem<String>(
              //           //           child: Text(zoneNameText),
              //           //           value: zoneNameText,
              //           //         ));
              //           //   }
              //           //   for(var i in snapshotZone.data!){
              //           //     dropDownTypesList.add(
              //           //       DropdownMenuItem<String>(
              //           //         value: i.zoneName,
              //           //         child: Text(i.zoneName),
              //           //       ),
              //           //     );
              //           //   }
              //           //   return CICCDropdown(
              //           //     borderRadius: 8,
              //           //       initialValue: dropDownTypesList[0].value,
              //           //       onChange: (val){
              //           //         for(var a in snapshotZone.data!){
              //           //           if(a.zoneName == val){
              //           //             zoneNameText = val;
              //           //             docType = a.zoneId;
              //           //             print("ZONE id :: ${a.zoneId}");
              //           //             docZoneId = docType;
              //           //           }
              //           //         }
              //           //         print(":::${docType}");
              //           //         print(":::<>${docZoneId}");
              //           //       },
              //           //       items:dropDownTypesList
              //           //   );
              //           // }
              //           return const SizedBox();
              //         }
              //     ),
              //   ],
              // ),

              // SizedBox(height: AppSize.s15),
              SMTextfieldAsteric(
                controller: widget.zipcodeController,
                keyboardType: TextInputType.text,
                text: AppStringEM.zipCode,
              ),
              zipcodeError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    zipcodeError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                ],
              ) : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s15),
              Row(
                children: [
                  TextButton(
                    onPressed: _pickLocation,
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent),
                    child: Text(
                      'Pick Location',
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.bluelight,
                        //decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on_outlined,
                    color: ColorManager.granitegray,
                    size: AppSize.s18,
                  ),
                  SizedBox(width: AppSize.s5,),
                  Text(
                      _location,
                      style: AllNoDataAvailable.customTextStyle(context)
                  ),
                ],
              ),
              SizedBox(height: AppSize.s15),

            ],
          ),
          ],
        ),
    ),
      ],

      bottomButtons:  isLoading
          ? SizedBox(
          width: AppSize.s30,
          height: AppSize.s30,
          child: CircularProgressIndicator(
            color: ColorManager.blueprime,
          ))
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            var response = await updateZipCodeSetup(
                context,
                widget.zipCodeSetupId,
                widget.zoneId,
                widget.countyId,
                widget.officeId,
                "",
                widget.zipCodes == widget.zipcodeController.text ? widget.zipCodes
                    .toString() : widget.zipcodeController.text,
                _selectedLocation.latitude.toString(),
                _selectedLocation.longitude.toString(),
                // "37.0902°",
                // "95.7129°",
                "");

            if(response.statusCode == 200 || response.statusCode == 201){
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSuccessPopup(
                    message: 'Zipcode Edited Successfully',
                  );
                },
              );
            }else if(response.statusCode == 400 || response.statusCode == 404){
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => const FourNotFourPopup(),
              );
            }
            else {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => FailedPopup(text: response.message),
              );
            }
            setState(() {
              isLoading = false;
            });
          }
        },
      ),

    );
  }
}


///zone
class AddZonePopup extends StatefulWidget {
  final TextEditingController zoneNumberController;
  final TextEditingController countyNameController;
  final Future<void> Function() onSavePressed;
  final Widget? child;
  final String title;
  final String buttonTitle;
  AddZonePopup(
      {super.key,
        required this.zoneNumberController,
        this.child,
        required this.title,
        required this.onSavePressed,
        required this.buttonTitle,
        required this.countyNameController});

  @override
  State<AddZonePopup> createState() => _AddZonePopupState();
}

class _AddZonePopupState extends State<AddZonePopup> {
  bool isLoading = false;

  // Variables to hold error messages
  String? zoneNumberError;
  String? countyError;

  // Method to validate the input fields
  bool validateFields() {
    bool isValid = true;

    setState(() {
      // Validate zone number field
      zoneNumberError = widget.zoneNumberController.text.isEmpty
          ? 'Zone Name cannot be empty'
          : null;

      // Validate dropdown (assuming 'Select County' is the default unselected value)
      countyError = widget.child.toString() == 'Select County'
          ? 'Please select a county'
          : null;

      // If any error message is not null, the form is invalid
      isValid = zoneNumberError == null && countyError == null;
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      title: widget.title,
      width: AppSize.s400,
      height: AppSize.s330,
      body: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: widget.zoneNumberController,
                keyboardType: TextInputType.text,
                text: AppStringEM.zoneName,
                onChanged: (value){
                  setState(() {
                    bool isValid = true;
                    zoneNumberError = widget.zoneNumberController.text.isEmpty
                        ? 'Zone Name cannot be empty'
                        : null;
                  });
                },
              ),
              zoneNumberError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      zoneNumberError!,
                      style:CommonErrorMsg.customTextStyle(context)
                  ),
                ],
              )  : SizedBox(height: AppSize.s12,),
              SizedBox(height: AppSize.s10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SMTextfieldAsteric(
                    enable: false,
                    controller: widget.countyNameController,
                    keyboardType: TextInputType.text,
                    text: AppString.county,
                  ),
                  if (countyError != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            countyError!,
                            style: CommonErrorMsg.customTextStyle(context)
                        ),
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
          ))
          : CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: widget.buttonTitle,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            await widget.onSavePressed();
            setState(() {
              isLoading = false;
            });
          }
        },
      ),

    );
  }
}