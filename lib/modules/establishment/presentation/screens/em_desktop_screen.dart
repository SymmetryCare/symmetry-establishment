import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/router/em_routes.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/em_dashboard_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/const_appbar/controller.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

/// The Establishment header (Dashboard, Company Identity, the module
/// dropdown), the current page under it, and the footer.
///
/// The pages used to sit in a PageView here, switched by index and restored
/// from sessionStorage on refresh. Each is now its own URL (see
/// app/router/em_routes.dart): the header navigates, and the router hands the
/// page in as [child].
class EMDesktopScreen extends StatefulWidget {
  /// The page the URL names, for the header's highlight and dropdown label.
  final EmPage page;

  /// That page's screen.
  final Widget child;

  const EMDesktopScreen({
    super.key,
    required this.page,
    required this.child,
  });

  @override
  State<EMDesktopScreen> createState() => _EMDesktopScreenState();
}

class _EMDesktopScreenState extends State<EMDesktopScreen> {
  final EMController smController = Get.put(EMController());
  final HRController hrController = Get.put(HRController());
  final ButtonSelectionController myController = Get.put(ButtonSelectionController());
  bool showSelectOption = true;

  /// Go to [page] on its first tab — unless the user is already on it, in
  /// which case it stays on whatever tab is showing. That is how the header
  /// behaved with the PageView: re-selecting the current page changed nothing,
  /// and every other page opened fresh.
  ///
  /// A real navigation, so it adds a Back step.
  void _openPage(EmPage page) {
    if (page == widget.page) return;
    context.go(EmRoutes.location(page));
  }

  /// Dropdown label for [pageIndex]: the item's title for dropdown pages,
  /// the placeholder for Dashboard and Company Identity.
  String _pageNameFor(int pageIndex) {
    for (final item in _dropdownItems) {
      if (item.index == pageIndex) return item.title;
    }
    return EmDashboardStringManager.selectModule;
  }

  final List<DropdownItem> _dropdownItems = [
    DropdownItem(title: "User Management", isHeading: true),
    DropdownItem(title: "Users", index: 2),
    DropdownItem(title: "Clinical", isHeading: true),
    DropdownItem(title: "Visits", index: 3),
    DropdownItem(title: "HR", isHeading: true),
    DropdownItem(title: "Designation Settings", index: 4),
    DropdownItem(title: "Work Schedule", index: 5),
    DropdownItem(title: "Employee Documents", index: 6),
    DropdownItem(title: "Finance", isHeading: true),
    DropdownItem(title: "Pay Rate", index: 7),
    DropdownItem(title: "Org Document", isHeading: true),
    DropdownItem(title: "Document Definition", index: 8),
  ];

  @override
  Widget build(BuildContext context) {
    // Browser Back and Forward belong to the router (pages visited, like any
    // website); the index-stepping WillPopScope that used to sit here drove a
    // PageController that no longer exists.
    final EmPage currentPage = widget.page;
    return Builder(
      builder: (context) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              Column(
                children: [
                  ApplicationEmrAppBar(
                    isHrModule: true,
                    headingText: EmDashboardStringManager.em,
                    body: [
                      const SizedBox(width: 16),
                      // Sized by its children, never by a flex factor.
                      // This list is handed to the app bar's nav slot, which
                      // lays it out in a horizontally scrollable Row — the
                      // incoming width is unbounded, so an Expanded here
                      // throws "RenderFlex children have non-zero flex but
                      // incoming width constraints are unbounded" and leaves
                      // the bar and the whole screen under it unsized, which
                      // paints as a blank page. See the contract note in
                      // hh_emr_appbar.dart. Even spacing now comes from the
                      // Row's own `spacing` rather than spaceBetween, which
                      // needs a bounded width to divide up.
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: AppPadding.p30,
                          children: [
                              CustomTitleButton(
                                height: AppSize.s30,
                                width: AppSize.s100,
                                onPressed: () => _openPage(EmPage.dashboard),
                                text: EmDashboardStringManager.dashboard,
                                isSelected: currentPage == EmPage.dashboard,
                              ),
                              CustomTitleButton(
                                height: AppSize.s30,
                                width: AppSize.s140,
                                onPressed: () {
                                  companyByIdApi(context);
                                  _openPage(EmPage.companyIdentity);
                                },
                                text: EmDashboardStringManager.companyIdentity,
                                isSelected:
                                    currentPage == EmPage.companyIdentity,
                              ),
                              Material(
                                elevation: 4,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                child: CustomDropdownButton(
                                  height: AppSize.s30,
                                  width: AppSize.s170,
                                  initialItem: _pageNameFor(currentPage.index),
                                  items: _dropdownItems,
                                  // pageIndex is the old PageView index, which
                                  // is EmPage's order.
                                  onItemSelected: (selectedValue, pageIndex) =>
                                      _openPage(EmPage.values[pageIndex]),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      AppBarIcon(
                          icon: Icons.call_outlined,
                          onPressed: () => debugPrint('Call tapped')),
                      const SizedBox(width: 8),
                      AppBarIcon(
                          icon: Icons.notifications_none_outlined,
                          onPressed: () => debugPrint('Notification tapped')),
                      const SizedBox(width: 16),
                    ],
                  ),
                  Expanded(
                    flex: 8,
                    child: widget.child,
                  ),
                  BottomBarRow()
                ],
              ),
            ]),
        );
      },
    );
  }
}

class EMController extends GetxController {
  var selectedItem = 'Admin'.obs;
  void changeSelectedItem(String newItem) {
    selectedItem.value = newItem;
  }
}

class ButtonSelectionController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void selectButton(int index) {
    selectedIndex.value = index;
  }
}

class CustomDropdownButton extends StatefulWidget {
  final double height;
  final double width;
  final List<DropdownItem> items;
  final void Function(String, int)? onItemSelected;
  String initialItem;

  CustomDropdownButton({
    required this.height,
    required this.width,
    required this.items,
    required this.initialItem,
    this.onItemSelected,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  late String _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
  }

  // ✅ UPDATED: sync internal state when parent resets initialItem
  @override
  void didUpdateWidget(covariant CustomDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItem != oldWidget.initialItem) {
      setState(() {
        _selectedItem = widget.initialItem;
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double buttonHeight = renderBox.size.height;
    final double buttonWidth = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _removeDropdown,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            width: buttonWidth,
            left: offset.dx,
            top: offset.dy + buttonHeight,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, buttonHeight),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.items.map((item) {
                        return InkWell(
                          onTap: () {
                            if (!item.isHeading) {
                              setState(() {
                                _selectedItem = item.title;
                              });
                              int itemIndex = widget.items
                                  .where((element) => !element.isHeading)
                                  .toList()
                                  .indexOf(item) +
                                  2;
                              widget.onItemSelected?.call(item.title, itemIndex);
                              _removeDropdown();
                            }
                          },
                          child: Container(
                            padding: item.isHeading
                                ? EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                                : EdgeInsets.only(top: 8, bottom: 8, left: 30),
                            width: double.infinity,
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: FontSize.s14,
                                fontWeight: item.isHeading
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: item.isHeading
                                    ? ColorManager.black
                                    : ColorManager.textPrimaryColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: widget.height + 5,
          decoration: widget.initialItem != EmDashboardStringManager.selectModule
              ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff51B5E6),
                  Color(0xff008ABD),
                ],
              ))
              : const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialItem,
                style: TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                    color: widget.initialItem == EmDashboardStringManager.selectModule
                        ? ColorManager.textPrimaryColor
                        : Colors.white),
              ),
              Icon(Icons.arrow_drop_down,
                  color: widget.initialItem == EmDashboardStringManager.selectModule
                      ? ColorManager.textPrimaryColor
                      : Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownItem {
  final String title;
  final bool isHeading;
  final int? index;

  DropdownItem({required this.title, this.isHeading = false, this.index});
}
/// A round, low-emphasis icon button in the Establishment header (call,
/// notifications).
///
/// Reconstructed from its two call sites above — the original lived in the
/// `prohealth` monolith's shared app bar and did not come across with the
/// extracted screens. Sized and coloured to sit quietly beside the module
/// title rather than compete with the primary actions.
class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIcon({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: IconSize.I22, color: IconColorManager.bluebottom),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }
}
