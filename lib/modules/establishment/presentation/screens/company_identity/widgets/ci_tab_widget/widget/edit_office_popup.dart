import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/ci_tab_widget/widget/add_office_submit_button.dart'
    show AddressInput;
import 'package:symmetry_establishment/modules/establishment/presentation/screens/company_identity/widgets/company_identity_zone/widgets/location_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/widgets/text_form_field_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establishment_string_manager.dart';

/// Edit an office from its Company Identity card: name, contact details,
/// address and its location (latitude / longitude).
///
/// The card list only carries name, address, state, country and lat/long, so
/// the phones, email and fax numbers are pre-filled from the office-details
/// GET. Fax numbers and city are not edited here but are sent back unchanged,
/// because the PATCH replaces every field it is given.
///
/// Pops the office with its edited values after a successful save.
class EditOfficePopup extends StatefulWidget {
  final CompanyIdentityModel office;
  const EditOfficePopup({super.key, required this.office});

  @override
  State<EditOfficePopup> createState() => _EditOfficePopupState();
}

class _EditOfficePopupState extends State<EditOfficePopup> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final primaryPhoneController = TextEditingController();
  final secondaryPhoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  ManageDetails? _details;
  bool _loadingDetails = true;
  bool _saving = false;

  String? _nameError;
  String? _addressError;
  String? _latError;
  String? _lngError;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final o = widget.office;
    nameController.text = o.officeName;
    addressController.text = o.address;
    stateController.text = o.stateName;
    countryController.text = o.countryName;
    latController.text = o.lat;
    lngController.text = o.long;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    final details = await companyDetailGetAll(context, widget.office.officeId);
    if (!mounted) return;
    setState(() {
      _details = details;
      _loadingDetails = false;
      if (details != null) {
        // Prefer the details record where it has a value; it is the fresher
        // copy of the same office.
        _fillIfNotEmpty(nameController, details.officeName);
        _fillIfNotEmpty(addressController, details.address);
        _fillIfNotEmpty(stateController, details.stateName);
        _fillIfNotEmpty(countryController, details.countryName);
        _fillIfNotEmpty(latController, details.lat);
        _fillIfNotEmpty(lngController, details.long);
        emailController.text = details.email;
        primaryPhoneController.text = details.priNumber;
        secondaryPhoneController.text = details.secNumber;
        altPhoneController.text = details.alternateNumber;
      }
    });
    _moveMapTo(_currentLatLng);
  }

  void _fillIfNotEmpty(TextEditingController c, String? value) {
    if (value != null && value.trim().isNotEmpty) c.text = value;
  }

  @override
  void dispose() {
    for (final c in [
      nameController,
      emailController,
      addressController,
      stateController,
      countryController,
      primaryPhoneController,
      secondaryPhoneController,
      altPhoneController,
      latController,
      lngController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  double? get _lat {
    final v = double.tryParse(latController.text.trim());
    return (v != null && v >= -90 && v <= 90) ? v : null;
  }

  double? get _lng {
    final v = double.tryParse(lngController.text.trim());
    return (v != null && v >= -180 && v <= 180) ? v : null;
  }

  /// The typed location when valid, else the office's saved one.
  LatLng get _currentLatLng {
    if (_lat != null && _lng != null) return LatLng(_lat!, _lng!);
    return LatLng(double.tryParse(widget.office.lat) ?? 37.7749,
        double.tryParse(widget.office.long) ?? -122.4194);
  }

  void _setLocation(LatLng location) {
    setState(() {
      latController.text = location.latitude.toStringAsFixed(6);
      lngController.text = location.longitude.toStringAsFixed(6);
      _latError = null;
      _lngError = null;
    });
    _moveMapTo(location);
  }

  void _moveMapTo(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _onLatLngTyped() {
    setState(() {
      _latError = _validateLat();
      _lngError = _validateLng();
    });
    if (_lat != null && _lng != null) _moveMapTo(LatLng(_lat!, _lng!));
  }

  Future<void> _pickOnMap() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapScreen(
          initialLocation: _currentLatLng,
          onLocationPicked: (_) {},
        ),
      ),
    );
    if (picked != null && mounted) _setLocation(picked);
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _required(String value, String field) =>
      value.trim().isEmpty ? 'Please Enter $field' : null;

  String? _validateLat() {
    if (latController.text.trim().isEmpty) return 'Please Enter Latitude';
    return _lat == null ? 'Latitude must be between -90 and 90' : null;
  }

  String? _validateLng() {
    if (lngController.text.trim().isEmpty) return 'Please Enter Longitude';
    return _lng == null ? 'Longitude must be between -180 and 180' : null;
  }

  bool _validate() {
    setState(() {
      _nameError = _required(nameController.text, 'Office Name');
      _addressError = _required(addressController.text, 'Office Address');
      _latError = _validateLat();
      _lngError = _validateLng();
    });
    return _nameError == null &&
        _addressError == null &&
        _latError == null &&
        _lngError == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);
    try {
      final ApiData response = await patchCompanyOffice(
        context,
        widget.office.companyOfficeId,
        widget.office.officeId,
        primaryPhoneController.text,
        secondaryPhoneController.text,
        _details?.primaryFax ?? '',
        _details?.secondaryFax ?? '',
        altPhoneController.text,
        emailController.text,
        nameController.text.trim(),
        addressController.text.trim(),
        _lat!.toString(),
        _lng!.toString(),
        _details?.city ?? widget.office.cityName,
        stateController.text.trim(),
        countryController.text.trim(),
      );
      if (!mounted) return;
      if (response.success) {
        final o = widget.office;
        Navigator.pop(
          context,
          CompanyIdentityModel(
            officeId: o.officeId,
            companyOfficeId: o.companyOfficeId,
            companyId: o.companyId,
            name: o.name,
            officeName: nameController.text.trim(),
            address: addressController.text.trim(),
            stateName: stateController.text.trim(),
            countryName: countryController.text.trim(),
            cityName: _details?.city ?? o.cityName,
            lat: _lat!.toString(),
            long: _lng!.toString(),
            isHeadOffice: o.isHeadOffice,
            pageNo: o.pageNo,
            rowsNo: o.rowsNo,
            sucess: true,
            message: response.message,
          ),
        );
      } else {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message.isNotEmpty
              ? response.message
              : AppString.somethingWentWrong),
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  Widget _error(String? text) => text != null
      ? Text(text, style: CommonErrorMsg.customTextStyle(context))
      : const SizedBox(height: AppSize.s12);

  final _coordinateFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^-?\d{0,3}(\.\d{0,8})?'));

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s800,
      height: AppSize.s700,
      title: 'Edit Office',
      body: [
        if (_loadingDetails)
          Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: LinearProgressIndicator(
              color: ColorManager.blueprime,
              backgroundColor: ColorManager.white,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SMTextfieldAsteric(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.name,
                  onChanged: (v) => setState(
                      () => _nameError = _required(v, 'Office Name')),
                ),
                _error(_nameError),
                const SizedBox(height: AppSize.s9),
                DemailSMTextFConst(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  text: AppString.email,
                ),
                const SizedBox(height: AppSize.s20),
                FirstSMTextFConst(
                  controller: stateController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.state,
                ),
                const SizedBox(height: AppSize.s20),
                FirstSMTextFConst(
                  controller: countryController,
                  keyboardType: TextInputType.text,
                  text: AppStringEM.countryName,
                ),
              ],
            ),
            const SizedBox(width: AppSize.s20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddressInput(
                  controller: addressController,
                  onChanged: (v) => setState(
                      () => _addressError = _required(v, 'Office Address')),
                ),
                _error(_addressError),
                const SizedBox(height: AppSize.s9),
                SMTextFConstPhone(
                  controller: primaryPhoneController,
                  keyboardType: TextInputType.number,
                  text: AppStringEM.primaryPhone,
                ),
                const SizedBox(height: AppSize.s20),
                SMTextFConstPhone(
                  controller: secondaryPhoneController,
                  keyboardType: TextInputType.number,
                  text: AppStringEM.secondaryPhone,
                ),
                const SizedBox(height: AppSize.s20),
                SMTextFConstPhone(
                  controller: altPhoneController,
                  keyboardType: TextInputType.number,
                  text: AppStringEM.alternativePhone,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSize.s20),

        /// Location
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSize.s354,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location',
                      style: AllPopupHeadings.customTextStyle(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSize.s6),
                  SMTextfieldAsteric(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    text: 'Latitude',
                    hintText: 'e.g. 37.774900',
                    inputFormated: [_coordinateFormatter],
                    onChanged: (_) => _onLatLngTyped(),
                  ),
                  _error(_latError),
                  const SizedBox(height: AppSize.s6),
                  SMTextfieldAsteric(
                    controller: lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    text: 'Longitude',
                    hintText: 'e.g. -122.419400',
                    inputFormated: [_coordinateFormatter],
                    onChanged: (_) => _onLatLngTyped(),
                  ),
                  _error(_lngError),
                  const SizedBox(height: AppSize.s6),
                  InkWell(
                    onTap: _pickOnMap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: ColorManager.bluelight, size: AppSize.s18),
                        const SizedBox(width: 4),
                        Text(
                          'Pick on Map',
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.bluelight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSize.s20),
            SizedBox(
              width: AppSize.s354,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Click the map to move the pin',
                      style: TableSubHeading.customTextStyle(context)),
                  const SizedBox(height: AppSize.s6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: AppSize.s181,
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _currentLatLng, zoom: 15),
                        onMapCreated: (c) => _mapController = c,
                        onTap: _setLocation,
                        markers: {
                          Marker(
                            markerId: const MarkerId('office'),
                            position: _currentLatLng,
                          ),
                        },
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      bottomButtons: _saving
          ? SizedBox(
              height: AppSize.s30,
              width: AppSize.s30,
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            )
          : CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              onPressed: () { if (!_loadingDetails) _save(); },
            ),
    );
  }
}
