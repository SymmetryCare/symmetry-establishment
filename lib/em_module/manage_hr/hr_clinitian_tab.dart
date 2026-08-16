import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/hr_screen.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/widgets/edit_emp_popup_const.dart';
import 'package:provider/provider.dart';

import '../../../../app/resources/color.dart';
import '../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../app/resources/value_manager.dart';
import '../../../../app/services/api/managers/establishment_manager/all_from_hr_manager.dart';
import '../../../../data/api_data/establishment_data/all_from_hr/all_from_hr_data.dart';
import '../../../widgets/error_popups/delete_success_popup.dart';
import '../../../widgets/error_popups/failed_popup.dart';
import '../../../widgets/widgets/custom_scrollbar.dart';
import '../../../widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../company_identity/widgets/whitelabelling/success_popup.dart';
import 'manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';

class HRTabScreens extends StatefulWidget {
  final deptId;
  const HRTabScreens({super.key, this.deptId});

  @override
  State<HRTabScreens> createState() => _HRTabScreensState();
}

class _HRTabScreensState extends State<HRTabScreens> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HRTabScreenProvider>(builder: (context, provider, child) {
      return Column(
        children: [
          Expanded(
            child: StreamBuilder<List<HRAllData>>(
              stream: provider.hrAllcontroller.stream,
              builder: (context, snapshot) {
                getAllHrDeptWise(context, widget.deptId).then((data) {
                  provider.hrAllcontroller.add(data);
                }).catchError((error) {});
                print('1111111');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: ColorManager.blueprime),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      ErrorMessageString.noEmpType,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  List<HRAllData> sortedData = snapshot.data!;
                  sortedData.sort((a, b) => b.employeeTypesId.compareTo(a.employeeTypesId));

                  int totalItems = sortedData.length;
                  int totalPages = (totalItems / provider.itemsPerPage).ceil();
                  List<HRAllData> paginatedData = sortedData
                      .skip((provider.currentPage - 1) * provider.itemsPerPage)
                      .take(provider.itemsPerPage)
                      .toList();

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
                                  height: constraints.maxHeight,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: AppSize.s30,
                                        margin: EdgeInsets.symmetric(horizontal: 60),
                                        padding: EdgeInsets.only(right: 80, left: 20),
                                        decoration: BoxDecoration(
                                          color: ColorManager.fmediumgrey,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex: provider.flexVal,
                                              child: Text(AppStringEM.srno,
                                                textAlign: TextAlign.center,
                                                style: TableHeading.customTextStyle(context),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: SizedBox()),
                                            Expanded(
                                              flex: provider.flexVal,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 35.0),
                                                child: Text(AppStringEM.employee,
                                                  textAlign: TextAlign.start,
                                                  style: TableHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: SizedBox()),
                                            Expanded(
                                              flex: provider.flexVal,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20.0),
                                                child: Center(
                                                  child: Text(AppStringEM.abbrevation,
                                                    textAlign: TextAlign.start,
                                                    style: TableHeading.customTextStyle(context),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: provider.flexVal,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20.0),
                                                child: Text(AppStringEM.color,
                                                  textAlign: TextAlign.end,
                                                  style: TableHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                            Expanded(flex: 1, child: SizedBox()),
                                            Expanded(
                                              flex: provider.flexVal,
                                              child: Center(
                                                child: Text(AppStringEM.action,
                                                  style: TableHeading.customTextStyle(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: AppSize.s10),
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior: ScrollBehavior().copyWith(scrollbars: false),
                                          child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: paginatedData.length,
                                            itemBuilder: (context, index) {
                                              int serialNumber = index + 1 + (provider.currentPage - 1) * provider.itemsPerPage;
                                              String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                              HRAllData hrdoc = paginatedData[index];
                                              print('Color code ${hrdoc.color}');

                                              return Column(
                                                children: [
                                                  SizedBox(height: AppSize.s5),
                                                  Container(
                                                    padding: EdgeInsets.only(bottom: AppPadding.p5),
                                                    margin: EdgeInsets.symmetric(horizontal: 60),
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
                                                    height: AppSize.s56,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        // sr no
                                                        Expanded(
                                                          flex: provider.flexVal,
                                                          child: Center(
                                                            child: Text(
                                                              formattedSerialNumber,
                                                              style: DocumentTypeDataStyle.customTextStyle(context),
                                                              textAlign: TextAlign.start,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(flex: 1, child: SizedBox()),
                                                        // emp type
                                                        Expanded(
                                                          flex: provider.flexVal,
                                                          child: Text(
                                                            hrdoc.empType ?? '',
                                                            textAlign: TextAlign.start,
                                                            style: DocumentTypeDataStyle.customTextStyle(context),
                                                          ),
                                                        ),
                                                        // abbreviation
                                                        Expanded(
                                                          flex: provider.flexVal,
                                                          child: Center(
                                                            child: Text(
                                                              hrdoc.abbrivation ?? '',
                                                              style: DocumentTypeDataStyle.customTextStyle(context),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(width: 100),
                                                        // color
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width / 30,
                                                            height: AppSize.s22,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: hrdoc.color?.toColorMaybeNull,
                                                            ),
                                                          ),
                                                        ),
                                                        // actions
                                                        Expanded(
                                                          flex: 3,
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // edit
                                                                IconButton(
                                                                  splashColor: Colors.transparent,
                                                                  highlightColor: Colors.transparent,
                                                                  hoverColor: Colors.transparent,
                                                                  onPressed: () {
                                                                    final hexColorData = (hrdoc.color ?? '#FFFFFF').replaceAll('#', '');
                                                                    final Color hexColor = Color(int.parse('0xFF$hexColorData'));

                                                                    provider.typeController = TextEditingController(text: hrdoc.empType ?? '');
                                                                    provider.shorthandController = TextEditingController(text: hrdoc.abbrivation ?? '');

                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (context) {
                                                                        return EditPopupWidget(
                                                                          id: hrdoc.deptID,
                                                                          typeController: provider.typeController,
                                                                          shorthandController: provider.shorthandController,
                                                                          containerColor: hexColor,
                                                                          roleId: hrdoc.roleId ?? 0,
                                                                          roleName: hrdoc.roleName ?? '',
                                                                          masterEmpId: hrdoc.masterEmpTypeId ?? 0,
                                                                          masterEmpName: hrdoc.masterEmpTypeName ?? '',
                                                                          isClinician: true,
                                                                          childEmpTypeId: (hrdoc.childEmpTypeId ?? [])
                                                                              .where((id) => id != 0)
                                                                              .toList(),
                                                                          childEmpTypeNames: (hrdoc.childEmpTypeNames ?? [])
                                                                              .where((n) => n != null && n.isNotEmpty)
                                                                              .map((n) => n!)
                                                                              .toList(),
                                                                          salariedTemplateId: hrdoc.templateIdSalaried ?? 0,
                                                                          partTimeTemplateId: hrdoc.templateIdParttime ?? 0,
                                                                          perDiemTemplateId: hrdoc.templateIdPerdiem ?? 0,
                                                                          title: EditPopupString.editEmptype,
                                                                          onSavePressed: (
                                                                              String selectedColorToSave,
                                                                              int masterTypeId,
                                                                              int roleId,
                                                                              List<int> childEmpTypeId,
                                                                              int templateIdSalaried,
                                                                              int templateIdParttime,
                                                                              int templateIdPerdie,
                                                                              ) async {
                                                                            var response = await AllFromHrPatch(
                                                                              context,
                                                                              hrdoc.employeeTypesId,
                                                                              hrdoc.deptID,
                                                                              provider.typeController.text,
                                                                              provider.shorthandController.text,
                                                                              selectedColorToSave,
                                                                              roleId,
                                                                              masterTypeId,
                                                                              childEmpTypeId,
                                                                              templateIdSalaried,
                                                                              templateIdParttime,
                                                                              templateIdPerdie,
                                                                            );

                                                                            getAllHrDeptWise(context, widget.deptId).then((data) {
                                                                              provider.hrAllcontroller.add(data);
                                                                            }).catchError((error) {});

                                                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) => AddSuccessPopup(message: 'Edit Successfully'),
                                                                              );
                                                                            } else {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) => FailedPopup(text: response.message),
                                                                              );
                                                                            }

                                                                            provider.typeController.clear();
                                                                            provider.shorthandController.clear();
                                                                          },
                                                                          onColorChanged: (Color selectedColor) {
                                                                            provider.onColorChanged(index, selectedColor);
                                                                            print("Updated Color: ${provider.colorToHex(selectedColor)}");
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.edit_outlined,
                                                                    size: IconSize.I18,
                                                                    color: IconColorManager.bluebottom,
                                                                  ),
                                                                ),
                                                                SizedBox(width: 3),
                                                                // delete
                                                                IconButton(
                                                                  splashColor: Colors.transparent,
                                                                  highlightColor: Colors.transparent,
                                                                  hoverColor: Colors.transparent,
                                                                  onPressed: () async {
                                                                    await showDialog(
                                                                      context: context,
                                                                      builder: (context) => StatefulBuilder(
                                                                        builder: (context, setState) {
                                                                          return DeletePopup(
                                                                            loadingDuration: provider.isLoading,
                                                                            title: DeletePopupString.deleteEmpType,
                                                                            onCancel: () => Navigator.pop(context),
                                                                            onDelete: () async {
                                                                              provider.setLoading(true);
                                                                              try {
                                                                                await allfromHrDelete(context, hrdoc.employeeTypesId);
                                                                                getAllHrDeptWise(context, widget.deptId).then((data) {
                                                                                  provider.hrAllcontroller.add(data);
                                                                                }).catchError((error) {});
                                                                                Navigator.pop(context);
                                                                                showDialog(context: context, builder: (context) => DeleteSuccessPopup());
                                                                              } finally {
                                                                                provider.setLoading(false);
                                                                              }
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.delete_outline_outlined,
                                                                    size: IconSize.I18,
                                                                    color: IconColorManager.red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
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
                        currentPage: provider.currentPage,
                        items: snapshot.data!,
                        itemsPerPage: provider.itemsPerPage,
                        onPreviousPagePressed: () {
                          if (provider.currentPage > 1) {
                            provider.updatePageNumber(provider.currentPage - 1);
                          }
                        },
                        onPageNumberPressed: (pageNumber) {
                          provider.updatePageNumber(pageNumber);
                        },
                        onNextPagePressed: () {
                          if (provider.currentPage < totalPages) {
                            provider.updatePageNumber(provider.currentPage + 1);
                          }
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
      );
    });
  }
}