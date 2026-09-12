import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/register_manager/register_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/text_form_field_const.dart';

/// Popup to add a new employee speciality.
/// Posts to `/employee-speciality/add`, the list the Speciality dropdowns
/// in the enroll and onboarding forms are built from.
class AddSpecialityPopup extends StatefulWidget {
  const AddSpecialityPopup({super.key, this.onSpecialityAdded});

  /// Called after a speciality is added successfully, so the caller can
  /// refresh its speciality list.
  final VoidCallback? onSpecialityAdded;

  @override
  State<AddSpecialityPopup> createState() => _AddSpecialityPopupState();
}

class _AddSpecialityPopupState extends State<AddSpecialityPopup> {
  final TextEditingController specialityController = TextEditingController();

  final FocusNode _specialityFocus = FocusNode();
  String? _specialityError;
  bool isLoading = false;

  @override
  void dispose() {
    specialityController.dispose();
    _specialityFocus.dispose();
    super.dispose();
  }

  Future<void> _addSpeciality() async {
    if (specialityController.text.trim().isEmpty) {
      setState(() => _specialityError = 'Please Enter Speciality');
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      ApiData response = await addEmployeeSpeciality(
        context: context,
        speciality: specialityController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        widget.onSpecialityAdded?.call();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddSuccessPopup(
              message: 'Speciality added successfully.',
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
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: 410,
      height: AppSize.s250,
      title: 'Add Speciality',
      color: ColorManager.blueprime,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                hintText: 'Speciality',
                controller: specialityController,
                keyboardType: TextInputType.text,
                text: 'Speciality',
                focusNode: _specialityFocus,
                onChange: () {
                  if (_specialityError != null) {
                    setState(() => _specialityError = null);
                  }
                },
              ),
              _specialityError != null
                  ? Text(_specialityError!,
                      style: CommonErrorMsg.customTextStyle(context))
                  : const SizedBox(height: AppSize.s12),
            ],
          ),
        ),
      ],
      bottomButtons: CustomElevatedButton(
        color: ColorManager.blueprime,
        height: AppSize.s30,
        width: AppSize.s120,
        text: 'Add',
        isLoading: isLoading,
        onPressed: _addSpeciality,
      ),
    );
  }
}
