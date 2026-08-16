import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/establishment_resources/establish_theme_manager.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/zone_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/company_identity_zone/widgets/zone_widgets_constants.dart';
import 'package:prohealth/presentation/widgets/error_popups/failed_popup.dart';
import 'package:prohealth/presentation/widgets/error_popups/four_not_four_popup.dart';
import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../data/api_data/establishment_data/zone/zone_model_data.dart';
import '../../../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../whitelabelling/success_popup.dart';

class CIZoneCountry extends StatefulWidget {
  final int companyID;
  final String officeId;
  const CIZoneCountry({super.key, required this.companyID, required this.officeId});

  @override
  State<CIZoneCountry> createState() => _CIZoneCountryState();
}

class _CIZoneCountryState extends State<CIZoneCountry> {
  TextEditingController countynameController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mapController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  final StreamController<List<AllCountyGet>> _contyController = StreamController<List<AllCountyGet>>();

  @override
  void initState() {
    super.initState();
  }

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;
  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8, horizontal: AppPadding.p35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: AppSize.s30,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                          AppStringEM.srno,
                          style: TableHeading.customTextStyle(context)
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                          AppStringEM.name,
                          style: TableHeading.customTextStyle(context)
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                          AppStringEM.zones,
                          style: TableHeading.customTextStyle(context)
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                          AppStringEM.actions,
                          style: TableHeading.customTextStyle(context)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: AppSize.s10,
          ),
          Expanded(
            child:
            StreamBuilder<List<AllCountyGet>>(
              stream: _contyController.stream,
              builder: (context, snapshot) {
                getZoneBYcompOffice(context, widget.officeId, 1, 50).then((data) {
                  data.sort((a, b) => b.countyId.compareTo(a.countyId)); // Assuming countyId for sorting
                  _contyController.add(data);
                }).catchError((error) {});
                print('1111111');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      ErrorMessageString.noCounties,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  int totalItems = snapshot.data!.length;
                  int totalPages = (totalItems / itemsPerPage).ceil();
                  List<AllCountyGet> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: paginatedData.length,
                            itemBuilder: (context, index) {
                              int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                              String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                              AllCountyGet county = paginatedData[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: ColorManager.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ColorManager.black.withOpacity(0.25),
                                            spreadRadius: 0,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      height: AppSize.s56,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  formattedSerialNumber,
                                                  style:  TableSubHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            // Text(''),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  county.countyName.toString(),
                                                  textAlign:TextAlign.center,
                                                  style:  TableSubHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  county.zoneName.join(', '),
                                                  style:  TableSubHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      splashColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      onPressed: (){
                                                        showDialog(context: context, builder: (context){
                                                          return FutureBuilder<CountyPrefillGet>(
                                                              future: countyPrefillGet(context,county.countyId),
                                                              builder: (context,snapshotPrefill) {
                                                                if(snapshotPrefill.connectionState == ConnectionState.waiting){
                                                                  return Center(
                                                                    child: CircularProgressIndicator(color: ColorManager.blueprime,),
                                                                  );
                                                                }
                                                                var countyName = snapshotPrefill.data!.countyName;
                                                                countynameController = TextEditingController(text:snapshotPrefill.data!.countyName );

                                                                var stateName = snapshotPrefill.data!.state;
                                                                stateController = TextEditingController(text: snapshotPrefill.data!.state);

                                                                var countryName = snapshotPrefill.data!.country;
                                                                countyController = TextEditingController(text:snapshotPrefill.data!.country);

                                                                return CIZoneAddPopup(
                                                                  buttonTitle: AppStringEM.save,
                                                                  onSavePressed: ()async{
                                                                    var response = await updateCounty(context, county.countyId,
                                                                        countyName == countynameController.text ? countyName.toString() : countynameController.text,
                                                                        stateName.toString(),
                                                                        countryName.toString(),
                                                                        "37.0902°",
                                                                        "95.7129°", widget.companyID, widget.officeId);
                                                                    if(response.statusCode == 200 || response.statusCode == 201){
                                                                      Navigator.pop(context);
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) {
                                                                          return AddSuccessPopup(
                                                                            message: 'County Edited Successfully',
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
                                                                    getZoneBYcompOffice(context, widget.officeId, 1, 20).then((data){
                                                                      data.sort((a, b) => b.countyId.compareTo(a.countyId));
                                                                      _contyController.add(data);
                                                                    }).catchError((error){});

                                                                  },
                                                                  title: 'Edit County',
                                                                  title1: 'County Name',
                                                                  countynameController: countynameController,
                                                                );
                                                              }
                                                          );
                                                        });
                                                      }, icon: Icon(Icons.edit_outlined,
                                                      size:IconSize.I22,color: IconColorManager.bluebottom,),),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              );
                            }),
                      ),
                      // Pagination Controls
                      PaginationControlsWidget(
                        currentPage: currentPage,
                        items: snapshot.data!,
                        itemsPerPage: itemsPerPage,
                        onPreviousPagePressed: () {
                          setState(() {
                            currentPage = currentPage > 1 ? currentPage - 1 : 1;
                          });
                        },
                        onPageNumberPressed: (pageNumber) {
                          setState(() {
                            currentPage = pageNumber;
                          });
                        },
                        onNextPagePressed: () {
                          setState(() {
                            currentPage = currentPage < totalPages ? currentPage + 1 : totalPages;
                          });
                        },
                      ),
                    ],
                  );
                }
                return Offstage();
              },
            ),
          ),
        ],
      ),
    );
  }
}
