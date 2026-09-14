import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_education_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

/// Popup to add a degree for the company.
/// Posts to `/employee-degree/add`, the list the Degree dropdown in the
/// employee education form is built from.
class AddDegreePopup extends StatefulWidget {
  const AddDegreePopup({super.key, this.onDegreeAdded});

  /// Called after a degree is added successfully, so the caller can refresh
  /// its degree list.
  final VoidCallback? onDegreeAdded;

  @override
  State<AddDegreePopup> createState() => _AddDegreePopupState();
}

class _AddDegreePopupState extends State<AddDegreePopup> {
  TextEditingController degreeController = TextEditingController();

  bool _isFormValid = true;
  String? _degreeError;
  bool _isLoading = false;

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      if (degreeController.text.trim().isEmpty) {
        _degreeError = 'Please Enter Degree';
        _isFormValid = false;
      } else {
        _degreeError = null;
      }
    });
  }

  Future<void> _addDegree() async {
    _validateForm(); // Validate the form on button press

    if (!_isFormValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      ApiData response = await addEmployeeDegree(
        context: context,
        degree: degreeController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        widget.onDegreeAdded?.call();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddSuccessPopup(
              message: 'Degree added successfully.',
            );
          },
        );
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => const FourNotFourPopup(),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              FailedPopup(text: response.message),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s250,
      title: AppStringEM.addDegree,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: degreeController,
                keyboardType: TextInputType.text,
                text: AppStringEM.degree,
                onChanged: (value) {
                  if (_degreeError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _degreeError = null;
                    });
                  }
                },
              ),
              _degreeError != null
                  ? Text(
                      _degreeError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    )
                  : SizedBox(height: AppSize.s12),
            ],
          ),
        ),
      ],
      bottomButtons: _isLoading
          ? SizedBox(
              width: AppSize.s30,
              height: AppSize.s30,
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            )
          : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.add,
              onPressed: _addDegree,
            ),
    );
  }
}
