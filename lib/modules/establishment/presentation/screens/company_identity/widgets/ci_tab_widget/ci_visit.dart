import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/ci_visit_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_visit_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/visit_constants.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';

class CiVisitScreen extends StatefulWidget {

  const CiVisitScreen({super.key});

  @override
  State<CiVisitScreen> createState() => _CiVisitScreenState();
}

class _CiVisitScreenState extends State<CiVisitScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  String? selectedValue;
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController eligibleClinicalController = TextEditingController();
  final StreamController<List<CiVisit>> _visitController =
  StreamController<List<CiVisit>>();
  late List<Color> hrcontainerColors;
  int empTypeId = 0;
  @override
  void initState() {
    super.initState();
    hrcontainerColors = List.generate(20, (index) => Color(0xffE8A87D));
    _loadColors();
    getVisit(context, 1, 9999).then((data) {
      _visitController.add(data);
    }).catchError((error) {

    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }
  String? selectedServiceName;
  String? serviceId;
  List<Widget> selectedChips = [];
  List<Widget> chipsList = [];
  List<String> editChipValues = [];
  List<int> selectedChipsId = [];
  List<Widget> selectedEditChips = [];
  List<int> selectedEditChipsId = [];
  List<String> chipValues = [];
  String chips = "";
  bool _isLoading = false;
  bool _isDarkColor(Color color) {
    double perceivedBrightness =
        color.red * 0.299 + color.green * 0.587 + color.blue * 0.114;
    return perceivedBrightness <
        128;
  }

  void deleteChip(String chip, int chipId) {
    setState(() {
      selectedChips.remove(chip);
      selectedChipsId.remove(chipId);
    });
  }

  void _loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < hrcontainerColors.length; i++) {
        int? colorValue = prefs.getInt('containerColor$i');
        if (colorValue != null) {
          hrcontainerColors[i] = Color(colorValue);
        }
      }
    });
  }

  String _selectedItem = 'Select';
  void _onDropdownItemSelected(String newValue) {
    setState(() {
      _selectedItem = newValue;
    });
  }

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }
  TextEditingController dummyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/26),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomIconButtonConst(
                text: AppString.addnewvisit,
                height: AppSize.s30,
                icon: Icons.add,
                onPressed: () async {
                  docIdController.clear();
                  docNamecontroller.clear();
                  selectedChips.clear();
                  selectedServiceName = "";
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return AddVisitPopup(
                              title: AppStringEM.addNewvisit,
                              nameOfDocumentController: docNamecontroller,
                              idOfDocumentController: docIdController,
                            );
                          },
                        );
                      });
                }),
          ],
        ),
        SizedBox(
          height: AppSize.s10,
        ),
        Expanded(
          child: StreamBuilder<List<CiVisit>>(
              stream: _visitController.stream,
              builder: (context, snapshot) {
                print('1111111');
                getVisit(context, 1, 9999).then((data) {
                  _visitController.add(data);
                }).catchError((error) {
                  // Handle error
                });
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppPadding.p150),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Center(
                      child: Text(
                        ErrorMessageString.noVisit,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  int totalItems = snapshot.data!.length;
                  int totalPages = (totalItems / itemsPerPage).ceil();
                  List<CiVisit> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();
                  return Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
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
                                  child: Column(
                                    children: [
                                      ///headings
                                      Container(
                                        height: AppSize.s30,
                                        decoration: BoxDecoration(
                                          color: ColorManager.fmediumgrey,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: AppPadding.p60),
                                              child: Text(
                                                AppString.srNo,
                                                textAlign: TextAlign.center,
                                                style: TableHeading.customTextStyle(context),
                                              ),
                                            ),
                                            ///type of visit
                                            Padding(
                                              padding: const EdgeInsets.only(left: AppPadding.p80),
                                              child: Text(
                                                AppString.visit,
                                                textAlign: TextAlign.center,
                                                style: TableHeading.customTextStyle(context),
                                              ),
                                            ),
                                            ///EL clinician
                                            Padding(
                                              padding: const EdgeInsets.only(right: 195),
                                              child: Text(
                                                AppString.eligibleClinician,
                                                textAlign: TextAlign.center,
                                                style: TableHeading.customTextStyle(context),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: AppPadding.p60),
                                              child: Text(
                                                AppString.actions,
                                                textAlign: TextAlign.center,
                                                style: TableHeading.customTextStyle(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: AppSize.s5,
                                      ),
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior: ScrollBehavior().copyWith(scrollbars: false),
                                          child: ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: paginatedData.length,
                                              itemBuilder: (context, index) {
                                                                          int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                                                          String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                                                          CiVisit visitData = paginatedData[index];
                                                                          print("Length ::: ${snapshot.data![index].eligibleClinician.toString()}");
                                                                          List<Widget> clinical = [];
                                                                          for (var i in visitData.eligibleClinician!) {
                                                                            var hexColor = i.color.replaceAll("#", "");
                                                                            clinical.add(Padding(
                                                                              padding: const EdgeInsets.all(AppPadding.p8),
                                                                              child: Container(
                                          height: AppSize.s30,
                                          width: AppSize.s30,
                                          color: hexColor == 'string'
                                              ? Colors.white
                                              : Color(int.parse('0xFF$hexColor')),
                                          child: Center(
                                              child: Text(
                                                i.eligibleClinician,
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color: _isDarkColor(hexColor == 'string'
                                                      ? Colors.white
                                                      : Color(int.parse('0xFF$hexColor')))
                                                      ? ColorManager.white
                                                      : ColorManager.black,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ))),
                                                                            ));
                                                                          }
                                                                          return Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                          padding: const EdgeInsets.symmetric(vertical: AppPadding.p6, horizontal: AppPadding.p2),
                                          child: Container(
                                              padding: EdgeInsets.only(bottom: AppPadding.p5),
                                              decoration: BoxDecoration(
                                                color: ColorManager.white,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorManager.grey.withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              // FIXED: Removed fixed height so container grows
                                              // to fit wrapped clinician chips
                                              constraints: BoxConstraints(minHeight: AppSize.s56),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      formattedSerialNumber,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: AppPadding.p70),
                                                      child: Text(
                                                        visitData.typeofVisit.toString(),
                                                        textAlign: TextAlign.center,
                                                        style: DocumentTypeDataStyle.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  // FIXED: Changed Row to Wrap so clinician chips
                                                  // wrap to next line instead of overflowing
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: AppPadding.p10),
                                                      child: Wrap(
                                                        alignment: WrapAlignment.start,
                                                        crossAxisAlignment: WrapCrossAlignment.center,
                                                        children: clinical,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                              splashColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              hoverColor: Colors.transparent,
                                                              onPressed: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return FutureBuilder<VisitListDataPrefill>(
                                                                      future: getVisitListPrefill(context, visitData.visitId),
                                                                      builder: (context, snapshotPrefill) {
                                                                        if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                          return Center(
                                                                            child: CircularProgressIndicator(
                                                                              color: ColorManager.blueprime,
                                                                            ),
                                                                          );
                                                                        }
                                                                        var visitName = snapshotPrefill.data!.visitType;
                                                                        docNamecontroller = TextEditingController(
                                                                          text: snapshotPrefill.data!.visitType.toString(),
                                                                        );

                                                                        return StatefulBuilder(
                                                                          builder: (BuildContext context, setState) {
                                                                            // Initialize the chips only once, when the dialog is first built
                                                                            if (selectedEditChips.isEmpty) {
                                                                              for (var i in snapshotPrefill.data!.eligibleClinicia) {
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
                                                                                      size: IconSize.I16,
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
                                                                                        // Remove chip data
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
                                                                            return EditVisitPopup(
                                                                              serviceNameSelected: TextEditingController(text: snapshotPrefill.data!.serviceId),
                                                                              enable: false,
                                                                              visitId: snapshotPrefill.data!.visitId,
                                                                              nameOfDocumentController: docNamecontroller,
                                                                              idOfDocumentController: docIdController,
                                                                              prefilledClinicians: snapshotPrefill.data!.eligibleClinicia,
                                                                              title: AppStringEM.editVisit,
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.edit_outlined,
                                                                size: IconSize.I18,
                                                                color: IconColorManager.bluebottom,
                                                              )),
                                                          SizedBox(
                                                            width: AppSize.s3,
                                                          ),
                                                          IconButton(
                                                            splashColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            hoverColor: Colors.transparent,
                                                            onPressed: () {
                                                              showDialog(context: context,
                                                                builder: (context) =>
                                                                    StatefulBuilder(
                                                                      builder: (BuildContext context, void Function(void Function())
                                                                      setState) {
                                                                        return DeletePopup(
                                                                            title: 'Delete Visit',
                                                                            loadingDuration: _isLoading,
                                                                            onCancel: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            onDelete: () async {
                                                                              setState(() {
                                                                                _isLoading = true;
                                                                              });
                                                                              try {
                                                                                await deleteVisit(context, snapshot.data![index].visitId);
                                                                                getVisit(context, 1, 10).then((data) {
                                                                                  _visitController.add(data);
                                                                                }).catchError((error) {
                                                                                  // Handle error
                                                                                });
                                                                                Navigator.pop(context);
                                                                                showDialog(context: context, builder: (context) => DeleteSuccessPopup());
                                                                              } finally {
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                              }
                                                                            }
                                                                        );
                                                                      },
                                                                    ),
                                                              );
                                                            },
                                                            icon: Icon(
                                                              size: IconSize.I18,
                                                              Icons.delete_outline,
                                                              color: IconColorManager.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                                                                )
                                                                              ]);
                                                                        }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
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
              }),
        ),
      ]),
    );
  }
}