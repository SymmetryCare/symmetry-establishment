import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:open_file/open_file.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/common_resources/common_theme_const.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/whitelabelling_manager.dart';
import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/text_form_field_const.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';

import '../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../data/api_data/establishment_data/whitelabelling_modal/whitelabelling_modal_.dart';
import '../../../../../../presentation/widgets/widgets/custom_scrollbar.dart';

class WhitelabellingScreen extends StatefulWidget {
  final String officeId;
  final VoidCallback backButtonCallback;

  WhitelabellingScreen(
      {super.key, required this.officeId, required this.backButtonCallback});

  @override
  State<WhitelabellingScreen> createState() => _WhitelabellingScreenState();
}

class _WhitelabellingScreenState extends State<WhitelabellingScreen> {
  // ── Form controllers ──────────────────────────────────────────────────────────
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController secNumberController = TextEditingController();
  TextEditingController primNumController = TextEditingController();
  TextEditingController altNumController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hcoNumController = TextEditingController();
  TextEditingController medicareController = TextEditingController();
  TextEditingController npiNumController = TextEditingController();
  TextEditingController faxController = TextEditingController();

  TextEditingController addressCtlr = TextEditingController();
  TextEditingController nameCtlr = TextEditingController();
  TextEditingController secNumberCtlr = TextEditingController();
  TextEditingController primNumCtlr = TextEditingController();
  TextEditingController altNumCtlr = TextEditingController();
  TextEditingController emailCtlr = TextEditingController();
  TextEditingController hcoNumCtlr = TextEditingController();
  TextEditingController medicareCtlr = TextEditingController();
  TextEditingController npiNumCtlr = TextEditingController();
  TextEditingController faxCtlr = TextEditingController();

  // ── Stream controllers ────────────────────────────────────────────────────────
  final StreamController<List<PlatformFile>> _mobileFilesStreamController =
  StreamController<List<PlatformFile>>.broadcast();
  final StreamController<List<PlatformFile>> _webFilesStreamController =
  StreamController<List<PlatformFile>>.broadcast();
  final StreamController<List<WhiteLabellingCompanyDetailModal>> _controller =
  StreamController<List<WhiteLabellingCompanyDetailModal>>();

  bool showManageScreen = false;
  bool showWhitelabellingScreen = true;
  final ScrollController _horizontalScrollController = ScrollController();

  // ── Logo state ────────────────────────────────────────────────────────────────
  /// Raw bytes of the locally-picked file (used for Image.memory preview)
  dynamic filePath;
  String fileName = "No Chosen";

  List<PlatformFile>? pickedMobileFiles;
  List<PlatformFile>? pickedWebFiles;

  /// true while an upload/patch API call is in flight
  bool _isLogoUploading = false;

  /// Single future shared by all three FutureBuilders; refreshed after upload
  late Future<WhiteLabellingCompanyDetailModal> _whitelabelFuture;

  // ── Address autocomplete ──────────────────────────────────────────────────────
  ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier([]);

  var maskFormatter = MaskTextInputFormatter(
      mask: '+# (###) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool _isEditing = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _whitelabelFuture = getWhiteLabellingData(context);
    addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _mobileFilesStreamController.close();
    _webFilesStreamController.close();
    _controller.close();
    addressController.removeListener(_onAddressChanged);
    nameController.dispose();
    addressController.dispose();
    secNumberController.dispose();
    primNumController.dispose();
    altNumController.dispose();
    emailController.dispose();
    faxController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _refreshData() {
    if (!mounted) return;
    setState(() {
      _whitelabelFuture = getWhiteLabellingData(context);
      filePath = null;
      fileName = "No Chosen";
    });
  }

  void _onAddressChanged() async {
    if (addressController.text.isEmpty) {
      _suggestionsNotifier.value = [];
      return;
    }
    final suggestions = await fetchSuggestions(addressController.text);
    _suggestionsNotifier.value = suggestions;
  }

  // ── Pick file → upload immediately ───────────────────────────────────────────
  /// Opens the file picker. On selection it:
  ///   1. Shows an immediate local preview (Image.memory).
  ///   2. Calls PATCH if a logo already exists, otherwise POST.
  ///   3. Refreshes the future on success, rolls back preview on failure.
  Future<void> _pickAndUploadLogo({
    required bool hasExistingLogo,
    int? existingLogoId,
  }) async {
    // Guard: don't open picker while another upload is running
    if (_isLogoUploading) return;

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg','svg'],
    );

    if (result == null) return; // user cancelled

    final bytes = result.files.first.bytes;
    final name = result.files.first.name;

    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not read file bytes. Please try again.')),
        );
      }
      return;
    }

    // Show preview + spinner immediately
    setState(() {
      filePath = bytes;
      fileName = name;
      _isLogoUploading = true;
    });

    try {
      if (hasExistingLogo && existingLogoId != null) {
        // ── PATCH existing logo ────────────────────────────────────────────
        final response = await patchWebAndAppLogo(
          context: context,
          type: "web",
          documentFile: bytes,
          companyLogoId: existingLogoId,
          documentName: name,
        );
        if (!mounted) return;
        if (response.statusCode == 200 || response.statusCode == 201) {
          _refreshData();
          showDialog(
            context: context,
            builder: (_) =>
            const EditSuccessPopup(message: 'Logo updated successfully'),
          );
        } else {
          // Roll back preview on failure
          setState(() { filePath = null; fileName = "No Chosen"; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.message ?? 'Update failed. Try again.')),
          );
        }
      } else {
        // ── POST new logo ──────────────────────────────────────────────────
        final response = await uploadWebAndAppLogo(
          context: context,
          type: "web",
          documentFile: bytes,
          documentName: name,
        );
        if (!mounted) return;
        if (response.statusCode == 200 || response.statusCode == 201) {
          _refreshData();
          showDialog(
            context: context,
            builder: (_) =>
            const EditSuccessPopup(message: 'Logo uploaded successfully'),
          );
        } else {
          setState(() { filePath = null; fileName = "No Chosen"; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.message ?? 'Upload failed. Try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { filePath = null; fileName = "No Chosen"; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogoUploading = false);
    }
  }

  // ── Logo container with overlaid pencil button ────────────────────────────────
  Widget _buildLogoPanel(
      AsyncSnapshot<WhiteLabellingCompanyDetailModal> snapshot) {
    final bool isWaiting =
        snapshot.connectionState == ConnectionState.waiting;
    final bool hasLogo =
        snapshot.hasData && snapshot.data!.logos.isNotEmpty;
    final int? existingLogoId =
    hasLogo ? snapshot.data!.logos[0].companyLogoId : null;
    final String? serverLogoUrl =
    hasLogo ? snapshot.data!.logos[0].url : null;

    return Stack(
      children: [
        // ── Main bordered box ─────────────────────────────────────────────────
        Container(
          height: 320,
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: ColorManager.blueprime),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: _buildLogoContent(
              isWaiting: isWaiting,
              hasLogo: hasLogo,
              serverLogoUrl: serverLogoUrl,
            ),
          ),
        ),

        // ── Pencil / add button pinned to bottom-right ────────────────────────
        // Hidden while data is loading; shows spinner while upload is running.
        if (!isWaiting)
          Positioned(
            top: 20,
            right: 21,
            child: _isLogoUploading
                ? _circleWidget(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
                : Tooltip(
              message: hasLogo ? 'Change logo' : 'Add logo',
              child: InkWell(
                onTap: () => _pickAndUploadLogo(
                  hasExistingLogo: hasLogo,
                  existingLogoId: existingLogoId,
                ),
                borderRadius: BorderRadius.circular(20),
                child: _circleWidget(
                  child: Icon(
                    hasLogo
                        ? Icons.edit_outlined
                        : Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Shared styled circle container for the action button
  Widget _circleWidget({required Widget child}) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: ColorManager.blueprime,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Pure display logic for what goes inside the bordered box
  Widget _buildLogoContent({
    required bool isWaiting,
    required bool hasLogo,
    required String? serverLogoUrl,
  }) {
    // 1. Initial API loading
    if (isWaiting) {
      return const CircularProgressIndicator();
    }

    // 2. Local bytes ready — show preview (+ "Uploading…" label while in-flight)
    if (filePath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.memory(
            filePath,
            height: AppSize.s100,
            width: AppSize.s100,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Image.asset("images/forwebprohealth.png"),
          ),
          const SizedBox(height: 8),
          Text(
            _isLogoUploading ? 'Uploading…' : 'Preview',
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.mediumgrey,
            ),
          ),
        ],
      );
    }

    // 3. Logo fetched from server
    if (hasLogo && serverLogoUrl != null) {
      return Image.network(
        serverLogoUrl,
        height: AppSize.s100,
        width: AppSize.s100,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: AppSize.s25,
            width: AppSize.s25,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) =>
            Image.asset("images/forwebprohealth.png"),
      );
    }

    // 4. Empty state
    return Text(
      'No available logo!',
      style: DocumentTypeDataStyle.customTextStyle(null as BuildContext),
    );
  }

  // ── Details Save (form) ───────────────────────────────────────────────────────
  Future<void> _onSaveDetails() async {
    // Wire up your details update API call here
  }

  // ── Main build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;

        return CustomScrollbar(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p10),
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Top bar ────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.s40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onPressed: widget.backButtonCallback,
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: ColorManager.mediumgrey,
                                size: IconSize.I16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p15),
                              child: Text(
                                AppStringEM.logos,
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width /
                                    4.2),
                            Expanded(
                              child: Text(
                                AppStringEM.details,
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                            ),
                            // Details Save button (form only, not logo)
                            SizedBox(
                              height: AppSize.s30,
                              width: AppSize.s90,
                              child: CustomButton(
                                borderRadius: 12,
                                style: BlueButtonTextConst.customTextStyle(
                                    context),
                                text: AppStringEM.save,
                                onPressed: _onSaveDetails,
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width /
                                    50),
                          ],
                        ),
                      ),

                      // ── Logo + Details row ─────────────────────────────────
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Logo panel ─────────────────────────────────────
                            Expanded(
                              flex: 2,
                              child: FutureBuilder<
                                  WhiteLabellingCompanyDetailModal>(
                                future: _whitelabelFuture,
                                builder: (context, snapshot) =>
                                    _buildLogoPanel(snapshot),
                              ),
                            ),

                            const SizedBox(width: AppSize.s35),

                            // ── Details panel ──────────────────────────────────
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(15.0),
                                    padding: const EdgeInsets.all(
                                        AppPadding.p3),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: ColorManager.blueprime),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                    height: 320,
                                    width: 1100,
                                    child: FutureBuilder<
                                        WhiteLabellingCompanyDetailModal>(
                                      future: _whitelabelFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }
                                        if (snapshot.hasData) {
                                          final data = snapshot.data!;
                                          nameController =
                                              TextEditingController(
                                                  text: data
                                                      .companyDetail.name);
                                          secNumberController.text = data
                                              .contactDetail.secondaryPhone;
                                          faxController.text =
                                              data.contactDetail.primaryFax;
                                          addressController.text =
                                              data.companyDetail.address;
                                          primNumController.text =
                                              data.contactDetail.primaryPhone;
                                          altNumController.text = data
                                              .contactDetail.alternativePhone;
                                          emailController.text =
                                              data.contactDetail.email;

                                          return Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  EditTextField(
                                                    enabled: _isEditing,
                                                    controller:
                                                    nameController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM
                                                        .companyName,
                                                  ),
                                                  SizedBox(
                                                      height: AppSize.s9),
                                                  EditTextFieldPhone(
                                                    controller:
                                                    secNumberController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM.secNum,
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                      height: AppSize.s9),
                                                  EditTextField(
                                                    controller:
                                                    faxController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM.fax,
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                      height: AppSize.s9),
                                                  EditTextField(
                                                    controller:
                                                    emailController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM
                                                        .primarymail,
                                                    enabled: _isEditing,
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  EditTextFieldPhone(
                                                    controller:
                                                    primNumController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM.primNum,
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                      height: AppSize.s9),
                                                  EditTextFieldPhone(
                                                    controller:
                                                    altNumController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM
                                                        .alternatephone,
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                      height: AppSize.s9),
                                                  EditTextField(
                                                    controller:
                                                    addressController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: "Street Address",
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                    height: AppSize.s60,
                                                    width: AppSize.s354,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}