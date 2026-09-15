import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';

///add popup
class CCScreensAddPopup extends StatefulWidget {
  final TextEditingController countynameController;
  final TextEditingController zipcodeController;
  VoidCallback onSavePressed;
  final Widget child;
  final Widget child1;
  final String title;
  CCScreensAddPopup(
      {super.key,
        required this.countynameController,
        required this.zipcodeController,
        required this.onSavePressed,
        required this.child,
        required this.child1,
        required this.title});

  @override
  State<CCScreensAddPopup> createState() => _CCScreensAddPopusState();
}

class _CCScreensAddPopusState extends State<CCScreensAddPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s420,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: AppSize.s40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      widget.title,
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p3,
                horizontal: AppPadding.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SMTextFConst(
                    controller: widget.countynameController,
                    keyboardType: TextInputType.text,
                    text: AppString.name_of_the_document,
                  ),
                  const SizedBox(height: AppSize.s15),
                  SMTextFConst(
                    controller: widget.zipcodeController,
                    keyboardType: TextInputType.text,
                    text: AppString.id_of_the_document,
                  ),
                  const SizedBox(height: AppSize.s15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.type_of_the_document,
                        style:  DefineWorkWeekStyle.customTextStyle(context),
                      ),
                      const SizedBox(
                        height: AppSize.s5,
                      ),
                      widget.child
                    ],
                  ),
                  const SizedBox(height: AppSize.s15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.sub_type_of_the_document,
                        style:  DefineWorkWeekStyle.customTextStyle(context),
                      ),
                      const SizedBox(
                        height: AppSize.s5,
                      ),
                      widget.child1
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p50),
              child: Center(
                child: CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: AppStringEM.add,
                  onPressed: () {
                    widget.onSavePressed();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Role dropdown
class RoleDropdown extends StatefulWidget {
  final double? width;
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;
  final double? constraintHeight;
  final double? borderRadius;

  const RoleDropdown({
    Key? key,
    required this.items,
    this.width,
    this.borderRadius,
    this.initialValue,
    String? hintText,
    this.onChange,
    this.isEnabled,
    this.constraintHeight = 250,
  }) : super(key: key);

  @override
  _RoleDropdownState createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  String? _selectedValue;
  bool _isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<DropdownMenuItem<String>> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(RoleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
        _searchController.clear();
      });
    }
    if (oldWidget.items != widget.items) {
      setState(() {
        _filteredItems = widget.items;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _filteredItems = widget.items;
    _searchController.clear();

    _overlayEntry = OverlayEntry(
      builder: (context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() => _isOpen = false);
          _removeOverlay();
          _focusNode.unfocus();
        },
        child: Stack(
          children: [
            const SizedBox.expand(),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    return Container(
                      // FIX: widget.width can be double.infinity (callers pass
                      // width: double.infinity to make the closed field stretch
                      // to fill its parent column). That's fine for the closed
                      // field, but this Container sits inside a
                      // CompositedTransformFollower with no bounding parent, so
                      // an infinite width here throws "BoxConstraints forces an
                      // infinite width". Fall back to the measured field width
                      // whenever widget.width is null OR infinite.
                      width: (widget.width == null ||
                          !widget.width!.isFinite)
                          ? size.width
                          : widget.width,
                      constraints: const BoxConstraints(
                        maxHeight: 40 * 3, // show only 3 items, rest scroll
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _filteredItems.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(AppPadding.p12),
                        child: Text(
                          'No results found',
                          style: DocumentTypeDataStyle.customTextStyle(context)
                              ?.copyWith(color: Colors.grey),
                        ),
                      )
                          : ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: _filteredItems.map((item) {
                          final isSelected = item.value == _selectedValue;
                          return ListTile(
                            dense: true,
                            selected: isSelected,
                            selectedTileColor:
                            ColorManager.blueprime.withOpacity(0.08),
                            title: Text(
                                item.value ?? '',
                                style: DocumentTypeDataStyle.customTextStyle(context)
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check,
                                size: IconSize.I16,
                                color: ColorManager.blueprime)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedValue = item.value;
                                _isOpen = false;
                                _searchController.clear();
                              });
                              widget.onChange?.call(item.value!);
                              _removeOverlay();
                              _focusNode.unfocus();
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) =>
          (item.value ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: widget.width ?? AppSize.s354,
        height: AppSize.s30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? (FormDialogFields.isActive(context) ? FormDialogFields.radius : 5.0)),
        ),
        child: Row(
          children: [
            // ── Search prefix icon ────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: Icon(
                Icons.search,
                size: IconSize.I16,
                color: Colors.black,
              ),
            ),
            // ── Inline search / selected text field ───────────
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                enabled: widget.isEnabled ?? true,
                style: DocumentTypeDataStyle.customTextStyle(context),
                decoration: InputDecoration(
                  hintText: _selectedValue ?? 'Select',
                  hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  if (!_isOpen) _showOverlay();
                },
                onChanged: _onSearchChanged,
              ),
            ),
            // ── Arrow icon ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color:  Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
///dropdown constant

class CICCDropdown extends StatefulWidget {
  final double? width;
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;
  final double? constraintHeight;
  final double? borderRadius;
  final FocusNode? focusNode;
  /// Closed-field height. Defaults to AppSize.s30 so existing callers are
  /// untouched; the Qualifications toolbar passes a taller value to line up
  /// with the "+ Add New" button beside it.
  final double? height;
  /// Defaults to the filled Material caret; callers wanting the thin chevron
  /// from the design pass Icons.keyboard_arrow_down.
  final IconData? trailingIcon;
  /// Unfocused border colour. Defaults to Colors.grey so existing callers are
  /// untouched; the design's field uses a much lighter hairline.
  final Color? borderColor;
  /// Overrides the label style. Defaults to DocumentTypeDataStyle.
  final TextStyle? textStyle;
  /// Overrides the label's horizontal inset. Defaults to AppPadding.p10.
  final double? textPadding;
  /// Overrides the trailing icon's size.
  final double? trailingIconSize;
  /// Fill colour of the closed field. Defaults to transparent, as before.
  final Color? backgroundColor;
  /// Shown inside the popup when [items] is empty, so the closed field still
  /// looks like a normal dropdown instead of being replaced by a message.
  final String? emptyText;

  const CICCDropdown({
    Key? key,
    required this.items,
    this.width,
    this.height,
    this.trailingIcon,
    this.borderColor,
    this.textStyle,
    this.textPadding,
    this.trailingIconSize,
    this.backgroundColor,
    this.emptyText,
    this.borderRadius,
    this.initialValue,
    String? hintText,
    this.onChange,
    this.isEnabled,
    this.constraintHeight = 250,
    this.focusNode,
  }) : super(key: key);

  @override
  _CIDetailsDropdownState createState() => _CIDetailsDropdownState();
}

class _CIDetailsDropdownState extends State<CICCDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(CICCDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  void _showCustomDropdown() {
    widget.focusNode?.requestFocus();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  // FIX: callers (e.g. the County/Zone dropdowns in the offer
                  // letter coverage card) pass `width: double.infinity` so the
                  // *closed* field stretches to fill its Expanded column. That
                  // value was being reused as-is for this overlay Container,
                  // which sits directly inside a Positioned/Stack pushed via
                  // showDialog with no bounding width — giving it an infinite
                  // width threw "BoxConstraints forces an infinite width" and
                  // cascaded into the RenderBox-not-laid-out crashes. Whenever
                  // widget.width is null OR not finite (infinite), fall back
                  // to the actual measured field width instead.
                  width: (widget.width == null || !widget.width!.isFinite)
                      ? size.width
                      : widget.width,
                  // FIX: only force a fixed height when there are more than 3
                  // items — otherwise the overlay height should hug its content
                  // (e.g. 1-2 items) rather than always reserving AppSize.s200,
                  // which left ugly empty space for short lists.
                  height: widget.items.length > 3 ? AppSize.s150 : null,
                  constraints: BoxConstraints(
                    maxHeight: widget.constraintHeight!,
                  ),
                  child: widget.items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p15,
                              vertical: AppPadding.p15),
                          child: Text(
                            widget.emptyText ?? 'No options available',
                            style: DocumentTypeDataStyle.customTextStyle(
                                context),
                          ),
                        )
                      : widget.items.length > 3
                      ? ListView(
                    shrinkWrap: true,
                    children: widget.items.map((DropdownMenuItem<String> item) {
                      return ListTile(
                        title: Text(
                          item.value ?? '',
                          style: DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedValue = item.value;
                            widget.onChange?.call(item.value!);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  )
                      : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((DropdownMenuItem<String> item) {
                        return ListTile(
                          title: Text(
                            item.value ?? '',
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedValue = item.value;
                              widget.onChange?.call(item.value!);
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(bool hasFocus) {
    return InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
      onTap: widget.isEnabled == false ? null : _showCustomDropdown,
      child: Container(
        width: widget.width ?? AppSize.s354,
        height: widget.height ?? AppSize.s30,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(
            color: hasFocus
                ? ColorManager.blueprime
                : (widget.borderColor ?? (FormDialogFields.isActive(context) ? FormDialogFields.borderColor : Colors.grey)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? (FormDialogFields.isActive(context) ? FormDialogFields.radius : 5.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: widget.textPadding ?? AppPadding.p10),
                child: Text(
                  _selectedValue ?? 'Select',
                  style: widget.textStyle ??
                      DocumentTypeDataStyle.customTextStyle(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: Icon(
                widget.trailingIcon ?? Icons.arrow_drop_down,
                size: widget.trailingIconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusNode != null) {
      return Focus(
        focusNode: widget.focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.space)) {
            if (widget.isEnabled != false) {
              _showCustomDropdown();
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (ctx) => _buildDropdown(Focus.of(ctx).hasFocus),
        ),
      );
    }
    return _buildDropdown(false);
  }
}


///prajwal
class CICCDropDownExcel extends StatefulWidget {
  final double? width;
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;

  const CICCDropDownExcel({
    Key? key,
    required this.items,
    this.width,
    this.initialValue,
    this.onChange,
    String? hintText,
    this.isEnabled,
  }) : super(key: key);

  @override
  _CIDetailsDropDownState createState() => _CIDetailsDropDownState();
}

class _CIDetailsDropDownState extends State<CICCDropDownExcel> {
  String? _selectedValue;
  GlobalKey _dropdownKey = GlobalKey();
  List items = [];
  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showCustomDropdown() async {
    final RenderBox renderBox =
    _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + size.width, 0),
      items: widget.items.map((DropdownMenuItem<String> item) {
        return PopupMenuItem<String>(
          textStyle: DocumentTypeDataStyle.customTextStyle(context),
          value: item.value,
          child: Container(
            width: size.width - 16,

            ///minus padding/margin
            child: Text(item.value ?? ''),
          ),
        );
      }).toList(),
      color: ColorManager.white,
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChange!(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
          onTap: _showCustomDropdown,
          child: Container(
            padding: const EdgeInsets.only(left: AppPadding.p2),
            key: _dropdownKey,
            width: widget.width == null ? AppSize.s354 : widget.width,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(
                  color: ColorManager.containerBorderGrey, width: AppSize.s1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: Text(
                    _selectedValue ?? '',
                    style:  DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: AppPadding.p10),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

///
///
///prajwal
class CICCDropDownedit extends StatefulWidget {
  final double? width;
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;
  final double? constraintHeight;

  const CICCDropDownedit({
    Key? key,
    required this.items,
    this.width,
    this.initialValue,
    this.onChange,
    String? hintText,
    this.isEnabled,
    this.constraintHeight = 250,
  }) : super(key: key);

  @override
  _CIDetailsDropState createState() => _CIDetailsDropState();
}

class _CIDetailsDropState extends State<CICCDropDownedit> {
  String? _selectedValue;
  GlobalKey _dropdownKey = GlobalKey();
  List items = [];
  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showCustomDropdown() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;



    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  // FIX: same infinite-width hazard as CICCDropdown above —
                  // guard against widget.width being double.infinity.
                  width: (widget.width == null || !widget.width!.isFinite)
                      ? size.width
                      : widget.width,
                  constraints: BoxConstraints(
                    maxHeight: widget.constraintHeight!, // Limit height for scrolling
                  ),
                  child: Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: widget.items.map((DropdownMenuItem<String> item) {
                        return ListTile(
                          title: Text(
                            item.value ?? '',
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedValue = item.value;
                              widget.onChange?.call(item.value!);
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
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
    return Column(
      children: [
        InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
          onTap: _showCustomDropdown,
          child: Container(
            padding: const EdgeInsets.only(left: AppPadding.p2),
            key: _dropdownKey,
            width: widget.width == null ? AppSize.s354 : widget.width,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(
                  color: ColorManager.containerBorderGrey, width: AppSize.s1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: Text(
                    _selectedValue ?? '',
                    style:  DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: AppPadding.p10),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
///
///

///edit popup
class CCScreenEditPopup extends StatefulWidget {
  final String? idOfDoc;
  final TextEditingController idOfDocController;
  final TextEditingController nameDocController;
  final TextEditingController? calenderController;
  final VoidCallback? onSavePressed;
  final Widget child;
  final Widget? child1;
  final Widget? child2;
  final double? height;
  final Widget? radioButton;
  bool? loadingDuration;
  final String title;

  CCScreenEditPopup({
    super.key,
    required this.idOfDocController,
    required this.nameDocController,
    this.onSavePressed,
    required this.child,
    this.child1,
    this.child2,
    this.idOfDoc,
    this.radioButton,
    this.calenderController,
    this.loadingDuration,
    required this.title,
    this.height,
  });

  @override
  State<CCScreenEditPopup> createState() => _CCScreenEditPopupState();
}

class _CCScreenEditPopupState extends State<CCScreenEditPopup> {
  String? _expiryType;
  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s420,
        height: widget.height == null ? AppSize.s550 : widget.height,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: AppSize.s35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      widget.title,
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p18,
                horizontal: AppPadding.p18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SMTextFConst(
                    enable: false,
                    controller: widget.idOfDocController,
                    keyboardType: TextInputType.text,
                    text: AppString.id_of_the_document,
                  ),
                  const SizedBox(height: AppSize.s12),
                  SMTextFConst(
                    controller: widget.nameDocController,
                    keyboardType: TextInputType.text,
                    text: AppString.name_of_the_document,
                  ),
                  const SizedBox(height: AppSize.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.type_of_the_document,
                        style: ConstTextFieldRegister.customTextStyle(context),
                      ),
                      const SizedBox(height: AppSize.s5),
                      widget.child!,
                    ],
                  ),
                  const SizedBox(height: AppSize.s5),
                  if (widget.child1 != null) ...[
                    Text(
                      AppString.sub_type_of_the_document,
                      style: DefineWorkWeekStyle.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                  ],
                  widget.child1 ?? const Offstage(),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s5),

            ///radio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p25),
              child: widget.radioButton,
            ),
            const SizedBox(height: AppSize.s10),

            Padding(
              padding: const EdgeInsets.only(
                left: AppPadding.p20,
                right: AppPadding.p20,
              ),
              child: widget.child2,
            ),
            const SizedBox(height: AppSize.s20),

            ///button
            Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p10),
              child: Center(
                child: CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: AppStringEM.add, //submit
                  isLoading: widget.loadingDuration == true,
                  onPressed: () {
                    widget.onSavePressed!();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// add popu
class AddOrgDocButton extends StatefulWidget {
  final TextEditingController idDocController;
  final TextEditingController nameDocController;
  final TextEditingController calenderController;
  final VoidCallback onPressed;
  final double? height;
  Widget? child;
  Widget? child1;
  final String title;
  final Widget? radioButton;
  final Visibility? child2;
  final bool? loadingDuration;
  final String? selectedSubDocType;
  AddOrgDocButton(
      {super.key,
        required this.idDocController,
        required this.nameDocController,
        this.child,
        this.child1,
        required this.onPressed,
        required this.calenderController,
        this.radioButton,
        this.loadingDuration,
        required this.title,
        this.child2,
        this.height,
        this.selectedSubDocType});

  @override
  State<AddOrgDocButton> createState() => _AddOrgDocButtonState();
}

class _AddOrgDocButtonState extends State<AddOrgDocButton> {
  bool _isFormValid = true;

  // Error messages for each text field
  String? _idDocError;
  String? _nameDocError;

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please Enter $fieldName";
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      _idDocError =
          _validateTextField(widget.idDocController.text, 'ID of the Document');
      _nameDocError = _validateTextField(
          widget.nameDocController.text, 'Name of the Document');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s420,
        height: widget.height ?? AppSize.s598,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              height: AppSize.s40,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style:  PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p3,
                horizontal: AppPadding.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// ID of the Document
                  SMTextFConst(
                    controller: widget.idDocController,
                    keyboardType: TextInputType.text,
                    text: AppString.id_of_the_document,
                  ),
                  if (_idDocError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        _idDocError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSize.s13),

                  /// Name of the Document
                  FirstSMTextFConst(
                    controller: widget.nameDocController,
                    keyboardType: TextInputType.text,
                    text: AppString.name_of_the_document,
                  ),
                  if (_nameDocError != null) // Display error if any
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _nameDocError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSize.s13),

                  /// Type of the Document
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.type_of_the_document,
                        style: DefineWorkWeekStyle.customTextStyle(context),
                      ),
                      const SizedBox(height: AppSize.s5),
                      widget.child ?? const Offstage(),
                    ],
                  ),
                  const SizedBox(height: AppSize.s13),

                  /// Sub Type of the Document
                  if (widget.child1 != null) ...[
                    Text(
                      AppString.sub_type_of_the_document,
                      style: DefineWorkWeekStyle.customTextStyle(context),
                    ),
                    const SizedBox(height: AppSize.s5),
                  ],
                  widget.child1 ?? const Offstage(),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s10),

            /// Radio Button Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p25),
              child: widget.radioButton,
            ),
            const SizedBox(height: AppSize.s10),

            Padding(
              padding: const EdgeInsets.only(
                left: AppPadding.p20,
                right: AppPadding.p20,
              ),
              child: widget.child2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
              child: Center(
                child: CustomElevatedButton(
                  width: AppSize.s105,
                  height: AppSize.s30,
                  text: AppStringEM.add,
                  isLoading: widget.loadingDuration == true,
                  onPressed: () {
                    _validateForm(); // Validate the form on button press
                    if (_isFormValid) {
                      widget.onPressed();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class dummeyTextField extends StatefulWidget {
  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final Icon? suffixIcon;
  final FormFieldValidator<String>? validator;
  final double? width;
  final double? height;

  const dummeyTextField({
    Key? key,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _dummeyTextFieldState createState() => _dummeyTextFieldState();
}

class _dummeyTextFieldState extends State<dummeyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          controller: _controller,
          style: TextStyle(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: ColorManager.black,
          ),
          cursorColor: ColorManager.black,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              fontSize: FontSize.s10,
              color: ColorManager.greylight,
            ),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorManager.containerBorderGrey),
            ),
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
              onTap: () async {
                // Open the date picker when the calendar icon is tapped
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  // Format the date and set it into the text field
                  String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
                  _controller.text = formattedDate;
                }
              },
              child: widget.suffixIcon,
            )
                : null,
            // Do not show any icon if suffixIcon is null
          ),
          validator: widget.validator,
        ));
  }
}

///circuler border


class CICCDropDownExcell extends StatefulWidget {
  final double? width;
  final List<DropdownMenuItem<String>> items;
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;

  // ✅ NEW: control visible items count and item height
  final int visibleItemCount;
  final double itemHeight;

  const CICCDropDownExcell({
    Key? key,
    required this.items,
    this.width,
    this.initialValue,
    this.onChange,
    String? hintText,
    this.isEnabled,
    this.visibleItemCount = 4,     // ✅ default 4 items
    this.itemHeight = 48.0,        // ✅ default item height
  }) : super(key: key);

  @override
  _CIDetailsDropDownsState createState() => _CIDetailsDropDownsState();
}

class _CIDetailsDropDownsState extends State<CICCDropDownExcell> {
  String? _selectedValue;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showCustomDropdown() async {
    if (widget.isEnabled == false) return;

    final RenderBox renderBox =
    _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // ✅ Height for 4 items (scroll after this)
    final double maxMenuHeight = widget.visibleItemCount * widget.itemHeight;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),

      // ✅ This makes menu scrollable after max height
      constraints: BoxConstraints(
        maxHeight: maxMenuHeight,
        minWidth: size.width,
        maxWidth: size.width,
      ),

      items: widget.items.map((DropdownMenuItem<String> item) {
        return PopupMenuItem<String>(
          textStyle: DocumentTypeDataStyle.customTextStyle(context),
          value: item.value,

          // ✅ Fixed item height for consistent 4 items display
          height: widget.itemHeight,

          child: SizedBox(
            width: size.width - 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(item.value ?? ''),
            ),
          ),
        );
      }).toList(),

      color: ColorManager.white,
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
      });

      // ✅ null safe
      widget.onChange?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
          onTap: _showCustomDropdown,
          child: Container(
            padding: const EdgeInsets.only(left: AppPadding.p2),
            key: _dropdownKey,
            width: widget.width ?? AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorManager.containerBorderGrey,
                width: AppSize.s1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: Text(
                    _selectedValue ?? '',
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: AppPadding.p10),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}