import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

class CustomTextFieldOfferScreen extends StatelessWidget {
  final TextEditingController controller;
  final double? height;
  final FormFieldValidator<String>? validator;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  VoidCallback? onTap;

  CustomTextFieldOfferScreen(
      {super.key,
      required this.controller,
      this.height,
      this.validator,
      this.onChanged,
      this.hintText,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    // Border is identical in every state — the field is read-only and only
    // opens the date picker, so it never shows a "focused" style.
    final OutlineInputBorder _border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xffD8DDE1), width: 1.0),
    );

    return SizedBox(
      // FIX: was a hardcoded `width: 300`. Every caller now lays these fields
      // out inside an Expanded column, so a fixed width made the three date
      // fields overflow/mismatch their column instead of filling it evenly
      // the way the design does.
      width: double.infinity,
      height: height ?? 32,
      child: TextFormField(
        readOnly: true,
        style: DocumentTypeDataStyle.customTextStyle(context),
        onChanged: onChanged,
        cursorColor: Colors.black,
        controller: controller,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
          hintText: hintText, // Add your hint text here
          // Design spec colour for the date placeholders; size/weight stay
          // on the shared style.
          hintStyle: onlyFormDataStyle
              .customTextStyle(context)
              .copyWith(color: const Color(0xFF757575)),
          labelStyle: DocumentTypeDataStyle.customTextStyle(context),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 30,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SvgPicture.asset(
              'images/calendar_icon.svg',
              width: 16,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

///

class CustomDropdownFormField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final double? height;

  const CustomDropdownFormField({
    Key? key,
    required this.hintText,
    this.labelText,
    required this.items,
    this.value,
    this.height,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  String? selectedValue;
  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
              bottom: AppPadding.p3, top: AppPadding.p5, left: 4),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffB1B1B1), width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffB1B1B1), width: 1.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffB1B1B1), width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: DocumentTypeDataStyle.customTextStyle(context),
          labelText: widget.labelText,
          labelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xff686464),
          ),
        ),
        value: widget.value,
        items: widget.items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: DocumentTypeDataStyle.customTextStyle(context),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedValue = newValue;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(newValue);
          }
        },
        icon: Icon(Icons.arrow_drop_down, color: ColorManager.mediumgrey),
      ),
    );
  }
}

////

class CustomDropdownTextFieldpadding extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;

  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  final String? initialValue;

  const CustomDropdownTextFieldpadding({
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
  _CustomDropdownTextFieldpaddingState createState() =>
      _CustomDropdownTextFieldpaddingState();
}

class _CustomDropdownTextFieldpaddingState
    extends State<CustomDropdownTextFieldpadding> {
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
          height: widget.height ?? AppSize.s30,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _selectedValue ?? widget.hintText ?? 'Select',
                      style: DocumentTypeDataStyle.customTextStyle(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
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

///
///
///
