import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_hr/sales_hr.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/search_byfilter.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_hr/administration_hr.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/see_all_hr/clinical_hr.dart';

///enums
enum OfficeLocation { sanJose, austin }
enum Zone { zone1, zone2 }
enum LicenseStatus { active, expired }
enum Availability { fullTime, partTime }
///
class ProfilePatientPopUp extends StatefulWidget {
  final Widget? zoneDropDown;
  final VoidCallback onSearch;
  final Widget clearFilter;
  final Widget officceIdWidget;
  final Widget licensesWidget;
  final Widget avabilityWidget;
  final Widget? abbrivationWidget;
  bool? isShown;
  ProfilePatientPopUp({Key? key,
    this.isShown = true,
    required this.clearFilter,
    required this.avabilityWidget,
    required this.licensesWidget,
     this.abbrivationWidget,
    required this.officceIdWidget,
    required this.onSearch, this.zoneDropDown,}) : super(key: key);

  @override
  State<ProfilePatientPopUp> createState() => _PopUpState();
}

class _PopUpState extends State<ProfilePatientPopUp> {
  String? dropdownValue;
  String? dropdownOfficeLocation;
  String? dropdownZone;
  String? dropdownLicenseStatus;
  String? dropdownAvailability;
  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: 480, height: 450,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Office Location',
                        style:AllPopupHeadings.customTextStyle(context)
                      ),
                      const SizedBox(height: 5,),
                      widget.officceIdWidget
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 20),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zone', style: AllPopupHeadings.customTextStyle(context)),
                        const SizedBox(height: 5,),
                        widget.zoneDropDown == null ? const Offstage() : widget.zoneDropDown!
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                children: [
                  Text(
                    'License Status',
                    style: AllPopupHeadings.customTextStyle(context)
                  ),
                  const SizedBox(height:5),
                ],
              ),
              const SizedBox(height: 5,),
              widget.licensesWidget,
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                children: [
                  Text(
                    'Availability',
                    style: AllPopupHeadings.customTextStyle(context)
                  ),
                ],
              ),
              const SizedBox(height: 5,),
              widget.avabilityWidget,
            ],
          ),
        )


    ],
      bottomButtons:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.clearFilter,
          const SizedBox(width: 10,),
          CustomElevatedButton(
            width: AppSize.s105,
            height: AppSize.s30,
            text: "Search",
            isSelectShow: widget.isShown ?? true,
            onPressed: () async {
              widget.onSearch();
              Navigator.pop(context);
            } ,
          ),
        ],
      ),
      title: 'Clinician Search Filter',
    );
  }
}













class ConstantContainerWithText extends StatefulWidget {
  final String text;

  const ConstantContainerWithText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  _ConstantContainerWithTextState createState() =>
      _ConstantContainerWithTextState();
}

class _ConstantContainerWithTextState extends State<ConstantContainerWithText> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isSelected ? const Color(0xff4FB8EB) : Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        height: 27,
        width: 31,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: _isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
