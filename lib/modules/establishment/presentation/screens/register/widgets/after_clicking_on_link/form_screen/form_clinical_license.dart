import 'dart:async';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/clinical_licenses_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_health_record_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_health_record_data.dart';
// NOTE: adjust this import to wherever ClinicalLicenseDataModel / PractitionerLicenseDataModel actually live in your project.
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/taxtfield_constant.dart';

class Clinical_licenses extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;
  const Clinical_licenses(
      {super.key,
        required this.employeeID,
        required this.onSave,
        required this.onBack,
        required this.onNext,
        required this.context});

  final BuildContext context;
  @override
  State<Clinical_licenses> createState() => _Clinical_licensesState();
}

class _Clinical_licensesState extends State<Clinical_licenses> {
  final StreamController<List<HREmployeeDocumentModal>> healthrecord =
  StreamController<List<HREmployeeDocumentModal>>();

  bool _loading = false;
  bool isLoading = false;
  Uint8List? finalPathDl;
  String? fileNameDl;

  //
  Uint8List? finalPathPl;
  String? fileNamePl;
  bool dLFileAbove20Mb = false;
  bool pLFileAbove20Mb = false;

  // ---- Driving license prefill state ----
  // Populated from getDrivingLicenseRecord. If a record already exists for
  // this employee, we prefill the name/expiry/approval and only hit the
  // create+upload endpoints again if the user picks a brand new file.
  int? _existingDrivingLicenseId;
  String? _existingDrivingLicenseUrl;
  bool? _drivingLicenseApproved;
  // Canonical flag: true only when the fetched record genuinely has a usable
  // file name. Drives the "Replace File" vs "Choose File" label directly,
  // instead of re-deriving it from fileNameDl (which could be set for other
  // reasons and doesn't by itself confirm a real prior submission).
  bool _drivingLicensePrefilled = false;

  // ---- Practitioner license prefill state ----
  // Same pattern as the driving license, populated from
  // getPractitionerLicenseRecord.
  int? _existingPractitionerLicenseId;
  String? _existingPractitionerLicenseUrl;
  bool? _practitionerLicenseApproved;
  bool _practitionerLicensePrefilled = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  /// True only for real, usable values — filters out the placeholder strings
  /// ('null', '--', '') the backend sends when a field genuinely has no data.
  bool _isUsableString(String? value) {
    return value != null && value.isNotEmpty && value != 'null' && value != '--';
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchDrivingLicenseRecord(),
      _fetchPractitionerLicenseRecord(),
    ]);
  }

  Future<void> _fetchDrivingLicenseRecord() async {
    try {
      final records = await getDrivingLicenseRecord(
        context,
        widget.employeeID,
        'false', // approveOnly: pass 'true' if only approved records should prefill
      );

      if (records.isEmpty || !mounted) return;

      // Assuming the most recent driving license record is first in the list.
      final record = records.first;
      final resolvedName = _isUsableString(record.fileName) ? record.fileName : null;

      // Only treat this as a genuine prefill if there's an actual usable
      // file name — otherwise leave everything untouched so the card renders
      // exactly like an unfilled one.
      if (resolvedName == null) return;

      setState(() {
        _existingDrivingLicenseId = record.drivingLicenseId;
        _existingDrivingLicenseUrl = _isUsableString(record.url) ? record.url : null;
        _drivingLicenseApproved = record.approve;

        fileNameDl = resolvedName;
        if (record.expDate != null && record.expDate!.isNotEmpty) {
          expirydatecontrollerdl.text = record.expDate!;
        }

        // A prefilled record is already "on file" — don't block save on size.
        dLFileAbove20Mb = false;
        _drivingLicensePrefilled = true;
      });
    } catch (e) {
      print("Error fetching driving license record: $e");
    }
  }

  Future<void> _fetchPractitionerLicenseRecord() async {
    try {
      final records = await getPractitionerLicenseRecord(
        context,
        widget.employeeID,
        'false', // approveOnly: pass 'true' if only approved records should prefill
      );

      if (records.isEmpty || !mounted) return;

      // Assuming the most recent practitioner license record is first in the list.
      final record = records.first;
      final resolvedName = _isUsableString(record.fileName) ? record.fileName : null;

      // Only treat this as a genuine prefill if there's an actual usable
      // file name — otherwise leave everything untouched so the card renders
      // exactly like an unfilled one.
      if (resolvedName == null) return;

      setState(() {
        _existingPractitionerLicenseId = record.practitionerLicenceId;
        _existingPractitionerLicenseUrl = _isUsableString(record.url) ? record.url : null;
        _practitionerLicenseApproved = record.approve;

        fileNamePl = resolvedName;
        if (record.expDate != null && record.expDate!.isNotEmpty) {
          expirydatecontrollerpl.text = record.expDate!;
        }

        // A prefilled record is already "on file" — don't block save on size.
        pLFileAbove20Mb = false;
        _practitionerLicensePrefilled = true;
      });
    } catch (e) {
      print("Error fetching practitioner license record: $e");
    }
  }

  String _trimSummery(String address) {
    const int maxLength = 16;
    if (address.length > maxLength) {
      return '${address.substring(0, maxLength)}...';
    }
    return address;
  }
  String _trimPrefillSummery(String address) {
    const int maxLength = 36;
    if (address.length > maxLength) {
      return '${address.substring(0, maxLength)}...';
    }
    return address;
  }
  TextEditingController expirydatecontrollerdl = TextEditingController();
  TextEditingController expirydatecontrollerpl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 150),
          child: FormsBlueHeaderConst(
            text: 'Kindly upload the driving license and practitioner license compulsory.',
          ),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Padding(
          padding:  const EdgeInsets.symmetric(horizontal: AppPadding.p150),
          child: Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xffB1B1B1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Driving License',
                                  textAlign: TextAlign.start,
                                  style: HeadingFormStyle.customTextStyle(context),
                                ),
                                if (_drivingLicensePrefilled && _drivingLicenseApproved != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _drivingLicenseApproved == true
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _drivingLicenseApproved == true ? 'Approved' : 'Pending review',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _drivingLicenseApproved == true ? Colors.green[800] : Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'PDF format only.',
                              textAlign: TextAlign.end,
                              style: FileuploadString.customTextStyle(context),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFieldRegister(
                                  header: 'Expiry Date',
                                  readOnly: true,
                                  onTap: () async {
                                    // Once a genuine record is prefilled, the
                                    // expiry date came from that record — don't
                                    // let it be changed unless the user replaces
                                    // the file (which resets the prefill flag).
                                    if (_drivingLicensePrefilled) return;

                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      expirydatecontrollerdl.text =
                                      "${pickedDate.toLocal()}".split(' ')[0];
                                    }
                                  },
                                  width: 200,
                                  controller: expirydatecontrollerdl,
                                  hintText: 'yyyy-mm-dd',
                                  hintStyle: onlyFormDataStyle.customTextStyle(context),
                                  height: 30,
                                  suffixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: _drivingLicensePrefilled
                                        ? const Color(0xffB1B1B1)
                                        : const Color(0xff50B5E5),
                                    size: 22,
                                  ),
                                ),
                              ],),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload Document',
                                    style: AllPopupHeadings.customTextStyle(context),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xffB1B1B1)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                // Prefilled rows are view-only: no
                                                // upload/replace feature is offered
                                                // once a genuine driving license
                                                // record has already provided this
                                                // document.
                                                if (!_drivingLicensePrefilled)
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        FilePickerResult? result =
                                                        await FilePicker.platform.pickFiles(
                                                            type: FileType.custom,
                                                            allowedExtensions: ['pdf']);
                                                        final fileSize = result?.files.first.size;
                                                        if (fileSize != null) {
                                                          final isAbove20MB = fileSize >
                                                              (20 * 1024 * 1024); // Check if file is larger than 20MB

                                                          if (isAbove20MB) {
                                                            // If the file is larger than 20MB, show an error message
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return const AddErrorPopup(
                                                                  message: 'File is too large!',
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            // If the file is less than 20MB, proceed with the upload process
                                                            if (result != null) {
                                                              final file = result.files.first;
                                                              setState(() {
                                                                fileNameDl = file.name;
                                                                finalPathDl = file.bytes;
                                                                dLFileAbove20Mb =
                                                                false; // This flag indicates that the file is below 20MB
                                                                // A newly picked file replaces the prefilled record view.
                                                                _drivingLicensePrefilled = false;
                                                                _drivingLicenseApproved = null;
                                                                _existingDrivingLicenseUrl = null;
                                                              });
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: Text(
                                                        "Choose File",
                                                        style: DocumentTypeDataStyle.customTextStyle(context),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xffD9D9D9),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                // If a file is picked, display the file name, otherwise show 'No file selected'
                                                _loading
                                                    ? SizedBox(
                                                  width: 25,
                                                  height: 25,
                                                  child: CircularProgressIndicator(
                                                    color: ColorManager.blueprime,
                                                  ),
                                                )
                                                    : (fileNameDl != null && fileNameDl!.isNotEmpty)
                                                    ? Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (finalPathDl != null) {
                                                        // Newly picked file: open from in-memory bytes.
                                                        final blob = html.Blob(
                                                            [finalPathDl!],
                                                            'application/pdf');
                                                        final url = html.Url
                                                            .createObjectUrlFromBlob(
                                                            blob);
                                                        html.window.open(url, '_blank');
                                                      } else if (_existingDrivingLicenseUrl != null) {
                                                        // Previously submitted (prefilled) file: download it.
                                                        await downloadFile(
                                                          context: context,
                                                          fileUrl: _existingDrivingLicenseUrl!,
                                                          documentName: fileNameDl!,
                                                          apiPath: DownloadDocumentRepository.getDrivingLicenseDocumentByFileName(),
                                                        );
                                                      }
                                                    },
                                                    child: !_drivingLicensePrefilled ? Text(
                                                      _trimSummery('$fileNameDl'),
                                                      style: onlyFormDataStyle.customTextStyle(context).copyWith(
                                                        decoration: TextDecoration.underline,
                                                        color: const Color(0xff50B5E5),
                                                      ),
                                                    ) : Text(
                                                      _trimPrefillSummery('$fileNameDl'),
                                                      style: onlyFormDataStyle.customTextStyle(context).copyWith(
                                                        decoration: TextDecoration.underline,
                                                        color: const Color(0xff50B5E5),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    'No file chosen',
                                                    style: AllPopupHeadings
                                                        .customTextStyle(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],),
                            )
                          ],),
                      ],
                    ),
                  ),
                  ///
                  /////////////////////////////////
                  const SizedBox(height: AppSizeConst.A20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xffB1B1B1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Practitioner License',
                                  textAlign: TextAlign.start,
                                  style: HeadingFormStyle.customTextStyle(context),
                                ),
                                if (_practitionerLicensePrefilled && _practitionerLicenseApproved != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _practitionerLicenseApproved == true
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _practitionerLicenseApproved == true ? 'Approved' : 'Pending review',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _practitionerLicenseApproved == true ? Colors.green[800] : Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'PDF format only.',
                              textAlign: TextAlign.end,
                              style: FileuploadString.customTextStyle(context),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextFieldRegister(
                                  header: 'Expiry Date',
                                  readOnly: true,
                                  onTap: () async {
                                    // Once a genuine record is prefilled, the
                                    // expiry date came from that record — don't
                                    // let it be changed unless the user replaces
                                    // the file (which resets the prefill flag).
                                    if (_practitionerLicensePrefilled) return;

                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null) {
                                      expirydatecontrollerpl.text =
                                      "${pickedDate.toLocal()}".split(' ')[0];
                                    }
                                  },
                                  width: 200,
                                  controller: expirydatecontrollerpl,
                                  hintText: 'yyyy-mm-dd',
                                  hintStyle: onlyFormDataStyle.customTextStyle(context),
                                  height: 30,
                                  suffixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: _practitionerLicensePrefilled
                                        ? const Color(0xffB1B1B1)
                                        : const Color(0xff50B5E5),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload Document',
                                    style: AllPopupHeadings.customTextStyle(context),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 250,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xffB1B1B1)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                // Prefilled rows are view-only: no
                                                // upload/replace feature is offered
                                                // once a genuine practitioner license
                                                // record has already provided this
                                                // document.
                                                if (!_practitionerLicensePrefilled)
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        FilePickerResult? result =
                                                        await FilePicker.platform.pickFiles(
                                                            type: FileType.custom,
                                                            allowedExtensions: ['pdf']);
                                                        final fileSize = result?.files.first.size;
                                                        if (fileSize != null) {
                                                          final isAbove20MB = fileSize > (20 * 1024 * 1024);
                                                          if (isAbove20MB) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return const AddErrorPopup(
                                                                  message: 'File is too large!',
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            if (result != null) {
                                                              final file = result.files.first;
                                                              setState(() {
                                                                fileNamePl = file.name;
                                                                finalPathPl = file.bytes;
                                                                pLFileAbove20Mb = false;
                                                                // A newly picked file replaces the prefilled record view.
                                                                _practitionerLicensePrefilled = false;
                                                                _practitionerLicenseApproved = null;
                                                                _existingPractitionerLicenseUrl = null;
                                                              });
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: Text(
                                                        "Choose File",
                                                        style: AllPopupHeadings.customTextStyle(context),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xffD9D9D9),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                _loading
                                                    ? SizedBox(
                                                  width: 25,
                                                  height: 25,
                                                  child: CircularProgressIndicator(
                                                    color: ColorManager.blueprime,
                                                  ),
                                                )
                                                    : (fileNamePl != null && fileNamePl!.isNotEmpty)
                                                    ? Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (finalPathPl != null) {
                                                        // Newly picked file: open from in-memory bytes.
                                                        final blob = html.Blob([finalPathPl!], 'application/pdf');
                                                        final url = html.Url.createObjectUrlFromBlob(blob);
                                                        html.window.open(url, '_blank');
                                                      } else if (_existingPractitionerLicenseUrl != null) {
                                                        // Previously submitted (prefilled) file: download it.
                                                        await downloadFile(
                                                          context: context,
                                                          fileUrl: _existingPractitionerLicenseUrl!,
                                                          documentName: fileNamePl!,
                                                          apiPath: DownloadDocumentRepository.getPractitionerLicenseDocumentByFileName(),
                                                        );
                                                      }
                                                    },
                                                    child: !_practitionerLicensePrefilled ? Text(
                                                      _trimSummery('$fileNamePl'),
                                                      style: onlyFormDataStyle.customTextStyle(context).copyWith(
                                                        decoration: TextDecoration.underline,
                                                        color: const Color(0xff50B5E5),
                                                      ),
                                                    ) : Text(
                                                      _trimPrefillSummery('$fileNamePl'),
                                                      style: onlyFormDataStyle.customTextStyle(context).copyWith(
                                                        decoration: TextDecoration.underline,
                                                        color: const Color(0xff50B5E5),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    'No file chosen',
                                                    style: AllPopupHeadings.customTextStyle(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
        const SizedBox(height: AppSizeConst.A20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormOutlineButtonConst(
              text: 'Previous',
              onPressed: () {
                widget.onBack();
              },
            ),
            const SizedBox(
              width: 30,
            ),
            FormSaveButtonConst(
              isLoading: isLoading,
              onPressed: () async {
                // Check if both documents are present (either newly picked
                // or already on file via prefill).
                if (fileNameDl == null || fileNameDl!.isEmpty || fileNamePl == null || fileNamePl!.isEmpty) {
                  // Show error message if any document is missing
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddFailePopup(
                        message: "Both Documents Are Required.",
                      );
                    },
                  );
                  return; // Exit early if validation fails
                }
                print("........${dLFileAbove20Mb}");
                print("........${pLFileAbove20Mb}");
                if (!dLFileAbove20Mb && !pLFileAbove20Mb){
                  setState(() {
                    isLoading = true; // Start loading
                  });

                  try {
                    // Driving License: only hit create+upload again if the
                    // user picked a brand new file in this session. If the
                    // driving license came from a prefilled record and
                    // wasn't replaced, there's nothing new to submit.
                    bool drivingLicenseOk = true;
                    if (finalPathDl != null) {
                      var response = await postDrivinglicenseData(
                        context,
                        expirydatecontrollerdl.text,
                        '',
                        widget.employeeID,
                        '',
                        fileNameDl!,
                      );

                      var uploadResponseDL = await uploadDocumentsDL(
                        context: context,
                        drivingLicenceId: response.drivingLicenceId!,
                        documentFile: finalPathDl!,
                        documentName: fileNameDl!,
                      );

                      drivingLicenseOk =
                          (response.statusCode == 200 || response.statusCode == 201) &&
                              (uploadResponseDL.statusCode == 200 || uploadResponseDL.statusCode == 201);
                    } else if (_existingDrivingLicenseId == null) {
                      // Shouldn't happen given the validation above, but
                      // guard against a missing new file with no prior record.
                      drivingLicenseOk = false;
                    }

                    // Practitioner License: same rule — only hit create+upload
                    // again if the user picked a brand new file in this session.
                    bool practitionerLicenseOk = true;
                    if (finalPathPl != null) {
                      var responsePL = await postpractitionerLicenseData(
                        context,
                        expirydatecontrollerpl.text,
                        '',
                        widget.employeeID,
                        '',
                        fileNamePl!,
                      );

                      var uploadResponsePL = await uploadDocumentsPL(
                        context: context,
                        practitionerLicenceId: responsePL.practitionerLicenceId!,
                        documentFile: finalPathPl!,
                        documentName: fileNamePl!,
                      );

                      practitionerLicenseOk =
                          (responsePL.statusCode == 200 || responsePL.statusCode == 201) &&
                              (uploadResponsePL.statusCode == 200 || uploadResponsePL.statusCode == 201);
                    } else if (_existingPractitionerLicenseId == null) {
                      // Shouldn't happen given the validation above, but
                      // guard against a missing new file with no prior record.
                      practitionerLicenseOk = false;
                    }

                    if (drivingLicenseOk && practitionerLicenseOk){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(
                            message: 'Clinical License Data Saved!',
                          );
                        },
                      );
                      // Show success popup
                      await widget.onSave();
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => const FailedPopup(text: "Something Went Wrong"),
                      );
                    }

                  } catch (e) {
                    // Show error popup if something goes wrong
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const FailedPopup(text: "Something Went Wrong"),
                    );
                  }

                  setState(() {
                    isLoading = false; // End loading
                  });

                }
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddErrorPopup(
                        message: 'File is too large!',
                      );
                    },
                  );
                }

              },
            ),
            const SizedBox(
              width: AppSize.s30,
            ),
            FormOutlineButtonConst(
              text: 'Next',
              onPressed: () {
                widget.onNext();
              },
            ),
          ],
        ),
      ],
    );
  }
}