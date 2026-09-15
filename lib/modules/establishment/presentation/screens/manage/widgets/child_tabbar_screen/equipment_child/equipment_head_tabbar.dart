import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/equipment_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/equipment_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/equipment_child/widgets/add_new_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_table.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';

// ── Status options ────────────────────────────────────────────────────────
// These are just the values the API accepts for `inventoryStatus` — no
// enum, just plain strings straight from the server.
const String _statusMissing = 'Missing';
const String _statusDeposited = 'Deposited';
const String _statusIssued = 'Issued';
const List<String> _allStatuses = [
  _statusMissing,
  _statusDeposited,
  _statusIssued,
];

class InventoryHeadTabbar extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const InventoryHeadTabbar({
    super.key,
    required this.employeeId,
    required this.employeeStatus,
  });

  @override
  State<InventoryHeadTabbar> createState() => _InventoryHeadTabbarState();
}

class _InventoryHeadTabbarState extends State<InventoryHeadTabbar> {
  final StreamController<List<EquipmentData>> equipementDataStreamController =
      StreamController<List<EquipmentData>>();
  late int currentPage;
  late int itemsPerPage;

  // ── Table geometry ───────────────────────────────────────────────────────
  // Column weights straight out of the design. The trailing weight holds
  // three action circles plus the gaps between them.
  static final List<ManageColumn> _columns = [
    const ManageColumn(AppString.srNo, 110),
    ManageColumn(AppStringHr.inventoryid, 156),
    ManageColumn(AppStringHr.docName, 188),
    const ManageColumn('Device Description', 162),
    const ManageColumn('Category', 124),
    const ManageColumn('Assign Date', 161),
    // Fixed, not flex: the width is exactly the three action circles plus
    // their gaps, so the buttons always fill the cell and the centred header
    // sits dead centre over them at any panel width.
    ManageColumn.fixed('Status', manageActionsWidth(3)),
  ];

  // Status comes straight from the API (`inventoryStatus`) and persists for
  // real via updateEquipmentStatusPatch. This map only holds an OPTIMISTIC
  // local override for a row while that PATCH is in flight, keyed by
  // employeeInventoryId — the actual per-row record id (inventoryId is NOT
  // unique per row; multiple assigned items can share one inventoryId).
  // Reset on every _loadEquipment() call, seeded from the server value.
  final Map<int, String> _statusOverrideByInventoryId = {};

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    itemsPerPage = 20;
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final data = await getEquipement(context, widget.employeeId);
    if (!mounted || equipementDataStreamController.isClosed) return;

    setState(() {
      _statusOverrideByInventoryId.clear();
      for (final item in data) {
        _statusOverrideByInventoryId[item.employeeInventoryId] =
            item.inventoryStatus ?? _statusIssued;
      }
    });
    equipementDataStreamController.add(data);
  }

  @override
  void dispose() {
    equipementDataStreamController.close();
    super.dispose();
  }

  bool get _isReadOnly =>
      widget.employeeStatus == 'Terminated' ||
      widget.employeeStatus == 'Inactive';

  String _statusOf(EquipmentData data) =>
      _statusOverrideByInventoryId[data.employeeInventoryId] ??
      (data.inventoryStatus ?? _statusIssued);

  // ── Status change logic (unchanged behaviour) ────────────────────────────
  // The design replaces the old more_vert cell with the row's action
  // buttons, so the status picker now hangs off the edit (pencil) button —
  // status is the only field the API lets us change on an assigned item.
  Future<void> _applyStatusChange(EquipmentData data, String value) async {
    // Optimistic UI update while the PATCH is in flight.
    setState(() {
      _statusOverrideByInventoryId[data.employeeInventoryId] = value;
    });

    final result = await updateEquipmentStatusPatch(
      context,
      data.employeeInventoryId,
      data.employeeId,
      value,
    );

    if (!mounted) return;

    if (result.success) {
      await _loadEquipment();
    } else {
      // Revert on failure since the server rejected it.
      setState(() {
        _statusOverrideByInventoryId[data.employeeInventoryId] =
            data.inventoryStatus ?? _statusIssued;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The same inset manage_screen's _bounded helper gives the other tabs;
    // Equipment is handed to the TabBarView bare, so it carries its own.
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isReadOnly)
            AddNewOutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      EquipmentAddPopup(employeeId: widget.employeeId),
                ).then((_) => _loadEquipment());
              },
            ),
          // Breathing room between the toolbar row and the table.
          const SizedBox(height: 18),
          ManageTableHeader(columns: _columns),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<EquipmentData>>(
              stream: equipementDataStreamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Text(
                        AppStringHRNoData.equpmentNoData,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    ),
                  );
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) =>
                        _tableRow(context, snapshot.data![index], index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, EquipmentData data, int index) {
    final int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;

    return ManageTableRow(
      columns: _columns,
      cells: [
        ManageTableRow.text(context, serialNumber.toString().padLeft(2, '0')),
        ManageTableRow.text(context, data.employeeInventoryId.toString()),
        ManageTableRow.text(context, data.name),
        ManageTableRow.text(context, data.givenId),
        ManageTableRow.text(context, data.categoryName ?? '-'),
        ManageTableRow.text(context, data.assignedDate),
        _EquipmentRowActions(
          currentStatus: _statusOf(data),
          readOnly: _isReadOnly,
          onStatusSelected: (value) => _applyStatusChange(data, value),
        ),
      ],
    );
  }
}

// ── Row actions ────────────────────────────────────────────────────────────
// The three circular buttons from the design, built from the shared
// ManageRowActionButton. Edit opens the status picker overlay anchored under
// the pencil, which runs the unchanged PATCH flow in the parent. Download and
// delete are wired to nothing yet — the equipment API exposes neither a file
// to fetch nor a delete endpoint.
class _EquipmentRowActions extends StatefulWidget {
  final String currentStatus;
  final bool readOnly;
  final ValueChanged<String> onStatusSelected;

  const _EquipmentRowActions({
    required this.currentStatus,
    required this.readOnly,
    required this.onStatusSelected,
  });

  @override
  State<_EquipmentRowActions> createState() => _EquipmentRowActionsState();
}

class _EquipmentRowActionsState extends State<_EquipmentRowActions> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  Color _colorFor(String status) {
    switch (status) {
      case _statusMissing:
        return ColorManager.red;
      case _statusDeposited:
        return ColorManager.EMgreen;
      case _statusIssued:
        return ColorManager.yellowBright;
      default:
        return ColorManager.mediumgrey;
    }
  }

  OverlayEntry _buildOverlay() {
    const double menuWidth = 150;
    const double buttonSize = ManageRowActionButton.size;
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full-screen tap catcher to dismiss when tapping outside.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-menuWidth + buttonSize, buttonSize + 4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _allStatuses.map((status) {
                      final bool isSelected = widget.currentStatus == status;
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: ColorManager.containerBorderGrey
                            .withValues(alpha: 0.3),
                        onTap: () {
                          _removeOverlay();
                          if (status != widget.currentStatus) {
                            widget.onStatusSelected(status);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _colorFor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  status,
                                  style: ManageCardValueStyle.customTextStyle(
                                    context,
                                  ).copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: ColorManager.blueprime,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageRowActions(
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: ManageRowActionButton.edit(
            onPressed: widget.readOnly ? null : _toggleOverlay,
          ),
        ),
        // TODO: no document is attached to an assigned item yet — enable once
        // the equipment API returns one.
        ManageRowActionButton.download(),
        // TODO: enable once a delete-assigned-equipment endpoint exists.
        ManageRowActionButton.delete(),
      ],
    );
  }
}
