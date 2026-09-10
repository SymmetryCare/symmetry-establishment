import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/references_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/references_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_qualification_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/dialogue_template.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/qualificatin_emloyment_tab.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/qualification_tab_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/reject_popup_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';

class QualificationReferance extends StatefulWidget {
  final int employeeId;
  const QualificationReferance({Key? key, required this.employeeId})
      : super(key: key);

  @override
  State<QualificationReferance> createState() =>
      _QualificationReferanceState();
}

class _QualificationReferanceState extends State<QualificationReferance> {
  final ScrollController _horizontalScrollController = ScrollController();

  // FIX: single shared LayerLinks would need the same per-row + per-field
  // uniqueness fix used in Employment/Education/Licenses/References tabs,
  // now that hover is being wired up here too — a LayerLink can only back
  // ONE CompositedTransformTarget at a time, so reusing one across rows
  // would corrupt the layer tree ("Assertion failed: layer.dart:2461").
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // ── Alignment helpers ────────────────────────────────────────────────
  // Fixed row height keeps the label column and value column perfectly
  // aligned, no matter how long or short the content is.
  static const double _rowHeight = 26;

  // FIX: fixed height reserved for the bottom action-button slot.
  // QualificationActionButtons renders differently depending on approval
  // state — a plain "Approved"/"Rejected" text label vs. actual Reject +
  // Approve pill buttons — and those two visual states have different
  // intrinsic heights (text vs. padded buttons), which is what makes an
  // already-approved card end up a different height than a still-pending
  // card in the screenshot. Wrapping the row in one fixed-height SizedBox +
  // Align pins the outer slot regardless of which state
  // QualificationActionButtons renders internally.
  // NOTE: I don't have QualificationActionButtons' source, so I can't
  // guarantee its content never exceeds this height — if it still doesn't
  // line up, bump this value until it comfortably fits the taller
  // (Reject/Approve buttons) state.
  static const double _actionRowHeight = 36;

  Widget _labelText(BuildContext context, String text) {
    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: ThemeManagerDark.customTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // FIX (same width-based fix as Employment/Education/Licenses/References
  // tabs, and QualificationEmployment/QualificationEducation/
  // QualificationLicense): replaced _valueText with _adaptiveValue.
  // Overflow is decided by measuring the actual text against the real
  // available column width using TextPainter — hover (MouseRegion +
  // CompositedTransformTarget) is only wired up when the text truly
  // overflows and gets clipped with "...". If it fits, it renders as
  // plain text with no hover overhead.
  //
  // Uses HrOnboardingProvider.showOverlay/removeOverlay (already added
  // for QualificationEmployment's _adaptiveValue).
  Widget _adaptiveValue(
      BuildContext context, {
        required String? fullText,
        required LayerLink link,
        required HrOnboardingProvider provider,
      }) {
    final text = (fullText == null || fullText.isEmpty) ? '--' : fullText;
    final style = ThemeManagerDarkFont.customTextStyle(context);

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
    final providerRefState =
    Provider.of<HrOnboardingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      providerRefState.getReferenceData(context, widget.employeeId);
    });
    final mediaQuery = MediaQuery.of(context).size;

    return LayoutBuilder(
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
                // ── height removed: was constraints.maxHeight (Infinity) which crashed layout ──
                child: Consumer<HrOnboardingProvider>(
                  builder: (context, providerState, child) {
                    return StreamBuilder<List<OnboardingQualificationReferanceData>>(
                      stream:
                      providerState.referenceStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 150),
                              child: CircularProgressIndicator(
                                color: ColorManager.blueprime,
                              ),
                            ),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 150),
                                child: Text(
                                  AppStringHRNoData.noOnboardRefData,
                                  style: AllNoDataAvailable.customTextStyle(
                                      context),
                                ),
                              ));
                        }
                        if (snapshot.hasData) {
                          return WrapWidget(
                              children: List.generate(snapshot.data!.length,
                                      (index) {
                                    return CardDetails(
                                        childWidget: DetailsFormate(
                                          row1Child1: [
                                            const SizedBox(height: 5),
                                            _labelText(context, 'Name :'),
                                            _labelText(context, 'Title/Position :'),
                                            _labelText(context, 'Company/Organization :'),
                                            _labelText(context, 'How do you know this person ? :'),
                                          ],
                                          row1Child2: [
                                            const SizedBox(height: 5),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].name,
                                              link: _linkFor(index, 'name'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].title,
                                              link: _linkFor(index, 'title'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].company,
                                              link: _linkFor(index, 'company'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].references?.toString(),
                                              link: _linkFor(index, 'references'),
                                              provider: providerState,
                                            ),
                                          ],
                                          row2Child1: [
                                            const SizedBox(height: 5),
                                            _labelText(context, 'Mobile Number :'),
                                            _labelText(context, 'Email :'),
                                            _labelText(context, 'Length of Association :'),
                                          ],
                                          row2Child2: [
                                            const SizedBox(height: 5),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].mob,
                                              link: _linkFor(index, 'mob'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].email,
                                              link: _linkFor(index, 'email'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].association?.toString(),
                                              link: _linkFor(index, 'association'),
                                              provider: providerState,
                                            ),
                                          ],
                                          // FIX: whole action row pinned to a
                                          // fixed height + right-aligned so
                                          // the "Approved"/"Rejected" text
                                          // state and the Reject/Approve
                                          // buttons state both occupy the
                                          // same outer slot, regardless of
                                          // QualificationActionButtons'
                                          // internal content height.
                                          button: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                height: _actionRowHeight,
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: QualificationActionButtons(
                                                    isBackColor: false,
                                                    approve:
                                                    snapshot.data![index].approve,
                                                    onRejectPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return RejectDialog(
                                                            onYesPressed: () async {
                                                              await rejectOnboardQualifyReferencePatch(
                                                                  context,
                                                                  snapshot.data![index]
                                                                      .referenceId);
                                                              providerState.getReferenceData(
                                                                  context,
                                                                  widget.employeeId);
                                                              Navigator.of(context).pop();
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                    onApprovePressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return ApproveDialog(
                                                              onYesPressed: () async {
                                                                await approveOnboardQualifyReferencePatch(
                                                                    context,
                                                                    snapshot.data![index]
                                                                        .referenceId);
                                                                providerState.getReferenceData(
                                                                    context,
                                                                    widget.employeeId);
                                                                Navigator.of(context).pop();
                                                              });
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: 'References #${index + 1}',
                                        ));
                                  }));
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}