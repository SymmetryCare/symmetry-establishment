import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_qualification_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/qualification_tab_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/reject_popup_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/widgets/widgets/banking_tab_constant.dart';
// TODO: verify these two import paths point at the actual definitions in
// your project — BorderIconButton and downloadFile weren't in the files
// shared with me, so these are best-guess locations based on similar
// widgets/utilities used elsewhere (e.g. HealthRecordConstant).
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';

class QualificationEducation extends StatefulWidget {
  final int employeeId;
  const QualificationEducation({Key? key, required this.employeeId})
      : super(key: key);

  @override
  State<QualificationEducation> createState() =>
      _QualificationEducationState();
}

class _QualificationEducationState extends State<QualificationEducation> {
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

  // FIX: fixed height for the title-row trailing slot (View button /
  // nothing). Previously titleTrailing was passed as `null` whenever
  // documentUrl == "--", and DetailsFormate only renders titleTrailing
  // when it's non-null — no placeholder existed for the "no document"
  // case. A Row's height is the max of its children, so cards with the
  // View button showing were taller than cards without it. Always
  // supplying a fixed-height widget (button or empty box) keeps every
  // card's title row the same height regardless of documentUrl.
  static const double _titleTrailingHeight = 28;

  // FIX: fixed height reserved for the bottom action-button slot too.
  // QualificationActionButtons renders differently depending on approval
  // state — a plain "Approved"/"Rejected" text label vs. actual Reject +
  // Approve pill buttons — and those two visual states have different
  // intrinsic heights (text vs. padded buttons), which is what makes an
  // already-approved card end up a different height than a still-pending
  // card. Wrapping the whole row in one fixed-height SizedBox + Align pins
  // the outer slot regardless of which state QualificationActionButtons
  // renders internally.
  // NOTE: I don't have QualificationActionButtons' source, so I can't
  // guarantee its content never exceeds this height — if it still doesn't
  // line up, bump this value up until it comfortably fits the taller
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
  // tabs, and QualificationEmployment): replaced _valueText with
  // _adaptiveValue. Overflow is decided by measuring the actual text
  // against the real available column width using TextPainter — hover
  // (MouseRegion + CompositedTransformTarget) is only wired up when the
  // text truly overflows and gets clipped with "...". If it fits, it
  // renders as plain text with no hover overhead.
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
    final providerEduState =
    Provider.of<HrOnboardingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      providerEduState.getEducationData(context, widget.employeeId);
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
                    return StreamBuilder<List<OnboardingQualificationEducationData>>(
                      stream: providerState.educationStreamController.stream,
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
                                  AppStringHRNoData.noOnboardEdnData,
                                  style: AllNoDataAvailable.customTextStyle(
                                      context),
                                ),
                              ));
                        }
                        if (snapshot.hasData) {
                          return WrapWidget(
                              children: List.generate(snapshot.data!.length,
                                      (index) {
                                    final documentUrl =
                                        snapshot.data![index].documentUrl;
                                    return CardDetails(
                                        childWidget: DetailsFormate(
                                          title: 'Education #${index + 1}',
                                          // FIX: always a fixed-height widget
                                          // now, never null, so the title row
                                          // height stays constant with or
                                          // without a document to view.
                                          titleTrailing: SizedBox(
                                            height: _titleTrailingHeight,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: documentUrl == "--"
                                                  ? const SizedBox()
                                                  : BorderIconButton(
                                                iconData: Icons.remove_red_eye_outlined,
                                                buttonText: 'View',
                                                onPressed: () {
                                                  downloadFile(context: context,
                                                      fileUrl: documentUrl!,
                                                      documentName:"education_${index + 1}_document.pdf",
                                                      apiPath: DownloadDocumentRepository.getEmployeeEducationsDocumentByFileName());
                                                },
                                              ),
                                            ),
                                          ),
                                          row1Child1: [
                                            const SizedBox(height: 5),
                                            _labelText(context, 'College/University :'),
                                            _labelText(context, 'Graduate :'),
                                            _labelText(context, 'Degree :'),
                                            _labelText(context, 'Major Subject :'),
                                          ],
                                          row1Child2: [
                                            const SizedBox(height: 5),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].college,
                                              link: _linkFor(index, 'college'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].graduate,
                                              link: _linkFor(index, 'graduate'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].degree,
                                              link: _linkFor(index, 'degree'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].major,
                                              link: _linkFor(index, 'major'),
                                              provider: providerState,
                                            ),
                                          ],
                                          row2Child1: [
                                            const SizedBox(height: 5),
                                            _labelText(context, 'Phone :'),
                                            _labelText(context, 'City :'),
                                            _labelText(context, 'State :'),
                                          ],
                                          row2Child2: [
                                            const SizedBox(height: 5),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].phone,
                                              link: _linkFor(index, 'phone'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].city?.toString(),
                                              link: _linkFor(index, 'city'),
                                              provider: providerState,
                                            ),
                                            _adaptiveValue(
                                              context,
                                              fullText: snapshot.data![index].state?.toString(),
                                              link: _linkFor(index, 'state'),
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
                                                    snapshot.data![index].approved,
                                                    onRejectPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return RejectDialog(
                                                            onYesPressed: () async {
                                                              await rejectOnboardQualifyEducationPatch(
                                                                  context,
                                                                  snapshot.data![index]
                                                                      .educationId);
                                                              providerState.getEducationData(
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
                                                                await approveOnboardQualifyEducationPatch(
                                                                    context,
                                                                    snapshot.data![index]
                                                                        .educationId);
                                                                providerState.getEducationData(
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