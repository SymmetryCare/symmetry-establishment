import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/payrates_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/payrates_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_table.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';

// The two rate bases the tab can show. "Per Zone" reads `payRates` off each
// row; "Per Mileage" reads `permiles`.

const String _perZone = 'Per Zone';
const String _perMileage = 'Per Mileage';

class PayRatesHeadTabbar extends StatefulWidget {
  final int employeeId;
  const PayRatesHeadTabbar({super.key, required this.employeeId});

  @override
  State<PayRatesHeadTabbar> createState() => _PayRatesHeadTabbarState();
}

class _PayRatesHeadTabbarState extends State<PayRatesHeadTabbar> {
  final StreamController<List<PayratesData>> _payratesStreamController =
      StreamController<List<PayratesData>>();

  late int currentPage;
  late int itemsPerPage;

  String _rateBasis = _perZone;

  // ── Table geometry ───────────────────────────────────────────────────────
  // Column weights straight out of the design: Rate takes the slack between
  // "Type of Visit" and the trailing action buttons.
  static final List<ManageColumn> _columns = [
    const ManageColumn(AppString.znNo, 130),
    const ManageColumn('Type of Visit', 180),
    const ManageColumn('Rate', 590),
    // Fixed, not flex: the width is exactly the two action circles plus
    // their gap, so the buttons always fill the cell and the centred header
    // sits dead centre over them at any panel width.
    ManageColumn.fixed('Action', manageActionsWidth(2)),
  ];

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    itemsPerPage = 20;
    _loadData();
  }

  void _loadData() {
    getEmployeePayrates(context, widget.employeeId, 1, 20).then((data) {
      if (mounted) _payratesStreamController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _payratesStreamController.close();
    super.dispose();
  }

  Future<void> _confirmDelete(PayratesData payRates) async {
    showDialog(
      context: context,
      builder: (_) => DeletePopup(
        title: 'Delete',
        onCancel: () => Navigator.pop(context),
        onDelete: () async {
          Navigator.pop(context);
          final result = await deleteEmployeePayrates(
            context: context,
            employeePayratesId: payRates.payratesSetupId,
          );
          if (result.success) _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The same inset manage_screen's _bounded helper gives the other tabs.
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RateBasisDropdown(
            value: _rateBasis,
            onChanged: (value) => setState(() => _rateBasis = value),
          ),
          // Breathing room between the toolbar row and the table.
          const SizedBox(height: 18),
          // Rows carry the blue left rail, so the header matches its inset.
          ManageTableHeader(columns: _columns, accented: true),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<PayratesData>>(
              stream: _payratesStreamController.stream,
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
                        AppStringHRNoData.payRatesNoData,
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
                        _tableRow(context, snapshot.data![index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, PayratesData payRates) {
    final int rate =
        _rateBasis == _perMileage ? payRates.permiles : payRates.payRates;

    return ManageTableRow(
      columns: _columns,
      accentColor: ManageTable.accentBlue,
      height: ManageTable.rowHeightTall,
      cells: [
        ManageTableRow.text(context, '${payRates.zoneId}'),
        ManageTableRow.text(context, payRates.visitType),
        ManageTableRow.text(context, '$rate'),
        ManageRowActions(
          children: [
            // TODO: enable once an update-employee-payrates endpoint exists —
            // the manager only exposes get and delete today.
            ManageRowActionButton.edit(),
            ManageRowActionButton.delete(
              onPressed: () => _confirmDelete(payRates),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Rate-basis dropdown ────────────────────────────────────────────────────
// The rounded pill from the design: white, hairline border, full radius, with
// a small caret. Uses the shared 14/17 label style so it matches the table.
class _RateBasisDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RateBasisDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 175,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(
          Icons.arrow_drop_down,
          size: 18,
          color: Color(0xFF64748B),
        ),
        style: ManageCardLabelStyle.customTextStyle(context),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: const [_perZone, _perMileage]
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }
}
