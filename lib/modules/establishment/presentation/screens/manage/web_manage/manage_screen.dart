import 'package:flutter/material.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/employee_profile/search_profile_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/bancking_child/banking_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/acknowledgements_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/add_vaccination_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/clinical_licenses.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/compensation_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/other_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/equipment_child/equipment_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/payrates_child/pay_rates_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/education_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/employment_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/licenses_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/references_child_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/termination/termination_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/timeoff_child/time_off_head_tabbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/form_status.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/profile_bar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/profilebar_editor.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class ManageScreen extends StatefulWidget {
  final int employeeId;
  final SearchByEmployeeIdProfileData? searchByEmployeeIdProfileData;
  final PageController pageManageController;
  final int? employeeEnrollId;
  final Future<void> Function() onRefresh;

  const ManageScreen({
    super.key,
    this.searchByEmployeeIdProfileData,
    required this.employeeId,
    required this.onRefresh,
    required this.pageManageController,
    this.employeeEnrollId,
  });

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  // Every size on this screen (fonts, paddings, card and pill dimensions)
  // comes straight from the 1920px-wide Figma frame. Rather than shrinking
  // each of those values individually — which would drift away from the
  // design's proportions — the whole screen is laid out at its Figma size
  // and then scaled down uniformly. Lower this to shrink further, set it
  // to 1.0 to render the design at full size.
  static const double _uiScale = 0.81;

  static const _blue = Color(0xFF008ABD);
  static const _slate = Color(0xFF64748B);
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isEditMode = false;
  bool _isRefreshing = false;

  SearchByEmployeeIdProfileData get profile =>
      widget.searchByEmployeeIdProfileData!;

  @override
  void didUpdateWidget(ManageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employeeId != widget.employeeId) {
      final state = Provider.of<HrManageProvider>(context, listen: false);
      state.setTab(0);
      state.setQulificationModuleTab(0);
      state.setDocumentsModuleTab(0);
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _finishEditing() async {
    setState(() => _isRefreshing = true);
    await widget.onRefresh();
    if (!mounted) return;
    setState(() {
      _isEditMode = false;
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      return ProfileEditScreen(
        onCancel: _finishEditing,
        employeeId: widget.employeeId,
      );
    }
    if (_isRefreshing) {
      return const Center(child: CircularProgressIndicator(color: _blue));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const minWidth = 1460.0;
          // Virtual viewport the design is laid out in: the real viewport
          // divided by the scale, so that once scaled back down it fills
          // exactly the space we were given.
          final layoutWidth = constraints.maxWidth / _uiScale;
          final layoutHeight = constraints.maxHeight / _uiScale;
          final contentWidth = layoutWidth < minWidth ? minWidth : layoutWidth;
          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: layoutWidth < minWidth,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // What the scaled-down result actually occupies on screen.
                width: contentWidth * _uiScale,
                height: constraints.maxHeight,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: contentWidth,
                    height: layoutHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 18, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 489,
                            child: ProfileBar(
                              searchByEmployeeIdProfileData: profile,
                              onEditPressed: () =>
                                  setState(() => _isEditMode = true),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(child: _buildWorkspace()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkspace() {
    final state = Provider.of<HrManageProvider>(context, listen: false);
    const labels = [
      'Qualifications',
      'Documents',
      'Banking',
      'Equipment',
      'Pay Rates',
      'Termination',
      'Time Off',
    ];

    return DefaultTabController(
      key: ValueKey('${widget.employeeId}-${state.currentTab}'),
      length: labels.length,
      initialIndex: state.currentTab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 1002,
            height: 60,
            child: TabBar(
              onTap: state.setTab,
              isScrollable: false,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
              indicator: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(9),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: _slate,
              // Figma: Fira Sans 400, 16/19.
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 19 / 16,
              ),
              tabs: labels.map((label) => Tab(text: label)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .60),
                border: Border.all(color: const Color(0xFFDEDEDE)),
                borderRadius: BorderRadius.circular(17),
              ),
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _qualificationTab(state),
                  _documentsTab(state),
                  BankingHeadTabbar(
                    employeeID: profile.employeeId!,
                    employeeStatus: profile.employeeStatus,
                  ),
                  InventoryHeadTabbar(
                    employeeId: profile.employeeId!,
                    employeeStatus: profile.employeeStatus,
                  ),
                  PayRatesHeadTabbar(employeeId: profile.employeeId!),
                  TerminationHeadTabbar(
                    employeeId: profile.employeeId!,
                    onTerminateSuccess: () async {
                      setState(() => _isRefreshing = true);
                      await widget.onRefresh();
                      if (mounted) setState(() => _isRefreshing = false);
                    },
                  ),
                  TimeOffHeadTabbar(employeeId: profile.employeeId!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualificationTab(HrManageProvider state) {
    return DefaultTabController(
      key: ValueKey(
          'qualification-${widget.employeeId}-${state.qulificationModuleTab}'),
      initialIndex: state.qulificationModuleTab,
      length: 4,
      child: Column(
        children: [
          _secondaryTabs(
            labels: const [
              'Employment',
              'Education',
              'References',
              'Professional licenses',
            ],
            onTap: state.setQulificationModuleTab,
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _scroll(EmploymentContainerConstant(
                  employeeId: widget.employeeId,
                  employeeStatus: profile.employeeStatus,
                )),
                _scroll(EducationChildTabbar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _scroll(ReferencesChildTabbar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _scroll(LicensesChildTabbar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentsTab(HrManageProvider state) {
    final clinical = profile.departmentId == 1;
    final labels = <String>[
      'Acknowledgements',
      'Compensation',
      'Vaccinations',
      'Other',
      'Form Status',
      if (clinical) 'Clinical Licenses',
    ];
    return DefaultTabController(
      key: ValueKey(
          'documents-${widget.employeeId}-${state.documentsModuleTab}'),
      length: labels.length,
      initialIndex: state.documentsModuleTab.clamp(0, labels.length - 1),
      child: Column(
        children: [
          _secondaryTabs(labels: labels, onTap: state.setDocumentsModuleTab),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _bounded(AcknowledgementsChildBar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _bounded(CompensationChildTabbar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _bounded(AdditionalVaccinationsChildBar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _bounded(OtherChildTabbar(
                  employeeId: profile.employeeId!,
                  employeeStatus: profile.employeeStatus,
                )),
                _bounded(FormStatusScreen(employeeId: profile.employeeId!)),
                if (clinical)
                  _bounded(ClinicalLicensesDoc(
                    employeeId: profile.employeeId!,
                    employeeStatus: profile.employeeStatus,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryTabs({
    required List<String> labels,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      height: 62,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: SizedBox(
        width: labels.length > 4 ? 980 : 720,
        height: 62,
        child: TabBar(
          onTap: onTap,
          // Secondary labels vary substantially in length (for example,
          // “Professional licenses” and “Acknowledgements”). Dividing the
          // fixed bar width evenly truncates those labels, so let each tab
          // take the width it needs and allow the row to scroll if necessary.
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          // A little breathing room keeps adjacent tab labels visually
          // distinct without wasting the available horizontal space.
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: _blue,
          indicatorWeight: 3,
          labelColor: _blue,
          unselectedLabelColor: _slate,
          // Figma: selected Fira Sans 600, unselected 400 — both 16/19.
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 19 / 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 19 / 16,
          ),
          tabs: labels.map((label) => Tab(text: label)).toList(),
        ),
      ),
    );
  }

  Widget _scroll(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Align(alignment: Alignment.topLeft, child: child),
    );
  }

  Widget _bounded(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: child,
    );
  }
}
