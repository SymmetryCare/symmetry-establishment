import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/company_identity_zone/widgets/zone_widgets_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';

class CiZoneZipcode extends StatefulWidget {
  final int countySortId;
  final int zoneSortId;
  final int companyID;
  final String officeId;
  final VoidCallback onRefresh;
   CiZoneZipcode({super.key, required this.companyID, required this.officeId, required this.countySortId, required this.zoneSortId, required this.onRefresh});

  @override
  State<CiZoneZipcode> createState() => _CiZoneZipcodeState();
}

class _CiZoneZipcodeState extends State<CiZoneZipcode> {
  TextEditingController countynameController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mapController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
   // StreamController<List<AllZipCodeGet>> _zipcodeController = StreamController<List<AllZipCodeGet>>.broadcast();
  late StreamController<List<AllZipCodeGet>> _zipcodeController;
  int docZoneId =0;
  int countyId =0;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;
  double? _latitude;
  double? _longitude;
  Timer? _fetchTimer;
  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _zipcodeController = StreamController<List<AllZipCodeGet>>.broadcast();
    fetchZipcodes();
    // Call every 3 seconds
    _fetchTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchZipcodes();
    });
  }
  @override
  void didUpdateWidget(covariant CiZoneZipcode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countySortId != widget.countySortId ||
        oldWidget.zoneSortId != widget.zoneSortId) {
      fetchZipcodes();
    }
  }
  void fetchZipcodes() {
    if (widget.countySortId != 0 && widget.zoneSortId != 0) {
      getZipcodeSetup(context, widget.officeId,1,999, widget.countySortId.toString(), widget.zoneSortId.toString()).then((data) {
        _zipcodeController.add(data);
      }).catchError((error) {
        _zipcodeController.add([]);
        debugPrint("Error loading zip codes: $error");
      });
    }
  }
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  String _location = 'Lat/Long not selected'; // Default text
  String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trimRight() + '';
  }
  @override
  void dispose() {
    _fetchTimer?.cancel(); // avoid memory leaks
    _zipcodeController.close(); // also close stream
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8, horizontal: AppPadding.p35),
      child: Column(
        children: [
          Container(
            height: AppSize.s30,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            ///heading
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(AppStringEM.zipCode,textAlign: TextAlign.start,
                        style:TableHeading.customTextStyle(context),),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(AppStringEM.map,
                          textAlign: TextAlign.start,
                        style:TableHeading.customTextStyle(context),),
                    ),
                  ),
                  // Expanded(
                  //   child: Center(
                  //     child: Text(
                  //       'Landmark',
                  //       style: GoogleFonts.firaSans(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w700,
                  //         color: Colors.white,
                  //         decoration: TextDecoration.none,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppStringEM.actions,
                        style:TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: AppSize.s10,
          ),
          Expanded(
            child:
            StreamBuilder<List<AllZipCodeGet>>(
              stream: _zipcodeController.stream,
              builder: (context, snapshot) {
                if(widget.countySortId == 0 || widget.zoneSortId == 0){
                  return Center(
                    child: Text(
                      ErrorMessageString.noSortZipcode,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
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
                      ErrorMessageString.noZipcode,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  int totalItems = snapshot.data!.length;
                  int totalPages = (totalItems / itemsPerPage).ceil();
                  List<AllZipCodeGet> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: paginatedData.length,
                            itemBuilder: (context, index) {
                              int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                              String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                              AllZipCodeGet zipcode = paginatedData[index];
                              return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xff000000).withOpacity(0.25),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                height: AppSize.s56,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   flex: 2,
                                      //   child: Text(
                                      //     textAlign: TextAlign.center,
                                      //     zipcode.city.toString(),
                                      //     style: GoogleFonts.firaSans(
                                      //       fontSize: 10,
                                      //       fontWeight: FontWeight.w500,
                                      //       color: ColorManager.mediumgrey,
                                      //       decoration: TextDecoration.none,
                                      //     ),
                                      //   ),
                                      // ),
                                      // Text(''),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          zipcode.zipcode.toString(),
                                          style:  TableSubHeading.customTextStyle(context),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap:() async{
                                             String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${zipcode.latitude}, ${zipcode.longitude}";
                                            if (await canLaunchUrlString(googleMapsUrl)) {
                                            await launchUrlString(googleMapsUrl);
                                            } else {
                                            print('Could not open the map.');
                                            }
                                          },
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            'View Map',
                                            style:  TableSubHeading.customTextStyle(context),
                                          ),
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 2,
                                      //   child: Text(
                                      //     textAlign: TextAlign.center,
                                      //     zipcode.landmark.toString(),
                                      //     style: GoogleFonts.firaSans(
                                      //       fontSize: 10,
                                      //       fontWeight: FontWeight.w500,
                                      //       color: ColorManager.mediumgrey,
                                      //       decoration: TextDecoration.none,
                                      //     ),
                                      //   ),
                                      // ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                splashColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onPressed: (){
                                              showDialog(context: context, builder: (context){
                                                return FutureBuilder<ZipCodeGetPrefill>(
                                                  future: getZipcodeSetupPrefill(context, zipcode.zipcodeSetupId!),
                                                  builder: (context,snapshotPrefill) {
                                                    if(snapshotPrefill.connectionState == ConnectionState.waiting){
                                                      return Center(child:CircularProgressIndicator(color: ColorManager.blueprime,));
                                                    }
                                                    var countyName = snapshotPrefill.data!.countyName;
                                                    var zoneName = snapshotPrefill.data!.zoneName;
                                                    var zipCode = snapshotPrefill.data!.zipcode;
                                                    // var landmark = snapshotPrefill.data!.landmark;
                                                    var zoinId = snapshotPrefill.data!.zoneId;
                                                    docZoneId = zoinId!;
                                                    var countyPreId = snapshotPrefill.data!.countyID;
                                                    countyId = countyPreId!;
                                                    // landmarkController = TextEditingController(text:snapshotPrefill.data!.landmark.toString());
                                                    // countynameController = TextEditingController(text:snapshotPrefill.data!.countyName.toString());
                                                    // cityController = TextEditingController(text: snapshotPrefill.data!.city.toString());
                                                    zipcodeController = TextEditingController(text: snapshotPrefill.data!.zipcode.toString());
                                                    return EditZipCodePopup(
                                                      lat: truncateWithEllipsis(snapshotPrefill.data!.latitude!,7),
                                                      long: truncateWithEllipsis(snapshotPrefill.data!.longitude!,8),
                                                      zoneName:zoneName,
                                                      countyName:countyName,
                                                      title: 'Edit Zip Code',
                                                      // countynameController: countynameController,
                                                      officeId: widget.officeId,
                                                      zipCodeSetupId: zipcode.zipcodeSetupId!,
                                                      zoneId: zoinId,
                                                      zipCodes: zipCode!,
                                                      countyId:countyPreId,
                                                      zipcodeController: zipcodeController,
                                                      latitude: snapshotPrefill.data!.latitude!,
                                                      longitude: snapshotPrefill.data!.longitude!,
                                                      onSavePressed: () async{
                                                        fetchZipcodes();
                                                      // getZipcodeSetup(context, widget.officeId,1, 20).then((data){
                                                      //   _zipcodeController.add(data);
                                                      // }).catchError((error){
                                                      // });

                                                      },
                                                      );
                                                  }
                                                );
                                              });
                                            },
                                                icon: Icon(Icons.edit_outlined,
                                                  size:IconSize.I22,color: IconColorManager.bluebottom,),),
                                          ],
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
