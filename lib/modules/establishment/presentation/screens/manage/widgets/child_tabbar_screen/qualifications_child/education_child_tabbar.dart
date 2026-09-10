import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/font_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/string_manager.dart';
import 'package:symmetry_establishment/modules/establishment/providers/navigation_provider.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/education_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/qualification_bar_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/education_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/radio_button_tile_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/const_wrap_widget.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/qualifications_child/widgets/add_education_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/const_card_details.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/row_container_widget_const.dart';

class EducationChildTabbar extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const EducationChildTabbar({super.key, required this.employeeId, required this.employeeStatus});

  @override
  State<EducationChildTabbar> createState() => _EducationChildTabbarState();
}

class _EducationChildTabbarState extends State<EducationChildTabbar> {
  // FIX: single shared LayerLinks (_layerLinkDegree/_layerLinkCollege) were being
  // reused across EVERY row inside List.generate. A LayerLink can only back ONE
  // CompositedTransformTarget at a time — reusing it across simultaneous rows
  // corrupted the layer tree and caused "Assertion failed: layer.dart:2461" to
  // fire repeatedly. Replaced with a Map so every row + field gets its own link.
  final Map<String, LayerLink> _layerLinks = {};

  LayerLink _linkFor(int index, String field) {
    final key = '$index-$field';
    return _layerLinks.putIfAbsent(key, () => LayerLink());
  }

  final StreamController<List<EducationData>> educationStreamController =
  StreamController<List<EducationData>>();
  final TextEditingController collegeUniversityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController calenderController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController majorSubjectController = TextEditingController();
  final TextEditingController countryNameController = TextEditingController();
  String? expiryType = "No";

  @override
  void initState() {
    super.initState();
    _loadEducation();
  }

  Future<void> _loadEducation() async {
    final data = await getEmployeeEducation(context, widget.employeeId);
    if (!mounted || educationStreamController.isClosed) return;
    educationStreamController.add(data);
  }

  @override
  void dispose() {
    educationStreamController.close();
    collegeUniversityController.dispose();
    phoneController.dispose();
    calenderController.dispose();
    cityController.dispose();
    degreeController.dispose();
    stateController.dispose();
    majorSubjectController.dispose();
    countryNameController.dispose();
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
  static const double _rowHeight = 34;

  // FIX: fixed height for the trailing "button" row (Not Approved text /
  // Edit button / nothing). DetailsFormate's outer Column has no bounded
  // height and no flex children for spaceBetween to distribute, so it just
  // sums up every child's natural height — including this last row. Before
  // this fix, that row rendered at 3 different heights depending on state
  // (AppSize.s28 for the "Not Approved" text, 0 for Offstage(), and
  // BorderIconButton's own intrinsic height for Edit), which made cards in
  // the same Wrap end up with mismatched total heights. Pinning it to one
  // constant height fixes that regardless of which state is showing.
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
  // columns have different widths (e.g. "Educational Institute :" leaves
  // less room than "Phone :"), so the same character count overflows in
  // one column but fits fine in another. This measures the actual text
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
    final providerState = Provider.of<HrManageProvider>(context, listen: false);

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
              widget.employeeStatus == "Terminated"
                  || widget.employeeStatus == "Inactive" ? const Offstage() :  AddNewOutlinedButton(
                  onPressed: () {
                    collegeUniversityController.clear();
                    phoneController.clear();
                    calenderController.clear();
                    cityController.clear();
                    degreeController.clear();
                    stateController.clear();
                    majorSubjectController.clear();
                    countryNameController.clear();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AddEducationPopup(
                            collegeUniversityController: collegeUniversityController,
                            phoneController: phoneController,
                            calenderController: calenderController,
                            cityController: cityController,
                            degreeController: degreeController,
                            stateController: stateController,
                            majorSubjectController: majorSubjectController,
                            countryNameController: countryNameController,
                            employeeId: widget.employeeId,
                            onpressedClose: () {},
                            title: 'Add Education',
                          );
                        }).then((_) => _loadEducation());
                  }),
              const SizedBox(width: 15),
            ],
          ),
          // Breathing room between the toolbar row and the first card.
          const SizedBox(height: 18),
          StreamBuilder<List<EducationData>>(
            stream: educationStreamController.stream,
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
                        AppStringHRNoData.educationNoData,
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    ));
              }
              return WrapWidgetM(
                  children:
                  List.generate(snapshot.data!.length, (index) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      providerState
                          .trimDegreeString(snapshot.data![index].degree);
                      providerState
                          .trimCollegeString(snapshot.data![index].college);
                      providerState
                          .trimMajorString(snapshot.data![index].major);
                    });

                    return CardDetails(
                        childWidget: DetailsFormate(
                          title: 'Education #${index + 1}',
                          // Matches the Employment card: approval state is a
                          // pill in the title row, not grey text at the foot
                          // of the card.
                          titleTrailing:
                              snapshot.data![index].approved == null
                                  ? const CardStatusChip(
                                      label: 'Not Approved')
                                  : null,
                          row1Child1: [
                            const SizedBox(height: 5),
                            _labelText(context, 'Degree :'),
                            _labelText(context, 'Graduate :'),
                            _labelText(context, 'Educational Institute :'),
                            _labelText(context, 'Major Subject :'),
                          ],
                          row1Child2: [
                            const SizedBox(height: 5),
                            _adaptiveValue(
                              context,
                              fullText: snapshot.data![index].degree,
                              link: _linkFor(index, 'degree'),
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
                              fullText: snapshot.data![index].college,
                              link: _linkFor(index, 'college'),
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
                            _labelText(context, 'Country :'),
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
                              fullText: snapshot.data![index].city,
                              link: _linkFor(index, 'city'),
                              provider: providerState,
                            ),
                            _adaptiveValue(
                              context,
                              fullText: snapshot.data![index].state,
                              link: _linkFor(index, 'state'),
                              provider: providerState,
                            ),
                            _adaptiveValue(
                              context,
                              fullText: snapshot.data![index].country,
                              link: _linkFor(index, 'country'),
                              provider: providerState,
                            ),
                          ],

                          // FIX: whole trailing state (Not Approved text /
                          // Edit button / nothing for terminated-inactive)
                          // now wrapped in one SizedBox(height:
                          // _buttonRowHeight) + Align so every card in the
                          // Wrap ends up the same total height regardless of
                          // which of the 3 states is showing.
                          // Collapses entirely when there is no Edit button
                          // to show, so no dead strip is left under the last
                          // field row (same as Employment).
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
                                          // FIX: compute the future once per press instead of
                                          // inline inside the dialog's builder, which re-fires
                                          // the API call on every rebuild of the dialog.
                                          final Future<EducationPrefillData>
                                          educationPrefillFuture =
                                          getPrefillEmployeeEducation(
                                              context,
                                              snapshot.data![index]
                                                  .educationId);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return FutureBuilder<EducationPrefillData>(
                                                    future:
                                                    educationPrefillFuture,
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
                                                      var college = snapshotPrefill
                                                          .data!.college;
                                                      collegeUniversityController.text =
                                                          snapshotPrefill.data!.college;

                                                      var phone = snapshotPrefill
                                                          .data!.phone;
                                                      phoneController.text =
                                                          snapshotPrefill.data!.phone;

                                                      var city =
                                                          snapshotPrefill.data!.city;
                                                      cityController.text =
                                                          snapshotPrefill.data!.city;

                                                      var degree = snapshotPrefill
                                                          .data!.degree;
                                                      degreeController.text =
                                                          snapshotPrefill.data!.degree;

                                                      var state = snapshotPrefill
                                                          .data!.state;
                                                      stateController.text =
                                                          snapshotPrefill.data!.state;

                                                      var majorSubject =
                                                          snapshotPrefill.data!.major;
                                                      majorSubjectController.text =
                                                          snapshotPrefill.data!.major;

                                                      var graduate = snapshotPrefill
                                                          .data!.graduate;
                                                      expiryType = snapshotPrefill
                                                          .data!.graduate
                                                          .toString();

                                                      var country = snapshotPrefill
                                                          .data!.country;
                                                      countryNameController.text =
                                                          snapshotPrefill.data!.country;

                                                      var startDate = snapshotPrefill
                                                          .data!.startDate;
                                                      calenderController.text =
                                                          snapshotPrefill.data!.startDate;

                                                      return StatefulBuilder(
                                                        builder: (BuildContext context,
                                                            void Function(
                                                                void Function())
                                                            setState) {
                                                          return EditEducationPopup(
                                                            collegeUniversityController:
                                                            collegeUniversityController,
                                                            phoneController:
                                                            phoneController,
                                                            calenderController:
                                                            calenderController,
                                                            cityController:
                                                            cityController,
                                                            degreeController:
                                                            degreeController,
                                                            stateController:
                                                            stateController,
                                                            majorSubjectController:
                                                            majorSubjectController,
                                                            countryNameController:
                                                            countryNameController,
                                                            onpressedClose: () {
                                                              Navigator.pop(context);
                                                            },
                                                            onpressedSave: () async {
                                                              var response =
                                                              await updateEmployeeEducation(
                                                                context,
                                                                snapshot.data![index]
                                                                    .educationId,
                                                                widget.employeeId,
                                                                graduate ==
                                                                    expiryType
                                                                        .toString()
                                                                    ? graduate
                                                                    .toString()
                                                                    : expiryType
                                                                    .toString(),
                                                                degree ==
                                                                    degreeController
                                                                        .text
                                                                    ? degree.toString()
                                                                    : degreeController
                                                                    .text,
                                                                majorSubject ==
                                                                    majorSubjectController
                                                                        .text
                                                                    ? majorSubject
                                                                    .toString()
                                                                    : majorSubjectController
                                                                    .text,
                                                                city ==
                                                                    cityController
                                                                        .text
                                                                    ? city.toString()
                                                                    : cityController
                                                                    .text,
                                                                college ==
                                                                    collegeUniversityController
                                                                        .text
                                                                    ? college.toString()
                                                                    : collegeUniversityController
                                                                    .text,
                                                                phone ==
                                                                    phoneController
                                                                        .text
                                                                    ? phone.toString()
                                                                    : phoneController
                                                                    .text,
                                                                state ==
                                                                    stateController
                                                                        .text
                                                                    ? state.toString()
                                                                    : stateController
                                                                    .text,
                                                                country ==
                                                                    countryNameController
                                                                        .text
                                                                    ? country.toString()
                                                                    : countryNameController
                                                                    .text,
                                                                startDate ==
                                                                    calenderController
                                                                        .text
                                                                    ? startDate
                                                                    : calenderController
                                                                    .text,
                                                              );
                                                              Navigator.pop(context);
                                                              if (response.statusCode ==
                                                                  200 ||
                                                                  response.statusCode ==
                                                                      201) {
                                                                await _loadEducation();
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext
                                                                  context) {
                                                                    return const AddSuccessPopup(
                                                                      message:
                                                                      'Education Edit Successfully',
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
                                                              expiryType = '';
                                                            },
                                                            radioButton: Container(
                                                              width: AppSize.s280,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                    CustomRadioListTile(
                                                                      value: "Yes",
                                                                      groupValue:
                                                                      expiryType
                                                                          .toString(),
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          expiryType =
                                                                          value!;
                                                                        });
                                                                      },
                                                                      title: "Yes",
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                    CustomRadioListTile(
                                                                      value: "No",
                                                                      groupValue:
                                                                      expiryType
                                                                          .toString(),
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(() {
                                                                          expiryType =
                                                                          value!;
                                                                        });
                                                                      },
                                                                      title: "No",
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            title: 'Edit Education',
                                                          );
                                                        },
                                                      );
                                                    });
                                              });
                                        })
                                ),
                              ),
                            ],
                          ),
                        ));
                  }));
            },
          ),
        ],
      ),
    );
  }
}