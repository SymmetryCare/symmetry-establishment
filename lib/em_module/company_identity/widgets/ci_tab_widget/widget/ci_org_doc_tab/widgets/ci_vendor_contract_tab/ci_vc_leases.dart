import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/establishment_resources/establishment_string_manager.dart';
import 'package:prohealth/presentation/screens/em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../../../app/constants/app_config.dart';
import '../../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../../app/resources/provider/delete_popup_provider.dart';
import '../../../../../../../../../../app/services/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import '../../../../../../../../../../data/api_data/establishment_data/company_identity/new_org_doc.dart';
import '../../../../../../../../../../data/appconfige_data/app_confige_data.dart';
import '../../../../../../../../../widgets/error_popups/delete_success_popup.dart';
import '../../../files_constant-widget.dart';
import '../org_add_popup_const.dart';
class VendorContractLeasesProvider with ChangeNotifier {
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController docIdController = TextEditingController();
  final TextEditingController calenderController = TextEditingController();
  final TextEditingController idOfDocController = TextEditingController();
  final TextEditingController daysController = TextEditingController(text: "1");

  final StreamController<List<NewOrgDocument>> documentStream =
  StreamController<List<NewOrgDocument>>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDocuments(BuildContext context, int docTypeId, int subDocTypeId) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,
        docTypeId,
        subDocTypeId,
        1,
        50,
      );
      documentStream.add(documents);
    } catch (e) {
      documentStream.addError(e);
    }
  }

  Future<void> onEdit(NewOrgDocument doc, BuildContext context) async {
    final snapshotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);
    docNameController.text = snapshotPrefill.docName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return OrgDocNewEditPopup(
          title: EditPopupString.editLeases,
          orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid,
          docTypeId: snapshotPrefill.documentTypeId,
          subDocTypeId: snapshotPrefill.documentSubTypeId,
          idOfDoc: snapshotPrefill.idOfDocument,
          docName: snapshotPrefill.docName,
          expiryType: snapshotPrefill.expiryType,
          threshhold: snapshotPrefill.threshold,
          expiryDate: snapshotPrefill.expiryDate,
          expiryReminder: snapshotPrefill.expiryReminder,
          docTypeText: AppStringEM.vendorContracts,
          subDocTypeText: AppStringEM.leases,
        );
      },
    );
  }

  Future<void> onDelete(NewOrgDocument doc, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteLeases,
          loadingDuration: _isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoading(true);
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              Navigator.pop(context); // Close confirmation dialog
              showDialog(
                context: context,
                builder: (context) => DeleteSuccessPopup(),
              );
            } finally {
              setLoading(false);
            }
          },
        );
      },
    );
  }

  void disposeControllers() {
    docNameController.dispose();
    docIdController.dispose();
    calenderController.dispose();
    idOfDocController.dispose();
    daysController.dispose();
    documentStream.close();
  }
}
class VendorContractLeases extends StatelessWidget {
  final int docId;
  final int subDocID;

  const VendorContractLeases({
    super.key,
    required this.docId,
    required this.subDocID,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendorContractLeasesProvider(),
      child: Consumer<VendorContractLeasesProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              PoliciesProcedureList(
                controller: provider.documentStream,
                fetchDocuments: (context) => getNewOrgDocfetch(
                  context,
                  FrontendConfigStore.data!.config.vendorContracts,
                  // AppConfig.vendorContracts,
                  FrontendConfigStore.data!.config.subDocId6Leases,
                  // AppConfig.subDocId6Leases,
                  1,
                  50,
                ),
                emptyMessage: ErrorMessageString.noLeases,
                onEdit: (NewOrgDocument doc) async {
                  await provider.onEdit(doc, context);
                },
                onDelete: (NewOrgDocument doc) async {
                  await provider.onDelete(doc, context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

