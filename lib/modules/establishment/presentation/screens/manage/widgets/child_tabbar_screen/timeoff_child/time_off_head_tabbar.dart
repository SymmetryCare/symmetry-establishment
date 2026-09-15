import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/timeoff_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/timeoff_data.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_table.dart';

/// Wraps a modal's child and auto-pops that modal's own route once the
/// window/viewport width drops below [breakpoint]. Lives entirely inside
/// the dialog's own subtree so it always targets the correct Navigator,
/// even under nested Navigators or scaled/desktop-simulated viewports.
class _AutoCloseOnNarrowWidth extends StatefulWidget {
  final double breakpoint;
  final Widget child;

  const _AutoCloseOnNarrowWidth({
    required this.breakpoint,
    required this.child,
  });

  @override
  State<_AutoCloseOnNarrowWidth> createState() =>
      _AutoCloseOnNarrowWidthState();
}

class _AutoCloseOnNarrowWidthState extends State<_AutoCloseOnNarrowWidth>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double width = MediaQuery.of(context).size.width;
      if (width < widget.breakpoint) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class TimeOffHeadTabbar extends StatefulWidget {
  final int employeeId;

  const TimeOffHeadTabbar({
    super.key,
    required this.employeeId,
  });

  @override
  State<TimeOffHeadTabbar> createState() => _TimeOffHeadTabbarState();
}

class _TimeOffHeadTabbarState extends State<TimeOffHeadTabbar> {
  TextEditingController _controllerStartDate = TextEditingController();
  TextEditingController _controllerEndDate = TextEditingController();

  final StreamController<List<TimeOfffData>> timeOffStremController =
  StreamController<List<TimeOfffData>>.broadcast();

  late int currentPage;
  late int itemsPerPage;

  /// Date format used for the picker labels AND the API query params.
  static const String _apiDateFormat = 'yyyy-MM-dd';

  /// Below this screen width, an open date picker is auto-dismissed.
  static const double _calendarCloseBreakpoint = 855;

// ============================================================
// TABLE SHAPE
// ============================================================

  // Column weights straight out of the design. The trailing column is fixed
  // so the action pills always fill it and the centred header sits over them.
  static const double _actionsWidth =
      2 * _pillWidth + _pillGap;
  // 86 in the design, but that was drawn against a 10px label; at the
  // Manage-wide 14px text "Approve" needs ~92 just to fit, so the pill is
  // widened well past that to give the labels real breathing room. The
  // action column is fixed-width, so the extra comes out of the flex text
  // columns automatically — their weights below stay untouched.
  static const double _pillWidth = 128;
  static const double _pillGap = 12;

  static final List<ManageColumn> _columns = [
    // Zn. No. holds a two-digit value, so it is pinned narrow rather than
    // handed a flex share it would only leave empty. That reclaimed width
    // goes to the action column with the rest.
    ManageColumn.fixed(AppString.znNo, 70, alignment: Alignment.centerLeft),
    const ManageColumn('Name', 190),
    ManageColumn(AppString.reasonTimeOff, 170),
    const ManageColumn('Start Time', 210),
    const ManageColumn('End Time', 210),
    ManageColumn.fixed('Action', _actionsWidth),
  ];

// ============================================================
// STYLES / SMALL WIDGETS
// ============================================================

  /// A pill sized to the design's fixed width, so Approve and Reject line up
  /// column-to-column however long their labels render.
  Widget _pill(Widget pill) => SizedBox(width: _pillWidth, child: pill);

  Widget _avatar(String imageUrl) {
    final bool hasImage =
        imageUrl.isNotEmpty && imageUrl != 'imgurl';
    const double size = 26;

    Widget fallback() => Image.asset('images/profilepic.png');

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                errorBuilder: (context, error, stackTrace) => fallback(),
              )
            : fallback(),
      ),
    );
  }

// ============================================================
// LIFECYCLE
// ============================================================

  @override
  void initState() {
    super.initState();

    currentPage = 1;
    itemsPerPage = 20;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeOffData();
    });
  }

  @override
  void dispose() {
    _controllerStartDate.dispose();
    _controllerEndDate.dispose();

    timeOffStremController.close();

    super.dispose();
  }

// ============================================================
// DATA LOADING  (single source of truth)
// ============================================================

  /// Loads time off data. Works with or without a date range selected, so it
  /// serves both the initial load AND post-approve/reject refreshes.
  Future<void> _loadTimeOffData() async {
    try {
      final response = await getEmployeeTimeOff(
        context: context,
        employeeId: widget.employeeId,
        startDate: _controllerStartDate.text,
        endDate: _controllerEndDate.text,
      );

      if (!timeOffStremController.isClosed) {
// Always add — even when empty — so stale rows are cleared.
        timeOffStremController.add(response);
      }
    } catch (e) {
      if (!timeOffStremController.isClosed) {
        timeOffStremController.addError(e);
      }
    }
  }

  Future<void> _refreshTimeOffData() => _loadTimeOffData();

// ============================================================
// DATE PICKERS  (yyyy-MM-dd)
// ============================================================

  DateTime? _tryParse(String value) {
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? current = _tryParse(_controllerStartDate.text);
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: DateTime(2000),
      lastDate: today,   // ← was DateTime(2101)
      builder: (dialogContext, child) => _AutoCloseOnNarrowWidth(
        breakpoint: _calendarCloseBreakpoint,
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _controllerStartDate.text =
            DateFormat(_apiDateFormat).format(pickedDate);

// Clear an end date that now precedes the start date.
        final DateTime? end = _tryParse(_controllerEndDate.text);
        if (end != null && end.isBefore(pickedDate)) {
          _controllerEndDate.clear();
        }
      });

      if (_controllerEndDate.text.isNotEmpty) {
        await _loadTimeOffData();
      }
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? start = _tryParse(_controllerStartDate.text);
    final DateTime firstDate = start ?? DateTime.now();
    final DateTime? current = _tryParse(_controllerEndDate.text);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),// ← was DateTime(2101)
      builder: (dialogContext, child) => _AutoCloseOnNarrowWidth(
        breakpoint: _calendarCloseBreakpoint,
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _controllerEndDate.text = DateFormat(_apiDateFormat).format(pickedDate);
      });

      await _loadTimeOffData();
    }
  }

// ============================================================
// APPROVE / REJECT FLOW
// ============================================================
// Uses the existing constant DeletePopup, unmodified. The loader is
// layered on top of it from here via a Stack, so no new dialog UI and
// no edits to delete_popup_const.dart are needed.

  Future<void> _confirmTimeOffAction(
      BuildContext context, {
        required int employeeTimeOffId,
        required bool isApprove,
      }) async {
    final String label = isApprove ? 'Approve' : 'Reject';
    bool isProcessing = false;
    ApiData? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: !isProcessing,
              child: Stack(
                alignment: Alignment.center,
                children: [
// ---- The existing constant popup (unchanged) ----
                  DeletePopup(
                    loadingDuration: isProcessing,
                    title: '$label Leave',
                    text:
                    'Do you really want to ${label.toLowerCase()} this leave?',
                    btnText: label,
                    onCancel: () {
                      Navigator.pop(dialogContext);
                    },
                    onDelete: () async {
                      if (isProcessing) return;
                      setDialogState(() => isProcessing = true);

                      final response = isApprove
                          ? await approveTimeOffPatch(
                          context, employeeTimeOffId)
                          : await rejectTimeOffPatch(
                          context, employeeTimeOffId);

                      result = response;

// Reload the list before closing so the row is
// already up to date behind the popup.
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        await _refreshTimeOffData();
                      }

                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

// Dialog closed — report the outcome.
    if (!mounted || result == null) return;

    final bool success =
        result!.statusCode == 200 || result!.statusCode == 201;

    showDialog(
      context: context,
      builder: (_) => success
          ? AddSuccessPopup(
        message:
        'Leave ${isApprove ? "Approved" : "Rejected"} Successfully.',
      )
          : FailedPopup(text: result!.message),
    );
  }

// ============================================================
// DATE FILTER BAR (shared by every state)
// ============================================================

  Widget _dateFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ManageDateField(
          placeholder: 'Start date',
          value: _controllerStartDate.text,
          onPressed: _selectStartDate,
        ),
        const SizedBox(width: 20),
        ManageDateField(
          placeholder: 'End date',
          value: _controllerEndDate.text,
          onPressed: _selectEndDate,
        ),
      ],
    );
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    // The same inset manage_screen's _bounded helper gives the other tabs.
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dateFilterBar(),
          // Breathing room between the toolbar row and the table.
          const SizedBox(height: 18),
          // Rows carry the blue left rail, so the header matches its inset.
          ManageTableHeader(columns: _columns, accented: true),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<TimeOfffData>>(
              stream: timeOffStremController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong',
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      'Please select Start Date and End Date',
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      AppStringHRNoData.timeOffNoData,
                      style: AllNoDataAvailable.customTextStyle(context),
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

  Widget _tableRow(BuildContext context, TimeOfffData timeOff, int index) {
    final int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;

    final String status = timeOff.timeOffStatus.toLowerCase().trim();
    final bool isApproved = status == 'approved';
    final bool isRejected = status == 'reject' || status == 'rejected';

    return ManageTableRow(
      columns: _columns,
      accentColor: ManageTable.accentBlue,
      height: ManageTable.rowHeightTall,
      cells: [
        ManageTableRow.text(
          context,
          serialNumber.toString().padLeft(2, '0'),
        ),
        // Name is the one cell with a leading avatar, so it is built by hand
        // rather than through ManageTableRow.text.
        Row(
          children: [
            _avatar(timeOff.imageUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                timeOff.employeeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ManageCardValueStyle.customTextStyle(context),
              ),
            ),
          ],
        ),
        ManageTableRow.text(context, timeOff.reason),
        ManageTableRow.text(context, timeOff.startDate),
        ManageTableRow.text(context, timeOff.endDate),
        _actionCell(
          timeOff,
          isApproved: isApproved,
          isRejected: isRejected,
        ),
      ],
    );
  }

  /// A decided row collapses to the single filled pill for its outcome; an
  /// undecided one shows both pills in their soft-wash form.
  Widget _actionCell(
    TimeOfffData timeOff, {
    required bool isApproved,
    required bool isRejected,
  }) {
    if (isApproved) {
      return Align(
        alignment: Alignment.centerRight,
        child: _pill(ManageStatusPill.approve(filled: true)),
      );
    }
    if (isRejected) {
      return Align(
        alignment: Alignment.centerRight,
        child: _pill(ManageStatusPill.reject(filled: true)),
      );
    }
    return Row(
      children: [
        _pill(
          ManageStatusPill.approve(
            onPressed: () => _confirmTimeOffAction(
              context,
              employeeTimeOffId: timeOff.employeeTimeOffId,
              isApprove: true,
            ),
          ),
        ),
        const SizedBox(width: _pillGap),
        _pill(
          ManageStatusPill.reject(
            onPressed: () => _confirmTimeOffAction(
              context,
              employeeTimeOffId: timeOff.employeeTimeOffId,
              isApprove: false,
            ),
          ),
        ),
      ],
    );
  }
}
