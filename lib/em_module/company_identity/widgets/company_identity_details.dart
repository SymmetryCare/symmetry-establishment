import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:prohealth/data/api_data/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import '../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../app/resources/hr_resources/hr_theme_manager.dart';
import '../../../../widgets/error_popups/delete_success_popup.dart';
import '../../widgets/button_constant.dart';

class CIDetailsScreen extends StatefulWidget {
  CIDetailsScreen({
        super.key,
        required this.officeId,
        required this.docTD,
        required this.companyId,
        required int companyID,
        required this.companyOfficeid,
        required this.stateName,
        required this.countryName,
        required this.updateOfficeName
      });
  final String stateName;
  final String countryName;
  final int companyId;
  final int docTD;
  final int companyOfficeid;
  final String officeId;
  final Function(String) updateOfficeName;

  @override
  State<CIDetailsScreen> createState() => _CIDetailsScreenState();
}

class _CIDetailsScreenState extends State<CIDetailsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController secNumberController = TextEditingController();
  TextEditingController primNumController = TextEditingController();
  TextEditingController altNumController = TextEditingController();
  TextEditingController primeFaxController = TextEditingController();
  TextEditingController secFaxController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hcoNumController = TextEditingController();
  TextEditingController hcoNumControllerPrefill = TextEditingController();
  TextEditingController medicareController = TextEditingController();
  TextEditingController npiNumController = TextEditingController();
  TextEditingController stateNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();
  late final Future<ManageDetails> _companyDetailsFuture;
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;

  String latitude = '';
  String longitude = '';
  bool isChecked = false;
  Future<void> updateServices(
      int officeServiceId,
      String officeId,
      String serviceName,
      String serviceId,
      String npiNum,
      String medicareNum,
      String hcoNumber) async {
    await patchCompanyOfficeService(context, officeServiceId, officeId,
        serviceName, serviceId, npiNum, medicareNum, hcoNumber);
    setState(() {
      companyDetailGetAll(context, widget.officeId);
    });
  }

  Future<void> deleteService(int officeServiceId) async {
    await deleteCompanyOfficeService(context, officeServiceId);
    setState(() {
      companyDetailGetAll(context, widget.officeId);
    });
  }
  bool _isLoading = false;
  bool showHcoError = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<ManageDetails?>(
        future: companyDetailGetAll(context, widget.officeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: CircularProgressIndicator(
                  color: ColorManager.blueprime,
                ),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            nameController.text = snapshot.data!.officeName;
            primNumController.text = snapshot.data!.priNumber;
            secNumberController.text = snapshot.data!.secNumber;
            altNumController.text = snapshot.data!.alternateNumber;
            addressController.text = snapshot.data!.address;
            emailController.text = snapshot.data!.email;
            primeFaxController.text = snapshot.data!.primaryFax;
            secFaxController.text = snapshot.data!.secondaryFax;
            stateNameController.text = snapshot.data!.stateName;
            countryNameController.text = snapshot.data!.countryName;
            latitude = snapshot.data!.lat;
            longitude = snapshot.data!.long;

            List<Widget> serviceRows = [];
            print('Fetched lat lng ${latitude} + ${longitude}');

            for (int i = 0; i < snapshot.data!.serviceDetails!.length; i += 2) {
              List<Widget> rowChildren = [];

              for (int j = 0; j < 2; j++) {
                if (i + j < snapshot.data!.serviceDetails!.length) {
                  var serviceDetail = snapshot.data!.serviceDetails![i + j];
                  npiNumController.text = serviceDetail.npiNum;
                  hcoNumController.text = serviceDetail.hcoNum;
                  medicareController.text = serviceDetail.medicareNum;
                  List<String> dropdownItems = [
                    serviceDetail.serviceName,
                    'HCO Number: ${serviceDetail.hcoNum}',
                    'Medicare ID: ${serviceDetail.medicareNum}',
                    'NPI Number: ${serviceDetail.npiNum}',
                  ];

                  rowChildren.add(
                    Padding(
                      padding: const EdgeInsets.only( bottom: AppPadding.p12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: AppSize.s170,
                            width: AppSize.s550,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: ColorManager.white),
                            child: Column(
                              children: [
                                Container(
                                  height: AppSize.s40,
                                  width: AppSize.s550,
                                  decoration: BoxDecoration(
                                    color: ColorManager.blueprime,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                        setState) {

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: AppPadding.p20),
                                            child: Text(serviceDetail.serviceName,style: PopupBlueBarText.customTextStyle(context),),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                splashColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                      context) {
                                                        return FutureBuilder<ServicePreFillData>(
                                                            future:getAllServicesPrefillData(context: context, officeServiceId: serviceDetail.officeServiceId,),
                                                            builder: (context, snapshot) {
                                                              if(snapshot.connectionState == ConnectionState.waiting){
                                                                return Center(child: CircularProgressIndicator(color: ColorManager.blueprime,),);
                                                              }
                                                              var hcoNumber = snapshot.data!.hcoNumber;
                                                              hcoNumControllerPrefill = TextEditingController(text: snapshot.data!.hcoNumber);
                                                              return StatefulBuilder(
                                                                builder: (BuildContext context, void Function(void Function()) setState) {
                                                                  // bool showHcoError = false;
                                                                  return DialogueTemplate(
                                                                    width: AppSize.s420,
                                                                    height: AppSize.s250,
                                                                    body: [
                                                                      SMTextfieldAsteric(
                                                                        controller:
                                                                        hcoNumControllerPrefill,
                                                                        keyboardType:
                                                                        TextInputType.text,
                                                                        text: AppStringEM.hcoNum,
                                                                        onChanged: (value) {
                                                                          if (showHcoError && value.trim().isNotEmpty) {
                                                                            setState(() {
                                                                              showHcoError = false; // ✅ hide error as user types
                                                                            });
                                                                          }
                                                                        },
                                                                      ),

                                                                      showHcoError
                                                                          ? Padding(
                                                                        padding: const EdgeInsets.only(top: 4.0, left: 12),
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              'HCO Number cannot be empty',
                                                                              style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontSize: 10,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                          : SizedBox(height: 14),
                                                                    ],
                                                                    bottomButtons: CustomElevatedButton(
                                                                        width: AppSize.s105,
                                                                        height: AppSize.s30,
                                                                        text: AppStringEM.save, //submit
                                                                        onPressed: () async {

                                                                          if (hcoNumControllerPrefill.text.isEmpty) {
                                                                            setState(() {
                                                                              showHcoError = true;
                                                                            });
                                                                            return;
                                                                          }

                                                                          await updateServices(
                                                                              serviceDetail.officeServiceId,
                                                                              widget.officeId,
                                                                              serviceDetail.serviceName,
                                                                              serviceDetail.serviceId,
                                                                              serviceDetail.npiNum,
                                                                              serviceDetail.medicareNum,
                                                                              hcoNumber == hcoNumControllerPrefill
                                                                                  .text ? hcoNumber : hcoNumControllerPrefill.text);
                                                                          hcoNumControllerPrefill.clear();
                                                                          Navigator.pop(
                                                                              context);
                                                                          showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context) {
                                                                              return AddSuccessPopup(
                                                                                message: 'Service edited successfully.',
                                                                              );
                                                                            },
                                                                          );

                                                                        }),
                                                                    title: 'Edit Service',
                                                                  );
                                                                },

                                                              );
                                                            }
                                                        );
                                                      });
                                                },
                                                icon: Icon(
                                                    Icons.mode_edit_outline_outlined,
                                                    size: IconSize.I20,
                                                    color: Colors.white),
                                              ),
                                              // SizedBox(width:2),
                                              IconButton(
                                                splashColor:
                                                Colors.transparent,
                                                hoverColor:
                                                Colors.transparent,
                                                highlightColor:
                                                Colors.transparent,
                                                onPressed: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        StatefulBuilder(
                                                          builder: (BuildContext context, void Function(void Function()) setState) {
                                                            return DeletePopup(
                                                                title: DeletePopupString.deleteService,
                                                                loadingDuration: _isLoading,
                                                                onCancel: () {
                                                                  Navigator.pop(context);
                                                                }, onDelete:
                                                                () async {
                                                              setState(() {
                                                                _isLoading = true;
                                                              });
                                                              try {
                                                                await deleteService(serviceDetail.officeServiceId);
                                                                Navigator.pop(context);
                                                                showDialog(context: context, builder: (context) => DeleteSuccessPopup());
                                                              } finally {
                                                                setState(() {
                                                                  _isLoading = false;
                                                                });
                                                              }
                                                            });
                                                          },
                                                        ),
                                                  );
                                                },
                                                icon: Icon(
                                                    Icons.delete_outline_outlined,
                                                    size: IconSize.I20,
                                                    color: Colors.white),
                                              )
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.s10,
                                ),

                                /// HCO number
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p20),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'HCO Number :',
                                        style: AllPopupHeadings.customTextStyle(context),
                                      ),
                                      Text(
                                        "${hcoNumController.text}",
                                        style: AllPopupHeadings.customTextStyle(context),
                                      )
                                    ],
                                  ),
                                ),
                                // Divider
                                Padding(
                                  padding: const EdgeInsets.all(AppPadding.p5),
                                  child: Divider(
                                    color: ColorManager.faintGrey,
                                    thickness: 1,
                                  ),
                                ),

                                /// Medicare ID
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p20),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Medicare ID :',
                                        style: AllPopupHeadings.customTextStyle(context),
                                      ),
                                      Text(
                                        "${medicareController.text}",
                                        style:AllPopupHeadings.customTextStyle(context),
                                      )
                                    ],
                                  ),
                                ),
                                // Divider
                                Padding(
                                  padding: const EdgeInsets.all(AppPadding.p5),
                                  child: Divider(
                                    color: ColorManager.faintGrey,
                                    thickness: 0.5,
                                  ),
                                ),

                                /// NPI Number
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p20),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'NPI Number :',
                                        style: AllPopupHeadings.customTextStyle(context),
                                      ),
                                      Text(
                                        "${npiNumController.text}",
                                        style: AllPopupHeadings.customTextStyle(context),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              }
              serviceRows.add(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: rowChildren,
              ));
            }

            return Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 9,
                right: MediaQuery.of(context).size.width / 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: AppPadding.p25),
                    child: Row(
                      children: [
                        Text(
                          AppStringEM.details,
                          style: HeadingFormStyle.customTextStyle(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: AppSize.s367,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 2,
                        color: ColorManager.black.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                      color: ColorManager.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: AppPadding.p50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FirstSMTextFConst(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                text: AppStringEM.officename,
                              ),
                              const SizedBox(height: AppSize.s10),
                              SMTextFConstPhone(
                                controller: secNumberController,
                                keyboardType: TextInputType.number,
                                text: AppStringEM.secNum,
                              ),
                              const SizedBox(height: AppSize.s10),
                              FirstSMTextFConst(
                                controller: stateNameController,
                                keyboardType: TextInputType.text,
                                text: AppStringEM.stateName,
                              ),
                              const SizedBox(height: AppSize.s10),
                              AddressInput(
                                controller: addressController,
                                onSuggestionSelected: (selectedSuggestion) {
                                  // Handle the selected suggestion here
                                  print("Selected suggestion: $selectedSuggestion");
                                }, onChanged: (String ) {  },
                              ),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SMTextFConstPhone(
                              controller: primNumController,
                              keyboardType: TextInputType.number,
                              text: AppStringEM.primNum,
                            ),
                            const SizedBox(height: AppSize.s10),
                            SMTextFConstPhone(
                              controller: altNumController,
                              keyboardType: TextInputType.number,
                              text: AppStringEM.alternatephone,
                            ),
                            const SizedBox(height: AppSize.s10),
                            SMTextFConst(
                              controller: emailController,
                              keyboardType: TextInputType.text,
                              text: AppStringEM.primarymail,
                            ),
                            const SizedBox(height: AppSize.s10),
                            FirstSMTextFConst(
                              controller: countryNameController,
                              keyboardType: TextInputType.text,
                              text: AppStringEM.countryName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  /// Service List
                  if (snapshot.data!.serviceDetails != null && snapshot.data!.serviceDetails!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Services',
                            style: HeadingFormStyle.customTextStyle(context),
                          ),
                          const SizedBox(height: AppSize.s25),
                          Container(
                            //color: Colors.purple,
                            child: Column(
                              children: serviceRows,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSize.s10),

                  /// Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        width: AppSize.s105,
                        height: AppSize.s30,
                        text: AppStringEM.save,
                        onPressed: () async {
                          var response = await patchCompanyOffice(
                              context,
                              widget.companyOfficeid,
                              widget.officeId,
                              primNumController.text,
                              secNumberController.text,
                              primeFaxController.text,
                              secFaxController.text,
                              altNumController.text,
                              emailController.text,
                              nameController.text,
                              addressController.text,
                              latitude,
                              longitude,
                              "",
                              stateNameController.text,
                              countryNameController.text);

                          widget.updateOfficeName(nameController.text);
                          if(response.statusCode == 200 || response.statusCode == 201){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddSuccessPopup(
                                  message: 'Edited successfully.',
                                );
                              },
                            );
                          }else if(response.statusCode == 400 || response.statusCode == 404){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => const FourNotFourPopup(),
                            );
                          }
                          else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => FailedPopup(text: response.message),
                            );
                          }

                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  )
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}



///Address suggestion

class AddressInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSuggestionSelected;
  final Function(String) onChanged;// Callback to notify parent

  AddressInput({required this.controller, this.onSuggestionSelected, required this.onChanged});

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
                color: Colors.transparent, // Make this transparent so it's invisible
              ),
            ),Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height,
              width: AppSize.s354,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
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

                            // Call the callback with the selected suggestion
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
        SMTextFConst(
          controller: widget.controller,
          keyboardType: TextInputType.streetAddress,
          text:'Address',
        ),
      ],
    );
  }
}
