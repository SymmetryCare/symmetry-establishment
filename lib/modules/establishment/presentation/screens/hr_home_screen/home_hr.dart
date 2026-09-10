import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_search_provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/pay_rates_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/search_byfilter.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/employee_profile/search_profile_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/controllers/hr_navigation_controller.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/dashboard/dashoboard_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/hr_home_screen/referesh_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/web_manage/manage_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/new_onboard_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/register_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_hr/see_all_hr_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/hh_emr_appbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/const_appbar/controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';

class HomeHrScreen extends StatefulWidget {
  const HomeHrScreen({super.key});

  @override
  State<HomeHrScreen> createState() => _HomeHrScreenState();
}

class _HomeHrScreenState extends State<HomeHrScreen> {
  PageController _pageController = PageController();
  PageController _pageManageController = PageController();
  late final String? dropdownValue;
  late final ValueChanged<String?>? onChanged;
  final HRController hrController = Get.put(HRController());
  late final VoidCallback? onItem2Selected;
  bool showSelectOption = true;
  bool isSelected = false;
  final HrNavigationController myController = Get.put(HrNavigationController());
  String selectedOption = 'Select';
  TextEditingController searchController = TextEditingController();
  Future<List<SearchEmployeeProfileData>>? _searchFuture;

  TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<String> _searchResults = [];

  final LayerLink _layerLink = LayerLink();
  List<SearchEmployeeProfileData> data = [];
  List<ApiDataFilter> data1 = [];

  // ✅ NEW — tracks whichever search-bar width is currently active (wide or
  // narrow layout) so the suggestion overlay below can match it exactly,
  // instead of being hardcoded to 180 regardless of the actual box width.
  double _currentSearchBarWidth = 180;

  // ── Cached profile future — prevents refetch/rebuild loop on every build ──
  Future<SearchByEmployeeIdProfileData>? _employeeProfileFuture;

  // ── Cached filter-dialog dropdown futures — prevents refetch on every
  // rebuild of the filter dialog (e.g. every keystroke/setState above).
  late Future<List<CompanyOfficeListData>> _companyOfficeListFuture;
  late Future<List<SortByZoneData>> _payRateZoneFuture;

  // ── Hamburger menu overlay ──────────────────────────────────────────────
  OverlayEntry? _menuOverlay;
  final GlobalKey _menuButtonKey = GlobalKey();

  static const List<String> _tabLabels = [
    'Dashboard',
    'Manage',
    'Register',
    'Onboarding',
    'Reports',
  ];

  // ── Helper: reset manage tabs when new employee is selected ─────────────────
  void _resetManageTabs() {
    Provider.of<HrManageProvider>(context, listen: false).setTab(0);
  }

  // ✅ NEW — persistence keys for the currently-selected employee. Needed
  // because crossing the desktop/tablet width breakpoint recreates this
  // whole State (initState runs again with employeeId back at 0 and a fresh,
  // empty `_controller`), so without persisting somewhere outside this
  // State's memory, the selected employee and typed search text vanish on
  // resize even though the underlying page/tab index was already being saved.
  static const String _selectedEmployeeIdKey = 'selectedEmployeeId';
  static const String _selectedEmployeeNameKey = 'selectedEmployeeName';

  Future<void> _persistSelectedEmployee(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedEmployeeIdKey, id);
    await prefs.setString(_selectedEmployeeNameKey, name);
  }

  // ✅ NEW — restores the selected employee (id + typed search text) after a
  // fresh State is created, e.g. when resizing across the desktop/tablet
  // breakpoint. Only restores if the user had actually picked someone
  // (id != 0) and does NOT force a tab switch — it just re-hydrates the
  // Manage tab's data + the search box text so whichever tab/page the layout
  // rebuild lands on already has the right context if the user goes back.
  Future<void> _restoreSelectedEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_selectedEmployeeIdKey) ?? 0;
    final savedName = prefs.getString(_selectedEmployeeNameKey) ?? '';
    if (savedId != 0 && mounted) {
      setState(() {
        employeeId = savedId;
        _controller.text = savedName;
        _employeeProfileFuture =
            getSearchByEmployeeIdProfileByText(context, employeeId);
      });
    }
  }

  // ── Helper: select an employee from search results ──────────────────────
  // FIX: previously recreated `_pageController = PageController(initialPage: 1)`
  // here. That worked only when the PageView itself was rebuilt from scratch
  // on every change. Now that PageView is permanently mounted (see build()),
  // it already has a live scroll position attached to the OLD controller —
  // swapping in a brand-new PageController just re-attaches to that same
  // existing position and ignores `initialPage`, so the page silently stayed
  // on Dashboard after picking a search result. Use _navigateToTab(1) instead,
  // which calls animateToPage on the one persistent controller that's always
  // attached.
  void _selectEmployee(int id, {String name = ''}) {
    setState(() {
      employeeId = id;
      if (name.isNotEmpty) _controller.text = name;
      _employeeProfileFuture =
          getSearchByEmployeeIdProfileByText(context, employeeId);
      _resetManageTabs(); // ← reset tabs to Qualifications
    });
    // ✅ NEW — persist so the selection survives a State recreation caused
    // by a desktop/tablet breakpoint switch.
    _persistSelectedEmployee(id, _controller.text);
    _navigateToTab(1);
  }

  // FIX: new helper — actually refetches the employee profile and only
  // updates state once the fresh data is in hand. This is what ManageScreen's
  // onCancel now awaits before switching back from edit mode, so the
  // ProfileBar never rebuilds with the stale searchByEmployeeIdProfileData.
  // Previously onRefresh was `() { setState(() {}); }` — a no-op that never
  // refetched anything, so the fix in ManageScreen had nothing fresh to await.
  Future<void> _refreshEmployeeProfile() async {
    final refreshed =
        await getSearchByEmployeeIdProfileByText(context, employeeId);
    if (!mounted) return;
    setState(() {
      _employeeProfileFuture = Future.value(refreshed);
    });
  }

  // ✅ NEW — single source of truth for tab navigation. Every tab button
  // (wide-row, narrow-row hamburger menu) now funnels through here instead
  // of each duplicating its own setState/animateToPage/saveIndex block.
  // This fixes the "fast-tab blink back to Dashboard" bug: previously the
  // PageView itself was swapped out for a CircularProgressIndicator while
  // _employeeProfileFuture was still resolving, so _pageController had NO
  // attached view and animateToPage() silently no-op'd. When the future
  // then resolved, FutureBuilder mounted a brand-new PageView which always
  // opened at page 0 (Dashboard) — while the appbar (GetX) had already
  // flipped to "Register" selected. Now the PageView stays permanently
  // mounted (see build() below), so _pageController.hasClients is always
  // true and animateToPage always actually moves the page.
  void _navigateToTab(int index) {
    setState(() {
      myController.selectButton(index);
      pgeControllerId = index;
    });
    _saveIndex(index);
    onPageChanged(index);
    if (_pageController.hasClients) {
      // ✅ NEW — easeInOutCubic reads as noticeably smoother/less linear
      // than Curves.ease for a page-width slide, and 400ms keeps it feeling
      // snappy rather than sluggish. This is the one place every tab
      // switch (forward taps, hamburger menu, and the back button) goes
      // through, so the smoothing applies everywhere consistently.
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Safety net only — shouldn't trigger now that PageView stays mounted,
      // but kept in case _pageController is ever recreated mid-frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) _pageController.jumpToPage(index);
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Detect taps outside the overlay to remove it
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            // ✅ FIX — was hardcoded `width: 180`, so the suggestion list
            // never matched the actual search box width once that box
            // started scaling with screen size (_wideSearchBarWidth /
            // _narrowSearchBarWidth, both clamped between ~140–320px).
            // Now it always mirrors whichever width the visible TextField
            // is currently using.
            width: _currentSearchBarWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: true,
              offset: const Offset(0.0, 40),
              child: Material(
                elevation: 4.0,
                child: _searchResults.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 150),
                          child: Text(
                            'No User Found!',
                            style: AllNoDataAvailable.customTextStyle(context),
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: _searchResults.length > 10
                              ? 400.0
                              : double.infinity,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ..._searchResults.map((result) => ListTile(
                                    title: Text(
                                      result,
                                      style: TextStyle(
                                        fontSize: FontSize.s14,
                                        fontWeight: FontWeight.w400,
                                        color: ColorManager.mediumgrey,
                                      ),
                                    ),
                                    onTap: data.isEmpty
                                        ? () {
                                            _controller.text = result;
                                            int id = 0;
                                            for (var e in data1) {
                                              if (result ==
                                                  e.firstName +
                                                      " " +
                                                      e.lastName) {
                                                id = e.employeeId;
                                              }
                                            }
                                            _removeOverlay();
                                            _selectEmployee(id, name: result);
                                          }
                                        : () {
                                            _controller.text = result;
                                            int id = 0;
                                            for (var e in data) {
                                              if (result ==
                                                  e.firstName +
                                                      " " +
                                                      e.lastName) {
                                                id = e.employeeId;
                                              }
                                            }
                                            _removeOverlay();
                                            _selectEmployee(id, name: result);
                                          },
                                  )),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _removeOverlay();
      return;
    }

    // Replace with your API endpoint
    if (searchSelect == false) {
      print("Search using Normal");
      print('search value ${searchSelect}');
      data = await getSearchProfileByText(context, query);
      _searchResults = data.map((e) => e.firstName + " " + e.lastName).toList();
      print(_searchResults);
    } else if (searchSelect == true) {
      print("Search using hanBurger");
      data1 = await firstResult;
      _searchResults =
          data1.map((e) => e.firstName + " " + e.lastName).toList();
      print(_searchResults);
    }
    _showOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  int selectedZoneId = 0;
  bool searchSelect = false;
  var firstResult;

  Future<void> _searchByFilter(
      {required int zoneId,
      required bool isZoneSelectedBool,
      required bool isReportingOffice,
      required String officeName,
      required bool isLicensesSelected,
      required String licenseStatusName,
      required bool isSelectAvailability,
      required String availabilityName}) async {
    final usrId = await TokenManager.getuserId();
    print('UserID:: ${usrId}');
    List<ApiDataFilter> result = await postSearchByFilter(
        context,
        false, // patientProfileSearch
        '', // profileName
        isReportingOffice, // officeLocationSearch
        officeName, // officeId
        isZoneSelectedBool, // zoneSearch
        zoneId, // zoneId
        isLicensesSelected, // licenseSearch
        licenseStatusName, // licenseStatus
        isSelectAvailability, // availabilitySearch
        availabilityName,
        isSelected,
        usrId) as List<ApiDataFilter>;
    print("Search : ${isSelected}");
    print('Search successful');

    setState(() {
      searchSelect = true;
      firstResult = result;
      print('search value ${searchSelect}');
    });
  }

  int employeeId = 0;
  int pgeControllerId = 0;
  String dropdownLicenseStatus = '';
  String dropdownAvailability = '';
  String reportingOfficeId = '';
  String? _selectedValue;
  String dropdownAbbrevation = '';
  bool isDropDownAbbreavation = false;
  bool isDropdownLicenseStatus = false;
  bool isDropdownAvailability = false;
  bool isReportingOfficeId = false;
  bool isZoneSelected = false;
  bool isSelectedBox = false;
  final ValueNotifier<bool> _isEditMode = ValueNotifier<bool>(false);

  // ── Back navigation — steps one tab to the left, in sync with the
  // hamburger/GetX index and the persisted index. See _onWillPop for the
  // Android hardware/gesture back handler, which now delegates here too.
  void _goBack() {
    if (pgeControllerId > 0) {
      _navigateToTab(pgeControllerId - 1);
    }
  }

  // FIX: previously each branch here called _pageController.animateToPage
  // and myController.selectButton directly, but never touched
  // pgeControllerId itself (except the `== 0` branch, which called
  // previousPage() without ever decrementing pgeControllerId at all). That
  // meant pgeControllerId very quickly went stale relative to the actual
  // visible page: pressing back from Onboarding (3) moved the PageView to
  // Register (2) but pgeControllerId stayed 3, so the *next* back press
  // read pgeControllerId==3 again and animated to Register a second time
  // instead of moving on to Manage — i.e. back-press N and N+1 landed on
  // the same page, and depending on timing it could look like the app
  // "automatically" jumped/re-triggered navigation on its own. It also
  // bypassed _navigateToTab entirely, so `_saveIndex`/`onPageChanged`
  // never ran on back-press, leaving the persisted index and the
  // PageIndexProvider out of sync with what was on screen.
  //
  // Now this is a single, symmetric rule that mirrors the forward
  // (_navigateToTab) path exactly: every back press moves exactly one tab
  // to the left through the one shared helper, so myController,
  // pgeControllerId, the saved index, and the PageIndexProvider are always
  // updated together and stay consistent no matter how fast the user taps.
  Future<bool> _onWillPop() async {
    if (pgeControllerId > 0) {
      _goBack();
      return false; // handled internally — just step back one tab
    }
    // ✅ NEW — already on Dashboard (tab 0), so there's nothing left to
    // step back through *inside* this screen. Previously `return true`
    // here handed control back to the platform/browser, which on Flutter
    // web means the browser's own back button just pops to whatever the
    // previous history entry happened to be (often outside the app, or a
    // blank/unexpected route) instead of a route this app actually owns.
    // Send the user to a known, named "/home" route instead, and swallow
    // the pop ourselves so the browser doesn't also try to navigate.
    _goToHomeRoute();
    return false;
  }

  // ── Explicit, smooth hand-off to the app's home route ───────────────────
  // Uses pushNamedAndRemoveUntil so the whole HR-module stack is cleared —
  // pressing back again from /home won't loop back into this screen — and
  // relies on the app's normal registered MaterialPageRoute transition for
  // "/home", which animates smoothly rather than snapping instantly.
  // If "/home" isn't registered in your route table, swap the string below
  // for whatever route name your app actually uses for the landing screen.
  void _goToHomeRoute() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  /// Referesh code
  @override
  void initState() {
    super.initState();
    _employeeProfileFuture =
        getSearchByEmployeeIdProfileByText(context, employeeId);
    _companyOfficeListFuture = getCompanyOfficeList(context);
    _payRateZoneFuture = PayRateZoneDropdown(context);

    // ✅ FIX: ButtonSelectionController is a Get.put() singleton that outlives
    // this screen's State — so if Register (index 2) or any non-Dashboard
    // tab was selected before a resize/rebuild recreated this State, the
    // fresh `_pageController` above always resets to page 0 while
    // myController.selectedIndex.value still says 2. That caused the appbar
    // (which reads myController.selectedIndex) to show "Register" selected
    // while the PageView (which reads _pageController) silently rendered
    // the Dashboard page underneath. Jump the new controller to match the
    // still-selected GetX index once the first frame is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedIndex = myController.selectedIndex.value;
      if (savedIndex != 0 && _pageController.hasClients) {
        _pageController.jumpToPage(savedIndex);
        pgeControllerId = savedIndex;
      }
    });
  }

  // ✅ NEW — fixes the "hot reload moves the appbar tab but not the page
  // below" bug. `initState` only runs once, when this State object is
  // first created; a hot reload that keeps this exact State alive never
  // re-enters `initState`, so the sync logic above never gets a second
  // chance to run. Meanwhile `myController.selectedIndex` is a Get.put()
  // singleton living outside the widget tree, so IT survives hot reload
  // completely untouched — it can end up pointing at a different tab than
  // whatever page `_pageController` (a plain State field) is still sitting
  // on. The appbar's `Obx` widgets read `myController.selectedIndex`
  // directly, so they immediately show the "moved" tab as selected, while
  // the PageView underneath — driven by `_pageController`, which nothing
  // told to move — stays put.
  //
  // `reassemble()` is a State lifecycle hook the framework calls
  // specifically (and only) on hot reload, which makes it the right place
  // to re-run this same reconciliation every time, not just on first
  // creation. It also runs `setState` (unlike the initState version) so
  // any other UI that depends on `pgeControllerId` — e.g. hiding the
  // search box on Register/Onboarding — updates immediately too, not just
  // the raw scroll position.
  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentIndex = myController.selectedIndex.value;
      if (_pageController.hasClients &&
          _pageController.page?.round() != currentIndex) {
        setState(() {
          pgeControllerId = currentIndex;
        });
        _pageController.jumpToPage(currentIndex);
      }
    });
  }

  void onPageChanged(int index) {
    Provider.of<PageIndexProvider>(context, listen: false).setIndex(index);
  }

  Future<void> _loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pgeControllerId = prefs.getInt('currentIndex') ?? 0;
      print('pageIndex ${pgeControllerId}');
      myController.selectButton(pgeControllerId);
      pageChanges(pgeControllerId);
    });
  }

  void pageChanges(int pageIndex) {
    _pageController.animateToPage(pgeControllerId,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  Future<void> _saveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', index);
  }

  // ── Hamburger menu ──────────────────────────────────────────────────────
  void _openMenu() {
    if (_menuOverlay != null) {
      _closeMenu();
      return;
    }

    final renderBox =
        _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final currentIndex = myController.selectedIndex.value;

    _menuOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Transparent barrier
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown menu
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_tabLabels.length, (i) {
                    final bool isSelectedTab = currentIndex == i;
                    return InkWell(
                      onTap: () {
                        _navigateToTab(i);
                        _closeMenu();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p16,
                          vertical: AppPadding.p10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelectedTab
                              ? ColorManager.blueprime.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: i == 0
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(AppSize.s8))
                              : i == _tabLabels.length - 1
                                  ? const BorderRadius.vertical(
                                      bottom: Radius.circular(AppSize.s8))
                                  : BorderRadius.zero,
                        ),
                        child: Text(
                          _tabLabels[i],
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            fontWeight: isSelectedTab
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelectedTab
                                ? ColorManager.blueprime
                                : ColorManager.darkgrey,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _closeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  @override
  void dispose() {
    _closeMenu();
    _removeOverlay();
    _controller.dispose();
    searchController.dispose();
    _isEditMode.dispose();
    super.dispose();
  }

  // ── Reusable filter dialog builder (used in both wide and narrow) ───────
  Widget _buildFilterDialog(
      BuildContext context, HrSearchProviderManager provider) {
    return ProfilePatientPopUp(
      officceIdWidget: FutureBuilder<List<CompanyOfficeListData>>(
        future: _companyOfficeListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 170,
              child: ClinicalConstDropDown(
                items: const [],
                initialValue:
                    reportingOfficeId == '' ? 'Select' : provider.officeText,
                onChanged: (newValue) {},
              ),
            );
          }
          if (snapshot.hasData) {
            List<DropdownMenuItem<String>> dropDownList = [];
            for (var i in snapshot.data!) {
              dropDownList.add(DropdownMenuItem<String>(
                child: Text(i.name,
                    style: SearchDropdownConst.customTextStyle(context)),
                value: i.name,
              ));
            }
            return Container(
              width: 170,
              child: ClinicalConstDropDown(
                dropDownMenuList: dropDownList,
                initialValue:
                    reportingOfficeId == '' ? 'Select' : provider.officeText,
                onChanged: (newValue) {
                  for (var a in snapshot.data!) {
                    if (a.name == newValue) {
                      provider.officeTextChange(changeText: a.name);
                      reportingOfficeId = a.name;
                      isReportingOfficeId = true;
                      print('Office Name : ${reportingOfficeId}');
                    }
                  }
                },
              ),
            );
          } else {
            return const Offstage();
          }
        },
      ),
      avabilityWidget: Row(
        children: [
          Container(
            width: 170,
            child: ClinicalConstDropDown(
              initialValue: provider.avalableStatus,
              items: const ['Full Time', 'Part Time', 'Per Diem'],
              onChanged: (value) {
                setState(() {
                  provider.avalableTextChange(changeText: value!);
                  dropdownAvailability = value!;
                  isDropdownAvailability = true;
                  print("Availability Status :: ${dropdownAvailability}");
                });
              },
            ),
          ),
        ],
      ),
      licensesWidget: Row(
        children: [
          Container(
            width: 170,
            child: ClinicalConstDropDown(
              initialValue: provider.expTypeValue,
              items: const ['Expired', 'About to Expire', 'Upto date'],
              onChanged: (value) {
                setState(() {
                  provider.expTypeTextChange(changeText: value!);
                  dropdownLicenseStatus = value!;
                  isDropdownLicenseStatus = true;
                  print("License Status :: ${dropdownLicenseStatus}");
                });
              },
            ),
          ),
        ],
      ),
      zoneDropDown: FutureBuilder<List<SortByZoneData>>(
        future: _payRateZoneFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 170,
              child: ClinicalConstDropDown(
                items: const [],
                initialValue: provider.zoneValue,
                onChanged: (newValue) {},
              ),
            );
          } else if (snapshot.hasData) {
            List<DropdownMenuItem<String>> dropDownList = [];
            int zoneId = 0;
            for (var i in snapshot.data!) {
              dropDownList.add(DropdownMenuItem<String>(
                child: Text(i.zoneName,
                    style: SearchDropdownConst.customTextStyle(context)),
                value: i.zoneName,
              ));
            }
            print("Zone: ");
            return Container(
              width: 170,
              child: ClinicalConstDropDown(
                dropDownMenuList: dropDownList,
                initialValue: provider.zoneValue,
                onChanged: (newValue) {
                  for (var a in snapshot.data!) {
                    if (a.zoneName == newValue) {
                      provider.zoneTextChange(changeText: a.zoneName);
                      zoneId = a.zoneId;
                      selectedZoneId = zoneId;
                      isZoneSelected = true;
                      print("Zone id :: ${selectedZoneId}");
                    }
                  }
                },
              ),
            );
          } else {
            return CustomDropdownTextField(
              headText: 'Zone',
              items: const ['No Data'],
            );
          }
        },
      ),
      isShown: (reportingOfficeId == '' &&
              dropdownLicenseStatus == '' &&
              dropdownAvailability == '' &&
              selectedZoneId == 0)
          ? false
          : true,
      onSearch: () {
        _searchByFilter(
            zoneId: selectedZoneId,
            isZoneSelectedBool: isZoneSelected,
            isReportingOffice: isReportingOfficeId,
            officeName: reportingOfficeId,
            isLicensesSelected: isDropdownLicenseStatus,
            licenseStatusName: dropdownLicenseStatus,
            isSelectAvailability: isDropdownAvailability,
            availabilityName: dropdownAvailability);
        // FIX: same PageController-recreation bug as _selectEmployee — now
        // that PageView stays permanently mounted, swapping in a fresh
        // PageController doesn't move the page. Use _navigateToTab(1).
        _navigateToTab(1);
      },
      clearFilter: (reportingOfficeId != '' ||
              dropdownLicenseStatus != '' ||
              dropdownAvailability != '' ||
              selectedZoneId != 0)
          ? CustomButtonTransparentSM(
              text: 'Clear',
              onPressed: () {
                provider.clearFilter();
                // Force UI update for dropdowns to show 'Select'
                provider.avalableTextChange(changeText: 'Select');
                provider.expTypeTextChange(changeText: 'Select');
                provider.officeTextChange(changeText: 'Select');
                provider.zoneTextChange(changeText: 'Select');
                setState(() {
                  // Reset all dropdown variables
                  dropdownLicenseStatus = '';
                  dropdownAvailability = '';
                  reportingOfficeId = '';
                  dropdownAbbrevation = '';
                  _selectedValue = null;
                  selectedZoneId = 0;

                  // Reset boolean visibility flags
                  isDropDownAbbreavation = false;
                  isDropdownLicenseStatus = false;
                  isDropdownAvailability = false;
                  isReportingOfficeId = false;
                  isZoneSelected = false;
                  isSelectedBox = false;

                  // Hide the Clear button
                  searchSelect = false;
                });
              },
            )
          : const SizedBox(height: AppSize.s30),
    );
  }


  /// ── App-bar search box ────────────────────────────────────────────────
  /// White, 1px #E8E8E8, 4px radius, a 14px magnifier 16px in from the left
  /// and the hint 16px after that. Sized by [kAppBarSearchWidth] /
  /// [kAppBarSearchHeight] so the app bar can reserve its slot.
  /// ── Compact tab selector ──────────────────────────────────────────────
  /// Shown instead of the five nav labels below
  /// [kAppBarNavCollapseBreakpoint], so the tabs never have to shrink or
  /// crowd the search box. Opens the same overlay menu as before via
  /// [_openMenu].
  Widget _buildCompactTabSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        key: _menuButtonKey,
        onTap: _openMenu,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu, size: 18, color: ColorManager.darkgrey),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  _tabLabels[myController.selectedIndex.value
                      .clamp(0, _tabLabels.length - 1)],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kAppBarAccent,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SvgPicture.asset(
                'images/sort_dropdown_arrow.svg',
                width: 10,
                height: 6,
                colorFilter:
                    const ColorFilter.mode(Color(0xFF6B7A85), BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarSearchField() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: kAppBarSearchWidth,
        height: kAppBarSearchHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'images/search_field_icon.svg',
              width: 14,
              height: 14,
              colorFilter:
                  const ColorFilter.mode(Color(0xFF585858), BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                onChanged: _search,
                decoration: const InputDecoration(
                  hintText: 'Search employees, documents…',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    height: 1.17,
                    fontWeight: FontWeight.w400,
                    color: Color(0x8A757575),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Read live width from MediaQuery — reacts to window resize ──────────
    final double screenWidth = MediaQuery.of(context).size.width;

    // ✅ The app bar now has ONE fixed-width search box, so the suggestion
    // overlay (built outside this method via _createOverlayEntry) just
    // matches it — no more wide/narrow split to keep in sync.
    _currentSearchBarWidth = kAppBarSearchWidth;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            ///log appbar
            ApplicationEmrAppBar(
              hideNameOnSmallScreen: true,
              shortHeadingText:
                  "HRM", // ✅ NEW — shown instead of full heading below 1200px
              isHrModule: true,
              headingText: "Human Resource Manager",

              /// Top-level nav — plain labels with a 3px accent bar under
              /// the active one, pinned to the bottom of the bar. On a
              /// window too narrow to hold all five beside the search box,
              /// they collapse to a dropdown rather than shrinking.
              body: [
                if (screenWidth < kAppBarNavCollapseBreakpoint)
                  _buildCompactTabSelector()
                else
                  AppBarNavRow(
                    items: [
                      for (final MapEntry<int, String> tab
                          in const <int, String>{
                        0: 'Dashboard',
                        1: 'Manage',
                        2: 'Register',
                        3: 'Onboarding',
                        4: 'Reports',
                      }.entries)
                        Obx(
                          () => AppBarNavItem(
                            label: tab.value,
                            isSelected:
                                myController.selectedIndex.value == tab.key,
                            onTap: () => _navigateToTab(tab.key),
                          ),
                        ),
                    ],
                  ),
              ],

              /// Global employee search — always present now, where the old
              /// bar only showed it on Dashboard/Manage.
              searchField: _buildAppBarSearchField(),
            ),

            ///page view
            // ✅ FIX: PageView is now permanently mounted for the lifetime of
            // this screen. Previously it lived INSIDE the FutureBuilder and
            // was replaced by a CircularProgressIndicator while
            // _employeeProfileFuture was resolving — during that window
            // _pageController had no attached view, so a fast tab-tap's
            // animateToPage() call silently no-op'd. When the future then
            // resolved, FutureBuilder mounted a brand-new PageView that
            // always opened at page 0 (Dashboard), leaving the GetX-driven
            // appbar tab and the actual visible page out of sync (the
            // "blink to Register then snap back to Dashboard" bug). Now the
            // FutureBuilder only wraps the Manage tab's *content*, so
            // _pageController.hasClients is always true and every tab
            // switch actually takes effect immediately.
            Expanded(
              flex: 8,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const DashBoardScreen(),
                  FutureBuilder<SearchByEmployeeIdProfileData>(
                      future: _employeeProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: ColorManager.blueprime,
                            ),
                          );
                        }
                        if (employeeId == 0) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'images/search_user_empty.png',
                                  width: AppSize.s400,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(
                                          width: AppSize.s400, height: 226),
                                ),
                                const SizedBox(height: AppSize.s20),
                                Text(
                                  "Use the search bar to search a user!",
                                  style: CustomTextStylesCommon.commonStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: FontSize.s14,
                                      color: const Color(0xff3E3B3B)),
                                ),
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          SearchByEmployeeIdProfileData
                              searchByEmployeeIdProfileData = snapshot.data!;
                          print(
                              "Employee ID:::${searchByEmployeeIdProfileData.employeeId!}");
                          int empID = searchByEmployeeIdProfileData.employeeId!;

                          return ManageScreen(
                            searchByEmployeeIdProfileData:
                                searchByEmployeeIdProfileData,
                            employeeId: empID,
                            pageManageController: _pageManageController,
                            // FIX: was `() { setState(() {}); }` — a no-op
                            // that never refetched the profile, so awaiting
                            // it in ManageScreen resolved instantly with
                            // stale data still cached. Now it actually
                            // refetches the employee profile and only
                            // resolves once fresh data is set.
                            onRefresh: _refreshEmployeeProfile,
                          );
                        }
                        return Container();
                      }),
                  RegisterScreen(
                    onRefresh: () {
                      myController.selectButton(2);
                    },
                    onBackPressed: () {
                      if (myController.selectedIndex.value == 2) {
                        _navigateToTab(myController.selectedIndex.value - 1);
                      }
                    },
                  ),
                  NewOnboardScreen(
                    onBackPressed: () {
                      if (myController.selectedIndex.value == 3) {
                        _navigateToTab(myController.selectedIndex.value - 1);
                      }
                    },
                  ),
                  // Report tab — placeholder until the feature is built.
                  const Center(
                    child: Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff3E3B3B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BottomBarRow(),
          ],
        ),
      ),
    );
  }
}
