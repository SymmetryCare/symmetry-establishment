import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_establishment/app/services/shell/shell_link.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_establishment/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_clickable_widget.dart';

import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_establishment/services/device_notification_service.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/company_logo_widget.dart';
import 'package:symmetry_establishment/main.dart'; // ✅ gives access to global navigatorKey

/// Where to send the user once the session has been cleared.
///
/// Standalone, that is Establishment's own login screen — unchanged.
/// Shell-hosted, the login screen belongs to the shell, and pushing
/// Establishment's copy would strand the user on a second login form at
/// `/establishment/` that the module picker is never reached from. The four
/// logout branches below all end here so the two shapes cannot drift apart.
void _afterSignOut(BuildContext context) {
  if (ShellLink.isHosted) {
    ShellLink.signOutRedirect();
    return;
  }
  Navigator.pushNamedAndRemoveUntil(
    context,
    LoginScreen.routeName,
    (route) => false,
  );
}

/// ✅ NEW — shared guard so a null/empty/literal-"null" value never
/// renders as visible text in the UI. Use everywhere a nullable
/// display string (username, first name, last name, etc.) is shown.
String displayOrEmpty(String? value) {
  if (value == null) return '';
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
  return value;
}

/// ── App bar metrics ─────────────────────────────────────────────────────
/// Taken off the 1920-wide design. The bar is a fixed 78px white strip laid
/// out as: logo, divider, module selector, the centred nav, then the right
/// cluster (search, bell, divider, user). Everything but the nav keeps its
/// design offsets; the nav gets the slack.
const double kAppBarHeight = 58;

/// Below this the bar scrolls sideways instead of squeezing the nav. It no
/// longer matches the page content's own 1200 floor — the bar got small
/// enough to keep its full geometry further down, and the two scroll
/// independently anyway.
///
/// Measured, not estimated: the five 14px labels lay out to 426.4px, and the
/// fixed clusters are 281.5 (left) + 332 (right, name hidden) — so the nav
/// stops fitting at 1040. This leaves ~20px of headroom for font fallback.
const double kAppBarMinWidth = 1060;

const double _kLogoLeftInset = 15;
const double _kLogoWidth = 132;
const double _kLogoHeight = 41;
const double _kLogoToDividerGap = 11;
const double _kLeftDividerHeight = 23;
const double _kDividerToModuleGap = 5;

// 118 in symmetry-hr, where the label is the 9-character "HR Module".
// "Establishment" is 13 and ellipsised to "Establish..." at that width,
// so the box is widened here rather than the module abbreviated.
const double _kModuleBoxWidth = 146;
const double _kModuleBoxHeight = 30;
const double _kModuleIconInset = 9;
const double _kModuleIconSize = 16;
const double _kModuleIconToLabelGap = 7;
const double _kModuleChevronInset = 9;

/// Global search box. The design draws it 292x40; trimmed down here.
const double kAppBarSearchWidth = 200;
const double kAppBarSearchHeight = 32;

const double _kSearchToBellGap = 13;
const double _kBellSize = 17;
const double _kBellToDividerGap = 10;
const double _kRightDividerHeight = 38;
const double _kDividerToUserGap = 10;
const double _kAppBarRightInset = 19;

/// The user cluster: the avatar, the two-line name block, then a chevron.
const double _kUserAvatarSize = 32;
const double _kUserAvatarToNameGap = 9;
/// The design sizes this block to exactly fit "Skylar Calzoni" (90px),
/// which clips most real names. Widened — but kept FIXED rather than
/// content-sized, because anything variable in here would move the nav.
const double _kUserNameWidth = 112;
const double _kUserNameToChevronGap = 11;
const double _kUserChevronSize = 11;

/// Nav item: the active underline overhangs its label by [_kNavItemPad]
/// either side (the design draws an 86px bar under a 61px "Register"), so
/// the label carries that as padding and the items sit [_kNavItemGap] apart.
/// Everything to the right of the nav lives in a slot of this fixed width.
/// Reserving it is what stops the nav from shifting when the user's name is
/// hidden on a narrow window — the contents just right-align inside it.
const double _kUserClusterWidth = _kUserAvatarSize +
    _kUserAvatarToNameGap +
    _kUserNameWidth +
    _kUserNameToChevronGap +
    _kUserChevronSize;
const double _kRightClusterWidth = kAppBarSearchWidth +
    _kSearchToBellGap +
    (_kBellSize + 8) +
    _kBellToDividerGap +
    1 +
    _kDividerToUserGap +
    _kUserClusterWidth +
    _kAppBarRightInset;

/// With the name block collapsed the cluster gives that width back to the
/// nav, which is what keeps all five tabs full-size on a narrower window.
const double _kRightClusterWidthCompact =
    _kRightClusterWidth - _kUserNameWidth - _kUserAvatarToNameGap;

/// Below this the user's name collapses to just the avatar + chevron. Both
/// [EmrAppBar] (to size the cluster) and [UserAppBarWidgetEmr] (to draw it)
/// read this, so the two always agree.
const double kAppBarNameHideBreakpoint = 1180;

/// Below this there isn't room for the full nav beside the search box, so
/// the caller should hand [EmrAppBar.body] a compact dropdown selector
/// instead of the five labels. The tabs are never scaled down — they are
/// either drawn at full size or swapped for the dropdown.
const double kAppBarNavCollapseBreakpoint = 1060;

const double _kNavLabelTop = 22;
const double _kNavItemPad = 10;
const double _kNavItemGap = 9;
const double _kNavUnderlineHeight = 3;
const double _kNavUnderlineBottom = 2;

const Color kAppBarAccent = Color(0xFF008ABD);
const Color _kNavIdleColor = Color(0xFF848484);
const Color _kModuleLabelColor = Color(0xFF4B4B4B);
const Color _kIconGrey = Color(0xFF585858);

const TextStyle _kNavTextStyle = TextStyle(
  fontSize: 14,
  height: 1.19,
  fontWeight: FontWeight.w400,
  color: _kNavIdleColor,
  decoration: TextDecoration.none,
);
const TextStyle _kModuleLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: _kModuleLabelColor,
  decoration: TextDecoration.none,
);
const TextStyle _kUserNameStyle = TextStyle(
  fontSize: 13,
  height: 1.21,
  fontWeight: FontWeight.w600,
  color: Colors.black,
  decoration: TextDecoration.none,
);
const TextStyle _kUserRoleStyle = TextStyle(
  fontSize: 10,
  height: 1.2,
  fontWeight: FontWeight.w300,
  color: Color(0xFF747474),
  decoration: TextDecoration.none,
);

/// A hairline vertical rule — used beside the logo and beside the bell.
class _AppBarDivider extends StatelessWidget {
  const _AppBarDivider({
    required this.height,
    required this.color,
    this.thickness = 1,
  });

  final double height;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(width: thickness, height: height, color: color);
  }
}

/// The module selector pill — grid glyph, label, chevron.
class _ModuleSelector extends StatelessWidget {
  const _ModuleSelector({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: _kModuleBoxWidth,
        height: _kModuleBoxHeight,
        decoration: BoxDecoration(
          color: const Color(0x0D2563EB),
          border: Border.all(color: const Color(0x0D000000), width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const SizedBox(width: _kModuleIconInset),
            SvgPicture.asset(
              'images/module_grid_icon.svg',
              width: _kModuleIconSize,
              height: _kModuleIconSize,
            ),
            const SizedBox(width: _kModuleIconToLabelGap),
            Expanded(
              child: Text(
                label,
                style: _kModuleLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SvgPicture.asset(
              'images/sort_dropdown_arrow.svg',
              width: 8,
              height: 4,
              colorFilter:
                  const ColorFilter.mode(Color(0xCF000000), BlendMode.srcIn),
            ),
            const SizedBox(width: _kModuleChevronInset),
          ],
        ),
      ),
    );
  }
}

/// Bell with the design's 6px unread dot.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: _kBellSize + 8,
        height: _kBellSize + 8,
        child: Center(
          child: SizedBox(
            width: _kBellSize,
            height: _kBellSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    'images/notification_bell.svg',
                    width: _kBellSize,
                    height: _kBellSize,
                    colorFilter: const ColorFilter.mode(
                        _kIconGrey, BlendMode.srcIn),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5484D),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One top-level nav entry: the label, and a 3px accent bar pinned to the
/// bottom of the bar when selected.
class AppBarNavItem extends StatelessWidget {
  const AppBarNavItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: kAppBarHeight,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: _kNavLabelTop),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _kNavItemPad),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  softWrap: false,
                  maxLines: 1,
                  style: isSelected
                      ? _kNavTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kAppBarAccent,
                        )
                      : _kNavTextStyle,
                ),
              ),
              const Spacer(),
              Container(
                height: _kNavUnderlineHeight,
                color: isSelected ? kAppBarAccent : Colors.transparent,
              ),
              const SizedBox(height: _kNavUnderlineBottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays [items] out as the centred nav row with the design's spacing.
class AppBarNavRow extends StatelessWidget {
  const AppBarNavRow({super.key, required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(const SizedBox(width: _kNavItemGap));
      spaced.add(items[i]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: spaced,
    );
  }
}

class EmrAppBar extends StatelessWidget {
  const EmrAppBar({
    super.key,
    required this.headingText,
    required this.body,
    this.isHrModule = false,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false,
    this.shortHeadingText,
    this.moduleLabel = 'Establishment',
    this.onModuleTap,
    this.onNotificationTap,
    this.searchField,
  });

  final String headingText;
  final bool isHrModule;
  final bool isEmrClinicianModule;

  /// The centred nav — normally a single [AppBarNavRow].
  final List<Widget> body;
  final bool hideNameOnSmallScreen;
  final String? shortHeadingText;

  /// Label inside the module selector beside the logo.
  final String moduleLabel;
  final VoidCallback? onModuleTap;
  final VoidCallback? onNotificationTap;

  /// The global search box, sized by the caller. Sits between the nav and
  /// the bell.
  final Widget? searchField;

  @override
  Widget build(BuildContext context) {
    // The bar holds its design geometry down to [kAppBarMinWidth] and
    // scrolls sideways below that, rather than compressing the nav.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = math.max(screenWidth, kAppBarMinWidth);
    final bool nameHidden = hideNameOnSmallScreen &&
        screenWidth < kAppBarNameHideBreakpoint;
    final double rightClusterWidth =
        nameHidden ? _kRightClusterWidthCompact : _kRightClusterWidth;

    return Material(
      color: Colors.white,
      child: SizedBox(
        height: kAppBarHeight,
        width: double.maxFinite,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: barWidth,
            height: kAppBarHeight,
            child: Row(
              children: [
                // ── Left: logo, rule, module selector ────────────────────────
                const SizedBox(width: _kLogoLeftInset),
                const CompanyLogoWidget(
                  width: _kLogoWidth,
                  height: _kLogoHeight,
                ),
                const SizedBox(width: _kLogoToDividerGap),
                const _AppBarDivider(
                  height: _kLeftDividerHeight,
                  color: Color(0x21000000),
                  thickness: 0.5,
                ),
                const SizedBox(width: _kDividerToModuleGap),
                // Falls back to "return to the shell's module picker" when the
                // caller has no opinion. Standalone builds get null back, so
                // the selector stays inert exactly as it is today.
                _ModuleSelector(
                  label: moduleLabel,
                  onTap: onModuleTap ?? ShellLink.backToModulesOrNull,
                ),

                // ── Middle: the nav ─────────────────────────────────────────
                // Centred while it fits, scrollable once it doesn't. The
                // minWidth constraint is what does both: it makes the row at
                // least as wide as the slot (so MainAxisAlignment.center has
                // something to centre within) while letting it grow past the
                // slot instead of overflowing.
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints slot) {
                      // Always full size — never scaled. The minWidth is
                      // what lets MainAxisAlignment.center do its job while
                      // still allowing the row to grow past the slot rather
                      // than overflow; below
                      // [kAppBarNavCollapseBreakpoint] the caller sends a
                      // dropdown instead, so that growth shouldn't happen.
                      //
                      // NOTE the contract this implies: the incoming width
                      // here is minWidth..Infinity, so every widget a caller
                      // puts in `body` must size itself. A flex child
                      // (Expanded/Flexible) is illegal and throws
                      // "RenderFlex children have non-zero flex but incoming
                      // width constraints are unbounded", which leaves the
                      // whole bar and the screen under it unsized - a blank
                      // page.
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: slot.maxWidth),
                          child: SizedBox(
                            height: kAppBarHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: body,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Right: search, extras, bell, rule, user ──────────────────
                // Fixed width, contents right-aligned — see
                // [_kRightClusterWidth].
                SizedBox(
                  width: rightClusterWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (searchField != null) searchField!,
                      const SizedBox(width: _kSearchToBellGap),
                      _NotificationBell(onTap: onNotificationTap),
                      const SizedBox(width: _kBellToDividerGap),
                      const _AppBarDivider(
                        height: _kRightDividerHeight,
                        color: Color(0xFFD9D9D9),
                      ),
                      const SizedBox(width: _kDividerToUserGap),
                      UserAppBarWidgetEmr(
                        isEmrClinicianModule: isEmrClinicianModule,
                        hideNameOnSmallScreen: hideNameOnSmallScreen,
                      ),
                      const SizedBox(width: _kAppBarRightInset),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
///

class UserAppBarWidgetEmr extends StatefulWidget {
  const UserAppBarWidgetEmr({
    Key? key,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false, // ✅ NEW — default false
  }) : super(key: key);

  final bool isEmrClinicianModule;
  final bool hideNameOnSmallScreen; // ✅ NEW

  @override
  State<UserAppBarWidgetEmr> createState() => _UserAppBarWidgetEmrState();
}

class _UserAppBarWidgetEmrState extends State<UserAppBarWidgetEmr> {
  late Future<UserAppBar> _appBarFuture;
  late Future<String> _userFuture;

  String? loginName = '';
  String? loginRole = '';
  int? _userId; // ✅ NEW
  bool isLoggedIn = true;

  // ✅ shared with EmrAppBar, which reserves the cluster's width
  static const double _nameHideBreakpoint = kAppBarNameHideBreakpoint;

  // ✅ NEW — lets us programmatically trigger the same popup menu the
  // arrow icon opens, when the user taps the name instead
  final GlobalKey<PopupMenuButtonState<String>> _popupMenuKey =
      GlobalKey<PopupMenuButtonState<String>>();

  @override
  void initState() {
    super.initState();
    _appBarFuture = getAppBarDetails(context);
    _userFuture = _loadUser();
  }

  Future<String> _loadUser() async {
    loginName = await TokenManager.getUserName();
    // ✅ second line of the design's user block
    loginRole = await TokenManager.getRole();
    _userId = await TokenManager.getuserId(); // ✅ NEW — fetched once here
    return loginName ?? ''; // ✅ guard: avoid ! crash if token not set yet
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NEW — only relevant when caller opted in via hideNameOnSmallScreen
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool shouldHideName =
        widget.hideNameOnSmallScreen && screenWidth < _nameHideBreakpoint;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar + name/role + chevron — the whole cluster opens the menu
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _popupMenuKey.currentState?.showButtonMenu(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              FutureBuilder<UserAppBar>(
                future: _appBarFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data!.imgUrl.isNotEmpty) {
                    return CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: _kUserAvatarSize / 2,
                      backgroundImage: NetworkImage(snapshot.data!.imgUrl),
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    radius: _kUserAvatarSize / 2,
                    backgroundImage: const AssetImage("images/profilepic.png"),
                  );
                },
              ),

              // Login name + role + dropdown
              FutureBuilder<String>(
                future: _userFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ name collapses away below the breakpoint, but the
                      // avatar + chevron keep the menu reachable
                      if (!shouldHideName) ...[
                        const SizedBox(width: _kUserAvatarToNameGap),
                        SizedBox(
                          width: _kUserNameWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayOrEmpty(loginName),
                                style: _kUserNameStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                displayOrEmpty(loginRole),
                                style: _kUserRoleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: _kUserNameToChevronGap),
                      SvgPicture.asset(
                        'images/sort_dropdown_arrow.svg',
                        width: _kUserChevronSize,
                        height: _kUserChevronSize / 2,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF7E7E7E), BlendMode.srcIn),
                      ),

                      // Popup menu
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: PopupMenuButton<String>(
                          key:
                              _popupMenuKey, // ✅ NEW — lets the name tap trigger this
                          tooltip: '',
                          splashRadius: 0,
                          color: Colors.white,
                          offset: const Offset(0, 40),
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context) => [
                            // Log Out
                            PopupMenuItem<String>(
                              height: 25,
                              value: 'Logout',
                              padding: EdgeInsets.zero,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                  if (isLoggedIn) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => DeletePopup(
                                        onCancel: () => Navigator.pop(context),
                                        onDelete: () async {
                                          String fcmToken = await TokenManager
                                              .getFcmTokenRegister();
                                          String refreshToken =
                                              await TokenManager
                                                  .getRefreshToken();
                                          if (fcmToken.isEmpty) {
                                            var refreshTokenLogout =
                                                await AuthManager()
                                                    .logOutuserByToken(
                                              refreshToken: refreshToken,
                                              context: context,
                                            );
                                            if (refreshTokenLogout.statusCode ==
                                                    200 ||
                                                refreshTokenLogout.statusCode ==
                                                    204) {
                                              print(
                                                  'User logged out successfully');
                                              await TokenManager
                                                  .clearSession(); // ✅ clear on success too
                                              _afterSignOut(context);
                                            } else {
                                              print('Failed to log out user');
                                              await TokenManager
                                                  .clearSession(); // ✅ was: removeAccessToken()
                                              _afterSignOut(context);
                                            }
                                          } else {
                                            var response =
                                                await unRegisterDevice(
                                              context: context,
                                              fcmToken: fcmToken,
                                            );
                                            if (response.statusCode == 201 ||
                                                response.statusCode == 200) {
                                              var refreshTokenLogout =
                                                  await AuthManager()
                                                      .logOutuserByToken(
                                                refreshToken: refreshToken,
                                                context: context,
                                              );
                                              if (refreshTokenLogout
                                                          .statusCode ==
                                                      200 ||
                                                  refreshTokenLogout
                                                          .statusCode ==
                                                      204) {
                                                print(
                                                    'User logged out successfully');
                                                await TokenManager
                                                    .clearSession(); // ✅ was: removeFCMToken() only
                                                _afterSignOut(context);
                                              } else {
                                                print('Failed to log out user');
                                                await TokenManager
                                                    .clearSession(); // ✅ was: removeAccessToken()
                                                _afterSignOut(context);
                                              }
                                            }
                                          }
                                        },
                                        btnText: "Log Out",
                                        title: "Log Out",
                                        text: "Do you really want to log out?",
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 12),
                                  width: 130,
                                  height: 40,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5.5),
                                      Row(
                                        children: [
                                          Icon(Icons.logout,
                                              size: 18,
                                              color: ColorManager.mediumgrey),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Log Out',
                                            style: CustomTextStylesCommon
                                                .commonStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: FontSize.s12,
                                              color: ColorManager.mediumgrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

///
//
///

//nociteg824@noyavip.com  RN new user RN
//
// vedayaj820@nriza.com   PT User PT
//
//     OT clinician
//
// mepix47097@nriza.com         OT user 202 maxi lee
//
// kibivom298@nriza.com ST user  kibivom298@nriza.com
//
// yifej90134@nuitx.com    dme@123
//
// managersujata@gmail.com       QA manager@123
//
// gohoji5803@hitzcart.com  CEO sujata@123

//copoy11850@hitzcart.com
//
// qasujata01@gmail.com     qa@123  QA-Cordinator
//
// codersujata@gmail.com   coder@123 Coder
//
//devawa8533@ifcoat.com Clinical manager --sujata@123
///

///
//flutter build web --release --dart-define=API_ENDPOINT=https://prohealth-dev.symmetry.care --dart-define="APP_VERSION=Version 1.1.4 (1) dev"

//flutter build web --release --dart-define=API_ENDPOINT=https://demo.symmetry.care --dart-define="APP_VERSION=Version 1.1.4 (1) demo"

// class UserAppBarWidgetEmr extends StatefulWidget {
//    UserAppBarWidgetEmr({Key? key, this.isEmrClinicianModule = false}) : super(key: key);
//   final bool isEmrClinicianModule;
//
//   @override
//   State<UserAppBarWidgetEmr> createState() => _UserAppBarWidgetEmrState();
// }
//
// class _UserAppBarWidgetEmrState extends State<UserAppBarWidgetEmr> {
//   String? loginName = '';
//
//   String? loginEmail = '';
//
//   //int loginUserId = 0;
//   bool isLoggedIn = true;
//
//   Future<String> user() async {
//     loginName = await TokenManager.getUserName();
//     //loginName = userName;
//     print("UserName login ${loginName}");
//     return loginName!;
//   }
//
//   Future<String> email() async {
//     loginEmail = await TokenManager.getEmail();
//     //loginName = userName;
//     print("loginEmail login ${loginEmail}");
//     return loginEmail!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10,right: 5),
//       child:Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Avatar (non-tappable)
//           FutureBuilder<UserAppBar>(
//             future: getAppBarDetails(context),
//             builder: (context, snapshot) {
//               Widget avatar = CircleAvatar(
//                 backgroundColor: Colors.grey[100],
//                 radius: 20,
//                 backgroundImage: const AssetImage("images/profilepic.png"),
//               );
//
//               if (snapshot.connectionState == ConnectionState.done &&
//                   snapshot.hasData &&
//                   snapshot.data!.imgUrl.isNotEmpty) {
//                 avatar = CircleAvatar(
//                   backgroundColor: Colors.transparent,
//                   radius: 20,
//                   backgroundImage: NetworkImage(snapshot.data!.imgUrl),
//                 );
//               }
//
//               return avatar; // purely visual
//             },
//           ),
//           const SizedBox(width: 3),
//
//           // Login name and dropdown icon
//           FutureBuilder(
//             future: user(),
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return const SizedBox();
//               }
//
//               return Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Flexible(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Text(
//                         loginName ?? "",
//                         style: const TextStyle(
//                           color: Color(0xFF2EA3D4),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//
//
//
//                   // Custom styled popup menu with icons
//                   Theme(
//                     data: Theme.of(context).copyWith(
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       hoverColor: Colors.transparent,
//                       splashFactory: NoSplash.splashFactory,
//                     ),
//                     child: PopupMenuButton<String>(
//                       tooltip: '',
//                       splashRadius: 0,
//                       color: Colors.white,
//                       offset: const Offset(0, 40),
//                       padding: EdgeInsets.zero,
//
//                       itemBuilder: (BuildContext context) => [
//                         // Settings
//                         PopupMenuItem<String>(
//                           height: 25,
//                           value: 'Settings',
//                           padding: EdgeInsets.zero,
//                           child: InkWell(
//                             splashColor: Colors.transparent,
//                             highlightColor: Colors.transparent,
//                             hoverColor: Colors.transparent,
//                             onTap: () {
//                               if (widget.isEmrClinicianModule) {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const ProfileDetailScreen(),
//                                   ),
//                                 );
//                               }
//                             },
//                             // onTap: () {
//                             //   Navigator.pop(context); // Close the popup menu first
//                             //   Navigator.push(
//                             //     context,
//                             //     MaterialPageRoute(
//                             //       builder: (context) => const ProfileDetailScreen(),
//                             //     ),
//                             //   );
//                             //   // Navigator.pop(context);
//                             //   // Navigate or perform settings logic
//                             // },
//                             child: Container(
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 12,),
//                               width: 130,
//                               height: 40,
//                               child: Column(
//                                 children: [
//                                   const SizedBox(height: 5.5),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.settings, size: 18, color: ColorManager.mediumgrey),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Settings',
//                                         style: CustomTextStylesCommon.commonStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: FontSize.s12,
//                                           color: ColorManager.mediumgrey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(),
//                                 ],
//                               ),
//                             ),
//
//                           ),
//                         ),
//
//                         // Divider
//                         //  const PopupMenuDivider(),
//
//                         // Notification
//                         // PopupMenuItem<String>(
//                         //   height: 25,
//                         //   value: 'Notification',
//                         //   padding: EdgeInsets.zero,
//                         //   child: InkWell(
//                         //     splashColor: Colors.transparent,
//                         //     highlightColor: Colors.transparent,
//                         //     hoverColor: Colors.transparent,
//                         //     onTap: () {
//                         //       //  Navigator.pop(context);
//                         //       // Notification logic
//                         //     },
//                         //     child: Container(
//                         //       alignment: Alignment.centerLeft,
//                         //       padding: const EdgeInsets.only(left: 12, ),
//                         //       width: 130,
//                         //       height: 40,
//                         //       child: Column(
//                         //         children: [
//                         //           const SizedBox(height: 5.5),
//                         //           Row(
//                         //             children: [
//                         //               Image.asset('images/hh_emr/sick_leave.png', width: 18, height: 18,color: ColorManager.mediumgrey),
//                         //               // Icon(Icons.notifications_rounded, size: 18, color: ColorManager.mediumgrey),
//                         //               const SizedBox(width: 10),
//                         //               Text(
//                         //                 'Sick Leave (40h)',
//                         //                 style: CustomTextStylesCommon.commonStyle(
//                         //                   fontWeight: FontWeight.w700,
//                         //                   fontSize: FontSize.s12,
//                         //                   color: ColorManager.mediumgrey,
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //           Divider(),
//                         //         ],
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//
//                         // Divider
//                         // const PopupMenuDivider(),
//
//                         // Log Out
//                         PopupMenuItem<String>(
//                           height: 25,
//                           value: 'Logout',
//                           padding: EdgeInsets.zero,
//                           child: InkWell(
//                             splashColor: Colors.transparent,
//                             highlightColor: Colors.transparent,
//                             hoverColor: Colors.transparent,
//                             onTap: () {
//                               Navigator.pop(context);
//                               if (isLoggedIn) {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => DeletePopup(
//                                     onCancel: () => Navigator.pop(context),
//                                     onDelete: () async{
//                                       String fcmToken = await TokenManager.getFcmTokenRegister();
//                                       String refreshToken = await TokenManager.getRefreshToken();
//                                       if(fcmToken.isEmpty){
//                                         var refreshTokenLogout = await AuthManager().logOutuserByToken(refreshToken: refreshToken, context: context);
//                                         if(refreshTokenLogout.statusCode == 200 || refreshTokenLogout.statusCode == 204){
//                                           print('User logged out successfully');
//                                           // TokenManager.removeAccessToken();
//                                           // Navigator.pushNamedAndRemoveUntil(
//                                           //     buildContext, LoginScreen.routeName, (route) => false);
//                                         }else{
//                                           print('Failed to log out user');
//                                           TokenManager.removeAccessToken();
//                                           Navigator.pushNamedAndRemoveUntil(
//                                               context,
//                                               LoginScreen.routeName,
//                                                   (route) => false);
//                                         }
//
//                                       }else{
//                                         var response = await unRegisterDevice(context: context, fcmToken: fcmToken);
//                                         if(response.statusCode == 201 || response.statusCode == 200){
//                                           var refreshTokenLogout = await AuthManager().logOutuserByToken(refreshToken: refreshToken, context: context);
//                                           if(refreshTokenLogout.statusCode == 200 || refreshTokenLogout.statusCode == 204){
//                                             TokenManager.removeFCMToken();
//                                             print('User logged out successfully');
//                                             // TokenManager.removeAccessToken();
//                                             // Navigator.pushNamedAndRemoveUntil(
//                                             //     buildContext, LoginScreen.routeName, (route) => false);
//                                           }else{
//                                             print('Failed to log out user');
//                                             TokenManager.removeAccessToken();
//                                             Navigator.pushNamedAndRemoveUntil(
//                                                 context,
//                                                 LoginScreen.routeName,
//                                                     (route) => false);
//                                           }
//
//                                           // TokenManager.removeAccessToken();
//                                           // Navigator.pushNamedAndRemoveUntil(
//                                           //     context,
//                                           //     LoginScreen.routeName,
//                                           //         (route) => false);
//                                         }
//                                       }
//                                     },
//                                     btnText: "Log Out",
//                                     title: "Log Out",
//                                     text: "Do you really want to logout?",
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 12, ),
//                               width: 130,
//                               height: 40,
//                               child: Column(
//                                 children: [
//                                   const SizedBox(height: 5.5),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.logout, size: 18, color: ColorManager.mediumgrey),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Log Out',
//                                         style: CustomTextStylesCommon.commonStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: FontSize.s12,
//                                           color: ColorManager.mediumgrey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         //   const PopupMenuDivider(),
//                       ],
//                       child: const Icon(
//                         Icons.keyboard_arrow_down_outlined,
//                         color: Color(0xFF2EA3D4),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//
//
//       ///
//       // Row(
//       //   mainAxisAlignment: MainAxisAlignment.end,
//       //   crossAxisAlignment: CrossAxisAlignment.center,
//       //   children: [
//       //     MouseRegion(
//       //       onEnter: (_) {},
//       //       onExit: (_) {},
//       //       child: FutureBuilder<UserAppBar>(
//       //         future: getAppBarDetails(context),
//       //         builder: (context, snapshot) {
//       //           Widget avatar = CircleAvatar(
//       //             backgroundColor: Colors.grey[100],
//       //             radius: 20,
//       //             backgroundImage: const AssetImage("images/profilepic.png"),
//       //           );
//       //
//       //           if (snapshot.connectionState == ConnectionState.waiting) {
//       //             return GestureDetector(child: avatar, onTap: () {});
//       //           } else if (snapshot.hasData && snapshot.data!.imgUrl.isNotEmpty) {
//       //             avatar = CircleAvatar(
//       //               backgroundColor: Colors.transparent,
//       //               radius: 20,
//       //               backgroundImage: NetworkImage(snapshot.data!.imgUrl),
//       //             );
//       //           }
//       //
//       //           return GestureDetector(
//       //             child: avatar,
//       //             onTap: () {
//       //               print("userid appbar: ${snapshot.data?.userId}");
//       //             },
//       //           );
//       //         },
//       //       ),
//       //     ),
//       //     const SizedBox(width: 3),
//       //     FutureBuilder(
//       //       future: user(),
//       //       builder: (context, snap) {
//       //         if (snap.connectionState == ConnectionState.waiting) {
//       //           return const SizedBox();
//       //         }
//       //
//       //         return MouseRegion(
//       //           onEnter: (_) {
//       //             showMenu(
//       //               context: context,
//       //               position: const RelativeRect.fromLTRB(70, 70, 0, 0),
//       //               items: [
//       //                 // PopupMenuItem(
//       //                 //   padding: EdgeInsets.zero,
//       //                 //   height: 30,
//       //                 //   child: GestureDetector(
//       //                 //     onTap: () {
//       //                 //       if (isLoggedIn) {
//       //                 //         showDialog(
//       //                 //           context: context,
//       //                 //           builder: (context) => DeletePopup(
//       //                 //             onCancel: () => Navigator.pop(context),
//       //                 //             onDelete: () {
//       //                 //               TokenManager.removeAccessToken();
//       //                 //               Navigator.pushNamedAndRemoveUntil(
//       //                 //                 context,
//       //                 //                 LoginScreen.routeName,
//       //                 //                     (route) => false,
//       //                 //               );
//       //                 //             },
//       //                 //             btnText: "Log Out",
//       //                 //             title: "Log Out",
//       //                 //             text: "Do you really want to logout?",
//       //                 //           ),
//       //                 //         );
//       //                 //       }
//       //                 //     },
//       //                 //     child: Container(
//       //                 //       height: 25,
//       //                 //       width: 90,
//       //                 //       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                 //       child: Row(
//       //                 //         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                 //         crossAxisAlignment: CrossAxisAlignment.center,
//       //                 //         children: const [
//       //                 //           Icon(Icons.logout, size: 12, color: Colors.black),
//       //                 //           Text(
//       //                 //             'Log Out',
//       //                 //             style: TextStyle(
//       //                 //               fontSize: 12,
//       //                 //               color: Colors.black,
//       //                 //               fontWeight: FontWeight.w600,
//       //                 //             ),
//       //                 //           ),
//       //                 //         ],
//       //                 //       ),
//       //                 //     ),
//       //                 //   ),
//       //                 // ),
//       //                 ///
//       //                 ///
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       // Add your navigation or action here
//       //                      // Navigator.pushNamed(context, '/profile'); // Example
//       //                     },
//       //                     child: Container(
//       //                       height: 30,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.notifications_rounded, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Notification',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //
//       //                 // Settings item
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       // Add your navigation or action here
//       //                      // Navigator.pushNamed(context, '/settings'); // Example
//       //                     },
//       //                     child: Container(
//       //                       height: 25,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.settings, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Settings',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //
//       //                 // Log Out item
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       if (isLoggedIn) {
//       //                         showDialog(
//       //                           context: context,
//       //                           builder: (context) => DeletePopup(
//       //                             onCancel: () => Navigator.pop(context),
//       //                             onDelete: () {
//       //                               TokenManager.removeAccessToken();
//       //                               Navigator.pushNamedAndRemoveUntil(
//       //                                 context,
//       //                                 LoginScreen.routeName,
//       //                                     (route) => false,
//       //                               );
//       //                             },
//       //                             btnText: "Log Out",
//       //                             title: "Log Out",
//       //                             text: "Do you really want to logout?",
//       //                           ),
//       //                         );
//       //                       }
//       //                     },
//       //                     child: Container(
//       //                       height: 25,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.logout, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Log Out',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //               ],
//       //             );
//       //           },
//       //           child: Row(
//       //             mainAxisSize: MainAxisSize.min,
//       //             children: [
//       //               Text(
//       //                 loginName ?? "",
//       //                 style: TextStyle(
//       //                   color: Color(0xFF2EA3D4),
//       //                   fontSize: 13,
//       //                   fontWeight: FontWeight.w700,
//       //                 ),
//       //               ),
//       //               const SizedBox(width: 4),
//       //               Icon(Icons.keyboard_arrow_down_outlined, color: Color(0xFF2EA3D4)),
//       //             ],
//       //           ),
//       //         );
//       //       },
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
