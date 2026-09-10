import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_onboarding_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_banking_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';

// FIX: converted from StatelessWidget to StatefulWidget. Adding hover
// support requires a LayerLink per row + field that stays stable across
// rebuilds (a LayerLink can only back ONE CompositedTransformTarget at a
// time — a fresh one built every build() call would corrupt the layer
// tree). A StatelessWidget has nowhere to keep that Map alive, so this
// now follows the same StatefulWidget + Map<String, LayerLink> pattern
// used in every other tab (Employment/Education/Licenses/References and
// the Qualification* onboarding tabs).
class BankingTabContainerConstant extends StatefulWidget {
  final int employeeId;
  const BankingTabContainerConstant({required this.employeeId});

  @override
  State<BankingTabContainerConstant> createState() =>
      _BankingTabContainerConstantState();
}

class _BankingTabContainerConstantState
    extends State<BankingTabContainerConstant> {
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  // ── Alignment helpers ────────────────────────────────────────────────
  // Fixed row height keeps the label column and value column perfectly
  // aligned, no matter how long or short the content is.
  static const double _rowHeight = 26;

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
  // QualificationLicense/QualificationReferance): replaced _valueText
  // with _adaptiveValue. Overflow is decided by measuring the actual
  // text against the real available column width using TextPainter —
  // hover (MouseRegion + CompositedTransformTarget) is only wired up
  // when the text truly overflows and gets clipped with "...". If it
  // fits, it renders as plain text with no hover overhead.
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
    final providerBankingState = Provider.of<HrOnboardingProvider>(context,listen:false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      providerBankingState.getBankingData(context,widget.employeeId);
    });
    final mediaQuery = MediaQuery.of(context).size;
    return Consumer<HrOnboardingProvider>(
        builder: (context,providerState,child) {
          return StreamBuilder<List<OnboardingBankingData>>(
              stream: providerState.bankingStreamController.stream,
              builder: (context,snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 150),
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 150),
                        child: Text(
                            AppStringHRNoData.noOnboardBanking,
                            style: AllNoDataAvailable.customTextStyle(context)
                        ),
                      ));
                }
                if(snapshot.hasData){
                  return WrapWidget(
                    // alignment: WrapAlignment.center,
                    // runAlignment: WrapAlignment.center,
                    // spacing: AppSize.s16,
                    // runSpacing: AppSize.s16,
                    children: List.generate(snapshot.data!.length, (index){
                      return CardDetails(childWidget: DetailsFormate(
                        row1Child1: [
                          const SizedBox(height: 5),
                          _labelText(context, 'Type :'),
                          _labelText(context, 'Effective Date :'),
                          _labelText(context, 'Bank Name :'),
                          _labelText(context, 'Account No. :'),
                        ],
                        row1Child2: [
                          const SizedBox(height: 5),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].type,
                            link: _linkFor(index, 'type'),
                            provider: providerState,
                          ),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].effectiveDate,
                            link: _linkFor(index, 'effectiveDate'),
                            provider: providerState,
                          ),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].bankName,
                            link: _linkFor(index, 'bankName'),
                            provider: providerState,
                          ),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].accNum,
                            link: _linkFor(index, 'accNum'),
                            provider: providerState,
                          ),
                        ],
                        row2Child1: [
                          const SizedBox(height: 5),
                          _labelText(context, 'Routing/Transit No. :'),
                          _labelText(context, 'Requested amount :'),
                        ],
                        row2Child2: [
                          const SizedBox(height: 5),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].rountingNumber,
                            link: _linkFor(index, 'rountingNumber'),
                            provider: providerState,
                          ),
                          _adaptiveValue(
                            context,
                            fullText: snapshot.data![index].amtRequested?.toString(),
                            link: _linkFor(index, 'amtRequested'),
                            provider: providerState,
                          ),
                        ],
                        button:  Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomElevatedButton(
                              icon: Icons.remove_red_eye,
                              label: 'Void Check',
                              onPressed: () async {
                                try {
                                  final pdf = pw.Document();
                                  final bankingData = snapshot.data![index];
                                  pdf.addPage(
                                    pw.Page(
                                      build: (pw.Context context) => pw.Padding(
                                        padding: const pw.EdgeInsets.all(20),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              'Banking Details',
                                              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                                            ),
                                            pw.Divider(),
                                            pw.SizedBox(height: 10),
                                            pw.Text(
                                              'Bank #${index + 1}',
                                              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                                            ),
                                            pw.SizedBox(height: 20),
                                            pw.Table(
                                              border: pw.TableBorder.all(),
                                              children: [
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.type),
                                                    ),
                                                  ],
                                                ),
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Effective Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.effectiveDate),
                                                    ),
                                                  ],
                                                ),
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Bank Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.bankName),
                                                    ),
                                                  ],
                                                ),
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Routing/Transit No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.rountingNumber),
                                                    ),
                                                  ],
                                                ),
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Account No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.accNum),
                                                    ),
                                                  ],
                                                ),
                                                pw.TableRow(
                                                  children: [
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text('Requested Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                                    ),
                                                    pw.Padding(
                                                      padding: const pw.EdgeInsets.all(8),
                                                      child: pw.Text(bankingData.amtRequested.toString()),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  await Printing.layoutPdf(
                                    onLayout: (PdfPageFormat format) async => pdf.save(),
                                  );
                                } catch (e) {
                                  print('Error generating PDF: $e');
                                }
                              },
                            ),
                          ],
                        ),
                        title: 'Bank #${index + 1}',));
                    }),
                  );
                }else{
                  return const SizedBox();
                }
              }
          );
        }
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;

  const InfoText(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style:  ThemeManager.customTextStyle(context)),
        const SizedBox(height: 10),
      ],
    );
  }
}

class InfoData extends StatelessWidget {
  final String text;

  const InfoData(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style:  ThemeManagerDark.customTextStyle(context)),
        const SizedBox(height: 10),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomElevatedButton(
          icon: Icons.remove_red_eye,
          label: 'Void Check',
          onPressed: () {

          },
        ),
        const SizedBox(width: 8.0),
        CustomElevatedButton(
          icon: Icons.print_outlined,
          label: 'Print',
          iconPosition: IconPosition.right,
          onPressed: () async {
            final pdf = pw.Document();
            pdf.addPage(
              pw.Page(
                build: (pw.Context context) => pw.Center(
                  child: pw.Text('Hello, this is a test print!'),
                ),
              ),
            );

            // You can modify the content of the PDF as needed.

            await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdf.save(),
            );
          },
        ),
        const SizedBox(width: 8.0),
        CustomElevatedButton(
          icon: Icons.sim_card_download_outlined,
          label: 'Download',
          iconPosition: IconPosition.right,
          onPressed: () {

          },
        ),
      ],
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconPosition iconPosition;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconPosition = IconPosition.left,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ColorManager.blueprime,
        side: BorderSide(color: ColorManager.blueprime),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconPosition == IconPosition.left
            ? [
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color:ColorManager.blueprime,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Icon(
              icon,
              size: 12.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]
            : [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6.0),
          Icon(
            icon,
            size: 16.0,
            color:ColorManager.blueprime,
          ),
        ],
      ),
    );
  }
}

enum IconPosition { left, right }