import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/post_html_manager.dart';
import 'package:symmetry_establishment/data/api_data/api_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employeement_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/controller/controller.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/add_employee_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/widgets/add_employeement_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/row_container_widget_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';

///done by saloni
class EmploymentContainerConstant extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const EmploymentContainerConstant({required this.employeeId, required this.employeeStatus});

  @override
  State<EmploymentContainerConstant> createState() =>
      _EmploymentContainerConstantState();
}

class _EmploymentContainerConstantState
    extends State<EmploymentContainerConstant> {
  // The "+ Add New" button belongs only to Education, References and
  // Professional licenses; Employment records are not added from here.
  // Flip this to true to bring the button back — the popup wiring below is
  // left intact on purpose.
  static const bool _showAddButton = false;

  bool isSelectedADD = false;
  bool isSelectedEdit = false;

  // FIX: single shared LayerLink was being reused across every row's
  // "reason" and "supervisor" CompositedTransformTarget at the same time.
  // A LayerLink can only back ONE target at a time — reusing it across
  // multiple simultaneous targets corrupted the layer tree and caused
  // "Assertion failed: layer.dart:2461" to fire repeatedly.
  // Replaced with a Map so every row + field gets its own unique link.
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  final StreamController<List<EmployeementData>> employeementStreamController =
  StreamController<List<EmployeementData>>();
  final TextEditingController positionTitleController = TextEditingController();
  final TextEditingController leavingResonController = TextEditingController();
  final TextEditingController startDateContoller = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController lastSupervisorNameController =
  TextEditingController();
  final TextEditingController supervisorMobileNumber = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController employeerController = TextEditingController();
  final TextEditingController emergencyMobileNumber = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployeement();
  }

  Future<void> _loadEmployeement() async {
    final data = await getEmployeement(context, widget.employeeId);
    if (!mounted || employeementStreamController.isClosed) return;
    employeementStreamController.add(data);
  }

  @override
  void dispose() {
    employeementStreamController.close();
    positionTitleController.dispose();
    leavingResonController.dispose();
    startDateContoller.dispose();
    endDateController.dispose();
    lastSupervisorNameController.dispose();
    supervisorMobileNumber.dispose();
    cityNameController.dispose();
    employeerController.dispose();
    emergencyMobileNumber.dispose();
    countryController.dispose();
    super.dispose();
  }

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text;
  }

  // ── Alignment helpers ────────────────────────────────────────────────
  // Fixed row height keeps the label column and value column perfectly
  // aligned, no matter how long or short the content is.
  // Figma has these rows on a 38px pitch; tightened slightly from that.
  static const double _rowHeight = 34;

  // FIX: fixed height for the trailing "button" row (Not Approved text /
  // Edit button / nothing). DetailsFormate's outer Column has no bounded
  // height and no flex children for spaceBetween to distribute, so it just
  // sums up every child's natural height — including this last row. Before
  // this fix, that row rendered at 3 different heights depending on state
  // (28 for the "Not Approved" text, 0 for Offstage(), and BorderIconButton's
  // own intrinsic height for Edit), which made cards in the same Wrap end up
  // with mismatched total heights. Pinning it to one constant height fixes
  // that regardless of which state is showing.
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

  // FIX (root cause of the "country" bug): truncation on screen is driven
  // by the ACTUAL RENDERED WIDTH of the value column (via
  // TextOverflow.ellipsis), not by word count. "United States Of America"
  // is only 4 words but still doesn't fit — so a word-count check will
  // never catch cases like this. This replaces both the old _valueText
  // and _hoverValue with one widget that measures the text against the
  // real available width using TextPainter, and only wires up the hover
  // overlay (MouseRegion + CompositedTransformTarget) when the text
  // actually overflows and gets clipped with "...". If it fits, it's
  // rendered as plain text with zero hover overhead.
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
    final employeementProviderState =
    Provider.of<HrManageProvider>(context, listen: false);

    return Container(
      // Was a hard-capped width: 1190, which pinned the card grid to the
      // same two columns however wide the panel got — and to one column
      // once a card's minimum width rose. Full width now; the grid decides
      // the column count.
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ///add button
              !_showAddButton
                  || widget.employeeStatus == "Terminated"
                  || widget.employeeStatus == "Inactive" ? const Offstage() :  AddNewOutlinedButton(
                  onPressed: () {
                    positionTitleController.clear();
                    leavingResonController.clear();
                    startDateContoller.clear();
                    endDateController.clear();
                    lastSupervisorNameController.clear();
                    supervisorMobileNumber.clear();
                    cityNameController.clear();
                    employeerController.clear();
                    emergencyMobileNumber.clear();
                    countryController.clear();
                    // Reset the "Currently work here" flag every time the
                    // Add popup is freshly opened.
                    isSelectedADD = false;
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AddEmployeementPopup(
                          positionTitleController: positionTitleController,
                          leavingResonController: leavingResonController,
                          startDateContoller: startDateContoller,
                          endDateController: endDateController,
                          lastSupervisorNameController:
                          lastSupervisorNameController,
                          supervisorMobileNumber: supervisorMobileNumber,
                          cityNameController: cityNameController,
                          employeerController: employeerController,
                          emergencyMobileNumber: emergencyMobileNumber,
                          countryController: countryController,
                          // ✅ Popup builds + owns the checkbox itself now.
                          // These two just read/write our plain bool field
                          // — no separate StatefulBuilder needed here
                          // anymore, since the popup rebuilds itself.
                          isCurrentlyWorking: () => isSelectedADD,
                          onCurrentlyWorkingChanged: (value) {
                            isSelectedADD = value;
                          },
                          onpressedSave: () async {
                            var response = await addEmployeement(
                                context,
                                widget.employeeId,
                                employeerController.text,
                                cityNameController.text,
                                leavingResonController.text,
                                lastSupervisorNameController.text,
                                supervisorMobileNumber.text,
                                positionTitleController.text,
                                startDateContoller.text,
                                isSelectedADD
                                    ? "Currently Working"
                                    : endDateController.text,
                                emergencyMobileNumber.text,
                                countryController.text);

                            var approveResponse =
                            await approveOnboardQualifyEmploymentPatch(
                                context, response.employeementId!);
                            if (approveResponse.statusCode == 200 ||
                                approveResponse.statusCode == 201) {
                              Navigator.pop(context);
                              await _loadEmployeement();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const AddSuccessPopup(
                                    message:
                                    'Employement Added Successfully',
                                  );
                                },
                              );
                            } else if (response.statusCode == 400 ||
                                response.statusCode == 404) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                const FourNotFourPopup(),
                              );
                            } else {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    FailedPopup(text: response.message),
                              );
                            }
                          },
                          tite: 'Add Employment',
                          onpressedClose: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }),
              const SizedBox(width: 15),
            ],
          ),
          // Breathing room between the toolbar row and the first card.
          const SizedBox(height: 18),
          StreamBuilder<List<EmployeementData>>(
              stream: employeementStreamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
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
                          AppStringHRNoData.employeeNoData,
                          style: AllNoDataAvailable.customTextStyle(context),
                        ),
                      ));
                }
                return WrapWidgetM(
                    children: List.generate(snapshot.data!.length, (index) {
                      var fileUrl = snapshot.data![index].documentUrl;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        employeementProviderState
                            .trimEmpAddress(snapshot.data![index].reason);
                        employeementProviderState
                            .trimSupervisor(snapshot.data![index].supervisor);
                      });

                      return CardDetails(
                          childWidget: DetailsFormate(
                            titleTrailing: snapshot.data![index].approved == null
                                ? const CardStatusChip(label: 'Not Approved')
                                : fileUrl == "--"
                                    ? const SizedBox(height: _buttonRowHeight)
                                    : OutlinedActionButton(
                              trailingIcon: Icons.remove_red_eye_outlined,
                              label: 'View',
                              width: _actionButtonWidth,
                              height: _buttonRowHeight,
                              fontSize: _actionButtonFontSize,
                              onPressed: () {
                                downloadFile(context: context,
                                    fileUrl: fileUrl,
                                    documentName:snapshot.data![index].title,
                                    apiPath: DownloadDocumentRepository.getEmployeeEmploymentHistoriesDocumentByFileName());
                              },
                            ),
                            row1Child1: [
                              const SizedBox(height: 5),
                              _labelText(context, 'Final Position Title'),
                              _labelText(context, 'Start Date'),
                              _labelText(context, 'End Date'),
                              _labelText(context, 'Employer'),
                              _labelText(context, 'Emergency Contact'),
                            ],
                            row1Child2: [
                              const SizedBox(height: 5),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].title,
                                link: _linkFor(index, 'title'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].dateOfJoining,
                                link: _linkFor(index, 'dateOfJoining'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].endDate,
                                link: _linkFor(index, 'endDate'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].employer,
                                link: _linkFor(index, 'employer'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].emgMobile,
                                link: _linkFor(index, 'emgMobile'),
                                provider: employeementProviderState,
                              ),
                            ],
                            row2Child1: [
                              const SizedBox(height: 5),
                              _labelText(context, 'Reason of Leaving'),
                              _labelText(context, 'Last Supervisor\'s Name'),
                              _labelText(context, 'Supervisor\'s Phone No.'),
                              _labelText(context, 'City'),
                              _labelText(context, 'Country'),
                            ],
                            row2Child2: [
                              const SizedBox(height: 5),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].reason,
                                link: _linkFor(index, 'reason'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].supervisor,
                                link: _linkFor(index, 'supervisor'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].supMobile,
                                link: _linkFor(index, 'supMobile'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].city,
                                link: _linkFor(index, 'city'),
                                provider: employeementProviderState,
                              ),
                              _adaptiveValue(
                                context,
                                fullText: snapshot.data![index].country,
                                link: _linkFor(index, 'country'),
                                provider: employeementProviderState,
                              ),
                            ],
                            // FIX: whole trailing state (Not Approved text /
                            // Edit button / nothing for terminated-inactive)
                            // now wrapped in one SizedBox(height:
                            // _buttonRowHeight) so every card in the Wrap
                            // ends up the same total height regardless of
                            // which of the 3 states is showing.
                            // The trailing row only reserves its fixed
                            // height when it actually holds an Edit button.
                            // Reserving it unconditionally left ~28px of
                            // dead space under the last field on every card
                            // that has no button to show.
                            button: snapshot.data![index].approved == null ||
                                    widget.employeeStatus == "Terminated" ||
                                    widget.employeeStatus == "Inactive"
                                ? const SizedBox.shrink()
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: _buttonRowHeight,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedActionButton(
                                      icon: Icons.edit_outlined,
                                      label: 'Edit',
                                      width: _actionButtonWidth,
                                      height: _buttonRowHeight,
                                      fontSize: _actionButtonFontSize,
                                      onPressed: () {
                                        // Seed isSelectedEdit from the actual
                                        // record BEFORE the popup opens, so
                                        // isCurrentlyWorking() reflects
                                        // reality on the first frame.
                                        isSelectedEdit = snapshot.data![index]
                                            .endDate ==
                                            "Currently Working";
                                        // FIX: compute the future once per press instead of
                                        // inline inside the dialog's builder, which re-fires
                                        // the API call on every rebuild of the dialog.
                                        final Future<EmployeementPrefillData>
                                        employmentPrefillFuture =
                                        getPrefillEmployeement(
                                            context,
                                            snapshot.data![index]
                                                .employmentId);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return FutureBuilder
                                              <EmployeementPrefillData>(
                                                  future: employmentPrefillFuture,
                                                  builder:
                                                      (context, snapshotPrefill) {
                                                    if (snapshotPrefill
                                                        .connectionState ==
                                                        ConnectionState.waiting) {
                                                      return Center(
                                                        child:
                                                        CircularProgressIndicator(
                                                          color: ColorManager
                                                              .blueprime,
                                                        ),
                                                      );
                                                    }

                                                    var positionTitle =
                                                        snapshotPrefill
                                                            .data!.title;
                                                    positionTitleController.text =
                                                        snapshotPrefill
                                                            .data!.title;

                                                    var leavingReason =
                                                        snapshotPrefill
                                                            .data!.reason;
                                                    leavingResonController.text =
                                                        snapshotPrefill
                                                            .data!.reason;

                                                    var startDate = snapshotPrefill
                                                        .data!.dateOfJoining;
                                                    startDateContoller.text =
                                                        snapshotPrefill.data
                                                            ?.dateOfJoining ??
                                                            '';

                                                    var endDate = snapshotPrefill
                                                        .data!.endDate;
                                                    endDateController.text =
                                                        snapshotPrefill
                                                            .data?.endDate ??
                                                            '';

                                                    if (endDateController.text ==
                                                        "Currently Working") {
                                                      isSelectedEdit = true;
                                                    } else if (endDateController
                                                        .text ==
                                                        "2024/12/24") {
                                                      isSelectedEdit = false;
                                                    }

                                                    var supervisorName =
                                                        snapshotPrefill
                                                            .data!.supervisor;
                                                    lastSupervisorNameController
                                                        .text =
                                                        snapshotPrefill
                                                            .data!.supervisor;

                                                    var supervisorMob =
                                                        snapshotPrefill
                                                            .data!.supMobile;
                                                    supervisorMobileNumber.text =
                                                        snapshotPrefill
                                                            .data!.supMobile;

                                                    var cityName =
                                                        snapshotPrefill.data!.city;
                                                    cityNameController.text =
                                                        snapshotPrefill.data!.city;

                                                    var employeer = snapshotPrefill
                                                        .data!.employer;
                                                    employeerController.text =
                                                        snapshotPrefill
                                                            .data!.employer;

                                                    var emgMobile = snapshotPrefill
                                                        .data!.emgMobile;
                                                    emergencyMobileNumber.text =
                                                        snapshotPrefill
                                                            .data!.emgMobile;

                                                    var country = snapshotPrefill
                                                        .data!.country;
                                                    countryController.text =
                                                        snapshotPrefill
                                                            .data!.country;

                                                    return AddEmployeementPopup(
                                                      positionTitleController:
                                                      positionTitleController,
                                                      leavingResonController:
                                                      leavingResonController,
                                                      startDateContoller:
                                                      startDateContoller,
                                                      endDateController:
                                                      endDateController,
                                                      lastSupervisorNameController:
                                                      lastSupervisorNameController,
                                                      supervisorMobileNumber:
                                                      supervisorMobileNumber,
                                                      cityNameController:
                                                      cityNameController,
                                                      employeerController:
                                                      employeerController,
                                                      emergencyMobileNumber:
                                                      emergencyMobileNumber,
                                                      countryController:
                                                      countryController,
                                                      // ✅ Same pattern for
                                                      // the Edit popup.
                                                      isCurrentlyWorking: () =>
                                                      isSelectedEdit,
                                                      onCurrentlyWorkingChanged:
                                                          (value) {
                                                        isSelectedEdit = value;
                                                      },
                                                      onpressedSave: () async {
                                                        var response =
                                                        await updateEmployeementPatch(
                                                          context,
                                                          snapshot.data![index]
                                                              .employmentId,
                                                          widget.employeeId,
                                                          employeer ==
                                                              employeerController
                                                                  .text
                                                              ? employeer
                                                              .toString()
                                                              : employeerController
                                                              .text,
                                                          cityName ==
                                                              cityNameController
                                                                  .text
                                                              ? cityName.toString()
                                                              : cityNameController
                                                              .text,
                                                          leavingReason ==
                                                              leavingResonController
                                                                  .text
                                                              ? leavingReason
                                                              .toString()
                                                              : leavingResonController
                                                              .text,
                                                          supervisorName ==
                                                              lastSupervisorNameController
                                                                  .text
                                                              ? supervisorName
                                                              .toString()
                                                              : lastSupervisorNameController
                                                              .text,
                                                          supervisorMob ==
                                                              supervisorMobileNumber
                                                                  .text
                                                              ? supervisorMob
                                                              .toString()
                                                              : supervisorMobileNumber
                                                              .text,
                                                          positionTitle ==
                                                              positionTitleController
                                                                  .text
                                                              ? positionTitle
                                                              .toString()
                                                              : positionTitleController
                                                              .text,
                                                          startDate ==
                                                              startDateContoller
                                                                  .text
                                                              ? startDate
                                                              : startDateContoller
                                                              .text,
                                                          isSelectedEdit
                                                              ? "Currently Working"
                                                              : endDateController
                                                              .text,
                                                          emgMobile ==
                                                              emergencyMobileNumber
                                                                  .text
                                                              ? emgMobile
                                                              : emergencyMobileNumber
                                                              .text,
                                                          country ==
                                                              countryController
                                                                  .text
                                                              ? country.toString()
                                                              : countryController
                                                              .text,
                                                        );
                                                        if (response.statusCode ==
                                                            200 ||
                                                            response.statusCode ==
                                                                201) {
                                                          Navigator.pop(context);
                                                          await _loadEmployeement();
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                            context) {
                                                              return const AddSuccessPopup(
                                                                message:
                                                                'Employement Edited Successfully',
                                                              );
                                                            },
                                                          );
                                                        } else if (response
                                                            .statusCode ==
                                                            400 ||
                                                            response.statusCode ==
                                                                404) {
                                                          Navigator.pop(context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                            context) =>
                                                            const FourNotFourPopup(),
                                                          );
                                                        } else {
                                                          Navigator.pop(context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                            context) =>
                                                                FailedPopup(
                                                                    text: response
                                                                        .message),
                                                          );
                                                        }
                                                      },
                                                      tite: 'Edit Employment',
                                                      onpressedClose: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  });
                                            });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: 'Employment #${index + 1}',
                          ));
                    }));
              }),
        ],
      ),
    );
  }
}
