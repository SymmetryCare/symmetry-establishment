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
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/compensation_add_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';
import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/app/services/base64/download_file_base64.dart';
import 'package:symmetry_establishment/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/error_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/document_row_card.dart';

class AdditionalVaccinationsChildBar extends StatefulWidget {
  final int employeeId;
  final String? fileUrl;
  final String? fileExtension;
  final String employeeStatus;
  const AdditionalVaccinationsChildBar(
      {super.key,
        required this.employeeId,
        this.fileUrl,
        this.fileExtension, required this.employeeStatus});

  @override
  State<AdditionalVaccinationsChildBar> createState() =>
      _AdditionalVaccinationsChildBarState();
}

class _AdditionalVaccinationsChildBarState
    extends State<AdditionalVaccinationsChildBar> {
  bool _isLoading = false;
  final StreamController<List<OnboardingAckHealthManageDocData>> _controller =
  StreamController<List<OnboardingAckHealthManageDocData>>();

  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
  }

  Future<void> _loadHealthRecords() async {
    // FrontendConfigStore.data is populated asynchronously at startup; the
    // `!` here threw "Unexpected null value" out of initState when this tab
    // mounted before that landed, taking the whole TabBarView down.
    final cfg = FrontendConfigStore.data?.config;
    if (cfg == null) {
      if (mounted && !_controller.isClosed) {
        _controller.add(const <OnboardingAckHealthManageDocData>[]);
      }
      return;
    }
    final data = await getAckDocManageHealthRecord(
        context, cfg.healthDocId, widget.employeeId, 'no');
    if (!mounted || _controller.isClosed) return;
    _controller.add(data);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  bool get _isReadOnly =>
      widget.employeeStatus == 'Terminated' ||
      widget.employeeStatus == 'Inactive';

  Future<void> _openDocument(OnboardingAckHealthManageDocData doc) async {
    await downloadFile(
      context: context,
      fileUrl: doc.DocumentUrl,
      documentName: doc.DocumentName,
      apiPath: DownloadDocumentRepository.getDocumentByFileName(),
    );
  }

  void _addDocument() {
    final cfg = FrontendConfigStore.data?.config;
    if (cfg == null) return;
    // Computed once per press instead of inline inside the dialog's
    // builder, which re-fires the API call on every rebuild of the dialog.
    final Future<List<EmployeeDocSetupModal>> docSetupDropDownFuture =
        getEmployeeDocSetupDropDown(context, cfg.healthDocId);
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<EmployeeDocSetupModal>>(
        future: docSetupDropDownFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return CustomDocumedAddPopup(
              title: 'Add Health Record',
              employeeId: widget.employeeId,
              dataList: snapshot.data!,
            );
          }
          return ErrorPopUp(
            title: "Received Error",
            text: snapshot.error.toString(),
          );
        },
      ),
    ).then((_) => _loadHealthRecords());
  }

  void _editDocument(OnboardingAckHealthManageDocData doc) {
    // Computed once per press instead of inline inside the dialog's
    // builder, which re-fires the API call on every rebuild.
    final Future<EmployeeDocumentPrefillData> docPrefillFuture =
        getPrefillEmployeeDocuments(
      context: context,
      empDocumentId: doc.employeeDocumentId,
    );
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<EmployeeDocumentPrefillData>(
        future: docPrefillFuture,
        builder: (context, snapshotPreFill) {
          if (snapshotPreFill.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotPreFill.hasData) {
            return CustomDocumedEditPopup(
              labelName: 'Edit Health Record',
              employeeId: widget.employeeId,
              docName: doc.DocumentName,
              docMetaDataId: doc.EmployeeDocumentTypeMetaDataId,
              docSetupId: doc.EmployeeDocumentTypeSetupId,
              empDocumentId: doc.employeeDocumentId,
              selectedExpiryType: doc.ReminderThreshold,
              expiryDate: snapshotPreFill.data!.expiry,
              url: doc.DocumentUrl,
              documentFileName: doc.documentFileName,
            );
          }
          // Report this prefill request's error, not the list stream's.
          return ErrorPopUp(
            title: "Received Error",
            text: snapshotPreFill.error.toString(),
          );
        },
      ),
    ).then((_) => _loadHealthRecords());
  }

  void _confirmDelete(OnboardingAckHealthManageDocData doc) {
    final BuildContext screenContext = context;
    bool dialogIsOpen = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Named to avoid shadowing the outer State's setState. This local
        // one only rebuilds the dialog while it is open; it must never be
        // called after Navigator.pop().
        builder: (context, setDialogState) => DeletePopup(
          loadingDuration: _isLoading,
          title: 'Delete Health',
          onCancel: () {
            dialogIsOpen = false;
            Navigator.pop(context);
          },
          onDelete: () async {
            // _isLoading lives on the outer State — that is what
            // DeletePopup's loadingDuration reads, and it stays alive
            // after the dialog closes.
            setState(() => _isLoading = true);
            if (dialogIsOpen) setDialogState(() {});
            try {
              final response = await deleteEmployeeDocuments(
                context: context,
                empDocumentId: doc.employeeDocumentId,
              );
              if (response.statusCode == 200 || response.statusCode == 201) {
                dialogIsOpen = false;
                Navigator.pop(context);
                await _loadHealthRecords();
                if (mounted) {
                  showDialog(
                    context: screenContext,
                    builder: (_) => const DeleteSuccessPopup(),
                  );
                }
              }
            } finally {
              // Always reset, so the next delete does not inherit a stuck
              // "true" and show a spinner forever.
              if (mounted) setState(() => _isLoading = false);
              if (dialogIsOpen) setDialogState(() {});
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // stretch, not the default centre: the list below fills the full width,
      // so a centred toolbar left the "+ Add New" button inset from the cards.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!_isReadOnly) AddNewOutlinedButton(onPressed: _addDocument),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: StreamBuilder<List<OnboardingAckHealthManageDocData>>(
            stream: _controller.stream,
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
                    padding: const EdgeInsets.symmetric(vertical: 120),
                    child: Text(
                      AppStringHRNoData.healthNoData,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  ),
                );
              }
              return ManageCardGridView(
                cardHeight: 97,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data![index];
                  return DocumentRowCard(
                    idLabel: 'ID: ${doc.idOfTheDocument}',
                    fileName: doc.documentFileName,
                    onTap: () => _openDocument(doc),
                    onEdit: _isReadOnly ? null : () => _editDocument(doc),
                    onPrint: () => _openDocument(doc),
                    onDownload: () => downloadDocument(
                      context: context,
                      fileUrl: doc.DocumentUrl,
                      documentName: doc.documentFileName,
                      apiPath:
                          DownloadDocumentRepository.getDocumentByFileName(),
                    ),
                    onDelete: _isReadOnly ? null : () => _confirmDelete(doc),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
