import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/i9_form_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/form_legal_documents_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/thank_you_screen.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/certificate_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/offer_letter_description_screen.dart';

class FormNineScreen extends StatefulWidget {
  final int? employeeID;
  const FormNineScreen({Key? key, this.employeeID}) : super(key: key);

  @override
  State<FormNineScreen> createState() => _FormNineScreenState();
}

class _FormNineScreenState extends State<FormNineScreen> {
  TextEditingController lastName = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController middleInitial = TextEditingController();
  TextEditingController otherLastNames = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController aptNumber = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController ssn = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController cityTown = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController alienRegistrationNumber = TextEditingController();
  TextEditingController workAuthorizationExpirationDate = TextEditingController();
  TextEditingController uscisNumber = TextEditingController();
  TextEditingController formI94AdmissionNumber = TextEditingController();
  TextEditingController foreignPassportNumber = TextEditingController();
  TextEditingController countryOfIssuance = TextEditingController();
  TextEditingController _controller = TextEditingController();
  bool isUSCitizen = false;
  bool isNonUSCitizen = false;
  bool isAuthoRiseToWork = false;
  bool isLawFullResidence = false;

  List<bool> _checkboxValues = List<bool>.generate(4, (index) => false);

  Widget _buildLabeledTextField(String label, TextEditingController controller,
      String hintText, TextInputType keyboardType,
      {bool isRequired = true, Widget? suffixIcon,double? width,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style:  AllPopupHeadings.customTextStyle(context),
          ),
        const SizedBox(height: 7),
        CustomTextFieldRegister(
          height: AppSize.s31,
          width: width ?? MediaQuery.of(context).size.width / 2.8,
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          padding: const EdgeInsets.only(left: 10, bottom: AppPadding.p10),
          onChanged: (value) {},
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return AppString.enterText;
            }
            return null;
          },
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }


  ///email field
  Widget _buildLabeledTextFieldEmail(String label, TextEditingController controller,
      String hintText, TextInputType keyboardType,
      {bool isRequired = true, Widget? suffixIcon,double? width,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style:  AllPopupHeadings.customTextStyle(context),
          ),
        const SizedBox(height: 7),
        CustomTextFieldForEmail(
          height: AppSize.s31,
          width: width ?? MediaQuery.of(context).size.width / 2.8,
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          padding: const EdgeInsets.only(left: 10, bottom: AppPadding.p10),
          onChanged: (value) {},
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return AppString.enterText;
            }
            return null;
          },
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }

  ///


  ///phone number textfield
  Widget _buildLabeledTextFieldPhone(String label, TextEditingController controller,
      String hintText, TextInputType keyboardType,
      {bool isRequired = true, Widget? suffixIcon,double? width,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style:  AllPopupHeadings.customTextStyle(context),
          ),
        const SizedBox(height: 7),
        CustomTextFieldRegisterPhone(
          height: AppSize.s31,
          width: width ?? MediaQuery.of(context).size.width / 2.8,
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          padding: const EdgeInsets.only(left: 10, bottom: AppPadding.p10),
          onChanged: (value) {},
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return AppString.enterText;
            }
            return null;
          },
          suffixIcon: suffixIcon,

        ),
      ],
    );
  }

  ///







  Widget _buildCheckboxItem(String text, int index) {
    return Row(
      children: [
        Checkbox(
          value: _checkboxValues[index],
          onChanged: (bool? value) {
            setState(() {
              _checkboxValues[index] = value!;
              isUSCitizen = _checkboxValues[0];
              isNonUSCitizen = _checkboxValues[1];
              isLawFullResidence =  _checkboxValues[2];
              isAuthoRiseToWork =  _checkboxValues[3];

              print('isUSCitized ${isUSCitizen}');
              print('isNonUSCitized ${isNonUSCitizen}');
              print('isLawFulWork ${isLawFullResidence}');
              print('IsAuthoriseWork ${isAuthoRiseToWork}');
            });
          },
        ),
        Expanded(
          child: Text(
            text,
            style: onlyFormINineDataStyle.customTextStyle(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 150.0,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Form i - 9',
                style:FormHeading.customTextStyle(context),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "Last Name (Family Name)",
                      lastName,
                      "Ex-John",
                      TextInputType.text),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      "U.S. Social Security Number",
                      ssn,
                      "Enter Socal Security Number",
                      TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "First Name (Given Name)",
                      firstName,
                      "Ex.Adams",
                      TextInputType.text),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextFieldEmail(
                      "Employee's Email",
                      email,
                      "Enter Email",
                      TextInputType.emailAddress),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "Middle Initial",
                      middleInitial,
                      "Enter Text",
                      TextInputType.text,
                      isRequired: false),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextFieldPhone(
                      "Employee's Phone Number",
                      phoneNumber,
                      "Enter Phone Number",
                      TextInputType.phone),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "Other Last Names Used (if any)",
                      otherLastNames,
                      "Enter Other Last Names",
                      TextInputType.text,
                      isRequired: false),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      "City or Town",
                      cityTown,
                      "Enter City or Town",
                      TextInputType.text),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "Address (Street Number & Name)",
                      address,
                      "Enter Address",
                      TextInputType.streetAddress),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      "State", state, "Enter Text", TextInputType.text),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledTextField(
                      "Apt. Number",
                      aptNumber,
                      "Enter Apt number",
                      TextInputType.text,
                      isRequired: false),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      "Zip Code", zipCode, "Enter Text", TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLabeledTextField(
                  "DOB",
                  dob,
                  "dd-mm-yyyy",
                  TextInputType.datetime,
                  suffixIcon: IconButton(
                    splashColor:
                    Colors.transparent,
                    highlightColor:
                    Colors.transparent,
                    hoverColor:
                    Colors.transparent,
                    icon: const Icon(Icons.calendar_month_outlined, color: Color(0xff50B5E5), size: 16,),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        dob.text = formattedDate;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'I attest, under penalty of perjury, that I am (Check one of the following boxes.):',
              style:  DefineWorkWeekStyle.customTextStyle(context),
            ),
            _buildCheckboxItem('A citizen of the United States', 0),
            _buildCheckboxItem('A noncitizen national of the United States', 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCheckboxItem(
                      'A lawful permanent resident (Alien Registration Number/USCIS Number):', 2),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: Visibility(
                    visible: isLawFullResidence,
                    child: _buildLabeledTextField(
                        '',
                        alienRegistrationNumber,
                        'Enter Text',
                        TextInputType.text,
                        width: MediaQuery.of(context).size.width/5
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCheckboxItem(
                      'An alien authorized to work until (expiration date, if applicable, mm/dd/yyyy):', 3),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: Visibility(
                    visible: isAuthoRiseToWork,
                    child: _buildLabeledTextField(
                      '',
                      workAuthorizationExpirationDate,
                      'Enter Text',
                      TextInputType.text,
                      width: MediaQuery.of(context).size.width/5,
                      suffixIcon: IconButton(
                        splashColor:
                        Colors.transparent,
                        highlightColor:
                        Colors.transparent,
                        hoverColor:
                        Colors.transparent,
                        icon: const Icon(Icons.calendar_month_outlined, color: Color(0xff50B5E5), size: 16,),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            workAuthorizationExpirationDate.text = formattedDate;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Aliens authorized to work must provide only one of the following document numbers to complete Form I-9:',
              style:  DefineWorkWeekStyle.customTextStyle(context),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Alien Registration Number or USCIS Number:',
                    style: onlyFormINineDataStyle.customTextStyle(context),
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      '',
                      uscisNumber,
                      'Enter Text',
                      TextInputType.text,
                      width: MediaQuery.of(context).size.width/5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding:  const EdgeInsets.only(left: 280),
              child: Text(
                'Or',
                style: onlyFormINineDataStyle.customTextStyle(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Form I-94 Admission Number:',
                    style: onlyFormINineDataStyle.customTextStyle(context),
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      '',
                      formI94AdmissionNumber,
                      'Enter Text',
                      TextInputType.text,
                      width: MediaQuery.of(context).size.width/5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 280),
              child: Text(
                'Or',
                style: onlyFormINineDataStyle.customTextStyle(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Foreign Passport Number:',
                    style: onlyFormINineDataStyle.customTextStyle(context),
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      '',
                      foreignPassportNumber,
                      'Enter Text',
                      TextInputType.text,
                      width: MediaQuery.of(context).size.width/5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Country of Issuance:',
                    style: onlyFormINineDataStyle.customTextStyle(context),
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: _buildLabeledTextField(
                      '',
                      countryOfIssuance,
                      'Enter Text',
                      TextInputType.text,
                      width: MediaQuery.of(context).size.width/5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
                      height: 30,
                      width: 125,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF50B5E5),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF50B5E5),
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Back',
                              style: TransparentButtonTextConst.customTextStyle(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }
                ),
                const SizedBox(width: 10),

                Container(
                  height: 30,
                  width: 140,
                  child: CustomIconButton(text: 'Continue', icon: Icons.arrow_forward , onPressed: () async{
                    var response =  await addEmployeeI9Form(context: context, employeeId: widget.employeeID!, firstName: firstName.text,
                        middleName: middleInitial.text, lastName: lastName.text, lastNameOther: otherLastNames.text, phonrNumber: phoneNumber.text,
                        city: cityTown.text, state: state.text, address: address.text, zipCode: zipCode.text, SSNNbr: ssn.text, email: email.text,
                        DOB: dob.text, isUSACitizen: isUSCitizen, isNonUSACitizen: isNonUSCitizen, isLawfullResident: isLawFullResidence,
                        alienRegNbr: isLawFullResidence == false ? "--" :alienRegistrationNumber.text, isAuthorizedToWork: isAuthoRiseToWork, unthorizedToWorkDate: isAuthoRiseToWork == false ?"0000-00-00":workAuthorizationExpirationDate.text,
                        I94AdmissionNbr: formI94AdmissionNumber.text, foreignPassportNbr: foreignPassportNumber.text, countryOfIssue: countryOfIssuance.text,
                        officeId: "");
                    if(response.statusCode == 200 || response.statusCode == 201){
                      Navigator.pop(context);
                    }else{

                    }

                  }, isNotPopUpButton: true,),
                ),

              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBarRow(),
    );
  }
}
