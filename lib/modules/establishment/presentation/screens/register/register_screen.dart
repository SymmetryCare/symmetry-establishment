import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/main_register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/register_enroll_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/on_boarding_welcome.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/new_popup_with_upload_file.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_regster_status_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/user.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/add_employee/clinical_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/add_employee/clinical.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/register_data/main_register_screen_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/confirmation_constant.dart';

/// ── Register table metrics ──────────────────────────────────────────────
/// Taken straight off the 1920-wide design (table at x=67, width 1423).
/// The row is laid out as: a fixed leading gutter, three flexible columns,
/// then a fixed trailing block. The flex weights ARE the design's column
/// widths, so at the design width every column lands on its exact x and at
/// any other width Name/Role/Email share the slack proportionally.
const double _kHeaderHeight = 44;
const double _kRowHeight = 84;
const double _kRowGap = 10;
const double _kTableRadius = 10;
const double _kHeaderRadius = 8;
const Color _kHeaderBg = Color(0xFFE5F3F8);
const Color _kTableBorder = Color(0xFFE2E8F0);
const List<BoxShadow> _kTableShadow = <BoxShadow>[
  BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 2),
];

/// Leading block — 94 + 40 + 17 = 151, putting the avatar at x=162 and the
/// name at x=219 for a table starting at x=67.
const double _kAvatarGutter = 94;
const double _kAvatarSize = 40;
const double _kAvatarGap = 17;
const double _kLeadingWidth = _kAvatarGutter + _kAvatarSize + _kAvatarGap;

/// Flexible middle — Name 151→434, Role 434→644, Email 644→1140.
const int _kNameFlex = 283;
const int _kRoleFlex = 210;
const int _kEmailFlex = 496;

/// Trailing block — action pill, edit icon, delete icon, right margin.
const double _kActionPillWidth = 77;
const double _kActionPillHeight = 31;
const double _kPillToIconGap = 74;
/// Edit / delete hit target. Trimmed from the design's 40 — the buttons read
/// as heavy next to the 31px action pill at that size. [_kTrailingWidth]
/// derives from this, so the slack goes back to Name/Role/Email.
const double _kIconSize = 32;
const double _kIconGap = 15;
const double _kTableRightPad = 35;

const double _kTrailingWidth = _kActionPillWidth +
    _kPillToIconGap +
    _kIconSize +
    _kIconGap +
    _kIconSize +
    _kTableRightPad;

/// Page geometry: one centred content column, at most [_kTableMaxWidth]
/// wide, shared by the title/link + controls row AND the table. Sharing it
/// is what lines the search field / Sort / Create User up with the table's
/// right edge, and the title with its left. Pages too narrow for the cap
/// fill the width instead, keeping [_kTableMinSideInset] clear either side.
/// (The design's own table is 1423 wide; this keeps the action controls a
/// little closer to the Email column than the previous 1300px cap.)
const double _kTableMaxWidth = 1240;
const double _kTableMinSideInset = 40;

/// The design sets "Name" over the avatar gutter rather than over the name
/// text, and nudges "Role" 7px right of the role value.
const double _kHeaderNameX = 82;
const double _kHeaderRoleNudge = 7;

const TextStyle _kHeaderTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1E293B),
);
const TextStyle _kNameTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1E293B),
);
const TextStyle _kRoleTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: Color(0xFF0F172A),
);
const TextStyle _kEmailTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: Color(0xFF0F172A),
);
const TextStyle _kBadgeTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);
const TextStyle _kStatusRibbonTextStyle = TextStyle(
  fontSize: 10,
  height: 1.2,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);
const TextStyle _kActionPillTextStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: Colors.white,
);

/// ── Register table header ───────────────────────────────────────────────
/// Mirrors [_RegisterScreenState._buildUserRow]'s column geometry, so the
/// labels stay over their columns at every table width.
class _RegisterTableHeader extends StatelessWidget {
  const _RegisterTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _kHeaderHeight,
      margin: const EdgeInsets.only(bottom: _kRowGap),
      decoration: BoxDecoration(
        color: _kHeaderBg,
        borderRadius: BorderRadius.circular(_kHeaderRadius),
        boxShadow: _kTableShadow,
      ),
      child: const Row(
        children: [
          SizedBox(width: _kHeaderNameX),
          SizedBox(
            width: _kLeadingWidth - _kHeaderNameX,
            child: Text('Name', style: _kHeaderTextStyle),
          ),
          Expanded(flex: _kNameFlex, child: SizedBox()),
          Expanded(
            flex: _kRoleFlex,
            child: Padding(
              padding: EdgeInsets.only(left: _kHeaderRoleNudge),
              child: Text('Role', style: _kHeaderTextStyle),
            ),
          ),
          Expanded(
            flex: _kEmailFlex,
            child: Text('Email', style: _kHeaderTextStyle),
          ),
          SizedBox(width: _kTrailingWidth),
        ],
      ),
    );
  }
}

///saloni
class RegisterScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Function() onRefresh;

  const RegisterScreen({
    Key? key,
    required this.onRefresh,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  /// Single-line width of [text] in [style] — used by the header to decide
  /// whether the "to open this form" link still fits beside the buttons
  /// once it has wrapped onto two lines.
  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  /// ✅ Pagination + Search state
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  List<RegisterDataCompID> _latestUsers = [];
  int _latestTotalPages = 1;

  /// ✅ Controllers created once (not on every rebuild)
  /// register enroll user
  final TextEditingController newUserFirstNameController =
      TextEditingController();
  final TextEditingController newUserLastNameController =
      TextEditingController();
  final TextEditingController newUserEmailController = TextEditingController();
  final TextEditingController newUserPasswordController =
      TextEditingController();

  /// Enroll
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  /// Enroll
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Fetch ONCE, not on every rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HrRegisterProvider>(context, listen: false);
      provider.fetchData(context);
      provider.fetchDropdownData(context);
    });
  }

  /// ✅ Smooth page change: update page + glide the list back to the top
  void _goToPage(int page) {
    if (page < 1) page = 1;
    if (page > _latestTotalPages) page = _latestTotalPages;
    if (page == currentPage) return;
    setState(() => currentPage = page);
    if (_verticalScrollController.hasClients) {
      _verticalScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    newUserFirstNameController.dispose();
    newUserLastNameController.dispose();
    newUserEmailController.dispose();
    newUserPasswordController.dispose();
    phoneNumberController.dispose();
    positionController.dispose();
    userIdController.dispose();
    roleController.dispose();
    companyIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> displayTextMap = {
      'Sort': 'Sort',
      'Opened': 'Opened',
      'Notopen': 'Not Opened',
      'Partial': 'Partial',
      'Completed': 'Completed',
      'Inactive': 'In Active',
    };

    var baseUrl = html.window.location.origin;

    Future<void> showDeleteUserPopup(
      BuildContext context,
      RegisterDataCompID data,
    ) async {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ConfirmationPopup(
            title: 'Confirm Delete',
            containerText: 'Do you really want to delete this user?',
            onCancel: () {
              Navigator.pop(dialogContext);
            },
            onConfirm: () async {
              // NEW: print the record being deleted to console before calling the API
              print("=====================================");
              print("🗑️ ABOUT TO DELETE USER:");
              print("userId: ${data.userId}");
              print("firstName: ${data.firstName}");
              print("lastName: ${data.lastName}");
              print("email: ${data.email}");
              print("role: ${data.role}");
              print("status: ${data.status}");
              print("company_id: ${data.company_id}");
              print("employeeId: ${data.employeeId}");
              print("=====================================");

              try {
                // ✅ CALL DELETE API
                final response = await deleteUserApi(
                  context,
                  data.userId, // ✅ delete uses userId
                );

                print(
                    "🗑️ DELETE RESPONSE: statusCode=${response.statusCode}, success=${response.success}, message=${response.message}");

                if (response.success &&
                    (response.statusCode == 200 ||
                        response.statusCode == 201 ||
                        response.statusCode == 204)) {
                  await Provider.of<HrRegisterProvider>(
                    context,
                    listen: false,
                  ).fetchData(context);
                }
              } catch (e) {
                debugPrint('Delete failed: $e');
              } finally {
                // ✅ always close popup
                Navigator.pop(dialogContext);
              }
            },
          );
        },
      );
    }

    List<AEClinicalDiscipline> _aEClinicalDiscipline = [];

    /// ✅ FIX: the StreamBuilder now wraps BOTH the list AND the pagination
    /// bar. Before, the pagination widget sat outside the StreamBuilder, so
    /// when data arrived only the list rebuilt — the pagination bar kept its
    /// initial EMPTY items list and never showed working page buttons.
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F6F8),
      child: Consumer<HrRegisterProvider>(
          builder: (context, registerProvider, child) {
        return StreamBuilder<List<RegisterDataCompID>>(
          stream: registerProvider.registerStream,
          builder: (context, snapshot) {
            // cached data → spinner only on the very first load
            final List<RegisterDataCompID> users =
                snapshot.data ?? registerProvider.lastEmitted;
            final bool isFirstLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                    users.isEmpty;

            /// ✅ SEARCH filter
            final List<RegisterDataCompID> filteredUsers = _searchQuery.isEmpty
                ? users
                : users.where((d) {
                    final String fullName =
                        '${d.firstName} ${d.lastName}'.toLowerCase();
                    return fullName.contains(_searchQuery) ||
                        d.firstName.toLowerCase().contains(_searchQuery) ||
                        d.lastName.toLowerCase().contains(_searchQuery) ||
                        d.email.toLowerCase().contains(_searchQuery) ||
                        d.role.toLowerCase().contains(_searchQuery);
                  }).toList();

            /// ✅ PAGINATION logic — computed here so the pagination bar
            /// below ALWAYS rebuilds with fresh values
            _latestUsers = filteredUsers;
            _latestTotalPages = (filteredUsers.length / itemsPerPage).ceil();
            if (_latestTotalPages == 0) _latestTotalPages = 1;
            if (currentPage > _latestTotalPages) {
              currentPage = _latestTotalPages;
            }
            final int startIndex = (currentPage - 1) * itemsPerPage;
            final int endIndex =
                (startIndex + itemsPerPage) > filteredUsers.length
                    ? filteredUsers.length
                    : (startIndex + itemsPerPage);
            final List<RegisterDataCompID> paginatedUsers =
                filteredUsers.isEmpty
                    ? <RegisterDataCompID>[]
                    : filteredUsers.sublist(startIndex, endIndex);

            return LayoutBuilder(
              builder: (context, constraints) {
                const double minContentWidth = 1200;
                final double contentWidth =
                    constraints.maxWidth > minContentWidth
                        ? constraints.maxWidth
                        : minContentWidth;

                /// Centred content column: the cap wherever it fits, else
                /// whatever the page leaves inside the side insets. Every
                /// block below is padded by [sideInset], so they all share
                /// the same left and right edges.
                final double tableWidth = math.min(
                  contentWidth - (_kTableMinSideInset * 2),
                  _kTableMaxWidth,
                );
                final double sideInset = (contentWidth - tableWidth) / 2;

                /// ✅ Responsive header. Two stages, in this order:
                ///   1. the "To open this form click here : <link>" line
                ///      wraps onto a second line (handled by the Wrap
                ///      below — it needs no breakpoint);
                ///   2. only if the left column is still too narrow for
                ///      that wrapped link does the button group stack —
                ///      search on top, Sort + Create User underneath.
                /// So the widths are measured rather than guessed: the
                /// link's own label/URL decide when stage 2 kicks in.
                const double _kHeaderSideGap = 24;
                const double _kSearchWidth = 260;
                const double _kSortWidth = 150;
                const double _kCreateWidth = 160;
                // One-line button group: search + gap + sort + gap + create.
                const double _kButtonsRowWidth =
                    _kSearchWidth + 20 + _kSortWidth + 20 + _kCreateWidth;

                final String _linkLabel = ' To open this form click here :';
                final String _linkUrl =
                    '${baseUrl}/#${AppString.onboardingWelcome}';
                // Widest line the wrapped link can produce, plus the
                // TextButton's own horizontal padding.
                final double _linkLineWidth = math.max(
                  _measureTextWidth(_linkLabel,
                      DocumentTypeDataStyle.customLinkTextStyle(context)),
                  _measureTextWidth(_linkUrl,
                          RegisterLinkDataStyle.customTextStyle(context)) +
                      32,
                );
                final double _leftColumnWidth =
                    tableWidth - _kHeaderSideGap - _kButtonsRowWidth;
                final bool isCompactHeader = _leftColumnWidth < _linkLineWidth;

                final Widget searchField = Container(
                  height: 36,
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0x1F000000), width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'images/search_field_icon.svg',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: DocumentTypeDataStyle.customTextStyle(context),
                          cursorColor: ColorManager.granitegray,
                          decoration: const InputDecoration(
                            hintText: 'Search User',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              height: 1.23,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9EA8B0),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            // ✅ instant local filtering
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                              currentPage = 1;
                            });
                            // ✅ debounced API call
                            _searchDebounce?.cancel();
                            _searchDebounce = Timer(
                              const Duration(milliseconds: 400),
                              () {
                                if (!mounted) return;
                                registerProvider.searchRegister(context, value);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );

                final Widget sortDropdown = Column(
                  children: [
                    DropdownButton2<String>(
                      value: registerProvider.selectedValue,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == 'Sort') {
                            registerProvider.fetchData(context, 'Sort');
                          } else {
                            registerProvider.updateSelectedValue(newValue);
                          }
                          // ✅ reset to first page on filter change
                          setState(() {
                            currentPage = 1;
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9EA8B0),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SvgPicture.asset(
                            'images/sort_dropdown_arrow.svg',
                            width: 10,
                            height: 6,
                          ),
                        ),
                      ),
                      underline: const SizedBox(),
                      buttonStyleData: ButtonStyleData(
                        height: 36,
                        width: 122,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0x1F000000), width: 1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      selectedItemBuilder: (context) =>
                          displayTextMap.keys.map((String value) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(displayTextMap[value]!),
                        );
                      }).toList(),
                      dropdownStyleData: DropdownStyleData(
                        width: 160,
                        direction: DropdownDirection.left,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                      ),
                      items: displayTextMap.keys.map((String value) {
                        final bool isSelected =
                            value == registerProvider.selectedValue;
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            displayTextMap[value]!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? ColorManager.blueprime
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );

                final Widget createUserButton = Container(
                  height: 36,
                  width: 160,
                  child: CustomIconButton(
                    icon: Icons.add,
                    text: 'Create User',
                    textSize: FontSize.s15,
                    color: const Color(0xFF0B8CBF),
                    borderRadius: 24.0,
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogUploadefile(
                            title: "Create User",
                            lastNameController: newUserLastNameController,
                            emailController: newUserEmailController,
                            firstNameController: newUserFirstNameController,
                            passwordController: newUserPasswordController,
                            onCancel: () {
                              registerProvider.fetchData(context);
                            },
                          );
                        },
                      );
                    },
                    isNotPopUpButton: false,
                  ),
                );

                /// ✅ Column: scrollable content on top (Expanded),
                /// pagination FIXED at bottomCenter, outside the scroll views.
                return Column(
                  children: [
                    Expanded(
                      child: CustomScrollbar(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppPadding.p10),
                            child: SizedBox(
                              width: contentWidth,
                              child: ScrollConfiguration(
                                behavior:
                                    ScrollConfiguration.of(context).copyWith(
                                  scrollbars: false,
                                ),
                                child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),

                                      /// ✅ Header: title + form link on the
                                      /// left, search / sort / Create User on
                                      /// the right — one row, two columns, so
                                      /// the link sits right under the title
                                      /// instead of below the button row.
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: sideInset,
                                            vertical: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            /// ── Left column ──────────────
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Register',
                                                      style: BoxHeadingStyle
                                                              .customTextStyle(
                                                                  context)
                                                          .copyWith(
                                                              fontSize:
                                                                  FontSize.s24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                  const SizedBox(height: 6),
                                                  // ✅ Wrap, not Row: on narrow
                                                  // screens the URL drops onto a
                                                  // second line under the label
                                                  // instead of being clipped.
                                                  Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          ' To open this form click here :',
                                                          style: DocumentTypeDataStyle
                                                              .customLinkTextStyle(
                                                                  context)),
                                                      const SizedBox(width: 7),
                                                      TextButton(
                                                        onPressed: () async {
                                                          String url =
                                                              "${baseUrl}/#${AppString.onboardingWelcome}";
                                                          if (await canLaunch(
                                                              url)) {
                                                            await launch(url);
                                                          } else {
                                                            throw 'Could not launch $url';
                                                          }
                                                        },
                                                        child: Text(
                                                          '${baseUrl}/#${AppString.onboardingWelcome}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: RegisterLinkDataStyle
                                                              .customTextStyle(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 24),

                                            /// ── Right column ─────────────
                                            if (isCompactHeader)
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  searchField,
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      sortDropdown,
                                                      const SizedBox(width: 20),
                                                      createUserButton,
                                                    ],
                                                  ),
                                                ],
                                              )
                                            else
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  searchField,
                                                  const SizedBox(width: 20),
                                                  sortDropdown,
                                                  const SizedBox(width: 20),
                                                  createUserButton,
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),

                                      /// ✅ Table header row — column
                                      /// labels sit above the same column
                                      /// geometry the list items use, so the
                                      /// two stay aligned at any width.
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: sideInset),
                                        child: const _RegisterTableHeader(),
                                      ),

                                      /// ✅ Body: spinner on first load,
                                      /// message when empty, else the list
                                      if (isFirstLoading)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 150),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                color: ColorManager.blueprime),
                                          ),
                                        )
                                      else if (filteredUsers.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 150),
                                          child: Center(
                                            child: Text("No user available!",
                                                style: AllNoDataAvailable
                                                    .customTextStyle(context)),
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: sideInset),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: paginatedUsers.length,
                                            itemBuilder: (context, index) {
                                              final RegisterDataCompID data =
                                                  paginatedUsers[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: _kRowGap),
                                                child: _buildUserRow(
                                                  context: context,
                                                  data: data,
                                                  index: index,
                                                  registerProvider:
                                                      registerProvider,
                                                  onDelete: () =>
                                                      showDeleteUserPopup(
                                                          context, data),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// ✅ Pagination Controls — FIXED at bottomCenter,
                    /// OUTSIDE the scroll views, but INSIDE the
                    /// StreamBuilder so it rebuilds when data arrives.
                    if (!isFirstLoading && filteredUsers.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child: Center(
                          child: PaginationControlsWidget(
                            currentPage: currentPage,
                            items: _latestUsers,
                            itemsPerPage: itemsPerPage,
                            onPreviousPagePressed: () {
                              _goToPage(currentPage - 1);
                            },
                            onPageNumberPressed: (pageNumber) {
                              _goToPage(pageNumber);
                            },
                            onNextPagePressed: () {
                              _goToPage(currentPage + 1);
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      }),
    );
  }

  /// ── One register list item ─────────────────────────────────────────
  /// A 96px card whose columns use the fixed leading gutter / flexible
  /// middle / fixed trailing split described on [_kLeadingWidth], so the
  /// avatar, action pill and icons keep their design offsets while
  /// Name/Role/Email share the slack.
  Widget _buildUserRow({
    required BuildContext context,
    required RegisterDataCompID data,
    required int index,
    required HrRegisterProvider registerProvider,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: double.infinity,
      height: _kRowHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kTableRadius),
        border: Border.all(color: _kTableBorder, width: 1),
        boxShadow: _kTableShadow,
      ),
      child: ClipRRect(
        /// rounds the status ribbon off with the card's own corner
        borderRadius: BorderRadius.circular(_kTableRadius - 1),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  const SizedBox(width: _kAvatarGutter),
                  _buildAvatar(),
                  const SizedBox(width: _kAvatarGap),

                  /// name + gender/age badge
                  Expanded(
                    flex: _kNameFlex,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.firstName.capitalizeFirst ?? data.firstName}'
                          ' ${data.lastName.capitalizeFirst ?? data.lastName}',
                          style: _kNameTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // ⚠️ PLACEHOLDER — the API (/users/ByCompanyId)
                        // doesn't return gender/age, so this alternates a
                        // sample M/F and a fixed 44 per the design mock.
                        // Swap for real fields once the backend adds them.
                        _buildGenderAgeBadge(index),
                      ],
                    ),
                  ),

                  /// role / department
                  Expanded(
                    flex: _kRoleFlex,
                    child: Text(
                      data.role,
                      style: _kRoleTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// email — regular weight so name/role read as the bold
                  /// columns
                  Expanded(
                    flex: _kEmailFlex,
                    child: Text(
                      data.email,
                      style: _kEmailTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// action pill (Enroll / Activate / Onboard / Active) —
                  /// fixed slot even when empty so every row's columns line
                  /// up whether or not the row has a button
                  SizedBox(
                    width: _kActionPillWidth,
                    child:
                        _buildActionButton(context, data, registerProvider),
                  ),
                  const SizedBox(width: _kPillToIconGap),

                  /// edit
                  _circleActionButton(
                    assetPath: 'images/edit_pencil_icon.svg',
                    iconWidth: 14,
                    iconHeight: 14,
                    background: const Color(0x3BB8B8B8),
                    tooltip: 'Edit',
                    onTap: () =>
                        _openEnrollPopup(context, data, registerProvider),
                  ),
                  const SizedBox(width: _kIconGap),

                  /// delete
                  _circleActionButton(
                    assetPath: 'images/delete_trash_icon.svg',
                    iconWidth: 13,
                    iconHeight: 15,
                    background: const Color(0x3BFFD1D1),
                    tooltip: 'Delete',
                    onTap: onDelete,
                  ),
                  const SizedBox(width: _kTableRightPad),
                ],
              ),
            ),

            /// status ribbon in the card's top-left corner
            _buildStatusCornerLabel(data.status),
          ],
        ),
      ),
    );
  }

  /// ⚠️ PLACEHOLDER avatar — the API returns no photo, so this renders the
  /// design's 40×40 / r12 rounded square with a person glyph instead.
  Widget _buildAvatar() {
    return Container(
      width: _kAvatarSize,
      height: _kAvatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.person, size: 22, color: ColorManager.mediumgrey),
    );
  }

  /// 40px round icon button used for the row's edit / delete actions. The
  /// glyphs are SVGs carrying their own colour, so no colour filter here.
  Widget _circleActionButton({
    required String assetPath,
    required double iconWidth,
    required double iconHeight,
    required Color background,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: _kIconSize,
            height: _kIconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              assetPath,
              width: iconWidth,
              height: iconHeight,
            ),
          ),
        ),
      ),
    );
  }

  /// ⚠️ PLACEHOLDER gender/age badge — RegisterDataCompID has no gender/age
  /// field (the API doesn't return one), so this alternates a sample M/F
  /// by row index with a fixed age, purely to match the design mock.
  Widget _buildGenderAgeBadge(int index) {
    final bool isFemale = index.isOdd;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 19,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isFemale ? const Color(0x40E12BA7) : const Color(0x2E0B8CBF),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(isFemale ? 'F' : 'M', style: _kBadgeTextStyle),
        ),
        const SizedBox(width: 5),
        const Text('44', style: _kBadgeTextStyle),
      ],
    );
  }

  /// Status ribbon pinned to the card's top-left corner — the card's own
  /// ClipRRect rounds its outer corner to match.
  Widget _buildStatusCornerLabel(String status) {
    if (status.isEmpty) {
      return const SizedBox.shrink();
    }
    final Color bgColor = status == 'Opened'
        ? const Color(0xFF0B8CBF)
        : status == 'Partial'
            ? const Color(0xFFFC990E)
            : status == 'Completed'
                ? const Color(0xFF12A07A)
                : status == 'Inactive'
                    ? const Color(0xff6B7280)
                    : status == 'Notopen'
                        ? const Color(0xFFB1B1B1)
                        : status == 'Active'
                            ? const Color(0xFF12A07A)
                            : const Color(0xffC30404);
    final String label = status == 'Notopen'
        ? 'Not Opened'
        : status == 'Inactive'
            ? 'In Active'
            : status;
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        color: bgColor,
        child: Text(label, style: _kStatusRibbonTextStyle),
      ),
    );
  }

  /// A tappable 77×31 pill, used for Enroll / Activate / Onboard.
  Widget _pillButton(String text, Color color, Future<void> Function() onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: _kActionPillWidth,
          height: _kActionPillHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _kActionPillTextStyle,
          ),
        ),
      ),
    );
  }

  /// A non-interactive pill — same 77×31 box as [_pillButton], used for
  /// informational states (Active / Not open).
  Widget _staticPill(String text, Color color) {
    return Container(
      width: _kActionPillWidth,
      height: _kActionPillHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _kActionPillTextStyle,
      ),
    );
  }

  /// Opens the prefilled enroll / user-details popup. Shared by the row's
  /// Enroll pill and by its edit icon — the register API exposes no
  /// separate "update user" endpoint, so this form is the edit surface.
  void _openEnrollPopup(
    BuildContext context,
    RegisterDataCompID data,
    HrRegisterProvider registerProvider,
  ) {
      // FIX: compute the future once per button press instead of
      // inline inside the dialog's builder — the builder can be
      // re-invoked on rebuild, which was re-firing this API call.
      final Future<RegisterDataUserIDPrefill> prefillFuture =
          getRegisterEnrollPrefillUserId(context, data.userId);
      showDialog(
        context: context,
        builder: (_) => FutureBuilder<RegisterDataUserIDPrefill>(
            future: prefillFuture,
            builder: (context, snapshotPrefill) {
              Provider.of<HrEnrollEmployeeProvider>(context, listen: false)
                  .fetchDeptDropdownData(context, data.deptId ?? 0);
              Provider.of<HrEnrollEmployeeProvider>(context, listen: false)
                  .fetchZoneDropdown(context, 0);
              Provider.of<HrEnrollEmployeeProvider>(context, listen: false)
                  .fetchOfficeWiseCounty(context, ' ');
              if (snapshotPrefill.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      color: ColorManager.blueprime),
                );
              }
              var firstName = snapshotPrefill.data!.firstName.toString();
              firstNameController = TextEditingController(text: firstName);

              var lastName = snapshotPrefill.data!.lastName.toString();
              lastNameController = TextEditingController(text: lastName);

              var email = snapshotPrefill.data!.email.toString();
              emailController = TextEditingController(text: email);

              return RegisterEnrollPopup(
                employeeId: data.employeeId,
                employeeEnrollId: data.employeeEnrollId ?? 0,
                firstName: firstNameController,
                lastName: lastNameController,
                email: emailController,
                userId: snapshotPrefill.data!.userId,
                role: snapshotPrefill.data!.role,
                status: snapshotPrefill.data!.status,
                depId: snapshotPrefill.data!.departmentId ?? 0,
                cities: registerProvider.clinicalCities ?? [],
                companyOffices: registerProvider.companyOffices ?? [],
                zones: registerProvider.zone ?? [],
                onPressed: () {
                  Navigator.pop(context);
                },
                onReferesh: () {
                  registerProvider.fetchData(context);
                },
              );
            }),
      );
  }

  Widget _buildActionButton(
    BuildContext context,
    RegisterDataCompID data,
    HrRegisterProvider registerProvider,
  ) {
    if (data.status == 'Notopen') {
      return _pillButton(AppString.enroll, const Color(0xFF0B8CBF), () async {
        _openEnrollPopup(context, data, registerProvider);
      });
    }

    if (data.status == 'Partial') {
      return _pillButton('Activate', const Color(0xFF0BBF5F), () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationPopup(
                loadingDuration: registerProvider.load,
                onCancel: () {
                  Navigator.pop(context);
                },
                onConfirm: () async {
                  registerProvider.loaderTrue();

                  try {
                    var response =
                        await changeStatusUserPatch(context, data.employeeId);
                    registerProvider.fetchData(context);
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error during Onboarding: $e");
                  } finally {
                    registerProvider.loaderFalse();
                  }
                },
                title: 'Confirm Activation',
                containerText: 'Do you really want to complete?',
              );
            });
      });
    }

    if (data.status == 'Completed') {
      // ⚠️ ASSUMPTION: `isActive` (from the API) marks a Completed user who
      // has already been onboarded — shown as a static "Active" pill instead
      // of the actionable "Onboard" button. Flip this check if the real
      // semantics turn out to be reversed.
      if (data.isActive) {
        return _staticPill('Active', const Color(0xFF0BBF5F));
      }
      return _pillButton('Onboard', const Color(0xFF0B8CBF), () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationPopup(
                loadingDuration: registerProvider.load,
                onCancel: () {
                  Navigator.pop(context);
                },
                onConfirm: () async {
                  registerProvider.loaderTrue();
                  try {
                    var response =
                        await onboardingUserPatch(context, data.employeeId);
                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      registerProvider.fetchData(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print("Error during Onboarding: $e");
                  } finally {
                    registerProvider.loaderFalse();
                  }
                },
                title: 'Confirm Onboarding',
                containerText: 'Do you really want to onboard?',
              );
            });
      });
    }

    // ⚠️ ASSUMPTION: same `isActive` field — an Opened row that isn't active
    // yet shows a static "Not open" pill; once active, nothing shows here
    // (matches the reference rows where an Opened/active row has an empty
    // action slot).
    if (data.status == 'Opened' && !data.isActive) {
      return _staticPill('Not open', const Color(0xFFB1B1B1));
    }

    return const SizedBox.shrink();
  }
}

///
///
///
