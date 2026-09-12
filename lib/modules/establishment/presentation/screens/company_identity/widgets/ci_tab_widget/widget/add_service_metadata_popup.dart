import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

/// Popup to add a new service in the service meta data (service catalog).
/// Posts to `/service-metadata/add`, the list every office services
/// selection is built from.
class AddServiceMetaDataPopup extends StatefulWidget {
  const AddServiceMetaDataPopup({super.key, this.onServiceAdded});

  /// Called after a service is added successfully, so the caller can
  /// refresh its services list.
  final VoidCallback? onServiceAdded;

  @override
  State<AddServiceMetaDataPopup> createState() =>
      _AddServiceMetaDataPopupState();
}

class _AddServiceMetaDataPopupState extends State<AddServiceMetaDataPopup> {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceIdController = TextEditingController();

  String? _serviceNameError;
  String? _serviceIdError;
  bool isLoading = false;

  @override
  void dispose() {
    serviceNameController.dispose();
    serviceIdController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _serviceNameError = serviceNameController.text.trim().isEmpty
          ? 'Please Enter Service Name'
          : null;
      _serviceIdError =
          serviceIdController.text.trim().isEmpty ? 'Please Enter Service ID' : null;
    });
    return _serviceNameError == null && _serviceIdError == null;
  }

  Future<void> _addService() async {
    if (!_validateForm()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      ApiData response = await addServiceMetaData(
        context: context,
        serviceName: serviceNameController.text.trim(),
        serviceId: serviceIdController.text.trim(),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        widget.onServiceAdded?.call();
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              AddSuccessPopup(message: 'Service added successfully.'),
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
          builder: (BuildContext context) => FailedPopup(text: response.message),
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
      width: AppSize.s420,
      height: AppSize.s350,
      title: AppStringEM.addNewService,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: serviceNameController,
                keyboardType: TextInputType.text,
                text: AppStringEM.serviceName,
                onChanged: (value) {
                  if (_serviceNameError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _serviceNameError = null;
                    });
                  }
                },
              ),
              _serviceNameError != null
                  ? Text(
                      _serviceNameError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    )
                  : SizedBox(height: AppSize.s12),
              SizedBox(height: AppSize.s10),
              SMTextfieldAsteric(
                controller: serviceIdController,
                keyboardType: TextInputType.text,
                text: AppStringEM.serviceId,
                onChanged: (value) {
                  if (_serviceIdError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _serviceIdError = null;
                    });
                  }
                },
              ),
              _serviceIdError != null
                  ? Text(
                      _serviceIdError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    )
                  : SizedBox(height: AppSize.s12),
            ],
          ),
        ),
      ],
      bottomButtons: isLoading
          ? SizedBox(
              height: AppSize.s30,
              width: AppSize.s30,
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            )
          : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.add,
              onPressed: _addService,
            ),
    );
  }
}
