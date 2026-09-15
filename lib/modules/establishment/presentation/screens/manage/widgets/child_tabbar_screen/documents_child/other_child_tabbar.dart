import 'dart:async';

import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/app/resources/const_string.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/hr_module_manager/others_doc_manager.dart';
import 'package:symmetry_establishment/app/services/base64/download_file_base64.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/hr_module_data/manage/others_data.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/delete_popup_const.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/others_doc_addPopup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/onboarding/download_doc_const.dart';

import 'package:symmetry_establishment/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_establishment/modules/establishment/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_establishment/presentation/shared/widgets/error_popup.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/manage_card_grid.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/screens/manage/widgets/child_tabbar_screen/documents_child/widgets/document_row_card.dart';

class OtherChildTabbar extends StatefulWidget {
  final int employeeId;
  final String employeeStatus;
  const OtherChildTabbar({super.key, required this.employeeId, required this.employeeStatus});

  @override
  State<OtherChildTabbar> createState() => _OtherChildTabbarState();
}

class _OtherChildTabbarState extends State<OtherChildTabbar> {
  final StreamController<List<OthersDocModel>> _controller =
  StreamController<List<OthersDocModel>>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    getOthersData(
        context: context,
        employeeId: widget.employeeId)
        .then((data) {
      if (mounted) _controller.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  bool get _isReadOnly =>
      widget.employeeStatus == 'Terminated' ||
      widget.employeeStatus == 'Inactive';

  Future<void> _openDocument(OthersDocModel doc) async {
    await downloadFile(
      context: context,
      fileUrl: doc.url,
      documentName: doc.fileName,
      apiPath: DownloadDocumentRepository.getDocumentByFileName(),
    );
  }

  void _addDocument() {
    showDialog(
      context: context,
      builder: (context) => OthersDocAddpopup(
        title: 'Add Other Document',
        employeeId: widget.employeeId,
      ),
    ).then((_) => _loadData());
  }

  void _editDocument(OthersDocModel doc) {
    // Computed once per press instead of inline inside the dialog's
    // builder, which re-fires the API call on every rebuild.
    final Future<OthersDocPreFillModel> othersPrefillFuture =
        getOthersPrefillData(context: context, otherDocId: doc.otherDocId);
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<OthersDocPreFillModel>(
        future: othersPrefillFuture,
        builder: (context, snapshotPreFill) {
          if (snapshotPreFill.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotPreFill.hasData) {
            return OthersEditPopup(
              url: snapshotPreFill.data!.url,
              fileName: snapshotPreFill.data!.fileName,
              expDate: snapshotPreFill.data!.expDate,
              documentName: snapshotPreFill.data!.idOfDocument,
              title: 'Edit Other Document',
              employeeId: widget.employeeId,
              otherDocId: doc.otherDocId,
            );
          }
          // Report this prefill request's error, not the list stream's.
          return ErrorPopUp(
            title: "Received Error",
            text: snapshotPreFill.error.toString(),
          );
        },
      ),
    ).then((_) => _loadData());
  }

  void _confirmDelete(OthersDocModel doc) {
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
          title: 'Delete Document',
          onCancel: () {
            dialogIsOpen = false;
            Navigator.pop(context);
          },
          onDelete: () async {
            setState(() => _isLoading = true);
            if (dialogIsOpen) setDialogState(() {});
            try {
              final result = await deleteOthersDocumentData(
                context: context,
                otherDocumentId: doc.otherDocId,
              );
              dialogIsOpen = false;
              Navigator.pop(context);
              if (result.success) {
                _loadData();
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
          child: StreamBuilder<List<OthersDocModel>>(
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
                      AppStringHRNoData.othersnNoData,
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
                    idLabel: 'ID: ${doc.idOfDocument}',
                    fileName: doc.fileName,
                    onTap: () => _openDocument(doc),
                    onEdit: _isReadOnly ? null : () => _editDocument(doc),
                    onPrint: () => _openDocument(doc),
                    onDownload: () => downloadDocument(
                      context: context,
                      fileUrl: doc.url,
                      documentName: doc.fileName,
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
