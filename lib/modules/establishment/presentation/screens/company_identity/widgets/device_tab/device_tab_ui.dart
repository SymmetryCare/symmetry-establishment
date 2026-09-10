import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_insurance_manager/device_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/device_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/device_tab/device_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/device_tab/device_edit_popup.dart';

class DeviceTabUi extends StatefulWidget {
  final int companyID;
  const DeviceTabUi({super.key, required this.companyID});

  @override
  State<DeviceTabUi> createState() => _DeviceTabUiState();
}

class _DeviceTabUiState extends State<DeviceTabUi> {
  final StreamController<List<InventoryData>> _deviceController =
  StreamController<List<InventoryData>>();

  bool _isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _deviceController.close();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    final data = await getInventoryList(context);
    _deviceController.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppPadding.p8,
        horizontal: AppPadding.p65,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Add button ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomIconButtonConst(
                width: AppSize.s80,
                icon: Icons.add,
                text: AppStringEM.add,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddInventoryPopup(
                      onSuccess: () async {
                        final data = await getInventoryList(context);
                        final newTotal =
                        (data.length / itemsPerPage).ceil().clamp(1, 999999);
                        setState(() => currentPage = newTotal);
                        _deviceController.add(data);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSize.s8),

          // ── Header row ─────────────────────────────────────────────────
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
                        style: TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Device Name',
                        style: TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Category',                          // ← new
                        style: TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Quantity',
                        style: TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppStringEM.actions,
                        style: TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSize.s10),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<InventoryData>>(
              stream: _deviceController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  );
                }
                final allData = snapshot.data!;
                if (allData.isEmpty) {
                  return Center(
                    child: Text(
                      'No devices found',
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }

                int totalPages =
                (allData.length / itemsPerPage).ceil().clamp(1, 999999);
                if (currentPage > totalPages) currentPage = totalPages;
                final paginatedData = allData
                    .skip((currentPage - 1) * itemsPerPage)
                    .take(itemsPerPage)
                    .toList();

                return Column(
                  children: [
                    Expanded(
                      child:  ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView.builder(
                          itemCount: paginatedData.length,
                          itemBuilder: (context, index) {
                            int serialNumber =
                                index + 1 + (currentPage - 1) * itemsPerPage;
                            String formattedSerial =
                            serialNumber.toString().padLeft(2, '0');
                            final InventoryData device = paginatedData[index];
                        
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSize.s8),
                                Container(
                                  height: AppSize.s56,
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppPadding.p12),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        // Sr. No.
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              formattedSerial,
                                              style: TableSubHeading
                                                  .customTextStyle(context),
                                            ),
                                          ),
                                        ),
                                        // Device Name
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              device.name,
                                              textAlign: TextAlign.center,
                                              style: TableSubHeading
                                                  .customTextStyle(context),
                                            ),
                                          ),
                                        ),
                                        // Category ── new ──────────────────
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              device.categoryName ?? '-',
                                              textAlign: TextAlign.center,
                                              style: TableSubHeading
                                                  .customTextStyle(context),
                                            ),
                                          ),
                                        ),
                                        // Quantity
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              device.qty.toString(),
                                              textAlign: TextAlign.center,
                                              style: TableSubHeading
                                                  .customTextStyle(context),
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        Expanded(
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                // ── Edit ──────────────
                                                IconButton(
                                                  splashColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor:
                                                  Colors.transparent,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          EditInventoryPopup(
                                                            device: device,
                                                            onSuccess: () async {
                                                              await _loadDevices();
                                                            },
                                                          ),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.edit_outlined,
                                                    size: IconSize.I22,
                                                    color: IconColorManager
                                                        .bluebottom,
                                                  ),
                                                ),
                                                const SizedBox(width: AppSize.s10),
                                                // ── Delete ────────────
                                                IconButton(
                                                  splashColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor:
                                                  Colors.transparent,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          StatefulBuilder(
                                                            builder: (BuildContext
                                                            context,
                                                                void Function(
                                                                    void
                                                                    Function())
                                                                setState) {
                                                              return DeletePopup(
                                                                title: 'Delete Device',
                                                                loadingDuration:
                                                                _isLoading,
                                                                onCancel: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                onDelete: () async {
                                                                  setState(() =>
                                                                  _isLoading =
                                                                  true);
                                                                  try {
                                                                    final result =
                                                                    await deleteInventory(
                                                                      context,
                                                                      device.inventoryId,
                                                                    );
                                                                    Navigator.pop(
                                                                        context);
                                                                    if (result
                                                                        .success) {
                                                                      showDialog(
                                                                        context:
                                                                        context,
                                                                        builder: (context) =>
                                                                            DeleteSuccessPopup(),
                                                                      );
                                                                      final data =
                                                                      await getInventoryList(
                                                                          context);
                                                                      final newTotal =
                                                                      (data.length /
                                                                          itemsPerPage)
                                                                          .ceil();
                                                                      setState(() {
                                                                        if (currentPage >
                                                                            newTotal &&
                                                                            newTotal >
                                                                                0) {
                                                                          currentPage =
                                                                              newTotal;
                                                                        }
                                                                      });
                                                                      _deviceController
                                                                          .add(data);
                                                                    }
                                                                  } finally {
                                                                    setState(() =>
                                                                    _isLoading =
                                                                    false);
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          ),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    size: IconSize.I22,
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
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    PaginationControlsWidget(
                      currentPage: currentPage,
                      items: allData,
                      itemsPerPage: itemsPerPage,
                      onPreviousPagePressed: () {
                        setState(() {
                          currentPage =
                          currentPage > 1 ? currentPage - 1 : 1;
                        });
                      },
                      onPageNumberPressed: (pageNumber) {
                        setState(() => currentPage = pageNumber);
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}