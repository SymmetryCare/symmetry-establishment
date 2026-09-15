import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/org_doc_ccd.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/qulification_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/corporate_compliance_constants.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/widgets/add_licences_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/qualification_licenses.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/row_container_widget_const.dart';

///done by saloni
class LicensesChildTabbar extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const LicensesChildTabbar({super.key, required this.employeeId, required this.employeeStatus});

  @override
  State<LicensesChildTabbar> createState() => _LicensesChildTabbarState();
}

class _LicensesChildTabbarState extends State<LicensesChildTabbar> {
  // FIX: stream + controllers moved to State fields — were previously
  // re-created on every build(), causing new StreamControllers and
  // duplicate fetches to pile up on every rebuild.
  final StreamController<List<QulificationLicensesFilteredData>>
  _streamController =
  StreamController<List<QulificationLicensesFilteredData>>.broadcast();

  TextEditingController livensureController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController issuingOrganizationController =
  TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController numberIDController = TextEditingController();

  String docName = 'Select Document';
  String docNameadd = 'Select';
  String docNameEdit = '';

  // FIX: single shared LayerLink was previously created fresh inline per
  // row inside List.generate. Moved to a stable Map keyed by row + field,
  // matching the pattern used in Employment/Education/References tabs, so
  // every row + field gets one persistent, unique LayerLink instead of a
  // new one on every rebuild.
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  @override
  void initState() {
    super.initState();
    // FIX: fetch exactly once here instead of inside StreamBuilder.builder.
    // Previously the API call ran on every rebuild and re-added to the
    // stream, which triggered another rebuild -> another call -> infinite
    // loop (this was the repeated ByLicenseName / reference request spam).
    _loadLicenses();
    // FrontendConfigStore.data is populated asynchronously at startup and is
    // still null if this tab is opened before that lands — the `!` here threw
    // "Unexpected null value" out of initState and killed the whole tab.
    // Read it defensively and fall back to an empty document list, matching
    // the fix already applied in offer_letter_screen / register_enroll_popup.
    final cfg = FrontendConfigStore.data?.config;
    _orgDocFuture = cfg == null
        ? Future<List<NewOrgDocument>>.value(const <NewOrgDocument>[])
        : getNewOrgDocfetch(
            context,
            cfg.corporateAndCompliance,
            cfg.subDocId1Licenses,
            1,
            999,
          );
  }

  Future<void> _loadLicenses() async {
    try {
      final data = await getEmployeeLicensesFilteredData(
          context, widget.employeeId, docName);
      if (!_streamController.isClosed) {
        _streamController.add(data);
      }
    } catch (e) {
      print("Error $e");
    }
  }

  // FIX: call this instead of re-fetching inline whenever the dropdown
  // filter (docName) changes.
  void _onDocNameChanged(String newDocName) {
    setState(() {
      docName = newDocName;
    });
    _loadLicenses();
  }

  @override
  void dispose() {
    _streamController.close();
    livensureController.dispose();
    issueDateController.dispose();
    expiryDateController.dispose();
    issuingOrganizationController.dispose();
    countryController.dispose();
    numberIDController.dispose();
    super.dispose();
  }

  // Truncate the text to 10 characters
  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) +
          '...'; // Add "..." if the text exceeds 10 characters
    }
    return text;
  }
  late Future<List<NewOrgDocument>> _orgDocFuture;

  // ── Alignment helpers ────────────────────────────────────────────────
  // Fixed row height keeps the label column and value column perfectly
  // aligned, no matter how long or short the content is.
  static const double _rowHeight = 34;

  // FIX: fixed height for the title-row trailing slot (Edit button /
  // nothing). Previously the Edit button was only added to the titleRow's
  // children list conditionally (via an `if` inside the list literal) —
  // when absent, there was no placeholder at all, not even Offstage(). A
  // Row's height is the max of its children's heights, so cards with the
  // Edit button visible ended up taller than cards without it. Wrapping
  // both states in this fixed-height box keeps every card's title row
  // (and therefore total card height) consistent.
  static const double _titleTrailingHeight = 35;
  // In-card actions use the same outlined look as the "+ Add New" button and
  // the Banking card, sized down to Banking's in-card dimensions.
  static const double _actionButtonWidth = 90;
  static const double _actionButtonFontSize = 13;


  Widget _labelText(BuildContext context, String text) {
    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: ManageCardLabelStyle.customTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // FIX: switched from fixed-character-count to WIDTH-based overflow
  // detection. A fixed character count can't work correctly here because
  // columns have different widths (e.g. "Issuing Organization :" leaves
  // less room than "Country :"), so the same character count overflows
  // in one column but fits fine in another. This measures the actual text
  // against the real available width using TextPainter, and only shows
  // hover when the text truly overflows and gets clipped with "...".
  Widget _adaptiveValue(
      BuildContext context, {
        required String? fullText,
        required LayerLink link,
        required HrManageProvider provider,
      }) {
    final text = (fullText == null || fullText.isEmpty) ? '--' : fullText;
    final style = ManageCardValueStyle.customTextStyle(context);

    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textPainter = TextPainter(
              text: TextSpan(text: text, style: style),
              maxLines: 1,
              textDirection: ui.TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final bool isOverflowing = textPainter.didExceedMaxLines;

            if (!isOverflowing) {
              // Fits fully within the column — no hover needed.
              return Text(
                text,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }

            // Doesn't fit — the UI shows "..." here, so attach hover to
            // reveal the full value.
            return MouseRegion(
              onHover: (event) {
                provider.showOverlay(context, event.position, text);
              },
              onExit: (_) => provider.removeOverlay(),
              child: CompositedTransformTarget(
                // FIX: unique link per row + field
                link: link,
                child: Text(
                  text,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final licenseProviderState =
    Provider.of<HrManageProvider>(context, listen: false);

    return Container(
      // Was a hard-capped width: 1190, which pinned the card grid to the
      // same two columns however wide the panel got — and to one column
      // once a card's minimum width rose. Full width now; the grid decides
      // the column count.
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ///Add button
                widget.employeeStatus == "Terminated"
                    || widget.employeeStatus == "Inactive" ? const Offstage() :  AddNewOutlinedButton(
                    onPressed: () {
                      livensureController.clear();
                      issueDateController.clear();
                      expiryDateController.clear();
                      issuingOrganizationController.clear();
                      countryController.clear();
                      numberIDController.clear();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddLicencesPopup(
                              onpressedClose: () {
                              },
                              title: 'Add License',
                              employeeId: widget.employeeId,
                            );
                          }).then((_) {
                        // FIX: refresh list after add dialog closes instead of
                        // relying on rebuild-triggered refetch.
                        _loadLicenses();
                      });
                    }),
                const SizedBox(width: 9),

                ///Document filter
                FutureBuilder<List<NewOrgDocument>>(
                    future: _orgDocFuture, // FIX: stable future — no refetch on rebuild
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          width: 310,
                          height: 45,
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(136, 136, 136, 0.23),
                                width: 1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                        );
                      }
                      // The field looks identical whether or not there are
                      // documents: an error / empty response just yields an
                      // empty item list, and the popup says so instead of the
                      // whole control being swapped for a message box.
                      final dropDownMenuItems =
                          (snapshot.data ?? const <NewOrgDocument>[])
                              .map((i) => DropdownMenuItem<String>(
                        value: i.docName,
                        child: Text(i.docName),
                      ))
                          .toList();

                      // Figma: Rectangle 153780 — 310x45, 11px radius,
                      // 1px rgba(136,136,136,0.23) border, label Fira Sans
                      // 400 16/19 #9D9D9D inset 23px.
                      return CICCDropdown(
                          width: 310,
                          height: 45,
                          borderRadius: 11,
                          borderColor: const Color.fromRGBO(136, 136, 136, 0.23),
                          backgroundColor: Colors.white,
                          emptyText: 'No licenses available',
                          trailingIcon: Icons.keyboard_arrow_down,
                          trailingIconSize: 18,
                          textPadding: 23,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 19 / 16,
                            color: Color(0xFF9D9D9D),
                          ),
                          constraintHeight: 180,
                          initialValue: docName,
                          onChange: (val) {
                            if (val == null) return;
                            // FIX: no need to loop — val IS the docName
                            _onDocNameChanged(val);
                            print(":::$val");
                          },
                          items: dropDownMenuItems);
                    }),
                const SizedBox(width: 15),
              ],
            ),
          ),
          // Breathing room between the toolbar row and the first card.
          const SizedBox(height: 18),
          StreamBuilder<List<QulificationLicensesFilteredData>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                // FIX: no API call here anymore — data is fed by _loadLicenses()
                // called from initState / filter change / after-dialog-refresh.
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 100),
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 100),
                        child: Text(
                          AppStringHRNoData.licenseNoData,
                          style:
                          AllNoDataAvailable.customTextStyle(context),
                        ),
                      ));
                }
                return WrapWidgetM(
                    children: List.generate(snapshot.data!.length,
                            (index) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            licenseProviderState.trimOrgString(
                                snapshot.data![index].org ?? '--');
                          });
                          // FIX/CHANGED: Edit button now shows only when a
                          // license has been REJECTED (approved == false) —
                          // previously it showed when approved == true,
                          // which was backwards from what's wanted. When
                          // approved == true (Approved) or null (Not
                          // Approved / still pending), Edit stays hidden.
                          // Computed once here so the guard and the
                          // fixed-height wrapper below stay in sync.
                          final bool showEdit = snapshot.data![index].approved ==
                              false &&
                              widget.employeeStatus != "Terminated" &&
                              widget.employeeStatus != "Inactive";
                          return CardDetails(
                              childWidget: DetailsFormate(
                                titleRow: Row(
                                  // Expanded title rather than spaceBetween:
                                  // with a pill in the row as well, spaceBetween
                                  // stranded it in the middle instead of keeping
                                  // it next to the Edit button on the right.
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'License #${index + 1}',
                                        style: ManageCardTitleStyle
                                            .customTextStyle(context),
                                      ),
                                    ),
                                    // The approval pill sits to the left of
                                    // the Edit slot, as on the Banking card,
                                    // rather than at the foot of the card.
                                    if (snapshot.data![index].approved == null)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: CardStatusChip(
                                            label: 'Not Approved'),
                                      )
                                    else if (snapshot.data![index].approved ==
                                        false)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child:
                                            CardStatusChip(label: 'Rejected'),
                                      ),
                                    // FIX: always render this fixed-height
                                    // slot so the title row (and therefore
                                    // the whole card) is the same height
                                    // whether or not the Edit button shows.
                                    SizedBox(
                                      height: _titleTrailingHeight,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: !showEdit
                                            ? const SizedBox()
                                            : OutlinedActionButton(
                                          icon: Icons.edit_outlined,
                                          label: "Edit",
                                          width: _actionButtonWidth,
                                          height: _titleTrailingHeight,
                                          fontSize: _actionButtonFontSize,
                                          onPressed: () {
                                            // FIX: compute the futures once per press instead of
                                            // inline inside the dialog's builder, which re-fires
                                            // the API calls on every rebuild of the dialog.
                                            final Future<QulificationLicensesPreFillData>
                                            licensesPrefillFuture =
                                            getEmployeeLicensesPreFill(
                                                context,
                                                snapshot.data![index]
                                                    .licenseId);
                                            final Future<List<NewOrgDocument>>
                                            editNewOrgDocFuture = getNewOrgDocfetch(
                                                context,
                                                FrontendConfigStore
                                                    .data!.config.corporateAndCompliance,
                                                FrontendConfigStore
                                                    .data!.config.subDocId1Licenses,
                                                1,
                                                200);
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return FutureBuilder<QulificationLicensesPreFillData>(
                                                      future:
                                                      licensesPrefillFuture,
                                                      builder: (context,
                                                          snapshotPrefill) {
                                                        if (snapshotPrefill
                                                            .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Center(
                                                            child:
                                                            CircularProgressIndicator(
                                                                color: ColorManager
                                                                    .blueprime),
                                                          );
                                                        }
                                                        var country = snapshotPrefill
                                                            .data!.country;
                                                        countryController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data!.country);

                                                        var expDate = snapshotPrefill
                                                            .data!.expData;
                                                        expiryDateController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data!.expData);

                                                        var issueDate = snapshotPrefill
                                                            .data!.issueDate;
                                                        issueDateController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data?.issueDate);

                                                        var licensure = snapshotPrefill
                                                            .data!.licenure;
                                                        livensureController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data?.licenure);

                                                        var licenseNumber =
                                                            snapshotPrefill
                                                                .data!.licenseNumber;
                                                        numberIDController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data!.licenseNumber);

                                                        docNameEdit = snapshotPrefill
                                                            .data!.documentType;
                                                        var org =
                                                            snapshotPrefill.data!.org;
                                                        issuingOrganizationController =
                                                            TextEditingController(
                                                                text: snapshotPrefill
                                                                    .data!.org);

                                                        var licenseUrl = snapshotPrefill
                                                            .data!.licenseUrl;

                                                        return EditLicencesPopup(
                                                          LivensureController:
                                                          livensureController,
                                                          issueDateController:
                                                          issueDateController,
                                                          expiryDateController:
                                                          expiryDateController,
                                                          issuingOrganizationController:
                                                          issuingOrganizationController,
                                                          countryController:
                                                          countryController,
                                                          numberIDController:
                                                          numberIDController,
                                                          onpressedClose: () {
                                                          },
                                                          // CHANGED: now returns Future<ApiData> instead of
                                                          // Future<void>, matching EditLicencesPopup's updated
                                                          // contract. This lets the popup itself decide what to do
                                                          // with a failure — apply per-field errors and stay open,
                                                          // or fall back to its own FailedPopup — instead of this
                                                          // callback closing/erroring on its behalf.
                                                          onpressedSave: () async {
                                                            var response =
                                                            await updateLicensePatch(
                                                                context,
                                                                snapshot.data![index]
                                                                    .licenseId,
                                                                country ==
                                                                    countryController
                                                                        .text
                                                                    ? country
                                                                    .toString()
                                                                    : countryController
                                                                    .text,
                                                                widget.employeeId,
                                                                expDate ==
                                                                    expiryDateController
                                                                        .text
                                                                    ? expDate
                                                                    .toString()
                                                                    : expiryDateController
                                                                    .text,
                                                                issueDate ==
                                                                    issueDateController
                                                                        .text
                                                                    ? issueDate
                                                                    .toString()
                                                                    : issueDateController
                                                                    .text,
                                                                licenseUrl,
                                                                licensure ==
                                                                    livensureController
                                                                        .text
                                                                    ? licensure
                                                                    : livensureController
                                                                    .text,
                                                                licenseNumber ==
                                                                    numberIDController
                                                                        .text
                                                                    ? licenseNumber
                                                                    .toString()
                                                                    : numberIDController
                                                                    .text,
                                                                org ==
                                                                    issuingOrganizationController
                                                                        .text
                                                                    ? org
                                                                    : issuingOrganizationController
                                                                    .text,
                                                                docNameEdit
                                                                    .toString());

                                                            if (response.statusCode ==
                                                                200 ||
                                                                response.statusCode ==
                                                                    201) {
                                                              Navigator.pop(context);
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext
                                                                context) {
                                                                  return const AddSuccessPopup(
                                                                    message:
                                                                    'Licenses Edited Successfully',
                                                                  );
                                                                },
                                                              ).then((_) {
                                                                // FIX: refresh after edit instead
                                                                // of relying on rebuild-triggered
                                                                // refetch.
                                                                _loadLicenses();
                                                              });
                                                            }
                                                            // REMOVED: the 400/404/else branches that used to call
                                                            // showDialog(FailedPopup(...)) here. EditLicencesPopup's
                                                            // own Save handler now does that — it applies per-field
                                                            // errors when response.fieldErrors is non-empty, and
                                                            // only falls back to a FailedPopup when it isn't. Doing
                                                            // it here too would have shown two error popups stacked
                                                            // and closed nothing, since this outer dialog never
                                                            // popped on failure anyway.

                                                            // NEW: always return the response so the popup can
                                                            // inspect statusCode/fieldErrors and act accordingly.
                                                            return response;
                                                          },
                                                          title: 'Edit License',
                                                          licenseId: snapshot
                                                              .data![index].licenseId,
                                                          documentName: snapshotPrefill
                                                              .data!.documentName,
                                                          child: FutureBuilder<List<NewOrgDocument>>(
                                                            future: editNewOrgDocFuture,
                                                            builder:
                                                                (context, snapshot) {
                                                              if (snapshot
                                                                  .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Container(
                                                                  height: AppSize.s30,
                                                                  width:240,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                          Colors.grey,
                                                                          width: 1),
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          5)),
                                                                );
                                                              }
                                                              if (snapshot
                                                                  .data!.isEmpty) {
                                                                return const Center(
                                                                    child: Offstage());
                                                              }
                                                              if (snapshot.hasData) {
                                                                List dropDown = [];
                                                                String docType = '';
                                                                List<DropdownMenuItem<String>>
                                                                dropDownMenuItems =
                                                                [];
                                                                for (var i
                                                                in snapshot.data!) {
                                                                  dropDownMenuItems.add(
                                                                    DropdownMenuItem<String>(
                                                                      child:
                                                                      Text(i.docName),
                                                                      value: i.docName,
                                                                    ),
                                                                  );
                                                                }
                                                                return CICCDropdown(
                                                                  width:240,
                                                                  initialValue: docNameEdit,
                                                                  onChange: (val) {
                                                                    for (var a
                                                                    in snapshot.data!) {
                                                                      if (a.docName ==
                                                                          val) {
                                                                        docType = a.docName;
                                                                        docNameEdit =
                                                                            docType;
                                                                      }
                                                                    }
                                                                    print(
                                                                        ":::${docType}");
                                                                  },
                                                                  items:
                                                                  dropDownMenuItems,
                                                                );
                                                              } else {
                                                                return const SizedBox();
                                                              }
                                                            },
                                                          ),
                                                        );
                                                      });
                                                });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: 'License #${index + 1}',
                                row1Child1: [
                                  const SizedBox(height: 5),
                                  _labelText(context, 'Licensure/Certification :'),
                                  _labelText(context, 'Issuing Organization :'),
                                  _labelText(context, 'Country :'),
                                  _labelText(context, 'Number/ID :'),
                                ],
                                row1Child2: [
                                  const SizedBox(height: 5),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].licenure,
                                    link: _linkFor(index, 'licenure'),
                                    provider: licenseProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].org,
                                    link: _linkFor(index, 'org'),
                                    provider: licenseProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].country,
                                    link: _linkFor(index, 'country'),
                                    provider: licenseProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].licenseNumber,
                                    link: _linkFor(index, 'licenseNumber'),
                                    provider: licenseProviderState,
                                  ),
                                ],
                                row2Child1: [
                                  const SizedBox(height: 5),
                                  _labelText(context, 'Issue Date :'),
                                  _labelText(context, 'End Date :'),
                                ],
                                row2Child2: [
                                  const SizedBox(height: 5),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].issueDate,
                                    link: _linkFor(index, 'issueDate'),
                                    provider: licenseProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].expData,
                                    link: _linkFor(index, 'expData'),
                                    provider: licenseProviderState,
                                  ),
                                ],
                                // Nothing under the field columns: the pill
                                // and the Edit button both ride in the title
                                // row above.
                                button: const SizedBox.shrink(),
                              ));
                        }));
              }),
        ],
      ),
    );
  }
}