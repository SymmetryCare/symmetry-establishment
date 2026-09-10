import 'dart:async';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/see_all_data/see_all_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/confirmation_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';

/// ── Onboarding table metrics ────────────────────────────────────────────
/// Taken straight off the 1920-wide design (table at x=67, width 1812).
/// A row is laid out as: a fixed leading block holding the tinted clinician
/// panel, then three flexible columns whose flex weights ARE the design's
/// column widths. At the design width every column lands on its exact x,
/// and at any other width the three share the slack proportionally.
const double _kHeaderHeight = 44;
const double _kRowHeight = 150;
const double _kRowGap = 17;
const double _kCardRadius = 21;
const double _kPanelRadius = 19;
const double _kHeaderRadius = 10;

const Color _kPageBg = Color(0xFFF3F6F8);
const Color _kHeaderBg = Color(0xFFE5F3F8);
const Color _kCardBorder = Color(0x12000000); // rgba(0, 0, 0, 0.07)
const Color _kDividerColor = Color(0x2B000000); // rgba(0, 0, 0, 0.17)
const List<BoxShadow> _kCardShadow = <BoxShadow>[
  BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 2),
];

/// Leading block — the tinted panel is 263 wide, inset 5 from the card's
/// left edge.
const double _kPanelInset = 5;
const double _kPanelWidth = 263;
const double _kLeadingWidth = _kPanelInset + _kPanelWidth; // 268
/// Minimum breathing room either side of the Contact & License block. The
/// block is centred in its column rather than pinned to a fixed left
/// indent: the design's indent left ~40px on its left and ~136px of dead
/// band on its right at a wide window, and no single indent can balance
/// both, since the slack shrinks to nothing as the table narrows. Centring
/// splits whatever slack exists evenly at every width, and this is just the
/// floor that keeps the block off the panel and the divider. The header
/// label is centred in the same padded box, so the two share a centre line.
const double _kContactMinGap = 16;

/// Flexible middle — Contact 268→688, Professional 688→1228 (divider at
/// 688), Additional 1228→1812 (divider at 1228), all relative to the card.
const int _kContactFlex = 420;
const int _kProfessionalFlex = 540;
const int _kAdditionalFlex = 584;

/// Column indents past their own divider, and the label→value split that
/// keeps every value in a column left-aligned with the one above it. The
/// splits are flex weights, not fixed widths, so a value column narrows
/// with its own column instead of being squeezed to nothing on a small
/// window (design: Professional labels 809→1043, Additional 1347→1556).
const double _kProfIndent = 54; // 809 - 755
const double _kAddlIndent = 52; // 1347 - 1295
const int _kProfLabelFlex = 234;
const int _kProfValueFlex = 239;
const int _kAddlLabelFlex = 209;
const int _kAddlValueFlex = 310;

/// Vertical rhythm inside a card: contact rows are 32 apart, label/value
/// rows 27, each row a [_kTextRowHeight] box.
const double _kContactRowPitch = 29;
const double _kFieldRowPitch = 25;
const double _kTextRowHeight = 15;
const double _kContactIconGap = 20; // 477 - 444 - 13 (icon)

/// Professional Details is the tallest column (5 label/value rows) and so
/// is what the card is sized around.
const double _kTallestColumnHeight =
    (5 * _kTextRowHeight) + (4 * (_kFieldRowPitch - _kTextRowHeight)); // 124

/// All three columns start this far down from the card's top edge — the
/// outer row stretches, so the inset is exact for all three and their first
/// rows share one line, the way the design lays the table out.
///
/// It is derived rather than hard-coded so the tallest column sits centred:
/// pinning it to a round number left Professional Details ending ~9px off
/// the card's bottom while carrying 30px above it, which read as the middle
/// column being shoved downwards. The shorter Contact and Additional Info
/// columns hang from the same line, as they do in the design.
const double _kColumnTopInset =
    (_kRowHeight - 2 - _kTallestColumnHeight) / 2; // ≈ 20

/// Trailing gutter inside a flexible column.
const double _kColumnRightPad = 12;

/// The Additional Info column's FIRST row sits level with the status ribbon
/// in the card's top-right corner — the centred [_kColumnTopInset] puts it
/// there — so that row's value reserves the ribbon's width and stops short
/// of it, instead of sliding underneath. Sized for the widest label
/// ("Completed") plus the ribbon's own padding.
const double _kRibbonReserve = 100;

/// The hairline that separates the flexible columns.
const double _kDividerHeight = 118;

/// Tinted panel interior — avatar, then name / role / gender-age stacked
/// beside it, with the employee id pinned to the panel's top-left corner.
const double _kAvatarSize = 58;
const double _kAvatarRadius = 14;
const double _kAvatarIndent = 23;
const double _kAvatarGap = 12;

/// The id chip hugs the panel's top-left corner. Left stays clear of the
/// panel's own 19px corner curve, which at this y has eaten ~4px.
const double _kIdChipLeft = 10;
const double _kIdChipTop = 8;

/// The avatar / name block is centred down the panel, then nudged this far
/// below centre so it sits clear of the id chip above it. It is applied as
/// top padding, and padding shifts a centred child by only half its value,
/// so the constant is doubled at the point of use.
const double _kPanelBlockDrop = 7;

/// Trailing overlay — the row's edit / delete icons, pinned bottom-right.
const double _kActionIconSize = 28;
const double _kActionIconGap = 12;
const double _kActionRightPad = 20;
const double _kActionBottomPad = 12;

/// The design sets "CLINICIAN" 34px in from the table's left edge, over the
/// tinted panel rather than over the clinician's name.
const double _kHeaderClinicianX = 34;

/// Page geometry: one centred content column, at most [_kTableMaxWidth]
/// wide, shared by the title + controls row AND the table. Sharing it is
/// what lines the search field / Sort up with the table's right edge and
/// the title with its left. Pages too narrow for the cap fill the width
/// instead, keeping [_kTableMinSideInset] clear either side. (The design's
/// own table is 1812 wide; this is tightened from that.)
const double _kTableMaxWidth = 1600;
const double _kTableMinSideInset = 40;

/// Page title. Built from the very same expression the Register screen uses
/// for its "Register" heading rather than restating 24/w800/#333333 here, so
/// the two sibling tabs' titles stay identical if either is ever restyled.
TextStyle _titleStyle(BuildContext context) =>
    BoxHeadingStyle.customTextStyle(context)
        .copyWith(fontSize: FontSize.s20, fontWeight: FontWeight.w800);
const TextStyle _kHeaderTextStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Color(0xFF14212B),
);
const TextStyle _kNameStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1E293B),
);
const TextStyle _kRoleStyle = TextStyle(
  fontSize: 8,
  height: 1.2,
  fontWeight: FontWeight.w400,
  color: Color(0xFF727272),
);
const TextStyle _kIdStyle = TextStyle(
  fontSize: 8,
  fontWeight: FontWeight.w400,
  color: Color(0xFF8A98A5),
);
const TextStyle _kBadgeStyle = TextStyle(
  fontSize: 10,
  height: 1.17,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);
const TextStyle _kRolePipStyle = TextStyle(
  fontSize: 8,
  height: 1.2,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);
const TextStyle _kContactStyle = TextStyle(
  fontSize: 11,
  height: 1.25,
  fontWeight: FontWeight.w400,
  color: Color(0xFF4B5563),
);
/// Field labels in the Professional Details and Additional Info columns.
/// Heavier than the design's w500 so they read as the titles of their rows
/// against the w400 values beside them.
const TextStyle _kLabelStyle = TextStyle(
  fontSize: 11,
  height: 1.17,
  fontWeight: FontWeight.w700,
  color: Color(0xFF0F172A),
);
const TextStyle _kValueStyle = TextStyle(
  fontSize: 11,
  height: 1.17,
  fontWeight: FontWeight.w400,
  color: Color(0xFF334155),
);
const TextStyle _kRibbonStyle = TextStyle(
  fontSize: 11,
  height: 1.2,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

/// The colour a clinician type paints: the pip under the avatar takes it at
/// full strength, the panel behind the whole leading block takes it at 11%.
class _ClinicianStyle {
  final String abbreviation;
  final Color color;

  const _ClinicianStyle(this.abbreviation, this.color);
}

/// Palette straight off the design — Physical Therapist salmon, Registered
/// Nurse lime, Occupational Therapist amber — extended with the remaining
/// disciplines the API returns.
const Map<String, _ClinicianStyle> _kClinicianStyles =
    <String, _ClinicianStyle>{
  'physical therapist': _ClinicianStyle('PT', Color(0xFFF6928A)),
  'physical therapist assistant': _ClinicianStyle('PTA', Color(0xFFF6928A)),
  'registered nurse': _ClinicianStyle('RN', Color(0xFFB4DB4C)),
  'licensed practical nurse': _ClinicianStyle('LPN', Color(0xFF7ECFA6)),
  'occupational therapist': _ClinicianStyle('OT', Color(0xFFFEBD4D)),
  'certified occupational therapy assistant':
      _ClinicianStyle('COTA', Color(0xFFFEBD4D)),
  'speech therapist': _ClinicianStyle('ST', Color(0xFF7CC6F0)),
  'speech language pathologist': _ClinicianStyle('SLP', Color(0xFF7CC6F0)),
  'medical social worker': _ClinicianStyle('MSW', Color(0xFFC9A0E9)),
  'home health aide': _ClinicianStyle('HHA', Color(0xFF8FB8E8)),
};

/// Fallback colours for a discipline the map above doesn't name — picked by
/// a hash of the type so the same title always paints the same colour.
const List<Color> _kFallbackClinicianColors = <Color>[
  Color(0xFFF6928A),
  Color(0xFFB4DB4C),
  Color(0xFFFEBD4D),
  Color(0xFF7CC6F0),
  Color(0xFFC9A0E9),
  Color(0xFF7ECFA6),
];

_ClinicianStyle _clinicianStyleFor(String? clinicianType) {
  final String type = (clinicianType ?? '').trim();
  if (type.isEmpty) {
    return const _ClinicianStyle('--', Color(0xFFB1B1B1));
  }
  final _ClinicianStyle? known = _kClinicianStyles[type.toLowerCase()];
  if (known != null) return known;

  // Initials of the first three words — "Wound Care Nurse" → "WCN".
  final List<String> words = type
      .split(RegExp(r'[\s/_-]+'))
      .where((String w) => w.isNotEmpty)
      .toList();
  final String abbreviation = words.isEmpty
      ? '--'
      : words
          .take(3)
          .map((String w) => w[0].toUpperCase())
          .join();
  final Color color = _kFallbackClinicianColors[
      type.toLowerCase().hashCode.abs() % _kFallbackClinicianColors.length];
  return _ClinicianStyle(abbreviation, color);
}

/// Status ribbon colours, shared with the Register screen so a person's
/// state reads the same on both tables.
Color _statusRibbonColor(String status) {
  switch (status) {
    case 'Opened':
    case 'Enrolled':
      return const Color(0xFF0B8CBF);
    case 'Partial':
      return const Color(0xFFFC990E);
    case 'Completed':
      return const Color(0xFF12A07A);
    default:
      return const Color(0xFFB1B1B1);
  }
}

/// 'M' / 'F' for the gender pip, '-' when the API returned nothing.
String _genderInitial(String? gender) {
  final String value = (gender ?? '').trim();
  if (value.isEmpty) return '-';
  return value[0].toUpperCase();
}

/// Age from the date of birth, or '--' when it can't be read. The API hands
/// back both ISO (`yyyy-MM-dd`) and dashed `dd-MM-yyyy` / `MM-dd-yyyy`
/// strings depending on the record, so both are tried.
String _ageFrom(String? dateOfBirth) {
  final DateTime? dob = _parseDate(dateOfBirth);
  if (dob == null) return '--';
  final DateTime now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month ||
      (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  if (age < 0 || age > 120) return '--';
  return '$age';
}

DateTime? _parseDate(String? raw) {
  final String value = (raw ?? '').trim();
  if (value.isEmpty) return null;

  final DateTime? iso = DateTime.tryParse(value);
  if (iso != null) return iso;

  final List<String> parts = value.split(RegExp(r'[-/]'));
  if (parts.length != 3) return null;
  final int? a = int.tryParse(parts[0]);
  final int? b = int.tryParse(parts[1]);
  final int? year = int.tryParse(parts[2]);
  if (a == null || b == null || year == null) return null;

  // dd-MM-yyyy unless the first field can't be a day, in which case the
  // string must be MM-dd-yyyy.
  final int day = a > 12 ? a : (b > 12 ? b : a);
  final int month = a > 12 ? b : (b > 12 ? a : b);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

String _orDash(String? value) {
  final String trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? '--' : trimmed;
}

/// A column label that always stays on one line. On a window narrow enough
/// to squeeze a column, the label runs a few pixels into the next column's
/// indent — which is empty at the header's height — rather than wrapping to
/// two lines and breaking the single-row header the design shows.
class _HeaderLabel extends StatelessWidget {
  final String text;

  const _HeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _kHeaderTextStyle,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
    );
  }
}

/// ── Onboarding table header ─────────────────────────────────────────────
/// Mirrors [_OnboardingRow]'s column geometry, so the labels stay over
/// their columns at every table width.
class _OnboardingTableHeader extends StatelessWidget {
  const _OnboardingTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _kHeaderHeight,
      margin: const EdgeInsets.only(bottom: _kRowGap),
      decoration: BoxDecoration(
        color: _kHeaderBg,
        borderRadius: BorderRadius.circular(_kHeaderRadius),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(width: _kHeaderClinicianX),
          SizedBox(
            width: _kLeadingWidth - _kHeaderClinicianX,
            child: _HeaderLabel('CLINICIAN'),
          ),
          Expanded(
            flex: _kContactFlex,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _kContactMinGap),
              child: Center(child: _HeaderLabel('CONTACT & LICENSE')),
            ),
          ),
          Expanded(
            flex: _kProfessionalFlex,
            child: Padding(
              padding: EdgeInsets.only(left: _kProfIndent),
              child: _HeaderLabel('PROFESSIONAL DETAILS'),
            ),
          ),
          Expanded(
            flex: _kAdditionalFlex,
            child: Padding(
              padding: EdgeInsets.only(left: _kAddlIndent),
              child: _HeaderLabel('ADDITIONAL INFO'),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingGeneral extends StatefulWidget {
  final void Function(int, int, String, String, int) selectButton;
  final VoidCallback goBackButtion;

  const OnboardingGeneral({
    Key? key,
    required this.selectButton,
    required this.goBackButtion,
  }) : super(key: key);

  @override
  State<OnboardingGeneral> createState() => _OnboardingGeneralState();
}

class _OnboardingGeneralState extends State<OnboardingGeneral> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final HrOnboardingProvider provider =
          Provider.of<HrOnboardingProvider>(context, listen: false);
      provider.setCurrentPage(1); // ← reset to page 1 on tab enter
      provider.getStreamData(context);
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Smooth page change: update the page, then glide the list back to top.
  void _goToPage(HrOnboardingProvider provider, int page, int totalPages) {
    if (page < 1 || page > totalPages || page == provider.currentPage) return;
    provider.setCurrentPage(page);
    if (_verticalScrollController.hasClients) {
      _verticalScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Deleting a person from Onboarding removes the same user record the
  /// Register screen's delete removes — both tables list the company's
  /// enrolled users — so it reuses that endpoint. Rows the API returned
  /// without a userID have nothing to delete, and just close the popup.
  Future<void> _showDeletePopup(SeeAllData general, String fullName) async {
    final HrOnboardingProvider provider =
        Provider.of<HrOnboardingProvider>(context, listen: false);
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationPopup(
          title: 'Confirm Delete',
          containerText:
              'Do you really want to delete ${fullName.trim().isEmpty ? 'this clinician' : fullName.trim()}?',
          onCancel: () => Navigator.pop(dialogContext),
          onConfirm: () async {
            final int? userId = general.userID;
            // The screen's own context, not the dialog's — the dialog is
            // popped in the finally below, and the list refresh has to
            // outlive it.
            final BuildContext screenContext = this.context;
            try {
              if (userId != null && userId != 0) {
                final response = await deleteUserApi(screenContext, userId);
                if (response.success && mounted) {
                  provider.getStreamData(screenContext);
                }
              }
            } catch (e) {
              debugPrint('Onboarding delete failed: $e');
            } finally {
              Navigator.pop(dialogContext);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> displayTextMap = <String, String>{
      'Sort': 'Sort',
      'Enrolled': 'Opened',
      'Partial': 'Partial',
      'Completed': 'Completed',
    };

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _kPageBg,
      child: Consumer<HrOnboardingProvider>(
        builder: (BuildContext context, HrOnboardingProvider onboardingState,
            Widget? child) {
          return StreamBuilder<List<SeeAllData>>(
            stream: onboardingState.generalController.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<SeeAllData>> snapshot) {
              final List<SeeAllData> clinicians =
                  snapshot.data ?? const <SeeAllData>[];
              final bool isFirstLoading =
                  snapshot.connectionState == ConnectionState.waiting &&
                      clinicians.isEmpty;

              final int totalPages =
                  math.max(1, (clinicians.length / _itemsPerPage).ceil());
              final int currentPage =
                  math.min(onboardingState.currentPage, totalPages);
              final int startIndex = (currentPage - 1) * _itemsPerPage;
              final int endIndex =
                  math.min(startIndex + _itemsPerPage, clinicians.length);
              final List<SeeAllData> paginated = clinicians.isEmpty
                  ? const <SeeAllData>[]
                  : clinicians.sublist(startIndex, endIndex);

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double minContentWidth = 1200;
                  final double contentWidth =
                      constraints.maxWidth > minContentWidth
                          ? constraints.maxWidth
                          : minContentWidth;

                  /// Centred content column: the cap wherever it fits, else
                  /// whatever the page leaves inside the side insets. Every
                  /// block below is padded by [sideInset], so the title, the
                  /// controls, the header and the rows share both edges.
                  final double tableWidth = math.min(
                    contentWidth - (_kTableMinSideInset * 2),
                    _kTableMaxWidth,
                  );
                  final double sideInset = (contentWidth - tableWidth) / 2;

                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: CustomScrollbar(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: contentWidth,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: false),
                                child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: sideInset,
                                      right: sideInset,
                                      top: 25,
                                      bottom: AppPadding.p10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        /// Title on the left, search + Sort
                                        /// on the right, both on the table's
                                        /// own edges.
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text('Onboarding',
                                                  style: _titleStyle(context)),
                                            ),
                                            const SizedBox(width: 24),
                                            _buildSearchField(
                                                context, onboardingState),
                                            const SizedBox(width: 12),
                                            _buildSortDropdown(context,
                                                onboardingState, displayTextMap),
                                          ],
                                        ),
                                        const SizedBox(height: 33),
                                        const _OnboardingTableHeader(),
                                        if (isFirstLoading)
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 150),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(
                                                color:
                                                    ColorManager.blueprime,
                                              ),
                                            ),
                                          )
                                        else if (clinicians.isEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 150),
                                            child: Center(
                                              child: Text(
                                                AppStringHRNoData
                                                    .noOnboardingData,
                                                style: AllNoDataAvailable
                                                    .customTextStyle(context),
                                              ),
                                            ),
                                          )
                                        else
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: paginated.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(
                                                    height: _kRowGap),
                                            itemBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              final SeeAllData general =
                                                  paginated[index];
                                              return _OnboardingRow(
                                                general: general,
                                                onOpen: () =>
                                                    widget.selectButton(
                                                  1,
                                                  general.empId ?? 0,
                                                  _fullNameOf(general),
                                                  general.imgurl ?? '',
                                                  general.deptId ?? 0,
                                                ),
                                                onDelete: () =>
                                                    _showDeletePopup(
                                                  general,
                                                  _fullNameOf(general),
                                                ),
                                              );
                                            },
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

                      /// Pagination — fixed at the bottom, outside the
                      /// scroll views but inside the StreamBuilder so it
                      /// rebuilds when data arrives.
                      if (!isFirstLoading && clinicians.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: PaginationControlsWidget(
                              currentPage: currentPage,
                              items: clinicians,
                              itemsPerPage: _itemsPerPage,
                              onPreviousPagePressed: () => _goToPage(
                                  onboardingState,
                                  currentPage - 1,
                                  totalPages),
                              onPageNumberPressed: (int page) => _goToPage(
                                  onboardingState, page, totalPages),
                              onNextPagePressed: () => _goToPage(
                                  onboardingState,
                                  currentPage + 1,
                                  totalPages),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 200×36 pill — white, hairline border, 50px radius.
  Widget _buildSearchField(
      BuildContext context, HrOnboardingProvider onboardingState) {
    return Container(
      height: 36,
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x1F000000), width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset('images/search_field_icon.svg',
              width: 14, height: 14),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: DocumentTypeDataStyle.customTextStyle(context),
              cursorColor: ColorManager.granitegray,
              decoration: const InputDecoration(
                hintText: 'Search Employee',
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
              onChanged: (String value) {
                // The provider debounces this and re-queries the API.
                onboardingState.searchData(context, value);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 122×36 pill matching the search field, with the design's chevron.
  Widget _buildSortDropdown(
    BuildContext context,
    HrOnboardingProvider onboardingState,
    Map<String, String> displayTextMap,
  ) {
    return DropdownButton2<String>(
      value: onboardingState.selectedValue,
      onChanged: (String? newValue) {
        if (newValue == null) return;
        onboardingState.sortData(newValue);
        onboardingState.setCurrentPage(1);
      },
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9EA8B0),
      ),
      iconStyleData: IconStyleData(
        icon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: SvgPicture.asset('images/sort_dropdown_arrow.svg',
              width: 10, height: 6),
        ),
      ),
      underline: const SizedBox(),
      buttonStyleData: ButtonStyleData(
        height: 36,
        width: 122,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0x1F000000), width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      selectedItemBuilder: (BuildContext context) =>
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
        final bool isSelected = value == onboardingState.selectedValue;
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            displayTextMap[value]!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? ColorManager.blueprime : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fullNameOf(SeeAllData general) =>
      '${general.firstName?.capitalizeFirst ?? ''} '
      '${general.lastName?.capitalizeFirst ?? ''}';
}

/// ── One onboarding list item ────────────────────────────────────────────
/// A 183px card: a tinted clinician panel down the left, then Contact &
/// License / Professional Details / Additional Info split by 148px
/// hairlines, with the status ribbon in the top-right corner and the
/// edit / delete actions in the bottom-right.
class _OnboardingRow extends StatelessWidget {
  final SeeAllData general;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _OnboardingRow({
    required this.general,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String displayStatus = general.status == 'Enrolled'
        ? 'Opened'
        : _orDash(general.status);
    final _ClinicianStyle clinician =
        _clinicianStyleFor(general.employeeType ?? general.position);

    return Container(
      width: double.infinity,
      height: _kRowHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kCardBorder, width: 1),
        boxShadow: _kCardShadow,
      ),
      child: ClipRRect(
        /// rounds the status ribbon off with the card's own corner
        borderRadius: BorderRadius.circular(_kCardRadius - 1),
        child: Stack(
          children: <Widget>[
            /// The whole card opens the clinician's onboarding forms, the
            /// same as the pencil does.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpen,
                  child: Row(
                    // stretch, NOT the default centre: centring sizes each
                    // column to its own content and then centres that, so
                    // the three columns (4, 5 and 4 rows) each started at a
                    // different y and left dead space above them all. With
                    // stretch every column fills the card's height and its
                    // own [_kColumnTopInset] padding puts all three first
                    // rows on one line.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildClinicianPanel(clinician),
                      Expanded(
                        flex: _kContactFlex,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: _kContactMinGap,
                            right: _kContactMinGap,
                            top: _kColumnTopInset,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _buildContactColumn(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: _kProfessionalFlex,
                        child: _buildDividedColumn(
                          indent: _kProfIndent,
                          child: _buildFieldColumn(
                            labelFlex: _kProfLabelFlex,
                            valueFlex: _kProfValueFlex,
                            fields: <List<String>>[
                              <String>[
                                'Social Security No.',
                                _orDash(general.ssnnbr)
                              ],
                              <String>[
                                'Clinician Type',
                                _orDash(general.employeeType)
                              ],
                              <String>[
                                'Speciality',
                                _orDash(general.expertise)
                              ],
                              <String>[
                                'Employment',
                                _orDash(general.employment)
                              ],
                              <String>['Service', _orDash(general.service)],
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: _kAdditionalFlex,
                        child: _buildDividedColumn(
                          indent: _kAddlIndent,
                          child: _buildFieldColumn(
                            labelFlex: _kAddlLabelFlex,
                            valueFlex: _kAddlValueFlex,
                            firstRowValueInset: _kRibbonReserve,
                            fields: <List<String>>[
                              <String>[
                                'Personal Email',
                                _orDash(general.personalEmail)
                              ],
                              <String>['Zone', _orDash(general.zone)],
                              <String>[
                                'Date of Birth',
                                _orDash(general.dateOfBirth)
                              ],
                              <String>['Race', _orDash(general.race)],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// status ribbon, top-right corner
            _buildStatusRibbon(displayStatus),

            /// edit / delete, bottom-right corner
            Positioned(
              right: _kActionRightPad,
              bottom: _kActionBottomPad,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _circleActionButton(
                    assetPath: 'images/edit_pencil_icon.svg',
                    iconWidth: 13,
                    iconHeight: 13,
                    background: const Color(0x3BB8B8B8),
                    tooltip: 'Edit',
                    onTap: onOpen,
                  ),
                  const SizedBox(width: _kActionIconGap),
                  _circleActionButton(
                    assetPath: 'images/delete_trash_icon.svg',
                    iconWidth: 12,
                    iconHeight: 14,
                    background: const Color(0x3BFFD1D1),
                    tooltip: 'Delete',
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tinted 263-wide panel: employee id pinned top-left, then the avatar
  /// beside the name / discipline / gender-age stack.
  Widget _buildClinicianPanel(_ClinicianStyle clinician) {
    final String employeeId = (general.code ?? '').trim().isNotEmpty
        ? general.code!.trim()
        : (general.empId?.toString() ?? '--');

    return Padding(
      padding: const EdgeInsets.only(
          left: _kPanelInset, top: _kPanelInset, bottom: _kPanelInset - 1),
      child: SizedBox(
        width: _kPanelWidth,
        child: Container(
          decoration: BoxDecoration(
            color: clinician.color.withValues(alpha: 0.11),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_kPanelRadius),
              bottomLeft: Radius.circular(_kPanelRadius),
            ),
          ),
          child: Stack(
            children: <Widget>[
              /// Employee id on its own white rounded chip, so it reads
              /// against whichever discipline tint the panel is wearing.
              Positioned(
                left: _kIdChipLeft,
                top: _kIdChipTop,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('ID: #$employeeId', style: _kIdStyle),
                ),
              ),
              /// Positioned.fill, not a bare child: a Stack hands loose
              /// constraints to its non-positioned children, so the Row
              /// would shrink-wrap to the top of the panel instead of
              /// centring the avatar / name block down its height.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: _kAvatarIndent,
                      right: 8,
                      top: _kPanelBlockDrop * 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildAvatar(clinician),
                      const SizedBox(width: _kAvatarGap),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _fullName,
                              style: _kNameStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _orDash(general.employeeType),
                              style: _kRoleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            _buildGenderAgeBadge(),
                          ],
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
    );
  }

  /// 68px rounded-square photo with the discipline pip on its bottom-right.
  Widget _buildAvatar(_ClinicianStyle clinician) {
    return SizedBox(
      width: _kAvatarSize,
      height: _kAvatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kAvatarRadius),
              child: _buildAvatarImage(),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: clinician.color,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(clinician.abbreviation, style: _kRolePipStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    final String? url = general.imgurl;
    if (url == null || url.isEmpty || url == 'imgurl') {
      return _fallbackAvatar();
    }
    return Image.network(
      url,
      width: _kAvatarSize,
      height: _kAvatarSize,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: ColorManager.faintGrey,
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ColorManager.blueprime,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _fallbackAvatar(),
    );
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      'images/profilepic.png',
      width: _kAvatarSize,
      height: _kAvatarSize,
      fit: BoxFit.cover,
    );
  }

  /// Gender pip + age, per the design: a translucent white box so the
  /// panel's tint shows through, then the age beside it.
  Widget _buildGenderAgeBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 17,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x40FFFFFF),
            border: Border.all(color: const Color(0x21000000), width: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(_genderInitial(general.gender), style: _kBadgeStyle),
        ),
        const SizedBox(width: 5),
        Text(_ageFrom(general.dateOfBirth), style: _kBadgeStyle),
      ],
    );
  }

  /// Phone / email / licence / location, each 32px below the last.
  Widget _buildContactColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _contactRow(Icons.phone_outlined, _orDash(general.primaryPhoneNbr)),
        const SizedBox(height: _kContactRowPitch - _kTextRowHeight),
        _contactRow(Icons.mail_outline,
            _orDash(general.workEmail ?? general.personalEmail)),
        const SizedBox(height: _kContactRowPitch - _kTextRowHeight),
        _contactRow(
            Icons.badge_outlined, _orDash(general.driverLicenseNum)),
        const SizedBox(height: _kContactRowPitch - _kTextRowHeight),
        _contactRow(
          Icons.location_on_outlined,
          _orDash(general.city ?? general.finalAddress),
        ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return SizedBox(
      height: _kTextRowHeight,
      // MainAxisSize.min + Flexible, not Expanded: Expanded stretched every
      // row to the column's full width, which made the whole block as wide
      // as the column and left nothing to centre. Sizing each row to its
      // own content lets the column shrink-wrap to its widest row so the
      // block can be centred, while Flexible still bounds a long email so
      // it ellipsises rather than overflowing.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: _kContactIconGap),
          Flexible(
            child: Tooltip(
              message: value,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                value,
                style: _kContactStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A flexible column preceded by the hairline that separates it from the
  /// one before, keeping the content on its design x. [rightInset] is the
  /// trailing gutter — the Additional Info column passes a wide one to keep
  /// clear of the status ribbon overhead.
  Widget _buildDividedColumn({
    required double indent,
    required Widget child,
    double rightInset = _kColumnRightPad,
  }) {
    return Row(
      // stretch for the same reason as the outer row: centred, this row
      // would size the column to its own content and centre that, so the
      // 5-row Professional and 4-row Additional columns each drifted down
      // by a different amount instead of starting on the Contact column's
      // line. Stretch makes [_kColumnTopInset] the real offset for both.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 1,
          child: Center(
            child: Container(
              width: 1,
              height: _kDividerHeight,
              color: _kDividerColor,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                left: indent - 1, top: _kColumnTopInset, right: rightInset),
            child: child,
          ),
        ),
      ],
    );
  }

  /// label / value pairs, each 27px below the last, with the values sharing
  /// one left edge courtesy of the fixed [labelFlex] / [valueFlex] split.
  ///
  /// [firstRowValueInset] shortens only the FIRST row's value. Just that row
  /// sits level with the status ribbon, so insetting the whole column would
  /// squeeze all four rows (and start ellipsising the labels) to solve a
  /// one-row problem. Applying it inside the value's own flex slot also
  /// leaves every value's left edge where it was, so the column still reads
  /// as one aligned block.
  Widget _buildFieldColumn({
    required int labelFlex,
    required int valueFlex,
    required List<List<String>> fields,
    double firstRowValueInset = 0,
  }) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < fields.length; i++) {
      if (i > 0) {
        rows.add(const SizedBox(height: _kFieldRowPitch - _kTextRowHeight));
      }
      rows.add(SizedBox(
        height: _kTextRowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: labelFlex,
              child: Text(
                fields[i][0],
                style: _kLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: valueFlex,
              child: Padding(
                padding: EdgeInsets.only(
                    right: i == 0 ? firstRowValueInset : 0),
                child: Tooltip(
                  message: fields[i][1],
                  waitDuration: const Duration(milliseconds: 400),
                  child: Text(
                    fields[i][1],
                    style: _kValueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  /// Status ribbon filling the card's top-right corner: flush against the
  /// top and right edges, square along its bottom and left, with only the
  /// outer corner rounded — and that rounding comes from the card's own
  /// ClipRRect, so the ribbon carries no radius of its own.
  Widget _buildStatusRibbon(String status) {
    if (status == '--') return const SizedBox.shrink();
    return Positioned(
      top: 0,
      right: 0,
      // No `alignment:` on the Container: giving one both a child AND an
      // alignment makes it expand to fill whatever bounded space its
      // parent offers instead of hugging the child, which painted its
      // colour over the whole card. Without it the ribbon sizes to its own
      // label — "Opened" narrower than "Completed".
      child: Container(
        color: _statusRibbonColor(status),
        padding: const EdgeInsets.only(
            left: 18, right: 18, top: 7, bottom: 7),
        child: Text(status, style: _kRibbonStyle),
      ),
    );
  }

  /// Round icon button used for the row's edit / delete actions. The glyphs
  /// are SVGs carrying their own colour, so no colour filter here.
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
        color: background,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _kActionIconSize,
            height: _kActionIconSize,
            child: Center(
              child: SvgPicture.asset(
                assetPath,
                width: iconWidth,
                height: iconHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _fullName =>
      '${general.firstName?.capitalizeFirst ?? ''} '
      '${general.lastName?.capitalizeFirst ?? ''}'
          .trim();
}
