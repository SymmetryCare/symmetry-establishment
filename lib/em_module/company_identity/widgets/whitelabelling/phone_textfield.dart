import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';

class PhoneNumberInput extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController countryCodeController;
  final String labelText;
  final Color textColor;
  final Icon? icon;
  final bool? enable;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;

  PhoneNumberInput({
    Key? key,
    required this.phoneController,
    required this.countryCodeController,
    required this.labelText,
    this.textColor = const Color(0xff686464),
    this.icon,
    this.enable,
    this.prefixWidget,
    this.validator,
  }) : super(key: key);

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style:ConstTextFieldStyles.customTextStyle(textColor: widget.textColor),
        ),
        SizedBox(height: AppSize.s5),
        Container(
          height: AppSize.s60,
          width: AppSize.s354, // Increased height for better UI
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFB1B1B1), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              setState(() {
                widget.phoneController.text = number.phoneNumber ?? '';
                widget.countryCodeController.text = number.isoCode ?? '';
              });
            },
            onInputValidated: (bool isValid) {
              print(isValid ? 'Valid' : 'Invalid');
            },
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            initialValue: PhoneNumber(isoCode: 'US'), // Default country code
            textFieldController: widget.phoneController,
            formatInput: true,
            keyboardType: TextInputType.number,
            inputBorder: OutlineInputBorder(),
            selectorTextStyle: TextStyle(color: Colors.black),
            textStyle: TextStyle(color: Colors.black),
            inputDecoration: InputDecoration(
              suffixIcon: widget.icon,
              prefix: widget.prefixWidget,
              prefixStyle: AllHRTableData.customTextStyle(context),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: AppPadding.p18, left: AppPadding.p15),
            ),
          ),
        ),
      ],
    );
  }
}