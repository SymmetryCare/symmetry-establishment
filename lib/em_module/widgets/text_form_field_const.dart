import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../emr_module/emr_tab/emr_const/calender_popup_const.dart';

///normal textfield

class SMTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final ValueChanged<String>? onChangeField;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? width;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;
  final bool isAsteric;
  final bool isIcon;
  final bool? onlyAllowNumbers;

  SMTextFConst({
    Key? key,
    this.onChangeField,
    this.focusNode,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.width, this.inputFormated,
    this.showDatePicker = false, this.suffixIcon,
    this.isAsteric = true, this.isIcon = false, this.onlyAllowNumbers = false,
  }) : super(key: key);

  @override
  State<SMTextFConst> createState() => _SMTextFConstState();
}

class _SMTextFConstState extends State<SMTextFConst> {
  // late TextEditingController _controller;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }
  @override
  Widget build(BuildContext context) {
    String? errorText;
    return Padding(
      padding:  const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: widget.text, // Main text
                  style: AllPopupHeadings.customTextStyle(context), // Main style
                  children: widget.isAsteric
                      ? [
                    TextSpan(
                      text: ' *', // Asterisk
                      style: AllPopupHeadings.customTextStyle(context).copyWith(
                        color: ColorManager.red, // Asterisk color
                      ),
                    ),
                  ]
                      : [],
                ),
              ),
             widget.isIcon ? InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: (){},
                  child: SvgPicture.asset(
                    'images/sm/sm_refferal/i_circle.svg',
                    height: IconSize.I20,
                    width: IconSize.I20,
                  ))
                 : SizedBox()
            ],
          ),
          SizedBox(
            height: AppSize.s5,
          ),
          Container(
            width: widget.width ?? AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              focusNode: widget.focusNode,
              autofocus: false,
              enabled: widget.enable == null ? true : false,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              //cursorHeight: 17,
              onChanged: widget.onChangeField,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                suffixIcon: widget.showDatePicker
                    ? GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Icon(Icons.calendar_month_outlined),
                )
                    : widget.icon,
                prefix: widget.prefixWidget,
                prefixIcon: widget.suffixIcon,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom:18, left: AppPadding.p10),
              ),
              style: TableSubHeading.customTextStyleWithColor(context,widget.textColor),
              //validator: widget.validator,
              onTap: widget.onChange,
              validator: widget.validator,
              inputFormatters: widget.onlyAllowNumbers!
                  ? [FilteringTextInputFormatter.digitsOnly]  // Allow only digits if true
                  : widget.inputFormated,
              // onTap: widget.onChange,
            ),
          ),
        ],
      ),
    );
  }
}
///normal textfield with asteric
class SMTextfieldAstericZipcode extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? width;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;
  final Function(String)? onChanged;
  final bool? onlyAllowNumbers;
  final String? hintText;

  SMTextfieldAstericZipcode({
    Key? key,
    this.focusNode,
    this.hintText = '',
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.width,
    this.inputFormated,
    this.showDatePicker = false,
    this.suffixIcon, this.onChanged, this.onlyAllowNumbers = false,
  }) : super(key: key);

  @override
  State<SMTextfieldAstericZipcode> createState() => _SMTextfieldAstericZipcodeState();
}

class _SMTextfieldAstericZipcodeState extends State<SMTextfieldAstericZipcode> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using RichText for label with red asterisk
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: Colors.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: widget.width ?? AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              focusNode: widget.focusNode,
              autofocus: true,
              enabled: widget.enable == null ? true : false,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              //cursorHeight: 16,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                suffixIcon: widget.showDatePicker
                    ? GestureDetector(
                  onTap: () => _selectDate(context),
                  child: const Icon(Icons.calendar_month_outlined),
                )
                    : widget.icon,
                prefix: widget.prefixWidget,
                prefixIcon: widget.suffixIcon,
                hintText: widget.hintText,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 18, left: AppPadding.p10,),
              ),
              style: TableSubHeading.customTextStyle(context),
              onTap: widget.onChange,
              onChanged: widget.onChanged,
              validator: widget.validator,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                LengthLimitingTextInputFormatter(9), // Limit to 9 digits
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/// 9 digit constant text field for zipcode
class SMTextfieldAsteric extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? width;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;
  final Function(String)? onChanged;
  final bool? onlyAllowNumbers;
  final String? hintText;

  SMTextfieldAsteric({
    Key? key,
    this.focusNode,
    this.hintText = '',
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.width,
    this.inputFormated,
    this.showDatePicker = false,
    this.suffixIcon, this.onChanged, this.onlyAllowNumbers = false,
  }) : super(key: key);

  @override
  State<SMTextfieldAsteric> createState() => _SMTextfieldAstericState();
}

class _SMTextfieldAstericState extends State<SMTextfieldAsteric> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using RichText for label with red asterisk
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: Colors.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: widget.width ?? AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              focusNode: widget.focusNode,
              autofocus: true,
              enabled: widget.enable == null ? true : false,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              //cursorHeight: 16,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                suffixIcon: widget.showDatePicker
                    ? GestureDetector(
                  onTap: () => _selectDate(context),
                  child: const Icon(Icons.calendar_month_outlined),
                )
                    : widget.icon,
                prefix: widget.prefixWidget,
                prefixIcon: widget.suffixIcon,
                hintText: widget.hintText,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 18, left: AppPadding.p10,),
              ),
              style: TableSubHeading.customTextStyle(context),
              onTap: widget.onChange,
              onChanged: widget.onChanged,
              validator: widget.validator,
              inputFormatters: widget.onlyAllowNumbers!
                  ? [FilteringTextInputFormatter.digitsOnly]  // Allow only digits if true
                  : widget.inputFormated,
            ),
          ),
        ],
      ),
    );
  }
}


///number only
class SMNumberTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final String text;
  final Color textColor;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final bool? isAsteric;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? width;
  final Icon? suffixIcon;

  SMNumberTextFConst({
    Key? key,
    this.focusNode,
    required this.controller,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.onChange,
    this.readOnly,
    this.enable,
    this.isAsteric,
    this.validator,
    this.prefixWidget,
    this.width,

    this.suffixIcon,
  }) : super(key: key);

  @override
  State<SMNumberTextFConst> createState() => _SMNumberTextFConstState();
}

class _SMNumberTextFConstState extends State<SMNumberTextFConst> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: widget.width ?? AppSize.s354,
          child: RichText(
            text: TextSpan(
              text: widget.text,
              style: NumberTExtFieldLegalDoc.customTextStyle(context), // Apply the main text style here
              children: [
                widget.isAsteric! ?
                TextSpan(
                  text: ' *',
                  style: NumberTExtFieldLegalDoc.customTextStyle(context).copyWith(
                    color: Colors.red, // Set the asterisk color to red
                  ),
                ) :
            TextSpan(
            text: ' ',
            )
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: widget.width ?? AppSize.s354,
          height: AppSize.s30,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            focusNode: widget.focusNode,
            autofocus: true,
            enabled: widget.enable ?? true,
            controller: widget.controller,
            keyboardType: TextInputType.number, // Number input type
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only digits allowed
            ],
           // cursorHeight: 17,
            cursorColor: Colors.black,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              suffixIcon: widget.suffixIcon,
              prefix: widget.prefixWidget,
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.only(bottom: 18, left: AppPadding.p15),
            ),
            style: TableSubHeading.customTextStyle(context),
            onTap: widget.onChange,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}



////defualt Email

class DemailSMTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  DemailSMTextFConst({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget, this.onChanged,
  }) : super(key: key);

  @override
  State<DemailSMTextFConst> createState() => _DemailSMTextFConstState();
}

class _DemailSMTextFConstState extends State<DemailSMTextFConst> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with a listener
    _controller = widget.controller;
    _controller.addListener(_updateText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateText);
    super.dispose();
  }

  void _updateText() {
    final text = _controller.text;
    if (!text.endsWith('@prohealth.us')) {
      // Ensure that the text ends with '@gmail.com'
      _controller.value = _controller.value.copyWith(
        text: text.endsWith('@prohealth.us') ? text : '$text@prohealth.us',
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: Colors.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.s5),
          Container(
            width: AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              autofocus: true,
              enabled: widget.enable ?? true,
              controller: _controller,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
             // cursorHeight: 17,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                suffixIcon: widget.icon,
                prefix: widget.prefixWidget,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 22, left: 10,top: 5),
              ),
              style: TableSubHeading.customTextStyle(context),
              // style: TextStyle(
              //   fontWeight: FontWeight.w500,
              //   fontSize: 12,
              //   color: Color(0xff686464),
              // ),
              onTap: widget.onChange,
              validator: widget.validator,
            ),
          ),
        ],
      ),
    );
  }
}

////us phone

class SMTextFConstPhone extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final ValueChanged<String>? onChangeField;
  final bool isAsteric;


  SMTextFConstPhone({
    Key? key,
    this.onChangeField,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget, this.onChanged,
    this.isAsteric = true,
  }) : super(key: key);

  @override
  State<SMTextFConstPhone> createState() => _SMTextFConstPhoneState();
}

class _SMTextFConstPhoneState extends State<SMTextFConstPhone> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: widget.isAsteric
              ? []
              : [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: Colors.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   widget.text,
          //   style: AllPopupHeadings.customTextStyle(context),
          // ),
          SizedBox(height: 5),
          Container(
            width: AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              autofocus: false,
              enabled: widget.enable ?? true,
              controller: widget.controller,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              //cursorHeight: 16,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                PhoneNumberInputFormatter(),
              ],
              decoration: InputDecoration(
                suffixIcon: widget.icon,
                prefix: widget.prefixWidget,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 22, left: 10,top: 1),
              ),
              style: TableSubHeading.customTextStyle(context),
              validator: widget.validator,
              onTap: widget.onChange,
            ),
          ),
        ],
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

    // newText.write('+1 ');
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

///first latter capital
class FirstSMTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final void Function(String)? onTapChange;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;
  final FocusNode? focusNode;




  FirstSMTextFConst({
    Key? key,
    this.onTapChange,
    this.inputFormated,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.showDatePicker = false, this.suffixIcon, this.focusNode,
  }) : super(key: key);

  @override
  State<FirstSMTextFConst> createState() => _FirstSMTextFConstState();
}

class _FirstSMTextFConstState extends State<FirstSMTextFConst> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000),
    );
    if (pickedDate != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }
  @override
  Widget build(BuildContext context) {
    String? errorText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: Colors.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   widget.text,
          //   style: AllPopupHeadings.customTextStyle(context),
          // ),
          SizedBox(
            height: AppSize.s5,
          ),
          Container(
            width: AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
                autofocus: true,
                enabled: widget.enable == null ? true : false,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                cursorHeight: 16,
                cursorColor: Colors.black,
                focusNode: widget.focusNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  suffixIcon: widget.showDatePicker
                      ? GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Icon(Icons.calendar_month_outlined,color:ColorManager.blueprime),
                  )
                      : widget.suffixIcon,
                  prefix: widget.prefixWidget,
                  prefixStyle:ZoneDataStyle.customTextStyle(context),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 2,
                      bottom: 22, left: AppPadding.p10, right: AppPadding.p10),
                ),
                style: TableSubHeading.customTextStyle(context),
                //validator: widget.validator,
                onTap: widget.onChange,
                onChanged: widget.onTapChange,

                inputFormatters: widget.inputFormated == null
                    ? [
                        //CapitalizeFirstLetterFormatter(),
                      ]
                    : widget.inputFormated
            ),
          ),
        ],
      ),
    );
  }
}


///new
class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // If the new text is empty or just whitespace, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter
    String newText;
    if (newValue.text.length > 1) {
      newText = newValue.text[0].toUpperCase() + newValue.text.substring(1);
    } else {
      newText = newValue.text.toUpperCase();
    }

    // Calculate the new cursor position
    int newOffset;
    if (newText.length > oldValue.text.length) {
      newOffset = oldValue.selection.start == 0 ? 1 : oldValue.selection.start + 1;
    } else {
      newOffset = oldValue.selection.start;
    }

    // Return the updated text value while preserving cursor position
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, newText.length)),
    );
  }
}

///all capital letter
class CapitalSMTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;

  CapitalSMTextFConst({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
  }) : super(key: key);

  @override
  State<CapitalSMTextFConst> createState() => _CapitalSMTextFConstState();
}

class _CapitalSMTextFConstState extends State<CapitalSMTextFConst> {
  @override
  Widget build(BuildContext context) {
    String? errorText;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.text, // Main text
            style: AllPopupHeadings.customTextStyle(context), // Main style
            children: [
              TextSpan(
                text: ' *', // Asterisk
                style: AllPopupHeadings.customTextStyle(context).copyWith(
                  color: Colors.red, // Asterisk color
                ),
              ),
            ],
          ),
        ),
        // Text(
        //   widget.text,
        //   style: AllPopupHeadings.customTextStyle(context),
        // ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: AppSize.s354,
          height: AppSize.s30,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFB1B1B1), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            autofocus: true,
            enabled: widget.enable == null ? true : false,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            cursorHeight: 17,
            cursorColor: Colors.black,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              suffixIcon: widget.icon,
              prefix: widget.prefixWidget,
              prefixStyle: AllHRTableData.customTextStyle(context),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(bottom: AppPadding.p18, left: AppPadding.p15),
            ),
            style: TableSubHeading.customTextStyle(context),

            inputFormatters: [UppercaseTextFormatter()],
            //validator: widget.validator,
            onTap: widget.onChange,
            //textCapitalization:  TextCapitalization.characters,
          ),
        ),
      ],
    );
  }
}
////////////////////////////////

class UppercaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert the new text to uppercase
    final String newText = newValue.text.toUpperCase();

    // Return the updated text value with the new uppercase text
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

///
class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final bool? enabled;
  final VoidCallback? onChange;

  EditTextField({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: ConstTextFieldStyles.customTextStyle(textColor: textColor),
        ),
        SizedBox(
          height: AppSize.s5,
        ),
        Container(
          width: MediaQuery.of(context).size.width / 5,
          height: AppSize.s30,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFB1B1B1), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            enabled: enabled,
            readOnly: true,
            autofocus: true,
            controller: controller,
            keyboardType: keyboardType,
            cursorHeight: 17,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              suffixIcon: icon,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(bottom: AppPadding.p18, left: AppPadding.p15),
            ),
            style: DocumentTypeDataStyle.customTextStyle(context),
            onTap: onChange,
          ),
        ),
      ],
    );
  }
}

///phone number in edit
///
class EditTextFieldPhone extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final bool? enabled;
  final VoidCallback? onChange;

  EditTextFieldPhone({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: ConstTextFieldStyles.customTextStyle(textColor: textColor),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: MediaQuery.of(context).size.width / 5,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFB1B1B1), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            inputFormatters: [
              PhoneNumberInputFormatter(),
            ],
            readOnly: true,
            autofocus: true,
            enabled: enabled,
            controller: controller,
            keyboardType: keyboardType,
            cursorHeight: 17,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              suffixIcon: icon,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(bottom: AppPadding.p18, left: AppPadding.p15),
            ),
            style: DocumentTypeDataStyle.customTextStyle(context),
            onTap: onChange,
          ),
        ),
      ],
    );
  }
}





class SSNTextFConst extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;



 SSNTextFConst({
    Key? key,
    this.inputFormated,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.showDatePicker = false, this.suffixIcon,
  }) : super(key: key);

  @override
  State<SSNTextFConst> createState() => _SSNTextFConstState();
}

class _SSNTextFConstState extends State<SSNTextFConst> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000),
    );
    if (pickedDate != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }
  @override
  Widget build(BuildContext context) {
    String? errorText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.text, // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: ColorManager.red, // Asterisk color
                  ),
                ),
              ],
            ),
          ),
          // Text(
          //   widget.text,
          //   style: AllPopupHeadings.customTextStyle(context),
          // ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
                autofocus: true,
                enabled: widget.enable == null ? true : false,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                cursorHeight: 17,
                cursorColor: Colors.black,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  suffixIcon: widget.showDatePicker
                      ? GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Icon(Icons.calendar_month_outlined,color:ColorManager.blueprime),
                  )
                      : widget.suffixIcon,
                  prefix: widget.prefixWidget,
                  prefixStyle:ZoneDataStyle.customTextStyle(context),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                      bottom: 22, left: AppPadding.p10),
                ),
                style: TableSubHeading.customTextStyle(context),
                //validator: widget.validator,
                onTap: widget.onChange,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                LengthLimitingTextInputFormatter(9), // Limit to 9 digits
              ],
            ),
          ),
        ],
      ),
    );
  }
}







class HhermTextFConstCalender extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String text;
  final Color textColor;
  final Icon? icon;
  final bool? readOnly;
  final VoidCallback? onChange;
  final ValueChanged<String>? onChangeField;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final double? width;
  final List<TextInputFormatter>? inputFormated;
  final bool showDatePicker;
  final Icon? suffixIcon;
  final bool isAsteric;
  final bool isIcon;
  final bool? onlyAllowNumbers;

  HhermTextFConstCalender({
    Key? key,
    this.onChangeField,
    this.focusNode,
    required this.controller,
    required this.keyboardType,
    required this.text,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.onChange,
    this.readOnly,
    this.enable,
    this.validator,
    this.prefixWidget,
    this.width,
    this.inputFormated,
    this.showDatePicker = false,
    this.suffixIcon,
    this.isAsteric = true,
    this.isIcon = false,
    this.onlyAllowNumbers = false,
  }) : super(key: key);

  @override
  State<HhermTextFConstCalender> createState() =>
      _HhermTextFConstCalenderState();
}

class _HhermTextFConstCalenderState extends State<HhermTextFConstCalender> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final picked = await CalendarDialogHelper.show(
      context: context,
      selectedDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.controller.text = CalendarDialogHelper.fmt(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: widget.text,
                  style: AllPopupHeadings.customTextStyle(context),
                  children: widget.isAsteric
                      ? [
                    TextSpan(
                      text: ' *',
                      style: AllPopupHeadings.customTextStyle(context)
                          .copyWith(color: ColorManager.red),
                    ),
                  ]
                      : [],
                ),
              ),
              widget.isIcon
                  ? InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {},
                child: SvgPicture.asset(
                  'images/sm/sm_refferal/i_circle.svg',
                  height: IconSize.I20,
                  width: IconSize.I20,
                ),
              )
                  : SizedBox(),
            ],
          ),
          SizedBox(height: AppSize.s5),
          Container(
            width: widget.width ?? AppSize.s354,
            height: AppSize.s30,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFB1B1B1), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              focusNode: widget.focusNode,
              autofocus: false,
              enabled: widget.enable == null ? true : false,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChangeField,
              cursorColor: Colors.black,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                suffixIcon: widget.showDatePicker
                    ? GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Icon(Icons.calendar_month_outlined, color: ColorManager.mediumgrey,size: 18,),
                )
                    : widget.icon,
                prefix: widget.prefixWidget,
                prefixIcon: widget.suffixIcon,
                prefixStyle: AllHRTableData.customTextStyle(context),
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.only(bottom: 18, left: AppPadding.p10),
              ),
              style: TableSubHeading.customTextStyleWithColor(
                  context, widget.textColor),
              onTap: widget.onChange,
              validator: widget.validator,
              inputFormatters: widget.onlyAllowNumbers!
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : widget.inputFormated,
            ),
          ),
        ],
      ),
    );
  }
}