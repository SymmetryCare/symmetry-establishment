import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employee_banking_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employee_banking_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/bancking_child/widget/edit_banking_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';

import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';

class BankingHeadTabbar extends StatefulWidget {
  final int employeeID;
  final String employeeStatus;
  const BankingHeadTabbar({
    super.key,
    required this.employeeID,
    required this.employeeStatus,
  });

  @override
  State<BankingHeadTabbar> createState() => _BankingHeadTabbarState();
}

class _BankingHeadTabbarState extends State<BankingHeadTabbar> {
  // 16 to match the Wrap spacing the Qualifications card grids use.
  static const double _cardSpacing = 16;

  final StreamController<List<EmployeeBankingData>> _bankingStream =
  StreamController<List<EmployeeBankingData>>.broadcast();
  bool _isDisposed = false;

  // ✅ controllers kept as instance fields so Add/Edit popups reuse them safely
  final TextEditingController effectiveDateController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController verifyAccountController = TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();
  final TextEditingController specificAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanking());
  }

  Future<void> _loadBanking() async {
    try {
      final data = await getEmployeeBanking(context, widget.employeeID);
      if (!_isDisposed) _bankingStream.add(data);
    } catch (e) {
      print("Error $e");
      if (!_isDisposed) _bankingStream.add([]);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bankingStream.close();
    effectiveDateController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    verifyAccountController.dispose();
    routingNumberController.dispose();
    specificAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? selectedType;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        // The other tabs get this inset from manage_screen's _scroll/_bounded
        // helpers; Banking is handed to the TabBarView bare, so its content
        // sat flush against the panel's edge. Padding the scroll view rather
        // than the button keeps the button and the cards in line.
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        // stretch, not the default centre: the card grid shrink-wraps to its
        // content, so a row that does not happen to be full (a single card,
        // or an odd last row) used to float to the middle of the panel
        // instead of starting under the "+ Add New" button. Any leftover
        // width now falls on the right, as it does in the Qualifications
        // grids.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // left: 3 matches the card grid's own padding below, so the
            // button's left edge lines up with the first card.
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                    widget.employeeStatus == "Terminated" || widget.employeeStatus == "Inactive"
                        ? const Offstage()
                        : AddNewOutlinedButton(
                            onPressed: () {
                              effectiveDateController.clear();
                              bankNameController.clear();
                              accountNumberController.clear();
                              verifyAccountController.clear();
                              routingNumberController.clear();
                              specificAmountController.clear();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AddBankingPopup(
                                  employeeID: widget.employeeID,
                                  banckId: 0,
                                ),
                              ).then((_) => _loadBanking());
                            }),
                ],
              ),
            ),
            // Breathing room between the toolbar row and the first card.
            const SizedBox(height: 18),
            StreamBuilder<List<EmployeeBankingData>>(
              stream: _bankingStream.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: CircularProgressIndicator(color: ColorManager.blueprime),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Text(
                        AppStringHRNoData.bankingNoData,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    ),
                  );
                }

                // Same responsive card grid as the Qualifications tabs:
                // as many columns as the panel can hold without squeezing a
                // card, each card sized to its column.
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ManageCardGrid(
                    spacing: _cardSpacing,
                    children: List.generate(snapshot.data!.length, (index) {
                      return BankingContainerConst(
                        approved:
                            snapshot.data![index].approve == true,
                        employeeStatus: widget.employeeStatus,
                        index: index,
                        bankId: snapshot.data![index].empBankingId,
                        typeName: snapshot.data![index].type,
                        acNumber: snapshot.data![index].accountNumber,
                        effectiveDate: snapshot.data![index].effectiveDate,
                        requestPercentage: snapshot.data![index].percentage,
                        bankName: snapshot.data![index].bankName,
                        routinNo: snapshot.data![index].routinNumber,
                        effectiveDateController: effectiveDateController,
                        bankNameController: bankNameController,
                        accountNumberController: accountNumberController,
                        verifyAccountController: verifyAccountController,
                        routingNumberController: routingNumberController,
                        specificAmountController: specificAmountController,
                        onPressed: () {
                          // FIX: compute the future once per press instead of
                          // inline inside the dialog's builder, which re-fires
                          // the API call on every rebuild of the dialog.
                          final Future<EmployeeBankingPrefillData>
                              prefillFuture = getPrefillEmployeeBancking(
                              context, snapshot.data![index].empBankingId);
                          showDialog(
                            context: context,
                            builder: (_) => FutureBuilder<EmployeeBankingPrefillData>(
                              future: prefillFuture,
                              builder: (context, snapshotPrefill) {
                                if (snapshotPrefill.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: ColorManager.blueprime,
                                    ),
                                  );
                                }
                                var bankid = snapshotPrefill.data!.empBankingId;
                                var bankName = snapshotPrefill.data!.bankName;
                                bankNameController.text = snapshotPrefill.data!.bankName;

                                var effectiveDate = snapshotPrefill.data!.effectiveDate;
                                effectiveDateController.text =
                                    snapshotPrefill.data!.effectiveDate;

                                var accountNumber = snapshotPrefill.data!.accountNumber;
                                accountNumberController.text =
                                    snapshotPrefill.data!.accountNumber;

                                var routingNumber = snapshotPrefill.data!.routinNumber;
                                routingNumberController.text =
                                    snapshotPrefill.data!.routinNumber;

                                var amount = snapshotPrefill.data!.amountRequested;
                                selectedType = snapshotPrefill.data!.type;
                                specificAmountController.text =
                                    snapshotPrefill.data!.amountRequested.toString();
                                verifyAccountController.text =
                                    snapshotPrefill.data!.accountNumber;

                                return EditBankingPopUp(
                                  title: 'Edit Banking',
                                  banckId: bankid,
                                  effectiveDateController: effectiveDateController,
                                  bankNameController: bankNameController,
                                  accountNumberController: accountNumberController,
                                  verifyAccountController: verifyAccountController,
                                  routingNumberController: routingNumberController,
                                  specificAmountController: specificAmountController,
                                  selectedType: selectedType,
                                  documentUrl: snapshotPrefill.data!.checkUrl,   // ← NEW: forwards the S3 PDF url
                                  onPressed: (gropvalue) async {
                                    return await PatchEmployeeBanking(
                                      context,
                                      snapshot.data![index].empBankingId,
                                      snapshotPrefill.data!.employeeId,
                                      accountNumber == accountNumberController.text
                                          ? accountNumber.toString()
                                          : accountNumberController.text,
                                      bankName == bankNameController.text
                                          ? bankName.toString()
                                          : bankNameController.text,
                                      amount == int.parse(specificAmountController.text)
                                          ? amount
                                          : int.parse(specificAmountController.text),
                                      snapshotPrefill.data!.checkUrl,
                                      effectiveDate == effectiveDateController.text
                                          ? effectiveDate.toString()
                                          : effectiveDateController.text,
                                      routingNumber == routingNumberController.text
                                          ? routingNumber.toString()
                                          : routingNumberController.text,
                                      snapshotPrefill.data!.percentage,
                                      gropvalue,
                                    );
                                  },
                                  onSaved: () async {
                                    _loadBanking();
                                  },
                                  documentName: snapshotPrefill.data!.documentName,
                                );
                              },
                            ),
                          );
                        },
                        onPressedPrint: () async {
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
                                        style: pw.TextStyle(
                                            fontSize: 24, fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Divider(),
                                      pw.SizedBox(height: 10),
                                      pw.Text(
                                        'Bank #${index + 1}',
                                        style: pw.TextStyle(
                                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(height: 20),
                                      pw.Table(
                                        border: pw.TableBorder.all(),
                                        children: [
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Type',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(bankingData.type),
                                            ),
                                          ]),
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Effective Date',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(bankingData.effectiveDate),
                                            ),
                                          ]),
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Bank Name',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(bankingData.bankName),
                                            ),
                                          ]),
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Routing/Transit No.',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(bankingData.routinNumber),
                                            ),
                                          ]),
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Account No.',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(bankingData.accountNumber),
                                            ),
                                          ]),
                                          pw.TableRow(children: [
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text('Requested Amount',
                                                  style: pw.TextStyle(
                                                      fontWeight: pw.FontWeight.bold)),
                                            ),
                                            pw.Padding(
                                              padding: const pw.EdgeInsets.all(8),
                                              child: pw.Text(
                                                  bankingData.amountRequested.toString()),
                                            ),
                                          ]),
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
                      );
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Container Constant — unchanged
class BankingContainerConst extends StatelessWidget {
  int index;
  int bankId;
  String typeName;
  String acNumber;
  String effectiveDate;
  String requestPercentage;
  String bankName;
  String routinNo;
  final bool approved;
  final employeeStatus;
  final VoidCallback onPressed;
  final VoidCallback onPressedPrint;
  final TextEditingController effectiveDateController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController verifyAccountController;
  final TextEditingController routingNumberController;
  final TextEditingController specificAmountController;

  BankingContainerConst({
    Key? key,
    required this.index,
    required this.bankId,
    required this.typeName,
    required this.acNumber,
    required this.effectiveDate,
    required this.requestPercentage,
    required this.bankName,
    required this.routinNo,
    this.approved = false,
    required this.effectiveDateController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.verifyAccountController,
    required this.routingNumberController,
    required this.specificAmountController,
    required this.onPressed,
    required this.onPressedPrint,
    this.employeeStatus,
  }) : super(key: key);

  /// Fixed row height so cards sitting side by side line up, matching the
  /// Qualifications cards.
  static const double _rowHeight = 34;
  // 35 to fill the title row and match the status chip beside it.
  static const double _buttonHeight = 35;

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

  Widget _valueText(BuildContext context, String text) {
    return SizedBox(
      height: _rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: ManageCardValueStyle.customTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit =
        employeeStatus != "Terminated" && employeeStatus != "Inactive";
    return CardDetails(
      childWidget: DetailsFormate(
        title: 'Bank #${index + 1}',
        // Approval pill and both actions ride in the title row, where there
        // is free space to the right of the title — as the Employment card
        // does with its status pill — so nothing sits under the field
        // columns and the card loses its trailing strip. Pinned to the
        // chip's height whether or not the chip shows, so an approved card
        // is exactly as tall as one that is not and the two line up side by
        // side.
        titleTrailing: SizedBox(
          height: 35,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (approved) ...[
                const CardStatusChip.approved(),
                const SizedBox(width: 10),
              ],
              OutlinedActionButton(
                label: AppStringHr.voidcheck,
                trailingIcon: Icons.remove_red_eye_outlined,
                width: 110,
                height: _buttonHeight,
                fontSize: 13,
                onPressed: onPressedPrint,
              ),
              if (canEdit) ...[
                const SizedBox(width: 10),
                OutlinedActionButton(
                  label: AppStringHr.edit,
                  icon: Icons.edit_outlined,
                  width: 90,
                  height: _buttonHeight,
                  fontSize: 13,
                  onPressed: onPressed,
                ),
              ],
            ],
          ),
        ),
        row1Child1: [
          const SizedBox(height: 5),
          _labelText(context, AppStringHr.type),
          _labelText(context, AppStringHr.effectiveDate),
          _labelText(context, AppStringHr.bankName),
        ],
        row1Child2: [
          const SizedBox(height: 5),
          _valueText(context, typeName),
          _valueText(context, effectiveDate),
          _valueText(context, bankName),
        ],
        row2Child1: [
          const SizedBox(height: 5),
          _labelText(context, AppStringHr.routingNo),
          _labelText(context, AppStringHr.accNo),
          _labelText(context, AppStringHr.requestPercent),
        ],
        row2Child2: [
          const SizedBox(height: 5),
          _valueText(context, routinNo),
          _valueText(context, acNumber),
          _valueText(context, requestPercentage),
        ],
        // Nothing under the field columns: both actions moved up into
        // the title row, so this collapses rather than leaving a dead
        // strip under the last field row (same as the Employment card).
        button: const SizedBox.shrink(),
      ),
    );
  }
}
