import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';

import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';

///textfield constant widget
///todo prachi
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final double? width;
  final double? height;
  final double cursorHeight;
  final String text;
  //final TextStyle labelStyle;
  //final double labelFontSize;
  final Icon? suffixIcon;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final VoidCallback? onTapSuffixIcon;
  final void Function(String)? onChanged;
  final bool lettersOnly;
  bool? isEmail;

  /// Optional typography overrides. Callers that follow a specific design
  /// spec (e.g. the Enroll dialog) pass their own label/value styles; every
  /// other caller keeps the app-wide defaults.
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  /// Optional geometry overrides for callers following a design spec:
  /// [boxHeight] sizes the field's outer box and [contentPadding] controls how
  /// far the text sits from its border. Both default to the legacy values.
  final double? boxHeight;
  final EdgeInsetsGeometry? contentPadding;

  /// Optional border override. When [borderColor] is given the field draws a
  /// single 1px border of that colour in every state (radius [borderRadius],
  /// default 4) instead of the legacy theme outline + black focus ring.
  final Color? borderColor;
  final double? borderRadius;

  CustomTextField(
      {this.labelStyle,
      this.textStyle,
      this.boxHeight,
      this.contentPadding,
      this.borderColor,
      this.borderRadius,
      this.width,
      this.height,
      required this.cursorHeight,
      required this.text,
      // required this.labelStyle,
      this.suffixIcon,
      this.prefixIcon,
      required this.controller,
      this.focusNode,
      //required this.labelFontSize,
      this.onTapSuffixIcon,
      this.onChanged,
      this.lettersOnly = true,
      this.isEmail = false});

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder? _outlineBorder = borderColor == null
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4),
            borderSide: BorderSide(color: borderColor!, width: 1),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text.rich(
            TextSpan(
              text: text, // Main text
              style: labelStyle ??
                  AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style:
                      (labelStyle ?? AllPopupHeadings.customTextStyle(context))
                          .copyWith(
                    color: ColorManager.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          //Text(text,style: AllPopupHeadings.customTextStyle(context),),
        ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          width: width ?? AppSize.s250,
          height: boxHeight ?? AppSize.s40,
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p5),
            child: TextFormField(
              focusNode: focusNode,
              controller: controller,
              textAlign: TextAlign.start,
              style:
                  textStyle ?? DocumentTypeDataStyle.customTextStyle(context),
              textAlignVertical: TextAlignVertical.center,
              cursorHeight: cursorHeight,
              cursorColor: Colors.black,
              inputFormatters: [
                isEmail == true
                    ? FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    : FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z ]')), // no spaces, ever
                if (lettersOnly)
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
              decoration: FormDialogFields.decoration(context, InputDecoration(
                contentPadding: contentPadding ??
                    const EdgeInsets.only(
                        bottom: AppPadding.p3, top: AppPadding.p5, left: 4),
                border: _outlineBorder ?? const OutlineInputBorder(),
                enabledBorder: _outlineBorder,
                focusedBorder: _outlineBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(color: ColorManager.black),
                    ),
                // labelText: labelText,
                // labelStyle:DocumentTypeDataStyle.customTextStyle(context),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p14),
                  child: suffixIcon,
                ),
              )),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

///drop down text field
///todo prachi
// class CustomDropdownTextField extends StatefulWidget {
//   final String? value;
//   final List<String>? items;
//   final List<DropdownMenuItem<String>>? dropDownMenuList;
//   final String? hintText;
//   final String headText;
//   final void Function(String?)? onChanged;
//   final double? width;
//   final double? height;
//   final String? initialValue;
//
//   const CustomDropdownTextField({
//     Key? key,
//     this.dropDownMenuList,
//     required this.headText,
//     this.value,
//     this.items,
//     this.onChanged,
//     this.width,
//     this.height,
//     this.initialValue,
//     this.hintText,
//   }) : super(key: key);
//
//   @override
//   _CustomDropdownTextFieldState createState() =>
//       _CustomDropdownTextFieldState();
// }
//
// class _CustomDropdownTextFieldState extends State<CustomDropdownTextField> {
//   late String? _selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.value;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 5.0,bottom: 2),
//           child: Text(widget.headText,style: AllPopupHeadings.customTextStyle(context),),
//         ),
//         SizedBox(
//           width: AppSize.s250,
//           height: AppSize.s40,
//           child: Padding(
//             padding: const EdgeInsets.all(AppPadding.p5),
//             child: DropdownButtonFormField<String>(
//               icon:
//               Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Icon(Icons.arrow_drop_down_sharp, color: ColorManager.mediumgrey),
//               ),
//               value: _selectedValue,
//               items: widget.dropDownMenuList == null
//                   ? widget.items!.map((String value) {
//                 return DropdownMenuItem<String>(
//
//                   value: value,
//                   child: Text(
//                     value,
//                     style:DocumentTypeDataStyle.customTextStyle(context),
//                   ),
//                 );
//               }).toList()
//                   : widget.dropDownMenuList,
//               onChanged: (newValue) {
//                 setState(() {
//                   _selectedValue = newValue;
//                 });
//                 if (widget.onChanged != null) {
//                   widget.onChanged!(newValue);
//                 }
//               },
//               isExpanded: true,
//               decoration: InputDecoration(
//                 hoverColor: ColorManager.white,
//                 contentPadding: EdgeInsets.only(
//                     bottom: AppPadding.p3, top: AppPadding.p5, left: 4),
//                 border: OutlineInputBorder(),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: ColorManager.black),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class CustomDropdownTextField extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final String headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final FontWeight? fontwight;
  final double? fontsize;
  String? initialValue;
  final bool? isAstric;
  final IconData? icon;
  final Color? iconColor;
  final double? horiPadding;

  /// See [CustomTextField.labelStyle] — optional design-spec overrides.
  /// [textStyle] takes precedence over [fontsize] / [fontwight].
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  /// See [CustomTextField.boxHeight] — optional design-spec geometry.
  final double? boxHeight;
  final EdgeInsetsGeometry? contentPadding;

  /// See [CustomTextField.borderColor] — optional border override.
  final Color? borderColor;
  final double? borderRadius;

  CustomDropdownTextField({
    Key? key,
    this.labelStyle,
    this.textStyle,
    this.boxHeight,
    this.contentPadding,
    this.borderColor,
    this.borderRadius,
    this.isAstric = true,
    this.dropDownMenuList,
    required this.headText,
    this.value,
    this.items,
    this.horiPadding,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
    this.fontsize,
    this.icon,
    this.iconColor,
    this.fontwight,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldState createState() =>
      _CustomDropdownTextFieldState();
}

class _CustomDropdownTextFieldState extends State<CustomDropdownTextField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
    print('Initial value ${widget.initialValue}');
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _selectedValue = widget.value ?? widget.initialValue;
    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Initial value ${widget.initialValue}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.isAstric!
            ? Padding(
                padding:
                    EdgeInsets.only(left: widget.horiPadding ?? 5.0, bottom: 2),
                child: Text.rich(
                  TextSpan(
                    text: widget.isAstric! ? widget.headText : "", // Main text
                    style: widget.labelStyle ??
                        AllPopupHeadings.customTextStyle(context), // Main style
                    children: [
                      widget.isAstric!
                          ? TextSpan(
                              text: ' *', // Asterisk
                              style: (widget.labelStyle ??
                                      AllPopupHeadings.customTextStyle(context))
                                  .copyWith(
                                color: ColorManager.red, // Asterisk color
                              ),
                            )
                          : const TextSpan(
                              text: ' ', // Asterisk
                            )
                    ],
                  ),
                ),
                // Text(
                //   widget.headText,
                //   style: AllPopupHeadings.customTextStyle(context),
                // ),
              )
            : const Offstage(),
        SizedBox(
          width: widget.isAstric! ? AppSize.s250 : widget.width,
          height: widget.boxHeight ?? (FormDialogFields.isActive(context) ? 38 : AppSize.s40),
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal:
                      widget.horiPadding ?? 5), //const EdgeInsets.all(5),
              child: Container(
                padding: widget.contentPadding ?? (FormDialogFields.isActive(context) ? FormDialogFields.dropdownPadding : const EdgeInsets.only(bottom: 3, top: 5, left: 4)),
                decoration: widget.isAstric!
                    ? BoxDecoration(
                        border: Border.all(
                            color: widget.borderColor ?? (FormDialogFields.isActive(context) ? FormDialogFields.borderColor : Colors.grey)),
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? (FormDialogFields.isActive(context) ? FormDialogFields.radius : 4)),
                      )
                    : BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? (FormDialogFields.isActive(context) ? FormDialogFields.radius : 4)),
                      ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2.0, vertical: 3),
                        child: Text(
                            //_selectedValue ?? widget.initialValue ?? widget.hintText ?? 'Select',

                            widget.initialValue ?? widget.hintText ?? 'Select',
                            // The box is a fixed height, so a long value must
                            // ellipsize rather than wrap onto a second line
                            // that gets clipped.
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: widget.textStyle ?? (FormDialogFields.isActive(context) ? FormDialogFields.hintStyle : null) ??
                                TextStyle(
                                  fontWeight:
                                      widget.fontwight ?? FontWeight.w600,
                                  fontSize: widget.fontsize ?? FontSize.s13,
                                  color: ColorManager.mediumgrey,
                                  decoration: TextDecoration.none,
                                ) //DocumentTypeDataStyle.customTextStyle(context),
                            ),
                      ),
                    ),
                    Icon(widget.icon ?? Icons.arrow_drop_down_sharp,
                        color: widget.iconColor ?? Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomZoneFilterDropdownTextField extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final String headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final FontWeight? fontWeight;
  final double? fontSize;
  final String? initialValue;
  final bool? isAsterisk;
  final IconData? icon;
  final Color? iconColor;

  const CustomZoneFilterDropdownTextField({
    Key? key,
    this.isAsterisk = true,
    this.dropDownMenuList,
    required this.headText,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
    this.fontSize,
    this.icon,
    this.iconColor,
    this.fontWeight,
  }) : super(key: key);

  @override
  _CustomZoneFilterDropdownTextFieldState createState() =>
      _CustomZoneFilterDropdownTextFieldState();
}

class _CustomZoneFilterDropdownTextFieldState
    extends State<CustomZoneFilterDropdownTextField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        final items = widget.items ??
            widget.dropDownMenuList?.map((item) => item.value ?? '').toList() ??
            [];

        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          item,
                          style: DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(item);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double finalWidth = widget.width ?? AppSize.s200;
    final double finalHeight = widget.height ?? AppSize.s40;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.headText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5.0, bottom: 2),
            child: RichText(
              text: TextSpan(
                text: widget.headText,
                style: AllPopupHeadings.customTextStyle(context),
              ),
            ),
          ),
        SizedBox(
          width: finalWidth,
          height: finalHeight,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding:
                  const EdgeInsets.only(bottom: 3, top: 5, left: 4, right: 4),
              decoration: BoxDecoration(
                border: Border.all(color: ColorManager.containerBorderGrey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _selectedValue ?? widget.hintText ?? 'Select',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: widget.fontWeight ?? FontWeight.w600,
                        fontSize: widget.fontSize ?? AppSize.s13,
                        color: ColorManager.mediumgrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Icon(widget.icon ?? Icons.arrow_drop_down_sharp,
                      color: widget.iconColor ?? Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//
// class CustomZoneFilterDropdownTextField extends StatefulWidget {
//   final String? value;
//   final List<String>? items;
//   final List<DropdownMenuItem<String>>? dropDownMenuList;
//   final String? hintText;
//   final String headText;
//   final void Function(String?)? onChanged;
//   final double? width;
//   final double? height;
//   final FontWeight? fontwight;
//   final double? fontsize;
//   final String? initialValue;
//   final bool? isAstric;
//   final IconData? icon;
//   final Color? iconColor;
//
//   CustomZoneFilterDropdownTextField({
//     Key? key,
//     this.isAstric = true,
//     this.dropDownMenuList,
//     required this.headText,
//     this.value,
//     this.items,
//     this.onChanged,
//     this.width,
//     this.height,
//     this.initialValue,
//     this.hintText, this.fontsize,
//     this.icon, this.iconColor, this.fontwight,
//   }) : super(key: key);
//
//   @override
//   _CustomZoneFilterDropdownTextField createState() =>
//       _CustomZoneFilterDropdownTextField();
// }
//
// class _CustomZoneFilterDropdownTextField extends State<CustomZoneFilterDropdownTextField> {
//   String? _selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.value ?? widget.initialValue;
//   }
//
//   void _showDropdownDialog() async {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final offset = renderBox.localToGlobal(Offset.zero);
//     final size = renderBox.size;
//     final result = await showDialog<String>(
//       context: context,
//       barrierColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Stack(
//           children: [
//             Positioned(
//               left: offset.dx,
//               top: offset.dy + size.height,
//               child: Material(
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(4),
//                 child: Container(
//                   width: size.width,
//                   constraints: BoxConstraints(
//                     maxHeight: 250, // Restrict height for scroll
//                   ),
//                   child: SingleChildScrollView(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: widget.items?.length ?? widget.dropDownMenuList?.length ?? 0,
//                       itemBuilder: (context, index) {
//                         final item = widget.items != null
//                             ? widget.items![index]
//                             : widget.dropDownMenuList![index].value;
//                         return ListTile(
//                           title: Text(
//                             item!,
//                             style: DocumentTypeDataStyle.customTextStyle(context),
//                           ),
//                           onTap: () {
//                             Navigator.of(context).pop(item);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedValue = result;
//         widget.onChanged?.call(result);
//       });
//     }
//   }
//
//   // void _showDropdownDialog() {
//   //   final RenderBox renderBox = context.findRenderObject() as RenderBox;
//   //   final offset = renderBox.localToGlobal(Offset.zero);
//   //   final size = renderBox.size;
//   //
//   //   showDialog(
//   //     context: context,
//   //     barrierColor: Colors.transparent,
//   //     builder: (BuildContext context) {
//   //       return Stack(
//   //         children: [
//   //           Positioned(
//   //             left: offset.dx,
//   //             top: offset.dy + size.height,
//   //             child: Material(
//   //               elevation: 4,
//   //               borderRadius: BorderRadius.circular(4),
//   //               child: Container(
//   //                 width: widget.width ?? size.width,
//   //                 constraints: BoxConstraints(
//   //                   maxHeight: 250, // Limit height for scrolling
//   //                 ),
//   //                 child: Scrollbar(
//   //                   child: ListView.builder(
//   //
//   //                     shrinkWrap: true,
//   //                     children: widget.dropDownMenuList!.map((DropdownMenuItem<String> item) {
//   //                       return ListTile(
//   //                         title: Text(
//   //                           item.value ?? '',
//   //                           style: DocumentTypeDataStyle.customTextStyle(context),
//   //                         ),
//   //                         onTap: () {
//   //                           setState(() {
//   //                             _selectedValue = item.value;
//   //                             widget.onChanged?.call(item.value!);
//   //                           });
//   //                           Navigator.pop(context);
//   //                         },
//   //                       );
//   //                     }).toList(),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 5.0, bottom: 2),
//           child: RichText(
//             text: TextSpan(
//               text: widget.isAstric!?widget.headText:"", // Main text
//               style: AllPopupHeadings.customTextStyle(context), // Main style
//               children: [
//
//               ],
//             ),
//           ),
//           // Text(
//           //   widget.headText,
//           //   style: AllPopupHeadings.customTextStyle(context),
//           // ),
//         ),
//
//         SizedBox(
//           width: widget.isAstric!?AppSize.s200:widget.width,
//           height: AppSize.s40,
//           child: GestureDetector(
//             onTap: _showDropdownDialog,
//             child: Padding(
//               padding: const EdgeInsets.all(5),
//               child: Container(
//                 padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
//                 decoration:BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2.0,vertical: 3),
//                         child: Text(
//                             _selectedValue ?? widget.hintText ?? 'Select',
//                             style: TextStyle(
//                               fontWeight:widget.fontwight ?? FontWeight.w600,
//                               fontSize: widget.fontsize ?? FontSize.s13,
//                               color: ColorManager.mediumgrey,
//                               decoration: TextDecoration.none,
//                             ) //DocumentTypeDataStyle.customTextStyle(context),
//                         ),
//                       ),
//                     ),
//                     Icon(widget.icon ?? Icons.arrow_drop_down_sharp, color: widget.iconColor ?? Colors.grey),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

///
///
class CustomTextFieldPhone extends StatelessWidget {
  final TextEditingController controller;
  final double? width;
  final double? height;
  final double cursorHeight;
  final String text;
  final Icon? suffixIcon;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final VoidCallback? onTapSuffixIcon;
  final void Function(String)? onChanged;

  /// See [CustomTextField.labelStyle] — optional design-spec overrides.
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  /// Optional geometry overrides for callers following a design spec:
  /// [boxHeight] sizes the field's outer box and [contentPadding] controls how
  /// far the text sits from its border. Both default to the legacy values.
  final double? boxHeight;
  final EdgeInsetsGeometry? contentPadding;

  /// Optional border override. When [borderColor] is given the field draws a
  /// single 1px border of that colour in every state (radius [borderRadius],
  /// default 4) instead of the legacy theme outline + black focus ring.
  final Color? borderColor;
  final double? borderRadius;

  const CustomTextFieldPhone({
    this.labelStyle,
    this.textStyle,
    this.boxHeight,
    this.contentPadding,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
    required this.cursorHeight,
    required this.text,
    this.suffixIcon,
    this.prefixIcon,
    required this.controller,
    this.focusNode,
    this.onTapSuffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder? _outlineBorder = borderColor == null
        ? null
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4),
            borderSide: BorderSide(color: borderColor!, width: 1),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text.rich(
            TextSpan(
              text: text, // Main text
              style: labelStyle ??
                  AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style:
                      (labelStyle ?? AllPopupHeadings.customTextStyle(context))
                          .copyWith(
                    color: ColorManager.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          //Text(text,style: AllPopupHeadings.customTextStyle(context),),
        ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          width: width ?? AppSize.s250,
          height: boxHeight ?? AppSize.s40,
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p5),
            child: TextFormField(
              focusNode: focusNode,
              controller: controller,
              textAlign: TextAlign.start,
              style:
                  textStyle ?? DocumentTypeDataStyle.customTextStyle(context),
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.black,
              cursorHeight: cursorHeight,
              decoration: FormDialogFields.decoration(context, InputDecoration(
                contentPadding: contentPadding ??
                    const EdgeInsets.only(
                        bottom: AppPadding.p3, top: AppPadding.p5, left: 4),
                border: _outlineBorder ?? const OutlineInputBorder(),
                enabledBorder: _outlineBorder,
                focusedBorder: _outlineBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(color: ColorManager.black),
                    ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p14),
                  child: suffixIcon,
                ),
              )),
              onChanged: onChanged,
              inputFormatters: [
                PhoneNumberInputFormatter(),
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

class CustomDropdownTextFieldwidh extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;

  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  String? initialValue;
  double? menuMaxHeight;

  CustomDropdownTextFieldwidh({
    Key? key,
    this.dropDownMenuList,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText,
    this.menuMaxHeight = 250,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldwidhState createState() =>
      _CustomDropdownTextFieldwidhState();
}

class _CustomDropdownTextFieldwidhState
    extends State<CustomDropdownTextFieldwidh> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: BoxConstraints(
                    maxHeight: widget.menuMaxHeight!,
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // width: widget.widthone,
          height: widget.height ?? AppSize.s30,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedValue ?? widget.hintText ?? 'Select',
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                  const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clinical popup dropdown
class ClinicalConstDropDown extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;

  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  String? initialValue;
  ClinicalConstDropDown({
    Key? key,
    this.dropDownMenuList,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText,
  }) : super(key: key);

  @override
  State<ClinicalConstDropDown> createState() => _ClinicalConstDropDownState();
}

class _ClinicalConstDropDownState extends State<ClinicalConstDropDown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // width: widget.widthone,
          height: widget.height ?? AppSize.s30,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 3),
                      child: Text(
                        _selectedValue != widget.initialValue
                            ? 'Select'
                            : _selectedValue!,
                        style: DocumentTypeDataStyle.customTextStyle(context),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///
class CustomDropdownEMDashboard extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;

  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  final String? initialValue;
  const CustomDropdownEMDashboard({
    Key? key,
    this.dropDownMenuList,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText,
  }) : super(key: key);

  @override
  State<CustomDropdownEMDashboard> createState() =>
      _CustomDropdownEMDashboardState();
}

class _CustomDropdownEMDashboardState extends State<CustomDropdownEMDashboard> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // width: widget.widthone,
          height: widget.height ?? AppSize.s25,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC9C9C9), width: 0.86),
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent, // Ensure opacity 0 effect
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedValue ?? widget.hintText ?? 'Select',
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                  const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropDownNew extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final double? labelFontSize;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final String? initialValue;

  const CustomDropDownNew({
    super.key,
    this.value,
    required this.items,
    required this.labelText,
    this.labelStyle,
    this.labelFontSize,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
  });

  @override
  State<CustomDropDownNew> createState() => _CustomDropDownNewState();
}

class _CustomDropDownNewState extends State<CustomDropDownNew> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    final valueToUse = widget.value ?? widget.initialValue;
    _selectedValue = widget.items.contains(valueToUse) ? valueToUse : null;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title: Text(
                            item,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdownDialog,
      child: SizedBox(
        width: widget.width ?? 354,
        height: widget.height ?? 40,
        child: InputDecorator(
          isEmpty: _selectedValue == null,
          decoration: FormDialogFields.decoration(context, InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(left: 5, bottom: 8),
            border: const UnderlineInputBorder(),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelText: widget.labelText,
            labelStyle: widget.labelStyle?.copyWith(
                  fontSize: widget.labelFontSize,
                ) ??
                TextStyle(
                  fontSize: widget.labelFontSize,
                  color: ColorManager.mediumgrey,
                ),
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  _selectedValue ?? widget.hintText ?? '',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: _selectedValue != null
                      ? DocumentTypeDataStyle.customTextStyle(context)
                      : DocumentTypeDataStyle.customTextStyle(context),
                ),
              ),
              Icon(Icons.arrow_drop_down_sharp, color: ColorManager.black),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDropDown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final double? labelFontSize;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final String? initialValue;
  const CustomDropDown({
    super.key,
    this.value,
    required this.items,
    required this.labelText,
    this.labelStyle,
    this.labelFontSize,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 354,
      height: AppSize.s40,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p5),
        child: DropdownButtonFormField<String>(
          icon:
              Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime),
          value: _selectedValue,
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: DocumentTypeDataStyle.customTextStyle(context),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
          isExpanded: true,
          decoration: FormDialogFields.decoration(context, InputDecoration(
            contentPadding: const EdgeInsets.only(
                bottom: AppPadding.p3, top: AppPadding.p5, left: AppPadding.p2),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorManager.black),
            ),
            labelText: widget.labelText,
            labelStyle: widget.labelStyle?.copyWith(
                fontSize: widget.labelFontSize, color: ColorManager.mediumgrey),
          )),
        ),
      ),
    );
  }
}

class HRUManageDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Color textColor;
  // final TextStyle? labelStyle;
  final double labelFontSize;
  final List<String> items;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const HRUManageDropdown({
    Key? key,
    required this.controller,
    this.labelText,
    //this.labelStyle,
    required this.labelFontSize,
    required this.items,
    this.errorText,
    this.onChanged,
    this.hintText,
    this.focusNode,
    this.textColor = const Color(0xff686464),
  }) : super(key: key);

  @override
  State<HRUManageDropdown> createState() => _HRUManageDropdownState();
}

class _HRUManageDropdownState extends State<HRUManageDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  int _highlightedIndex = -1;
  late final FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _effectiveFocusNode.requestFocus();
    _highlightedIndex = -1;
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height,
                width: size.width,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final isHighlighted = index == _highlightedIndex;
                        return ListTile(
                          tileColor: isHighlighted
                              ? Colors.blue.withOpacity(0.12)
                              : null,
                          title: Text(
                            widget.items[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.s13,
                              color: isHighlighted
                                  ? Colors.blue
                                  : ColorManager.mediumgrey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          onTap: () => _selectItem(index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context)?.insert(_overlayEntry!);
    if (mounted) setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _highlightedIndex = -1;
    if (mounted) setState(() => _isDropdownOpen = false);
  }

  void _selectItem(int index) {
    final val = widget.items[index];
    widget.controller.text = val;
    widget.onChanged?.call(val);
    _closeDropdown();
  }

  void _moveHighlight(int delta) {
    if (!_isDropdownOpen || widget.items.isEmpty) return;
    final next = (_highlightedIndex + delta).clamp(0, widget.items.length - 1);
    if (next != _highlightedIndex) {
      _highlightedIndex = next;
      _overlayEntry?.markNeedsBuild();
    }
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      if (_isDropdownOpen && _highlightedIndex >= 0) {
        _selectItem(_highlightedIndex);
      } else {
        _toggleDropdown();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      if (!_isDropdownOpen) _openDropdown();
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (_isDropdownOpen) _closeDropdown();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _effectiveFocusNode.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      onKeyEvent: (_, event) => _handleKey(event),
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null)
              Text(
                widget.labelText!,
                style: TableSubHeading.customTextStyle(context),
              ),
            Builder(
              builder: (ctx) {
                final isFocused = Focus.of(ctx).hasFocus;
                return Container(
                  key: _dropdownKey,
                  width: 354,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isFocused ? ColorManager.blueprime : Colors.grey,
                      width: isFocused ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.controller.text.isEmpty
                            ? widget.hintText ?? ''
                            : widget.controller.text,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
            widget.errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      widget.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                : const Offstage(),
          ],
        ),
      ),
    );
  }
}

///clinical ropdown
class PatientCustomDropDown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final double? labelFontSize;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final String? initialValue;
  const PatientCustomDropDown({
    super.key,
    this.value,
    required this.items,
    required this.labelText,
    this.labelStyle,
    this.labelFontSize,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
  });

  @override
  State<PatientCustomDropDown> createState() => _PatientCustomDropDownState();
}

class _PatientCustomDropDownState extends State<PatientCustomDropDown> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: const Color(0xff686464).withOpacity(0.5),
            width: 1), // Black border
        borderRadius: BorderRadius.circular(6), // Rounded corners
      ),
      height: 31,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      child: DropdownButtonFormField<String>(
          icon: Icon(
            Icons.arrow_drop_down_sharp,
            color: ColorManager.mediumgrey,
          ),
          value: _selectedValue,
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: SearchDropdownConst.customTextStyle(context),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
          style: SearchDropdownConst.customTextStyle(context),
          isExpanded: true,
          decoration: const InputDecoration.collapsed(hintText: '')),
    );
  }
}

/////////////

///dont delete it is perfectly fine working dropdown code
// class PatientCustomDropDown extends StatefulWidget {
//   final String? value;
//   final List<String> items;
//   final String labelText;
//   final String? hintText;
//  // final TextStyle? labelStyle;
//   final double? labelFontSize;
//   final void Function(String?)? onChanged;
//   final double? width;
//   final double? height;
//   final String? initialValue;
//
//   const PatientCustomDropDown({
//     super.key,
//     this.value,
//     required this.items,
//     required this.labelText,
//    // this.labelStyle,
//     this.labelFontSize,
//     this.onChanged,
//     this.width,
//     this.height,
//     this.initialValue,
//     this.hintText,
//   });
//
//   @override
//   State<PatientCustomDropDown> createState() => _PatientCustomDropDownState();
// }
//
// class _PatientCustomDropDownState extends State<PatientCustomDropDown> {
//   late String? _selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.value;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonHideUnderline(
//       child: DropdownButton2<String>(
//         value: _selectedValue,
//         hint: Text(
//           widget.hintText ?? '',
//           style: SearchDropdownConst.customTextStyle(context),
//         ),
//         items: widget.items.map((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(
//               value,
//               style: SearchDropdownConst.customTextStyle(context),
//             ),
//           );
//         }).toList(),
//         onChanged: (newValue) {
//           setState(() {
//             _selectedValue = newValue;
//           });
//           if (widget.onChanged != null) {
//             widget.onChanged!(newValue);
//           }
//         },
//         buttonStyleData: ButtonStyleData(
//           height: widget.height ?? 30,
//           width: widget.width ?? 170,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(
//               color: const Color(0xff686464).withOpacity(0.5),
//               width: 1,
//             ),
//             borderRadius: BorderRadius.circular(6),
//           )
//         ),
//         iconStyleData: IconStyleData(
//           icon: Icon(
//             Icons.arrow_drop_down_sharp,
//             color: ColorManager.mediumgrey,
//           ),
//           iconSize: 24,
//         ),
//         dropdownStyleData: DropdownStyleData(
//           maxHeight: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(6),
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
//

///
class CustomDropdownTextFieldpp<T> extends StatefulWidget {
  final T? value; // Changed to generic type
  final List<T>? items; // Changed to generic type
  final String Function(T)?
      itemLabel; // Function to get the label from the item
  final String headText;
  final void Function(T?)? onChanged;
  final double? width;
  final double? height;
  final T? initialValue;

  const CustomDropdownTextFieldpp({
    Key? key,
    required this.headText,
    this.value,
    this.items,
    required this.itemLabel,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldppState<T> createState() =>
      _CustomDropdownTextFieldppState<T>();
}

class _CustomDropdownTextFieldppState<T>
    extends State<CustomDropdownTextFieldpp<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            widget.headText,
            style: AllPopupHeadings.customTextStyle(context),
          ),
        ),
        SizedBox(
          width: widget.width ?? AppSize.s250,
          height: widget.height ?? AppSize.s40,
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p5),
            child: DropdownButtonFormField<T>(
              icon: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(Icons.arrow_drop_down_sharp,
                    color: ColorManager.mediumgrey),
              ),
              value: _selectedValue,
              items: _buildDropdownMenuItems(),
              onChanged: (newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(newValue);
                }
              },
              isExpanded: true,
              decoration: FormDialogFields.decoration(context, InputDecoration(
                hoverColor: ColorManager.white,
                contentPadding: const EdgeInsets.only(
                  bottom: AppPadding.p3,
                  top: AppPadding.p5,
                  left: 4,
                ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.black),
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }

  // Build dropdown items based on the items provided
  List<DropdownMenuItem<T>> _buildDropdownMenuItems() {
    if (widget.items == null || widget.items!.isEmpty) return [];

    return widget.items!.map((T item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(
          widget.itemLabel!(
              item), // Use the itemLabel function to get the display text
          style: DocumentTypeDataStyle.customTextStyle(context),
        ),
      );
    }).toList();
  }
}

///offer letter screen
class SuffixDropDown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? hintText;
  final double? width;
  final double? height;

  const SuffixDropDown({
    Key? key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<SuffixDropDown> createState() => _SuffixDropDownState();
}

class _SuffixDropDownState extends State<SuffixDropDown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.items.first;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          title: Text(
                            item,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdownDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedValue ?? widget.hintText ?? 'Select',
              style: DocumentTypeDataStyle.customTextStyle(context),
            ),
            const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownsmi extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final String headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final FontWeight? fontwight;
  final double? fontsize;
  final String? initialValue;
  final bool? isAstric;
  final IconData? icon;
  final Color? iconColor;

  const CustomDropdownsmi({
    Key? key,
    this.isAstric = true,
    this.dropDownMenuList,
    required this.headText,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText,
    this.fontsize,
    this.icon,
    this.iconColor,
    this.fontwight,
  }) : super(key: key);

  @override
  _CustomDropdownsmiState createState() => _CustomDropdownsmiState();
}

class _CustomDropdownsmiState extends State<CustomDropdownsmi> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<String>(
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
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style:
                                DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with optional asterisk
        widget.isAstric!
            ? Padding(
                padding: const EdgeInsets.only(left: 5.0, bottom: 2),
                child: RichText(
                  text: TextSpan(
                    text: widget.headText,
                    style: AllPopupHeadings.customTextStyle(context),
                    children: [
                      TextSpan(
                        text: ' *',
                        style:
                            AllPopupHeadings.customTextStyle(context).copyWith(
                          color: ColorManager.red,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Offstage(),

        // Dropdown field with underline
        SizedBox(
          width: widget.width ?? AppSize.s250,
          height: AppSize.s40,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey, // Underline color
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 3),
                      child: Text(_selectedValue ?? widget.hintText ?? 'Select',
                          style: CustomTextStylesCommon.commonStyle(
                              color: const Color(0xFF7F7F7F),
                              fontWeight: FontWeight.w400,
                              fontSize: 12)),
                    ),
                  ),
                  Icon(
                    widget.icon ?? Icons.arrow_drop_down_sharp,
                    color: widget.iconColor ?? Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TerminationPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final Color textColor;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  // final String? errorText;

  const TerminationPhoneField({
    Key? key,
    required this.controller,
    this.text = 'Phone No.',
    this.textColor = const Color(0xff686464),
    this.focusNode,
    this.onChanged,
    // this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: FormDialogFields.isActive(context) ? FormDialogFields.labelStyle : ConstTextFieldStyles.customTextStyle(textColor: textColor),
          ),
          const SizedBox(height: 5),
          Container(
            width: 300,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                color: FormDialogFields.isActive(context) ? FormDialogFields.borderColor : const Color(0xFFB1B1B1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              cursorHeight: 17,
              cursorColor: Colors.black,
              textAlignVertical: TextAlignVertical.center,
              decoration: FormDialogFields.decoration(context, const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: 22,
                  left: AppPadding.p15,
                ),
              )),
              style: DocumentTypeDataStyle.customTextStyle(context),
              onChanged: onChanged,
              inputFormatters: [
                PhoneNumberInputFormatter(),
              ],
            ),
          ),
          // if (errorText != null)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 2, left: 4),
          //     child: Text(
          //       errorText!,
          //       style: CommonErrorMsg.customTextStyle(context),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
