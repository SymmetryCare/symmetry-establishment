import 'dart:async';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_establishment/modules/establishment/providers/hr_register_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_ack_health_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/register/widgets/after_clicking_on_link/form_screen/widgetConst/new_widget_const/forms_blue_header_const.dart';
import 'dart:typed_data';

import 'package:symmetry_establishment/app/constants/app_config.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_establishment/modules/establishment/resources/hr_theme_manager.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/progress_form_manager/form_health_record_manager.dart';
// NOTE: adjust this import to wherever getAckHealthRecord / OnboardingAckHealthData actually live in your project.
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_ack_health_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/progress_form_data/form_health_record_data.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/success_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';

class AcknowledgementsScreen extends StatefulWidget {
  final int employeeID;
  final Function onSave;
  final Function onBack;
  final Function onNext;
  const AcknowledgementsScreen({
    super.key,
    required this.context,
    required this.employeeID, required this.onSave, required this.onBack, required this.onNext,
  });

  final BuildContext context;

  @override
  State<AcknowledgementsScreen> createState() => _AcknowledgementsScreenState();
}

class _AcknowledgementsScreenState extends State<AcknowledgementsScreen> {

  final StreamController<List<HREmployeeDocumentModal>> acknowledgements = StreamController<List<HREmployeeDocumentModal>>.broadcast();

  bool isLoading = false;

  bool fileAbove20Mb = false;

  // ---- Prefill / ack-record state ----
  // Keyed by EmployeeDocumentTypeSetupId so we can match an already-submitted
  // record to the right document row when the list renders.
  Map<int, OnboardingAckHealthData> _ackRecordMap = {};
  bool _ackRecordsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final docsFuture = getHREmployeeDoc(
        context,
        FrontendConfigStore.data!.config.acknowledgementDocId,
        1,
        999,
      );

      final ackFuture = getAckHealthRecord(
        context,
        FrontendConfigStore.data!.config.acknowledgementDocId,
        widget.employeeID,
        'no', // approveOnly: pass 'true' if only approved records should prefill
      );

      final results = await Future.wait([docsFuture, ackFuture]);
      final documents = results[0] as List<HREmployeeDocumentModal>;
      final ackRecords = results[1] as List<OnboardingAckHealthData>;

      _ackRecordMap = {
        for (final record in ackRecords)
          record.EmployeeDocumentTypeSetupId: record,
      };

      if (!mounted) return;
      setState(() {
        _ackRecordsLoaded = true;
      });

      acknowledgements.add(documents);
    } catch (error) {
      acknowledgements.addError(error);
    }
  }

  List<String> _fileNames = [];
  List<String> onCAll = [];
  List<String> hIPPA = [];
  List<String> rDparty = [];
  List<String> prop = [];
  List<String> rocp = [];
  List<String> soConduct = [];
  List<String> harassment = [];

  List<Uint8List?> soConductFiles = [];
  List<Uint8List?> harassmentFiles = [];
  List<Uint8List?> onCAllFiles = [];
  List<Uint8List?> hIPPAFiles = [];
  List<Uint8List?> rDpartyFiles = [];
  List<Uint8List?> propFiles = [];

  bool _loading = false;

  bool _documentUploaded = true;
  List<int> docSetupId = [];

  List<Uint8List?> finalPaths = [];

  // Tracks a previously-submitted document's URL per row (for viewing when
  // no new bytes have been picked in this session).
  List<String?> _existingDocumentUrls = [];
  // Tracks approval state of a prefilled row, purely for the badge.
  List<bool?> _isApproved = [];
  // Canonical flag: true only when an ack record genuinely matched this row.
  // Drives the "Replace file" vs "Upload file" label directly, instead of
  // inferring it from URL nullability (which could be wrong for empty/placeholder
  // URL strings).
  List<bool> _hasPrefillRecord = [];

  /// Ensures every per-row list is padded to `length`, preserving existing values.
  void _growListsTo(int length) {
    if (_fileNames.length < length) {
      _fileNames.addAll(List.generate(length - _fileNames.length, (_) => ''));
    }
    if (finalPaths.length < length) {
      finalPaths.addAll(List.generate(length - finalPaths.length, (_) => null));
    }
    if (_existingDocumentUrls.length < length) {
      _existingDocumentUrls.addAll(List.generate(length - _existingDocumentUrls.length, (_) => null));
    }
    if (_isApproved.length < length) {
      _isApproved.addAll(List.generate(length - _isApproved.length, (_) => null));
    }
    if (_hasPrefillRecord.length < length) {
      _hasPrefillRecord.addAll(List.generate(length - _hasPrefillRecord.length, (_) => false));
    }
  }

  /// True only for real, usable values — filters out the placeholder strings
  /// ('null', '--', '') the backend sends when a field genuinely has no data.
  bool _isUsableString(String? value) {
    return value != null && value.isNotEmpty && value != 'null' && value != '--';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 150),
      child: Column(
        children: [
          const FormsBlueHeaderConst(
            text: 'Please sign the list of documents required for the recruitment process.',
          ),
          const SizedBox(height: AppSizeConst.A20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ' List Of Documents',
                style: HeadingFormStyle.customTextStyle(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: StreamBuilder<List<HREmployeeDocumentModal>>(
                stream: acknowledgements.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<HREmployeeDocumentModal>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}!"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No documents found!"));
                  } else {
                    List<HREmployeeDocumentModal> documents = snapshot.data!;

                    _growListsTo(documents.length);
                    if (_fileNames.length == documents.length) {
                      final providerState = Provider.of<HrProgressMultiStape>(context, listen: false);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        providerState.isAckRecordChnaged();
                      });
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];

                        int setupId = document.employeeDocTypesetupId;
                        if (docSetupId.length <= index) {
                          docSetupId.add(setupId);
                        } else {
                          docSetupId[index] = setupId;
                        }

                        // ---- Prefill from ack health record, once per row ----
                        // Only prefill if the user hasn't already picked a
                        // new file in this session (finalPaths[index] == null)
                        // and we haven't already prefilled this row's name.
                        if (_ackRecordsLoaded &&
                            _ackRecordMap.containsKey(setupId) &&
                            finalPaths[index] == null &&
                            !_hasPrefillRecord[index] &&
                            _fileNames[index].isEmpty) {
                          final record = _ackRecordMap[setupId]!;
                          final resolvedName = _isUsableString(record.documentFileName)
                              ? record.documentFileName
                              : (_isUsableString(record.DocumentName) ? record.DocumentName : null);

                          // Only treat this as a genuine prefill if there's an
                          // actual usable name — otherwise leave the row empty
                          // so it renders exactly like an unfilled row.
                          if (resolvedName != null) {
                            _fileNames[index] = resolvedName;
                            _existingDocumentUrls[index] =
                            _isUsableString(record.DocumentUrl) ? record.DocumentUrl : null;
                            _isApproved[index] = record.approved == true;
                            _hasPrefillRecord[index] = true;
                          }
                        }

                        final fileName = _fileNames[index];
                        // Button label (and badge) are driven only by the
                        // canonical prefill flag — not by URL/name presence —
                        // so a row with no matching ack record always reads
                        // "Upload file", never "Replace file".
                        final hasExistingRecord = _hasPrefillRecord[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorManager.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              document.docName,
                                              style: HeadingFormStyle.customTextStyle(context),
                                            ),
                                            if (hasExistingRecord && _isApproved[index] != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _isApproved[index] == true
                                                      ? Colors.green.withOpacity(0.15)
                                                      : Colors.orange.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _isApproved[index] == true ? 'Approved' : 'Pending review',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _isApproved[index] == true ? Colors.green[800] : Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Flexible(
                                          child: Text(
                                            'Please review and sign this document.',
                                            style: FileuploadString.customTextStyle(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Prefilled rows are view-only: no upload/replace
                                      // feature is offered once a genuine ack record
                                      // has already provided this document.
                                      if (!hasExistingRecord)
                                        ElevatedButton(
                                          onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['pdf'],
                                            );

                                            if (result != null) {
                                              final fileSize = result.files.first.size;
                                              final isAbove20MB = fileSize > (20 * 1024 * 1024);

                                              if (isAbove20MB) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => const AddErrorPopup(message: 'File is too large!'),
                                                );
                                                return;
                                              }

                                              try {
                                                Uint8List? bytes = result.files.first.bytes;
                                                if (bytes != null) {
                                                  setState(() {
                                                    _fileNames[index] = result.files.first.name;
                                                    finalPaths[index] = bytes;
                                                    // A newly picked file replaces the prefilled record view.
                                                    _existingDocumentUrls[index] = null;
                                                    _isApproved[index] = null;
                                                    _hasPrefillRecord[index] = false;
                                                    fileAbove20Mb = true;
                                                  });
                                                }
                                              } catch (e) {
                                                print(e);
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xff50B5E5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: Text(
                                            "Upload file",
                                            style: BlueButtonTextConst.customTextStyle(context),
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
                                          : fileName.isNotEmpty
                                          ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('File picked: ', style: onlyFormDataStyle.customTextStyle(context)),
                                            InkWell(
                                              onTap: () async {
                                                final bytes = finalPaths[index];
                                                if (bytes != null) {
                                                  // Newly picked file: open from in-memory bytes.
                                                  final blob = html.Blob([bytes], 'application/pdf');
                                                  final url = html.Url.createObjectUrlFromBlob(blob);
                                                  html.window.open(url, '_blank');
                                                } else if (_existingDocumentUrls[index] != null) {
                                                  // Previously submitted (prefilled) file: download it.
                                                  await downloadFile(
                                                    context: context,
                                                    fileUrl: _existingDocumentUrls[index]!,
                                                    documentName: _fileNames[index],
                                                    apiPath: DownloadDocumentRepository.getDocumentByFileName(),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                fileName,
                                                style: onlyFormDataStyle.customTextStyle(context).copyWith(
                                                  decoration: TextDecoration.underline,
                                                  color: const Color(0xff50B5E5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
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
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    // A row counts as "provided" if it has a newly picked
                    // file OR an already-submitted record from ack data.
                    final hasAnyFile = finalPaths.any((f) => f != null) ||
                        _existingDocumentUrls.any((u) => u != null);

                    if (!hasAnyFile) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const VendorSelectNoti(
                            message: 'Please Select File',
                          );
                        },
                      );
                      return;
                    }

                    if (!fileAbove20Mb && finalPaths.any((f) => f != null)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddErrorPopup(
                            message: 'File is too large!',
                          );
                        },
                      );
                      return;
                    }

                    int maxConcurrentUploads = 2;
                    List<Future<void>> currentBatch = [];

                    for (int i = 0; i < finalPaths.length; i++) {
                      // Skip rows with no newly picked bytes — either empty
                      // or already satisfied by a prior submission.
                      if (finalPaths[i] == null) continue;

                      dynamic file = finalPaths[i];
                      Uint8List fileBytes;

                      if (file is Uint8List) {
                        fileBytes = file;
                      } else if (file is String) {
                        fileBytes = await File(file).readAsBytes();
                      } else {
                        continue;
                      }

                      currentBatch.add(() async {
                        final response = await uploadDocuments(
                          context: context,
                          employeeDocumentMetaId: FrontendConfigStore.data!.config.acknowledgementDocId,
                          employeeDocumentTypeSetupId: docSetupId[i],
                          employeeId: widget.employeeID,
                          documentFile: fileBytes,
                          documentName: _fileNames[i],
                        );

                        if (response.statusCode != 200 && response.statusCode != 201) {
                          await showDialog(
                            context: context,
                            builder: (_) => AddFailePopup(
                              message: 'Failed To Upload Document: ${_fileNames[i]}',
                            ),
                          );
                          throw Exception('Upload failed for ${_fileNames[i]}');
                        }
                      }());

                      if (currentBatch.length == maxConcurrentUploads) {
                        await Future.wait(currentBatch);
                        currentBatch.clear();
                      }
                    }

                    if (currentBatch.isNotEmpty) {
                      await Future.wait(currentBatch);
                    }

                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddSuccessPopup(
                          message: 'Document Uploaded Successfully.',
                        );
                      },
                    );

                    widget.onSave();

                  } catch (e) {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddFailePopup(
                          message: 'Failed To Upload Document',
                        );
                      },
                    );
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
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
          )
        ],
      ),
    );
  }
}