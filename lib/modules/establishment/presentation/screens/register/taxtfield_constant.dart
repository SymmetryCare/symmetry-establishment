import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/form_dialog_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';




///for emailid only

import 'package:flutter/services.dart'; // 👈 needed for FilteringTextInputFormatter

class CustomTextFieldForEmail extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final String? hintText;
  final hintStyle;
  final prefixStyle;
  final String? prefixText;
  final double? cursorHeight;

  CustomTextFieldForEmail({
    Key? key,
    this.controller,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.prefixText,
    this.prefixStyle,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.padding,
    this.width,
    this.height,
    this.cursorHeight,
    this.onTap,
  }) : super(key: key);

  /// Default email validator — used when no custom validator is passed
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextFormField(
          controller: controller,
          cursorHeight: cursorHeight,
          cursorColor: Colors.black,
          cursorWidth: 1.5,

          // 🚫 Blocks spaces (and all whitespace) from being typed or pasted
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],

          decoration: FormDialogFields.decoration(context, InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            labelText: labelText,
            labelStyle: onlyFormDataStyle.customTextStyle(context),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.only(
                bottom: AppPadding.p3,
                top: AppPadding.p4,
                left: AppPadding.p12),
          )),

          // Email keyboard by default (caller can still override)
          keyboardType: keyboardType ?? TextInputType.emailAddress,
          textInputAction: textInputAction,
          style: onlyFormDataStyle.customTextStyle(context),
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,

          // Uses caller's validator if provided, otherwise the built-in email check
          validator: validator ?? emailValidator,

          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ),
    );
  }
}

/// us phone number
///
class CustomTextFieldRegisterPhone extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;
  final String? prefixText;
  final double? cursorHeight;
  final int? maxLength;


  CustomTextFieldRegisterPhone({
    Key? key,
    // Default to false
    this.maxLength,
    this.controller,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.prefixText,
    this.prefixStyle,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.padding,
    this.width,
    this.height,
    this.cursorHeight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextFormField(
          controller: controller,
          cursorHeight: cursorHeight,
          cursorColor: Colors.black,
          cursorWidth: 1.5,
          decoration: FormDialogFields.decoration(context, InputDecoration(
            contentPadding: const EdgeInsets.only(
                bottom: AppPadding.p3,
                top: AppPadding.p4,
                left: AppPadding.p12
            ),
            hintText: hintText,
            hintStyle: hintStyle,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color(0xffB1B1B1),
              ),
            ),
            labelText: labelText,
            labelStyle: DocumentTypeDataStyle.customTextStyle(context),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          )),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style:DocumentTypeDataStyle.customText12Style(context),
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: [
            PhoneNumberInputFormatter(),
          ],
        ),
      ),
    );
  }
}
///
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    final StringBuffer newText = StringBuffer();

    text = text.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // Add formatting based on length
    if (text.length > 0) {
      newText.write('(');
    }
    if (text.length > 3) {
      newText.write('${text.substring(0, 3)}) ');
      text = text.substring(3);
    }
    if (text.length > 3) {
      newText.write('${text.substring(0, 3)}-');
      text = text.substring(3);
    }
    newText.write(text);

    return newValue.copyWith(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
///
///





///first letter capital
class CustomTextFieldRegister extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;
  final String? prefixText;
  final double? cursorHeight;
  final int? maxLength;
  bool isDigitSelect;
  final bool readOnly;
  final bool? phoneNumberField;
  final String? header;
  final TextStyle? headerStyle;
  // NEW: optional custom formatters — when provided, these take priority
  // over isDigitSelect/phoneNumberField
  final List<TextInputFormatter>? inputFormatters;

  CustomTextFieldRegister({
    Key? key,
    this.phoneNumberField = false,
    this.isDigitSelect = false, // Default to false
    this.maxLength,
    this.controller,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.prefixText,
    this.prefixStyle,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.padding,
    this.width,
    this.height,
    this.cursorHeight,
    this.onTap,
    this.readOnly = false,
    this.header,
    this.headerStyle,
    this.inputFormatters, // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextFormField(
          controller: controller,
          cursorHeight: cursorHeight,
          cursorColor: Colors.black,
          cursorWidth: 1.5,
          decoration: FormDialogFields.decoration(context, InputDecoration(
            contentPadding: const EdgeInsets.only(
                bottom: AppPadding.p3,
                top: AppPadding.p4,
                left: AppPadding.p12
            ),
            hintText: hintText,
            hintStyle: hintStyle,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            labelText: labelText,
            labelStyle: DocumentTypeDataStyle.customTextStyle(context),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          )),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style:DocumentTypeDataStyle.customTextStyle(context),
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          focusNode: focusNode,
          readOnly: readOnly,
          onFieldSubmitted: onFieldSubmitted,
          // UPDATED: custom inputFormatters (if passed) take priority over
          // the isDigitSelect / phoneNumberField defaults
          inputFormatters: inputFormatters ??
              (isDigitSelect
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : (phoneNumberField!
                  ? [PhoneNumberInputFormatter()]
                  : [])),
        ),
      ),
    );

    if (header != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header!,
            style: headerStyle ?? AllPopupHeadings.customTextStyle(context),
          ),
          const SizedBox(height: AppSize.s5),
          field,
        ],
      );
    }
    return field;
  }
}

///normal textfield
class FirstHRTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;   // ✅ kept for date pickers (onTap)
  final VoidCallback? onChanged;  // ✅ NEW — fires on every keystroke
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormated;
  final FocusNode? focusNode;

  const FirstHRTextFConst({
    Key? key,
    this.inputFormated,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.onChanged,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.focusNode,
  }) : super(key: key);

  @override
  State<FirstHRTextFConst> createState() => _FirstHRTextFConstState();
}

class _FirstHRTextFConstState extends State<FirstHRTextFConst> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: FormDialogFields.isActive(context) ? FormDialogFields.labelStyle : ConstTextFieldStyles.customTextStyle(textColor: widget.textColor),
          ),
          const SizedBox(height: 5),
          Container(
            width: 300,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: FormDialogFields.isActive(context) ? FormDialogFields.borderColor : const Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              enabled: widget.enable == null ? true : false,
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly ?? false,
              cursorHeight: 17,
              cursorColor: Colors.black,
              decoration: FormDialogFields.decoration(context, InputDecoration(
                suffixIcon: widget.icon,
                prefix: widget.prefixWidget,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  bottom: AppPadding.p18,
                  left: AppPadding.p15,
                ),
              )),
              style: DocumentTypeDataStyle.customTextStyle(context),
              onTap: widget.onChange,           // ✅ date pickers / file pickers
              onChanged: (_) => widget.onChanged?.call(), // ✅ hides error on keystroke
              inputFormatters: widget.inputFormated ?? [],
            ),
          ),
        ],
      ),
    );
  }
}

///ssn number
class CustomTextFieldSSn extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;
  final String? prefixText;
  final double? cursorHeight;
  final int? maxLength;
  final bool capitalIsSelect;
  final bool? phoneNumberField;

  CustomTextFieldSSn({
    Key? key,
    this.phoneNumberField = false,
    this.capitalIsSelect = false, // Default to false
    this.maxLength,
    this.controller,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.prefixText,
    this.prefixStyle,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.padding,
    this.width,
    this.height,
    this.cursorHeight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextFormField(
          controller: controller,
          cursorHeight: cursorHeight,
          cursorColor: Colors.black,
          cursorWidth: 1.5,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: FormDialogFields.decoration(context, InputDecoration(
            contentPadding: const EdgeInsets.only(
                bottom: AppPadding.p3,
                top: AppPadding.p4,
                left: AppPadding.p12
            ),
            hintText: hintText,
            hintStyle: hintStyle,
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide:  const BorderSide(
                color: Color(0xFFB1B1B1),
              ),
            ),
            labelText: labelText,
            labelStyle: DocumentTypeDataStyle.customTextStyle(context),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          )),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style:DocumentTypeDataStyle.customText12Style(context),
          obscureText: obscureText,
          autofocus: autofocus,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Only allow digits
            LengthLimitingTextInputFormatter(9), // Limit to 9 digits
          ],

        ),
      ),
    );
  }
}

///only number
class CustomRegisternumberonly extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  VoidCallback? onTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;
  final String? prefixText;
  final double? cursorHeight;
  final int? maxLength;
  final bool capitalIsSelect;
  final bool readOnly;
  final bool? phoneNumberField;

  CustomRegisternumberonly({
    Key? key,
    this.phoneNumberField = false,
    this.capitalIsSelect = false, // Default to false
    this.maxLength,
    this.controller,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.prefixText,
    this.prefixStyle,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
    this.padding,
    this.width,
    this.height,
    this.cursorHeight,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: TextFormField(
            controller: controller,
            cursorHeight: cursorHeight,
            cursorColor: Colors.black,
            cursorWidth: 1.5,
            decoration: FormDialogFields.decoration(context, InputDecoration(
              contentPadding: const EdgeInsets.only(
                  bottom: AppPadding.p3,
                  top: AppPadding.p4,
                  left: AppPadding.p12
              ),
              hintText: hintText,
              hintStyle: hintStyle,
              prefixText: prefixText,
              prefixStyle: prefixStyle,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide:  const BorderSide(
                  color: Color(0xFFB1B1B1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide:  const BorderSide(
                  color: Color(0xFFB1B1B1),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide:  const BorderSide(
                  color: Color(0xFFB1B1B1),
                ),
              ),
              labelText: labelText,
              labelStyle: DocumentTypeDataStyle.customTextStyle(context),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            )),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style:DocumentTypeDataStyle.customTextStyle(context),
            obscureText: obscureText,
            autofocus: autofocus,
            enabled: enabled,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator,
            focusNode: focusNode,
            readOnly: readOnly,
            onFieldSubmitted: onFieldSubmitted,
            inputFormatters:  [
              FilteringTextInputFormatter.digitsOnly,
            ]

        ),
      ),
    );
  }
}
///