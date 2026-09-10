import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/establishment_manager/employee_doc_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/onboarding_manager/onboarding_ack_health_manager.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/employee_doc/employee_doc_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/employee_document_data.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/onboarding_data/onboarding_ack_health_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/acknowledgement_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/compensation_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/document_row_card.dart';
import 'dart:html' as html;

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/app/services/base64/download_file_base64.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/error_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';

///download

class HRDocAckStyle {
  static TextStyle customTextStyle(BuildContext context) {
    double fontSize = 10;
    return TextStyle(
      fontSize: fontSize,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
  }
}

class AcknowledgementsChildBar extends StatefulWidget {
  final int employeeId;
  final String? fileUrl;
  final String? fileExtension;
  final String employeeStatus;
  const AcknowledgementsChildBar(
      {super.key, required this.employeeId, this.fileUrl, this.fileExtension, required this.employeeStatus});

  @override
  State<AcknowledgementsChildBar> createState() =>
      _AcknowledgementsChildBarState();
}

class _AcknowledgementsChildBarState extends State<AcknowledgementsChildBar> {
  bool _isLoading = false;
  final StreamController<List<OnboardingAckHealthManageDocData>> _controller =
  StreamController<List<OnboardingAckHealthManageDocData>>();

  @override
  void initState() {
    super.initState();
    _loadAcknowledgements();
  }

  Future<void> _loadAcknowledgements() async {
    // FrontendConfigStore.data is populated asynchronously at startup; the
    // `!` here threw "Unexpected null value" when this tab opened first.
    final cfg = FrontendConfigStore.data?.config;
    if (cfg == null) {
      if (mounted && !_controller.isClosed) {
        _controller.add(const <OnboardingAckHealthManageDocData>[]);
      }
      return;
    }
    final data = await getAckDocManageHealthRecord(
        context, cfg.acknowledgementDocId, widget.employeeId, 'no');
    if (!mounted || _controller.isClosed) return;
    _controller.add(data);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  // NEW: replaces the old downloadFile(fileUrl)/PdfDownloadButton(apiUrl:...)
  // flow. Fetches the raw bytes via the new manager call and triggers a
  // browser download client-side using dart:html.



  Future<void> _openDocument(OnboardingAckHealthManageDocData ackData) async {
    await downloadFile(
        context: context,
        fileUrl: ackData.DocumentUrl,
        documentName: ackData.DocumentName,
        apiPath: DownloadDocumentRepository.getDocumentByFileName());
  }

  void _editDocument(OnboardingAckHealthManageDocData ackData) {
    // FIX: compute the future once per press instead of inline inside the
    // dialog's builder, which re-fires the API call on every rebuild.
    final Future<EmployeeDocumentPrefillData> docPrefillFuture =
        getPrefillEmployeeDocuments(
            context: context, empDocumentId: ackData.employeeDocumentId);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<EmployeeDocumentPrefillData>(
              future: docPrefillFuture,
              builder: (context, snapshotPreFill) {
                if (snapshotPreFill.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshotPreFill.hasData) {
                  return CustomDocumedEditPopup(
                    labelName: 'Edit Acknowledgement',
                    employeeId: widget.employeeId,
                    docName: ackData.DocumentName,
                    docMetaDataId: ackData.EmployeeDocumentTypeMetaDataId,
                    docSetupId: ackData.EmployeeDocumentTypeSetupId,
                    empDocumentId: ackData.employeeDocumentId,
                    selectedExpiryType: ackData.ReminderThreshold,
                    expiryDate: snapshotPreFill.data!.expiry,
                    url: ackData.DocumentUrl,
                    documentFileName: ackData.documentFileName,
                  );
                } else {
                  // FIX: was reporting the *list* stream's error here rather
                  // than this prefill request's.
                  return ErrorPopUp(
                      title: "Received Error",
                      text: snapshotPreFill.error.toString());
                }
              });
        }).then((_) => _loadAcknowledgements());
  }

  void _confirmDelete(OnboardingAckHealthManageDocData ackData) {

                                      final BuildContext screenContext = context;
                                      bool dialogIsOpen = true;
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              StatefulBuilder(
                                                // FIX: renamed to avoid shadowing the outer State's setState.
                                                // This local one only rebuilds the dialog while it's open;
                                                // it must never be called after Navigator.pop().
                                                builder: (BuildContext
                                                context,
                                                    void Function(
                                                        void
                                                        Function())
                                                    setDialogState) {
                                                  return DeletePopup(
                                                    loadingDuration:
                                                    _isLoading,
                                                    title:
                                                    'Delete Acknowledgement',
                                                    onCancel: () {
                                                      dialogIsOpen = false;
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    onDelete:
                                                        () async {
                                                      // FIX: update the outer widget's _isLoading via the
                                                      // outer State's own setState — this is what
                                                      // DeletePopup's loadingDuration actually reads, and
                                                      // this State stays alive after the dialog closes.
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      if (dialogIsOpen) {
                                                        setDialogState(() {});
                                                      }
                                                      try {
                                                        var response = await deleteEmployeeDocuments(
                                                            context:
                                                            context,
                                                            empDocumentId:
                                                            ackData.employeeDocumentId);
                                                        if (response.statusCode ==
                                                            200 ||
                                                            response.statusCode ==
                                                                201) {
                                                          dialogIsOpen = false;
                                                          Navigator.pop(
                                                              context);
                                                          await _loadAcknowledgements();
                                                          if (mounted) {
                                                            showDialog(
                                                              context:
                                                              screenContext,
                                                              builder: (BuildContext context) =>
                                                              const DeleteSuccessPopup(),
                                                            );
                                                          }
                                                        }
                                                      } finally {
                                                        // FIX: always reset _isLoading on the outer State
                                                        // (guarded only by `mounted`) so the NEXT delete
                                                        // attempt — on this row or any other — doesn't
                                                        // inherit a stuck "true" value and show a spinner
                                                        // forever instead of the delete button.
                                                        if (mounted) {
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                        }
                                                        // Only touch the dialog's own rebuild if it's still
                                                        // showing — calling this after pop() throws.
                                                        if (dialogIsOpen) {
                                                          setDialogState(() {});
                                                        }
                                                      }
                                                    },
                                                  );
                                                },
                                              ));
                                      }

  @override
  Widget build(BuildContext context) {
    return Column(
      // stretch, not the default centre: the list below fills the full width,
      // so a centred toolbar left the "+ Add New" button inset from the cards.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 7),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.employeeStatus == "Terminated"
                  || widget.employeeStatus == "Inactive" ? const Offstage() :AddNewOutlinedButton(
                  onPressed: () async {
                    // FIX: compute the future once per press instead of
                    // inline inside the dialog's builder, which re-fires
                    // the API call on every rebuild of the dialog.
                    final cfg = FrontendConfigStore.data?.config;
                    if (cfg == null) return;
                    final Future<List<EmployeeDocSetupModal>>
                    docSetupDropDownFuture = getEmployeeDocSetupDropDown(
                        context, cfg.acknowledgementDocId);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return FutureBuilder<List<EmployeeDocSetupModal>>(
                              future: docSetupDropDownFuture,
                              builder: (contex, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child:
                                      CircularProgressIndicator());
                                }
                                if (snapshot.hasData) {
                                  return AcknowledgementAddPopup(
                                    title: 'Add Acknowledgement',
                                    employeeId: widget.employeeId,
                                    dataList: snapshot.data!,
                                  );
                                } else {
                                  return ErrorPopUp(
                                      title: "Received Error",
                                      text:
                                      snapshot.error.toString());
                                }
                              });
                        }).then((_) => _loadAcknowledgements());
                  }) ,
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 100),
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                      ),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 120),
                      child: Text(
                        AppStringHRNoData.ackNoData,
                        style: AllNoDataAvailable.customTextStyle(
                            context),
                      ),
                    ),
                  );
                }
                return ManageCardGridView(
                  cardHeight: 97,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final ackData = snapshot.data![index];
                    final canEdit = widget.employeeStatus != "Terminated" &&
                        widget.employeeStatus != "Inactive";
                    return DocumentRowCard(
                      idLabel: 'ID: ${ackData.idOfTheDocument}',
                      fileName: ackData.documentFileName,
                      onTap: () => _openDocument(ackData),
                      onEdit: canEdit ? () => _editDocument(ackData) : null,
                      onPrint: () => _openDocument(ackData),
                      onDownload: () => downloadDocument(
                          context: context,
                          fileUrl: ackData.DocumentUrl,
                          documentName: ackData.documentFileName,
                          apiPath: DownloadDocumentRepository
                              .getDocumentByFileName()),
                      onDelete: canEdit ? () => _confirmDelete(ackData) : null,
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}

// Function to handle printing
void printFile(String url) {
  // Create an IFrameElement to load the PDF
  final iframe = html.IFrameElement()
    ..src = url
    ..style.border = 'none'
    ..style.width = '0'
    ..style.height = '0';

  // Append the iframe to the document body
  html.document.body!.append(iframe);

  // Listen for the load event
  iframe.onLoad.listen((_) {
    // After the PDF is loaded, trigger the print dialog
    html.window.print();

    // Remove the iframe from the document after printing
    iframe.remove();
  });
}