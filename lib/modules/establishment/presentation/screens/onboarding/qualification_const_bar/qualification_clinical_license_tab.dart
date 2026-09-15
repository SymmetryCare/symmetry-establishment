import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/app/resources/theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/clinical_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/clinical_license_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/qualification_tab_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/qualification_const_bar/widgets/reject_popup_constant.dart';

import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';

class QualificationGeneralLicenses extends StatefulWidget {
  final int employeeId;
  const QualificationGeneralLicenses({super.key, required this.employeeId});

  @override
  State<QualificationGeneralLicenses> createState() =>
      _QualificationGeneralLicensesState();
}

class _QualificationGeneralLicensesState
    extends State<QualificationGeneralLicenses> {
  // ── Cached futures — prevent refetch/rebuild loop on every build ──
  late Future<List<ClinicalLicenseDataModel>> _drivingLicenseFuture;
  late Future<List<PractitionerLicenseDataModel>> _practitionerLicenseFuture;

  @override
  void initState() {
    super.initState();
    _drivingLicenseFuture =
        getDrivingLicenseRecord(context, widget.employeeId, "no");
    _practitionerLicenseFuture =
        getPractitionerLicenseRecord(context, widget.employeeId, "no");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1180,
      alignment: Alignment.center,
      child: Column(
        children: [
          // ── Driving License card ──────────────────────────────────
          Material(
            color: ColorManager.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: AppSize.s88,
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<ClinicalLicenseDataModel>>(
                      future: _drivingLicenseFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                      color:
                                      ColorManager.blueprime)));
                        }
                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                                  AppString.noDrivingLicense,
                                  style: AllNoDataAvailable
                                      .customTextStyle(context)));
                        }
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p5),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        downloadFile(context: context,
                                            fileUrl: snapshot.data![0].url,
                                            documentName:snapshot.data![0].fileName,
                                            apiPath: DownloadDocumentRepository.getDrivingLicenseDocumentByFileName());
                                      },
                                      child: Container(
                                          width: 62,
                                          height: 45,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                              AppPadding.p10,
                                              vertical: AppPadding.p8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                4),
                                            border: Border.all(
                                                width: 2,
                                                color: ColorManager
                                                    .faintGrey),
                                          ),
                                          child: SvgPicture.asset(
                                              'images/doc_vector.svg')),
                                    ),
                                    const SizedBox(width: AppSize.s30),
                                    Text(
                                      "Driving License",
                                      style: AknowledgementStyleNormal
                                          .customTextStyle(context),
                                    ),
                                  ],
                                ),
                                const Text("     "),
                                Row(
                                  children: [
                                    Text('Expiry Date',
                                        style:
                                        AknowledgementStyleNormal
                                            .customTextStyle(
                                            context)),
                                    const SizedBox(width: AppSize.s20),
                                    Text(snapshot.data![0].expDate,
                                        style:
                                        AknowledgementStyleConst
                                            .customTextStyle(
                                            context)),
                                  ],
                                ),
                                const Text("     "),
                                Row(
                                  children: [
                                    QualificationActionButtons(
                                      approve:
                                      snapshot.data![0].approve,
                                      onRejectPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return RejectDialog(
                                              onYesPressed: () async {
                                                await singleDrivingLicenseRejectPatch(
                                                    context,
                                                    snapshot.data![0]
                                                        .drivingLicenseId);
                                                setState(() {
                                                  _drivingLicenseFuture =
                                                      getDrivingLicenseRecord(
                                                      context,
                                                      widget
                                                          .employeeId,
                                                      "no");
                                                });
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      onApprovePressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return ApproveDialog(
                                              onYesPressed: () async {
                                                await singleDrivingLicenseApprovePatch(
                                                    context,
                                                    snapshot.data![0]
                                                        .drivingLicenseId);
                                                setState(() {
                                                  _drivingLicenseFuture =
                                                      getDrivingLicenseRecord(
                                                      context,
                                                      widget
                                                          .employeeId,
                                                      "no");
                                                });
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      isBackColor: false,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          return const Offstage();
                        }
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSize.s10),

          // ── Practitioner License card ─────────────────────────────
          Material(
            color: ColorManager.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: AppSize.s88,
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: _practitionerLicenseFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                      color:
                                      ColorManager.blueprime)));
                        }
                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                                  AppString.noPractitionerLicense,
                                  style: AllNoDataAvailable
                                      .customTextStyle(context)));
                        }
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p5),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap:(){
                                        downloadFile(context: context,
                                            fileUrl: snapshot.data![0].url,
                                            documentName:snapshot.data![0].fileName,
                                            apiPath: DownloadDocumentRepository.getPractitionerLicenseDocumentByFileName());
                                      },
                                      child: Container(
                                          width: 62,
                                          height: 45,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                              AppPadding.p10,
                                              vertical: AppPadding.p8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                4),
                                            border: Border.all(
                                                width: 2,
                                                color: ColorManager
                                                    .faintGrey),
                                          ),
                                          child: SvgPicture.asset(
                                              'images/doc_vector.svg')),
                                    ),
                                    const SizedBox(width: AppSize.s30),
                                    Text(
                                      "Practitioner License",
                                      style: AknowledgementStyleNormal
                                          .customTextStyle(context),
                                    ),
                                  ],
                                ),
                                const Text(""),
                                Row(
                                  children: [
                                    Text('Expiry Date',
                                        style:
                                        AknowledgementStyleNormal
                                            .customTextStyle(
                                            context)),
                                    const SizedBox(width: AppSize.s20),
                                    Text(snapshot.data![0].expDate,
                                        style:
                                        AknowledgementStyleConst
                                            .customTextStyle(
                                            context)),
                                  ],
                                ),
                                const Text("     "),
                                Row(
                                  children: [
                                    QualificationActionButtons(
                                      approve:
                                      snapshot.data![0].approve,
                                      onRejectPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return RejectDialog(
                                              onYesPressed: () async {
                                                await singlePractitionerLicenseRejectPatch(
                                                    context,
                                                    snapshot.data![0]
                                                        .practitionerLicenceId);
                                                setState(() {
                                                  _practitionerLicenseFuture =
                                                      getPractitionerLicenseRecord(
                                                      context,
                                                      widget
                                                          .employeeId,
                                                      "no");
                                                });
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      onApprovePressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return ApproveDialog(
                                              onYesPressed: () async {
                                                await singlePractitionerLicenseApprovePatch(
                                                    context,
                                                    snapshot.data![0]
                                                        .practitionerLicenceId);
                                                setState(() {
                                                  _practitionerLicenseFuture =
                                                      getPractitionerLicenseRecord(
                                                      context,
                                                      widget
                                                          .employeeId,
                                                      "no");
                                                });
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                            );
                                          },
                                        );
                                      },
                                       isBackColor: false,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          return const Offstage();
                        }
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}