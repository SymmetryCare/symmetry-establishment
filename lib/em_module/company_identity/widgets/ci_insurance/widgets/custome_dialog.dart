import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../../app/services/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import '../../../../../../widgets/error_popups/failed_popup.dart';
import '../../../../../../widgets/error_popups/four_not_four_popup.dart';
import '../../../../../hr_module/manage/widgets/child_tabbar_screen/equipment_child/widgets/add_new_popup.dart';
import '../../../../widgets/button_constant.dart';
import '../../../../widgets/dialogue_template.dart';
import '../../../../widgets/text_form_field_const.dart';
import '../../whitelabelling/success_popup.dart';

class CustomPopup extends StatefulWidget {
  final String namecontroller;
  final String officeId;
  final int insuranceVendorId;
  CustomPopup({
    Key? key,
    required this.namecontroller,required this.insuranceVendorId, required this.officeId,
  }) : super(key: key);

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  TextEditingController nameController = TextEditingController();
  bool _isNameValid = true;
  String _nameErrorText = '';
  bool _isLoading = false;
  void _validateInputs() {
    setState(() {
      final nameText = nameController.text; // Use the controller's value

      if (nameText.isEmpty) {
        _isNameValid = false;
        _nameErrorText = 'Please enter vendor name';
      } else {
        _isNameValid = true;
        _nameErrorText = '';
      }
    });
  }


  @override
  void initState() {
    super.initState();
    nameController.text = widget.namecontroller;
    print(widget.namecontroller);
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s400,
        height: AppSize.s250,
          body: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p3,
                horizontal: AppPadding.p15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SMTextfieldAsteric(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    text: AppStringEM.vendorName,
                    onChanged: (value){
                      if (value.isNotEmpty) {
                      setState(() {
                        _nameErrorText = "";
                      });
                    }
                    },
                  ),
                 !_isNameValid ? // Show error text if name is invalid
                    Text(
                      _nameErrorText,
                      style: CommonErrorMsg.customTextStyle(context),
                    ): SizedBox(height: AppSize.s12,),

                ],
              ),
            ),

          ],
        bottomButtons: CustomElevatedButton(
          width: AppSize.s105,
          height: AppSize.s30,
          text: AppStringEM.save,
          onPressed: () async{
            _validateInputs(); // Perform validation
            if (_isNameValid) {
              setState(() {
                _isLoading = true;
              });
              try {
                String updatedName;
                if (nameController.text.isNotEmpty && nameController.text != widget.namecontroller) {
                  updatedName = nameController.text;
                } else {
                  updatedName = widget.namecontroller;
                }
                var response =  await patchCompanyVendor(
                  context,
                  widget.insuranceVendorId,
                  widget.officeId,
                    updatedName
                );
                if(response.statusCode == 200 || response.statusCode == 201){
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AddSuccessPopup(message:'Edited Successfully');
                    },
                  );
                }
                else if(response.statusCode == 400 || response.statusCode == 404){
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const FourNotFourPopup(),
                  );
                }
                else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => FailedPopup(text: response.message),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FailedPopup(
                      text: 'An error occurred. Please try again later.',
                    );
                  },
                );
              }finally {
                setState(() {
                  _isLoading = false;
                });
                // Navigator.pop(context);
              }
            }
          },
        ), title: AppStringEM.Editvendor,

    );
  }
}
///add
class AddVendorPopup extends StatefulWidget {
  final TextEditingController namecontroller;
  final String officeID;
  AddVendorPopup({
    Key? key,
    required this.namecontroller,required this.officeID,
  }) : super(key: key);

  @override
  State<AddVendorPopup> createState() => _AddVendorPopupState();
}

class _AddVendorPopupState extends State<AddVendorPopup> {
  bool _isNameValid = true;
  String _nameErrorText = '';
  void _validateInputs() {
    setState(() {
      final nameText = widget.namecontroller.text;

      if (nameText.isEmpty) {
        _isNameValid = false;
        _nameErrorText = 'Please enter vendor name';
      } else {
        _isNameValid = true;
        _nameErrorText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s250,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppPadding.p3,
            horizontal: AppPadding.p15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SMTextfieldAsteric(
                controller: widget.namecontroller,
                keyboardType: TextInputType.text,
                text: AppStringEM.vendorName,
                onChanged: (value){
                  setState(() {
                    if (value.isNotEmpty) {
                      _isNameValid = true;
                      _nameErrorText = ''; // Clear the error message
                    }
                  });
                },
              ),
              !_isNameValid ?  // Show error text if name is invalid
                Text(
                    _nameErrorText,
                    style:CommonErrorMsg.customTextStyle(context)
                ) : SizedBox(height: AppSize.s12,),
            ],
          ),
        ),

      ],
      bottomButtons: CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        onPressed: () async {
          _validateInputs(); // Perform validation
          if (_isNameValid) {
            var response = await addVendors(
              context,
              widget.officeID,
              widget.namecontroller.text,

            );
            if(response.statusCode == 200 || response.statusCode == 201){

              // print('Response Body: ${response.body}');
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSuccessPopup(message:'Added Successfully');
                },
              );
            }
            else if(response.statusCode == 400 || response.statusCode == 404){
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => const FourNotFourPopup(),
              );
            }
            else {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) => FailedPopup(text: response.message),
              );
            }
            nameController.clear();
          }
        },
      ), title:AppStringEM.Addvendor,

    );
  }
}


