import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/manage_button_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/add_office_submit_button.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/whitelabelling_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/add_service_metadata_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

class CompanyIdentity extends StatefulWidget {
  const CompanyIdentity({Key? key}) : super(key: key);

  @override
  State<CompanyIdentity> createState() => _CompanyIdentityState();
}


class _CompanyIdentityState extends State<CompanyIdentity> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobNumController = TextEditingController();
  TextEditingController secNumController = TextEditingController();
  TextEditingController OptionalController = TextEditingController();
  TextEditingController stateNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();
  late StreamController<List<CompanyIdentityModel>> _companyIdentityController;
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  bool showStreamBuilder = true;
  bool showManageScreen = false;
  // bool _isSubmitting = false;
  bool showWhitelabellingScreen = false;
  final ScrollController _horizontalScrollController = ScrollController();

  void loadData() {}

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  String selectedOfficeID = '';
  String selectedOfficeName = '';
  String selectedStateName = '';
  String selectedCountryName = '';
  double selectedOfficeLat = 0.0;
  double selectedOfficeLon = 0.0;
  int selectedCompId = 0;
  int selectedCompOfficeId = 0;
  // bool _isSubmitting = false;

  void showManageScreenFunction(
      {required String officeId,
        officeName,
        required double officeLat,
        required double officeLon,
        required int compId,
        required int companyOfficeId,
        required String stateName,
        required String countryName}) {
    setState(() {
      selectedOfficeLat = officeLat;
      selectedOfficeLon = officeLon;
      selectedStateName = stateName;
      selectedCountryName = countryName;
      selectedOfficeID = officeId;
      selectedOfficeName = officeName;
      selectedCompId = compId;
      selectedCompOfficeId = companyOfficeId;
      showManageScreen = true;
      showStreamBuilder = false;
      showWhitelabellingScreen = false;
    });
  }

  void showWhitelabellingScreenFunction() {
    setState(() {
      showStreamBuilder = false;
      showWhitelabellingScreen = true;
      showManageScreen = false;
    });
  }

  int currentPage = 1;
  int itemsPerPage = 12;
  final int totalPages = 5;
  bool _isHovered = false;

  void onPageNumberPressed(int page) {
    setState(() {
      currentPage = page;
    });
  }

  String _trimAddress(String address) {
    const int maxLength = 28;
    if (address.length > maxLength) {
      return '${address.substring(0, maxLength)}...';
    }
    return address;
  }

  bool isHeadOffice = false;

  String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  String? generatedString;
  List<ServiceList> selectedServices = [];
  @override
  Widget build(BuildContext context) {
    _companyIdentityController = StreamController<List<CompanyIdentityModel>>();
    return LayoutBuilder(builder: (context, constraints) {
      const double minContentWidth = 1200;
      final double contentWidth = constraints.maxWidth > minContentWidth
          ? constraints.maxWidth
          : minContentWidth;
      return CustomScrollbar(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Column(
      children: [
        /// Render top row with buttons only if both manage and whitelabelling screens are not shown
        if (!showManageScreen && !showWhitelabellingScreen)
          Padding(
            padding: const EdgeInsets.only(right: AppPadding.p25, bottom: AppPadding.p15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconButtonConst(
                  width: AppSize.s150,
                  height: AppSize.s32,
                  text: AppStringEM.addService,
                  icon: Icons.add,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          AddServiceMetaDataPopup(),
                    );
                  },
                ),
                SizedBox(
                  width: AppSize.s35,
                ),
                CustomElevatedButton(
                  width: AppSize.s150,
                  height: AppSize.s32,
                  text: AppStringEM.whitelabelling,
                  color: ColorManager.blueprime,
                  onPressed: showWhitelabellingScreenFunction,
                ),
                SizedBox(
                  width: AppSize.s35,
                ),
                CustomIconButtonConst(
                  width: AppSize.s150,
                  text: AppStringEM.addNewOffice,
                  onPressed: () {
                    nameController.clear();
                    addressController.clear();
                    emailController.clear();
                    stateNameController.clear();
                    countryNameController.clear();
                    mobNumController.clear();
                    secNumController.clear();
                    OptionalController.clear();
                    selectedServices.clear();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return StatefulBuilder(
                        //   builder: (BuildContext context,
                        //       void Function(void Function()) setState) {
                            return FutureBuilder<List<ServicesMetaData>>(
                                future: getServicesMetaData(context),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasData) {
                                    return AddOfficeSumbitButton(
                                      nameController: nameController,
                                      addressController: addressController,
                                      emailController: emailController,
                                      stateController: stateNameController,
                                      countryController: countryNameController,
                                      mobNumController: mobNumController,
                                      secNumController: secNumController,
                                      OptionalController: OptionalController,
                                      onPressed: () async {},
                                      formKey: _formKey,
                                      servicesList: snapshot.data!,
                                    );
                                  } else {
                                    return ErrorPopUp(
                                        title: "Received Error",
                                        text: snapshot.error.toString());
                                  }
                                });
                          // },
                        // );
                      },
                    );
                  },
                  icon: Icons.add,
                ),
              ],
            ),
          ),

        /// Render list only if both manage and whitelabelling screens are not shown
        if (!showManageScreen && !showWhitelabellingScreen)
          Expanded(
            child: showStreamBuilder
                ? FutureBuilder(
                future: companyOfficeListGet(context, 1, 30),
                builder: (context, snap) {
                  if (snap.hasData) {
                    _companyIdentityController.add(snap.data!);
                    return StreamBuilder<List<CompanyIdentityModel>>(
                      stream: _companyIdentityController.stream,
                      builder: (BuildContext context, snapshot) {
                        companyOfficeListGet(context, 1, 30).then((data) {
                          _companyIdentityController.add(data);
                        }).catchError((error) {});
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue));
                        }
                        if (snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              ErrorMessageString.noOffice,
                              style: AllNoDataAvailable.customTextStyle(
                                  context),
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          int totalItems = snapshot.data!.length;
                          int totalPages =
                          (totalItems / itemsPerPage).ceil();
                          List<CompanyIdentityModel> paginatedData =
                          snapshot.data!
                              .skip((currentPage - 1) * itemsPerPage)
                              .take(itemsPerPage)
                              .toList();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10,vertical: 10),
                            child: Container(
                             // color: Colors.red,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ScrollConfiguration(
                                      behavior: ScrollBehavior().copyWith(scrollbars: false) ,
                                      child: LayoutBuilder(

                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          double screenWidth = MediaQuery.of(context).size.width;

                                          int columns = 4;  // Default to 4 columns for larger screens (laptops, desktops)
                                          double childAspectRatio = 1;  // Default aspect ratio for larger screens

                                          if (screenWidth <= 400) {
                                            columns = 1;
                                            childAspectRatio = 2;  // Use a taller aspect ratio for very small screens
                                          } else if (screenWidth <= 600) {
                                            columns = 2;
                                            childAspectRatio = 1.5; // Increase aspect ratio to use more space per item
                                          } else if (screenWidth <= 800) {
                                            columns = 2;
                                            childAspectRatio = 1.2; // Adjust aspect ratio to fit more content
                                          } else if (screenWidth <= 1000) {
                                            // For medium-sized tablets and small laptops (width <= 1000px)
                                            columns = 3;
                                            childAspectRatio = 1; // Default aspect ratio for tablets and small laptops
                                          } else if (screenWidth <= 1300) {
                                            // For large tablets and laptops (width <= 1200px)
                                            columns = 3;
                                            childAspectRatio = 0.95; // Slightly smaller items for larger screens
                                          }
                                          else {
                                            // For desktops and very large screens (> 1200px)
                                            columns = 4;
                                            childAspectRatio = 0.9; // More compact items for very large screens
                                          }
                                          return  GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columns,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25,
                                              childAspectRatio:childAspectRatio, // Aspect ratio of each grid item
                                            ),
                                            itemCount: paginatedData.length,
                                            itemBuilder: (context, index) {
                                              int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                              bool isHeadOffice = (currentPage == 1 && index == 0);

                                              return Container(
                                                margin:  EdgeInsets.symmetric(horizontal: AppPadding.p10,vertical: AppPadding.p10),
                                                // padding: const EdgeInsets.only(left: 20,right: 20,top: 0,bottom: 15),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                      offset: const Offset(1, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    isHeadOffice == true ?
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          height: AppSize.s22,
                                                          width: AppSize.s100,
                                                          decoration: BoxDecoration(
                                                            color: ColorManager
                                                                .faintOrange,
                                                            borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                              Radius.circular(10),
                                                              topRight:
                                                              Radius.circular(4),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              AppStringEM.headOffice,
                                                              style: TableHeading
                                                                  .customTextStyle(
                                                                  context),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ):SizedBox(  height: AppSize.s22,),
                                                    SizedBox(height: AppSize.s8,),
                                                    // Google Map Display
                                                    if (snapshot.data![index].lat != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: AppPadding.p25,right: AppPadding.p25,),
                                                        child: Column(
                                                          children: [

                                                            Container(
                                                              height: AppSize.s181,
                                                              child: GoogleMap(

                                                                initialCameraPosition:
                                                                CameraPosition(
                                                                  target: LatLng(
                                                                    double.parse(snapshot
                                                                        .data![index].lat),
                                                                    double.parse(snapshot
                                                                        .data![index].long),
                                                                  ),
                                                                  zoom: 15.0,
                                                                ),
                                                                markers: {
                                                                  Marker(
                                                                    markerId: MarkerId(''),
                                                                    position: LatLng(
                                                                      double.parse(snapshot
                                                                          .data![index]
                                                                          .lat),
                                                                      double.parse(snapshot
                                                                          .data![index]
                                                                          .long),
                                                                    ),
                                                                  ),
                                                                },
                                                                zoomControlsEnabled: false,
                                                                mapToolbarEnabled: false,
                                                                scrollGesturesEnabled: false,
                                                                tiltGesturesEnabled: false,
                                                                // scrollGesturesEnabled: !_isPopupOpen, // Disable gestures when popup is open
                                                                // tiltGesturesEnabled: !_isPopupOpen,
                                                                rotateGesturesEnabled: false,
                                                                myLocationButtonEnabled: false,
                                                              ),
                                                            ),
                                                            SizedBox(height: AppSize.s12),
                                                            //SizedBox(height: 4,),
                                                            Center(
                                                              child: InkWell(onTap: () async {
                                                                String googleMapsUrl =
                                                                    'https://www.google.com/maps/search/?api=1&query=${snapshot.data![index].lat}, ${snapshot.data![index].long}';
                                                                if (await canLaunchUrlString(googleMapsUrl)) {
                                                                  await launchUrlString(googleMapsUrl);
                                                                } else {
                                                                  print('Could not open the map.');
                                                                }
                                                              },
                                                                child: Text(
                                                                    "View in map", textAlign: TextAlign.center,
                                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: FontSize.s12, color: ColorManager.bluebottom, decoration: TextDecoration.underline,
                                                                    )),
                                                              ),
                                                            ),
                                                            SizedBox(height: AppSize.s6),
                                                            // Office Name and Address
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          AppStringEM.officeName,
                                                                          textAlign: TextAlign.start,
                                                                          style: TableSubHeading.customTextStyle(context),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Container(
                                                                            width:AppSize.s200,
                                                                            child: Text(
                                                                              paginatedData[index].officeName.toString(),
                                                                              textAlign: TextAlign.end,
                                                                              style: TableSubHeading.customTextStyle(context),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                SizedBox(height: AppSize.s6),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          AppStringEM.officeAddress,
                                                                          textAlign: TextAlign.start,
                                                                          style: TableSubHeading.customTextStyle(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Container(
                                                                            // color:Colors.red,
                                                                            width:AppSize.s200,
                                                                            child: Text(
                                                                             paginatedData[index].address.toString() ,
                                                                              textAlign: TextAlign.end,
                                                                              style: TableSubHeading.customTextStyle(context),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                    // Manage Button
                                                    Spacer(),
                                                   Padding(
                                                      padding: const EdgeInsets.only(bottom: AppPadding.p15),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                        CustomElevatedButton(
                                                        width: AppSize.s105,
                                                        height: AppSize.s30,
                                                        text: AppStringEM.manage,
                                                            color:  ColorManager.blueprime,
                                                            onPressed: ()async {
                                                              showManageScreenFunction(
                                                                officeId:
                                                                paginatedData[index]
                                                                    .officeId,
                                                                officeName:
                                                                paginatedData[index]
                                                                    .officeName,
                                                                compId:
                                                                paginatedData[index]
                                                                    .companyId,
                                                                companyOfficeId:
                                                                paginatedData[index]
                                                                    .companyOfficeId,
                                                                stateName:
                                                                paginatedData[index]
                                                                    .stateName,
                                                                countryName:
                                                                paginatedData[index]
                                                                    .countryName,
                                                                officeLat: double.parse(paginatedData[index].lat),
                                                                officeLon: double.parse(paginatedData[index].long),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              );
                                            },
                                          );  },

                                      ),
                                    ),
                                  ),
                                  /// Pagination Controls
                                  PaginationControlsWidget(
                                    currentPage: currentPage,
                                    items: snapshot.data!,
                                    itemsPerPage: itemsPerPage,
                                    onPreviousPagePressed: () {
                                      setState(() {
                                        currentPage = currentPage > 1
                                            ? currentPage - 1
                                            : 1;
                                      });
                                    },
                                    onPageNumberPressed: (pageNumber) {
                                      setState(() {
                                        currentPage = pageNumber;
                                      });
                                    },
                                    onNextPagePressed: () {
                                      setState(() {
                                        currentPage = currentPage < totalPages
                                            ? currentPage + 1
                                            : totalPages;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const Scaffold();
                      },
                    );
                  } else {
                    return const Center(
                        child:
                        CircularProgressIndicator(color: Colors.blue));
                  }
                })
                : PageView(
              controller: _pageController,
              children: [
                Container(
                  child: WhitelabellingScreen(
                    officeId: selectedOfficeID,
                    backButtonCallback: () {
                      setState(() {
                        showManageScreen = true;
                        showWhitelabellingScreen = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

        /// Render manage screen if showManageScreen is true
        if (showManageScreen)
          Expanded(
            child: ManageWidget(
              officeID: selectedOfficeID,
              officeName: selectedOfficeName,
              companyID: selectedCompId,
              backButtonCallBack: (bool val) {
                if (val) {
                  setState(() {
                    showWhitelabellingScreen = false;
                    showManageScreen = false;
                    showStreamBuilder = true;
                  });
                }
              },
              companyOfficeId: selectedCompOfficeId,
              stateName: selectedStateName,
              countryName: selectedCountryName,
              officeLat: selectedOfficeLat,
              officeLon: selectedOfficeLon,
            ),
          ),

        /// Render whitelabelling screen if showWhitelabellingScreen is true
        if (showWhitelabellingScreen)
          Expanded(
            child: WhitelabellingScreen(
              officeId: selectedOfficeID,
              backButtonCallback: () {
                setState(() {
                  showStreamBuilder = true;
                  showWhitelabellingScreen = false;
                });
              },
            ),
          ),
      ],          // Column children
    ),            // Column
            ),    // SizedBox
          ),      // Padding
        ),        // SingleChildScrollView
      );          // CustomScrollbar
    });           // LayoutBuilder
  }
}
