import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/references_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/references_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/widgets/add_reference_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';

///done by saloni
class ReferencesChildTabbar extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const ReferencesChildTabbar({super.key, required this.employeeId, required this.employeeStatus});

  @override
  State<ReferencesChildTabbar> createState() => _ReferencesChildTabbarState();
}

class _ReferencesChildTabbarState extends State<ReferencesChildTabbar> {
  // FIX: stream + controllers moved to State fields — were previously
  // re-created on every build(), leaking StreamControllers and controllers
  // on every rebuild.
  final StreamController<List<ReferenceData>> _referenceStreamController =
  StreamController<List<ReferenceData>>.broadcast();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController titlePositionController = TextEditingController();
  TextEditingController knowPersonController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController associationLengthController =
  TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController referredBController = TextEditingController();

  // FIX: single shared LayerLinks were previously created fresh inline
  // per row inside List.generate (three per row: title, company,
  // references). That avoided cross-target sharing, but recreated the
  // links on every rebuild. Moved to a stable Map keyed by row + field,
  // matching the pattern used in Employment/Education tabs, so every
  // row + field gets one persistent, unique LayerLink.
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  @override
  void initState() {
    super.initState();
    // FIX: fetch exactly once here. Previously getReferences() was called
    // directly inside StreamBuilder.builder on every build, then the result
    // was added back into the same stream — which triggered another build,
    // which called the API again, forever. That was the repeated
    // /reference/ByemployeeId/... spam in the logs.
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    try {
      final data = await getReferences(context, widget.employeeId);
      if (!_referenceStreamController.isClosed) {
        _referenceStreamController.add(data);
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  void dispose() {
    _referenceStreamController.close();
    nameController.dispose();
    emailController.dispose();
    titlePositionController.dispose();
    knowPersonController.dispose();
    companyNameController.dispose();
    associationLengthController.dispose();
    mobileNumberController.dispose();
    referredBController.dispose();
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

  // ── Alignment helpers ────────────────────────────────────────────────
  // Fixed row height keeps the label column and value column perfectly
  // aligned, no matter how long or short the content is.
  static const double _rowHeight = 34;

  // FIX: fixed height for the trailing "button" row (Not Approved text /
  // Edit button / nothing). Previously only the "Not Approved" branch was
  // wrapped in SizedBox(height: AppSize.s25) — the Offstage()/BorderIconButton
  // branch had no matching fixed-height wrapper, so the row ended up at 3
  // different heights depending on state (25 for "Not Approved", 0 for
  // Offstage(), BorderIconButton's own intrinsic height for Edit), which
  // mismatched card heights across the Wrap. Every state now shares one
  // SizedBox + Align so the row height stays constant.
  static const double _buttonRowHeight = 35;
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
  // columns have different widths (e.g. "Company/ Organization :" and
  // "How do you know this person ? :" leave less room than "Name :"), so
  // the same character count overflows in one column but fits fine in
  // another. This measures the actual text against the real available
  // width using TextPainter, and only shows hover when the text truly
  // overflows and gets clipped with "...".
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
    final referenceProviderState =
    Provider.of<HrManageProvider>(context, listen: false);

    return Container(
      // Was a hard-capped width: 1190, which pinned the card grid to the
      // same two columns however wide the panel got — and to one column
      // once a card's minimum width rose. Full width now; the grid decides
      // the column count.
      width: double.infinity,
      child: Column(
        children: [
          ///add button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.employeeStatus == "Terminated"
                  || widget.employeeStatus == "Inactive" ? const Offstage() :  AddNewOutlinedButton(
                  onPressed: () {
                    nameController.clear();
                    emailController.clear();
                    titlePositionController.clear();
                    knowPersonController.clear();
                    companyNameController.clear();
                    associationLengthController.clear();
                    referredBController.clear();
                    mobileNumberController.clear();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddReferencePopup(
                            nameController: nameController,
                            emailController: emailController,
                            titlePositionController: titlePositionController,
                            knowPersonController: knowPersonController,
                            companyNameController: companyNameController,
                            associationLengthController:
                            associationLengthController,
                            mobileNumberController: mobileNumberController,
                            referredBy: referredBController,
                            onpressedClose: () {},
                            // CHANGED: the popup now calls addReferencePost
                            // itself (and shows field-level errors on
                            // failure), so this is just a lightweight
                            // post-save hook. The .then() below already
                            // refreshes the list once the dialog closes,
                            // so there's nothing extra to do here.
                            onSaved: () async {},
                            title: 'Add Reference',
                            employeeId: widget.employeeId,
                            // referenceId omitted (defaults to null) —
                            // that's what tells the popup this is an Add,
                            // not an Edit.
                          );
                        }).then((_) {
                      // FIX: refresh list after add dialog closes instead of
                      // relying on rebuild-triggered refetch.
                      _loadReferences();
                    });
                  }),
              const SizedBox(width: 15),
            ],
          ),
          // Breathing room between the toolbar row and the first card.
          const SizedBox(height: 18),
          StreamBuilder<List<ReferenceData>>(
              stream: _referenceStreamController.stream,
              builder: (context, snapshot) {
                // FIX: no API call here anymore — data is fed by
                // _loadReferences() called from initState / after-dialog-refresh.
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
                          AppStringHRNoData.referenceNoData,
                          style:
                          AllNoDataAvailable.customTextStyle(context),
                        ),
                      ));
                }
                return WrapWidgetM(
                    children: List.generate(snapshot.data!.length,
                            (index) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            referenceProviderState.trimCompanyString(
                                snapshot.data![index].company ?? '--');
                            referenceProviderState.trimTitleString(
                                snapshot.data![index].title ?? '--');
                            referenceProviderState.trimReferenceString(
                                snapshot.data![index].references ?? '--');
                          });
                          return CardDetails(
                            childWidget: DetailsFormate(
                                title: 'References #${index + 1}',
                                // Matches the Employment card: approval state
                                // is a pill in the title row, not grey text at
                                // the foot of the card.
                                titleTrailing:
                                    snapshot.data![index].approve == null
                                        ? const CardStatusChip(
                                            label: 'Not Approved')
                                        : null,
                                row1Child1: [
                                  const SizedBox(height: 5),
                                  _labelText(context, 'Name :'),
                                  _labelText(context, 'Title/ Position :'),
                                  _labelText(context, 'Mobile Number :'),
                                  _labelText(context, 'Email :'),
                                ],
                                row1Child2: [
                                  const SizedBox(height: 5),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].name,
                                    link: _linkFor(index, 'name'),
                                    provider: referenceProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].title,
                                    link: _linkFor(index, 'title'),
                                    provider: referenceProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].mobNumber,
                                    link: _linkFor(index, 'mobNumber'),
                                    provider: referenceProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].email,
                                    link: _linkFor(index, 'email'),
                                    provider: referenceProviderState,
                                  ),
                                ],
                                row2Child1: [
                                  const SizedBox(height: 5),
                                  _labelText(context, 'Company/ Organization :'),
                                  _labelText(context, 'How do you know this person ? :'),
                                  _labelText(context, 'Length of Association :'),
                                ],
                                row2Child2: [
                                  const SizedBox(height: 5),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].company,
                                    link: _linkFor(index, 'company'),
                                    provider: referenceProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].references,
                                    link: _linkFor(index, 'references'),
                                    provider: referenceProviderState,
                                  ),
                                  _adaptiveValue(
                                    context,
                                    fullText: snapshot.data![index].association,
                                    link: _linkFor(index, 'association'),
                                    provider: referenceProviderState,
                                  ),
                                ],
                                // FIX: whole trailing state (Not Approved text /
                                // Edit button / nothing for terminated-inactive)
                                // now wrapped in one SizedBox(height:
                                // _buttonRowHeight) + Align so every card in the
                                // Wrap ends up the same total height regardless
                                // of which of the 3 states is showing.
                                button: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: _buttonRowHeight,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: snapshot.data![index].approve == null
                                            ? const SizedBox()
                                            : widget.employeeStatus == "Terminated"
                                            || widget.employeeStatus == "Inactive"
                                        // was Offstage() — that removed the
                                        // child from layout entirely (0
                                        // height). An empty SizedBox still
                                        // sits inside the fixed-height
                                        // parent above, so the row height
                                        // stays consistent.
                                            ? const SizedBox()
                                            : OutlinedActionButton(
                                            icon: Icons.edit_outlined,
                                            label: 'Edit',
                                            width: _actionButtonWidth,
                                            height: _buttonRowHeight,
                                            fontSize: _actionButtonFontSize,
                                            onPressed: () {
                                              // FIX: compute the future once per press instead of
                                              // inline inside the dialog's builder, which re-fires
                                              // the API call on every rebuild of the dialog.
                                              final Future<ReferencePrefillData>
                                              referencePrefillFuture =
                                              getPrefillReferences(
                                                  context,
                                                  snapshot.data![index]
                                                      .referenceId);
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return FutureBuilder<ReferencePrefillData>(
                                                        future: referencePrefillFuture,
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
                                                                    .blueprime,
                                                              ),
                                                            );
                                                          }
                                                          nameController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.name);
                                                          emailController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.email);
                                                          titlePositionController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.title);

                                                          knowPersonController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.references);

                                                          companyNameController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.company);

                                                          associationLengthController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.association);
                                                          referredBController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.references);
                                                          mobileNumberController =
                                                              TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!.mobNumber);
                                                          // CHANGED: no more manual
                                                          // updateReferencePatch call
                                                          // here — AddReferencePopup
                                                          // now does that itself
                                                          // (as an Edit, because
                                                          // referenceId is passed
                                                          // below) and shows
                                                          // field-level errors on
                                                          // failure instead of
                                                          // popping + FailedPopup
                                                          // unconditionally.
                                                          return AddReferencePopup(
                                                            nameController:
                                                            nameController,
                                                            emailController:
                                                            emailController,
                                                            titlePositionController:
                                                            titlePositionController,
                                                            knowPersonController:
                                                            knowPersonController,
                                                            companyNameController:
                                                            companyNameController,
                                                            associationLengthController:
                                                            associationLengthController,
                                                            mobileNumberController:
                                                            mobileNumberController,
                                                            referredBy:
                                                            referredBController,
                                                            onpressedClose: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            onSaved: () async {
                                                              // CHANGED: the
                                                              // popup already
                                                              // shows its own
                                                              // success flow
                                                              // and pops itself
                                                              // on a genuine
                                                              // 200/201, so all
                                                              // that's left to
                                                              // do here is
                                                              // refresh the
                                                              // list.
                                                              await showDialog(
                                                                context: context,
                                                                builder:
                                                                    (BuildContext
                                                                context) {
                                                                  return const AddSuccessPopup(
                                                                    message:
                                                                    'Reference Edit Successfully',
                                                                  );
                                                                },
                                                              );
                                                              _loadReferences();
                                                            },
                                                            title: 'Edit Reference',
                                                            employeeId:
                                                            widget.employeeId,
                                                            // NEW: passing a
                                                            // real referenceId
                                                            // is what tells the
                                                            // popup to call
                                                            // updateReferencePatch
                                                            // instead of
                                                            // addReferencePost.
                                                            referenceId: snapshot
                                                                .data![index]
                                                                .referenceId,
                                                          );
                                                        });
                                                  });
                                            }),
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        }));
              }),
        ],
      ),
    );
  }
}