import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/add_service_metadata_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/header_content_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

/// Popup to attach a service to an existing office.
/// Picks a service from the service meta data catalog and posts it to
/// `/company-office-service/add` through [addNewOfficeServices].
class AddOfficeServicePopup extends StatefulWidget {
  const AddOfficeServicePopup({
    super.key,
    required this.officeId,
    this.alreadyAddedServiceIds = const [],
    this.onServiceAdded,
  });

  final String officeId;

  /// Services already attached to this office - they are left out of the
  /// dropdown so the same service is not added twice.
  final List<String> alreadyAddedServiceIds;

  /// Called after the service is added, so the caller can refresh its list.
  final VoidCallback? onServiceAdded;

  @override
  State<AddOfficeServicePopup> createState() => _AddOfficeServicePopupState();
}

class _AddOfficeServicePopupState extends State<AddOfficeServicePopup> {
  TextEditingController npiNumController = TextEditingController();
  TextEditingController medicareController = TextEditingController();
  TextEditingController hcoNumController = TextEditingController();

  late Future<List<ServicesMetaData>> _servicesFuture;
  ServicesMetaData? _selectedService;

  bool _isFormValid = true;
  String? _serviceError;
  String? _hcoError;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _servicesFuture = getServicesMetaData(context);
  }

  void _refreshServices() {
    setState(() {
      _selectedService = null;
      _servicesFuture = getServicesMetaData(context);
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid = true;
      if (_selectedService == null) {
        _serviceError = 'Please select a service';
        _isFormValid = false;
      } else {
        _serviceError = null;
      }
      if (hcoNumController.text.trim().isEmpty) {
        _hcoError = 'HCO Number cannot be empty';
        _isFormValid = false;
      } else {
        _hcoError = null;
      }
    });
  }

  Future<void> _addOfficeService() async {
    _validateForm(); // Validate the form on button press

    if (!_isFormValid) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      ApiData response = await addNewOfficeServices(
        context: context,
        officeId: widget.officeId,
        serviceList: [
          ServiceList(
            serviceId: _selectedService!.serviceId,
            npiNumber: npiNumController.text.trim(),
            medicareProviderId: medicareController.text.trim(),
            hcoNumId: hcoNumController.text.trim(),
          ),
        ],
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        widget.onServiceAdded?.call();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddSuccessPopup(
              message: 'Service added successfully.',
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
      width: AppSize.s420,
      height: AppSize.s550,
      title: AppStringEM.addService,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderContentConst(
                isAsterisk: true,
                heading: AppStringEM.serviceName,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<List<ServicesMetaData>>(
                      future: _servicesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CICCDropdown(
                            constraintHeight: 200,
                            width: AppSize.s354,
                            borderRadius: 8,
                            items: [],
                          );
                        }

                        final availableServices = (snapshot.data ?? [])
                            .where((service) => !widget.alreadyAddedServiceIds
                                .contains(service.serviceId))
                            .toList();

                        return CICCDropdown(
                          constraintHeight: 200,
                          width: AppSize.s354,
                          borderRadius: 8,
                          emptyText: ErrorMessageString.noServicesAvailable,
                          initialValue: availableServices.isEmpty
                              ? ErrorMessageString.noServicesAvailable
                              : _selectedService?.serviceName ?? "Select",
                          items: availableServices
                              .map((service) => DropdownMenuItem<String>(
                                    value: service.serviceName,
                                    child: Text(service.serviceName),
                                  ))
                              .toList(),
                          onChange: (val) {
                            setState(() {
                              _selectedService = availableServices.firstWhere(
                                  (service) => service.serviceName == val);
                              _serviceError = null;
                            });
                          },
                        );
                      },
                    ),
                    _serviceError != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _serviceError!,
                                style: CommonErrorMsg.customTextStyle(context),
                              ),
                            ],
                          )
                        : SizedBox(height: AppSize.s12),
                  ],
                ),
              ),

              /// Lets the user create a service in the catalog without
              /// leaving this popup when the one they need is missing.
              SizedBox(
                width: AppSize.s354,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomIconButtonConst(
                      width: AppSize.s150,
                      height: AppSize.s30,
                      text: AppStringEM.addNewService,
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              AddServiceMetaDataPopup(
                            onServiceAdded: _refreshServices,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.s10),
              SMTextfieldAsteric(
                controller: hcoNumController,
                keyboardType: TextInputType.text,
                text: AppStringEM.hcoNum,
                onChanged: (value) {
                  if (_hcoError != null && value.trim().isNotEmpty) {
                    setState(() {
                      _hcoError = null;
                    });
                  }
                },
              ),
              _hcoError != null
                  ? Text(
                      _hcoError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    )
                  : SizedBox(height: AppSize.s12),
              SMTextFConst(
                controller: medicareController,
                keyboardType: TextInputType.text,
                text: AppStringEM.medicareid,
                isAsteric: false,
              ),
              SizedBox(height: AppSize.s10),
              SMTextFConst(
                controller: npiNumController,
                keyboardType: TextInputType.text,
                text: AppStringEM.npinum,
                isAsteric: false,
              ),
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
              onPressed: _addOfficeService,
            ),
    );
  }
}
