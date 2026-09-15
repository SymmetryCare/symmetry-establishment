import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/offer_letter_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/offer_letter_html_data/offer_letter_html.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/top_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/signature_screen.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/app/services/token/token_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/bottom_row.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/multi_step_form.dart';

class OfferLetterDescriptionScreen extends StatefulWidget {
  final dynamic signatureBytes;
  final int employeeId;
  final int depID;
  final int templateId;
  final int employeeEnrollId;

  const OfferLetterDescriptionScreen(
      {this.signatureBytes,
        required this.employeeId,
        required this.depID,
        required this.templateId,
        required this.employeeEnrollId});

  @override
  State<OfferLetterDescriptionScreen> createState() =>
      _OfferLetterDescriptionScreenState();
}

class _OfferLetterDescriptionScreenState
    extends State<OfferLetterDescriptionScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  PlatformFile? _selectedFile;
  Uint8List? _webImage;
  Uint8List? signatureBytes;

  // Width of the offer letter (Html container). The signature block,
  // checkbox and buttons all align against this same width.
  static const double letterWidth = 1032;

  // Shared left/right inset used by BOTH the letter text and the
  // signature / Upload Sign / checkbox block, so their left edges
  // are always identical on every screen size.
  // Tune this single value if your HTML template has its own inset.
  static const double letterInnerPadding = 32;

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<OfferLetterData> _offerLetterFuture;

  @override
  void initState() {
    super.initState();
    _offerLetterFuture =
        GetOfferLetter(context, widget.employeeId, widget.templateId);
    // Initialize the signatureBytes with the value passed from the previous screen
    signatureBytes = widget.signatureBytes;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  int offerId = 1;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopRowConstant(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                  height: constraints.maxHeight,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Offer Letter',
                                style: FormHeading.customTextStyle(context)),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 15),

                        // --- Offer letter (centered, fixed width, shared padding) ---
                        FutureBuilder<OfferLetterData>(
                          future: _offerLetterFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: letterWidth,
                                height: 1190,
                              );
                            }
                            if (snapshot.hasData) {
                              offerId = snapshot.data!.offerId;
                              return Container(
                                color: Colors.white,
                                width: letterWidth,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: letterInnerPadding),
                                child: Html(
                                  data:
                                  "<div>${snapshot.data!.template}</div>",
                                  style: {
                                    // Remove flutter_html's default outer
                                    // margins so the text starts exactly at
                                    // the container's padded edge.
                                    // (On flutter_html 2.x use
                                    //  margin/padding: EdgeInsets.zero)
                                    "body": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "div": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "p": Style(
                                      fontSize: FontSize(12.0),
                                      color: const Color(0xff686464),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    "li": Style(
                                      fontSize: FontSize(12.0),
                                      color: const Color(0xff686464),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    "table": Style(
                                      fontSize: FontSize(12.0),
                                      color: const Color(0xff686464),
                                    ),
                                    "td": Style(
                                      fontSize: FontSize(12.0),
                                      color: const Color(0xff686464),
                                    ),
                                  },
                                ),
                              );
                            } else {
                              return const SizedBox(
                                height: 1,
                                width: 1,
                              );
                            }
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height / 80),

                        // --- Signature + Upload button block ---
                        // Same width, centering, AND inner padding as the
                        // letter, so the button lines up exactly with the
                        // letter text on every screen size.
                        Center(
                          child: SizedBox(
                            width: letterWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: letterInnerPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Signature preview
                                  SizedBox(
                                    width: 250,
                                    height: 90,
                                    child: signatureBytes != null
                                        ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.memory(
                                        signatureBytes!,
                                        width: 120,
                                        height: 90,
                                        fit: BoxFit.contain,
                                        filterQuality:
                                        FilterQuality.high,
                                      ),
                                    )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(height: 10),

                                  // Upload Sign button — same left edge as
                                  // the letter text above.
                                  SizedBox(
                                    width: 250,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SignaturePage(
                                                  onSignatureSelected:
                                                      (Uint8List?
                                                  selectedSignature) {
                                                    setState(() {
                                                      signatureBytes =
                                                          selectedSignature;
                                                    });
                                                  },
                                                  employeeId: widget.employeeId,
                                                  depID: widget.depID,
                                                  templateId: widget.templateId,
                                                  employeeEnrollId:
                                                  widget.employeeEnrollId,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xff50B5E5),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Upload Sign',
                                        style: BlueButtonTextConst
                                            .customTextStyle(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return Column(
                              children: [
                                // Terms & conditions checkbox — shown only
                                // after a signature has been uploaded, and
                                // aligned to the same left edge as the
                                // letter text and Upload Sign button.
                                if (signatureBytes != null)
                                  Center(
                                    child: SizedBox(
                                      width: letterWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: letterInnerPadding),
                                        child: Row(
                                          children: [
                                            Theme(
                                              data: Theme.of(context)
                                                  .copyWith(
                                                splashColor:
                                                Colors.transparent,
                                                highlightColor:
                                                Colors.transparent,
                                              ),
                                              child: Checkbox(
                                                splashRadius: 0,
                                                // Removes the checkbox's
                                                // built-in material padding
                                                // so it sits flush with the
                                                // button's left edge.
                                                visualDensity:
                                                const VisualDensity(
                                                    horizontal: -4,
                                                    vertical: -4),
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                activeColor:
                                                ColorManager.blueprime,
                                                value: _isChecked,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    _isChecked = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'I agree to the terms & conditions',
                                              style: onlyFormDataStyle
                                                  .customTextStyle(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                // Continue button (centered on the page)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _isChecked
                                          ? () async {
                                        ApiData updateOfferFuture =
                                        await updateOfferLetter(
                                          context,
                                          offerId,
                                          widget.employeeEnrollId,
                                          widget.employeeId,
                                          true,
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now()),
                                        );
                                        if (updateOfferFuture.statusCode == 200 ||
                                            updateOfferFuture.statusCode == 201) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmationPopup(
                                                onCancel: () {
                                                  Navigator.pop(context);
                                                },
                                                onConfirm: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MultiStepForm(
                                                            employeeID: widget.employeeId,
                                                            depID: widget.depID,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                title: 'Offer Letter',
                                                containerText:
                                                'Offer Accepted Successfully.',
                                              );
                                            },
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConfirmationPopup(
                                                onCancel: () {
                                                  Navigator.pop(context);
                                                },
                                                onConfirm: () async {
                                                  Navigator.push(context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MultiStepForm(
                                                            employeeID: widget.employeeId,
                                                            depID: widget.depID,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                title: 'Offer Letter',
                                                containerText:
                                                'Offer Already Accepted',
                                              );
                                            },
                                          );
                                        }
                                      }
                                          : null, // Disabled until checkbox checked
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xff50B5E5),
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomBarRow(),
    );
  }
}

class ConfirmationPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool? loadingDuration;
  final String title;
  final String containerText;

  const ConfirmationPopup({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.loadingDuration,
    required this.title,
    required this.containerText,
  });

  @override
  State<ConfirmationPopup> createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends State<ConfirmationPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s350,
        height: AppSize.s181,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      widget.title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorManager.white,
                        size: IconSize.I18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 15),
              child: Row(
                children: [
                  Text(
                    widget.containerText,
                    textAlign: TextAlign.center,
                    style: ConstTextFieldRegister.customTextStyle(context),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p24),
                  child: SizedBox(
                    width: 100,
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: ColorManager.blueprime,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TransparentButtonTextConst.customTextStyle(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppPadding.p20),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppPadding.p24, right: AppPadding.p10),
                  child: Center(
                    child: CustomElevatedButton(
                      width: AppSize.s105,
                      height: AppSize.s30,
                      text: 'Confirm',
                      isLoading: widget.loadingDuration == true,
                      onPressed: () {
                        // Execute the confirm action and navigate
                        widget.onConfirm();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}